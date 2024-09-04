import 'dart:async';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:rail_madad/homepage.dart';
import 'package:rail_madad/login_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:io';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  String? selectedOption;
  String? hoveredOption;
  Color _currentColor = Colors.orangeAccent;
  Timer? _timer;
  bool isAwaitingPNR = false;
  bool isAwaitingDescription = false;
  bool isAwaitingFile = false;
  bool isAwaitingComplaintId = false;
  int id = 1201001;
  String? pnrNumber;
  String? grievanceDescription;
  String? uploadedFilePath;

  late stt.SpeechToText _speech; // Add this variable
  bool _isListening = false; // Add this variable
  String _text = ''; // Add this variable

  File? _selectedFile;

  List<ChatMessage> messages = [];
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startColorSwitching();
    _speech = stt.SpeechToText(); // Initialize Speech-to-Text here
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          String fileName = basename(_selectedFile!.path);
          messages.insert(
            0,
            ChatMessage(
              messageContent: "File uploaded successfully: $fileName",
              isBot: true,
            ),
          );
          isAwaitingFile = false;
          finalizeGrievanceSubmission();
        });
      } else {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(content: Text("File selection canceled")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text("Error picking file: $e")),
      );
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => setState(() => _isListening = val == 'listening'),
        onError: (val) => setState(() => _isListening = false),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _inputController.text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _text = val.recognizedWords;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _startColorSwitching() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentColor = _currentColor == Colors.orangeAccent
            ? Color.fromARGB(255, 137, 2, 49)
            : Colors.orangeAccent;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/navbar_logo.png',
              height: 40,
            ),
          ],
        ),
        backgroundColor: Colors.white,
        leading: selectedOption != null
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    selectedOption = null;
                    messages.clear();
                  });
                },
              )
            : null,
      ),
      body:
          selectedOption == null ? buildOptionSelection() : buildChatMessages(),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Image.asset('assets/navbar_logo.png'),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            ListTile(
              title: Text('Register Complaint'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ChatbotScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Other Services'),
              onTap: () {
                // Handle item 2 tap
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOptionSelection() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                duration: Duration(seconds: 1),
                decoration: BoxDecoration(
                  color: _currentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.phone_in_talk_rounded,
                      color: Colors.black,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '139',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Text(
                'for Security/Medical Assistance',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 80),
          const Center(
            child: Text(
              'Welcome to Rail Madad 🙏',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          SizedBox(height: 40),
          const Center(
              child: Text('Please select the type of Grievance',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
          SizedBox(height: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildOptionBox('Railway Grievance'),
                  buildOptionBox('Station Grievance'),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildOptionBox('Track Grievance'),
                  buildOptionBox('General Enquiry'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildOptionBox(String option) {
    final Map<String, IconData> iconMap = {
      'Railway Grievance': Icons.train,
      'Station Grievance': Icons.location_city,
      'Track Grievance': Icons.track_changes,
      'General Enquiry': Icons.question_answer,
    };

    final icon = iconMap[option] ?? Icons.help;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          hoveredOption = option;
        });
      },
      onExit: (_) {
        setState(() {
          hoveredOption = null;
        });
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedOption = option;
            messages.insert(
              0,
              ChatMessage(
                messageContent:
                    "Welcome to Rail Madad: An automated complaint redressal system",
                isBot: true,
              ),
            );
            messages.insert(
                0,
                ChatMessage(
                    messageContent: "You selected $option.", isBot: true));
            generateInitialReply(option);
          });
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          padding: EdgeInsets.all(16),
          width: 150,
          height: 120,
          decoration: BoxDecoration(
            color: hoveredOption == option
                ? Color.fromARGB(255, 38, 86, 217)
                : Color.fromARGB(220, 51, 122, 183),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(height: 8),
                Text(
                  option,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildChatMessages() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return ChatBubble(message: message);
            },
          ),
        ),
        buildChatInputField(),
      ],
    );
  }

  // Widget buildChatInputField() {
  //   return Padding(
  //     padding: const EdgeInsets.all(10.0),
  //     child: Column(
  //       children: [
  //         Row(
  //           children: [
  //             Expanded(
  //               child: TextField(
  //                 autofocus: true,
  //                 controller: _inputController,
  //                 decoration: InputDecoration(
  //                   hintText: 'Type your response here...',
  //                   border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(4),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             IconButton(
  //               splashRadius: sqrt1_2,
  //               icon: const Icon(Icons.mic),
  //               onPressed: _listen, // Start listening for voice input
  //             ),
  //             IconButton(
  //                 icon: const Icon(Icons.upload_file_rounded),
  //                 onPressed: () {
  //                   ScaffoldMessenger.of(context as BuildContext).showSnackBar(
  //                     const SnackBar(
  //                       content: Text('File upload feature coming soon...'),
  //                     ),
  //                   );
  //                 }),
  //             IconButton(
  //               icon: const Icon(Icons.send),
  //               onPressed: handleUserInput,
  //             ),
  //           ],
  //         ),
  //         const SizedBox(
  //           height: 25,
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               SizedBox(height: 15),
  //               Icon(
  //                 Icons.copyright_outlined,
  //                 size: 14,
  //               ),
  //               SizedBox(width: 3),
  //               Text(
  //                 'Powered by Semantics',
  //                 style: TextStyle(fontSize: 14),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget buildChatInputField() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  autofocus: true,
                  controller: _inputController,
                  decoration: InputDecoration(
                    hintText: 'Type your response here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              IconButton(
                splashRadius: sqrt1_2,
                icon: const Icon(Icons.mic),
                onPressed: _listen, // Start listening for voice input
              ),
              IconButton(
                icon: const Icon(Icons.upload_file_rounded),
                onPressed: pickFile, // Call the method to pick a file
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: handleUserInput,
              ),
            ],
          ),
          const SizedBox(
            height: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 15),
                Icon(
                  Icons.copyright_outlined,
                  size: 14,
                ),
                SizedBox(width: 3),
                Text(
                  'Powered by Semantics',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void handleUserInput() async {
    final userInput = _inputController.text.trim();

    if (userInput.isNotEmpty || _selectedFile != null) {
      setState(() {
        // Handle the selected file first
        if (_selectedFile != null) {
          String fileName = basename(_selectedFile!.path);
          messages.insert(
            0,
            ChatMessage(
              messageContent: "File uploaded successfully: $fileName",
              isBot: true,
            ),
          );
          _selectedFile = null; // Reset the selected file after processing
          isAwaitingFile = false; // Reset the file awaiting state
          finalizeGrievanceSubmission(); // Finalize submission if appropriate
        }

        // Handle text input from user
        if (userInput.isNotEmpty) {
          messages.insert(
              0, ChatMessage(messageContent: userInput, isBot: false));
          _inputController.clear();

          if (isAwaitingPNR) {
            if (validatePNR(userInput)) {
              pnrNumber = userInput;
              messages.insert(
                0,
                ChatMessage(
                  messageContent: "PNR Number received: $pnrNumber",
                  isBot: true,
                ),
              );
              isAwaitingPNR = false;
              generateGrievanceDescriptionPrompt();
            } else {
              messages.insert(
                0,
                ChatMessage(
                  messageContent: "Invalid PNR. Please try again.",
                  isBot: true,
                ),
              );
            }
          } else if (isAwaitingDescription) {
            grievanceDescription = userInput;
            messages.insert(
              0,
              ChatMessage(
                messageContent: "Description received: $grievanceDescription",
                isBot: true,
              ),
            );
            isAwaitingDescription = false;
            generateFileUploadPrompt();
          } else if (isAwaitingComplaintId) {
            messages.insert(
              0,
              ChatMessage(
                messageContent: "Complaint ID received: $userInput",
                isBot: true,
              ),
            );
            isAwaitingComplaintId = false;
            // Handle further steps as needed
          } else {
            generateResponse(userInput);
          }
        }
      });
    } else {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(
          content: Text("Please type a message or select a file."),
        ),
      );
    }
  }

  // void handleUserInput() {
  //   final userInput = _inputController.text.trim();

  //   if (userInput.isNotEmpty) {
  //     setState(() {
  //       messages.insert(
  //           0, ChatMessage(messageContent: userInput, isBot: false));
  //       _inputController.clear();

  //       if (isAwaitingPNR) {
  //         if (validatePNR(userInput)) {
  //           pnrNumber = userInput;
  //           messages.insert(
  //               0,
  //               ChatMessage(
  //                   messageContent: "PNR Number received: $pnrNumber",
  //                   isBot: true));
  //           isAwaitingPNR = false;
  //           generateGrievanceDescriptionPrompt();
  //         } else {
  //           messages.insert(
  //               0,
  //               ChatMessage(
  //                   messageContent: "Invalid PNR. Please try again.",
  //                   isBot: true));
  //         }
  //       } else if (isAwaitingDescription) {
  //         bool is_valid = true;
  //         grievanceDescription = userInput;
  //         if (is_valid == true) {
  //           messages.insert(
  //               0,
  //               ChatMessage(
  //                   messageContent:
  //                       "Description received: $grievanceDescription",
  //                   isBot: true));
  //           isAwaitingDescription = false;
  //           generateFileUploadPrompt();
  //         }
  //       } else if (isAwaitingFile) {
  //         uploadedFilePath =
  //             userInput; // In a real app, this would handle file selection.
  //         messages.insert(
  //             0,
  //             ChatMessage(
  //                 messageContent:
  //                     "File uploaded successfully: $uploadedFilePath",
  //                 isBot: true));
  //         isAwaitingFile = false;
  //         finalizeGrievanceSubmission();
  //       } else {
  //         generateResponse(userInput);
  //       }
  //     });
  //   }
  // }

  void generateResponse(String userInput) {
    if (isRelevantInput(userInput)) {
      setState(() {
        messages.insert(
          0,
          ChatMessage(
            messageContent:
                "You said: $userInput. How can I assist you further?",
            isBot: true,
          ),
        );
      });
    } else {
      setState(() {
        messages.insert(
          0,
          ChatMessage(
            messageContent: "Sorry, I don't understand",
            isBot: true,
          ),
        );
      });
    }
  }

  bool isRelevantInput(String input) {
    // Define a list of keywords related to railway complaints
    final List<String> railwayKeywords = [
      'train',
      'station',
      'track',
      'delay',
      'ticket',
      'reservation',
      'cancellation',
      'refund',
      'pnr',
      'coach',
      'berth',
      'platform',
      'luggage',
      'compartment',
      'railway',
      'irctc',
      'schedule',
      'accident',
      'cleanliness',
      'food',
      'security',
      'medical',
      'enquiry',
      'track',
    ];

    // Check if the input contains any of the keywords
    for (String keyword in railwayKeywords) {
      if (input.toLowerCase().contains(keyword)) {
        return true;
      }
    }

    // If no relevant keywords are found, return false
    return false;
  }

  void generateInitialReply(String option) {
    if (option == 'Railway Grievance') {
      setState(() {
        messages.insert(
          0,
          ChatMessage(
            messageContent: "Please enter your PNR Number to proceed.",
            isBot: true,
          ),
        );
        isAwaitingPNR = true;
      });
    } else if (option == 'Station Grievance') {
      setState(() {
        messages.insert(
          0,
          ChatMessage(
            messageContent: "Please enter Station name",
            isBot: true,
          ),
        );
        isAwaitingDescription = true;
      });
    } else if (option == 'Track Grievance') {
      setState(() {
        messages.insert(
          0,
          ChatMessage(
            messageContent: "Please enter Complaint ID",
            isBot: true,
          ),
        );
        isAwaitingComplaintId = true;
      });
    } else if (option == 'General Enquiry') {
    } else {
      setState(() {
        messages.insert(
          0,
          ChatMessage(
            messageContent: "How can I assist you with your $option?",
            isBot: true,
          ),
        );
      });
    }
  }

  void generateGrievanceDescriptionPrompt() {
    setState(() {
      messages.insert(
        0,
        ChatMessage(
          messageContent: "Please describe your grievance in detail.",
          isBot: true,
        ),
      );
      isAwaitingDescription = true;
    });
  }

  void generateFileUploadPrompt() {
    setState(() {
      messages.insert(
        0,
        ChatMessage(
          messageContent: "If you have any files to upload, please do so now.",
          isBot: true,
        ),
      );
      isAwaitingFile = true;
    });
  }

  void finalizeGrievanceSubmission() {
    setState(() {
      messages.insert(
        0,
        ChatMessage(
          messageContent:
              "Thank you for providing the details. Your grievance has been submitted. Your complaint ID is ${id}",
          isBot: true,
        ),
      );
      id += 1;
    });
  }

  bool validatePNR(String pnr) {
    return pnr.length == 10 && RegExp(r'^\d+$').hasMatch(pnr);
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isBot ? Colors.grey[200] : Colors.blue[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          message.messageContent,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String messageContent;
  final bool isBot;

  ChatMessage({required this.messageContent, required this.isBot});
}
