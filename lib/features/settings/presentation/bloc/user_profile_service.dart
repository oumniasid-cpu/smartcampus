import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  UserProfile — modèle de données qui correspond à Firestore
// ─────────────────────────────────────────────────────────────────────────────
class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String role;         // 'student' ou 'staff'
  final String? photoUrl;
  final List<String> badges; // ex: ['deans_list', 'junior_scholar']

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.role,
    this.photoUrl,
    this.badges = const [],
  });

  // Depuis un document Firestore → objet Dart
  factory UserProfile.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      displayName: d['displayName'] ?? 'Étudiant',
      email: d['email'] ?? '',
      role: d['role'] ?? 'student',
      photoUrl: d['photoUrl'],
      badges: List<String>.from(d['badges'] ?? []),
    );
  }

  // Objet Dart → Map pour Firestore
  Map<String, dynamic> toMap() => {
    'displayName': displayName,
    'email': email,
    'role': role,
    'photoUrl': photoUrl,
    'badges': badges,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
//  UserProfileService — toutes les opérations Firebase du profil
// ─────────────────────────────────────────────────────────────────────────────
class UserProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Raccourci : utilisateur connecté en ce moment
  User? get currentUser => _auth.currentUser;

  // ── Créer le profil lors de la première inscription ──────────────────────
  //
  // À appeler juste après FirebaseAuth.createUserWithEmailAndPassword()
  //
  Future<void> createProfile({
    required String uid,
    required String email,
    String displayName = 'Étudiant',
    String role = 'student',
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'photoUrl': null,
      'badges': [],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Lire le profil une seule fois ────────────────────────────────────────
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromDoc(doc);
  }

  // ── Écouter le profil en temps réel (Stream) ─────────────────────────────
  //
  // Utilise ce Stream dans un StreamBuilder pour que l'UI se mette à jour
  // automatiquement dès qu'un champ change dans Firestore.
  //
  Stream<UserProfile?> watchProfile(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromDoc(doc) : null);
  }

  // ── Mettre à jour le nom affiché ─────────────────────────────────────────
  Future<void> updateDisplayName(String uid, String name) async {
    await _db.collection('users').doc(uid).update({
      'displayName': name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    // Synchronise aussi dans FirebaseAuth (utilisé par les notifications, etc.)
    await _auth.currentUser?.updateDisplayName(name);
  }

  // ── Déconnexion ──────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }
}