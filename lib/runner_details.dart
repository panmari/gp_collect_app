import 'package:flutter/material.dart';

import 'runner_data.dart';

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
