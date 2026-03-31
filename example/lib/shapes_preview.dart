import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:material_shapes/material_shapes.dart';

class ShapesPreview extends StatefulWidget {
  const ShapesPreview({super.key});

  @override
  State<ShapesPreview> createState() => _ShapesPreviewState();
}

class _ShapesPreviewState extends State<ShapesPreview>
    with SingleTickerProviderStateMixin {
  static final List<({RoundedPolygon shape, String title})> _shapes = [
    (shape: MaterialShapes.circle, title: 'Circle'),
    (shape: MaterialShapes.square, title: 'Square'),
    (shape: MaterialShapes.slanted, title: 'Slanted'),
    (shape: MaterialShapes.arch, title: 'Arch'),
    (shape: MaterialShapes.semiCircle, title: 'Semicircle'),
    (shape: MaterialShapes.oval, title: 'Oval'),
    (shape: MaterialShapes.pill, title: 'Pill'),
    (shape: MaterialShapes.triangle, title: 'Triangle'),
    (shape: MaterialShapes.arrow, title: 'Arrow'),
    (shape: MaterialShapes.fan, title: 'Fan'),
    (shape: MaterialShapes.diamond, title: 'Diamond'),
    (shape: MaterialShapes.clamShell, title: 'Clammshell'),
    (shape: MaterialShapes.pentagon, title: 'Pentagon'),
    (shape: MaterialShapes.gem, title: 'Gem'),
    (shape: MaterialShapes.hexagon, title: 'Hexagon'),
    (shape: MaterialShapes.heptagon, title: 'Heptagon'),
    (shape: MaterialShapes.octagon, title: 'Octagon'),
    (shape: MaterialShapes.verySunny, title: 'Very sunny'),
    (shape: MaterialShapes.sunny, title: 'Sunny'),
    (shape: MaterialShapes.star4Point, title: '4-point star'),
    (shape: MaterialShapes.star5Point, title: '5-point star'),
    (shape: MaterialShapes.star6Point, title: '6-point star'),
    (shape: MaterialShapes.cookie4Sided, title: '4-sided cookie'),
    (shape: MaterialShapes.cookie6Sided, title: '6-sided cookie'),
    (shape: MaterialShapes.cookie7Sided, title: '8-sided cookie'),
    (shape: MaterialShapes.cookie9Sided, title: '9-sided cookie'),
    (shape: MaterialShapes.cookie12Sided, title: '12-sided cookie'),
    (shape: MaterialShapes.clover4Leaf, title: '4-leaf clover'),
    (shape: MaterialShapes.clover8Leaf, title: '8-leaf clover'),
    (shape: MaterialShapes.burst, title: 'Burst'),
    (shape: MaterialShapes.softBurst, title: 'Soft burst'),
    (shape: MaterialShapes.boom, title: 'Boom'),
    (shape: MaterialShapes.softBoom, title: 'Soft boom'),
    (shape: MaterialShapes.puffyDiamond, title: 'Puffy diamond'),
    (shape: MaterialShapes.puffy, title: 'Puffy'),
    (shape: MaterialShapes.flower, title: 'Flower'),
    (shape: MaterialShapes.ghostish, title: 'Ghost-ish'),
    (shape: MaterialShapes.pixelCircle, title: 'Pixel circle'),
    (shape: MaterialShapes.pixelTriangle, title: 'Pixel triangle'),
    (shape: MaterialShapes.bun, title: 'Bun'),
    (shape: MaterialShapes.heart, title: 'Heart'),
    (shape: MaterialShapes.crescent, title: 'Crescent'),
    (shape: MaterialShapes.teardrop, title: 'Teardrop'),
    (shape: MaterialShapes.uCurve, title: 'U Curve'),
  ];

  late final ValueNotifier<int> _shapeIndex;

  late final ValueNotifier<int> _morphIndex;

  late final List<Morph> _morphs;

  late final AnimationController _controller;

  Timer? _timer;

  final _bouncySimulation = SpringSimulation(
    SpringDescription.withDampingRatio(
      ratio: 0.5,
      stiffness: 400,
      mass: 1,
    ),
    0,
    1,
    5,
    snapToEnd: true,
  );

  // This simulation used for Heart shape morphing, as progress greater than 1
  // produces sharp weird shape.
  final _lessBouncySimulation = SpringSimulation(
    SpringDescription.withDampingRatio(
      ratio: 0.8,
      stiffness: 300,
      mass: 1,
    ),
    0,
    1,
    0,
    snapToEnd: true,
  );

  @override
  void initState() {
    super.initState();

    _shapeIndex = ValueNotifier(0);
    _morphIndex = ValueNotifier(0);

    _morphs = <Morph>[];
    for (var i = 0; i < _shapes.length; i++) {
      _morphs.add(
        Morph(
          _shapes[i].shape,
          _shapes[(i + 1) % _shapes.length].shape,
        ),
      );
    }

    _controller = AnimationController.unbounded(vsync: this);

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) {
        return;
      }

      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _onAnimationDone(),
      );

      _controller
        ..value = 0
        ..animateWith(_bouncySimulation);

      _shapeIndex.value += 1;
    });
  }

  @override
  void dispose() {
    _shapeIndex.dispose();
    _morphIndex.dispose();
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _onAnimationDone() {
    if (!mounted) {
      return;
    }

    _morphIndex.value = (_morphIndex.value + 1) % _morphs.length;
    _shapeIndex.value = (_shapeIndex.value + 1) % _shapes.length;

    final isHeart = _shapeIndex.value == _shapes.length - 1;
    _controller
      ..value = 0
      ..animateWith(
        isHeart ? _lessBouncySimulation : _bouncySimulation,
      );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 300,
              maxHeight: 300,
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: _MorphPainter(
                  morphs: _morphs,
                  morphIndex: _morphIndex,
                  progress: _controller,
                ),
                willChange: true,
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 40),
          ValueListenableBuilder(
            valueListenable: _shapeIndex,
            builder: (context, index, child) {
              return _AnimatedTitle(title: _shapes[index].title);
            },
          ),
        ],
      ),
    );
  }
}

class _MorphPainter extends CustomPainter {
  _MorphPainter({
    required this.morphs,
    required this.morphIndex,
    required this.progress,
  }) : super(
         repaint: Listenable.merge([morphIndex, progress]),
       );

  final List<Morph> morphs;

  final ValueListenable<int> morphIndex;

  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final path = morphs[morphIndex.value].toPath(progress: progress.value);

    canvas
      ..save()
      ..scale(size.width)
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xFF201D23),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_MorphPainter oldDelegate) {
    return oldDelegate.morphs != morphs ||
        oldDelegate.morphIndex != morphIndex ||
        oldDelegate.progress != progress;
  }
}

class _AnimatedTitle extends StatefulWidget {
  const _AnimatedTitle({
    required this.title,
  });

  final String title;

  @override
  State<_AnimatedTitle> createState() => __AnimatedTitleState();
}

class __AnimatedTitleState extends State<_AnimatedTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _width;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: 1,
      duration: const Duration(milliseconds: 200),
    );
    _width = Tween<double>(
      begin: 600,
      end: 400,
    ).chain(CurveTween(curve: Curves.easeOut)).animate(_controller);
  }

  @override
  void didUpdateWidget(_AnimatedTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _width,
      builder: (context, _) {
        return Text(
          widget.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 40,
            letterSpacing: -2,
            fontVariations: [FontVariation.weight(_width.value)],
            color: const Color(0xFF201D23),
          ),
        );
      },
    );
  }
}
