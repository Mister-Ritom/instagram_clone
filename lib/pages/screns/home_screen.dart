import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_riverpod/legacy.dart';
import 'package:iconic/iconic.dart';
import 'package:instagram_clone/pages/screns/child_pages/discover_page.dart';
import 'package:instagram_clone/pages/screns/child_pages/home_page.dart';
import 'package:instagram_clone/pages/screns/child_pages/profile_page.dart';
import 'package:instagram_clone/pages/screns/child_pages/reels_page.dart';

// Providers remain the same
final pageProvider = StateProvider<int>((ref) => 0);
final navIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isAddPageVisible = false;

  final pages = const [HomePage(), DiscoverPage(), ReelsPage(), ProfilePage()];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _showAddPage() {
    setState(() => _isAddPageVisible = true);
    _controller.forward();
  }

  void _hideAddPage() {
    _controller.reverse().then((_) {
      if (mounted) setState(() => _isAddPageVisible = false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPageIndex = ref.watch(pageProvider);
    final currentNavIndex = ref.watch(navIndexProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Main pages
          KeyedSubtree(
            key: ValueKey(currentPageIndex),
            child: pages[currentPageIndex],
          ),

          // Add Post Page overlay
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (_isAddPageVisible) {
                // Page is visible → drag right to left to hide
                if (details.primaryDelta! < 0) {
                  _controller.value +=
                      details.primaryDelta! / MediaQuery.of(context).size.width;
                }
              } else {
                // Page is hidden → drag left to right to show
                if (details.primaryDelta! > 0) {
                  _controller.value +=
                      details.primaryDelta! / MediaQuery.of(context).size.width;
                }
              }
            },
            onHorizontalDragEnd: (details) {
              if (_isAddPageVisible) {
                // Decide whether to hide or keep visible
                if (_controller.value < 0.5) {
                  _hideAddPage();
                } else {
                  _controller.forward();
                }
              } else {
                // Decide whether to show or stay hidden
                if (_controller.value > 0.5) {
                  _showAddPage();
                } else {
                  _controller.reverse();
                }
              }
            },
            child:
                _isAddPageVisible
                    ? SlideTransition(
                      position: _slideAnimation,
                      child: AddPostPage(),
                    )
                    : null,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentNavIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Iconic.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Iconic.search), label: ""),
          BottomNavigationBarItem(icon: Icon(Iconic.add), label: ""),
          BottomNavigationBarItem(icon: Icon(Iconic.tablet), label: ""),
          BottomNavigationBarItem(icon: Icon(Iconic.user), label: ""),
        ],
        onTap: (index) {
          if (index == 2) {
            _showAddPage();
          } else {
            final pageIndex = index == 4 ? 3 : index;
            ref.read(pageProvider.notifier).state = pageIndex;
            ref.read(navIndexProvider.notifier).state = index;
          }
        },
      ),
    );
  }
}

// Dummy AddPostPage
class AddPostPage extends StatelessWidget {
  const AddPostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const Center(child: Text("Add Post Page")));
  }
}
