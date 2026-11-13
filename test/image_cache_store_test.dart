@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:custom_cached_image/src/cache/image_cache_config.dart';
import 'package:custom_cached_image/src/cache/image_cache_store_io.dart';
import 'package:flutter_test/flutter_test.dart';

final _pngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAE'
  'hQGAhKmMIQAAAABJRU5ErkJggg==',
);

void main() {
  late HttpServer server;
  var requestCount = 0;

  String url() => 'http://${server.address.address}:${server.port}/a.png';

  setUp(() async {
    requestCount = 0;

    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

    server.listen((request) async {
      requestCount++;

      request.response.headers.contentType = ContentType('image', 'png');
      request.response.add(_pngBytes);

      await request.response.close();
    });

    ImageCacheStore.instance.configure(
      ImageCacheConfig(
        folderName: 'custom_cached_image_test_'
            '${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
  });

  tearDown(() async {
    await ImageCacheStore.instance.clear();
    await server.close(force: true);
  });


  test('downloads once and serves the second read from disk', () async {
    final first = await ImageCacheStore.instance.load(url());
    final second = await ImageCacheStore.instance.load(url());

    expect(first, equals(_pngBytes));
    expect(second, equals(_pngBytes));
    expect(requestCount, 1);
  });

  test('concurrent loads of the same url share one request', () async {
    await Future.wait([
      ImageCacheStore.instance.load(url()),
      ImageCacheStore.instance.load(url()),
      ImageCacheStore.instance.load(url()),
    ]);

    expect(requestCount, 1);
  });

  test('evicting an entry forces a new download', () async {
    await ImageCacheStore.instance.load(url());

    await ImageCacheStore.instance.evict(url());

    await ImageCacheStore.instance.load(url());

    expect(requestCount, 2);
  });

  test('the cached payload is reported in the cache size', () async {
    await ImageCacheStore.instance.load(url());

    expect(await ImageCacheStore.instance.currentSizeInBytes(),
        greaterThanOrEqualTo(_pngBytes.length));
  });

  test('a failing server throws a descriptive exception', () async {
    await expectLater(
      ImageCacheStore.instance.load('http://127.0.0.1:1/missing.png'),
      throwsA(isA<ImageCacheException>()),
    );
  });

  test('non http schemes are rejected', () async {
    await expectLater(
      ImageCacheStore.instance.load('ftp://example.com/a.png'),
      throwsA(isA<ImageCacheException>()),
    );
  });

  test('file keys are stable and unique', () {
    expect(imageCacheFileKey('a'), imageCacheFileKey('a'));
    expect(imageCacheFileKey('a') == imageCacheFileKey('b'), isFalse);
  });
}
