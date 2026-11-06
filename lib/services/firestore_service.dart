import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/onboarding_survey.dart';
import 'auth_service.dart';

class FirestoreService {
  static Future<void> saveSurveyResponse({
    required String? userId,
    required String userName,
    required String userEmail,
    required String authProvider,
    required OnboardingSurveyData surveyData,
  }) async {
    if (!AuthService.isFirebaseInitialized) {
      debugPrint('[FirestoreService] Firebase não inicializado. Salvamento em nuvem ignorado.');
      return;
    }

    try {
      final docId = (userId != null && userId.isNotEmpty)
          ? userId
          : (userEmail.isNotEmpty
              ? userEmail.replaceAll('.', '_')
              : 'anon_${DateTime.now().millisecondsSinceEpoch}');

      final payload = {
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'authProvider': authProvider,
        'completedAt': FieldValue.serverTimestamp(),
        'completedAtIso': DateTime.now().toIso8601String(),
        'primaryGoal': surveyData.primaryGoal,
        'dominantSymptom': surveyData.dominantSymptom,
        'stressFrequency': surveyData.stressFrequency,
        'dailyCommitmentMinutes': surveyData.dailyCommitmentMinutes,
        'profileTitle': surveyData.profileTitle,
        'recommendedFocusDomain': surveyData.recommendedFocusDomain,
        'surveyMap': surveyData.toMap(),
      };

      await FirebaseFirestore.instance
          .collection('onboarding_surveys')
          .doc(docId)
          .set(payload, SetOptions(merge: true));

      debugPrint('[FirestoreService] Formulário salvo no Firestore com sucesso: $docId');
    } catch (e) {
      debugPrint('[FirestoreService] Aviso ao salvar formulário no Firestore: $e');
    }
  }
}
