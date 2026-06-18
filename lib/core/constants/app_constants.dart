class AppConstants {
  AppConstants._();

  static const String appName = 'GreenWatch';
  static const String appTagline = 'Cuida San Jerónimo juntos';
  static const String districtName = 'San Jerónimo, Cusco';
  static const String mayorName = 'Prof. Máximo Rimachi Morales';

  static const String collectionUsers = 'users';
  static const String collectionReports = 'reports';
  static const String collectionSchedules = 'schedules';

  static const String storageReports = 'reports';
  static const String storageAvatars = 'avatars';

  static const String severityHigh = 'HIGH';
  static const String severityMedium = 'MEDIUM';
  static const String severityLow = 'LOW';

  static const String statusPending = 'PENDING';
  static const String statusReviewing = 'REVIEWING';
  static const String statusResolved = 'RESOLVED';

  static const int maxDescriptionLength = 280;
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5 MB

  static const String fcmTopicAll = 'all_users';
}

class AppStrings {
  AppStrings._();

  // Auth
  static const String loginTitle = 'Bienvenido a GreenWatch';
  static const String loginSubtitle = 'Cuida San Jerónimo juntos';
  static const String emailLabel = 'Correo electrónico';
  static const String passwordLabel = 'Contraseña';
  static const String confirmPasswordLabel = 'Confirmar contraseña';
  static const String fullNameLabel = 'Nombre completo';
  static const String neighborhoodLabel = 'Tu barrio';
  static const String loginButton = 'Ingresar';
  static const String registerButton = 'Crear cuenta';
  static const String googleButton = 'Continuar con Google';
  static const String noAccount = '¿No tienes cuenta? ';
  static const String register = 'Regístrate';
  static const String hasAccount = '¿Ya tienes cuenta? ';
  static const String login = 'Inicia sesión';
  static const String logout = 'Cerrar sesión';
  static const String orContinueWith = '— o continúa con —';

  // Home
  static const String tabEducation = 'Educación';
  static const String tabScanner = 'Escanear';
  static const String tabSchedule = 'Horarios';
  static const String tabCommunity = 'Comunidad';

  // Scanner
  static const String aimCamera = 'Apunta la cámara al residuo';
  static const String analyzingAI = 'Analizando con IA...';
  static const String scanAnother = 'Escanear otro';
  static const String moreInfo = 'Más información';
  static const String scanError = 'No se pudo identificar el residuo. Intenta de nuevo';
  static const String demoMode = 'Modo demostración (modelo IA no disponible)';

  // Schedule
  static const String scheduleTitle = 'Horarios de Recolección';
  static const String scheduleSubtitle = 'San Jerónimo, Cusco';
  static const String nextCollection = 'Próxima recolección';
  static const String collectionPoints = 'Puntos de Acopio';
  static const String howToGetThere = 'Cómo llegar';
  static const String activateReminder = 'Activar recordatorio';
  static const String selectZone = 'Seleccionar zona';
  static const String noScheduleAvailable = 'No hay horarios disponibles para tu zona';

  // Community
  static const String communityTitle = 'Comunidad GreenWatch';
  static const String pending = 'Pendientes';
  static const String inReview = 'En revisión / Atendidos';
  static const String createReport = 'Crear reporte';
  static const String reportPublished = '¡Reporte publicado! Gracias por cuidar San Jerónimo';
  static const String confirmReport = 'Confirmar';
  static const String comment = 'Comentar';
  static const String shareReport = 'Compartir';
  static const String anonymous = 'Vecino anónimo';
  static const String reportAnonymously = 'Reportar de forma anónima';

  // Create Report
  static const String step1Photo = 'Foto del problema';
  static const String step2Location = 'Ubicación';
  static const String step3Details = 'Detalles';
  static const String descriptionHint = 'Describe lo que encontraste en este lugar...';
  static const String severityLabel = 'Gravedad';
  static const String severityHigh = 'Alta - Requiere atención urgente';
  static const String severityMedium = 'Media - Problema moderado';
  static const String severityLow = 'Baja - Observación menor';
  static const String publishReport = 'Publicar reporte';
  static const String next = 'Siguiente';
  static const String back = 'Atrás';
  static const String takePhoto = 'Tomar foto';
  static const String fromGallery = 'Desde galería';
  static const String retake = 'Retomar';
  static const String usePhoto = 'Usar esta foto';

  // Profile
  static const String profileTitle = 'Mi Perfil';
  static const String myReports = 'Mis reportes';
  static const String myScans = 'Escaneos';
  static const String confirmationsReceived = 'Confirmaciones';
  static const String resolvedReports = 'Atendidos';
  static const String notifications = 'Notificaciones';
  static const String darkMode = 'Modo oscuro';
  static const String aboutApp = 'Acerca de GreenWatch';
  static const String editNeighborhood = 'Mi barrio';

  // Education
  static const String educationTitle = 'Aprende a clasificar';
  static const String educationSubtitle = 'Guía oficial para vecinos de San Jerónimo';
  static const String searchCategories = 'Buscar categoría...';
  static const String howToDispose = '¿Cómo desecharlo?';
  static const String environmentalFact = 'Dato ambiental';
  static const String alternativeUses = 'Usos alternativos';
  static const String compostGuide = 'Guía de Compostaje';

  // Common
  static const String retry = 'Reintentar';
  static const String cancel = 'Cancelar';
  static const String save = 'Guardar';
  static const String loading = 'Cargando...';
  static const String noInternet = 'Sin conexión a internet';
  static const String error = 'Ocurrió un error';
  static const String success = 'Éxito';
  static const String noData = 'No hay datos disponibles';
  static const String seeMore = 'Ver más';
}
