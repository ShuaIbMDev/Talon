import 'dart:async';

import 'package:flutter/material.dart';

import '../services/call_service.dart';

class ChatScreen extends StatefulWidget {
  final String contactName;

  const ChatScreen({
    super.key,
    required this.contactName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hey! Are you available today?',
      'isMe': false,
      'time': '09:25 AM',
    },
    {
      'text': "Hi! Yes, I'm available.",
      'isMe': true,
      'time': '09:26 AM',
    },
    {
      'text': 'Great! I wanted to discuss the documents.',
      'isMe': false,
      'time': '09:27 AM',
    },
    {
      'text': 'Sure, send them over.',
      'isMe': true,
      'time': '09:28 AM',
    },
    {
      'text': "I've just sent them. Please check.",
      'isMe': false,
      'time': '09:29 AM',
    },
    {
      'text': 'Got them, thank you!',
      'isMe': true,
      'time': '09:30 AM',
    },
  ];

  final TextEditingController _controller = TextEditingController();

  final CallService _callService = CallService();

  bool _callActive = false;
  bool _callMinimized = false;
  bool _isMuted = false;
  bool _speakerOn = false;
  bool _isInitializingCall = false;

  int _callSeconds = 0;

  Timer? _callTimer;

  String get _callTime {
    final minutes = (_callSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_callSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  // ---------------------------------------------------------------------------
  // SEND MESSAGE
  // ---------------------------------------------------------------------------

  void _sendMessage() {
    final message = _controller.text.trim();

    if (message.isEmpty) return;

    setState(() {
      _messages.add({
        'text': message,
        'isMe': true,
        'time': TimeOfDay.now().format(context),
      });
    });

    _controller.clear();
  }

  // ---------------------------------------------------------------------------
  // MESSAGE
  // ---------------------------------------------------------------------------

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // START CALL
  // ---------------------------------------------------------------------------

  Future<void> _startCall() async {
    if (_callActive || _isInitializingCall) {
      return;
    }

    setState(() {
      _isInitializingCall = true;
    });

    try {
      await _callService.initialize();

      if (!mounted) {
        return;
      }

      setState(() {
        _callActive = true;
        _callMinimized = false;
        _callSeconds = 0;
        _isMuted = false;
        _speakerOn = false;
      });

      _startCallTimer();

      _openCallScreen();
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage('Could not start microphone: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializingCall = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // CALL TIMER
  // ---------------------------------------------------------------------------

  void _startCallTimer() {
    _callTimer?.cancel();

    _callTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted || !_callActive) {
          return;
        }

        setState(() {
          _callSeconds++;
        });
      },
    );
  }

  // ---------------------------------------------------------------------------
  // OPEN CALL SCREEN
  // ---------------------------------------------------------------------------

  void _openCallScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return _CallScreen(
            contactName: widget.contactName,
            callTime: _callTime,
            isMuted: _isMuted,
            speakerOn: _speakerOn,
            onMuteChanged: _toggleMute,
            onSpeakerChanged: _toggleSpeaker,
            onKeypad: _showKeypad,
            onMore: _showCallMoreOptions,
            onMinimize: () {
              if (!mounted) return;

              setState(() {
                _callMinimized = true;
              });

              Navigator.pop(context);
            },
            onEndCall: () {
              _endCall();
              Navigator.pop(context);
            },
          );
        },
      ),
    ).then((_) {
      if (!mounted) return;

      if (_callActive && !_callMinimized) {
        setState(() {
          _callMinimized = true;
        });
      }
    });
  }

  // ---------------------------------------------------------------------------
  // MUTE
  // ---------------------------------------------------------------------------

  Future<void> _toggleMute(bool value) async {
    if (!_callActive) return;

    try {
      if (_callService.hasMicrophone) {
        await _callService.toggleMute();
      }

      if (!mounted) return;

      setState(() {
        _isMuted = _callService.isMuted;
      });
    } catch (e) {
      _showMessage('Unable to change microphone state.');
    }
  }

  // ---------------------------------------------------------------------------
  // SPEAKER
  // ---------------------------------------------------------------------------

  Future<void> _toggleSpeaker(bool value) async {
    if (!_callActive) return;

    try {
      await _callService.toggleSpeaker();

      if (!mounted) return;

      setState(() {
        _speakerOn = _callService.isSpeakerOn;
      });
    } catch (e) {
      _showMessage('Unable to change speaker.');
    }
  }

  // ---------------------------------------------------------------------------
  // RESTORE CALL
  // ---------------------------------------------------------------------------

  void _restoreCall() {
    if (!_callActive) return;

    setState(() {
      _callMinimized = false;
    });

    _openCallScreen();
  }

  // ---------------------------------------------------------------------------
  // END CALL
  // ---------------------------------------------------------------------------

  Future<void> _endCall() async {
    _callTimer?.cancel();
    _callTimer = null;

    await _callService.dispose();

    if (!mounted) return;

    setState(() {
      _callActive = false;
      _callMinimized = false;
      _callSeconds = 0;
      _isMuted = false;
      _speakerOn = false;
    });

    _showMessage('Call ended');
  }

  // ---------------------------------------------------------------------------
  // KEYPAD
  // ---------------------------------------------------------------------------

  void _showKeypad() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (context) {
        String enteredNumber = '';

        const keys = [
          '1',
          '2',
          '3',
          '4',
          '5',
          '6',
          '7',
          '8',
          '9',
          '*',
          '0',
          '#',
        ];

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  18,
                  24,
                  24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Keypad',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 45,
                      child: Center(
                        child: Text(
                          enteredNumber.isEmpty
                              ? 'Enter digits'
                              : enteredNumber,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: enteredNumber.isEmpty
                                ? Colors.black38
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: keys.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 18,
                        childAspectRatio: 1.25,
                      ),
                      itemBuilder: (context, index) {
                        final key = keys[index];

                        return Material(
                          color: Colors.green.shade50,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              setSheetState(() {
                                enteredNumber += key;
                              });
                            },
                            child: Center(
                              child: Text(
                                key,
                                style: const TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        IconButton(
                          tooltip: 'Delete digit',
                          onPressed:
                              enteredNumber.isEmpty
                                  ? null
                                  : () {
                                      setSheetState(() {
                                        enteredNumber =
                                            enteredNumber
                                                .substring(
                                          0,
                                          enteredNumber
                                                  .length -
                                              1,
                                        );
                                      });
                                    },
                          icon: Icon(
                            Icons.backspace_outlined,
                          ),
                        ),

                        const SizedBox(width: 20),

                        Container(
                          decoration:
                              const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            tooltip: 'Close keypad',
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.keyboard_hide_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // CALL MORE OPTIONS
  // ---------------------------------------------------------------------------

  void _showCallMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),

              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 10),

              ListTile(
                leading: const Icon(
                  Icons.person_add_outlined,
                ),
                title: const Text(
                  'Add participant',
                ),
                onTap: () {
                  Navigator.pop(context);

                  _showMessage(
                    'Add participant will be added next.',
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.bluetooth_outlined,
                ),
                title: const Text(
                  'Audio device',
                ),
                onTap: () {
                  Navigator.pop(context);

                  _showMessage(
                    'Audio device selection will be added next.',
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.info_outline,
                ),
                title: const Text(
                  'Call information',
                ),
                onTap: () {
                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                          'Call information',
                        ),
                        content: Text(
                          'Contact: ${widget.contactName}\n'
                          'Duration: $_callTime\n'
                          'Microphone: '
                          '${_isMuted ? 'Muted' : 'Active'}\n'
                          'Speaker: '
                          '${_speakerOn ? 'On' : 'Off'}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Close',
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // ATTACHMENTS
  // ---------------------------------------------------------------------------

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Send attachment',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: _attachmentButton(
                        icon: Icons.photo_outlined,
                        label: 'Photo',
                        onTap: () {
                          Navigator.pop(context);

                          _showMessage(
                            'Photo picker opened',
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _attachmentButton(
                        icon:
                            Icons.description_outlined,
                        label: 'Document',
                        onTap: () {
                          Navigator.pop(context);

                          _showMessage(
                            'Document picker opened',
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _attachmentButton(
                        icon:
                            Icons.camera_alt_outlined,
                        label: 'Camera',
                        onTap: () {
                          Navigator.pop(context);

                          _showMessage(
                            'Camera opened',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _attachmentButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: Colors.green.shade100,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.green,
              size: 30,
            ),

            const SizedBox(height: 8),

            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CHAT OPTIONS
  // ---------------------------------------------------------------------------

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),

              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 12),

              ListTile(
                leading: const Icon(
                  Icons.notifications_off_outlined,
                ),
                title: Text(
                  'Mute notifications',
                ),
                onTap: () {
                  Navigator.pop(context);

                  _showMessage(
                    'Notifications muted',
                  );
                },
              ),

              ListTile(
                leading:
                    const Icon(Icons.search),
                title: Text(
                  'Search in conversation',
                ),
                onTap: () {
                  Navigator.pop(context);

                  _showMessage(
                    'Search opened',
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                title: Text(
                  'Delete conversation',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);

                  _showMessage(
                    'Delete conversation selected',
                  );
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // MESSAGE BUBBLE
  // ---------------------------------------------------------------------------

  Widget _buildMessageBubble(
    String text,
    bool isMe,
    String time,
  ) {
    return Align(
      alignment: isMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
                  0.75,
        ),
        margin:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 5,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.green : Theme.of(context).colorScheme.surface,
          borderRadius:
              BorderRadius.only(
            topLeft:
                const Radius.circular(18),
            topRight:
                const Radius.circular(18),
            bottomLeft:
                Radius.circular(
              isMe ? 18 : 4,
            ),
            bottomRight:
                Radius.circular(
              isMe ? 4 : 18,
            ),
          ),
          border:
              isMe
                  ? null
                  : Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withValues(
                alpha: 0.03,
              ),
              blurRadius: 5,
              offset:
                  const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color:
                    isMe ? Colors.white : Theme.of(context).colorScheme.onSurface,
                fontSize: 15,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              time,
              style: TextStyle(
                color:
                    isMe ? Colors.white70 : Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _callTimer?.cancel();
    _controller.dispose();

    if (_callActive) {
      _callService.dispose();
    }

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // MAIN CHAT SCREEN
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.onSurface,
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
                    widget.contactName.isNotEmpty
                        ? widget.contactName[0]
                            .toUpperCase()
                        : '?',
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
                      border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contactName,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  'Online',
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
          _isInitializingCall
              ? const Padding(
                  padding:
                      EdgeInsets.symmetric(
                    horizontal: 14,
                  ),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    Icons.phone_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  tooltip: 'Call',
                  onPressed: _startCall,
                ),

          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: 'More options',
            onPressed:
                _showChatOptions,
          ),
        ],
      ),

      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child:
                      ListView.builder(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 16,
                    ),
                    itemCount:
                        _messages.length,
                    itemBuilder:
                        (context, index) {
                      final msg =
                          _messages[index];

                      return _buildMessageBubble(
                        msg['text'] as String,
                        msg['isMe'] as bool,
                        msg['time'] as String,
                      );
                    },
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.fromLTRB(
                    8,
                    8,
                    8,
                    10,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(
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
                        icon:
                            const Icon(
                          Icons.attach_file,
                          color:
                              Colors.green,
                        ),
                        onPressed:
                            _showAttachmentOptions,
                      ),

                      Expanded(
                        child: TextField(
                          controller:
                              _controller,
                          textInputAction:
                              TextInputAction
                                  .send,
                          onSubmitted:
                              (_) {
                            _sendMessage();
                          },
                          decoration:
                              InputDecoration(
                            hintText:
                                'Type a message...',
                            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.65), fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                                      .circular(
                                25,
                              ),
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
                          child:
                              const Padding(
                            padding:
                                EdgeInsets.all(
                              12,
                            ),
                            child: Icon(
                              Icons
                                  .send_rounded,
                              color:
                                  Colors.white,
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

            // -----------------------------------------------------------------
            // MINIMIZED CALL BAR
            // -----------------------------------------------------------------

            if (_callActive &&
                _callMinimized)
              Positioned(
                left: 12,
                right: 12,
                bottom: 82,
                child:
                    GestureDetector(
                  onTap:
                      _restoreCall,
                  child:
                      Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,
                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),
                      border:
                          Border.all(
                        color:
                            Colors.green
                                .shade100,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black
                                  .withValues(
                            alpha: 0.12,
                          ),
                          blurRadius: 14,
                          offset:
                              const Offset(
                            0,
                            5,
                          ),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration:
                              BoxDecoration(
                            color:
                                Colors.green
                                    .shade50,
                            shape:
                                BoxShape
                                    .circle,
                          ),
                          child:
                              const Icon(
                            Icons.phone,
                            color:
                                Colors.green,
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child:
                              Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                widget
                                    .contactName,
                                style:
                                    const TextStyle(
                                  fontSize:
                                      14,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),

                              const SizedBox(
                                height: 2,
                              ),

                              Text(
                                'Call in progress • $_callTime',
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.green,
                                  fontSize:
                                      11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          tooltip:
                              'Open call',
                          icon:
                              const Icon(
                            Icons
                                .open_in_full,
                            color:
                                Colors.green,
                          ),
                          onPressed:
                              _restoreCall,
                        ),

                        Container(
                          decoration:
                              const BoxDecoration(
                            color:
                                Colors.red,
                            shape:
                                BoxShape
                                    .circle,
                          ),
                          child:
                              IconButton(
                            tooltip:
                                'End call',
                            icon:
                                const Icon(
                              Icons
                                  .call_end,
                              color:
                                  Colors.white,
                              size: 19,
                            ),
                            onPressed:
                                _endCall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CALL SCREEN
// ============================================================================

class _CallScreen extends StatelessWidget {
  final String contactName;
  final String callTime;

  final bool isMuted;
  final bool speakerOn;

  final ValueChanged<bool>
      onMuteChanged;

  final ValueChanged<bool>
      onSpeakerChanged;

  final VoidCallback onKeypad;
  final VoidCallback onMore;
  final VoidCallback onMinimize;
  final VoidCallback onEndCall;

  const _CallScreen({
    required this.contactName,
    required this.callTime,
    required this.isMuted,
    required this.speakerOn,
    required this.onMuteChanged,
    required this.onSpeakerChanged,
    required this.onKeypad,
    required this.onMore,
    required this.onMinimize,
    required this.onEndCall,
  });

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0B1710),

      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR

            Padding(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip:
                        'Minimize call',
                    onPressed:
                        onMinimize,
                    icon:
                        const Icon(
                      Icons
                          .keyboard_arrow_down_rounded,
                      color:
                          Colors.white,
                      size: 30,
                    ),
                  ),

                  const Spacer(),

                  const Text(
                    'Talon Call',
                    style:
                        TextStyle(
                      color:
                          Colors.white,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  const SizedBox(
                    width: 48,
                  ),
                ],
              ),
            ),

            // CONTACT

            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.green
                              .shade700,
                      shape:
                          BoxShape
                              .circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors
                              .green
                              .withValues(
                            alpha: 0.25,
                          ),
                          blurRadius: 35,
                          spreadRadius:
                              10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        contactName
                                .isNotEmpty
                            ? contactName[0]
                                .toUpperCase()
                            : '?',
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize: 48,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  Text(
                    contactName,
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 27,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Text(
                    'Connected',
                    style:
                        TextStyle(
                      color:
                          Colors.greenAccent,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    callTime,
                    style:
                        const TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // CONTROLS

            Padding(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                28,
                10,
                28,
                35,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceEvenly,
                    children: [
                      _CallControl(
                        icon:
                            isMuted
                                ? Icons
                                    .mic_off_rounded
                                : Icons
                                    .mic_none_rounded,
                        label:
                            isMuted
                                ? 'Unmute'
                                : 'Mute',
                        active:
                            isMuted,
                        onTap: () {
                          onMuteChanged(
                            !isMuted,
                          );
                        },
                      ),

                      _CallControl(
                        icon:
                            speakerOn
                                ? Icons
                                    .volume_up_rounded
                                : Icons
                                    .volume_down_rounded,
                        label:
                            'Speaker',
                        active:
                            speakerOn,
                        onTap: () {
                          onSpeakerChanged(
                            !speakerOn,
                          );
                        },
                      ),

                      _CallControl(
                        icon:
                            Icons
                                .dialpad_rounded,
                        label:
                            'Keypad',
                        onTap:
                            onKeypad,
                      ),

                      _CallControl(
                        icon:
                            Icons
                                .more_horiz_rounded,
                        label:
                            'More',
                        onTap:
                            onMore,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  GestureDetector(
                    onTap:
                        onEndCall,
                    child:
                        Container(
                      width: 68,
                      height: 68,
                      decoration:
                          const BoxDecoration(
                        color:
                            Colors.red,
                        shape:
                            BoxShape
                                .circle,
                      ),
                      child:
                          const Icon(
                        Icons
                            .call_end_rounded,
                        color:
                            Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  const Text(
                    'End call',
                    style:
                        TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 12,
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

// ============================================================================
// CALL CONTROL
// ============================================================================

class _CallControl
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _CallControl({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(
      BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap:
              onTap,
          child:
              Container(
            width: 55,
            height: 55,
            decoration:
                BoxDecoration(
              color:
                  active
                      ? Colors.white
                          .withValues(
                        alpha: 0.25,
                      )
                      : Colors.white
                          .withValues(
                        alpha: 0.12,
                      ),
              shape:
                  BoxShape.circle,
            ),
            child:
                Icon(
              icon,
              color:
                  Colors.white,
              size: 24,
            ),
          ),
        ),

        const SizedBox(
          height: 7,
        ),

        Text(
          label,
          style:
              const TextStyle(
            color:
                Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}






