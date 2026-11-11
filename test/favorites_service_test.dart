import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirsir_travel_morocco/services/favorites_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('starts with an empty favorites list', () async {
    expect(await FavoritesService.getFavorites(), isEmpty);
  });

  test('toggleFavorite adds then removes a place', () async {
    expect(await FavoritesService.toggleFavorite('طنجة'), isTrue);
    expect(await FavoritesService.getFavorites(), contains('طنجة'));
    expect(await FavoritesService.isFavorite('طنجة'), isTrue);
    expect(await FavoritesService.toggleFavorite('طنجة'), isTrue);
    expect(await FavoritesService.getFavorites(), isEmpty);
    expect(await FavoritesService.isFavorite('طنجة'), isFalse);
  });

  test('does not store blank place names', () async {
    expect(await FavoritesService.toggleFavorite('  '), isFalse);
    expect(await FavoritesService.getFavorites(), isEmpty);
  });
}
