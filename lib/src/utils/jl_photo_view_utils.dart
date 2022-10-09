import 'dart:math' as math;
import 'dart:ui' show Size;

import 'package:jl_photo_view/src/jl_photo_view_computed_scale.dart';
import 'package:jl_photo_view/src/jl_photo_view_scale_state.dart';

/// Given a [JLPhotoViewScaleState], returns a scale value considering [scaleBoundaries].
double getScaleForScaleState(
  JLPhotoViewScaleState scaleState,
  ScaleBoundaries scaleBoundaries,
) {
  switch (scaleState) {
    case JLPhotoViewScaleState.initial:
    case JLPhotoViewScaleState.zoomedIn:
    case JLPhotoViewScaleState.zoomedOut:
      return _clampSize(scaleBoundaries.initialScale, scaleBoundaries);
    case JLPhotoViewScaleState.covering:
      return _clampSize(
          _scaleForCovering(
              scaleBoundaries.outerSize, scaleBoundaries.childSize),
          scaleBoundaries);
    case JLPhotoViewScaleState.originalSize:
      return _clampSize(1.0, scaleBoundaries);
    // Will never be reached
    default:
      return 0;
  }
}

/// Internal class to wraps custom scale boundaries (min, max and initial)
/// Also, stores values regarding the two sizes: the container and teh child.
class ScaleBoundaries {
  const ScaleBoundaries(
    this._minScale,
    this._maxScale,
    this._initialScale,
    this.outerSize,
    this.childSize,
  );

  final dynamic _minScale;
  final dynamic _maxScale;
  final dynamic _initialScale;
  final Size outerSize;
  final Size childSize;

  double get minScale {
    assert(_minScale is double || _minScale is JLPhotoViewComputedScale);
    if (_minScale == JLPhotoViewComputedScale.contained) {
      return _scaleForContained(outerSize, childSize) *
          (_minScale as JLPhotoViewComputedScale).multiplier; // ignore: avoid_as
    }
    if (_minScale == JLPhotoViewComputedScale.covered) {
      return _scaleForCovering(outerSize, childSize) *
          (_minScale as JLPhotoViewComputedScale).multiplier; // ignore: avoid_as
    }
    assert(_minScale >= 0.0);
    return _minScale;
  }

  double get maxScale {
    assert(_maxScale is double || _maxScale is JLPhotoViewComputedScale);
    if (_maxScale == JLPhotoViewComputedScale.contained) {
      return (_scaleForContained(outerSize, childSize) *
              (_maxScale as JLPhotoViewComputedScale) // ignore: avoid_as
                  .multiplier)
          .clamp(minScale, double.infinity);
    }
    if (_maxScale == JLPhotoViewComputedScale.covered) {
      return (_scaleForCovering(outerSize, childSize) *
              (_maxScale as JLPhotoViewComputedScale) // ignore: avoid_as
                  .multiplier)
          .clamp(minScale, double.infinity);
    }
    return _maxScale.clamp(minScale, double.infinity);
  }

  double get initialScale {
    assert(_initialScale is double || _initialScale is JLPhotoViewComputedScale);
    if (_initialScale == JLPhotoViewComputedScale.contained) {
      return _scaleForContained(outerSize, childSize) *
          (_initialScale as JLPhotoViewComputedScale) // ignore: avoid_as
              .multiplier;
    }
    if (_initialScale == JLPhotoViewComputedScale.covered) {
      return _scaleForCovering(outerSize, childSize) *
          (_initialScale as JLPhotoViewComputedScale) // ignore: avoid_as
              .multiplier;
    }
    return _initialScale.clamp(minScale, maxScale);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScaleBoundaries &&
          runtimeType == other.runtimeType &&
          _minScale == other._minScale &&
          _maxScale == other._maxScale &&
          _initialScale == other._initialScale &&
          outerSize == other.outerSize &&
          childSize == other.childSize;

  @override
  int get hashCode =>
      _minScale.hashCode ^
      _maxScale.hashCode ^
      _initialScale.hashCode ^
      outerSize.hashCode ^
      childSize.hashCode;
}

double _scaleForContained(Size size, Size childSize) {
  final double imageWidth = childSize.width;
  final double imageHeight = childSize.height;

  final double screenWidth = size.width;
  final double screenHeight = size.height;

  return math.min(screenWidth / imageWidth, screenHeight / imageHeight);
}

double _scaleForCovering(Size size, Size childSize) {
  final double imageWidth = childSize.width;
  final double imageHeight = childSize.height;

  final double screenWidth = size.width;
  final double screenHeight = size.height;

  return math.max(screenWidth / imageWidth, screenHeight / imageHeight);
}

double _clampSize(double size, ScaleBoundaries scaleBoundaries) {
  return size.clamp(scaleBoundaries.minScale, scaleBoundaries.maxScale);
}

/// Simple class to store a min and a max value
class CornersRange {
  const CornersRange(this.min, this.max);
  final double min;
  final double max;
}
