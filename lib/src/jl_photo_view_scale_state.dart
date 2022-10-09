/// A way to represent the step of the "doubletap gesture cycle" in which JLPhotoView is.
enum JLPhotoViewScaleState {
  initial,
  covering,
  originalSize,
  zoomedIn,
  zoomedOut,
}

extension JLPhotoViewScaleStateIZoomingExtension on JLPhotoViewScaleState {
  bool get isScaleStateZooming =>
      this == JLPhotoViewScaleState.zoomedIn ||
      this == JLPhotoViewScaleState.zoomedOut;
}
