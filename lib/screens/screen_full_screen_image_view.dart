import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:transparent_image/transparent_image.dart';

class FavoriteImages {
  static final Set<String> likedImages = {};
}

class FullscreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullscreenImageViewer({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showButtons = true;
  String _selectedResolution = "2K";

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleButtons() {
    setState(() {
      _showButtons = !_showButtons;
    });
  }

  void _shareImage() {
    String imageUrl = widget.imageUrls[_currentIndex];
    // Share.share(imageUrl).catchError((error) {});
  }

  void _toggleLike() {
    String imageUrl = widget.imageUrls[_currentIndex];
    setState(() {
      if (FavoriteImages.likedImages.contains(imageUrl)) {
        FavoriteImages.likedImages.remove(imageUrl);
      } else {
        FavoriteImages.likedImages.add(imageUrl);
      }
    });
  }

  Future<void> _downloadImage() async {
    if (_selectedResolution != "2K") return;
    Navigator.pop(context);
    try {
      // Yêu cầu quyền truy cập thư viện ảnh trên iOS
      var status = await Permission.photos.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission denied to save image")),
        );
        return;
      }

      // Tải ảnh về bộ nhớ tạm
      var response = await Dio().get(
        widget.imageUrls[_currentIndex],
        options: Options(responseType: ResponseType.bytes),
      );

      // Lưu ảnh vào thư viện ảnh
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: "downloaded_image",
      );

      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image saved to gallery")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save image")),
        );
      }
    } catch (e) {
      print("Error Download: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e")),
      );
    }
  }

  void _showDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey,
          title: const Text("Download Image",
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text("Download 4K best resolution",
                    style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.lock, color: Colors.purpleAccent),
                onTap: null,
              ),
              ListTile(
                title: const Text("Download full HD (1080*1920)",
                    style: TextStyle(color: Colors.white)),
                trailing: Radio(
                  value: "2K",
                  groupValue: _selectedResolution,
                  onChanged: (value) {
                    setState(() {
                      _selectedResolution = value as String;
                    });
                  },
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Column(
              children: [
                TextButton(
                  onPressed:
                      _selectedResolution == "2K" ? _downloadImage : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: _selectedResolution == "2K"
                          ? Colors.purpleAccent
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("Download",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white, size: 30),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleButtons,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Center(
                  child: FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image: widget.imageUrls[index],
                    fit: BoxFit.cover,
                    imageErrorBuilder: (context, error, stackTrace) =>
                        const Icon(
                      Icons.broken_image,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            if (_showButtons) ...[
              Positioned(
                top: 40,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: _shareImage,
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 40,
                right: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(
                      icon: Icons.check,
                      label: 'Apply',
                      onPressed: () {},
                    ),
                    const SizedBox(height: 16),
                    _buildActionButton(
                      icon: FavoriteImages.likedImages
                              .contains(widget.imageUrls[_currentIndex])
                          ? Icons.favorite
                          : Icons.favorite_border,
                      label: 'Like',
                      onPressed: _toggleLike,
                    ),
                    const SizedBox(height: 16),
                    _buildActionButton(
                      icon: Icons.save,
                      label: 'Save',
                      onPressed: _showDownloadDialog,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
