import 'dart:math';
import 'package:flutter/material.dart';

class Position {
  final double x;
  final double y;
  final DateTime timestamp;

  Position(this.x, this.y, this.timestamp);
}

class TrackedObject {
  final String id;
  List<Position> positions;
  List<double> distances;
  DateTime lastSeen;
  String label;
  bool isHazard;

  TrackedObject({
    required this.id,
    required this.positions,
    required this.lastSeen,
    this.label = 'Unknown',
    this.isHazard = false,
  }) : distances = [];

  /// Calculate smoothed velocity using multiple position samples
  Offset getSmoothedVelocity() {
    if (positions.length < 3) return Offset.zero;

    // Use last 5 positions for smoothing, or all if fewer
    int sampleSize = min(5, positions.length);
    List<Position> samples = positions.sublist(positions.length - sampleSize);

    double totalDx = 0;
    double totalDy = 0;
    double totalTime = 0;

    for (int i = 1; i < samples.length; i++) {
      double dx = samples[i].x - samples[i - 1].x;
      double dy = samples[i].y - samples[i - 1].y;
      double dt =
          samples[i].timestamp
              .difference(samples[i - 1].timestamp)
              .inMilliseconds /
          1000.0;

      if (dt > 0) {
        totalDx += dx;
        totalDy += dy;
        totalTime += dt;
      }
    }

    if (totalTime == 0) return Offset.zero;

    return Offset(totalDx / totalTime, totalDy / totalTime);
  }

  /// Legacy velocity method for compatibility
  Offset getVelocity() {
    return getSmoothedVelocity();
  }

  /// Predict future position based on current velocity
  Position predictPosition(double secondsAhead) {
    if (positions.isEmpty) {
      return Position(0.5, 0.5, DateTime.now());
    }

    Offset velocity = getSmoothedVelocity();
    Position current = positions.last;

    // Simple linear prediction with velocity
    double predictedX = current.x + (velocity.dx * secondsAhead);
    double predictedY = current.y + (velocity.dy * secondsAhead);

    // Clamp to screen bounds (0-1 normalized coordinates)
    predictedX = predictedX.clamp(0.0, 1.0);
    predictedY = predictedY.clamp(0.0, 1.0);

    return Position(
      predictedX,
      predictedY,
      DateTime.now().add(Duration(milliseconds: (secondsAhead * 1000).toInt())),
    );
  }

  /// Calculate acceleration (change in velocity)
  Offset getAcceleration() {
    if (positions.length < 4) return Offset.zero;

    // Calculate velocity at two different time points
    int mid = positions.length ~/ 2;

    var earlyPositions = positions.sublist(0, mid);
    var latePositions = positions.sublist(mid);

    Offset earlyVelocity = _calculateVelocityForRange(earlyPositions);
    Offset lateVelocity = _calculateVelocityForRange(latePositions);

    double timeDiff =
        positions.last.timestamp
            .difference(positions[mid].timestamp)
            .inMilliseconds /
        1000.0;

    if (timeDiff == 0) return Offset.zero;

    return Offset(
      (lateVelocity.dx - earlyVelocity.dx) / timeDiff,
      (lateVelocity.dy - earlyVelocity.dy) / timeDiff,
    );
  }

  Offset _calculateVelocityForRange(List<Position> range) {
    if (range.length < 2) return Offset.zero;

    double dx = range.last.x - range.first.x;
    double dy = range.last.y - range.first.y;
    double dt =
        range.last.timestamp.difference(range.first.timestamp).inMilliseconds /
        1000.0;

    if (dt == 0) return Offset.zero;
    return Offset(dx / dt, dy / dt);
  }

  /// Get movement confidence score (0-1)
  /// Higher score means more consistent movement pattern
  double getMovementConfidence() {
    if (positions.length < 3) return 0.0;

    // Calculate variance in velocity directions
    List<Offset> velocities = [];
    for (int i = 1; i < positions.length; i++) {
      double dx = positions[i].x - positions[i - 1].x;
      double dy = positions[i].y - positions[i - 1].y;
      velocities.add(Offset(dx, dy));
    }

    // Calculate average velocity
    Offset avgVelocity =
        velocities.reduce((a, b) => a + b) / velocities.length.toDouble();

    // Calculate variance
    double variance = 0;
    for (var v in velocities) {
      variance += pow(v.dx - avgVelocity.dx, 2) + pow(v.dy - avgVelocity.dy, 2);
    }
    variance /= velocities.length;

    // Convert variance to confidence (inverse relationship)
    // Lower variance = higher confidence
    double confidence = 1.0 / (1.0 + variance * 100);
    return confidence.clamp(0.0, 1.0);
  }

  /// Predict position with acceleration factored in (more accurate)
  Position predictPositionWithAcceleration(double secondsAhead) {
    if (positions.length < 4) {
      return predictPosition(secondsAhead);
    }

    Offset velocity = getSmoothedVelocity();
    Offset acceleration = getAcceleration();
    Position current = positions.last;

    // Kinematic equation: position = current + velocity*t + 0.5*acceleration*t²
    double t = secondsAhead;
    double predictedX =
        current.x + (velocity.dx * t) + (0.5 * acceleration.dx * t * t);
    double predictedY =
        current.y + (velocity.dy * t) + (0.5 * acceleration.dy * t * t);

    predictedX = predictedX.clamp(0.0, 1.0);
    predictedY = predictedY.clamp(0.0, 1.0);

    return Position(
      predictedX,
      predictedY,
      DateTime.now().add(Duration(milliseconds: (secondsAhead * 1000).toInt())),
    );
  }

  /// Check if object is approaching the user (distance decreasing)
  bool isApproaching() {
    if (distances.length < 3) return false;

    // Check last 3 distance measurements
    var recentDistances = distances.sublist(distances.length - 3);
    return recentDistances[0] > recentDistances[1] &&
        recentDistances[1] > recentDistances[2];
  }

  /// Get average speed in screen coordinates per second
  double getSpeed() {
    Offset velocity = getSmoothedVelocity();
    return velocity.distance;
  }
}
