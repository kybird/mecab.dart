// ignore_for_file: depend_on_referenced_packages

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    // advapi32 (Windows Registry API) is only needed on Windows — the native
    // source uses RegOpenKeyExW/RegCloseKey inside `#if _WIN32` guards.
    // Linking it unconditionally breaks Android (and other non-Windows)
    // builds: `ld.lld: error: unable to find library -ladvapi32`.
    final libraries = input.config.code.targetOS == OS.windows
        ? ['advapi32']
        : <String>[];
    await CBuilder.library(
      name: 'mecab_native',
      assetName: 'src/mecab.dart',
      sources: [
        'native/mecab/mecab/src/char_property.cpp',
        'native/mecab/mecab/src/connector.cpp',
        'native/mecab/mecab/src/context_id.cpp',
        'native/mecab/mecab/src/dictionary.cpp',
        'native/mecab/mecab/src/iconv_utils.cpp',
        'native/mecab/mecab/src/libmecab.cpp',
        'native/mecab/mecab/src/nbest_generator.cpp',
        'native/mecab/mecab/src/param.cpp',
        'native/mecab/mecab/src/string_buffer.cpp',
        'native/mecab/mecab/src/tagger.cpp',
        'native/mecab/mecab/src/tokenizer.cpp',
        'native/mecab/mecab/src/utils.cpp',
        'native/mecab/mecab/src/viterbi.cpp',
        'native/mecab/mecab/src/writer.cpp',
        'native/mecab/mecab/src/feature_index.cpp',
        'native/mecab/mecab/src/dictionary_rewriter.cpp',
        'native/mecab/mecab/src/dictionary_compiler.cpp',
        'native/mecab/mecab/src/dictionary_generator.cpp',
        'native/mecab/mecab/src/learner.cpp',
        'native/mecab/mecab/src/learner_tagger.cpp',
        'native/mecab/mecab/src/lbfgs.cpp',
      ],
      includes: [
        'native', // config.h + dart_ffi.cpp
        'native/mecab/mecab/src',
      ],
      defines: {'HAVE_CONFIG_H': null},
      flags: ['-std=c++11', '-w'],
      libraries: libraries,
      language: Language.cpp,
    ).run(input: input, output: output);
  });
}
