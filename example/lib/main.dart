import 'package:custom_cached_image/custom_cached_image.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Custom Cached Image Example',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const ExampleScreen(),
    );
  }
}

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  static const String validImageUrl =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQq5NIheZGS3FXmFa9StpgLnYkLaXKd8j1qrH8GV_TsKYCV3t5QmK9zOlZq&s=10';

  static const String invalidImageUrl = 'https://example.com/image-not-found.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Cached Image'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _SectionTitle(title: 'Basic Cached Network Image'),
          const SizedBox(height: 12),

          CustomCachedImage(
            imageUrl: validImageUrl,
            width: double.infinity,
            height: 220,
            borderRadius: 18,
            isProfile: false,
            fit: BoxFit.cover,
            loadingStyle: CachedImageLoadingStyle.shimmer,
            showRetryButton: true,
            semanticLabel: 'Example BBC cached network image',
            onTap: () {
              debugPrint('Basic image tapped');
            },
            onError: (error) {
              debugPrint('Basic image error: $error');
            },
            onRetry: () {
              debugPrint('Retrying basic image');
            },
          ),

          const SizedBox(height: 32),

          const _SectionTitle(title: 'Circular Profile Image'),
          const SizedBox(height: 12),

          Center(
            child: CustomCachedImage.circle(
              imageUrl: validImageUrl,
              name: 'Mansoor Shah',
              size: 100,
              border: Border.all(color: Colors.black,width: 2),
              onError: (error) {
                debugPrint('Profile image error: $error');
              },
            ),
          ),

          const SizedBox(height: 32),

          const _SectionTitle(title: 'Profile Initials Fallback'),
          const SizedBox(height: 12),

          const Center(child: CustomCachedImage.circle(imageUrl: '', name: 'Mansoor Ali', size: 100, showRetryButton: false)),

          const SizedBox(height: 32),

          const _SectionTitle(title: 'Spinner Loading Style'),
          const SizedBox(height: 12),

          Center(
            child: CustomCachedImage(
              imageUrl: validImageUrl,
              width: 180,
              height: 180,
              borderRadius: 16,
              isProfile: false,
              fit: BoxFit.cover,
              loadingStyle: CachedImageLoadingStyle.spinner,
            ),
          ),

          const SizedBox(height: 32),

          const _SectionTitle(title: 'Custom Placeholder'),
          const SizedBox(height: 12),

          CustomCachedImage(
            imageUrl: validImageUrl,
            width: double.infinity,
            height: 180,
            borderRadius: 16,
            isProfile: false,
            fit: BoxFit.cover,
            placeholderWidget: const ColoredBox(
              color: Color(0xFFEFF6FF),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [CircularProgressIndicator(strokeWidth: 2), SizedBox(height: 12), Text('Loading image...')],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          const _SectionTitle(title: 'Custom Error Widget'),
          const SizedBox(height: 12),

          CustomCachedImage(
            imageUrl: invalidImageUrl,
            width: double.infinity,
            height: 180,
            borderRadius: 16,
            isProfile: false,
            showRetryButton: false,
            errorWidget: const _CustomErrorWidget(),
            onError: (error) {
              debugPrint('Custom error example: $error');
            },
          ),

          const SizedBox(height: 32),

          const _SectionTitle(title: 'Retry Failed Image'),
          const SizedBox(height: 12),

          CustomCachedImage(
            imageUrl: invalidImageUrl,
            width: double.infinity,
            height: 180,
            borderRadius: 16,
            isProfile: false,
            showRetryButton: true,
            fallbackIcon: Icons.cloud_off_rounded,
            fallbackIconColor: Colors.redAccent,
            onRetry: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Retrying image...')));
            },
            onError: (error) {
              debugPrint('Retry image error: $error');
            },
          ),

          const SizedBox(height: 32),

          const _SectionTitle(title: 'Hero Image Preview'),
          const SizedBox(height: 12),

          Center(
            child: CustomCachedImage(
              imageUrl: validImageUrl,
              width: 150,
              height: 150,
              borderRadius: 20,
              isProfile: false,
              heroTag: 'cached-image-preview',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ImagePreviewScreen()));
              },
            ),
          ),

          const SizedBox(height: 10),

          const Text('Tap the image to open the Hero preview.', textAlign: TextAlign.center),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class ImagePreviewScreen extends StatelessWidget {
  const ImagePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Image Preview'), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: CustomCachedImage(
            imageUrl: ExampleScreen.validImageUrl,
            width: double.infinity,
            height: 420,
            borderRadius: 20,
            isProfile: false,
            fit: BoxFit.contain,
            backgroundColor: Colors.black,
            heroTag: 'cached-image-preview',
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700));
  }
}

class _CustomErrorWidget extends StatelessWidget {
  const _CustomErrorWidget();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFFF1F2),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_not_supported_outlined, size: 44, color: Colors.redAccent),
            const SizedBox(height: 10),
            Text('Image unavailable', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('The image could not be loaded.', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
