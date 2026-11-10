#!/usr/bin/env python3
"""Browser smoke test for the Flutter web build.

This test deliberately avoids signing in or writing to Firebase. It verifies
that the compiled app boots and keeps its Flutter view mounted at mobile and
desktop viewport sizes.
"""
from __future__ import annotations

import sys
from playwright.sync_api import sync_playwright


BASE_URL = "http://127.0.0.1:4173"


def main() -> int:
    page_errors: list[str] = []

    with sync_playwright() as playwright:
        browser = playwright.chromium.launch(headless=True)
        page = browser.new_page(viewport={"width": 390, "height": 844})
        page.on("pageerror", lambda error: page_errors.append(str(error)))

        response = page.goto(BASE_URL, wait_until="domcontentloaded", timeout=30_000)
        if response is None or not response.ok:
            raise AssertionError(
                f"Web app did not return a successful HTTP response: "
                f"{response.status if response else 'no response'}"
            )

        page.wait_for_selector("flt-glass-pane", state="attached", timeout=90_000)
        page.wait_for_function(
            """() => {
              const host = document.querySelector('flt-glass-pane');
              if (!host) return false;
              const rect = host.getBoundingClientRect();
              return rect.width > 0 && rect.height > 0;
            }""",
            timeout=30_000,
        )

        # Confirm the same compiled app remains mounted at a desktop viewport.
        page.set_viewport_size({"width": 1365, "height": 900})
        page.wait_for_timeout(1_000)
        page.wait_for_function(
            """() => {
              const host = document.querySelector('flt-glass-pane');
              if (!host) return false;
              const rect = host.getBoundingClientRect();
              return rect.width > 0 && rect.height > 0;
            }""",
            timeout=15_000,
        )

        browser.close()

    if page_errors:
        raise AssertionError("Uncaught browser exceptions:\n" + "\n".join(page_errors))

    print("PASS: Flutter web app booted at mobile and desktop viewport sizes.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:  # Keep CI output concise and actionable.
        print(f"FAIL: {error}", file=sys.stderr)
        raise
