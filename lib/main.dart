import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController textEditingController = TextEditingController();
  Map<dynamic, dynamic>? data;
  Uint8List? image;
  final MethodChannel channel = const MethodChannel('com.karthikayanApps/methods');
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Generate images with text',
      home: SafeArea(
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                controller: textEditingController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Padding inside the TextField
                  hintText: "Enter text",
                  border: OutlineInputBorder( // Default border
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder( // Border when not focused
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder( // Border when focused
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                            ),
              ),

              isLoading? Center(child: CircularProgressIndicator(),) : ElevatedButton(
                  onPressed: () async {

                    isLoading = true;
                    setState(() {});
                    data = await channel.invokeMethod('getImages', {"name": textEditingController.text});
                    while (true) {
                      if (data?.keys.first) {
                        break;
                      }
                      data = await channel.invokeMethod('getImages', {"name": textEditingController.text});
                    }
                    isLoading = false;
                    setState(() {});

                  },
                  child: Text("Search")),
              if(data != null)
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Wrap(
                      children: [
                        for(int i = 0; i< data!.values.first.length; i++)
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Image.memory(
                              data!.values.first[i],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ]
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
