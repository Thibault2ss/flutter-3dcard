import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

void main() {
  runApp(MyApp());
}

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
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(body: HomePage()),
    );
  }
}

class Card3D extends StatefulWidget {
  final double height;
  final double width;
  final double borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final Widget child;
  final bool dragAllowed;
  final bool autoMove;
  final Duration animDuration;

  Card3D(
      {Key key,
      this.child,
      this.dragAllowed = true,
      this.autoMove = true,
      this.width = 300.0,
      this.height = 300.0,
      this.borderRadius = 20.0,
      this.animDuration = const Duration(seconds: 5),
      Color backgroundColor,
      Color borderColor})
      : backgroundColor = backgroundColor ?? Color(0XFF180e43),
        borderColor = borderColor ?? Color(0xFF2fd6e8),
        super(key: key);

  @override
  _Card3DState createState() => _Card3DState();
}

class _Card3DState extends State<Card3D> with SingleTickerProviderStateMixin {
  Offset _angle = Offset(0, 0);

  AnimationController _animController;

  Matrix4 get _cardTransformation => Matrix4.identity()
    ..setEntry(3, 2, 0.0011) // perspective
    ..rotateX(_angle.dx)
    ..rotateY(_angle.dy);

  Offset get _shadowOffset => Offset(_angle.dy, -_angle.dx).scale(10, 10);

  double get _shinePosition => 0.3 - _angle.dy - _angle.dx * 2;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: widget.animDuration, value: 0);
    _animController.addListener(() {
      setState(() {
        final val = 2 * pi * _animController.value;
        _angle = Offset(cos(val), sin(pi / 3 + val)).scale(0.2, 0.6);
      });
    });
    _animController.repeat();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _angle += Offset(details.delta.dy / 100, -details.delta.dx / 100);
    });
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: widget.dragAllowed ? _onPanUpdate : null,
      child: Transform(
        alignment: Alignment.center,
        transform: _cardTransformation,
        // CARD
        child: Container(
          width: widget.width,
          height: widget.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: widget.borderColor,
                  blurRadius: 0,
                  spreadRadius: 0,
                  offset: _shadowOffset,
                ),
              ]),
          child: Stack(
            children: [
              // Content
              widget.child,

              // Shine
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment(-1.0, -1.0),
                    end: Alignment(1.0, 1.0),
                    stops: [
                      _shinePosition - 1,
                      _shinePosition,
                      _shinePosition + 1
                    ],
                    colors: [
                      Colors.white.withOpacity(0),
                      Colors.white30,
                      Colors.white.withOpacity(0),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
        child: Container(
            alignment: Alignment.center,
            color: Colors.white,
            child: Card3D(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox.expand(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "#Zenly",
                          style: TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.w900),
                        ),
                        Text(
                          "#Reverse Engineering",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w900),
                        ),
                        Image.asset(
                          'assets/logo.png',
                          width: 100,
                          height: 100,
                        ),
                      ]),
                ),
              ),
            )));
  }

  //   void _share(BuildContext context) async {
  //   String tempDirPath = (await getTemporaryDirectory()).path;
  //   String imagePath = '$tempDirPath/screenshot.png';

  //   final image = await _screenshotController.capture(
  //       path: imagePath, pixelRatio: MediaQuery.of(context).devicePixelRatio);
  //   final bytes = image.readAsBytesSync();

  //   await Share.file(
  //       'Profile Screenshot', 'screenshot.png', bytes, 'image/png');
  // }
}
