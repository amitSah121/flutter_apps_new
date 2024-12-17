import 'package:latlong2/latlong.dart';
import 'package:map_test_1/helper_classes/model.dart';

List<double> generateEvenlySpaced(double min, double max, int n) {
  if (n <= 1) {
    throw ArgumentError("n must be greater than 1 to create evenly spaced values.");
  }
  double step = (max - min) / (n - 1);
  return List<double>.generate(n, (i) => min + i * step);
}

List<LatLng> createPolygonFromPathNodes(List<PathNode> pathNodes) {
  return pathNodes.map((p) => LatLng(p.latitude, p.longitude)).toList();
}