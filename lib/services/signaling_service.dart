import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class SignalingService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // CREATE CALL
  // ---------------------------------------------------------------------------

  Future<String> createCall({
    required String callerId,
    required String receiverId,
    required Map<String, dynamic> offer,
  }) async {
    final callRef =
        _firestore.collection('calls').doc();

    await callRef.set({
      'callerId': callerId,
      'receiverId': receiverId,
      'offer': offer,
      'answer': null,
      'status': 'calling',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return callRef.id;
  }

  // ---------------------------------------------------------------------------
  // GET CALL
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?> getCall(
    String callId,
  ) async {
    final snapshot = await _firestore
        .collection('calls')
        .doc(callId)
        .get();

    return snapshot.data();
  }

  // ---------------------------------------------------------------------------
  // SAVE ANSWER
  // ---------------------------------------------------------------------------

  Future<void> saveAnswer({
    required String callId,
    required Map<String, dynamic> answer,
  }) async {
    await _firestore
        .collection('calls')
        .doc(callId)
        .update({
      'answer': answer,
      'status': 'connected',
    });
  }

  // ---------------------------------------------------------------------------
  // LISTEN FOR ANSWER
  // ---------------------------------------------------------------------------

  Stream<Map<String, dynamic>?> listenForAnswer(
    String callId,
  ) {
    return _firestore
        .collection('calls')
        .doc(callId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();

      if (data == null) {
        return null;
      }

      final answer = data['answer'];

      if (answer == null) {
        return null;
      }

      if (answer is! Map) {
        return null;
      }

      return Map<String, dynamic>.from(answer);
    });
  }

  // ---------------------------------------------------------------------------
  // ADD ICE CANDIDATE
  // ---------------------------------------------------------------------------

  Future<void> addIceCandidate({
    required String callId,
    required String collectionName,
    required Map<String, dynamic> candidate,
  }) async {
    await _firestore
        .collection('calls')
        .doc(callId)
        .collection(collectionName)
        .add(candidate);
  }

  // ---------------------------------------------------------------------------
  // LISTEN FOR ICE CANDIDATES
  // ---------------------------------------------------------------------------

  Stream<Map<String, dynamic>> listenForIceCandidates({
    required String callId,
    required String collectionName,
  }) {
    return _firestore
        .collection('calls')
        .doc(callId)
        .collection(collectionName)
        .snapshots()
        .expand(
          (snapshot) => snapshot.docChanges,
        )
        .where(
          (change) =>
              change.type == DocumentChangeType.added,
        )
        .map(
          (change) {
            final data = change.doc.data();

            if (data == null) {
              return <String, dynamic>{};
            }

            return Map<String, dynamic>.from(data);
          },
        );
  }

  // ---------------------------------------------------------------------------
  // LISTEN FOR INCOMING CALLS
  // ---------------------------------------------------------------------------

  Stream<QuerySnapshot<Map<String, dynamic>>>
      listenForIncomingCalls(
    String userId,
  ) {
    return _firestore
        .collection('calls')
        .where(
          'receiverId',
          isEqualTo: userId,
        )
        .where(
          'status',
          isEqualTo: 'calling',
        )
        .snapshots();
  }

  // ---------------------------------------------------------------------------
  // UPDATE CALL STATUS
  // ---------------------------------------------------------------------------

  Future<void> updateCallStatus({
    required String callId,
    required String status,
  }) async {
    await _firestore
        .collection('calls')
        .doc(callId)
        .update({
      'status': status,
    });
  }

  // ---------------------------------------------------------------------------
  // END CALL
  // ---------------------------------------------------------------------------

  Future<void> endCall(
    String callId,
  ) async {
    await _firestore
        .collection('calls')
        .doc(callId)
        .update({
      'status': 'ended',
      'endedAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------------------------------------------------------------------------
  // DELETE CALL
  // ---------------------------------------------------------------------------

  Future<void> deleteCall(
    String callId,
  ) async {
    await _firestore
        .collection('calls')
        .doc(callId)
        .delete();
  }

  // ---------------------------------------------------------------------------
  // WATCH CALL STATUS
  // ---------------------------------------------------------------------------

  Stream<String?> listenForCallStatus(
    String callId,
  ) {
    return _firestore
        .collection('calls')
        .doc(callId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();

      if (data == null) {
        return null;
      }

      return data['status'] as String?;
    });
  }
}