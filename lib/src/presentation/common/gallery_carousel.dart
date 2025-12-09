import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Image source type for the carousel.
sealed class CarouselImage {
  const CarouselImage();
}

/// Network image from URL.
class CarouselNetworkImage extends CarouselImage {
  final String url;
  const CarouselNetworkImage(this.url);
}

/// Asset image from local assets.
class CarouselAssetImage extends CarouselImage {
  final String assetPath;
  const CarouselAssetImage(this.assetPath);
}

/// A self-contained carousel with auto-play and cross-fade transitions.
/// Used for displaying gallery images in restaurant pages.
class GalleryCarousel extends StatefulWidget {
  /// List of images to display.
  final List<CarouselImage> images;

  /// Duration each image is visible before transitioning.
  final Duration displayDuration;

  /// Duration of the cross-fade transition.
  final Duration transitionDuration;

  /// Whether to show dots indicator.
  final bool showDots;

  /// Height of the carousel.
  final double height;

  /// Border radius of the carousel.
  final double borderRadius;

  /// Box fit for images.
  final BoxFit fit;

  const GalleryCarousel({
    super.key,
    required this.images,
    this.displayDuration = const Duration(seconds: 3),
    this.transitionDuration = const Duration(milliseconds: 500),
    this.showDots = true,
    this.height = 200,
    this.borderRadius = kCardRadius,
    this.fit = BoxFit.cover,
  });

  @override
  State<GalleryCarousel> createState() => _GalleryCarouselState();
}

class _GalleryCarouselState extends State<GalleryCarousel>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  Timer? _autoPlayTimer;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startAutoPlay();
  }

  @override
  void dispose() {
    _stopAutoPlay();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopAutoPlay();
      _isVisible = false;
    } else if (state == AppLifecycleState.resumed) {
      _isVisible = true;
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    if (widget.images.length <= 1) return;
    _stopAutoPlay();
    _autoPlayTimer = Timer.periodic(widget.displayDuration, (_) {
      if (_isVisible && mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.images.length;
        });
      }
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  void _goToIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Restart timer when user manually changes
    _startAutoPlay();
  }

  Widget _buildImage(CarouselImage image) {
    return switch (image) {
      CarouselNetworkImage(url: final url) => Image.network(
        url,
        fit: widget.fit,
        width: double.infinity,
        height: widget.height,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingIndicator();
        },
      ),
      CarouselAssetImage(assetPath: final path) => Image.asset(
        path,
        fit: widget.fit,
        width: double.infinity,
        height: widget.height,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      ),
    };
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: widget.height,
      color: kTextSecondary.withValues(alpha: 0.1),
      child: const Icon(Icons.image_outlined, size: 48, color: kTextSecondary),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: double.infinity,
      height: widget.height,
      color: kTextSecondary.withValues(alpha: 0.1),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Positioned(
      bottom: 12,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.images.length,
          (index) => GestureDetector(
            onTap: () => _goToIndex(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: index == _currentIndex ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: index == _currentIndex
                    ? kCardBg
                    : kCardBg.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: _buildPlaceholder(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            // Images with cross-fade
            AnimatedSwitcher(
              duration: widget.transitionDuration,
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: KeyedSubtree(
                key: ValueKey(_currentIndex),
                child: _buildImage(widget.images[_currentIndex]),
              ),
            ),
            // Dots indicator
            if (widget.showDots && widget.images.length > 1) _buildDots(),
          ],
        ),
      ),
    );
  }
}
