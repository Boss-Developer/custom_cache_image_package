import 'package:custom_cached_image/custom_cached_image.dart';
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
}
