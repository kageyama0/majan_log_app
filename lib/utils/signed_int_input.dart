import 'package:flutter/services.dart';

/// 全角・Unicode のマイナスを ASCII `-` に揃える。
String normalizeSignedIntText(String raw) {
  return raw
      .trim()
      .replaceAll('−', '-') // U+2212 MINUS SIGN
      .replaceAll('－', '-') // U+FF0D FULLWIDTH HYPHEN-MINUS
      .replaceAll('ー', '-'); // U+30FC 長音（誤入力対策）
}

/// 符号付き整数テキストをパース。空・単独 `-` は null。
int? parseSignedInt(String raw) {
  final text = normalizeSignedIntText(raw);
  if (text.isEmpty || text == '-') return null;
  return int.tryParse(text);
}

/// 先頭の `-` と数字のみを許可。末尾に付いた `-` は先頭へ移す。
///
/// 端末の数字キーパッドで符号キーが末尾挿入されるケースや、
/// Unicode マイナスを弾いてしまう問題を避ける。
class SignedIntegerTextInputFormatter extends TextInputFormatter {
  const SignedIntegerTextInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final normalized = normalizeSignedIntText(newValue.text);

    if (normalized.isEmpty || normalized == '-') {
      return TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }

    // "12-" → "-12"（符号キーが末尾に入る端末向け）
    if (RegExp(r'^\d+-$').hasMatch(normalized)) {
      final text = '-${normalized.substring(0, normalized.length - 1)}';
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    if (RegExp(r'^-?\d+$').hasMatch(normalized)) {
      final offset = newValue.selection.baseOffset;
      // 正規化で文字が変わった場合は末尾へ。それ以外はカーソルを可能な範囲で維持。
      final cursor = normalized == newValue.text
          ? offset.clamp(0, normalized.length)
          : normalized.length;
      return TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: cursor),
      );
    }

    return oldValue;
  }
}
