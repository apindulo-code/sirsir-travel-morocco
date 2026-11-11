#!/usr/bin/env python3
"""Browser smoke test for the compiled Flutter web build.

This test does not sign in or write to Firebase. It checks that Flutter's
rendered view is mounted at mobile and desktop viewport sizes. Flutter's
internal DOM changed across engine versions, so do not depend on the
implementation-specific flt-glass-pane element alone.
"""
from __future__ import annotations

import sys
from playwright.sync_api import TimeoutError as PlaywrightTimeoutError
from playwright.sync_api import sync_playwright


BASE_URL = "http://127.0.0.1:4173"
FLUTTER_VIEW_SCRIPT = """() => {
  const selectors = ['flutter-view', 'flt-glass-pane', 'canvas'];
  for (const selector of selectors) {
    for (const element of document.querySelectorAll(selector)) {
      const rect = element.getBoundingClientRect();
      if (rect.width > 0 && rect.height > 0) {
        return {selector, width: rect.width, height: rect.height};
      }
    }
  }
  return false;
}"""


def main() -> int:
    page_errors: list[str] = []
    failed_requests: list[str] = []

    with sync_playwright() as playwright:
        browser = playwright.chromium.launch(headless=True)
        page = browser.new_page(viewport={"width": 390, "height": 844})
        page.on("pageerror", lambda error: page_errors.append(str(error)))
        page.on(
            "requestfailed",
            lambda request: failed_requests.append(
                f"{request.method} {request.url}: "
                f"{request.failure or 'request failed'}"
            ),
        )

        response = page.goto(
            BASE_URL, wait_until="domcontentloaded", timeout=30_000
        )
        if response is None or not response.ok:
            raise AssertionError(
                "Web app did not return a successful HTTP response: "
                f"{response.status if response else 'no response'}"
            )

        try:
            page.wait_for_function(FLUTTER_VIEW_SCRIPT, timeout=90_000)
        except PlaywrightTimeoutError as error:
            diagnostics = page.evaluate(
                """() => ({
                  title: document.title,
                  readyState: document.readyState,
                  bodyText: document.body?.innerText?.slice(0, 1000) || '',
                  bodyHTML: document.body?.innerHTML?.slice(0, 3000) || '',
                  flutterElements: Array.from(
                    document.querySelectorAll(
                      'flutter-view, flt-glass-pane, flt-semantics-host, canvas'
                    )
                  ).map(element => ({
                    tag: element.tagName.toLowerCase(),
                    width: element.getBoundingClientRect().width,
                    height: element.getBoundingClientRect().height
                  })),
                  scripts: Array.from(document.scripts).map(script => script.src)
                })"""
            )
            raise AssertionError(
                "Flutter rendered view did not become visible within 90 seconds. "
                f"Browser diagnostics: {diagnostics}; "
                f"page errors: {page_errors}; failed requests: {failed_requests}"
            ) from error

        mobile_view = page.evaluate(FLUTTER_VIEW_SCRIPT)
        if page_errors:
            raise AssertionError(
                "Uncaught browser exceptions during mobile startup: "
                + " | ".join(page_errors)
            )

        # Confirm the same compiled app remains rendered at desktop size.
        page.set_viewport_size({"width": 1365, "height": 900})
        page.wait_for_function(FLUTTER_VIEW_SCRIPT, timeout=15_000)
        desktop_view = page.evaluate(FLUTTER_VIEW_SCRIPT)

        if page_errors:
            raise AssertionError(
                "Uncaught browser exceptions: " + " | ".join(page_errors)
            )

        browser.close()

    print(
        "PASS: Flutter web app rendered at mobile and desktop viewport sizes. "
        f"Mobile: {mobile_view}; desktop: {desktop_view}"
    )
    if failed_requests:
        print(
            "WARNING: Browser reported failed requests: "
            + " | ".join(failed_requests)
        )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:  # Keep CI output concise and actionable.
        print(f"FAIL: {error}", file=sys.stderr)
        raise
