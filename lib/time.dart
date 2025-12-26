// ignore_for_file: no_leading_underscores_for_local_identifiers, library_private_types_in_public_api, use_key_in_widget_constructors, file_names

import 'dart:async';
import 'package:billing/colors.dart';
import 'package:flutter/material.dart';

class LiveTimeWidget extends StatefulWidget {
  @override
  _LiveTimeWidgetState createState() => _LiveTimeWidgetState();
}

class _LiveTimeWidgetState extends State<LiveTimeWidget> {
  late Stream<DateTime> _timeStream;

  @override
  void initState() {
    super.initState();
    _timeStream = Stream<DateTime>.periodic(const Duration(seconds: 1), (i) => DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    // ColorPalette _colorPalette = ColorPalette();
    return StreamBuilder<DateTime>(
      stream: _timeStream,
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        final secondsText = now.second < 10 ? '0${now.second}' : '${now.second}';
        final hourText = now.hour < 10 ? '0${now.hour}' : '${now.hour}';
        final minuteText = now.minute < 10 ? '0${now.minute}' : '${now.minute}';
        return Column(
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: hourText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 28,
                    ),
                  ),
                  TextSpan(
                    text: ' : ',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: ColorPalette.blueAccent,
                    ),
                  ),
                  TextSpan(
                    text: minuteText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: ' : ',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: ColorPalette.blueAccent,
                    ),
                  ),
                  TextSpan(
                    text: secondsText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
