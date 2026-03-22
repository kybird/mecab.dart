import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'bindings_generated.dart';
import 'token.dart';

/// Japanese morphological analyzer powered by MeCab.
///
/// ```dart
/// final mecab = Mecab.init('/path/to/ipadic');
/// final tokens = mecab.parse('すもももももももものうち');
/// for (final token in tokens) {
///   print('${token.surface}\t${token.reading}');
/// }
/// mecab.dispose();
/// ```
class Mecab implements Finalizable {
  final Pointer<mecab_model_t> _model;
  final Pointer<mecab_t> _tagger;
  bool _disposed = false;

  Mecab._(this._model, this._tagger);

  /// Initialize MeCab with an IpaDic dictionary at [dictPath].
  factory Mecab.init(String dictPath) {
    return using((arena) {
      final args = ['mecab', '-d', dictPath, '-r', '$dictPath/dicrc'];
      final argv = arena<Pointer<Char>>(args.length);
      for (var i = 0; i < args.length; i++) {
        argv[i] = args[i].toNativeUtf8(allocator: arena).cast();
      }

      final model = mecab_model_new(args.length, argv);
      if (model == nullptr) {
        throw StateError('MeCab model init failed for: $dictPath');
      }

      final tagger = mecab_model_new_tagger(model);
      if (tagger == nullptr) {
        mecab_model_destroy(model);
        throw StateError('MeCab tagger creation failed');
      }

      return Mecab._(model, tagger);
    });
  }

  /// Parse text into morphological tokens.
  List<MecabToken> parse(String text) {
    _checkAlive();
    return using((arena) {
      final input = text.toNativeUtf8(allocator: arena).cast<Char>();
      final result = mecab_sparse_tostr(_tagger, input);
      if (result == nullptr) {
        throw StateError('MeCab parse failed');
      }
      return _parseOutput(result.cast<Utf8>().toDartString());
    });
  }

  /// Parse text and return raw MeCab output string.
  String rawParse(String text) {
    _checkAlive();
    return using((arena) {
      final input = text.toNativeUtf8(allocator: arena).cast<Char>();
      final result = mecab_sparse_tostr(_tagger, input);
      if (result == nullptr) {
        throw StateError('MeCab parse failed');
      }
      return result.cast<Utf8>().toDartString();
    });
  }

  /// Get MeCab version string.
  static String version() => mecab_version().cast<Utf8>().toDartString();

  /// Release MeCab resources.
  void dispose() {
    if (_disposed) return;
    mecab_destroy(_tagger);
    mecab_model_destroy(_model);
    _disposed = true;
  }

  void _checkAlive() {
    if (_disposed) throw StateError('Mecab has been disposed');
  }

  static List<MecabToken> _parseOutput(String output) {
    final tokens = <MecabToken>[];
    for (final line in output.split('\n')) {
      if (line == 'EOS' || line.isEmpty) continue;
      final tab = line.indexOf('\t');
      if (tab == -1) continue;
      tokens.add(MecabToken(
        line.substring(0, tab),
        line.substring(tab + 1),
      ));
    }
    return tokens;
  }
}
