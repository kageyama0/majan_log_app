import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:majan_log_app/utils/signed_int_input.dart';

void main() {
  group('parseSignedInt', () {
    test('通常の正負と空', () {
      expect(parseSignedInt('12'), 12);
      expect(parseSignedInt('-3'), -3);
      expect(parseSignedInt(''), isNull);
      expect(parseSignedInt('-'), isNull);
    });

    test('Unicode / 全角マイナスを解釈', () {
      expect(parseSignedInt('−5'), -5);
      expect(parseSignedInt('－8'), -8);
    });
  });

  group('SignedIntegerTextInputFormatter', () {
    final formatter = SignedIntegerTextInputFormatter();

    TextEditingValue fmt(String oldText, String newText) {
      return formatter.formatEditUpdate(
        TextEditingValue(
          text: oldText,
          selection: TextSelection.collapsed(offset: oldText.length),
        ),
        TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        ),
      );
    }

    test('マイナス単独と負数を許可', () {
      expect(fmt('', '-').text, '-');
      expect(fmt('-', '-5').text, '-5');
      expect(fmt('', '-12').text, '-12');
    });

    test('末尾のマイナスは先頭へ移す', () {
      expect(fmt('12', '12-').text, '-12');
    });

    test('不正文字は拒否', () {
      expect(fmt('12', '12a').text, '12');
      expect(fmt('-3', '-3.1').text, '-3');
    });
  });
}
