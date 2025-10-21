import 'package:flutter/material.dart';

// A MessageBubble for showing a single chat message on the ChatScreen.
class MessageBubble extends StatelessWidget {
  // Create a message bubble which is meant to be the first in the sequence.
  const MessageBubble.first({
    super.key,
    required this.userImage,
    required this.username,
    required this.message,
    required this.isMe,
  }) : isFirstInSequence = true;

  // Create a amessage bubble that continues the sequence.
  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
  }) : isFirstInSequence = false,
       userImage = null,
       username = null;

  // Whether or not this message bubble is the first in a sequence of messages
  // from the same user.
  // Modifies the message bubble slightly for these different cases - only
  // shows user image for the first message from the same user, and changes
  // the shape of the bubble for messages thereafter.
  final bool isFirstInSequence;

  // Image of the user to be displayed next to the bubble.
  // Not required if the message is not the first in a sequence.
  final String? userImage;

  // Username of the user.
  // Not required if the message is not the first in a sequence.
  final String? username;
  final String message;

  // Controls how the MessageBubble will be aligned.
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    print('Color -- ${Theme.of(context).colorScheme.primary}');
    return Stack(
      children: [
        if (userImage != null && !isMe)
          Positioned(
            top: 6,
            // Align user image to the right, if the message is from me.
            right: isMe ? 0 : null,
            child: Container(
              width: 36,
              height: 36,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(62, 0, 0, 0),
              ),
              child: Image.network(userImage!, fit: BoxFit.cover),
            ),
          ),
        Container(
          // Add some margin to the edges of the messages, to allow space for the
          // user's image.
          margin: EdgeInsets.symmetric(horizontal: isMe ? 0 : 40),
          child: Row(
            // The side of the chat screen the message should show at.
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // First messages in the sequence provide a visual buffer at
                  // the top.
                  // The "speech" box surrounding the message.
                  Container(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors:
                            isMe
                                ? [
                                  Color.fromARGB(255, 144, 126, 198),
                                  Color.fromARGB(255, 102, 84, 155),
                                ]
                                : [Color(0x77535057), Color(0x77363438)],
                      ),
                      // Only show the message bubble's "speaking edge" if first in
                      // the chain.
                      // Whether the "speaking edge" is on the left or right depends
                      // on whether or not the message bubble is the current user.
                      borderRadius: BorderRadius.only(
                        topLeft:
                            !isMe && isFirstInSequence
                                ? const Radius.circular(6)
                                : const Radius.circular(22),
                        topRight:
                            isMe && isFirstInSequence
                                ? const Radius.circular(6)
                                : const Radius.circular(22),
                        bottomLeft: const Radius.circular(22),
                        bottomRight: const Radius.circular(22),
                      ),
                    ),
                    // Set some reasonable constraints on the width of the
                    // message bubble so it can adjust to the amount of text
                    // it should show.
                    constraints: const BoxConstraints(maxWidth: 200),
                    padding: EdgeInsets.only(
                      right: 22,
                      left: 22,
                      top: (isFirstInSequence && !isMe) ? 16 : 12,
                      bottom: 22,
                    ),
                    // Margin around the bubble.
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 12,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (username != null && !isMe && isFirstInSequence)
                          Text(
                            username!,
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w400,
                              fontSize: 11,
                              color: Color(0x80FAF9FB),
                            ),
                          ),
                        SizedBox(height: 8),
                        Text(
                          message,
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: Color(0xFFF3F1F6),
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
