import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ImageLoader {
  final ScrollController scrollController;
  final int limit;

  int currentPage = 1;
  bool isLoading = false;
  List<Map<String, dynamic>> imageList = [];

  ImageLoader({
    required this.scrollController,
    this.limit = 30,
  }) {
    scrollController.addListener(_onScroll);
  }

  Future<List<Map<String, dynamic>>> _loadImagesFromApi() async {
    try {
      final response = await ApiService.fetchImages(currentPage, limit);
      return response.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint("❌ Error fetching images: $e");
      return [];
    }
  }

  Future<void> loadImages() async {
    if (isLoading) return;

    isLoading = true;
    debugPrint("🚀 Fetching images... Page: $currentPage, Limit: $limit");

    final newImages = await _loadImagesFromApi();

    if (newImages.isNotEmpty) {
      imageList.addAll(newImages);
      currentPage++;
    }

    isLoading = false;
  }

  void _onScroll() {
    if (scrollController.hasClients &&
        scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 100 &&
        !isLoading) {
      loadImages();
    }
  }

  void dispose() {
    scrollController.removeListener(_onScroll);
  }
}
