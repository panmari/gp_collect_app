import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;

void main() => runApp(CovidData());

class CovidDataState extends State<CovidData> {
  Future<GPCollectData> futureData;
  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  // final _Font = const TextStyle(fontSize: 18.0);
  Widget _buildRow(RunnerData runner) {
    return ListTile(
      title: Text(
        runner.firstName + " " + runner.lastName,
        // style: _Font,
      ),
      trailing: Text(
        "more text",
        // style: _biggerFont,
      ),
    );
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Covid cases'),
        ),
        body: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter a search term',
              ),
              onChanged: (text) {
                print("First text field: ${text}");
              },
            ),
            FutureBuilder<GPCollectData>(
              future: futureData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                      child: (ListView.builder(
                        itemCount: snapshot.data.runners.length,
                        itemBuilder: (context, index) {
                          RunnerData runner = snapshot.data.runners[index];
                          return _buildRow(runner);
                        },
                      )));
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CovidData extends StatefulWidget {
  @override
  CovidDataState createState() => CovidDataState();
}

class RunnerData {
  final String firstName;
  final String lastName;
  RunnerData({this.firstName, this.lastName});
}

class GPCollectData {
  final List<RunnerData> runners;
  GPCollectData({this.runners});

  factory GPCollectData.fromJson(Map<String, dynamic> json) {
    List<RunnerData> runners = json['data'].map<RunnerData>((data) {
      return RunnerData(
        firstName: data["first_name"],
        lastName: data["last_name"],
      );
    }).toList();
    return GPCollectData(
      runners: runners,
    );
  }
}

Future<GPCollectData> fetchData() async {
  final term = '';
  final response = await http.get(
      "http://gpcollect.duckdns.org/de/runners.json?search%5Bvalue%5D=${term}");
  if (response.statusCode == 200) {
    return GPCollectData.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load covid stats');
  }
}
