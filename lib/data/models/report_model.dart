import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String photoUrl;
  final double latitude;
  final double longitude;
  final String address;
  final String neighborhood;
  final String description;
  final String severity;
  final String status;
  final int confirmations;
  final int comments;
  final bool anonymous;
  final Timestamp createdAt;

  const ReportModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar = '',
    this.photoUrl = '',
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.neighborhood,
    required this.description,
    required this.severity,
    this.status = 'PENDING',
    this.confirmations = 0,
    this.comments = 0,
    this.anonymous = false,
    required this.createdAt,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReportModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      userAvatar: data['userAvatar'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      address: data['address'] as String? ?? '',
      neighborhood: data['neighborhood'] as String? ?? '',
      description: data['description'] as String? ?? '',
      severity: data['severity'] as String? ?? 'LOW',
      status: data['status'] as String? ?? 'PENDING',
      confirmations: (data['confirmations'] as num?)?.toInt() ?? 0,
      comments: (data['comments'] as num?)?.toInt() ?? 0,
      anonymous: data['anonymous'] as bool? ?? false,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'photoUrl': photoUrl,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'neighborhood': neighborhood,
        'description': description,
        'severity': severity,
        'status': status,
        'confirmations': confirmations,
        'comments': comments,
        'anonymous': anonymous,
        'createdAt': createdAt,
      };

  String get displayName => anonymous ? 'Vecino anónimo' : userName;
  String get displayAvatar => anonymous ? '' : userAvatar;
}
