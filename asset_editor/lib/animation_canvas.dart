import 'dart:math';
import 'package:flutter/material.dart';

class EditorCanvas extends StatefulWidget {
  EditorCanvas({Key? key}) : super(key: key);
  List<Frame> frame = [Frame()];
  Shape? selectedShape;
  bool isMultiSelectEnabled = false;
  List<Shape> multiSelectedShapes = [];
  Offset? multiSelectFocal;
  var currentFrame = 0;
  var setChildState;
  var frameClipboard;
  var onionFrames = 2;
  var grid_on = true;
  var copiedShapes = [];

  final List<List<Shape>> undoStack = [];
  final List<List<Shape>> redoStack = [];

  var colorPallette = [Colors.amber.shade100,
  Colors.amber.shade200,
  Colors.amber.shade300,Colors.amber.shade400,
  Colors.amber.shade500, Colors.amber.shade600, 
  Colors.amber.shade700, Colors.amber.shade800,
  Colors.white, Colors.black];

  bool isTranslating = true;
  bool isRotating = false;
  bool isScaling = false;

  // Offset delta;

  void toggleMultiSelect(bool enabled) {
    isMultiSelectEnabled = enabled;
    if (!enabled) multiSelectedShapes.clear();
    setChildState(() {});
  }

  void addShapeToMultiSelection(Shape shape) {
    if (!multiSelectedShapes.contains(shape)) {
      multiSelectedShapes.add(shape);
    }
    setChildState(() {});
  }

  Rect _getBoundingRect(List<Shape> shapes) {
    if (shapes.isEmpty) {
      return Rect.zero;
    }

    double left = double.infinity;
    double top = double.infinity;
    double right = double.negativeInfinity;
    double bottom = double.negativeInfinity;

    for (var shape in shapes) {
      left = min(left, shape.x);
      top = min(top, shape.y);
      right = max(right, shape.x + shape.width);
      bottom = max(bottom, shape.y + shape.height);
    }
    setChildState(() {});

    return Rect.fromLTRB(left, top, right, bottom);
  }

  void addFrame(){
    frame.add(Frame());
    currentFrame = frame.length-1;
    setChildState((){});
  }

  void addFrameCurrentWithDup({dup = false}){
    if(!dup){
      frame.insert(currentFrame,Frame());
      currentFrame++;
    }else{
      var p1 = Frame();
      for(var a in frame[currentFrame].shapes){
        p1.shapes.add(a.copyWith());
      }
      frame.insert(currentFrame, p1);
      currentFrame++;
    }
    setChildState((){});
  }

  void addFrameCurrent({left=false}){
    if(!left){
      frame.insert(currentFrame+1,Frame());
      currentFrame++;
    }else{
      frame.insert(currentFrame,Frame());
    }
    setChildState((){});
  }

  void copyFrame(){
    frameClipboard = Frame();
    for(var a in frame[currentFrame].shapes){
      frameClipboard.shapes.add(a.copyWith());
    }
  }

  void pasteFrame(){
    var p = Frame();
    for(var a in frameClipboard.shapes){
      p.shapes.add(a.copyWith());
    }
    frame[currentFrame].shapes.addAll(p.shapes);
    setChildState((){});
  }

  void removeFrame(){
    if(frame.length == 1) return;
    frame.removeAt(currentFrame);
    if(currentFrame == 0){
      setChildState((){});
      return;
    }
    currentFrame--;
    setChildState((){});
  }

  void setCurrentFrame(p){
    currentFrame = p;
    setChildState((){});
  }

  void setColorPallette(p){
    colorPallette = p;
    setChildState((){});
  }

  void addShape(String shape) {
    saveState();
    if (shape == "rect") {
      frame[currentFrame].addShape(RectangleShape(
        x: 100,
        y: 100,
        width: 100,
        height: 100,
        fillColor: Colors.red,
        strokeColor: Colors.transparent,
      ));
    } else {
      frame[currentFrame].addShape(CircleShape(
        x: 100,
        y: 200,
        width: 80,
        height: 80,
        fillColor: Colors.blue,
        strokeColor: Colors.transparent,
      ));
    }
    setChildState(() {});
  }

  void removeShape() {
    if (selectedShape != null) {
      saveState();
      frame[currentFrame].removeShape(selectedShape!);
      selectedShape = null;
    }
    setChildState(() {});
  }

  void setButtonState(int state) {
    isTranslating = state == 0;
    isRotating = state == 1;
    isScaling = state == 2;
    setChildState(() {});
  }

  void saveState() {
    // Create a deep copy of the shapes and their transformations
    undoStack.add(List.from(frame[currentFrame].shapes.map((shape) => shape.copyWith())));
    redoStack.clear(); // Clear redo stack on new action
  }

  void undo() {
    if (undoStack.isNotEmpty) {
      // Save the current state before undoing
      redoStack.add(List.from(frame[currentFrame].shapes.map((shape) => shape.copyWith())));
      
      // Revert to the previous state
      frame[currentFrame].shapes.clear();
      frame[currentFrame].shapes.addAll(undoStack.removeLast());
    }
  }

  void redo() {
    if (redoStack.isNotEmpty) {
      // Save the current state before redoing
      undoStack.add(List.from(frame[currentFrame].shapes.map((shape) => shape.copyWith())));
      
      // Restore the redone state
      frame[currentFrame].shapes.clear();
      frame[currentFrame].shapes.addAll(redoStack.removeLast());
    }
    setChildState(() {});
  }

  void moveShapeLayerUp() {
    if (selectedShape != null) {
      final index = frame[currentFrame].shapes.indexOf(selectedShape!);
      if (index < frame[currentFrame].shapes.length - 1) {
        saveState();
        final shape = frame[currentFrame].shapes.removeAt(index);
        frame[currentFrame].shapes.insert(index + 1, shape);
      }
    }
    setChildState(() {});
  }

  void setFillColor(p){
    selectedShape?.fillColor = p;
    setChildState((){});
  }

  void setStrokeColor(p){
    selectedShape?.strokeColor = p;
    setChildState((){});
  }

  void moveShapeLayerDown() {
    if (selectedShape != null) {
      final index = frame[currentFrame].shapes.indexOf(selectedShape!);
      if (index > 0) {
        saveState();
        final shape = frame[currentFrame].shapes.removeAt(index);
        frame[currentFrame].shapes.insert(index - 1, shape);
      }
    }
    setChildState(() {});
  }



  @override
  _EditorCanvasState createState() => _EditorCanvasState();
}

class _EditorCanvasState extends State<EditorCanvas> {
  Offset? lastPointerPosition;

  @override
  void initState() {
    super.initState();
    widget.setChildState = setState;
  }

  @override
  Widget build(BuildContext context) {
    final previousFrames = <Frame>[];
    for (int i = 1; i <= widget.onionFrames; i++) {
      final index = widget.currentFrame - i;
      if (index >= 0) {
        previousFrames.add(widget.frame[index]);
      } else {
        break;
      }
    }

    final nextFrames = <Frame>[];
    for (int i = 1; i <= widget.onionFrames; i++) {
      final index = widget.currentFrame + i;
      if (index < widget.frame.length) {
        nextFrames.add(widget.frame[index]);
      } else {
        break;
      }
    }
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: (details){
        widget.saveState();
      },
      child: CustomPaint(
        painter: FramePainter(
          widget.frame[widget.currentFrame],
          widget.selectedShape,
          widget.multiSelectedShapes,
          previousFrames, // Pass previous frames here
          nextFrames
        )..grid = widget.grid_on,
        size: Size.infinite,
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final touchPoint = details.localPosition;
    lastPointerPosition = touchPoint;
    // print(widget.isMultiSelectEnabled);
    if (widget.isMultiSelectEnabled) {
      // print("kk");
      for (var shape in widget.frame[widget.currentFrame].shapes) {
        if (shape.contains(touchPoint)) {
          setState(() {
            widget.addShapeToMultiSelection(shape);
          });
          return;
        }
      }
    } else {
      for (var shape in widget.frame[widget.currentFrame].shapes) {
        if (shape.contains(touchPoint)) {
          setState(() {
            widget.selectedShape = shape;
            lastPointerPosition = touchPoint;
          });
          return;
        }
      }
      setState(() {
        // widget.selectedShape = null;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final delta = details.localPosition - (lastPointerPosition ?? details.localPosition);
    lastPointerPosition = details.localPosition;

    setState(() {
      if (widget.isMultiSelectEnabled) {
        final bounds = Rect.fromLTRB(
          widget.multiSelectedShapes.map((s) => s.x).fold<double>(double.infinity, (currentMin, x) => x < currentMin ? x : currentMin),
          widget.multiSelectedShapes.map((s) => s.y).fold<double>(double.infinity, (currentMin, x) => x < currentMin ? x : currentMin),
          widget.multiSelectedShapes.map((s) => s.x + s.width).fold<double>(double.infinity, (currentMin, x) => x < currentMin ? x : currentMin),
          widget.multiSelectedShapes.map((s) => s.y + s.height).fold<double>(double.infinity, (currentMin, x) => x < currentMin ? x : currentMin),
        );
        for (var shape in widget.multiSelectedShapes) {
          final p = Offset(bounds.left,bounds.right);
          // print(p);
          if (widget.isTranslating) {
            shape.translate(delta.dx, delta.dy,p);
          } else if (widget.isRotating) {
            shape.rotate(delta.direction,p);
          } else if (widget.isScaling) {
            shape.scaleShape(delta.dx, delta.dy,p);
          }
        }
      } else if (widget.selectedShape != null) {
        Offset p = Offset(widget.selectedShape!.x,widget.selectedShape!.y);
        if (widget.isTranslating) {
          widget.selectedShape!.translate(delta.dx, delta.dy,p);
        } else if (widget.isRotating) {
          widget.selectedShape!.rotate(delta.direction,p);
        } else if (widget.isScaling) {
          widget.selectedShape!.scaleShape(delta.dx, delta.dy,p);
        }
      }
    });
  }

  void drawOnionSkin(Canvas canvas) {
    int startFrame = widget.currentFrame - 3; // Show last three frames
    if (startFrame < 0) startFrame = 0;

    for (int i = startFrame; i < widget.currentFrame; i++) {
      double opacity = 0.2 + 0.2 * (widget.currentFrame - i); // Gradually decrease opacity

      for (var shape in widget.frame[i].shapes) {
        final paint = Paint()
          ..color = shape.fillColor.withOpacity(opacity)
          ..style = PaintingStyle.fill;
        final strokePaint = Paint()
          ..color = shape.strokeColor.withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        if (shape is RectangleShape) {
          final rect = Rect.fromLTWH(shape.x, shape.y, shape.width, shape.height);
          final rrect = RRect.fromRectAndCorners(
            rect,
            topLeft: Radius.circular(shape.rtl.toDouble()),
            topRight: Radius.circular(shape.rtr.toDouble()),
            bottomLeft: Radius.circular(shape.rbl.toDouble()),
            bottomRight: Radius.circular(shape.rbr.toDouble()),
          );

          canvas.save();
          canvas.translate(shape.x + shape.width / 2, shape.y + shape.height / 2);
          canvas.rotate(shape.rotation * pi / 180);
          canvas.translate(-(shape.x + shape.width / 2), -(shape.y + shape.height / 2));
          canvas.drawRRect(rrect, paint);
          canvas.drawRect(rect, strokePaint);
          canvas.restore();
        } else if (shape is CircleShape) {
          final center = Offset(shape.x + shape.width / 2, shape.y + shape.height / 2);
          final radius = shape.width / 2;

          canvas.save();
          canvas.translate(center.dx, center.dy);
          canvas.rotate(shape.rotation * pi / 180);
          canvas.translate(-center.dx, -center.dy);
          canvas.drawOval(Rect.fromCenter(center: center, width: shape.width, height: shape.height), paint);
          canvas.drawOval(Rect.fromCenter(center: center, width: shape.width, height: shape.height), strokePaint);
          canvas.restore();
        }
      }
    }
  }
}

class FramePainter extends CustomPainter {
  final Frame currentFrame;
  final Shape? selectedShape;
  final List<Shape> multiSelectedShapes;
  final List<Frame> previousFrames; // Past frames
  final List<Frame> nextFrames; // Future frames
  var grid = false;

  FramePainter(
    this.currentFrame,
    this.selectedShape,
    this.multiSelectedShapes,
    this.previousFrames,
    this.nextFrames,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // Draw past frames with progressively lighter opacity
    for (int i = 0; i < previousFrames.length; i++) {
      final frame = previousFrames[i];
      final paint = Paint()
        ..color = Colors.grey.withOpacity(0.3 - i * 0.1)
        ..strokeWidth = 0; // Reduce opacity progressively

      for (var shape in frame.shapes) {
        shape.drawOnCanvas(canvas, overridePaint: paint, stroke_: false);
      }
    }

    // Draw future frames with progressively lighter opacity and a distinct color
    for (int i = 0; i < nextFrames.length; i++) {
      final frame = nextFrames[i];
      final paint = Paint()
        ..color = Colors.lightBlue.withOpacity(0.3 - i * 0.1); // Distinct color for future frames

      for (var shape in frame.shapes) {
        shape.drawOnCanvas(canvas, overridePaint: paint, stroke_: false);
      }
    }

    // Draw current frame shapes
    for (var shape in currentFrame.shapes.reversed) {
      shape.drawOnCanvas(canvas);
    }

    // Highlight multi-selected shapes
    if (multiSelectedShapes.isNotEmpty) {
      final bounds = Rect.fromLTRB(
        multiSelectedShapes.map((s) => s.x).reduce(min),
        multiSelectedShapes.map((s) => s.y).reduce(min),
        multiSelectedShapes.map((s) => s.x + s.width).reduce(max),
        multiSelectedShapes.map((s) => s.y + s.height).reduce(max),
      );

      final paint = Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      canvas.drawRect(bounds, paint);
    }

    // Highlight the selected shape
    if (selectedShape != null) {
      final rect = Rect.fromLTWH(
        selectedShape!.x+1,
        selectedShape!.y+1,
        selectedShape!.width-2,
        selectedShape!.height-2,
      );
      final paint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(rect, paint);
    }

    if(grid){
      grid_(canvas,size);
    }

    

    // final paint = Paint()
    //     ..color = Color.fromRGBO(0, 0, 255, 0.2)
    //     ..style = PaintingStyle.stroke
    //     ..strokeWidth = 1;

    // canvas.drawLine(const Offset(250,0),const Offset(250,5000), paint);
    // canvas.drawLine(const Offset(0,500),const Offset(1000,500), paint);
  }

  void grid_(canvas, size){
    final paint = Paint()
      ..color = Color.fromRGBO(0, 0, 255, 0.1) // Light blue color with transparency
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Grid dimensions
    const double gridSize = 20; // Size of each grid cell

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}



class Frame {
  final List<Shape> shapes = [];

  void addShape(Shape shape) {
    shapes.insert(0,shape);
  }

  void removeShape(Shape shape) {
    shapes.remove(shape);
  }
}

abstract class Shape {
  double x, y, width, height, rotation;
  Color fillColor, strokeColor;
  int rtl = 0, rtr = 0, rbl = 0, rbr = 0;

  Shape({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation = 0,
    required this.fillColor,
    required this.strokeColor,
  });

  Shape copyWith();

  void changeCornerRadius(int a,int b,int c,int d){
    rtl = a == -1 ? rtl : a;
    rtr = b == -1 ? rtr : b;
    rbl = c == -1 ? rbl : c;
    rbr = d == -1 ? rbr : d;
  }
  


  void translate(double dx, double dy,p) {
    x += dx;
    y += dy;
  }

  void rotate(double angle,p) {
    rotation += angle;
  }

  void scaleShape(double scaleFactorX, double scaleFactorY,p) {
    // print(scaleFactorX);
    width += scaleFactorX;
    height += scaleFactorY;
  }

  bool contains(Offset point);

  void drawOnCanvas(Canvas canvas, {Paint? overridePaint, bool stroke_ = false});
}

class RectangleShape extends Shape {
  RectangleShape({
    required double x,
    required double y,
    required double width,
    required double height,
    double rotation = 0,
    required Color fillColor,
    required Color strokeColor,
  }) : super(
          x: x,
          y: y,
          width: width,
          height: height,
          rotation: rotation,
          fillColor: fillColor,
          strokeColor: strokeColor,
        );

  @override
  bool contains(Offset point) {
    return point.dx >= x &&
        point.dx <= x + width &&
        point.dy >= y &&
        point.dy <= y + height;
  }

  @override
  Shape copyWith() {
    return RectangleShape(
      x: this.x,
      y: this.y,
      width: this.width,
      height: this.height,
      rotation: this.rotation,
      fillColor: this.fillColor,
      strokeColor: this.strokeColor,
    )..rtl= this.rtl
    ..rtr= this.rtr
    ..rbl = this.rbl
    ..rbr = this.rbr;
  }

  @override
  void drawOnCanvas(Canvas canvas, {Paint? overridePaint, stroke_ = true}) {
    final paint = overridePaint ??
        (Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill);
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = Rect.fromLTWH(x, y, width, height);
    final rrect = RRect.fromRectAndCorners(rect,topLeft: Radius.circular(rtl.toDouble()),topRight:  Radius.circular(rtr.toDouble()),bottomLeft:  Radius.circular(rbl.toDouble()),bottomRight:  Radius.circular(rbr.toDouble()));
    

    canvas.save();
    canvas.translate(x + width / 2, y + height / 2);
    canvas.rotate(rotation * pi / 180);
    canvas.translate(-(x + width / 2), -(y + height / 2));
    canvas.drawRRect(rrect, paint);
    canvas.drawRect(rect, stroke_ ? strokePaint : paint);
    canvas.restore();
  }
}

class CircleShape extends Shape {
  CircleShape({
    required double x,
    required double y,
    required double width,
    required double height,
    double rotation = 0,
    required Color fillColor,
    required Color strokeColor,
  }) : super(
          x: x,
          y: y,
          width: width,
          height: height,
          rotation: rotation,
          fillColor: fillColor,
          strokeColor: strokeColor,
        );

  @override
  bool contains(Offset point) {
    final center = Offset(x + width / 2, y + height / 2);
    final radius = width / 2;
    return (point - center).distance <= radius;
  }

  @override
  void drawOnCanvas(Canvas canvas, {Paint? overridePaint,stroke_ = true}) {
    final paint = overridePaint ??
        (Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill);
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(x + width / 2, y + height / 2);
    final radius = width / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * pi / 180);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawOval(Rect.fromCenter(center: center, width: width, height: height), paint);
    canvas.drawOval(Rect.fromCenter(center: center, width: width, height: height), stroke_ ? strokePaint : paint);
    canvas.restore();
  }

  @override
  Shape copyWith() {
    return CircleShape(
      x: this.x,
      y: this.y,
      width: this.width,
      height: this.height,
      rotation: this.rotation,
      fillColor: this.fillColor,
      strokeColor: this.strokeColor,
    )..rtl= this.rtl
    ..rtr= this.rtr
    ..rbl = this.rbl
    ..rbr = this.rbr;
  }
}
