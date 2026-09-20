import 'package:flutter/material.dart';

class ChatTypingScreen extends StatefulWidget {
  const ChatTypingScreen({super.key});

  @override
  State<ChatTypingScreen> createState() => _ChatTypingScreenState();
}

class _ChatTypingScreenState extends State<ChatTypingScreen> {
  final List<Map<String, dynamic>> _messages = [
    {
      "text": "Hey! Are you available today?",
      "isMe": false,
      "time": "09:25 AM",
    },
    {
      "text": "Hi Jane! Yes, I'm available.",
      "isMe": true,
      "time": "09:26 AM",
    },
    {
      "text": "Great! I wanted to discuss the documents.",
      "isMe": false,
      "time": "09:27 AM",
    },
    {
      "text": "Sure, send them over.",
      "isMe": true,
      "time": "09:28 AM",
    },
    {
      "text": "I've just sent them. Please check.",
      "isMe": false,
      "time": "09:29 AM",
    },
    {
      "text": "Got them, thank you!",
      "isMe": true,
      "time": "09:30 AM",
    },
  ];

  final TextEditingController _controller =
      TextEditingController(
    text: "Sure, I'll check them now.",
  );

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      FocusScope.of(context).requestFocus(_focusNode);

      _controller.selection = TextSelection.fromPosition(
        TextPosition(
          offset: _controller.text.length,
        ),
      );
    });
  }

  void _sendMessage() {
    final message = _controller.text.trim();

    if (message.isEmpty) return;

    setState(() {
      _messages.add({
        "text": message,
        "isMe": true,
        "time": TimeOfDay.now().format(context),
      });
    });

    _controller.clear();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildMessageBubble(
    String text,
    bool isMe,
    String time,
  ) {
    return Align(
      alignment:
          isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 5,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? Colors.green
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(
              isMe ? 18 : 4,
            ),
            bottomRight: Radius.circular(
              isMe ? 4 : 18,
            ),
          ),
          border: isMe
              ? null
              : Border.all(
                  color: Colors.grey.shade200,
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.03,
              ),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe
                    ? Colors.white
                    : Colors.black87,
                fontSize: 15,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(
                color: isMe
                    ? Colors.white70
                    : Colors.black45,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8FAF8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        titleSpacing: 0,

        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor:
                      Colors.green.shade100,
                  child: Text(
                    "J",
                    style: TextStyle(
                      color:
                          Colors.green.shade800,
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration:
                        BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 10),

            const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "Jane Smith",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Online",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.phone_outlined,
              color: Colors.black87,
            ),
            onPressed: () {
              _showMessage("Call Jane");
            },
          ),

          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black87,
            ),
            onPressed: () {
              _showMessage("Chat options");
            },
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                itemCount: _messages.length,
                itemBuilder:
                    (context, index) {
                  final msg =
                      _messages[index];

                  return _buildMessageBubble(
                    msg["text"],
                    msg["isMe"],
                    msg["time"],
                  );
                },
              ),
            ),

            // Typing / message input
            Container(
              padding:
                  const EdgeInsets.fromLTRB(
                8,
                8,
                8,
                10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.05,
                    ),
                    blurRadius: 8,
                    offset:
                        const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.attach_file,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      _showMessage(
                        "Attachment options",
                      );
                    },
                  ),

                  Expanded(
                    child: TextField(
                      controller:
                          _controller,
                      focusNode: _focusNode,
                      textInputAction:
                          TextInputAction.send,
                      onSubmitted: (_) {
                        _sendMessage();
                      },
                      decoration:
                          InputDecoration(
                        hintText:
                            "Type a message...",
                        hintStyle:
                            const TextStyle(
                          color:
                              Colors.black45,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor:
                            const Color(
                          0xFFF1F4F1,
                        ),
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 18,
                          vertical: 13,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(25),
                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  Material(
                    color: Colors.green,
                    shape:
                        const CircleBorder(),
                    child: InkWell(
                      customBorder:
                          const CircleBorder(),
                      onTap: _sendMessage,
                      child: const Padding(
                        padding:
                            EdgeInsets.all(12),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
