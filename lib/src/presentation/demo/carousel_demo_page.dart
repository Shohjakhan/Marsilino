import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../common/gallery_carousel.dart';
import '../common/rounded_card.dart';

/// Demo page showing the GalleryCarousel component.
class CarouselDemoPage extends StatelessWidget {
  const CarouselDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo images using picsum.photos for placeholder images
    const demoImages = [
      CarouselNetworkImage('https://picsum.photos/800/400?random=1'),
      CarouselNetworkImage('https://picsum.photos/800/400?random=2'),
      CarouselNetworkImage('https://picsum.photos/800/400?random=3'),
    ];

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text('Gallery Carousel Demo', style: kTitleStyle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Auto-play Carousel:', style: kSubtitleStyle),
            const SizedBox(height: 12),
            // Carousel with default settings
            const GalleryCarousel(images: demoImages, height: 200),
            const SizedBox(height: 32),
            Text('Carousel without dots:', style: kSubtitleStyle),
            const SizedBox(height: 12),
            // Carousel without dots indicator
            const GalleryCarousel(
              images: demoImages,
              height: 180,
              showDots: false,
            ),
            const SizedBox(height: 32),
            Text('Carousel inside RoundedCard:', style: kSubtitleStyle),
            const SizedBox(height: 12),
            // Carousel inside a card
            RoundedCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GalleryCarousel(
                    images: demoImages,
                    height: 160,
                    borderRadius: kCardRadius,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Restaurant Name', style: kTitleStyle),
                        const SizedBox(height: 4),
                        Text(
                          'A beautiful restaurant with amazing food',
                          style: kBodyStyle.copyWith(color: kTextSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Single image (no auto-play):', style: kSubtitleStyle),
            const SizedBox(height: 12),
            // Single image - no auto-play needed
            const GalleryCarousel(
              images: [
                CarouselNetworkImage('https://picsum.photos/800/400?random=4'),
              ],
              height: 150,
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
