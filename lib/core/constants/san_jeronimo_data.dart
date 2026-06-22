import 'package:google_maps_flutter/google_maps_flutter.dart';

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

class CollectionRoute {
  final String id;
  final String number;
  final String name;
  final String type; // 'organic' | 'general'
  final List<int> days; // 1=Mon,2=Tue,3=Wed,4=Thu,5=Fri,6=Sat,7=Sun
  final String daysLabel;
  final String timeStart;
  final String timeEnd;
  final List<String> sectors;
  final List<String> streets;
  final List<LatLng> routePoints; // approximate polyline

  const CollectionRoute({
    required this.id,
    required this.number,
    required this.name,
    required this.type,
    required this.days,
    required this.daysLabel,
    required this.timeStart,
    required this.timeEnd,
    required this.sectors,
    required this.streets,
    required this.routePoints,
  });

  LatLng get center {
    if (routePoints.isEmpty) return const LatLng(kSanJeronimoLat, kSanJeronimoLng);
    final avgLat = routePoints.map((p) => p.latitude).reduce((a, b) => a + b) / routePoints.length;
    final avgLng = routePoints.map((p) => p.longitude).reduce((a, b) => a + b) / routePoints.length;
    return LatLng(avgLat, avgLng);
  }
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

// ─── RUTAS DE RESIDUOS ORGÁNICOS ───────────────────────────────────────────

const List<CollectionRoute> kOrganicRoutes = [
  CollectionRoute(
    id: 'org_ruta1',
    number: 'O-1',
    name: 'LARAPA',
    type: 'organic',
    days: [2, 5], // Martes, Viernes
    daysLabel: 'Mar y Vie',
    timeStart: '10:00',
    timeEnd: '13:00',
    sectors: ['Urb. Larapa'],
    streets: ['Av. 12', 'Av. 10', 'Av. 8', 'Av. 5', 'Av. 1', 'Los Quishuares', 'Los Capulíes', 'U. Andina', 'Av. La Cultura'],
    routePoints: [
      LatLng(-13.5415, -71.8720),
      LatLng(-13.5430, -71.8700),
      LatLng(-13.5445, -71.8683),
      LatLng(-13.5460, -71.8695),
      LatLng(-13.5470, -71.8715),
      LatLng(-13.5455, -71.8735),
      LatLng(-13.5440, -71.8750),
      LatLng(-13.5425, -71.8760),
      LatLng(-13.5415, -71.8740),
    ],
  ),
  CollectionRoute(
    id: 'org_ruta2',
    number: 'O-2',
    name: 'CHIMPAHUAYLLA',
    type: 'organic',
    days: [1, 4], // Lunes, Jueves
    daysLabel: 'Lun y Jue',
    timeStart: '05:00',
    timeEnd: '09:00',
    sectors: ['Zona Chimpahuaylla'],
    streets: ['Av. Manco Ccapac', 'Vía Expresa', 'Av. Evitamiento', 'Colegio Alejandro Velasco Astete', 'Plaza Chimpahuaylla'],
    routePoints: [
      LatLng(-13.5515, -71.8790),
      LatLng(-13.5530, -71.8808),
      LatLng(-13.5548, -71.8825),
      LatLng(-13.5560, -71.8812),
      LatLng(-13.5545, -71.8793),
      LatLng(-13.5528, -71.8775),
      LatLng(-13.5515, -71.8790),
    ],
  ),
  CollectionRoute(
    id: 'org_ruta3',
    number: 'O-3',
    name: 'CENTRO HISTÓRICO',
    type: 'organic',
    days: [3, 6], // Miércoles, Sábados
    daysLabel: 'Mié y Sáb',
    timeStart: '05:00',
    timeEnd: '09:00',
    sectors: ['Casco urbano central'],
    streets: ['Calle Lima', 'Calle San Martín', 'Ramón Castilla', 'Calle Perú', 'Av. Manco Ccapac', 'Lloclla Pata', 'Mercado Vinocanchón', 'Plaza de San Jerónimo'],
    routePoints: [
      LatLng(-13.5480, -71.8775),
      LatLng(-13.5490, -71.8783),
      LatLng(-13.5502, -71.8776),
      LatLng(-13.5510, -71.8762),
      LatLng(-13.5498, -71.8750),
      LatLng(-13.5485, -71.8756),
      LatLng(-13.5475, -71.8768),
      LatLng(-13.5480, -71.8775),
    ],
  ),
  CollectionRoute(
    id: 'org_ruta4',
    number: 'O-4',
    name: 'RETAMALES',
    type: 'organic',
    days: [2, 5], // Martes, Viernes
    daysLabel: 'Mar y Vie',
    timeStart: '05:00',
    timeEnd: '09:00',
    sectors: ['Zona Retamales'],
    streets: ['Calle 24 de Junio', 'C. Lima', 'José Gálvez', 'Leoncio Prado', 'Los Triunfadores', 'Vinocanchón', 'Lloclla Pata'],
    routePoints: [
      LatLng(-13.5498, -71.8748),
      LatLng(-13.5512, -71.8742),
      LatLng(-13.5525, -71.8730),
      LatLng(-13.5518, -71.8715),
      LatLng(-13.5505, -71.8720),
      LatLng(-13.5492, -71.8733),
      LatLng(-13.5498, -71.8748),
    ],
  ),
];

// ─── RUTAS DE RECOLECCIÓN GENERAL ─────────────────────────────────────────

const List<CollectionRoute> kGeneralRoutes = [
  // LUNES Y JUEVES
  CollectionRoute(
    id: 'gen_ruta1',
    number: 'G-1',
    name: 'MIRAFLORES / NORTE',
    type: 'general',
    days: [1, 4],
    daysLabel: 'Lun y Jue',
    timeStart: '05:00',
    timeEnd: '10:00',
    sectors: ['Miraflores', 'Constructores', 'Villa el Carmen', 'Urubambilla', 'Los Cedros', 'Fray Martin de Porras', 'Sta Martha', 'Capullanas'],
    streets: ['Prolongación Av. La Cultura', 'Av. La Cultura'],
    routePoints: [
      LatLng(-13.5435, -71.8760),
      LatLng(-13.5448, -71.8742),
      LatLng(-13.5460, -71.8728),
      LatLng(-13.5472, -71.8715),
      LatLng(-13.5460, -71.8700),
      LatLng(-13.5445, -71.8718),
      LatLng(-13.5432, -71.8735),
      LatLng(-13.5435, -71.8760),
    ],
  ),
  CollectionRoute(
    id: 'gen_ruta2',
    number: 'G-2',
    name: 'PRIMAVERA / CHIMPAHUAYLLA',
    type: 'general',
    days: [1, 4],
    daysLabel: 'Lun y Jue',
    timeStart: '05:00',
    timeEnd: '10:00',
    sectors: ['Colegio AVA', 'Primavera', 'Presbítero Andrea García', '28 de Julio', 'Chimpahuaylla', 'Las Ñustas', 'Villa del Sol'],
    streets: ['Av. Evitamiento', 'Av. Manco Ccapac'],
    routePoints: [
      LatLng(-13.5520, -71.8800),
      LatLng(-13.5535, -71.8815),
      LatLng(-13.5550, -71.8825),
      LatLng(-13.5542, -71.8808),
      LatLng(-13.5528, -71.8792),
      LatLng(-13.5515, -71.8778),
      LatLng(-13.5520, -71.8800),
    ],
  ),
  CollectionRoute(
    id: 'gen_ruta3',
    number: 'G-3',
    name: 'ALTIVA CANAS / SAN LORENZO',
    type: 'general',
    days: [1, 4],
    daysLabel: 'Lun y Jue',
    timeStart: '05:00',
    timeEnd: '10:00',
    sectors: ['Altiva Canas', 'Nueva Alianza', 'San Lorenzo', 'Inticancha', 'Casuarinas', 'Villa Rinconada', 'Sta Bárbara'],
    streets: ['San Lorenzo', 'Inti Qancha'],
    routePoints: [
      LatLng(-13.5540, -71.8750),
      LatLng(-13.5555, -71.8738),
      LatLng(-13.5568, -71.8752),
      LatLng(-13.5558, -71.8770),
      LatLng(-13.5543, -71.8765),
      LatLng(-13.5540, -71.8750),
    ],
  ),
  CollectionRoute(
    id: 'gen_ruta4',
    number: 'G-4',
    name: 'VERSALLES / LARAPA',
    type: 'general',
    days: [1, 4],
    daysLabel: 'Lun y Jue',
    timeStart: '05:00',
    timeEnd: '10:00',
    sectors: ['Penal de varones', 'Penal de mujeres', 'Los Cipreces de Versalles', 'Alboreda', 'Terrasol', 'Los Kantus de Larapa'],
    streets: ['APV La Molina', 'Portales de Versalles'],
    routePoints: [
      LatLng(-13.5460, -71.8672),
      LatLng(-13.5475, -71.8658),
      LatLng(-13.5490, -71.8645),
      LatLng(-13.5505, -71.8660),
      LatLng(-13.5492, -71.8678),
      LatLng(-13.5475, -71.8688),
      LatLng(-13.5460, -71.8672),
    ],
  ),
  CollectionRoute(
    id: 'gen_ruta5',
    number: 'G-5',
    name: 'LARAPITA / SUR',
    type: 'general',
    days: [1, 4],
    daysLabel: 'Lun y Jue',
    timeStart: '05:00',
    timeEnd: '10:00',
    sectors: ['Larapita', 'Praderas del Sur', 'Feudatarios de Larapa', 'Machu Picol', 'Huayna Picol'],
    streets: ['Berma', 'Plaza de Armas', 'Puente - Control'],
    routePoints: [
      LatLng(-13.5450, -71.8730),
      LatLng(-13.5465, -71.8718),
      LatLng(-13.5480, -71.8705),
      LatLng(-13.5470, -71.8690),
      LatLng(-13.5455, -71.8702),
      LatLng(-13.5443, -71.8718),
      LatLng(-13.5450, -71.8730),
    ],
  ),
  // MARTES Y VIERNES
  CollectionRoute(
    id: 'gen_ruta6',
    number: 'G-6',
    name: 'LARAPA RESIDENCIAL',
    type: 'general',
    days: [2, 5],
    daysLabel: 'Mar y Vie',
    timeStart: '05:00',
    timeEnd: '10:00',
    sectors: ['Avenida 5', 'Avenida 2', 'Residencia Jardines de Larapa', 'Feudatarios', 'Condominio las Rocas', 'Colegio de Ingenieros', 'Universidad Andina'],
    streets: ['Av. 1', 'Av. 4', 'Av. 8', 'Av. 10', 'Av. 12', 'Prolongación Av. Cultura'],
    routePoints: [
      LatLng(-13.5408, -71.8695),
      LatLng(-13.5420, -71.8675),
      LatLng(-13.5438, -71.8660),
      LatLng(-13.5452, -71.8672),
      LatLng(-13.5440, -71.8690),
      LatLng(-13.5425, -71.8708),
      LatLng(-13.5408, -71.8695),
    ],
  ),
  CollectionRoute(
    id: 'gen_ruta7',
    number: 'G-7',
    name: 'RETAMALES / ALMUDENA',
    type: 'general',
    days: [2, 5],
    daysLabel: 'Mar y Vie',
    timeStart: '05:00',
    timeEnd: '10:00',
    sectors: ['Lloclla Pata', 'Allpa Orcona', 'Triunfadores', 'Retamales', 'Hospital', 'Almudena', 'El Bosquecito'],
    streets: ['Prolongación calle Lima', 'Plazoleta 2 de Noviembre', 'Calle 24 de Junio', 'Prolong. Túpac Amaru'],
    routePoints: [
      LatLng(-13.5505, -71.8755),
      LatLng(-13.5518, -71.8742),
      LatLng(-13.5530, -71.8728),
      LatLng(-13.5522, -71.8712),
      LatLng(-13.5508, -71.8718),
      LatLng(-13.5495, -71.8735),
      LatLng(-13.5505, -71.8755),
    ],
  ),
  CollectionRoute(
    id: 'gen_ruta8',
    number: 'G-8',
    name: 'VALLECITO / TABLÓN',
    type: 'general',
    days: [2, 5],
    daysLabel: 'Mar y Vie',
    timeStart: '05:00',
    timeEnd: '10:00',
    sectors: ['Centro Poblado Vallecito', 'Picol Orccompucyo', 'Tablón', '30 de Septiembre', 'Nuevo Horizonte', 'APV Los Rosales', 'APV Huayrancalle'],
    streets: ['Grifo Santa Elena', 'Subida a Pillao Matao', 'Pasaje Matamoros'],
    routePoints: [
      LatLng(-13.5555, -71.8760),
      LatLng(-13.5570, -71.8748),
      LatLng(-13.5582, -71.8762),
      LatLng(-13.5568, -71.8778),
      LatLng(-13.5550, -71.8772),
      LatLng(-13.5555, -71.8760),
    ],
  ),
  CollectionRoute(
    id: 'gen_ruta9',
    number: 'G-9',
    name: 'FUNDO ACOYOC / WIRACOCHA',
    type: 'general',
    days: [2, 5],
    daysLabel: 'Mar y Vie',
    timeStart: '05:00',
    timeEnd: '10:00',
    sectors: ['Fundo Acoyoc', 'Tambillo', 'La Encantada', 'Ccollana', 'Anden-Anden', 'Chahuanccosco', 'Sector Wiracocha'],
    streets: ['Prolong. Mancco Ccapac', 'Av. La Cultura', 'Continental', 'Planta de Seda Cusco'],
    routePoints: [
      LatLng(-13.5472, -71.8800),
      LatLng(-13.5487, -71.8815),
      LatLng(-13.5502, -71.8802),
      LatLng(-13.5512, -71.8785),
      LatLng(-13.5498, -71.8770),
      LatLng(-13.5483, -71.8782),
      LatLng(-13.5472, -71.8800),
    ],
  ),
  CollectionRoute(
    id: 'gen_ruta10',
    number: 'G-10',
    name: 'PILLAO MATAO / TRIGALES',
    type: 'general',
    days: [2, 5],
    daysLabel: 'Mar y Vie',
    timeStart: '05:00',
    timeEnd: '10:00',
    sectors: ['Pillao Matao (solo martes)', 'Tejas y Ladrillos', 'Collparo (solo viernes)', 'Trigales', 'APV Los Arenales', 'Ángeles de María'],
    streets: ['Berma Central', 'Plaza', 'Jusccapampa (solo martes)'],
    routePoints: [
      LatLng(-13.5578, -71.8768),
      LatLng(-13.5592, -71.8755),
      LatLng(-13.5605, -71.8770),
      LatLng(-13.5590, -71.8785),
      LatLng(-13.5575, -71.8778),
      LatLng(-13.5578, -71.8768),
    ],
  ),
  // MIÉRCOLES Y SÁBADOS
  CollectionRoute(
    id: 'gen_ruta11',
    number: 'G-11',
    name: 'GRANJA KAYRA / OESTE',
    type: 'general',
    days: [3, 6],
    daysLabel: 'Mié y Sáb',
    timeStart: '05:00',
    timeEnd: '10:00',
    sectors: ['Los Álamos', 'Los Cipreces', 'Los Nogales', 'Mesa Redonda', 'Granja Kayra'],
    streets: ['Control', 'Av. Mancco Capac', 'Pampa Chacra', 'Prolong. Mi Perú'],
    routePoints: [
      LatLng(-13.5488, -71.8830),
      LatLng(-13.5502, -71.8848),
      LatLng(-13.5518, -71.8838),
      LatLng(-13.5505, -71.8818),
      LatLng(-13.5490, -71.8825),
      LatLng(-13.5488, -71.8830),
    ],
  ),
  CollectionRoute(
    id: 'gen_ruta12',
    number: 'G-12',
    name: 'PLAZA DE ARMAS / CENTRO',
    type: 'general',
    days: [3, 6],
    daysLabel: 'Mié y Sáb',
    timeStart: '05:00',
    timeEnd: '10:00',
    sectors: ['Plaza de Armas', 'Coronel La Torre', 'APV Los Ayllus', 'APV Los Rosales', 'APV Los Capulíes (solo sábados)'],
    streets: ['Túpac Amaru', 'Ramón Castilla', 'Calle Lima', 'Calle San Martín', 'Colegio Fe y Alegría', 'Calle Perú'],
    routePoints: [
      LatLng(-13.5478, -71.8770),
      LatLng(-13.5488, -71.8780),
      LatLng(-13.5500, -71.8773),
      LatLng(-13.5508, -71.8760),
      LatLng(-13.5495, -71.8748),
      LatLng(-13.5480, -71.8755),
      LatLng(-13.5478, -71.8770),
    ],
  ),
  CollectionRoute(
    id: 'gen_ruta13',
    number: 'G-13',
    name: 'VERSALLES / HUAYLLAR',
    type: 'general',
    days: [3, 6],
    daysLabel: 'Mié y Sáb',
    timeStart: '05:00',
    timeEnd: '10:00',
    sectors: ['Picol Mojompata', 'Villa Los Pinos', 'Los Jardines de Versalles', 'Juan Pablo II', 'Prado de Versalles', 'La Kantuta', 'Huayllar', 'San Juan de Dios'],
    streets: ['Calle San Francisco', 'Aurora Ruiz Caro', 'Kantu de Versalles', 'Calle Perolpujio', 'Lloclla Pata (parte baja)'],
    routePoints: [
      LatLng(-13.5448, -71.8668),
      LatLng(-13.5462, -71.8650),
      LatLng(-13.5478, -71.8638),
      LatLng(-13.5492, -71.8652),
      LatLng(-13.5480, -71.8670),
      LatLng(-13.5463, -71.8680),
      LatLng(-13.5448, -71.8668),
    ],
  ),
  CollectionRoute(
    id: 'gen_ruta14',
    number: 'G-14',
    name: 'TANCARPATA / ANDAMACHAY',
    type: 'general',
    days: [3, 6],
    daysLabel: 'Mié y Sáb',
    timeStart: '05:00',
    timeEnd: '10:00',
    sectors: ['Derrama Magisterial', 'Sector Tancarpata', 'APV Los Ángeles', 'Andamachay', 'Romeritos', 'Las Canastas', 'APV Buena Vista', 'APV Villa Las Estrellas'],
    streets: ['Calle Los Geranios', 'Final de Transportes de Ttio la Florida', 'Final de los Rápidos'],
    routePoints: [
      LatLng(-13.5538, -71.8698),
      LatLng(-13.5552, -71.8685),
      LatLng(-13.5565, -71.8700),
      LatLng(-13.5552, -71.8715),
      LatLng(-13.5538, -71.8708),
      LatLng(-13.5538, -71.8698),
    ],
  ),
  CollectionRoute(
    id: 'gen_ruta15',
    number: 'G-15',
    name: 'BERMA / HUAYLLAPAMPA',
    type: 'general',
    days: [3, 6],
    daysLabel: 'Mié y Sáb',
    timeStart: '05:00',
    timeEnd: '10:00',
    sectors: ['Berma Central', 'San Isidro', 'Mi Perú y Uvima', 'Pampa de la Derrama Magisterial', 'Huayllapampa', 'Pata Pata'],
    streets: ['Colegio Isaiah Bowman Shants', 'Prolong. Perú', 'Rumi Tabla (solo sábado)'],
    routePoints: [
      LatLng(-13.5525, -71.8810),
      LatLng(-13.5540, -71.8825),
      LatLng(-13.5555, -71.8815),
      LatLng(-13.5542, -71.8798),
      LatLng(-13.5528, -71.8800),
      LatLng(-13.5525, -71.8810),
    ],
  ),
];

// Centro San Jerónimo (para cámara inicial del mapa)
const double kSanJeronimoLat = -13.5487;
const double kSanJeronimoLng = -71.8769;
