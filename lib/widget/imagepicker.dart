import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Getimage extends StatefulWidget {
  const Getimage({super.key, required this.onpickimage});
final void Function(File pickedimage) onpickimage;
  @override
  State<Getimage> createState() => _GetimageState();
}

class _GetimageState extends State<Getimage> {
  File? selectedimage;
  void imagepicker() async {
    final imagepicker = ImagePicker();
    final pickedimage = await imagepicker.pickImage(
        source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    if (pickedimage == null) {
      return;
    }
    setState(() {
      selectedimage = File(pickedimage.path);
    });
    widget.onpickimage(selectedimage!);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: selectedimage != null?FileImage(selectedimage!):null,
          ),
          TextButton.icon(
              onPressed: () {
                imagepicker();
              },
              icon: Icon(Icons.camera_alt_outlined),
              label: Text('upload image'))
        ],
      ),
    );
  }
}
