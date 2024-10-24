import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:test/test.dart';

const lipsum =
    """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras ut tristique arcu. Donec porta congue orci at rutrum. Sed non leo iaculis, viverra ligula vel, euismod libero. Pellentesque a risus egestas, malesuada diam at, commodo mauris. Donec id dolor mattis, lacinia ante nec, mattis orci. Fusce aliquet ligula nec urna gravida, at egestas urna hendrerit. Ut vel erat dictum, scelerisque augue in, semper lorem. Aenean turpis odio, tincidunt sit amet interdum at, porttitor et urna. Nam feugiat nulla tempus viverra condimentum.
Pellentesque sed venenatis urna. Nunc at diam vel lectus ornare scelerisque. Aliquam id arcu at ligula gravida rutrum. Sed non interdum quam. Pellentesque ut maximus dui. Nullam sed arcu nisl. Aliquam cursus mollis justo, eget auctor augue. Morbi tincidunt erat sit amet mi dictum ultrices.
Cras posuere, magna in commodo molestie, nisl eros porttitor erat, id consectetur ex justo quis nisi. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam feugiat gravida tortor, eget tempus velit tempor ac. Etiam tincidunt ullamcorper nisi, eu commodo nulla tincidunt ac. Donec et condimentum est. In sollicitudin erat id elit condimentum pretium. Quisque elementum leo nec faucibus elementum. Duis et turpis ut turpis ultricies rutrum.
Nunc sollicitudin fringilla blandit. Proin at interdum eros, consectetur gravida nunc. Morbi semper, dui id tincidunt pulvinar, metus odio blandit odio, quis pharetra erat enim vel libero. Aenean porta lacus eu lacus sollicitudin, quis ultrices dui cursus. Nunc non dui tincidunt, auctor nulla et, ornare eros. Donec nec tempor ipsum. Praesent nec nisl vitae nisi consequat viverra sed eget lacus. Phasellus at justo diam. Mauris rutrum, nisl egestas vulputate imperdiet, metus dolor rutrum diam, vel condimentum ipsum ligula in neque. Vestibulum quis ex ac metus aliquam lacinia id in ipsum. Nulla facilisi. Curabitur ultrices libero non urna congue sodales. Aenean condimentum accumsan ipsum vitae ullamcorper.
Nam ultricies sed tortor eu consequat. Nullam consectetur, neque sed venenatis cursus, velit risus vestibulum ipsum, ut malesuada mi tortor suscipit lectus. Etiam interdum consectetur neque. Aliquam placerat lacus eget nunc tristique semper. Integer lorem risus, consectetur at dapibus in, fringilla quis lorem. Donec vel felis ipsum. Integer nec semper nisi. Suspendisse ut malesuada magna, cursus tincidunt nunc. Aenean ullamcorper varius magna, ut sagittis velit molestie vel.""";
final encodedLipsum = base64.encode(gzip.encode(utf8.encode(lipsum)));

void main() {
  group('StringCompression extension', () {
    test("compressed", () {
      const testCompressed = "H4sIAAAAAAAAAwtJLS4BADLRTXgEAAAA";
      expect(
          [testCompressed, testCompressed.replaceRange(12, 13, "E")]
              .contains("Test".compressed),
          true);
      expect(
          [encodedLipsum, encodedLipsum.replaceRange(12, 13, "E")]
              .contains(lipsum.compressed),
          true);
    });
    test("uncompressed", () {
      expect("H4sIAAAAAAAAEwtJLS4BADLRTXgEAAAA".uncompressed, "Test");
      expect(encodedLipsum.uncompressed, lipsum);
    });
  });

  group('NumGenericUtils extension', () {
    group("localized", () {
      test("en-US", () {
        Get.updateLocale(const Locale("en", "US"));
        expect(1.234.localized, "1.23");
        expect(1.239.localized, "1.24");
        expect(12.localized, "12");
        expect(1234.localized, "1,234");
        expect(1234.567.localized, "1,234.57");
        expect(123456789.012.localized, "123,456,789.01");
      });

      test("it-IT", () {
        Get.updateLocale(const Locale("it", "IT"));
        expect(1.234.localized, "1,23");
        expect(1.239.localized, "1,24");
        expect(12.localized, "12");
        expect(1234.localized, "1.234");
        expect(1234.567.localized, "1.234,57");
        expect(123456789.012.localized, "123.456.789,01");
      });

      // To update if we support new languages
    });
  });
}
