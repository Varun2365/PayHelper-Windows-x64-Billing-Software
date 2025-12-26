import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoadingScreen extends StatefulWidget {
  final double value;

  const LoadingScreen({super.key, required this.value});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
                gradient:
                    LinearGradient(transform: GradientRotation(5), colors: [
              Color(0xff00123F),
              Color.fromARGB(255, 0, 4, 7),
            ])),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/splash.svg',
                  width: 170,
                ),
                const SizedBox(
                  height: 0,
                ),
                const Text(
                  "PayHelper",
                  style: TextStyle(
                      fontFamily: "Poppins", color: Colors.white, fontSize: 16),
                ),
                const SizedBox(
                  height: 30,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: SizedBox(
                    width: 170,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: widget.value),
                      duration: const Duration(
                          milliseconds:
                              400), // Adjust the duration for smoothness
                      builder:
                          (BuildContext context, double value, Widget? child) {
                        return LinearProgressIndicator(
                          minHeight: 4,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          value: value,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
