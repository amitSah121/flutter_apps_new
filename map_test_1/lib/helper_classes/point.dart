import 'dart:math';

import 'package:map_test_1/helper_classes/model.dart';

class Point {
  final double x;
  final double y;

  Point(this.x, this.y);

  double distanceTo(Point other) {
    return sqrt(pow(x - other.x, 2) + pow(y - other.y, 2));
  }

  @override
  String toString() {
    return "Point($x,$y)";
  }
}

List<Object> findNearestPoint(Point reference, List<Point> points) {
  if (points.isEmpty) {
    // throw ArgumentError("The list of points is empty.");
    return [Point(-1, -1),-1];
  }

  // Initialize the nearest point and its distance
  Point nearestPoint = points.first;
  double minDistance = reference.distanceTo(nearestPoint);

  // Iterate through the points to find the nearest one
  int index = 0, i = -1;
  for (var point in points) {
    i++;
    double distance = reference.distanceTo(point);
    if (distance < minDistance) {
      nearestPoint = point;
      minDistance = distance;
      index = i;
    }
  }

  return [nearestPoint,index];
}

Point getClosestPointOnSegment(Point p, Point a, Point b) {
  double dx = b.x - a.x;
  double dy = b.y - a.y;

  if (dx == 0 && dy == 0) {
    // Segment is a point
    return a;
  }

  // Calculate the projection of p onto the line segment
  double t = ((p.x - a.x) * dx + (p.y - a.y) * dy) / (dx * dx + dy * dy);

  // Clamp t to the segment [0, 1]
  t = max(0, min(1, t));

  return Point(a.x + t * dx, a.y + t * dy);
}

double findPointRatio(Point p1, Point a1, Point b1) {
  // Calculate the differences in x and y
  double dx = b1.x - a1.x;
  double dy = b1.y - a1.y;

  if (dx == 0 && dy == 0) {
    // throw Exception("a1 and b1 are the same point. Cannot determine ratio.");
    return 0;
  }

  // Calculate ratio (t) for x and y
  double tx = dx != 0 ? (p1.x - a1.x) / dx : 0;
  double ty = dy != 0 ? (p1.y - a1.y) / dy : 0;

  // Ensure tx and ty are consistent if both are non-zero
  if (dx != 0 && dy != 0 && (tx - ty).abs() > 1e-6) {
    // throw Exception("Point p1 is not collinear with a1 and b1.");
  }

  // Return the consistent ratio
  return dx != 0 ? tx : ty;
}

List<Object> getClosestPointOnPolyline(Point p, List<PathNode> polyline) {
  Point? closestPoint;
  double minDistance = double.infinity;
  PathNode? a1, b1;
  int index = -1;

  for (int i = 0; i < polyline.length - 1; i++) {
    Point a = Point(polyline[i].latitude, polyline[i].longitude);
    Point b = Point(polyline[i+1].latitude, polyline[i+1].longitude);

    Point projection = getClosestPointOnSegment(p, a, b);
    double distance = sqrt(pow(projection.x - p.x, 2) + pow(projection.y - p.y, 2));

    if (distance < minDistance) {
      minDistance = distance;
      closestPoint = projection;
      a1 = polyline[i];
      b1 = polyline[i+1];
      index = i;
    }
  }

  return [closestPoint!,a1!,b1!,index,index+1];
}


List<Object> getClosestPointOnPolylinePoints(Point p, List<Point> polyline) {
  Point? closestPoint;
  double minDistance = double.infinity;
  int index = -1;

  for (int i = 0; i < polyline.length; i++) {

    double distance = sqrt(pow(polyline[i].x - p.x, 2) + pow(polyline[i].y - p.y, 2));

    if (distance < minDistance) {
      minDistance = distance;
      closestPoint = polyline[i];
      index = i;
    }
  }

  return [closestPoint!,index];
}
