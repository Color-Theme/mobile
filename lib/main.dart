import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/screens/favorite_screen.dart';
import 'package:mobile/screens/search_screen.dart';
import 'package:mobile/screens/trending_screen.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/widgets/keep_alive_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");

  debugPrint("📂 ENV Loaded: ${dotenv.env.isNotEmpty}");

  runApp(const MyApp());
}

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
  late final TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  int currentPage = 1;
  final int limit = 15;
  bool isLoading = false;
  List<Map<String, dynamic>> imageList = [];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchImages();
    _scrollController.addListener(_onScroll);
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

  // Future<void> _fetchImages() async {
  //   if (isLoading) return;

  //   setState(() => isLoading = true);
  //   debugPrint("🚀 Fetching images... Page: $currentPage, Limit: $limit");

  //   final newImages = await _loadImagesFromApi(); // Gọi API lấy ảnh mới

  //   if (newImages.isNotEmpty && mounted) {
  //     setState(() {
  //       imageList.addAll(newImages); // Thêm ảnh mới vào danh sách cũ
  //       currentPage++; // Tăng trang để lần sau lấy dữ liệu mới hơn
  //       isLoading = false;
  //     });
  //     debugPrint("✅ Total images loaded: ${imageList.length}");
  //   } else if (mounted) {
  //     setState(() => isLoading = false);
  //   }
  // }

  Future<List<Map<String, dynamic>>> _fetchImages() async {
    if (isLoading) return [];

    setState(() => isLoading = true);
    debugPrint("🚀 Fetching images... Page: $currentPage, Limit: $limit");

    final newImages = await _loadImagesFromApi();

    if (mounted) {
      setState(() {
        isLoading = false;
        if (newImages.isNotEmpty) {
          imageList.addAll(newImages);
          currentPage++; // Cập nhật trang
        }
      });
    }

    return newImages;
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !isLoading) {
      _fetchImages();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          ),
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
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Trending'),
            Tab(icon: Icon(Icons.category), text: 'Category'),
            Tab(icon: Icon(Icons.favorite), text: 'Favorite'),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: TabBarView(
          controller: _tabController,
          children: [
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
            _buildDrawerItem('Trending', 0),
            _buildDrawerItem('Category', 1),
            _buildDrawerItem('Favorite', 2),
          ],
        ),
      ),
    );
  }

  ListTile _buildDrawerItem(String title, int index) {
    return ListTile(
      title: Text(title),
      onTap: () {
        _tabController.animateTo(index);
        Navigator.pop(context);
      },
    );
  }
}
