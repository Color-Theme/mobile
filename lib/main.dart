import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mobile/screens/screen_favorite.dart';
import 'package:mobile/screens/screen_full_screen_image_view.dart';
import 'package:mobile/screens/screen_search.dart';
import 'package:mobile/screens/screen_trending.dart';
import 'package:mobile/services/api_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const appTitle = 'Drawer Demo';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  int currentPage = 1;
  final int limit = 30;
  bool isLoading = false;
  List<Map<String, dynamic>> imageList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchImages();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchImages() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      List<Map<String, dynamic>> newImages =
          await ApiService.fetchImages(currentPage, limit);
      setState(() {
        imageList.addAll(newImages);
        currentPage++;
      });
    } catch (e) {
      print("Error fetching images: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !isLoading) {
      _fetchImages();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
    _fetchImages();
    _scrollController.addListener(_onScroll);
  }

  Widget buildImage(BuildContext context, int index) {
    final image = imageList[index];
    String downloadCount = image['id'];

    return Stack(children: [
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FullscreenImageViewer(
                imageUrls:
                    imageList.map((e) => e['download_url'] as String).toList(),
                initialIndex: index,
              ),
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: image['download_url'],
              useOldImageOnUrlChange: true,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              fadeInDuration: Duration.zero,
              placeholder: (context, url) {
                return FutureBuilder<FileInfo?>(
                  future: DefaultCacheManager().getFileFromCache(url),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData &&
                        snapshot.data != null) {
                      return Image.file(
                        snapshot.data!.file,
                        fit: BoxFit.cover,
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                );
              },
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ],
        ),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              children: [
                const Icon(
                  Icons.download,
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  downloadCount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchScreen(),
              ),
            );
          },
          child: IgnorePointer(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Search...",
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home),
                  SizedBox(width: 8),
                  Text('Trending'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.category),
                  SizedBox(width: 8),
                  Text('Category'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite),
                  SizedBox(width: 8),
                  Text('Favorite'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            // TrendingScreen(
            //   imageList: imageList,
            //   scrollController: _scrollController,
            //   loadMoreImages: _fetchImages,
            // ),
            KeepAliveWrapper(
              child: TrendingScreen(
                imageList: imageList,
                scrollController: _scrollController,
                loadMoreImages: _fetchImages,
              ),
            ),
            const Center(
                child:
                    Text('Category Section', style: TextStyle(fontSize: 20))),
            const FavoriteScreen(),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Trending'),
              onTap: () {
                _tabController.animateTo(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Category'),
              onTap: () {
                _tabController.animateTo(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Favorite'),
              onTap: () {
                _tabController.animateTo(2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ImageItem extends StatefulWidget {
  const ImageItem({
    super.key,
    required this.index,
    required this.image,
    required this.imageList,
  });

  final int index;
  final Map<String, dynamic> image;
  final List<Map<String, dynamic>> imageList;

  @override
  _ImageItemState createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(children: [
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FullscreenImageViewer(
                imageUrls: widget.imageList
                    .map((e) => e['download_url'] as String)
                    .toList(),
                initialIndex: widget.index,
              ),
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: widget.image['download_url'],
              useOldImageOnUrlChange: true,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              fadeInDuration: Duration.zero,
              placeholder: (context, url) {
                return FutureBuilder<FileInfo?>(
                  future: DefaultCacheManager().getFileFromCache(url),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData &&
                        snapshot.data != null) {
                      return Image.file(
                        snapshot.data!.file,
                        fit: BoxFit.cover,
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                );
              },
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ],
        ),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              children: [
                const Icon(
                  Icons.download,
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.image['id'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}

class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const KeepAliveWrapper({Key? key, required this.child}) : super(key: key);

  @override
  _KeepAliveWrapperState createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // ✅ Giữ trạng thái widget khi đổi tab

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
