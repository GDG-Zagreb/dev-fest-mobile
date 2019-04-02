import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yaml/yaml.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'DevFest'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static var httpClient = new HttpClient();

  Future<dynamic> _downloadFile(String url, String filename) async {
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    var content = await readFile(file);
    var doc = loadYaml(content);
    return doc;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FutureBuilder(
          future: _downloadFile(
              "https://raw.githubusercontent.com/GDG-Zagreb/zeppelin/gh-pages/_data/sessions.yml",
              "sessions.yml"),
          builder: (context, response) {
            print(response.data);
            return ListView.builder(
                itemCount: response.data.length,
                itemBuilder: (context, index) {
                  var item = response.data[index];
                  String subtype = item["subtype"];
                  String complexity = item["complexity"];
                  var color;
                  switch (complexity) {
                    case "Beginner":
                      color = Colors.green[800];
                      break;
                    case "Intermediate":
                      color = Colors.yellow[800];
                      break;
                    default:
                      color = Colors.blue[800];
                      break;
                  }
                  return ListTile(
                      title: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(item["title"]),
                            )),
                          ]),
                      subtitle: Text(
                        item["description"] != null
                            ? item["description"]
                            : '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(Icons.hearing, color: color),
                      onTap: () {
                        print(item["title"]);
                      },
                  );
                });
          }),
    );
  }

  Future<String> readFile(File stored) async {
    String contents = await stored.readAsString();
    return contents;
  }
}
