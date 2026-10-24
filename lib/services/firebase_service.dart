import 'dart:async';

class KidsStationFirebaseService {
  static final KidsStationFirebaseService instance = KidsStationFirebaseService._();
  KidsStationFirebaseService._();

  final List<String> operationLogs = [];

  void _logOp(String op, String path, Map<String, dynamic> payload) {
    final now = DateTime.now().toIso8601String().substring(11, 19);
    operationLogs.insert(0, '[$now] $op $path -> $payload');
  }

  Future<void> createBooking(Map<String, dynamic> bookingData) async {
    final String bookingId = (bookingData['id'] ?? 'KS-00000').toString();
    _logOp('SET', 'bookings/$bookingId', bookingData);
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
    if (bookingId != 'WALK-IN') {
      _logOp('UPDATE', 'bookings/$bookingId', {
        'status': 'active',
        'wristbandCode': wristbandCode,
      });
    }
    _logOp('SET', 'gate_sessions/$sessionId', {
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
    });
  }

  Future<void> checkOutChildFromGate(String sessionId, String verifiedPickupPin) async {
    _logOp('UPDATE', 'gate_sessions/$sessionId', {
      'status': 'checked_out',
      'verifiedPickupPin': verifiedPickupPin,
    });
  }

  Future<void> updateBranchCrowdStatus(String branchId, String crowdStatus, String crowdLabel) async {
    _logOp('UPDATE', 'branches/$branchId', {
      'crowdStatus': crowdStatus,
      'crowdLabel': crowdLabel,
    });
  }

  Future<void> updateBranchPrices({
    required String branchId,
    required int price1Hour,
    required int price2Hours,
    required int price5Hours,
    required int priceBirthday,
  }) async {
    _logOp('UPDATE', 'branches/$branchId/prices', {
      'hour1': price1Hour,
      'hour2': price2Hours,
      'hour5': price5Hours,
      'birthday': priceBirthday,
    });
  }

  Future<void> addNewBranch(Map<String, dynamic> branchData) async {
    final String branchId = (branchData['id'] ?? 'branch-new').toString();
    _logOp('SET', 'branches/$branchId', branchData);
  }
}
