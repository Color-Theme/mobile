import 'package:flutter/material.dart';
import 'package:mobile/main.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({
    super.key,
    required this.imageList,
    required this.scrollController,
    required this.loadMoreImages,
  });

  final List<Map<String, dynamic>> imageList;
  final ScrollController scrollController;
  final Future<void> Function() loadMoreImages;

  @override
  _TrendingScreenState createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: RefreshIndicator(
        onRefresh: widget.loadMoreImages,
        child: GridView.builder(
          key: const PageStorageKey('TrendingScreenGrid'),
          controller: widget.scrollController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
            crossAxisCount: 3,
            childAspectRatio: 1 / 2,
          ),
          itemCount: widget.imageList.length,
          itemBuilder: (context, index) {
            return ImageItem(
              index: index,
              image: widget.imageList[index],
              imageList: widget.imageList,
            );
          },
        ),
      ),
    );
  }
}
