import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;

void main() => runApp(GPCollectData());

class GPCollectDataState extends State<GPCollectData> {
  Future<GPCollectSearchResult> _results;
  @override
  void initState() {
    super.initState();
    _results = fetchData('');
  }

  // final _Font = const TextStyle(fontSize: 18.0);
  Widget _buildRow(RunnerData runner) {
    return ListTile(
      title: Text(
        runner.firstName + " " + runner.lastName,
      ),
      trailing: Text(
        runner.fastestRunDuration, 
      ),
    );
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GP Bern runners',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('GP Bern runners'),
        ),
        body: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter a search term',
              ),
              onChanged: (text) {
                setState(() {
                  _results = fetchData(text);
                });
              },
            ),
            FutureBuilder<GPCollectSearchResult>(
              future: _results,
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

class GPCollectData extends StatefulWidget {
  @override
  GPCollectDataState createState() => GPCollectDataState();
}

class RunnerData {
  final String firstName;
  final String lastName;
  final String fastestRunDuration;
  RunnerData({this.firstName, this.lastName, this.fastestRunDuration});
}

class GPCollectSearchResult {
  final List<RunnerData> runners;
  GPCollectSearchResult({this.runners});

  factory GPCollectSearchResult.fromJson(Map<String, dynamic> json) {
    List<RunnerData> runners = json['data'].map<RunnerData>((data) {
      return RunnerData(
        firstName: data["first_name"],
        lastName: data["last_name"],
        fastestRunDuration: data["fastest_run_duration"],
      );
    }).toList();
    return GPCollectSearchResult(
      runners: runners,
    );
  }
}

Future<GPCollectSearchResult> fetchData(searchTerm) async {
  final response = await http.get(
    "http://gpcollect.duckdns.org/de/runners.json?draw=1&columns%5B0%5D%5Bdata%5D=first_name&columns%5B0%5D%5Bname%5D=&columns%5B0%5D%5Bsearchable%5D=true&columns%5B0%5D%5Borderable%5D=true&columns%5B0%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B0%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B1%5D%5Bdata%5D=last_name&columns%5B1%5D%5Bname%5D=&columns%5B1%5D%5Bsearchable%5D=true&columns%5B1%5D%5Borderable%5D=true&columns%5B1%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B1%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B2%5D%5Bdata%5D=club_or_hometown&columns%5B2%5D%5Bname%5D=&columns%5B2%5D%5Bsearchable%5D=true&columns%5B2%5D%5Borderable%5D=true&columns%5B2%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B2%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B3%5D%5Bdata%5D=sex&columns%5B3%5D%5Bname%5D=&columns%5B3%5D%5Bsearchable%5D=false&columns%5B3%5D%5Borderable%5D=true&columns%5B3%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B3%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B4%5D%5Bdata%5D=nationality&columns%5B4%5D%5Bname%5D=&columns%5B4%5D%5Bsearchable%5D=false&columns%5B4%5D%5Borderable%5D=true&columns%5B4%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B4%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B5%5D%5Bdata%5D=runs_count&columns%5B5%5D%5Bname%5D=&columns%5B5%5D%5Bsearchable%5D=false&columns%5B5%5D%5Borderable%5D=true&columns%5B5%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B5%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B6%5D%5Bdata%5D=fastest_run_duration&columns%5B6%5D%5Bname%5D=&columns%5B6%5D%5Bsearchable%5D=false&columns%5B6%5D%5Borderable%5D=false&columns%5B6%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B6%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B7%5D%5Bdata%5D=runner_id&columns%5B7%5D%5Bname%5D=&columns%5B7%5D%5Bsearchable%5D=false&columns%5B7%5D%5Borderable%5D=false&columns%5B7%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B7%5D%5Bsearch%5D%5Bregex%5D=false&order%5B0%5D%5Bcolumn%5D=0&order%5B0%5D%5Bdir%5D=asc&start=0&length=10&search%5Bvalue%5D=$searchTerm");
  if (response.statusCode == 200) {
    return GPCollectSearchResult.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to search runners, response: ${response.body}');
  }
}
