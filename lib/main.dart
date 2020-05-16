import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;

void main() => runApp(GPCollectMain());

class GPCollectMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GP Bern runners',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: GPCollectDataWidget(),
      routes: {
        RunnerDetails.routeName: (context) => RunnerDetails(),
      },
    );
  }
}

class GPCollectDataWidget extends StatefulWidget {
  @override
  GPCollectDataState createState() => GPCollectDataState();
}

class GPCollectDataState extends State<GPCollectDataWidget> {
  Future<GPCollectSearchResult> _results;
  @override
  void initState() {
    super.initState();
    _results = _fetchData('');
  }

  Future<GPCollectSearchResult> _fetchData(searchTerm) async {
    // TODO(panmari): Support pagination.
    final response = await http
        .get(
            "http://gpcollect.duckdns.org/de/runners.json?draw=1&columns%5B0%5D%5Bdata%5D=first_name&columns%5B0%5D%5Bname%5D=&columns%5B0%5D%5Bsearchable%5D=true&columns%5B0%5D%5Borderable%5D=true&columns%5B0%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B0%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B1%5D%5Bdata%5D=last_name&columns%5B1%5D%5Bname%5D=&columns%5B1%5D%5Bsearchable%5D=true&columns%5B1%5D%5Borderable%5D=true&columns%5B1%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B1%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B2%5D%5Bdata%5D=club_or_hometown&columns%5B2%5D%5Bname%5D=&columns%5B2%5D%5Bsearchable%5D=true&columns%5B2%5D%5Borderable%5D=true&columns%5B2%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B2%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B3%5D%5Bdata%5D=sex&columns%5B3%5D%5Bname%5D=&columns%5B3%5D%5Bsearchable%5D=false&columns%5B3%5D%5Borderable%5D=true&columns%5B3%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B3%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B4%5D%5Bdata%5D=nationality&columns%5B4%5D%5Bname%5D=&columns%5B4%5D%5Bsearchable%5D=false&columns%5B4%5D%5Borderable%5D=true&columns%5B4%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B4%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B5%5D%5Bdata%5D=runs_count&columns%5B5%5D%5Bname%5D=&columns%5B5%5D%5Bsearchable%5D=false&columns%5B5%5D%5Borderable%5D=true&columns%5B5%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B5%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B6%5D%5Bdata%5D=fastest_run_duration&columns%5B6%5D%5Bname%5D=&columns%5B6%5D%5Bsearchable%5D=false&columns%5B6%5D%5Borderable%5D=false&columns%5B6%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B6%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B7%5D%5Bdata%5D=runner_id&columns%5B7%5D%5Bname%5D=&columns%5B7%5D%5Bsearchable%5D=false&columns%5B7%5D%5Borderable%5D=false&columns%5B7%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B7%5D%5Bsearch%5D%5Bregex%5D=false&order%5B0%5D%5Bcolumn%5D=0&order%5B0%5D%5Bdir%5D=asc&start=0&length=50&search%5Bvalue%5D=$searchTerm")
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return GPCollectSearchResult.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to search runners, response: ${response.body}');
    }
  }

  Widget _buildRow(RunnerData runner) {
    return ListTile(
      title: Text(
        runner.firstName + " " + runner.lastName,
      ),
      subtitle: Text(runner.clubOrHometown),
      trailing: Text(
        runner.fastestRunDuration,
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          RunnerDetails.routeName,
          arguments: runner,
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search for runners'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter a name or location',
            ),
            onChanged: (text) {
              setState(() {
                _results = _fetchData(text);
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
    );
  }
}

class RunnerData {
  final String firstName;
  final String lastName;
  final String clubOrHometown;
  final String fastestRunDuration;
  RunnerData(
      {this.firstName,
      this.lastName,
      this.clubOrHometown,
      this.fastestRunDuration});
}

class GPCollectSearchResult {
  final List<RunnerData> runners;
  final int recordsTotal;
  final int recordsFiltered;
  GPCollectSearchResult(
      {this.runners, this.recordsTotal, this.recordsFiltered});

  factory GPCollectSearchResult.fromJson(Map<String, dynamic> json) {
    List<RunnerData> runners = json['data'].map<RunnerData>((data) {
      return RunnerData(
        firstName: data["first_name"],
        lastName: data["last_name"],
        clubOrHometown: data["club_or_hometown"],
        fastestRunDuration: data["fastest_run_duration"],
      );
    }).toList();
    return GPCollectSearchResult(
      runners: runners,
      recordsTotal: json['recordsTotal'],
      recordsFiltered: json['recordsFiltered'],
    );
  }
}

class RunnerDetails extends StatelessWidget {
  static const routeName = '/runner';

  Widget build(BuildContext context) {
    final RunnerData args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 10, color: Colors.black38),
          borderRadius: const BorderRadius.all(const Radius.circular(8)),
        ),
        margin: const EdgeInsets.all(50),
        child: Center(
          child: Column(
            children: [
              Row(children: [Text(args.firstName + " " + args.lastName)]),
              Row(children: [Text(args.clubOrHometown)]),
              Row(children: [Text(args.fastestRunDuration)]),
            ],
          ),
        ),
      ),
    );
  }
}
