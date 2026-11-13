@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:custom_cached_image/custom_cached_image.dart';
import 'package:custom_cached_image/src/cache/image_cache_store_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _pngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAE'
  'hQGAhKmMIQAAAABJRU5ErkJggg==',
);

void main() {
  late HttpServer server;

  setUp(() async {
    HttpOverrides.global = null;

    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

    server.listen((request) async {
      request.response.headers.contentType = ContentType('image', 'png');
      request.response.add(_pngBytes);

      await request.response.close();
    });

    ImageCacheStore.instance.configure(
      ImageCacheConfig(
        folderName: 'custom_cached_image_widget_test_'
            '${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
  });

  tearDown(() async {
    await ImageCacheStore.instance.clear();
    await server.close(force: true);
  });

  testWidgets('loads a real image and replaces the shimmer placeholder',
      (tester) async {
    final url = 'http://${server.address.address}:${server.port}/a.png';

    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: CustomCachedImage(
              imageUrl: url,
              width: 50,
              height: 50,
              borderRadius: 8,
              isProfile: false,
            ),
          ),
        ),
      );

      expect(find.byType(CustomShimmer), findsOneWidget);

      await Future<void>.delayed(const Duration(milliseconds: 400));
    });

    await tester.pumpAndSettle();

    expect(find.byType(CustomShimmer), findsNothing);
    expect(tester.takeException(), isNull);

    final image = tester.widget<Image>(find.byType(Image));

    expect(image.image, isA<ResizeImage>());
  });

  testWidgets('a failing url shows the fallback and the retry button',
      (tester) async {
    Object? reportedError;

    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: CustomCachedImage(
              imageUrl: 'http://127.0.0.1:1/missing.png',
              width: 50,
              height: 50,
              borderRadius: 8,
              isProfile: false,
              onError: (error) => reportedError = error,
            ),
          ),
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 600));
    });

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    expect(reportedError, isNotNull);
  });
}
