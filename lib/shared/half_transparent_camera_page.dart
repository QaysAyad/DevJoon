import 'package:cached_network_image/cached_network_image.dart';
import 'package:camerawesome/camerapreview.dart';
import 'package:camerawesome/sensors.dart';
import 'package:devjoon/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HalfTransparentCameraPage extends StatefulWidget {
  const HalfTransparentCameraPage({Key key, this.step}) : super(key: key);
  final ProductStep step;

  @override
  _HalfTransparentCameraPageState createState() =>
      _HalfTransparentCameraPageState();
}

class _HalfTransparentCameraPageState extends State<HalfTransparentCameraPage> {
  double _value;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _value = 0.5;
  }

  @override
  Widget build(BuildContext context) {
    final sensor = ValueNotifier<Sensors>(Sensors.BACK);
    return Scaffold(
      appBar: AppBar(
        title: Text('DevJoon'),
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            LayoutBuilder(builder: (context, constraints) {
              final size = ValueNotifier(constraints.biggest);
              return CameraAwesome(
                photoSize: size,
                sensor: sensor,
              );
            }),
            Positioned.fill(
              child: Opacity(
                opacity: _value,
                child: InteractiveViewer(
                  minScale: 0.001,
                  maxScale: 10,
                  constrained: false,
                  child: CachedNetworkImage(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      imageUrl: widget.step.imageUrl,
                      fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Slider(
                value: _value,
                onChanged: (value) => setState(() {
                  _value = value;
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
