import 'package:flutter/material.dart';
import 'package:iconic/iconic.dart';

class ProfilePicture extends StatelessWidget {
  final String? img;

  const ProfilePicture({super.key, this.img});

  @override
  Widget build(BuildContext context) {
    if (img != null) {
      return CircleAvatar(foregroundImage: NetworkImage(img!));
    } else {
      return Icon(Iconic.user_straight, size: 32);
    }
  }
}
