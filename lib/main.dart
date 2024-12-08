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
  int selectedIndex = 0;
  final MethodChannel channel = const MethodChannel('com.karthikayanApps/methods');
  dynamic? val;

  Future<void> getImages() async {
    data = await channel.invokeMethod('getImages', {"name": textEditingController.text});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: textEditingController),
            image != null && image!.isNotEmpty ? Image.memory(image!, width: 100, height: 100) : Container(),
            ElevatedButton(
                onPressed: () async {
                  await getImages();
                  while (true) {
                    if (data?.keys.first) {
                      if(data?.values.first[0].length == 1 && data?.values.first[0][0] == 0){
                        print("error area");
                      }
                      else{
                        image = data!.values.first[selectedIndex];
                      }
                      break;
                    }
                    await getImages();
                  }
                  setState(() {});
                },
                child: Text("click")),
            ElevatedButton(
                onPressed: () {
                  if (selectedIndex == data!.values.first.length - 1) {
                    selectedIndex = 0;
                    image = data!.values.first[selectedIndex];
                  } else {
                    selectedIndex++;
                    image = data!.values.first[selectedIndex];
                  }
                  setState(() {});
                },
                child: Text("change")),
          ],
        ),
      ),
    );
  }
}
