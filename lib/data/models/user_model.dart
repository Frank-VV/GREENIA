import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;
  final String neighborhood;
  final String zone;
  final int reportsCount;
  final int scansCount;
  final String fcmToken;
  final Timestamp createdAt;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl = '',
    this.neighborhood = '',
    this.zone = '',
    this.reportsCount = 0,
    this.scansCount = 0,
    this.fcmToken = '',
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      neighborhood: data['neighborhood'] as String? ?? '',
      zone: data['zone'] as String? ?? '',
      reportsCount: (data['reportsCount'] as num?)?.toInt() ?? 0,
      scansCount: (data['scansCount'] as num?)?.toInt() ?? 0,
      fcmToken: data['fcmToken'] as String? ?? '',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
        'neighborhood': neighborhood,
        'zone': zone,
        'reportsCount': reportsCount,
        'scansCount': scansCount,
        'fcmToken': fcmToken,
        'createdAt': createdAt,
      };

  UserModel copyWith({
    String? displayName,
    String? email,
    String? photoUrl,
    String? neighborhood,
    String? zone,
    int? reportsCount,
    int? scansCount,
    String? fcmToken,
  }) =>
      UserModel(
        uid: uid,
        displayName: displayName ?? this.displayName,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        neighborhood: neighborhood ?? this.neighborhood,
        zone: zone ?? this.zone,
        reportsCount: reportsCount ?? this.reportsCount,
        scansCount: scansCount ?? this.scansCount,
        fcmToken: fcmToken ?? this.fcmToken,
        createdAt: createdAt,
      );

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
