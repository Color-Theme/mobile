import 'package:flutter/material.dart';
import 'package:mobile/widgets/image_item.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({
    super.key,
    required this.imageList,
    required this.scrollController,
    required this.loadMoreImages,
  });

  final List<Map<String, dynamic>> imageList;
  final ScrollController scrollController;
  final Future<List<Map<String, dynamic>>> Function() loadMoreImages;

  @override
  _TrendingScreenState createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen>
    with AutomaticKeepAliveClientMixin {
  bool isLoading = false; // 🛠️ Thêm biến isLoading

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController.hasClients &&
        widget.scrollController.position.pixels >=
            widget.scrollController.position.maxScrollExtent * 0.9 &&
        !isLoading) {
      _fetchImages();
    }
  }

  Future<void> _fetchImages() async {
    if (isLoading) return;

    setState(() => isLoading = true);
    debugPrint("🚀 Fetching images...");

    final newImages =
        await widget.loadMoreImages(); // ✅ loadMoreImages trả về danh sách ảnh

    if (mounted) {
      setState(() {
        isLoading = false;
        if (newImages.isNotEmpty) {
          widget.imageList.addAll(newImages);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return CustomScrollView(
      controller: widget.scrollController,
      slivers: [
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
            childAspectRatio: 1 / 2,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ImageItem(
                index: index,
                image: widget.imageList[index],
                imageList: widget.imageList,
              );
            },
            childCount: widget.imageList.length,
          ),
        ),
      ],
    );
  }
}
