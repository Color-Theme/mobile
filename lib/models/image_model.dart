import 'package:shared_preferences/shared_preferences.dart';

class ImageModel {
  final String id;
  final String url;
  final String title;

  ImageModel({
    required this.id,
    required this.url,
    required this.title,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'],
      url: json['url'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
    };
  }
}

class FavoriteImagesModel {
  final Set<String> likedImages;

  FavoriteImagesModel({required this.likedImages});

  void toggleLike(String imageId) async {
    if (likedImages.contains(imageId)) {
      likedImages.remove(imageId);
    } else {
      likedImages.add(imageId);
    }
    await _saveToStorage();
  }

  bool isLiked(String imageId) {
    return likedImages.contains(imageId);
  }

  Future<void> _saveToStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('likedImages', likedImages.toList());
  }

  static Future<FavoriteImagesModel> loadFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> likedImagesList = prefs.getStringList('likedImages') ?? [];
    return FavoriteImagesModel(likedImages: likedImagesList.toSet());
  }
}

class FavoriteImages {
  static late FavoriteImagesModel favoriteImages;

  static Future<void> init() async {
    favoriteImages = await FavoriteImagesModel.loadFromStorage();
  }
}
