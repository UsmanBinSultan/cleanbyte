import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sift/models/photo_category.dart';

class PhotoCategorizer {
  PhotoCategorizer()
    : _labeler = ImageLabeler(
        options: ImageLabelerOptions(confidenceThreshold: 0.45),
      ),
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
      );

  final ImageLabeler _labeler;
  final FaceDetector _faceDetector;

  static const _categoryKeywords = <PhotoCategory, List<String>>{
    PhotoCategory.children: [
      'child',
      'children',
      'kid',
      'kids',
      'baby',
      'toddler',
      'infant',
      'boy',
      'girl',
      'student',
      'school',
    ],
    PhotoCategory.pets: [
      'dog',
      'cat',
      'puppy',
      'kitten',
      'pet',
      'domestic animal',
      'golden retriever',
      'labrador',
      'poodle',
      'persian cat',
    ],
    PhotoCategory.animals: [
      'animal',
      'bird',
      'wildlife',
      'mammal',
      'reptile',
      'fish',
      'horse',
      'cow',
      'elephant',
      'tiger',
      'lion',
      'bear',
      'wolf',
      'deer',
      'rabbit',
      'snake',
      'frog',
      'butterfly',
      'insect',
    ],
    PhotoCategory.flowers: [
      'flower',
      'floral',
      'bouquet',
      'rose',
      'daisy',
      'sunflower',
      'tulip',
      'petal',
      'blossom',
      'plant stem',
    ],
    PhotoCategory.eyeglasses: [
      'glasses',
      'eyeglasses',
      'sunglasses',
      'goggles',
      'vision care',
      'spectacles',
      'eye wear',
      'eyewear',
    ],
    PhotoCategory.food: [
      'food',
      'meal',
      'dish',
      'pizza',
      'burger',
      'salad',
      'fruit',
      'vegetable',
      'dessert',
      'cake',
      'coffee',
      'drink',
      'cuisine',
      'bread',
      'rice',
      'meat',
      'snack',
      'restaurant',
    ],
    PhotoCategory.transportation: [
      'transport',
      'transportation',
      'train',
      'bus',
      'airplane',
      'aircraft',
      'boat',
      'ship',
      'helicopter',
      'railway',
      'public transport',
    ],
    PhotoCategory.clothing: [
      'dress',
      'skirt',
      'clothing',
      'fashion',
      'gown',
      'sari',
      'saree',
      'shirt',
      'suit',
      'jacket',
      'textile',
      'costume',
      'formal wear',
      'bridal clothing',
      'wedding dress',
    ],
    PhotoCategory.shoes: [
      'shoe',
      'shoes',
      'footwear',
      'sneaker',
      'boot',
      'sandal',
      'heel',
      'slipper',
    ],
    PhotoCategory.cars: [
      'car',
      'sedan',
      'suv',
      'automobile',
      'vehicle registration plate',
      'land vehicle',
      'motor vehicle',
      'sports car',
    ],
    PhotoCategory.vehicles: [
      'vehicle',
      'truck',
      'motorcycle',
      'bicycle',
      'van',
      'rickshaw',
      'scooter',
      'wheel',
      'tire',
    ],
    PhotoCategory.architecture: [
      'architecture',
      'building',
      'house',
      'home',
      'apartment',
      'skyscraper',
      'facade',
      'property',
      'real estate',
      'landmark',
      'monument',
      'temple',
      'mosque',
      'church',
      'bridge',
      'window',
      'door',
      'roof',
    ],
    PhotoCategory.sky: [
      'sky',
      'cloud',
      'sunset',
      'sunrise',
      'atmosphere',
      'horizon',
      'daytime',
      'night',
      'moon',
      'star',
      'weather',
    ],
    PhotoCategory.electronics: [
      'computer',
      'laptop',
      'phone',
      'smartphone',
      'tablet',
      'keyboard',
      'monitor',
      'television',
      'camera',
      'headphones',
      'electronics',
      'technology',
      'gadget',
      'screen',
      'display device',
      'computer monitor',
      'computer keyboard',
      'software',
      'code',
    ],
    PhotoCategory.sportsExercise: [
      'sport',
      'sports',
      'exercise',
      'fitness',
      'gym',
      'ball',
      'football',
      'soccer',
      'cricket',
      'basketball',
      'tennis',
      'running',
      'cycling',
      'yoga',
      'workout',
      'athlete',
      'player',
    ],
    PhotoCategory.documents: [
      'document',
      'paper',
      'text',
      'receipt',
      'invoice',
      'book',
      'menu',
      'newspaper',
      'poster',
      'font',
      'handwriting',
      'form',
      'identity document',
      'passport',
      'license',
      'contract',
      'letter',
      'page',
    ],
    PhotoCategory.nature: [
      'tree',
      'plant',
      'grass',
      'forest',
      'mountain',
      'beach',
      'ocean',
      'river',
      'lake',
      'landscape',
      'nature',
      'leaf',
      'rock',
      'water',
      'field',
      'garden',
    ],
  };

  static const _priority = [
    PhotoCategory.children,
    PhotoCategory.pets,
    PhotoCategory.flowers,
    PhotoCategory.eyeglasses,
    PhotoCategory.food,
    PhotoCategory.shoes,
    PhotoCategory.clothing,
    PhotoCategory.cars,
    PhotoCategory.transportation,
    PhotoCategory.vehicles,
    PhotoCategory.documents,
    PhotoCategory.electronics,
    PhotoCategory.sportsExercise,
    PhotoCategory.architecture,
    PhotoCategory.sky,
    PhotoCategory.animals,
    PhotoCategory.nature,
  ];

  Future<Set<PhotoCategory>> categorize(
    AssetEntity asset, {
    Set<PhotoCategory> hintCategories = const <PhotoCategory>{},
  }) async {
    final categories = <PhotoCategory>{...hintCategories};
    final title = asset.title?.toLowerCase() ?? '';
    if (_looksLikeScreenshot(title)) {
      categories.add(PhotoCategory.screenshots);
    }

    final file = await _analysisFileFor(asset);
    if (file == null) {
      return _normalizeCategories(categories);
    }

    categories.addAll(await _labelCategories(file));

    if (!categories.contains(PhotoCategory.people) && await _detectFace(file)) {
      categories.add(PhotoCategory.people);
    }

    unawaited(_deleteIfTemporary(file));

    return _normalizeCategories(categories);
  }

  Future<File?> _analysisFileFor(AssetEntity asset) async {
    try {
      final bytes = await asset.thumbnailDataWithSize(
        const ThumbnailSize(640, 640),
        quality: 72,
      );
      if (bytes != null && bytes.isNotEmpty) {
        return _writeTemporaryImage(asset.id, bytes);
      }
    } catch (_) {}
    return asset.file;
  }

  Future<File> _writeTemporaryImage(String id, Uint8List bytes) async {
    final safeId = id.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final file = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}clean_byte_ai_$safeId.jpg',
    );
    await file.writeAsBytes(bytes, flush: false);
    return file;
  }

  Future<void> _deleteIfTemporary(File file) async {
    try {
      final prefix =
          '${Directory.systemTemp.path}${Platform.pathSeparator}clean_byte_ai_';
      if (file.path.startsWith(prefix) && await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  Future<Set<PhotoCategory>> _labelCategories(File file) async {
    try {
      final inputImage = InputImage.fromFile(file);
      final labels = await _labeler.processImage(inputImage);
      return _mapLabelsToCategories(labels);
    } catch (_) {
      return const <PhotoCategory>{};
    }
  }

  Future<bool> _detectFace(File file) async {
    try {
      final inputImage = InputImage.fromFile(file);
      final faces = await _faceDetector.processImage(inputImage);
      return faces.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  bool _looksLikeScreenshot(String title) {
    return title.contains('screenshot') ||
        title.contains('screen_shot') ||
        title.startsWith('screen') ||
        title.startsWith('img_screenshot');
  }

  Set<PhotoCategory> _mapLabelsToCategories(List<ImageLabel> labels) {
    final scores = <PhotoCategory, double>{};

    for (final label in labels) {
      final text = label.label.toLowerCase();
      for (final category in _priority) {
        final keywords = _categoryKeywords[category] ?? const <String>[];
        if (keywords.any((keyword) => text.contains(keyword))) {
          scores[category] = (scores[category] ?? 0) + label.confidence;
        }
      }
    }

    final categories = <PhotoCategory>{};
    for (final category in _priority) {
      final score = scores[category] ?? 0;
      if (score >= 0.45) {
        categories.add(category);
      }
    }

    if (categories.contains(PhotoCategory.cars)) {
      categories.add(PhotoCategory.vehicles);
    }
    if (categories.contains(PhotoCategory.transportation)) {
      categories.add(PhotoCategory.vehicles);
    }
    if (categories.contains(PhotoCategory.flowers)) {
      categories.add(PhotoCategory.nature);
    }
    if (categories.contains(PhotoCategory.sky)) {
      categories.add(PhotoCategory.nature);
    }
    return categories;
  }

  Set<PhotoCategory> _normalizeCategories(Set<PhotoCategory> categories) {
    categories
      ..remove(PhotoCategory.all)
      ..remove(PhotoCategory.uncategorized);
    if (categories.isEmpty) {
      return {PhotoCategory.uncategorized};
    }
    return categories;
  }

  void dispose() {
    _labeler.close();
    _faceDetector.close();
  }
}
