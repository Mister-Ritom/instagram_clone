enum PostMode {
  post("Post"),
  story("Story"),
  reel("Reel");

  const PostMode(this.displayName);
  final String displayName;

  /// Determines the correct bucket name based on the type and media.
  /// [isVideoPost] applies only when [this] == PostMode.post
  String bucketName({bool isVideoPost = false}) {
    switch (this) {
      case PostMode.post:
        return isVideoPost ? "post-videos" : "post-photos";
      case PostMode.story:
        return "stories";
      case PostMode.reel:
        return "reels";
    }
  }

  String databaseName() {
    switch (this) {
      case PostMode.post:
        return "posts";
      case PostMode.story:
        return "stories";
      case PostMode.reel:
        return "reels";
    }
  }
}
