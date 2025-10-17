import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconic/iconic.dart';
import 'package:instagram_clone/core/supabase_client.dart';
import 'package:instagram_clone/models/post_model.dart';
import 'package:instagram_clone/models/story_model.dart';
import 'package:instagram_clone/utils/reusable/util_vars.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient supabase = Database.client;

  List<PostModel> posts = [];
  List<StoryModel> stories = [];
  bool isLoadingPosts = true;
  bool isLoadingStories = true;

  @override
  void initState() {
    super.initState();
    fetchStories();
    fetchPosts();
  }

  // Fetch user info helper
  Future<Map<String, dynamic>?> fetchUserInfo(String userId) async {
    try {
      final response =
          await supabase.from('profiles').select().eq('id', userId).single();
      return response as Map<String, dynamic>?;
    } catch (e) {
      log("Error fetching user info: $e");
      return null;
    }
  }

  // ================= FETCH POSTS =================
  Future<void> fetchPosts() async {
    try {
      final response = await supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      setState(() {
        posts = data.map((e) => PostModel.fromMap(e)).toList();
        isLoadingPosts = false;
      });
    } catch (e) {
      log('Error fetching posts: $e');
      setState(() => isLoadingPosts = false);
    }
  }

  // ================= FETCH STORIES =================
  Future<void> fetchStories() async {
    try {
      final response = await supabase
          .from('stories')
          .select()
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      setState(() {
        stories = data.map((e) => StoryModel.fromMap(e)).toList();
        isLoadingStories = false;
      });
    } catch (e) {
      log('Error fetching stories: $e');
      setState(() => isLoadingStories = false);
    }
  }

  Widget storyItem(StoryModel story) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchUserInfo(story.userId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final username = user?['username'] ?? 'Unknown';
        final profileImage = user?['avatar_url'];

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.redAccent, // story border color
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundImage:
                    profileImage != null ? NetworkImage(profileImage) : null,
                child: profileImage == null ? const Icon(Icons.person) : null,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 60,
              child: Text(
                username,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget postItem(PostModel post) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchUserInfo(post.userId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final username = user?['username'] ?? 'Unknown';
        final profileImage = user?['avatar_url'];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= User Info Row =================
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage:
                          profileImage != null
                              ? NetworkImage(profileImage)
                              : null,
                      child:
                          profileImage == null
                              ? const Icon(Icons.person)
                              : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),

              // ================= Post Image / Video =================
              if (post.isReel)
                AspectRatio(
                  aspectRatio: 9 / 16,
                  child: Container(
                    color: Colors.black12,
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else
                Image.network(
                  post.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 300,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.broken_image)),
                ),

              // ================= Actions =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Iconic.heart, size: 28),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Iconic.comment, size: 28),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Iconic.paper_plane, size: 28),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Iconic.bookmark, size: 28),
                    ),
                  ],
                ),
              ),

              // ================= Like Count =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${post.likeCount} likes',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              // ================= Caption =================
              if (post.caption != null && post.caption!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(text: post.caption),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          UtilVars.appName,
          style: GoogleFonts.pacifico(letterSpacing: 4),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Iconic.heart)),
          IconButton(onPressed: () {}, icon: Icon(Iconic.comment)),
        ],
        centerTitle: false,
      ),
      body:
          isLoadingPosts && isLoadingStories
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: () async {
                  await fetchStories();
                  await fetchPosts();
                },
                child: ListView(
                  children: [
                    // ================= STORIES =================
                    SizedBox(
                      height: 100,
                      child:
                          isLoadingStories
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: stories.length,
                                itemBuilder: (context, index) {
                                  return storyItem(stories[index]);
                                },
                              ),
                    ),
                    const Divider(),
                    // ================= POSTS =================
                    isLoadingPosts
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            return postItem(posts[index]);
                          },
                        ),
                  ],
                ),
              ),
    );
  }
}
