import 'dart:io';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:chat_practice/core/styles/text_styles.dart';
import 'package:chat_practice/util/snackbar_util.dart';
import 'package:chat_practice/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../util/loading_dialog_util.dart';

class ChatScreen extends StatefulWidget {
  bool? hasSignedUp;
  String? username;
  File? selectedImage;
  VoidCallback? resetHasSignedUp;
  ChatScreen({super.key});

  ChatScreen.withSignUp({
    required this.hasSignedUp,
    required this.username,
    required this.selectedImage,
    required this.resetHasSignedUp,
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();

  bool _showSendButton = false;

  void _uploadUserData() async {
    LoadingDialogUtil.showLoadingDialog(context);
    try {
      // The following code uploads the image to Firebase Storage
      final currentUser = FirebaseAuth.instance.currentUser!;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile-pictures')
          .child('${currentUser.uid}.jpg');
      await storageRef.putFile(widget.selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();

      // The following code saves the username of the user in Cloud Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set(<String, String>{
            'email': currentUser.email!,
            'username': widget.username!,
            'image-url': imageUrl,
          });
    } catch (exception) {
      SnackbarUtil.showErrorSnacbar(context, 'An error occurred');
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.currentUser!.delete();
      }
    } finally {
      Navigator.pop(context);
      widget.resetHasSignedUp!();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.hasSignedUp != null) {
        _uploadUserData();
      }

      _messageController.addListener(() {
        setState(() {
          _showSendButton = _messageController.text.isNotEmpty;
        });
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appbarColor = Theme.of(
      context,
    ).scaffoldBackgroundColor.withOpacity(0.65);
    final errorColor = const Color(0xFFFF7652);
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12, right: 8, left: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('messages')
                            .orderBy('sent-at', descending: true)
                            .snapshots(),
                    builder: (context, snapshot) {
                      late DateTime messageDate;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.send,
                                color: Theme.of(context).colorScheme.primary,
                                size: 50,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No messages found',
                                style: Theme.of(context).textTheme.titleLarge!,
                              ),
                              Text(
                                'Send one right away!',
                                style: Theme.of(context).textTheme.bodyMedium!,
                              ),
                            ],
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('An error occurred'));
                      }
                      final messagesDocuments = snapshot.data!.docs;
                      return ListView.separated(
                        reverse: true,
                        itemCount: messagesDocuments.length,
                        separatorBuilder: (context, index) {
                          final currentMessage = messagesDocuments[index];
                          if (index < messagesDocuments.length - 1) {
                            final previousMessage =
                                messagesDocuments[index + 1];
                            final currentMessageSender =
                                currentMessage['sender'];
                            final previousMessageSender =
                                previousMessage['sender'];
                            if (currentMessageSender == previousMessageSender) {
                              return SizedBox(height: 0);
                            }
                          }

                          return SizedBox(height: 12);
                        },
                        itemBuilder: (context, index) {
                          final currentMessage = messagesDocuments[index];
                          final isMe =
                              messagesDocuments[index]['sender'] ==
                              FirebaseAuth.instance.currentUser!.uid;
                          final userImage = currentMessage['image-url'];
                          final username = currentMessage['username'];
                          if (index < messagesDocuments.length - 1) {
                            final previousMessage =
                                messagesDocuments[index + 1];
                            final currentMessageSender =
                                currentMessage['sender'];
                            final previousMessageSender =
                                previousMessage['sender'];
                            if (currentMessageSender == previousMessageSender) {
                              return MessageBubble.next(
                                message: currentMessage['text'],
                                isMe: isMe,
                              );
                            }
                          }

                          return MessageBubble.first(
                            userImage: userImage,
                            username: username,
                            message: currentMessage['text'],
                            isMe: isMe,
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          child: TextField(
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFF3F1F6),
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(360),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 20,
                              ),
                              fillColor: const Color(0xFF2F2B33),
                              filled: true,
                              hintText: 'Enter message',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xA6DFDCE1),
                              ),
                            ),
                            controller: _messageController,
                          ),
                        ),
                      ),
                      if (_showSendButton) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          iconSize: 20,
                          onPressed: () async {
                            final enteredMessage = _messageController.text;
                            if (enteredMessage.trim().isEmpty) {
                              return;
                            }
                            LoadingDialogUtil.showLoadingDialog(context);
                            try {
                              final imageUrl =
                                  await FirebaseStorage.instance
                                      .ref(
                                        'profile-pictures/${FirebaseAuth.instance.currentUser!.uid}.jpg',
                                      )
                                      .getDownloadURL();
                              final userData =
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(
                                        FirebaseAuth.instance.currentUser!.uid,
                                      )
                                      .get();
                              final username = userData['username'];
                              await FirebaseFirestore.instance
                                  .collection('messages')
                                  .add({
                                    'text': _messageController.text,
                                    'sender':
                                        FirebaseAuth.instance.currentUser!.uid,
                                    'sent-at': Timestamp.now(),
                                    'image-url': imageUrl,
                                    'username': username,
                                  });
                              _messageController.clear();
                            } catch (exception) {
                              SnackbarUtil.showErrorSnacbar(
                                context,
                                'An error occurred',
                              );
                            } finally {
                              Navigator.pop(context);
                            }
                          },
                          icon: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromARGB(255, 115, 96, 172),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                'assets/icons/send.svg',
                                width: 24,
                                height: 24,
                                // ignore: deprecated_member_use
                                color: Color(0xFFEAE5EF),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x14FAF9FB),
              ),
            ),
          ),
          SafeArea(
            child: BlurryContainer(
              blur: 24,
              padding: const EdgeInsets.all(0),
              borderRadius: BorderRadius.zero,
              child: Container(
                color: appbarColor,
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 16,
                  left: 20,
                  right: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/globe.svg',
                          // ignore: deprecated_member_use
                          color: const Color(0xFFFAF9FB),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Global Chat',
                          style: AppTextStyles.body1Semi.copyWith(
                            color: const Color(0xFFFAF9FB),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Log out',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: errorColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
