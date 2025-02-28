import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class FavoriteImages {
  static final Set<String> likedImages = {};
}

class FullscreenImageScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullscreenImageScreen({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<FullscreenImageScreen> createState() => _FullscreenImageScreenState();
}

class _FullscreenImageScreenState extends State<FullscreenImageScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showButtons = true;
  String _selectedResolution = "2K";
  bool get wantKeepAlive => true;

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

  void _shareImage() async {
    String imageUrl = widget.imageUrls[_currentIndex];
    try {
      var response = await Dio().get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final tempDir = await getTemporaryDirectory();
      final filePath = "${tempDir.path}/shared_image.jpg";
      await File(filePath).writeAsBytes(response.data);

      Share.shareXFiles([XFile(filePath)], text: "Check out this image!");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sharing failed: $e")),
      );
    }
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
      var status = await Permission.photos.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission denied to save image")),
        );
        return;
      }

      var response = await Dio().get(
        widget.imageUrls[_currentIndex],
        options: Options(responseType: ResponseType.bytes),
      );

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e")),
      );
    }
  }

  void _showDownloadSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              ElevatedButton(
                onPressed: _selectedResolution == "2K" ? _downloadImage : null,
                child: const Text("Download"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("Cancel", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
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
                return CachedNetworkImage(
                  imageUrl: widget.imageUrls[index],
                  fit: BoxFit.cover,
                );
              },
            ),
            if (_showButtons)
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
            if (_showButtons)
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
                      onPressed: _showDownloadSheet,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
