library jl_photo_view_gallery;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'jl_photo_view.dart'
    show
        LoadingBuilder,
        JLPhotoView,
        JLPhotoViewImageTapDownCallback,
        JLPhotoViewImageTapUpCallback,
        JLPhotoViewImageLongPressCallback,
        JLPhotoViewImageScaleEndCallback,
        ScaleStateCycle;

import 'src/controller/jl_photo_view_controller.dart';
import 'src/controller/jl_photo_view_scalestate_controller.dart';
import 'src/core/jl_photo_view_gesture_detector.dart';
import 'src/jl_photo_view_scale_state.dart';
import 'src/utils/jl_photo_view_hero_attributes.dart';

/// A type definition for a [Function] that receives a index after a page change in [JLPhotoViewGallery]
typedef JLPhotoViewGalleryPageChangedCallback = void Function(int index);

/// A type definition for a [Function] that defines a page in [JLPhotoViewGallery.build]
typedef JLPhotoViewGalleryBuilder = JLPhotoViewGalleryPageOptions Function(
    BuildContext context, int index);

/// A [StatefulWidget] that shows multiple [JLPhotoView] widgets in a [PageView]
///
/// Some of [JLPhotoView] constructor options are passed direct to [JLPhotoViewGallery] constructor. Those options will affect the gallery in a whole.
///
/// Some of the options may be defined to each image individually, such as `initialScale` or `heroAttributes`. Those must be passed via each [JLPhotoViewGalleryPageOptions].
///
/// Example of usage as a list of options:
/// ```
/// JLPhotoViewGallery(
///   pageOptions: <JLPhotoViewGalleryPageOptions>[
///     JLPhotoViewGalleryPageOptions(
///       imageProvider: AssetImage("assets/gallery1.jpg"),
///       heroAttributes: const HeroAttributes(tag: "tag1"),
///     ),
///     JLPhotoViewGalleryPageOptions(
///       imageProvider: AssetImage("assets/gallery2.jpg"),
///       heroAttributes: const HeroAttributes(tag: "tag2"),
///       maxScale: JLPhotoViewComputedScale.contained * 0.3
///     ),
///     JLPhotoViewGalleryPageOptions(
///       imageProvider: AssetImage("assets/gallery3.jpg"),
///       minScale: JLPhotoViewComputedScale.contained * 0.8,
///       maxScale: JLPhotoViewComputedScale.covered * 1.1,
///       heroAttributes: const HeroAttributes(tag: "tag3"),
///     ),
///   ],
///   loadingBuilder: (context, progress) => Center(
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
///   backgroundDecoration: widget.backgroundDecoration,
///   pageController: widget.pageController,
///   onPageChanged: onPageChanged,
/// )
/// ```
///
/// Example of usage with builder pattern:
/// ```
/// JLPhotoViewGallery.builder(
///   scrollPhysics: const BouncingScrollPhysics(),
///   builder: (BuildContext context, int index) {
///     return JLPhotoViewGalleryPageOptions(
///       imageProvider: AssetImage(widget.galleryItems[index].image),
///       initialScale: JLPhotoViewComputedScale.contained * 0.8,
///       minScale: JLPhotoViewComputedScale.contained * 0.8,
///       maxScale: JLPhotoViewComputedScale.covered * 1.1,
///       heroAttributes: HeroAttributes(tag: galleryItems[index].id),
///     );
///   },
///   itemCount: galleryItems.length,
///   loadingBuilder: (context, progress) => Center(
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
///   backgroundDecoration: widget.backgroundDecoration,
///   pageController: widget.pageController,
///   onPageChanged: onPageChanged,
/// )
/// ```
class JLPhotoViewGallery extends StatefulWidget {
  /// Construct a gallery with static items through a list of [JLPhotoViewGalleryPageOptions].
  const JLPhotoViewGallery({
    Key? key,
    required this.pageOptions,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.wantKeepAlive = false,
    this.gaplessPlayback = false,
    this.reverse = false,
    this.pageController,
    this.onPageChanged,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.scrollPhysics,
    this.scrollDirection = Axis.horizontal,
    this.customSize,
    this.allowImplicitScrolling = false,
  })  : itemCount = null,
        builder = null,
        super(key: key);

  /// Construct a gallery with dynamic items.
  ///
  /// The builder must return a [JLPhotoViewGalleryPageOptions].
  const JLPhotoViewGallery.builder({
    Key? key,
    required this.itemCount,
    required this.builder,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.wantKeepAlive = false,
    this.gaplessPlayback = false,
    this.reverse = false,
    this.pageController,
    this.onPageChanged,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.scrollPhysics,
    this.scrollDirection = Axis.horizontal,
    this.customSize,
    this.allowImplicitScrolling = false,
  })  : pageOptions = null,
        assert(itemCount != null),
        assert(builder != null),
        super(key: key);

  /// A list of options to describe the items in the gallery
  final List<JLPhotoViewGalleryPageOptions>? pageOptions;

  /// The count of items in the gallery, only used when constructed via [JLPhotoViewGallery.builder]
  final int? itemCount;

  /// Called to build items for the gallery when using [JLPhotoViewGallery.builder]
  final JLPhotoViewGalleryBuilder? builder;

  /// [ScrollPhysics] for the internal [PageView]
  final ScrollPhysics? scrollPhysics;

  /// Mirror to [JLPhotoView.loadingBuilder]
  final LoadingBuilder? loadingBuilder;

  /// Mirror to [JLPhotoView.backgroundDecoration]
  final BoxDecoration? backgroundDecoration;

  /// Mirror to [JLPhotoView.wantKeepAlive]
  final bool wantKeepAlive;

  /// Mirror to [JLPhotoView.gaplessPlayback]
  final bool gaplessPlayback;

  /// Mirror to [PageView.reverse]
  final bool reverse;

  /// An object that controls the [PageView] inside [JLPhotoViewGallery]
  final PageController? pageController;

  /// An callback to be called on a page change
  final JLPhotoViewGalleryPageChangedCallback? onPageChanged;

  /// Mirror to [JLPhotoView.scaleStateChangedCallback]
  final ValueChanged<JLPhotoViewScaleState>? scaleStateChangedCallback;

  /// Mirror to [JLPhotoView.enableRotation]
  final bool enableRotation;

  /// Mirror to [JLPhotoView.customSize]
  final Size? customSize;

  /// The axis along which the [PageView] scrolls. Mirror to [PageView.scrollDirection]
  final Axis scrollDirection;

  /// When user attempts to move it to the next element, focus will traverse to the next page in the page view.
  final bool allowImplicitScrolling;

  bool get _isBuilder => builder != null;

  @override
  State<StatefulWidget> createState() {
    return _JLPhotoViewGalleryState();
  }
}

class _JLPhotoViewGalleryState extends State<JLPhotoViewGallery> {
  late final PageController _controller =
      widget.pageController ?? PageController();

  void scaleStateChangedCallback(JLPhotoViewScaleState scaleState) {
    if (widget.scaleStateChangedCallback != null) {
      widget.scaleStateChangedCallback!(scaleState);
    }
  }

  int get actualPage {
    return _controller.hasClients ? _controller.page!.floor() : 0;
  }

  int get itemCount {
    if (widget._isBuilder) {
      return widget.itemCount!;
    }
    return widget.pageOptions!.length;
  }

  @override
  Widget build(BuildContext context) {
    // Enable corner hit test
    return JLPhotoViewGestureDetectorScope(
      axis: widget.scrollDirection,
      child: PageView.builder(
        reverse: widget.reverse,
        controller: _controller,
        onPageChanged: widget.onPageChanged,
        itemCount: itemCount,
        itemBuilder: _buildItem,
        scrollDirection: widget.scrollDirection,
        physics: widget.scrollPhysics,
        allowImplicitScrolling: widget.allowImplicitScrolling,
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final pageOption = _buildPageOption(context, index);
    final isCustomChild = pageOption.child != null;

    final JLPhotoView photoView = isCustomChild
        ? JLPhotoView.customChild(
            key: ObjectKey(index),
            child: pageOption.child,
            childSize: pageOption.childSize,
            backgroundDecoration: widget.backgroundDecoration,
            wantKeepAlive: widget.wantKeepAlive,
            controller: pageOption.controller,
            scaleStateController: pageOption.scaleStateController,
            customSize: widget.customSize,
            heroAttributes: pageOption.heroAttributes,
            scaleStateChangedCallback: scaleStateChangedCallback,
            enableRotation: widget.enableRotation,
            initialScale: pageOption.initialScale,
            minScale: pageOption.minScale,
            maxScale: pageOption.maxScale,
            scaleStateCycle: pageOption.scaleStateCycle,
            onTapUp: pageOption.onTapUp,
            onTapDown: pageOption.onTapDown,
            onLongPress: pageOption.onLongPress,
            onScaleEnd: pageOption.onScaleEnd,
            gestureDetectorBehavior: pageOption.gestureDetectorBehavior,
            tightMode: pageOption.tightMode,
            filterQuality: pageOption.filterQuality,
            basePosition: pageOption.basePosition,
            disableGestures: pageOption.disableGestures,
          )
        : JLPhotoView(
            key: ObjectKey(index),
            imageProvider: pageOption.imageProvider,
            loadingBuilder: widget.loadingBuilder,
            backgroundDecoration: widget.backgroundDecoration,
            wantKeepAlive: widget.wantKeepAlive,
            controller: pageOption.controller,
            scaleStateController: pageOption.scaleStateController,
            customSize: widget.customSize,
            gaplessPlayback: widget.gaplessPlayback,
            heroAttributes: pageOption.heroAttributes,
            scaleStateChangedCallback: scaleStateChangedCallback,
            enableRotation: widget.enableRotation,
            initialScale: pageOption.initialScale,
            minScale: pageOption.minScale,
            maxScale: pageOption.maxScale,
            scaleStateCycle: pageOption.scaleStateCycle,
            onTapUp: pageOption.onTapUp,
            onTapDown: pageOption.onTapDown,
            onLongPress: pageOption.onLongPress,
            onScaleEnd: pageOption.onScaleEnd,
            gestureDetectorBehavior: pageOption.gestureDetectorBehavior,
            tightMode: pageOption.tightMode,
            filterQuality: pageOption.filterQuality,
            basePosition: pageOption.basePosition,
            disableGestures: pageOption.disableGestures,
            errorBuilder: pageOption.errorBuilder,
          );

    return ClipRect(
      child: photoView,
    );
  }

  JLPhotoViewGalleryPageOptions _buildPageOption(
      BuildContext context, int index) {
    if (widget._isBuilder) {
      return widget.builder!(context, index);
    }
    return widget.pageOptions![index];
  }
}

/// A helper class that wraps individual options of a page in [JLPhotoViewGallery]
///
/// The [maxScale], [minScale] and [initialScale] options may be [double] or a [JLPhotoViewComputedScale] constant
///
class JLPhotoViewGalleryPageOptions {
  JLPhotoViewGalleryPageOptions({
    Key? key,
    required this.imageProvider,
    this.heroAttributes,
    this.minScale,
    this.maxScale,
    this.initialScale,
    this.controller,
    this.scaleStateController,
    this.basePosition,
    this.scaleStateCycle,
    this.onTapUp,
    this.onTapDown,
    this.onLongPress,
    this.onScaleEnd,
    this.gestureDetectorBehavior,
    this.tightMode,
    this.filterQuality,
    this.disableGestures,
    this.errorBuilder,
  })  : child = null,
        childSize = null,
        assert(imageProvider != null);

  JLPhotoViewGalleryPageOptions.customChild({
    required this.child,
    this.childSize,
    this.heroAttributes,
    this.minScale,
    this.maxScale,
    this.initialScale,
    this.controller,
    this.scaleStateController,
    this.basePosition,
    this.scaleStateCycle,
    this.onTapUp,
    this.onTapDown,
    this.onLongPress,
    this.onScaleEnd,
    this.gestureDetectorBehavior,
    this.tightMode,
    this.filterQuality,
    this.disableGestures,
  })  : errorBuilder = null,
        imageProvider = null;

  /// Mirror to [JLPhotoView.imageProvider]
  final ImageProvider? imageProvider;

  /// Mirror to [JLPhotoView.heroAttributes]
  final JLPhotoViewHeroAttributes? heroAttributes;

  /// Mirror to [JLPhotoView.minScale]
  final dynamic minScale;

  /// Mirror to [JLPhotoView.maxScale]
  final dynamic maxScale;

  /// Mirror to [JLPhotoView.initialScale]
  final dynamic initialScale;

  /// Mirror to [JLPhotoView.controller]
  final JLPhotoViewController? controller;

  /// Mirror to [JLPhotoView.scaleStateController]
  final JLPhotoViewScaleStateController? scaleStateController;

  /// Mirror to [JLPhotoView.basePosition]
  final Alignment? basePosition;

  /// Mirror to [JLPhotoView.child]
  final Widget? child;

  /// Mirror to [JLPhotoView.childSize]
  final Size? childSize;

  /// Mirror to [JLPhotoView.scaleStateCycle]
  final ScaleStateCycle? scaleStateCycle;

  /// Mirror to [JLPhotoView.onTapUp]
  final JLPhotoViewImageTapUpCallback? onTapUp;

  /// Mirror to [JLPhotoView.onTapDown]
  final JLPhotoViewImageTapDownCallback? onTapDown;

  /// Mirror to [JLPhotoView.onLongPress]
  final JLPhotoViewImageLongPressCallback? onLongPress;

  /// Mirror to [JLPhotoView.onScaleEnd]
  final JLPhotoViewImageScaleEndCallback? onScaleEnd;

  /// Mirror to [JLPhotoView.gestureDetectorBehavior]
  final HitTestBehavior? gestureDetectorBehavior;

  /// Mirror to [JLPhotoView.tightMode]
  final bool? tightMode;

  /// Mirror to [JLPhotoView.disableGestures]
  final bool? disableGestures;

  /// Quality levels for image filters.
  final FilterQuality? filterQuality;

  /// Mirror to [JLPhotoView.errorBuilder]
  final ImageErrorWidgetBuilder? errorBuilder;
}
