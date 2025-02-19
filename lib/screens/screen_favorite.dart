import 'package:flutter/material.dart';
import 'package:mobile/screens/screen_full_screen_image_view.dart';
import 'package:transparent_image/transparent_image.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FavoriteImages.likedImages.isEmpty
          ? const Center(
              child: Text(
                'No favorite images yet!',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1 / 2,
              ),
              itemCount: FavoriteImages.likedImages.length,
              itemBuilder: (context, index) {
                String imageUrl = FavoriteImages.likedImages.elementAt(index);
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullscreenImageViewer(
                          imageUrls: FavoriteImages.likedImages.toList(),
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: imageUrl,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) =>
                          const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
