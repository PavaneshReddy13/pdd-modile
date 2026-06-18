import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

class GeminiService {
  // Use a placeholder or environment variable. For demonstration, we assume it's passed or available.
  // In a real app, this should be fetched securely.
  final String _apiKey = const String.fromEnvironment('GEMINI_API_KEY',
      defaultValue: 'YOUR_API_KEY');

  Future<String> analyzeSymptoms({
    required String symptoms,
    required String age,
    required String gender,
    required String duration,
    required String severity,
  }) async {
    if (_apiKey == 'YOUR_API_KEY') {
      // Return a simulated response if no real API key is configured.
      await Future.delayed(const Duration(seconds: 2));
      return '''
1. Possible conditions: Viral Fever, Common Cold
2. Risk level: Low
3. Recommended department: General Physician
4. Home care advice: Rest, stay hydrated, take paracetamol if fever persists.
5. Immediate consultation needed: No
''';
    }

    final model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: _apiKey);

    final prompt = '''
You are a healthcare triage assistant.
Analyze these symptoms:
Symptoms: $symptoms
Age: $age
Gender: $gender
Duration: $duration
Severity: $severity

Provide:
1. Possible conditions
2. Risk level (Low, Medium, High)
3. Recommended department
4. Home care advice
5. Whether immediate consultation is needed

Never provide a diagnosis.
Always recommend consultation.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      return response.text ?? 'Unable to analyze symptoms at this moment.';
    } catch (e) {
      return 'Error analyzing symptoms: \${e.toString()}';
    }
  }
}
