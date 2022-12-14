import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:jl_photo_view/jl_photo_view.dart'
    show
        JLPhotoViewScaleState,
        JLPhotoViewHeroAttributes,
        JLPhotoViewImageTapDownCallback,
        JLPhotoViewImageTapUpCallback,
        JLPhotoViewImageLongPressCallback,
        JLPhotoViewImageScaleEndCallback,
        ScaleStateCycle,
        JLPVUpdateImageViewCallback;
import 'package:jl_photo_view/src/controller/jl_photo_view_controller.dart';
import 'package:jl_photo_view/src/controller/jl_photo_view_controller_delegate.dart';
import 'package:jl_photo_view/src/controller/jl_photo_view_scalestate_controller.dart';
import 'package:jl_photo_view/src/core/jl_photo_view_gesture_detector.dart';
import 'package:jl_photo_view/src/core/jl_photo_view_hit_corners.dart';
import 'package:jl_photo_view/src/utils/jl_photo_view_utils.dart';
import 'package:jiji_modelcard_maker/common/jijimodel_photo_view_album.dart';
import 'package:jiji_modelcard_maker/common/jijimodel_photo_view_item.dart';
import 'package:provider/provider.dart';
const _defaultDecoration = const BoxDecoration(
  color: const Color.fromRGBO(0, 0, 0, 1.0),
);

/// Internal widget in which controls all animations lifecycle, core responses
/// to user gestures, updates to  the controller state and mounts the entire JLPhotoView Layout
class JLPhotoViewCore extends StatefulWidget {
  const JLPhotoViewCore({
    Key? key,
    required this.imageProvider,
    required this.backgroundDecoration,
    required this.gaplessPlayback,
    required this.heroAttributes,
    required this.enableRotation,
    required this.onTapUp,
    required this.onTapDown,
    required this.onLongPress,
    required this.onScaleEnd,
    required this.gestureDetectorBehavior,
    required this.controller,
    required this.scaleBoundaries,
    required this.scaleStateCycle,
    required this.scaleStateController,
    required this.basePosition,
    required this.tightMode,
    required this.filterQuality,
    required this.disableGestures,
    required this.enablePanAlways,
  })  : customChild = null,
        super(key: key);

  const JLPhotoViewCore.customChild({
    Key? key,
    required this.customChild,
    required this.backgroundDecoration,
    this.heroAttributes,
    required this.enableRotation,
    this.onTapUp,
    this.onTapDown,
    this.onLongPress,
    this.onScaleEnd,
    this.gestureDetectorBehavior,
    required this.controller,
    required this.scaleBoundaries,
    required this.scaleStateCycle,
    required this.scaleStateController,
    required this.basePosition,
    required this.tightMode,
    required this.filterQuality,
    required this.disableGestures,
    required this.enablePanAlways,

  })  : imageProvider = null,
        gaplessPlayback = false,
        super(key: key);
  final Decoration? backgroundDecoration;
  final ImageProvider? imageProvider;
  final bool? gaplessPlayback;
  final JLPhotoViewHeroAttributes? heroAttributes;
  final bool enableRotation;
  final Widget? customChild;

  final JLPhotoViewControllerBase controller;
  final JLPhotoViewScaleStateController scaleStateController;
  final ScaleBoundaries scaleBoundaries;
  final ScaleStateCycle scaleStateCycle;
  final Alignment basePosition;

  final JLPhotoViewImageTapUpCallback? onTapUp;
  final JLPhotoViewImageTapDownCallback? onTapDown;
  final JLPhotoViewImageLongPressCallback? onLongPress;
  final JLPhotoViewImageScaleEndCallback? onScaleEnd;

  final HitTestBehavior? gestureDetectorBehavior;
  final bool tightMode;
  final bool disableGestures;
  final bool enablePanAlways;

  final FilterQuality filterQuality;

  @override
  State<StatefulWidget> createState() {
    return JLPhotoViewCoreState();
  }

  bool get hasCustomChild => customChild != null;
}

class JLPhotoViewCoreState extends State<JLPhotoViewCore>
    with
        TickerProviderStateMixin,
        JLPhotoViewControllerDelegate,
        HitCornersDetector,
        AutomaticKeepAliveClientMixin{
  Offset? _normalizedPosition;
  double? _scaleBefore;
  double? _rotationBefore;

  Offset? _nextPosition;
  double? _scaleAfter;
  double? _rotationAfter;

  late final AnimationController _scaleAnimationController;
  Animation<double>? _scaleAnimation;

  late final AnimationController _positionAnimationController;
  Animation<Offset>? _positionAnimation;

  late final AnimationController _rotationAnimationController =
      AnimationController(vsync: this)..addListener(handleRotationAnimation);
  Animation<double>? _rotationAnimation;

  JLPhotoViewHeroAttributes? get heroAttributes => widget.heroAttributes;

  late ScaleBoundaries cachedScaleBoundaries = widget.scaleBoundaries;

  void handleScaleAnimation() {
    setState(() {
      scale = _scaleAnimation!.value;
    });
  }

  void handlePositionAnimate() {
    setState(() {
      controller.position = _positionAnimation!.value;
    });
  }

  void handleRotationAnimation() {
    setState(() {
      controller.rotation = _rotationAnimation!.value;
    });
  }

  void onLongPress() {
    print('onLongPress!!!!!!!!!!');
    //GestureDetector
  }
  
  void onScaleStart(ScaleStartDetails details) {
    _rotationBefore = controller.rotation;
    _scaleBefore = scale;
    _normalizedPosition = details.focalPoint - controller.position;
    _scaleAnimationController.stop();
    _positionAnimationController.stop();
    _rotationAnimationController.stop();
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    final double newScale = _scaleBefore! * details.scale;
    final Offset delta = details.focalPoint - _normalizedPosition!;

    updateScaleStateFromNewScale(newScale);

    updateMultiple(
      scale: newScale,
      position: widget.enablePanAlways
          ? delta
          : clampPosition(position: delta * details.scale),
      rotation:
          widget.enableRotation ? _rotationBefore! + details.rotation : null,
      rotationFocusPoint: widget.enableRotation ? details.focalPoint : null,
    );
  }

  void onScaleEnd(ScaleEndDetails details) {
    final double _scale = scale;
    final Offset _position = controller.position;
    final double maxScale = scaleBoundaries.maxScale;
    final double minScale = scaleBoundaries.minScale;
    // var photoViewModel = Provider.of<JiJiModelPhotoViewModel>(context);
    // photoViewModel.updatePhotoViewScale(value.rotation, value.position.dx, value.position.dy, computedScale);
    // print(photoViewModel.photoViewRotation);
    // print(photoViewModel.photoViewScale);
    // print(photoViewModel.deltaDx);
    // print(photoViewModel.deltaDy);
    // var photoViewAlbum = Provider.of<JiJiModelPhotoViewAlbum>(context, listen:false);
    // photoViewAlbum.updatePhotoViewItemwithKey(this, Key(this.hashCode));
    // photoViewAlbum.currentScale = controller.scale!;
    // photoViewAlbum.currentRotation = controller.rotation!;
    // print('----ImageStream build------controller.scale${photoViewAlbum.currentScale}');
    // print('----ImageStream build------controller.rotation${photoViewAlbum.currentRotation}');

    widget.onScaleEnd?.call(context, details, controller.value);

    //animate back to maxScale if gesture exceeded the maxScale specified
    if (_scale > maxScale) {
      final double scaleComebackRatio = maxScale / _scale;
      animateScale(_scale, maxScale);
      final Offset clampedPosition = clampPosition(
        position: _position * scaleComebackRatio,
        scale: maxScale,
      );

      animatePosition(_position, clampedPosition);
     return;
    }

    //animate back to minScale if gesture fell smaller than the minScale specified
    if (_scale < minScale) {
      final double scaleComebackRatio = minScale / _scale;
      animateScale(_scale, minScale);
      animatePosition(
        _position,
        clampPosition(
          position: _position * scaleComebackRatio,
          scale: minScale,
        ),
      );
      return;
    }
    // get magnitude from gesture velocity
    final double magnitude = details.velocity.pixelsPerSecond.distance;

    // animate velocity only if there is no scale change and a significant magnitude
    if (_scaleBefore! / _scale == 1.0 && magnitude >= 400.0) {
      final Offset direction = details.velocity.pixelsPerSecond / magnitude;
      animatePosition(
        _position,
        clampPosition(position: _position + direction * 100.0),
      );
    }
  }

  void onDoubleTap() {
    nextScaleState();
  }

  void animateScale(double from, double to) {
    _scaleAnimation = Tween<double>(
      begin: from,
      end: to,
    ).animate(_scaleAnimationController);
    _scaleAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void animatePosition(Offset from, Offset to) {
    _positionAnimation = Tween<Offset>(begin: from, end: to)
        .animate(_positionAnimationController);
    _positionAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void animateRotation(double from, double to) {
    _rotationAnimation = Tween<double>(begin: from, end: to)
        .animate(_rotationAnimationController);
    _rotationAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      onAnimationStatusCompleted();
    }
  }

  /// Check if scale is equal to initial after scale animation update
  void onAnimationStatusCompleted() {
    if (scaleStateController.scaleState != JLPhotoViewScaleState.initial &&
        scale == scaleBoundaries.initialScale) {
      scaleStateController.setInvisibly(JLPhotoViewScaleState.initial);
    }
  }

  @override
  void initState() {
    super.initState();
    initDelegate();
    addAnimateOnScaleStateUpdate(animateOnScaleStateUpdate);

    cachedScaleBoundaries = widget.scaleBoundaries;

    _scaleAnimationController = AnimationController(vsync: this)
      ..addListener(handleScaleAnimation)
      ..addStatusListener(onAnimationStatus);
    _positionAnimationController = AnimationController(vsync: this)
      ..addListener(handlePositionAnimate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //????????????????????????
      print('!!!!!!!!!!!!!!!--------WidgetsBinding');
      // JiJiModelPhotoViewItem item = JiJiModelPhotoViewItem();
      // item.key = Key('${widget.key}');
      // var photoViewModel = Provider.of<JiJiModelPhotoViewAlbum>(context);
      // var photoViewItem = JiJiModelPhotoViewItem();
      // photoViewItem.key = widget.key!;
      // photoViewModel.addPhotoViewItemWithKey(photoViewItem,Key('${widget.key}'));
      print('_scaleAfter${controller.scale}');
      print('_nextPosition${controller.position}');
      print('_rotationAfter${controller.rotation}');
      // var photoViewAlbum = Provider.of<JiJiModelPhotoViewAlbum>(context, listen:false);
      // photoViewAlbum.currentScale = controller.scale!;
      // print(photoViewAlbum.currentScale);
      // print('!!!!!!!!!!!!!!!--------WidgetsBinding');
    });
  }

  void animateOnScaleStateUpdate(double prevScale, double nextScale) {
    animateScale(prevScale, nextScale);
    animatePosition(controller.position, Offset.zero);
    animateRotation(controller.rotation, 0.0);

  }

  @override
  void dispose() {
    print('!!!!!!!!!!!!!!!--------dispose start');
    // var photoViewAlbum = Provider.of<JiJiModelPhotoViewAlbum>(context, listen:false);
    // var currentPhotoViewItem = photoViewAlbum.currentItem(Key('${this.hashCode}'));
    // currentPhotoViewItem.currentRotation = controller.rotation;
    // currentPhotoViewItem.currentScale = controller.scale;
    // currentPhotoViewItem.currentPosition = controller.position;
    // print(currentPhotoViewItem.currentRotation);
    // print(currentPhotoViewItem.currentScale);
    // print(currentPhotoViewItem.currentPosition);

    print('controller.scale${controller.scale}');
    print('controller.position${controller.position}');
    print('controller.rotation${controller.rotation}');
    print('!!!!!!!!!!!!!!!--------dispose end');

    _scaleAnimationController.removeStatusListener(onAnimationStatus);
    _scaleAnimationController.dispose();
    _positionAnimationController.dispose();
    _rotationAnimationController.dispose();
    super.dispose();
  }
  @override
  // void didChangeDependencies() {
  //   var photoViewAlbum = Provider.of<JiJiModelPhotoViewAlbum>(context);
  //   var currentPhotoViewItem = photoViewAlbum.currentItem(Key('${widget.key}'));
  //   if (this == currentPhotoViewItem) {
  //     currentPhotoViewItem?.currentPosition = this.controller.position!;
  //     currentPhotoViewItem?.currentScale = this.controller.scale!;
  //     currentPhotoViewItem?.currentRotation = this.controller.rotation!;
  //   } else return;
  // }
  //

  //????????????true
  @override
  bool get wantKeepAlive => true;

  void onTapUp(TapUpDetails details) {
    widget.onTapUp?.call(context, details, controller.value);
  }

  void onTapDown(TapDownDetails details) {
    widget.onTapDown?.call(context, details, controller.value);
  }

  @override
  Widget build(BuildContext context) {
    // Check if we need a recalc on the scale
    if (widget.scaleBoundaries != cachedScaleBoundaries) {
      markNeedsScaleRecalc = true;
      cachedScaleBoundaries = widget.scaleBoundaries;
    }

    return StreamBuilder(
        stream: controller.outputStateStream,
        initialData: controller.prevValue,
        builder: (
          BuildContext context,
          AsyncSnapshot<JLPhotoViewControllerValue> snapshot,
        ) {
          if (snapshot.hasData) {
            final JLPhotoViewControllerValue value = snapshot.data!;
            final useImageScale = widget.filterQuality != FilterQuality.none;

            final computedScale = useImageScale ? 1.0 : scale;

            final matrix = Matrix4.identity()
              ..translate(value.position.dx, value.position.dy)
              ..scale(computedScale)
              ..rotateZ(value.rotation);
            // print('-------jl_photo_view_core--${context.widget.hashCode}----position.dx-----${value.position.dx}');
            // print('-------jl_photo_view_core--${context.widget.hashCode}----position.dy-----${value.position.dy}');
            // print('-------jl_photo_view_core--${context.widget.hashCode}----rotationAfter---${value.rotation}');
            // print('-------jl_photo_view_core--${context.widget.hashCode}----scaleAfter------${computedScale}');
            // _nextPosition = Offset(value.position.dx, value.position.dy);
            // _scaleAfter = computedScale;
            // _rotationAfter = value.rotation;

            //print(photoViewAlbum.currentScale);
          final Widget customChildLayout = CustomSingleChildLayout(
              delegate: _CenterWithOriginalSizeDelegate(
                scaleBoundaries.childSize,
                basePosition,
                useImageScale,
              ),
              child: _buildHero(),
            );

            final child = Container(
              constraints: widget.tightMode
                  ? BoxConstraints.tight(scaleBoundaries.childSize * scale)
                  : null,
              child: Center(
                child: Transform(
                  child: customChildLayout,
                  transform: matrix,
                  alignment: basePosition,
                ),
              ),
              decoration: widget.backgroundDecoration ?? _defaultDecoration,
            );

            if (widget.disableGestures) {
              return child;
            }

            return JLPhotoViewGestureDetector(
              child: child,
              onDoubleTap: nextScaleState,
              onScaleStart: onScaleStart,
              onScaleUpdate: onScaleUpdate,
              onScaleEnd: onScaleEnd,
              hitDetector: this,
              onTapUp: widget.onTapUp != null
                  ? (details) => widget.onTapUp!(context, details, value)
                  : null,
              onTapDown: widget.onTapDown != null
                  ? (details) => widget.onTapDown!(context, details, value)
                  : null,
              //onLongPress: onLongPress,

            );
          } else {
            return Container();
          }
        });
  }

  Widget _buildHero() {
    return heroAttributes != null
        ? Hero(
            tag: heroAttributes!.tag,
            createRectTween: heroAttributes!.createRectTween,
            flightShuttleBuilder: heroAttributes!.flightShuttleBuilder,
            placeholderBuilder: heroAttributes!.placeholderBuilder,
            transitionOnUserGestures: heroAttributes!.transitionOnUserGestures,
            child: _buildChild(),
          )
        : _buildChild();
  }

  Widget _buildChild() {
    return widget.hasCustomChild
        ? widget.customChild!
        : Image(
            image: widget.imageProvider!,
            gaplessPlayback: widget.gaplessPlayback ?? false,
            filterQuality: widget.filterQuality,
            width: scaleBoundaries.childSize.width * scale,
            fit: BoxFit.contain,
          );
  }
}


class _CenterWithOriginalSizeDelegate extends SingleChildLayoutDelegate {
  const _CenterWithOriginalSizeDelegate(
    this.subjectSize,
    this.basePosition,
    this.useImageScale,
  );

  final Size subjectSize;
  final Alignment basePosition;
  final bool useImageScale;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final childWidth = useImageScale ? childSize.width : subjectSize.width;
    final childHeight = useImageScale ? childSize.height : subjectSize.height;

    final halfWidth = (size.width - childWidth) / 2;
    final halfHeight = (size.height - childHeight) / 2;

    final double offsetX = halfWidth * (basePosition.x + 1);
    final double offsetY = halfHeight * (basePosition.y + 1);
    return Offset(offsetX, offsetY);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return useImageScale
        ? const BoxConstraints()
        : BoxConstraints.tight(subjectSize);
  }

  @override
  bool shouldRelayout(_CenterWithOriginalSizeDelegate oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CenterWithOriginalSizeDelegate &&
          runtimeType == other.runtimeType &&
          subjectSize == other.subjectSize &&
          basePosition == other.basePosition &&
          useImageScale == other.useImageScale;

  @override
  int get hashCode =>
      subjectSize.hashCode ^ basePosition.hashCode ^ useImageScale.hashCode;
}
