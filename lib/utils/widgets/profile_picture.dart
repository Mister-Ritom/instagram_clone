import 'package:flutter/material.dart';
import 'package:iconic/iconic.dart';

class ProfilePicture extends StatelessWidget {
  final String? img;
  final double? size;

  const ProfilePicture({super.key, this.img, this.size});

  @override
  Widget build(BuildContext context) {
    if (img != null) {
      return CircleAvatar(foregroundImage: NetworkImage(img!), radius: size);
    } else {
      return Icon(Iconic.user_straight, size: size ?? 32);
    }
  }
}
