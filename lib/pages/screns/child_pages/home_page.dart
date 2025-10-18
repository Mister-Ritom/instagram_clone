import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconic/iconic.dart';
import 'package:instagram_clone/core/supabase_client.dart';
import 'package:instagram_clone/models/comment_model.dart';
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

      // Group stories by userId
      final uniqueUserIds = <String>{};
      final uniqueStories = <StoryModel>[];

      for (var e in data) {
        final story = StoryModel.fromMap(e);
        if (!uniqueUserIds.contains(story.userId)) {
          uniqueUserIds.add(story.userId);
          uniqueStories.add(story);
        }
      }

      setState(() {
        stories = uniqueStories;
        isLoadingStories = false;
      });
    } catch (e) {
      log('Error fetching stories: $e');
      setState(() => isLoadingStories = false);
    }
  }

  // ================= CHECK IF CURRENT USER HAS STORY =================
  Future<bool> hasCurrentUserStory() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final res = await supabase
        .from('stories')
        .select('id')
        .eq('user_id', userId)
        .limit(1);

    return res.isNotEmpty;
  }

  // ================= ADD STORY ITEM =================
  Widget addStoryItem() {
    return FutureBuilder(
      future: Future.wait([
        UtilVars.fetchCurrentUserProfile(),
        hasCurrentUserStory(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 70,
            width: 70,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final user = snapshot.data![0] as Map<String, dynamic>?;
        final hasStory = snapshot.data![1] as bool;
        final profileImage = user?['avatar_url'];

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    hasStory
                        ? Border.all(
                          color: Colors.redAccent, // story border
                          width: 2,
                        )
                        : null,
              ),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        profileImage != null
                            ? NetworkImage(profileImage)
                            : null,
                    backgroundColor:
                        profileImage == null ? Colors.grey : Colors.transparent,
                    child:
                        profileImage == null
                            ? const Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.white,
                            )
                            : null,
                  ),
                  if (!hasStory)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const SizedBox(
              width: 60,
              child: Text(
                "Your Story",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= STORY ITEM =================
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
                border: Border.all(color: Colors.redAccent, width: 2),
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

  // ================= POST ITEM =================
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
              PostActions(post: post),

              // ================= Caption =================
              if (post.caption != null && post.caption!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(),
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
    final currentUserId = supabase.auth.currentUser?.id;

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
                      height: 110,
                      child:
                          isLoadingStories
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: stories.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      child: addStoryItem(),
                                    );
                                  } else {
                                    final story = stories[index - 1];
                                    if (story.userId == currentUserId) {
                                      // hide own story in list
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      child: storyItem(story),
                                    );
                                  }
                                },
                              ),
                    ),

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

extension FormatNumber on int {
  String get formatted {
    if (this >= 1000000) return '${(this / 1000000).toStringAsFixed(1)}M';
    if (this >= 1000) return '${(this / 1000).toStringAsFixed(1)}K';
    return toString();
  }
}

class PostActions extends StatefulWidget {
  final PostModel post;

  const PostActions({super.key, required this.post});

  @override
  State<PostActions> createState() => _PostActionsState();
}

class _PostActionsState extends State<PostActions>
    with TickerProviderStateMixin {
  late PostModel _post;
  bool _isLiked = false;
  late AnimationController _likeController;
  final client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _checkIfLiked();
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      lowerBound: 0.8,
      upperBound: 1,
    );
  }

  Future<void> _checkIfLiked() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    final res =
        await client
            .from('likes')
            .select('user_id')
            .eq('post_id', _post.id)
            .eq('user_id', userId)
            .maybeSingle();

    setState(() => _isLiked = res != null);
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    final previouslyLiked = _isLiked;

    setState(() {
      _isLiked = !_isLiked;
      _post = _post.copyWith(likeCount: _post.likeCount + (_isLiked ? 1 : -1));
    });
    _likeController.reset();
    _likeController.forward(from: 0.8);

    try {
      if (previouslyLiked) {
        // User already liked → unlike
        await client
            .from('likes')
            .delete()
            .eq('post_id', _post.id)
            .eq('user_id', userId);
      } else {
        // New like
        await client.from('likes').insert({
          'post_id': _post.id,
          'user_id': userId,
        });
      }

      // Update like_count in posts table
      await client
          .from('posts')
          .update({'like_count': _post.likeCount})
          .eq('id', _post.id);
    } catch (e) {
      // revert UI if something goes wrong
      setState(() {
        _isLiked = previouslyLiked;
        _post = _post.copyWith(
          likeCount: _post.likeCount + (previouslyLiked ? 1 : -1),
        );
      });
      debugPrint('Error toggling like: $e');
    }
  }

  Future<void> _incrementShare() async {
    final shared = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => _ShareBottomSheet(post: _post),
    );

    if (shared == true) {
      setState(() {
        _post = _post.copyWith(shareCount: _post.shareCount + 1);
      });
      await client
          .from('posts')
          .update({'share_count': _post.shareCount})
          .eq('id', _post.id);
    }
  }

  Future<void> _showComments() async {
    final newCount = await showModalBottomSheet<int>(
      isScrollControlled: true,
      showDragHandle: true,
      context: context,
      builder: (context) => _CommentsBottomSheet(postId: _post.id),
    );

    // when closed, update comment count
    if (newCount != null && newCount != _post.commentCount) {
      setState(() {
        _post = _post.copyWith(commentCount: newCount);
      });
    }
  }

  final iconSize = 22.0;

  Widget buildAction({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
    required Animation<double> scale,
    Color? color,
  }) {
    return SizedBox(
      width: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: scale,
            child: IconButton(
              iconSize: iconSize,
              onPressed: onTap,
              padding: EdgeInsets.zero,
              icon: Icon(icon, color: color ?? Colors.white),
            ),
          ),
          SizedBox(
            width: iconSize,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                count.formatted,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          buildAction(
            icon: _isLiked ? Iconic.heart_solid : Iconic.heart,
            count: _post.likeCount,
            onTap: _toggleLike,
            color: _isLiked ? Colors.red : null,
            scale: _likeController.drive(CurveTween(curve: Curves.elasticOut)),
          ),
          buildAction(
            icon: Iconic.comment,
            count: _post.commentCount,
            onTap: _showComments,
            scale: const AlwaysStoppedAnimation(1),
          ),
          buildAction(
            icon: Iconic.paper_plane,
            count: _post.shareCount,
            onTap: _incrementShare,
            scale: const AlwaysStoppedAnimation(1),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.bookmark, size: iconSize),
          ),
        ],
      ),
    );
  }
}

//
// SHARE BOTTOM SHEET
//
class _ShareBottomSheet extends StatelessWidget {
  final PostModel post;
  const _ShareBottomSheet({required this.post});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          runSpacing: 12,
          children: [
            Text('Share Post', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy link'),
              onTap: () {
                // Clipboard.setData(ClipboardData(text: post.shareUrl));
                Navigator.pop(context, true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.send),
              title: const Text('Send via app'),
              onTap: () {
                // share logic
                Navigator.pop(context, true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ),
    );
  }
}

//
// COMMENTS BOTTOM SHEET
//
class _CommentsBottomSheet extends StatefulWidget {
  final String postId;
  const _CommentsBottomSheet({required this.postId});

  @override
  State<_CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<_CommentsBottomSheet> {
  final _controller = TextEditingController();
  final client = Supabase.instance.client;
  List<Comment> comments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final res = await client
        .from('comments')
        .select()
        .eq('post_id', widget.postId)
        .order('created_at', ascending: false);

    setState(() {
      comments = (res as List).map((e) => Comment.fromMap(e)).toList();
      _loading = false;
    });
  }

  Future<void> _addComment() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    final newComment = Comment(
      postId: widget.postId,
      userId: client.auth.currentUser!.id,
      content: content,
    );

    await client.from('comments').insert(newComment.toMap());
    _controller.clear();
    await _fetchComments();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 250),
        padding: MediaQuery.of(context).viewInsets,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Comments', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: comments.length,
                    itemBuilder: (_, i) {
                      final c = comments[i];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(c.content),
                        subtitle: Text(c.createdAt?.toLocal().toString() ?? ''),
                      );
                    },
                  ),
                ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
