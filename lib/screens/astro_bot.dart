import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AstroBotPage extends StatefulWidget {
  @override
  _AstroBotPageState createState() => _AstroBotPageState();
}

class _AstroBotPageState extends State<AstroBotPage> {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();

  Future<void> sendRequest(String text) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST', Uri.parse('http://127.0.0.1:8080/api/Chat'));
    
    
    request.body = json.encode(text);
    request.headers.addAll(headers);
    
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final Map<String, dynamic> data = json.decode(responseData);
      final String content = data['choices'][0]['message']['content'];
      
      setState(() {
        messages.add({'text': content, 'isBot': true});
      });
    } else {
      setState(() {
        messages.add({'text': 'Bir hata oluştu: ${response.reasonPhrase}', 'isBot': true});
      });
    }
  }

  void _sendMessage() {
    final text = _controller.text;
    if (text.isNotEmpty) {
      setState(() {
        messages.add({'text': text, 'isBot': false}); 
      });
      sendRequest(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SpaceHub Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 58, 55, 88), Color.fromARGB(255, 93, 97, 148)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Container(
                    alignment: messages[index]['isBot'] ? Alignment.centerLeft : Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: messages[index]['isBot'] ? Color.fromARGB(255, 202, 202, 202) : Color.fromARGB(255, 241, 243, 242),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Text(messages[index]['text']),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 16), 
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Color.fromARGB(255, 58, 55, 88)),
                    ),
                    child: TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        hintText: 'Mesajınızı buraya yazın',
                        border: InputBorder.none,
                      ),
                      onEditingComplete: _sendMessage,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Color.fromARGB(255, 58, 55, 88)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
