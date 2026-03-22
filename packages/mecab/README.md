# mecab

[![pub package](https://img.shields.io/pub/v/mecab.svg)](https://pub.dev/packages/mecab)

Japanese morphological analysis for Dart, powered by [MeCab](https://taku910.github.io/mecab/).

The native library compiles automatically via Dart Native Assets (requires a C++ compiler).

## Usage

```dart
import 'package:mecab/mecab.dart';

final mecab = Mecab.init('/path/to/ipadic');

final tokens = mecab.parse('すもももももももものうち');
for (final token in tokens) {
  print('${token.surface}\t${token.reading}');
}
// すもも	スモモ
// も	モ
// もも	モモ
// も	モ
// もも	モモ
// の	ノ
// うち	ウチ

mecab.dispose();
```

## Dictionary

MeCab needs a compiled IpaDic dictionary. Install via your system package manager:

```bash
# macOS
brew install mecab-ipadic

# Ubuntu/Debian
apt-get install mecab-ipadic-utf8
```

Then pass the dictionary path to `Mecab.init()`.

## License

BSD 3-Clause. MeCab is included under its [BSD license option](https://github.com/taku910/mecab/blob/master/mecab/BSD).
