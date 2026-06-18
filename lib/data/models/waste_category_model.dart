import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class Alternative {
  final String title;
  final String description;

  const Alternative({required this.title, required this.description});
}

class CompostGuide {
  final List<String> whatToCompost;
  final List<String> whatNotToCompost;
  final List<String> steps;
  final List<String> benefits;

  const CompostGuide({
    required this.whatToCompost,
    required this.whatNotToCompost,
    required this.steps,
    required this.benefits,
  });
}

class WasteCategory {
  final String key;
  final String name;
  final String type;
  final String bagColor;
  final Color color;
  final IconData icon;
  final String impactFact;
  final List<String> tips;
  final List<String> howToDispose;
  final List<Alternative> alternatives;
  final bool hasCompostGuide;

  const WasteCategory({
    required this.key,
    required this.name,
    required this.type,
    required this.bagColor,
    required this.color,
    required this.icon,
    required this.impactFact,
    required this.tips,
    required this.howToDispose,
    required this.alternatives,
    this.hasCompostGuide = false,
  });
}

const CompostGuide kCompostGuide = CompostGuide(
  whatToCompost: [
    'Cáscaras de frutas y verduras',
    'Posos de café y filtros de papel',
    'Cáscaras de huevo trituradas',
    'Restos de plantas y jardín',
    'Papel y cartón sin tintas brillantes',
  ],
  whatNotToCompost: [
    'Carnes y pescados — atraen plagas',
    'Lácteos — generan malos olores',
    'Aceites y grasas cocidas',
    'Medicamentos y productos químicos',
  ],
  steps: [
    'Consigue un balde o caja con tapa agujereada',
    'Alterna capas verdes (restos de comida) con marrones (cartón/papel)',
    'Mantén húmedo pero no empapado — como esponja',
    'Remueve cada 1 o 2 semanas para airear',
    'En 2 a 3 meses tendrás abono para tus plantas',
  ],
  benefits: [
    'Reduces hasta un 40% tu basura doméstica',
    'Obtienes abono gratuito y natural',
    'Mejoras la salud del suelo de tu chacra',
    'Reduces la emisión de metano en rellenos sanitarios',
  ],
);

const Map<String, WasteCategory> kWasteCategories = {
  'cardboard': WasteCategory(
    key: 'cardboard',
    name: 'Cartón',
    type: 'Inorgánico Reciclable',
    bagColor: 'Bolsa Azul',
    color: AppColors.cardboard,
    icon: Icons.inventory_2_rounded,
    impactFact: 'Reciclar 1 tonelada de cartón salva 17 árboles y 26 500 litros de agua.',
    tips: [
      'Aplana las cajas para ahorrar espacio',
      'Retira cintas adhesivas y grapas metálicas',
      'Mantén el cartón seco: el mojado no se recicla',
      'Triturado sirve de capa marrón en compostaje',
    ],
    howToDispose: [
      'Aplana y amarra las cajas en paquetes pequeños',
      'Deposita en la bolsa azul o punto de acopio',
      'El camión recolector pasa según tu horario de zona',
    ],
    alternatives: [
      Alternative(title: 'Compostaje', description: 'Úsalo triturado como capa marrón en tu compost casero. Acelera la descomposición y mejora la aireación.'),
      Alternative(title: 'Reutilización', description: 'Reutiliza cajas íntegras para almacenamiento, mudanzas o envíos.'),
      Alternative(title: 'Manualidades', description: 'Recorta figuras para macetas temporales, separadores o proyectos escolares.'),
    ],
    hasCompostGuide: true,
  ),
  'glass': WasteCategory(
    key: 'glass',
    name: 'Vidrio',
    type: 'Inorgánico Reciclable',
    bagColor: 'Bolsa Morada',
    color: AppColors.glass,
    icon: Icons.wine_bar_rounded,
    impactFact: 'Reciclar vidrio reduce la contaminación del agua en un 50% y la contaminación del aire en un 20%.',
    tips: [
      'Enjuaga los envases antes de reciclarlos',
      'Separa por colores: transparente, verde y ámbar',
      'No mezcles con cerámica ni espejos',
      'El vidrio se puede reciclar infinitas veces',
    ],
    howToDispose: [
      'Enjuaga el envase y retira tapas metálicas',
      'Deposita con cuidado en la bolsa morada',
      'Lleva al punto de acopio más cercano',
    ],
    alternatives: [
      Alternative(title: 'Decoración', description: 'Pinta o decora botellas de vidrio para usarlas como floreros, portavelas o adornos del hogar.'),
      Alternative(title: 'Almacenamiento', description: 'Los frascos de vidrio son perfectos para guardar especias, semillas, granos o miel.'),
    ],
    hasCompostGuide: false,
  ),
  'metal': WasteCategory(
    key: 'metal',
    name: 'Metal y Aluminio',
    type: 'Inorgánico Reciclable',
    bagColor: 'Bolsa Naranja',
    color: AppColors.metal,
    icon: Icons.hardware_rounded,
    impactFact: 'Reciclar aluminio usa 95% menos energía que producirlo desde cero y es infinitamente reciclable.',
    tips: [
      'Aplasta las latas para ahorrar espacio',
      'Enjuaga las latas de comida antes de reciclar',
      'El aluminio tiene valor: los centros de acopio lo compran',
      'Usa un imán para separar aluminio del acero',
    ],
    howToDispose: [
      'Aplasta las latas y enjuaga los residuos de comida',
      'Deposita en la bolsa naranja exclusiva para metales',
      'Entrega en punto de acopio o al camión recolector',
    ],
    alternatives: [
      Alternative(title: 'Macetas', description: 'Las latas grandes de conservas son perfectas como macetas para hierbas aromáticas como albahaca, menta o romero.'),
      Alternative(title: 'Organizador', description: 'Agrupa latas pequeñas para crear portálápices y organizadores de escritorio.'),
    ],
    hasCompostGuide: false,
  ),
  'paper': WasteCategory(
    key: 'paper',
    name: 'Papel',
    type: 'Inorgánico Reciclable',
    bagColor: 'Bolsa Azul',
    color: AppColors.paper,
    icon: Icons.article_rounded,
    impactFact: 'Reciclar papel reduce el 74% de la contaminación del aire y ahorra energía equivalente a encender un foco por 24 horas.',
    tips: [
      'No recicles papel sucio con grasa o alimentos',
      'Papel higiénico y servilletas van a basura general',
      'Separa papel blanco de colores para mejor calidad',
      'Imprime a doble cara para reducir tu consumo',
    ],
    howToDispose: [
      'Junta periódicos, hojas y revistas en paquetes',
      'Deposita en bolsa azul junto al cartón',
      'Mantén seco hasta el día de recolección',
    ],
    alternatives: [
      Alternative(title: 'Papel de regalo', description: 'Usa hojas de periódico o revistas como papel de regalo ecológico. Decora con twine y hojas naturales.'),
      Alternative(title: 'Compostaje', description: 'El papel sin tintas brillantes es ideal como capa marrón en el compost.'),
    ],
    hasCompostGuide: true,
  ),
  'plastic': WasteCategory(
    key: 'plastic',
    name: 'Plástico',
    type: 'Inorgánico Reciclable',
    bagColor: 'Bolsa Amarilla',
    color: AppColors.plastic,
    icon: Icons.local_drink_rounded,
    impactFact: 'El plástico puede tardar hasta 500 años en degradarse. Cada botella que reciclas cuenta para San Jerónimo.',
    tips: [
      'Revisa el número en el fondo: PET(1) y HDPE(2) son los más reciclables',
      'Enjuaga y retira tapas antes de reciclar',
      'Las bolsas van a puntos especiales, no al reciclaje normal',
      'Aplasta las botellas para ahorrar espacio',
    ],
    howToDispose: [
      'Enjuaga el envase y aplástalo para reducir volumen',
      'Retira la tapa y el anillo del cuello de la botella',
      'Deposita en la bolsa amarilla en el punto de acopio',
    ],
    alternatives: [
      Alternative(title: 'Riego por goteo', description: 'Perfora la tapa de una botella PET con agujas de coser para crear un sistema de riego por goteo para tus plantas.'),
      Alternative(title: 'Maceta colgante', description: 'Corta una botella a la mitad, cuelga la parte inferior invertida como maceta para plantas pequeñas.'),
    ],
    hasCompostGuide: false,
  ),
  'trash': WasteCategory(
    key: 'trash',
    name: 'Residuo General',
    type: 'No Reciclable',
    bagColor: 'Bolsa Negra',
    color: AppColors.trash,
    icon: Icons.delete_rounded,
    impactFact: 'Reducir los residuos generales protege el suelo y las aguas del río Huatanay en San Jerónimo.',
    tips: [
      'Reduce comprando productos con menos empaque',
      'Pilas y baterías: llévalas a puntos especiales de RAEE',
      'Medicamentos vencidos: devuélvelos a farmacias',
      'Electrónicos: busca puntos RAEE en el centro de Cusco',
    ],
    howToDispose: [
      'Desecha en bolsa negra bien cerrada para evitar dispersión',
      'No mezcles con materiales reciclables ni orgánicos',
      'Deposita solo en el horario de recolección de tu zona',
    ],
    alternatives: [
      Alternative(title: 'Reducir en origen', description: 'La mejor alternativa al residuo general es no generarlo. Elige productos con empaques reciclables o reutilizables.'),
    ],
    hasCompostGuide: false,
  ),
};

WasteCategory? getWasteCategory(String key) => kWasteCategories[key.toLowerCase()];
