import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camera/camera.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'data/services/waste_classifier_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (_) {}

  final classifierService = WasteClassifierService();
  await classifierService.initialize();

  runApp(
    GreenWatchApp(
      cameras: cameras,
      classifierService: classifierService,
    ),
  );
}
