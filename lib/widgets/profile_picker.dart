import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePicker extends StatefulWidget {
  final void Function(File? selectedImage) onImagePick;

  const ProfilePicker({required this.onImagePick, super.key});

  @override
  State<ProfilePicker> createState() => ProfilePickerState();
}

class ProfilePickerState extends State<ProfilePicker> {
  File? _selectedImage;

  void _showSelectorSheet() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _selectImage(true);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera),
                        SizedBox(height: 6),
                        Text('Camera'),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    _selectImage(false);
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image),
                        SizedBox(height: 6),
                        Text('Gallery'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _selectImage(bool isCameraMode) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: isCameraMode ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 150,
      imageQuality: 50,
    );
    if (pickedImage == null) {
      return;
    }

    // The following code will never excute if there pickedImage was null
    setState(() {
      _selectedImage = File(pickedImage.path);
    });
    widget.onImagePick(_selectedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            InkWell(
              onTap: _showSelectorSheet,
              borderRadius: BorderRadius.circular(360),
              child: Ink(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF423D47),
                  border: Border.all(color: Color(0xFFFAF9FB)),
                  image:
                      _selectedImage != null
                          ? DecorationImage(image: FileImage(_selectedImage!))
                          : null,
                ),
                child: Align(
                  child: SvgPicture.asset(
                    'assets/icons/profile-add.svg',
                    width: 28,
                    height: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set up your profile',
              style: TextStyle(
                color: Color(0xFFF4F1F6),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Choose your profile picture',
              style: TextStyle(
                color: Color(0x80F4F1F6),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
