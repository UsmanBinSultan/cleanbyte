// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:sift/models/photo_category.dart';

// class GeminiScanService {
//   static const String apiKey = 'AIzaSyCSt95JiBdwZzkttMRkLnDVcwQm8Vp7JvQ';

//   final GenerativeModel _model = GenerativeModel(
//     model: 'gemini-2.5-flash',
//     apiKey: apiKey,
//   );

//   /// Scan image and classify into category
//   Future<Map<String, dynamic>> scanImage(File imageFile) async {
//     try {
//       final bytes = await imageFile.readAsBytes();

//       final prompt = '''
// Analyze this image carefully.

// Classify the image into ONE main category.

// Available categories:
// - Plant Disease
// - Healthy Plant
// - Animal
// - Food
// - Human
// - Vehicle
// - Electronics
// - Nature
// - Document
// - Unknown

// Return ONLY valid JSON in this format:

// {
//   "category": "category name",
//   "confidence": 95,
//   "description": "short explanation"
// }
// ''';

//       final response = await _model.generateContent([
//         Content.multi([
//           TextPart(prompt),
//           DataPart('image/jpeg', bytes),
//         ])
//       ]);

//       final text = response.text ?? '';

//       return _parseJson(text);
//     } catch (e) {
//       return {
//         "category": "Error",
//         "confidence": 0,
//         "description": e.toString(),
//       };
//     }
//   }

//   /// Parse Gemini JSON response
//   Map<String, dynamic> _parseJson(String response) {
//     try {
//       final cleaned = response
//           .replaceAll('```json', '')
//           .replaceAll('```', '')
//           .trim();

//       final data = jsonDecode(cleaned);

//       return {
//         "category": data["category"] ?? "Unknown",
//         "confidence": data["confidence"] ?? 0,
//         "description": data["description"] ?? "",
//       };
//     } catch (e) {
//       return {
//         "category": "Unknown",
//         "confidence": 0,
//         "description": response,
//       };
//     }
//   }
//     Future<Set<PhotoCategory>> categorize({
//     required Uint8List imageBytes,
//     String mimeType = 'image/jpeg',
//   }) async {
//     if (!isConfigured) {
//       throw const GeminiPhotoCategorizerException(
//         'Gemini API key is missing. Run with --dart-define=GEMINI_API_KEY=your_key.',
//       );
//     }

//     final uri = Uri.https(
//       'generativelanguage.googleapis.com',
//       '/v1beta/models/$model:generateContent',
//     );
//     final request = await _client
//         .postUrl(uri)
//         .timeout(const Duration(seconds: 12));
//     request.headers
//       ..set(HttpHeaders.contentTypeHeader, 'application/json')
//       ..set('x-goog-api-key', apiKey);
//     request.write(
//       jsonEncode({
//         'contents': [
//           {
//             'parts': [
//               {
//                 'inline_data': {
//                   'mime_type': mimeType,
//                   'data': base64Encode(imageBytes),
//                 },
//               },
//               {'text': _prompt},
//             ],
//           },
//         ],
//         'generationConfig': {'responseMimeType': 'application/json'},
//       }),
//     );
// }