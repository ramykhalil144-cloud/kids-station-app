import 'package:cloud_firestore/cloud_firestore.dart';

class KidsStationFirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamBranches() {
    return _db.collection('branches').snapshots();
  }

  Future<void> createBooking(Map<String, dynamic> bookingData) async {
    final String bookingId = bookingData['id'];
    await _db.collection('bookings').doc(bookingId).set({
      ...bookingData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> checkInTicketAtGate({
    required String bookingId,
    required String sessionId,
    required String branchId,
    required String branchName,
    required String childName,
    required String parentName,
    required String parentPhone,
    required String wristbandCode,
    required String pickupPin,
    required int durationMinutes,
  }) async {
    final batch = _db.batch();
    if (bookingId != 'WALK-IN') {
      final bookingRef = _db.collection('bookings').doc(bookingId);
      batch.update(bookingRef, {
        'status': 'active',
        'checkedInAt': FieldValue.serverTimestamp(),
        'wristbandCode': wristbandCode,
      });
    }
    final sessionRef = _db.collection('gate_sessions').doc(sessionId);
    batch.set(sessionRef, {
      'sessionId': sessionId,
      'bookingId': bookingId,
      'branchId': branchId,
      'branchName': branchName,
      'childName': childName,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'wristbandCode': wristbandCode,
      'pickupPin': pickupPin,
      'remainingMinutes': durationMinutes,
      'status': 'inside',
      'checkInTimestamp': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> checkOutChildFromGate(String sessionId, String verifiedPickupPin) async {
    await _db.collection('gate_sessions').doc(sessionId).update({
      'status': 'checked_out',
      'verifiedPickupPin': verifiedPickupPin,
      'checkOutTimestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBranchCrowdStatus(String branchId, String crowdStatus, String crowdLabel) async {
    await _db.collection('branches').doc(branchId).set({
      'crowdStatus': crowdStatus,
      'crowdLabel': crowdLabel,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateBranchPrices({
    required String branchId,
    required int price1Hour,
    required int price2Hours,
    required int price5Hours,
    required int priceBirthday,
  }) async {
    await _db.collection('branches').doc(branchId).set({
      'prices': {
        'hour1': price1Hour,
        'hour2': price2Hours,
        'hour5': price5Hours,
        'birthday': priceBirthday,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> addNewBranch(Map<String, dynamic> branchData) async {
    final String branchId = branchData['id'];
    await _db.collection('branches').doc(branchId).set({
      ...branchData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
