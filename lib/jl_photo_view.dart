library jl_photo_view;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:jl_photo_view/src/controller/jl_photo_view_controller.dart';
import 'src/controller/jl_photo_view_scalestate_controller.dart';
import 'src/core/jl_photo_view_core.dart';
import 'src/jl_photo_view_computed_scale.dart';
import 'src/jl_photo_view_scale_state.dart';
import 'src/jl_photo_view_wrappers.dart';
import 'src/utils/jl_photo_view_hero_attributes.dart';

export 'src/controller/jl_photo_view_controller.dart';
export 'src/controller/jl_photo_view_scalestate_controller.dart';
export 'src/core/jl_photo_view_gesture_detector.dart'
    show JLPhotoViewGestureDetectorScope;
export 'src/jl_photo_view_computed_scale.dart';
export 'src/jl_photo_view_scale_state.dart';
export 'src/utils/jl_photo_view_hero_attributes.dart';

/// A [StatefulWidget] that contains all the photo view rendering elements.
///
/// Sample code to use within an image:
///
/// ```
/// JLPhotoView(
///  imageProvider: imageProvider,
///  loadingBuilder: (context, progress) => Center(
///            child: Container(
///              width: 20.0,
///              height: 20.0,
///              child: CircularProgressIndicator(
///                value: _progress == null
///                    ? null
///                    : _progress.cumulativeBytesLoaded /
///                        _progress.expectedTotalBytes,
///              ),
///            ),
///          ),
///  backgroundDecoration: BoxDecoration(color: Colors.black),
///  gaplessPlayback: false,
///  customSize: MediaQuery.of(context).size,
///  heroAttributes: const HeroAttributes(
///   tag: "someTag",
///   transitionOnUserGestures: true,
///  ),
///  scaleStateChangedCallback: this.onScaleStateChanged,
///  enableRotation: true,
///  controller:  controller,
///  minScale: JLPhotoViewComputedScale.contained * 0.8,
///  maxScale: JLPhotoViewComputedScale.covered * 1.8,
///  initialScale: JLPhotoViewComputedScale.contained,
///  basePosition: Alignment.center,
///  scaleStateCycle: scaleStateCycle
/// );
/// ```
///
/// You can customize to show an custom child instead of an image:
///
/// ```
/// JLPhotoView.customChild(
///  child: Container(
///    width: 220.0,
///    height: 250.0,
///    child: const Text(
///      "Hello there, this is a text",
///    )
///  ),
///  childSize: const Size(220.0, 250.0),
///  backgroundDecoration: BoxDecoration(color: Colors.black),
///  gaplessPlayback: false,
///  customSize: MediaQuery.of(context).size,
///  heroAttributes: const HeroAttributes(
///   tag: "someTag",
///   transitionOnUserGestures: true,
///  ),
///  scaleStateChangedCallback: this.onScaleStateChanged,
///  enableRotation: true,
///  controller:  controller,
///  minScale: JLPhotoViewComputedScale.contained * 0.8,
///  maxScale: JLPhotoViewComputedScale.covered * 1.8,
///  initialScale: JLPhotoViewComputedScale.contained,
///  basePosition: Alignment.center,
///  scaleStateCycle: scaleStateCycle
/// );
/// ```
/// The [maxScale], [minScale] and [initialScale] options may be [double] or a [JLPhotoViewComputedScale] constant
///
/// Sample using [maxScale], [minScale] and [initialScale]
///
/// ```
/// JLPhotoView(
///  imageProvider: imageProvider,
///  minScale: JLPhotoViewComputedScale.contained * 0.8,
///  maxScale: JLPhotoViewComputedScale.covered * 1.8,
///  initialScale: JLPhotoViewComputedScale.contained * 1.1,
/// );
/// ```
///
/// [customSize] is used to define the viewPort size in which the image will be
/// scaled to. This argument is rarely used. By default is the size that this widget assumes.
///
/// The argument [gaplessPlayback] is used to continue showing the old image
/// (`true`), or briefly show nothing (`false`), when the [imageProvider]
/// changes.By default it's set to `false`.
///
/// To use within an hero animation, specify [heroAttributes]. When
/// [heroAttributes] is specified, the image provider retrieval process should
/// be sync.
///
/// Sample using hero animation:
/// ```
/// // screen1
///   ...
///   Hero(
///     tag: "someTag",
///     child: Image.asset(
///       "assets/large-image.jpg",
///       width: 150.0
///     ),
///   )
/// // screen2
/// ...
/// child: JLPhotoView(
///   imageProvider: AssetImage("assets/large-image.jpg"),
///   heroAttributes: const HeroAttributes(tag: "someTag"),
/// )
/// ```
///
/// **Note: If you don't want to the zoomed image do not overlaps the size of the container, use [ClipRect](https://docs.flutter.io/flutter/widgets/ClipRect-class.html)**
///
/// ## Controllers
///
/// Controllers, when specified to JLPhotoView widget, enables the author(you) to listen for state updates through a `Stream` and change those values externally.
///
/// While [JLPhotoViewScaleStateController] is only responsible for the `scaleState`, [JLPhotoViewController] is responsible for all fields os [JLPhotoViewControllerValue].
///
/// To use them, pass a instance of those items on [controller] or [scaleStateController];
///
/// Since those follows the standard controller pattern found in widgets like [PageView] and [ScrollView], whoever instantiates it, should [dispose] it afterwards.
///
/// Example of [controller] usage, only listening for state changes:
///
/// ```
/// class _ExampleWidgetState extends State<ExampleWidget> {
///
///   JLPhotoViewController controller;
///   double scaleCopy;
///
///   @override
///   void initState() {
///     super.initState();
///     controller = JLPhotoViewController()
///       ..outputStateStream.listen(listener);
///   }
///
///   @override
///   void dispose() {
///     controller.dispose();
///     super.dispose();
///   }
///
///   void listener(JLPhotoViewControllerValue value){
///     setState((){
///       scaleCopy = value.scale;
///     })
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Stack(
///       children: <Widget>[
///         Positioned.fill(
///             child: JLPhotoView(
///               imageProvider: AssetImage("assets/pudim.png"),
///               controller: controller,
///             );
///         ),
///         Text("Scale applied: $scaleCopy")
///       ],
///     );
///   }
/// }
/// ```
///
/// An example of [scaleStateController] with state changes:
/// ```
/// class _ExampleWidgetState extends State<ExampleWidget> {
///
///   JLPhotoViewScaleStateController scaleStateController;
///
///   @override
///   void initState() {
///     super.initState();
///     scaleStateController = JLPhotoViewScaleStateController();
///   }
///
///   @override
///   void dispose() {
///     scaleStateController.dispose();
///     super.dispose();
///   }
///
///   void goBack(){
///     scaleStateController.scaleState = JLPhotoViewScaleState.originalSize;
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Stack(
///       children: <Widget>[
///         Positioned.fill(
///             child: JLPhotoView(
///               imageProvider: AssetImage("assets/pudim.png"),
///               scaleStateController: scaleStateController,
///             );
///         ),
///         FlatButton(
///           child: Text("Go to original size"),
///           onPressed: goBack,
///         );
///       ],
///     );
///   }
/// }
/// ```
///
///
/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

class JLPhotoView extends StatefulWidget {
  /// Creates a widget that displays a zoomable image.
  ///
  /// To show an image from the network or from an asset bundle, use their respective
  /// image providers, ie: [AssetImage] or [NetworkImage]
  ///
  /// Internally, the image is rendered within an [Image] widget.
  JLPhotoView({
    Key? key,
    required this.imageProvider,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.wantKeepAlive = false,
    this.gaplessPlayback = false,
    this.heroAttributes,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.controller,
    this.scaleStateController,
    this.maxScale,
    this.minScale,
    this.initialScale,
    this.basePosition,
    this.scaleStateCycle,
    this.onTapUp,
    this.onTapDown,
    this.onLongPress,
    this.onScaleEnd,
    this.customSize,
    this.gestureDetectorBehavior,
    this.tightMode,
    this.filterQuality,
    this.disableGestures,
    this.errorBuilder,
    this.enablePanAlways,
  })  : child = null,
        childSize = null,
        super(key: key);

  /// Creates a widget that displays a zoomable child.
  ///
  /// It has been created to resemble [JLPhotoView] behavior within widgets that aren't an image, such as [Container], [Text] or a svg.
  ///
  /// Instead of a [imageProvider], this constructor will receive a [child] and a [childSize].
  ///
  JLPhotoView.customChild({
    Key? key,
    required this.child,
    this.childSize,
    this.backgroundDecoration,
    this.wantKeepAlive = false,
    this.heroAttributes,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.controller,
    this.scaleStateController,
    this.maxScale,
    this.minScale,
    this.initialScale,
    this.basePosition,
    this.scaleStateCycle,
    this.onTapUp,
    this.onTapDown,
    this.onLongPress,
    this.onScaleEnd,
    this.customSize,
    this.gestureDetectorBehavior,
    this.tightMode,
    this.filterQuality,
    this.disableGestures,
    this.enablePanAlways,
  })  : errorBuilder = null,
        imageProvider = null,
        gaplessPlayback = false,
        loadingBuilder = null,
        super(key: key);

  /// Given a [imageProvider] it resolves into an zoomable image widget using. It
  /// is required
  final ImageProvider? imageProvider;

  /// While [imageProvider] is not resolved, [loadingBuilder] is called by [JLPhotoView]
  /// into the screen, by default it is a centered [CircularProgressIndicator]
  final LoadingBuilder? loadingBuilder;

  /// Show loadFailedChild when the image failed to load
  final ImageErrorWidgetBuilder? errorBuilder;

  /// Changes the background behind image, defaults to `Colors.black`.
  final BoxDecoration? backgroundDecoration;

  /// This is used to keep the state of an image in the gallery (e.g. scale state).
  /// `false` -> resets the state (default)
  /// `true`  -> keeps the state
  final bool wantKeepAlive;

  /// This is used to continue showing the old image (`true`), or briefly show
  /// nothing (`false`), when the `imageProvider` changes. By default it's set
  /// to `false`.
  final bool gaplessPlayback;

  /// Attributes that are going to be passed to [JLPhotoViewCore]'s
  /// [Hero]. Leave this property undefined if you don't want a hero animation.
  final JLPhotoViewHeroAttributes? heroAttributes;

  /// Defines the size of the scaling base of the image inside [JLPhotoView],
  /// by default it is `MediaQuery.of(context).size`.
  final Size? customSize;

  /// A [Function] to be called whenever the scaleState changes, this happens when the user double taps the content ou start to pinch-in.
  final ValueChanged<JLPhotoViewScaleState>? scaleStateChangedCallback;

  /// A flag that enables the rotation gesture support
  final bool enableRotation;

  /// The specified custom child to be shown instead of a image
  final Widget? child;

  /// The size of the custom [child]. [JLPhotoView] uses this value to compute the relation between the child and the container's size to calculate the scale value.
  final Size? childSize;

  /// Defines the maximum size in which the image will be allowed to assume, it
  /// is proportional to the original image size. Can be either a double (absolute value) or a
  /// [JLPhotoViewComputedScale], that can be multiplied by a double
  final dynamic maxScale;

  /// Defines the minimum size in which the image will be allowed to assume, it
  /// is proportional to the original image size. Can be either a double (absolute value) or a
  /// [JLPhotoViewComputedScale], that can be multiplied by a double
  final dynamic minScale;

  /// Defines the initial size in which the image will be assume in the mounting of the component, it
  /// is proportional to the original image size. Can be either a double (absolute value) or a
  /// [JLPhotoViewComputedScale], that can be multiplied by a double
  final dynamic initialScale;

  /// A way to control JLPhotoView transformation factors externally and listen to its updates
  final JLPhotoViewControllerBase? controller;

  /// A way to control JLPhotoViewScaleState value externally and listen to its updates
  final JLPhotoViewScaleStateController? scaleStateController;

  /// The alignment of the scale origin in relation to the widget size. Default is [Alignment.center]
  final Alignment? basePosition;

  /// Defines de next [JLPhotoViewScaleState] given the actual one. Default is [defaultScaleStateCycle]
  final ScaleStateCycle? scaleStateCycle;

  /// A pointer that will trigger a tap has stopped contacting the screen at a
  /// particular location.
  final JLPhotoViewImageTapUpCallback? onTapUp;

  /// A pointer that might cause a tap has contacted the screen at a particular
  /// location.
  final JLPhotoViewImageTapDownCallback? onTapDown;

  ///LongPressCallback
  final JLPhotoViewImageLongPressCallback? onLongPress;

  /// A pointer that will trigger a scale has stopped contacting the screen at a
  /// particular location.
  final JLPhotoViewImageScaleEndCallback? onScaleEnd;

  /// [HitTestBehavior] to be passed to the internal gesture detector.
  final HitTestBehavior? gestureDetectorBehavior;

  /// Enables tight mode, making background container assume the size of the image/child.
  /// Useful when inside a [Dialog]
  final bool? tightMode;

  /// Quality levels for image filters.
  final FilterQuality? filterQuality;

  // Removes gesture detector if `true`.
  // Useful when custom gesture detector is used in child widget.
  final bool? disableGestures;

  /// Enable pan the widget even if it's smaller than the hole parent widget.
  /// Useful when you want to drag a widget without restrictions.
  final bool? enablePanAlways;

  bool get _isCustomChild {
    return child != null;
  }

  @override
  State<StatefulWidget> createState() {
    return _JLPhotoViewState();
  }
}

class _JLPhotoViewState extends State<JLPhotoView>
    with AutomaticKeepAliveClientMixin {
  // image retrieval

  // controller
  late bool _controlledController;
  late JLPhotoViewControllerBase _controller;
  late bool _controlledScaleStateController;
  late JLPhotoViewScaleStateController _scaleStateController;

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _controlledController = true;
      _controller = JLPhotoViewController();
    } else {
      _controlledController = false;
      _controller = widget.controller!;
    }

    if (widget.scaleStateController == null) {
      _controlledScaleStateController = true;
      _scaleStateController = JLPhotoViewScaleStateController();
    } else {
      _controlledScaleStateController = false;
      _scaleStateController = widget.scaleStateController!;
    }

    _scaleStateController.outputScaleStateStream.listen(scaleStateListener);
  }

  @override
  void didUpdateWidget(JLPhotoView oldWidget) {
    if (widget.controller == null) {
      if (!_controlledController) {
        _controlledController = true;
        _controller = JLPhotoViewController();
      }
    } else {
      _controlledController = false;
      _controller = widget.controller!;
    }

    if (widget.scaleStateController == null) {
      if (!_controlledScaleStateController) {
        _controlledScaleStateController = true;
        _scaleStateController = JLPhotoViewScaleStateController();
      }
    } else {
      _controlledScaleStateController = false;
      _scaleStateController = widget.scaleStateController!;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (_controlledController) {
      _controller.dispose();
    }
    if (_controlledScaleStateController) {
      _scaleStateController.dispose();
    }
    super.dispose();
  }

  void scaleStateListener(JLPhotoViewScaleState scaleState) {
    if (widget.scaleStateChangedCallback != null) {
      widget.scaleStateChangedCallback!(_scaleStateController.scaleState);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (
          BuildContext context,
          BoxConstraints constraints,
          ) {
        final computedOuterSize = widget.customSize ?? constraints.biggest;
        final backgroundDecoration = widget.backgroundDecoration ??
            const BoxDecoration(color: Colors.white);

        return widget._isCustomChild
            ? CustomChildWrapper(
          child: widget.child,
          childSize: widget.childSize,
          backgroundDecoration: backgroundDecoration,
          heroAttributes: widget.heroAttributes,
          scaleStateChangedCallback: widget.scaleStateChangedCallback,
          enableRotation: widget.enableRotation,
          controller: _controller,
          scaleStateController: _scaleStateController,
          maxScale: widget.maxScale,
          minScale: widget.minScale,
          initialScale: widget.initialScale,
          basePosition: widget.basePosition,
          scaleStateCycle: widget.scaleStateCycle,
          onTapUp: widget.onTapUp,
          onTapDown: widget.onTapDown,
          onLongPress: widget.onLongPress,
          onScaleEnd: widget.onScaleEnd,
          outerSize: computedOuterSize,
          gestureDetectorBehavior: widget.gestureDetectorBehavior,
          tightMode: widget.tightMode,
          filterQuality: widget.filterQuality,
          disableGestures: widget.disableGestures,
          enablePanAlways: widget.enablePanAlways,
        )
            : ImageWrapper(
          imageProvider: widget.imageProvider!,
          loadingBuilder: widget.loadingBuilder,
          backgroundDecoration: backgroundDecoration,
          gaplessPlayback: widget.gaplessPlayback,
          heroAttributes: widget.heroAttributes,
          scaleStateChangedCallback: widget.scaleStateChangedCallback,
          enableRotation: widget.enableRotation,
          controller: _controller,
          scaleStateController: _scaleStateController,
          maxScale: widget.maxScale,
          minScale: widget.minScale,
          initialScale: widget.initialScale,
          basePosition: widget.basePosition,
          scaleStateCycle: widget.scaleStateCycle,
          onTapUp: widget.onTapUp,
          onTapDown: widget.onTapDown,
          onLongPress: widget.onLongPress,
          onScaleEnd: widget.onScaleEnd,
          outerSize: computedOuterSize,
          gestureDetectorBehavior: widget.gestureDetectorBehavior,
          tightMode: widget.tightMode,
          filterQuality: widget.filterQuality,
          disableGestures: widget.disableGestures,
          errorBuilder: widget.errorBuilder,
          enablePanAlways: widget.enablePanAlways,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => widget.wantKeepAlive;
}

/// The default [ScaleStateCycle]
JLPhotoViewScaleState defaultScaleStateCycle(JLPhotoViewScaleState actual) {
  switch (actual) {
    case JLPhotoViewScaleState.initial:
      return JLPhotoViewScaleState.covering;
    case JLPhotoViewScaleState.covering:
      return JLPhotoViewScaleState.originalSize;
    case JLPhotoViewScaleState.originalSize:
      return JLPhotoViewScaleState.initial;
    case JLPhotoViewScaleState.zoomedIn:
    case JLPhotoViewScaleState.zoomedOut:
      return JLPhotoViewScaleState.initial;
    default:
      return JLPhotoViewScaleState.initial;
  }
}

/// A type definition for a [Function] that receives the actual [JLPhotoViewScaleState] and returns the next one
/// It is used internally to walk in the "doubletap gesture cycle".
/// It is passed to [JLPhotoView.scaleStateCycle]
typedef ScaleStateCycle = JLPhotoViewScaleState Function(
    JLPhotoViewScaleState actual,
    );

/// A type definition for a callback when the user taps up the photoview region
typedef JLPhotoViewImageTapUpCallback = Function(
    BuildContext context,
    TapUpDetails details,
    JLPhotoViewControllerValue controllerValue,
    );

/// A type definition for a callback when the user long press the photoview region
typedef JLPhotoViewImageLongPressCallback = Function(
    BuildContext context,
    LongPressDownDetails details,
    JLPhotoViewControllerValue controllerValue,
    );

/// A type definition for a callback when the user taps down the photoview region
typedef JLPhotoViewImageTapDownCallback = Function(
    BuildContext context,
    TapDownDetails details,
    JLPhotoViewControllerValue controllerValue,
    );

/// A type definition for a callback when a user finished scale
typedef JLPhotoViewImageScaleEndCallback = Function(
    BuildContext context,
    ScaleEndDetails details,
    JLPhotoViewControllerValue controllerValue,
    );

/// A type definition for a callback to show a widget while the image is loading, a [ImageChunkEvent] is passed to inform progress
typedef LoadingBuilder = Widget Function(
    BuildContext context,
    ImageChunkEvent? event,
    );

