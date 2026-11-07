import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firestore data access for SirSir Travel Morocco.
///
/// Public catalog collections are read-only from the client. User-owned data
/// is always scoped to the authenticated Firebase UID and protected again by
/// firestore.rules.
class FirestoreService {
  FirestoreService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('يجب تسجيل الدخول أولاً.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  /// Creates or refreshes the signed-in user's basic profile.
  Future<void> saveCurrentUserProfile({
    String? displayName,
    String? preferredLanguage,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('يجب تسجيل الدخول أولاً.');

    final ref = _users.doc(user.uid);
    final existing = await ref.get();
    final profile = <String, dynamic>{
      'displayName': displayName ?? user.displayName ?? '',
      'phoneNumber': user.phoneNumber,
      'preferredLanguage': preferredLanguage ?? 'ar',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (existing.exists) {
      // Existing-profile updates are deliberately limited by firestore.rules.
      await ref.update(profile);
    } else {
      await ref.set({
        ...profile,
        'uid': user.uid,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Deletes the signed-in user's app profile and their booking requests.
  /// Firebase Authentication may require a recent sign-in before deleting the account.
  Future<void> deleteCurrentUserDataAndAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('يجب تسجيل الدخول أولاً.');

    final bookings = await _db
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .get();

    for (var offset = 0; offset < bookings.docs.length; offset += 400) {
      final batch = _db.batch();
      final end = (offset + 400 < bookings.docs.length)
          ? offset + 400
          : bookings.docs.length;
      for (final doc in bookings.docs.sublist(offset, end)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }

    await _users.doc(user.uid).delete();
    await user.delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchDestinations() =>
      _db.collection('destinations').snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> watchTransportProviders() =>
      _db.collection('transport_providers').snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> watchTravelNews() =>
      _db.collection('travel_news').snapshots();

  /// Stores a booking for the authenticated user.
  /// This records an in-app request, not a confirmed carrier reservation.
  Future<String> createBooking({
    required String origin,
    required String destination,
    required DateTime travelDate,
    required String passengerName,
    required String passengerPhone,
    required String providerName,
    required num displayedPrice,
    String currency = 'MAD',
  }) async {
    final uid = _uid;
    final ref = await _db.collection('bookings').add({
      'userId': uid,
      'origin': origin,
      'destination': destination,
      'travelDate': Timestamp.fromDate(travelDate),
      'passengerName': passengerName.trim(),
      'passengerPhone': passengerPhone.trim(),
      'providerName': providerName,
      'displayedPrice': displayedPrice,
      'currency': currency,
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyBookings() {
    final uid = _uid;
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }

  Future<void> cancelMyBooking(String bookingId) async {
    final uid = _uid;
    final ref = _db.collection('bookings').doc(bookingId);
    final snapshot = await ref.get();
    if (!snapshot.exists || snapshot.data()?['userId'] != uid) {
      throw StateError('الحجز غير موجود أو لا تملك صلاحية تعديله.');
    }
    await ref.update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchReviews() =>
      _db.collection('reviews').snapshots();

  Future<String> addReview({
    required String subjectId,
    required String subjectType,
    required int rating,
    required String comment,
  }) async {
    final uid = _uid;
    if (rating < 1 || rating > 5) {
      throw ArgumentError.value(rating, 'rating', 'يجب أن يكون بين 1 و5.');
    }
    final ref = await _db.collection('reviews').add({
      'userId': uid,
      'subjectId': subjectId,
      'subjectType': subjectType,
      'rating': rating,
      'comment': comment.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}
