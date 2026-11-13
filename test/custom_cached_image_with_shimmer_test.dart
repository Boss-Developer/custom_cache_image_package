import 'package:custom_cached_image/custom_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('constructs with the required parameters', () {
    const widget = CustomCachedImage(
      imageUrl: '',
      borderRadius: 5,
      height: 10,
      width: 10,
    );

    expect(widget.height, 10);
    expect(widget.width, 10);
    expect(widget.borderRadius, 5);
    expect(widget.imageUrl, '');
  });

  test('circle constructor derives size, radius and shape', () {
    const widget = CustomCachedImage.circle(
      size: 48,
      imageUrl: 'https://example.com/a.png',
    );

    expect(widget.width, 48);
    expect(widget.height, 48);
    expect(widget.borderRadius, 24);
    expect(widget.shape, BoxShape.circle);
  });

  testWidgets('shows the shimmer placeholder while loading', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CustomCachedImage(
          imageUrl: 'https://127.0.0.1:9/never-resolves.png',
          width: 100,
          height: 100,
          borderRadius: 8,
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(CustomShimmer), findsOneWidget);
  });

  testWidgets('shows the spinner placeholder when requested', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CustomCachedImage(
          imageUrl: 'https://127.0.0.1:9/never-resolves.png',
          width: 100,
          height: 100,
          borderRadius: 8,
          loadingStyle: CachedImageLoadingStyle.spinner,
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(CustomShimmer), findsNothing);
  });

  testWidgets('an empty url renders the fallback without a retry button',
      (tester) async {
    Object? reportedError;

    await tester.pumpWidget(
      MaterialApp(
        home: CustomCachedImage(
          imageUrl: '',
          width: 80,
          height: 80,
          borderRadius: 8,
          name: 'Mansoor Ahmed',
          onError: (error) => reportedError = error,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('MA'), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsNothing);
    expect(reportedError, isA<FormatException>());
  });

  testWidgets('a non profile empty url renders the fallback icon',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CustomCachedImage(
          imageUrl: '',
          width: 80,
          height: 80,
          borderRadius: 8,
          isProfile: false,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
  });

  testWidgets('the custom placeholder wins over the loading style',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CustomCachedImage(
          imageUrl: 'https://127.0.0.1:9/never-resolves.png',
          width: 100,
          height: 100,
          borderRadius: 8,
          placeholderWidget: Text('loading'),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('loading'), findsOneWidget);
    expect(find.byType(CustomShimmer), findsNothing);
  });

  testWidgets('shimmer keeps animating without throwing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 100,
          height: 100,
          child: CustomShimmer(
            child: SizedBox.expand(),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.byType(CustomShimmer), findsOneWidget);
  });

  test('image providers compare by url and cache key', () {
    const first = CustomCachedImageProvider(url: 'https://example.com/a.png');
    const second = CustomCachedImageProvider(url: 'https://example.com/a.png');

    const keyed = CustomCachedImageProvider(
      url: 'https://example.com/a.png',
      cacheKey: 'custom',
    );

    expect(first, second);
    expect(first.hashCode, second.hashCode);
    expect(first == keyed, isFalse);
  });

  test('the cache configuration can be replaced', () {
    const config = ImageCacheConfig(
      staleAfter: Duration(days: 2),
      maxEntries: 42,
    );

    CustomImageCacheManager.configure(config);

    expect(CustomImageCacheManager.config.staleAfter, const Duration(days: 2));
    expect(CustomImageCacheManager.config.maxEntries, 42);

    CustomImageCacheManager.configure(const ImageCacheConfig());
  });
}
