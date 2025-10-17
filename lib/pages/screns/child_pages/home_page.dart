import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconic/iconic.dart';
import 'package:instagram_clone/core/supabase_client.dart';
import 'package:instagram_clone/models/post_model.dart';
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      final response = await supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      final fetchedPosts = data.map((e) => PostModel.fromMap(e)).toList();

      setState(() {
        posts = fetchedPosts;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching posts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

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
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : posts.isEmpty
              ? const Center(child: Text('No posts yet'))
              : ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // image or video placeholder
                        if (post.isReel)
                          AspectRatio(
                            aspectRatio: 9 / 16,
                            child: Container(
                              color: Colors.black12,
                              child: Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        else
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              post.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 300,
                              errorBuilder: (context, error, stackTrace) {
                                log(
                                  "Something wrong",
                                  error: error,
                                  stackTrace: stackTrace,
                                );
                                return const Center(
                                  child: Icon(Icons.broken_image),
                                );
                              },
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            post.caption ?? '',
                            style: GoogleFonts.inter(fontSize: 15),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            children: [
                              Icon(Iconic.heart, size: 20),
                              const SizedBox(width: 6),
                              Text('${post.likeCount} likes'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
