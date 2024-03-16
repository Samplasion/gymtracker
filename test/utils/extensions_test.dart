import 'package:gymtracker/utils/extensions.dart';
import 'package:test/test.dart';

const lipsum =
    """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras ut tristique arcu. Donec porta congue orci at rutrum. Sed non leo iaculis, viverra ligula vel, euismod libero. Pellentesque a risus egestas, malesuada diam at, commodo mauris. Donec id dolor mattis, lacinia ante nec, mattis orci. Fusce aliquet ligula nec urna gravida, at egestas urna hendrerit. Ut vel erat dictum, scelerisque augue in, semper lorem. Aenean turpis odio, tincidunt sit amet interdum at, porttitor et urna. Nam feugiat nulla tempus viverra condimentum.
Pellentesque sed venenatis urna. Nunc at diam vel lectus ornare scelerisque. Aliquam id arcu at ligula gravida rutrum. Sed non interdum quam. Pellentesque ut maximus dui. Nullam sed arcu nisl. Aliquam cursus mollis justo, eget auctor augue. Morbi tincidunt erat sit amet mi dictum ultrices.
Cras posuere, magna in commodo molestie, nisl eros porttitor erat, id consectetur ex justo quis nisi. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam feugiat gravida tortor, eget tempus velit tempor ac. Etiam tincidunt ullamcorper nisi, eu commodo nulla tincidunt ac. Donec et condimentum est. In sollicitudin erat id elit condimentum pretium. Quisque elementum leo nec faucibus elementum. Duis et turpis ut turpis ultricies rutrum.
Nunc sollicitudin fringilla blandit. Proin at interdum eros, consectetur gravida nunc. Morbi semper, dui id tincidunt pulvinar, metus odio blandit odio, quis pharetra erat enim vel libero. Aenean porta lacus eu lacus sollicitudin, quis ultrices dui cursus. Nunc non dui tincidunt, auctor nulla et, ornare eros. Donec nec tempor ipsum. Praesent nec nisl vitae nisi consequat viverra sed eget lacus. Phasellus at justo diam. Mauris rutrum, nisl egestas vulputate imperdiet, metus dolor rutrum diam, vel condimentum ipsum ligula in neque. Vestibulum quis ex ac metus aliquam lacinia id in ipsum. Nulla facilisi. Curabitur ultrices libero non urna congue sodales. Aenean condimentum accumsan ipsum vitae ullamcorper.
Nam ultricies sed tortor eu consequat. Nullam consectetur, neque sed venenatis cursus, velit risus vestibulum ipsum, ut malesuada mi tortor suscipit lectus. Etiam interdum consectetur neque. Aliquam placerat lacus eget nunc tristique semper. Integer lorem risus, consectetur at dapibus in, fringilla quis lorem. Donec vel felis ipsum. Integer nec semper nisi. Suspendisse ut malesuada magna, cursus tincidunt nunc. Aenean ullamcorper varius magna, ut sagittis velit molestie vel.""";
const encodedLipsum =
    "H4sIAAAAAAAAA2VWW24cNxD81yn6AIO5g2EnQAAndmAk/72c1qoDDjnhY+Hjp5qP2ZECSIC0JPtRXVW9X2OSnfTIdact+pgoayHepSzkYsjiipSaiDc9NDsNdxKvZaXPiTPVQiVpLvpvFeLk6kpfYhBHR0yFLcAdBzE5JS6Uakl1X+mHbBRiIC+RlF31mhd66ENSYvJ6r57pIX4hqZr3uOGzm6S40nfxXkKR3NIRMtdMcpdcGBF29pIrb0yb8o6E1sGO9xFHFZdncbqNVncuxXJ7RmPKxIhNuLGMk1b5Sr/W7JDPW5dlFmiBagpM98QP3XixDkct/eBNwpYkGVh/FWuIJOHOpq7UfSHE9DjtvVTDSQM+lf2QRN7GstInCcKBMIDDqtk0LlQ0ON1qKOek8LBI2mrv2aAvWtAeTqyQlf4AHK9S74r0oXpUX5AG2E3QMahNd0CL8by8QzljVg9UEdjwGOFqcNQ6QVzry4Ml1dAKnOTaGDow1HANmBs/7NkAcOD2P1aczdi7DzMH33b+qTuSbVWtEjSztyJb9KDZP3O6mowge/RgGP1TcwF8GBFQq84AarCv9HtMN73g2sZ0grvrGBlVD7I7yetLI/8Rc5UkRpY7xq3hSbcIJhbFkRWEeDFfx5JsTADkqi/52QtE16gVz9DdN9PNg5OiCeAfDYGjTeJmvC8tMW5v+D04IYwCKWQ3uJCbMQmLnRQNVG9QVIjgl6IXPswxoDL8DHwmPUzq7R8Dy82nT6Qa/C4mo6zVbJI9URhMOy9bgC5AZLgwjoDVSr8FyjYop6VuwLINASC1Eq63jyRFjTB/1i4esG0cmaFY/FfMt2M0j5DZcLXWupbq8682VZU8mfjS+P2umNcE41Nr5+YZpaDe7ynigC/iszG/N82JbUDASbMu8MX4a+094TmqfygEBD5JUxPUPtMN6TduHG8QWYFoG0ISdGhweOSwjG7AMDZDoY4/rj2NaJPTrZ4umCFw06J9eFa4TNn0wdqGGIq3zuds7Xcwpm0VQ4olGzHbsQnioYWlEabDBbWW04tMzI2ErWY8f+MMD0D5uNQ1YsYDPJupj6lNqQ0DflR/1MKwczW4N7VqO67d+vurFmlp+F0p1tfh8ClMOUjzsr9N1DcIae/YQbPsRlQenjNXCUaLhwOBZlNgpVPfhP25Jr6pMeSEv4+vgd6Wx1idOW621c6xXqtk5+qeeWQZoF4UCSLzfqG3AdtV3lU6gD9d9MLcpbf8wf07PZZhC337Pp6YtDKW7tFzE8M8R0pcdvgKUcaymF5yqueqm4H39PEDoDayDzobOUxSl+8eXVXmIgXHY3/2Ej98j8Ha4qOZg2ngKew20bF2O5ONFa9iq2OMcQa3w7Gnu1H/qBm+DBvO8qF92wzLXERPrXdDGDO9muhw+/EOsTLftX0V6aDPzWL/rv8BFi+FabwJAAA=";

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
}
