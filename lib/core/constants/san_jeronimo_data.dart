class AcopioPoint {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String description;
  final String schedule;

  const AcopioPoint({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.description,
    required this.schedule,
  });
}

const List<String> kNeighborhoods = [
  'Centro',
  'Ttío',
  'Conchacalla',
  'Pillao Matao',
  'Waynapata',
  'Kantupata',
  'Chimpahuaylla',
  'Sucso Aucaylle',
  'Huaccoto',
  'Otra zona',
];

const Map<String, String> kNeighborhoodToZone = {
  'Centro': 'Zona Centro',
  'Ttío': 'Zona Ttío',
  'Conchacalla': 'Zona Conchacalla',
  'Pillao Matao': 'Zona Pillao Matao',
  'Waynapata': 'Zona Waynapata',
  'Kantupata': 'Zona Kantupata',
  'Chimpahuaylla': 'Zona Conchacalla',
  'Sucso Aucaylle': 'Zona Centro',
  'Huaccoto': 'Zona Pillao Matao',
  'Otra zona': 'Zona Centro',
};

const Map<String, String> kZoneToDocId = {
  'Zona Centro': 'zona_centro',
  'Zona Ttío': 'zona_ttio',
  'Zona Conchacalla': 'zona_conchacalla',
  'Zona Pillao Matao': 'zona_pillao_matao',
  'Zona Waynapata': 'zona_waynapata',
  'Zona Kantupata': 'zona_kantupata',
};

const List<String> kZoneNames = [
  'Zona Centro',
  'Zona Ttío',
  'Zona Conchacalla',
  'Zona Pillao Matao',
  'Zona Waynapata',
  'Zona Kantupata',
];

const List<AcopioPoint> kAcopioPoints = [
  AcopioPoint(
    id: 'plaza_principal',
    name: 'Plaza Principal San Jerónimo',
    lat: -13.5487,
    lng: -71.8769,
    description: 'Plaza central, esquina con Av. La Cultura',
    schedule: 'Lun–Sáb 6:00 AM – 10:00 AM',
  ),
  AcopioPoint(
    id: 'mercado_san_jeronimo',
    name: 'Mercado San Jerónimo',
    lat: -13.5501,
    lng: -71.8755,
    description: 'Frente al mercado central, Av. Prolongación Garcilaso',
    schedule: 'Lun–Sáb 6:00 AM – 10:00 AM',
  ),
  AcopioPoint(
    id: 'parque_ttio',
    name: 'Parque Ttío',
    lat: -13.5523,
    lng: -71.8801,
    description: 'Esquina del parque Ttío, ingreso principal',
    schedule: 'Mar, Jue, Sáb 6:30 AM – 8:30 AM',
  ),
  AcopioPoint(
    id: 'av_la_cultura',
    name: 'Av. La Cultura Km 7',
    lat: -13.5465,
    lng: -71.8743,
    description: 'Paradero La Cultura, frente al estadio',
    schedule: 'Lun, Mié, Vie 7:00 AM – 9:00 AM',
  ),
  AcopioPoint(
    id: 'colegio_velasco',
    name: 'Colegio Alejandro Velasco Astete',
    lat: -13.5510,
    lng: -71.8790,
    description: 'Esquina del colegio, calle lateral',
    schedule: 'Lun, Mié, Vie 7:00 AM – 9:00 AM',
  ),
  AcopioPoint(
    id: 'parque_conchacalla',
    name: 'Parque Infantil Conchacalla',
    lat: -13.5535,
    lng: -71.8820,
    description: 'Ingreso al parque infantil, zona Conchacalla',
    schedule: 'Lun, Jue 7:00 AM – 10:00 AM',
  ),
];

// Centro San Jerónimo (para cámara inicial del mapa)
const double kSanJeronimoLat = -13.5487;
const double kSanJeronimoLng = -71.8769;
