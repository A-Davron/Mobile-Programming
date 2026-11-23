import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as img;
import 'package:tm_classifier/services/image_sources.dart';

ImageSources _with(MockClientHandler handler, {Duration? timeout}) => ImageSources(
      client: MockClient(handler),
      timeout: timeout ?? const Duration(seconds: 15),
    );

Matcher _failsWith(String part) =>
    throwsA(isA<ImageSourceException>().having((e) => e.message, 'message', contains(part)));

void main() {
  final png = img.encodePng(img.Image(width: 8, height: 8));

  test('accepts a 200 image/png answer and returns its bytes', () async {
    final progress = <double?>[];
    final sources = _with((_) async => http.Response.bytes(png, 200, headers: {'content-type': 'image/png'}));

    final bytes = await sources.fromUrl('https://example.com/a.png', onProgress: progress.add);

    expect(bytes, png);
    expect(progress.last, 1.0);
  });

  test('rejects a web page instead of a picture', () async {
    final sources = _with((_) async =>
        http.Response('<html></html>', 200, headers: {'content-type': 'text/html; charset=utf-8'}));

    await expectLater(sources.fromUrl('https://example.com/page'), _failsWith('web page'));
  });

  test('rejects a wrong address: 404 and a non-URL', () async {
    final sources = _with((_) async => http.Response('missing', 404));

    await expectLater(sources.fromUrl('https://example.com/nope.jpg'), _failsWith('404'));
    await expectLater(sources.fromUrl('not a url'), _failsWith('https://'));
  });

  test('no network and a timeout each give a clear message', () async {
    final offline = _with((_) async => throw http.ClientException('Failed host lookup'));
    final slow = _with(
      (_) async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        return http.Response.bytes(png, 200, headers: {'content-type': 'image/png'});
      },
      timeout: const Duration(milliseconds: 20),
    );

    await expectLater(offline.fromUrl('https://example.com/a.png'), _failsWith('No connection'));
    await expectLater(slow.fromUrl('https://example.com/a.png'), _failsWith('too long'));
  });
}
