import 'dart:async';

import 'package:flutter/material.dart';

class ClockWidget extends StatefulWidget {
  const ClockWidget({Key? key}) : super(key: key);

  @override
  _ClockWidgetState createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  DateTime dateTime = DateTime.now();

  late Timer timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 30), (tick) {
      dateTime = DateTime.now();
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        '${(dateTime.hour % 12).toString().padLeft(2, '0')} : ${(dateTime.minute).toString().padLeft(2, '0')} ${dateTime.hour > 12 ? 'PM' : 'AM'}',
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
