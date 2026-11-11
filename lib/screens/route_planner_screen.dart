import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class RoutePlannerScreen extends StatefulWidget {
  final String language;

  const RoutePlannerScreen({super.key, this.language = 'ar'});

  @override
  State<RoutePlannerScreen> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
  String _text(String ar, String en, String fr, String es) {
    switch (widget.language) {
      case 'en': return en;
      case 'fr': return fr;
      case 'es': return es;
      default: return ar;
    }
  }

  static const Map<String, LatLng> _cities = {
    'طنجة': LatLng(35.7595, -5.8340),
    'تطوان': LatLng(35.5889, -5.3626),
    'المضيق': LatLng(35.6850, -5.3250),
    'مرتيل': LatLng(35.6167, -5.2750),
    'الرباط': LatLng(34.0209, -6.8416),
    'الدار البيضاء': LatLng(33.5731, -7.5898),
    'المحمدية': LatLng(33.6866, -7.3830),
    'الجديدة': LatLng(33.2316, -8.5007),
    'آسفي': LatLng(32.2994, -9.2372),
    'الصويرة': LatLng(31.5085, -9.7595),
    'أكادير': LatLng(30.4278, -9.5981),
    'مراكش': LatLng(31.6295, -7.9811),
    'فاس': LatLng(34.0331, -5.0003),
    'مكناس': LatLng(33.8935, -5.5473),
    'وجدة': LatLng(34.6814, -1.9086),
    'الناظور': LatLng(35.1681, -2.9335),
    'الحسيمة': LatLng(35.2517, -3.9372),
    'شفشاون': LatLng(35.1688, -5.2636),
    'العرائش': LatLng(35.1932, -6.1561),
    'القنيطرة': LatLng(34.2610, -6.5802),
    'بني ملال': LatLng(32.3373, -6.3498),
    'خريبكة': LatLng(32.8811, -6.9063),
    'ورزازات': LatLng(30.9335, -6.9370),
    'العيون': LatLng(27.1536, -13.2033),
    'الداخلة': LatLng(23.6848, -15.9570),
  };

  String _origin = 'طنجة';
  String _destination = 'الدار البيضاء';
  final MapController _mapController = MapController();
  bool _mapReady = false;
  bool _loading = false;
  String? _error;
  List<LatLng> _route = [];
  double? _distanceKm;
  double? _durationMinutes;

  Future<void> _findRoute() async {
    if (_origin == _destination) {
      setState(() => _error = _text('اختر مدينتين مختلفتين.', 'Choose two different cities.', 'Choisissez deux villes différentes.', 'Elige dos ciudades diferentes.'));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _route = [];
      _distanceKm = null;
      _durationMinutes = null;
    });

    try {
      final start = _cities[_origin]!;
      final end = _cities[_destination]!;
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 25));
      if (response.statusCode != 200) throw Exception('route service unavailable');
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = payload['routes'] as List?;
      if (payload['code'] != 'Ok' || routes == null || routes.isEmpty) {
        throw Exception('route not found');
      }
      final first = routes.first as Map<String, dynamic>;
      final geometry = first['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List;
      final points = coordinates.map((point) {
        final pair = point as List;
        return LatLng((pair[1] as num).toDouble(), (pair[0] as num).toDouble());
      }).toList();
      if (!mounted) return;
      setState(() {
        _route = points;
        _distanceKm = (first['distance'] as num).toDouble() / 1000;
        _durationMinutes = (first['duration'] as num).toDouble() / 60;
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _mapReady && points.isNotEmpty) {
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(points),
              padding: const EdgeInsets.all(42),
            ),
          );
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _text('تعذر حساب المسار الآن. يمكنك فتح الاتجاهات في خرائط Google.', 'Could not calculate the route. You can open directions in Google Maps.', 'Impossible de calculer l’itinéraire. Vous pouvez ouvrir les directions dans Google Maps.', 'No se pudo calcular la ruta. Puedes abrir las indicaciones en Google Maps.');
      });
    }
  }

  Future<void> _openGoogleMaps() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${Uri.encodeComponent(_origin)}'
      '&destination=${Uri.encodeComponent(_destination)}'
      '&travelmode=driving',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final start = _cities[_origin]!;
    final end = _cities[_destination]!;
    final center = _route.isNotEmpty
        ? _route[_route.length ~/ 2]
        : LatLng((start.latitude + end.latitude) / 2, (start.longitude + end.longitude) / 2);

    return Scaffold(
      appBar: AppBar(title: Text(_text('مخطط الطريق داخل المغرب', 'Route planner in Morocco', 'Planificateur d’itinéraire au Maroc', 'Planificador de rutas en Marruecos'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _origin,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: _text('مدينة الانطلاق', 'Departure city', 'Ville de départ', 'Ciudad de salida'),
                    prefixIcon: Icon(Icons.trip_origin),
                  ),
                  items: _cities.keys.map((city) => DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  )).toList(),
                  onChanged: _loading ? null : (value) {
                    if (value != null) {
                      setState(() {
                        _origin = value;
                        _route = [];
                        _distanceKm = null;
                        _durationMinutes = null;
                        _error = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _destination,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: _text('مدينة الوصول', 'Destination city', 'Ville d’arrivée', 'Ciudad de destino'),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  items: _cities.keys.map((city) => DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  )).toList(),
                  onChanged: _loading ? null : (value) {
                    if (value != null) {
                      setState(() {
                        _destination = value;
                        _route = [];
                        _distanceKm = null;
                        _durationMinutes = null;
                        _error = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _loading ? null : _findRoute,
                        icon: _loading
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.alt_route),
                        label: Text(_loading ? _text('جارٍ حساب الطريق…', 'Calculating route…', 'Calcul de l’itinéraire…', 'Calculando ruta…') : _text('احسب الطريق', 'Calculate route', 'Calculer l’itinéraire', 'Calcular ruta')),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: _text('تبديل المدينتين', 'Swap cities', 'Inverser les villes', 'Intercambiar ciudades'),
                      onPressed: _loading ? null : () => setState(() {
                        final previous = _origin;
                        _origin = _destination;
                        _destination = previous;
                        _route = [];
                        _distanceKm = null;
                        _durationMinutes = null;
                        _error = null;
                      }),
                      icon: const Icon(Icons.swap_vert),
                    ),
                  ],
                ),
                if (_distanceKm != null && _durationMinutes != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Chip(avatar: const Icon(Icons.route, size: 18), label: Text(_text('${_distanceKm!.round()} كم تقريباً', 'About ${_distanceKm!.round()} km', 'Environ ${_distanceKm!.round()} km', 'Aproximadamente ${_distanceKm!.round()} km'))),
                        Chip(avatar: const Icon(Icons.schedule, size: 18), label: Text(_text('${(_durationMinutes! / 60).floor()} س ${(_durationMinutes! % 60).round()} د', '${(_durationMinutes! / 60).floor()} h ${(_durationMinutes! % 60).round()} min', '${(_durationMinutes! / 60).floor()} h ${(_durationMinutes! % 60).round()} min', '${(_durationMinutes! / 60).floor()} h ${(_durationMinutes! % 60).round()} min'))),
                      ],
                    ),
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      children: [
                        Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                        if (_origin != _destination)
                          TextButton.icon(
                            onPressed: _loading ? null : _findRoute,
                            icon: const Icon(Icons.refresh),
                            label: Text(_text('إعادة المحاولة', 'Retry', 'Réessayer', 'Reintentar')),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: _route.isEmpty ? 5.4 : 6.2,
                onMapReady: () => _mapReady = true,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'ma.sirsirtravel.morocco',
                ),
                if (_route.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(points: _route, strokeWidth: 5, color: const Color(0xFFC62828)),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: start,
                      width: 42,
                      height: 48,
                      child: const Icon(Icons.location_on, color: Color(0xFF16834A), size: 40),
                    ),
                    Marker(
                      point: end,
                      width: 42,
                      height: 48,
                      child: const Icon(Icons.flag, color: Color(0xFFC62828), size: 36),
                    ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      '© OpenStreetMap contributors',
                      onTap: () => launchUrl(Uri.parse('https://www.openstreetmap.org/copyright')),
                    ),
                    TextSourceAttribution('Routing: OSRM'),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openGoogleMaps,
                icon: const Icon(Icons.open_in_new),
                label: Text(_text('افتح الاتجاهات في خرائط Google', 'Open directions in Google Maps', 'Ouvrir l’itinéraire dans Google Maps', 'Abrir indicaciones en Google Maps')),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Text(
              _text('المسافة والمدة تقدير آلي للمسار البري وليستا ضماناً لوقت الوصول. تحقق من حالة الطرق والإغلاقات قبل السفر.', 'Distance and duration are estimates for road travel, not a guaranteed arrival time. Check road conditions and closures before travelling.', 'La distance et la durée sont des estimations routières et ne garantissent pas l’heure d’arrivée. Vérifiez l’état des routes et les fermetures avant de partir.', 'La distancia y la duración son estimaciones por carretera, no garantizan la hora de llegada. Comprueba el estado de las carreteras y los cierres antes de viajar.'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
