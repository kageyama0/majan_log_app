import 'package:flutter_test/flutter_test.dart';
import 'package:majan_log_app/widgets/hanchan_row_editor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HanchanRowEditor sit-out', () {
    test('新規行はローテ既定の休み', () {
      final editor = HanchanRowEditor(
        gameNumber: 1,
        playerIds: const [1, 2, 3, 4, 5],
        seatCount: 4,
      );
      expect(editor.sittingOutIds, {1});
      expect(editor.seatedIds, [2, 3, 4, 5]);
      editor.dispose();
    });

    test('席上 n-1 入力後、空き席フォーカスでゼロ和自動', () {
      final editor = HanchanRowEditor(
        gameNumber: 1,
        playerIds: const [1, 2, 3, 4, 5],
        seatCount: 4,
        initialSittingOutIds: {5},
      );
      editor.controllers[1]!.text = '30';
      editor.controllers[2]!.text = '10';
      editor.controllers[3]!.text = '-20';
      // 入力だけでは埋まらない
      expect(editor.controllers[4]!.text, '');
      expect(editor.tryAutoFillOnFocus(4), isTrue);
      expect(editor.controllers[4]!.text, '-20');
      final scores = editor.parsedScoresOrNull();
      expect(scores, isNotNull);
      expect(scores!.keys.toSet(), {1, 2, 3, 4});
      expect(scores.values.fold<int>(0, (a, b) => a + b), 0);
      editor.dispose();
    });

    test('未入力が2席以上ならフォーカスでも埋めない', () {
      final editor = HanchanRowEditor(
        gameNumber: 1,
        playerIds: const [1, 2, 3, 4],
        seatCount: 4,
      );
      editor.controllers[1]!.text = '30';
      editor.controllers[2]!.text = '10';
      expect(editor.tryAutoFillOnFocus(4), isFalse);
      expect(editor.controllers[4]!.text, '');
      editor.dispose();
    });

    test('手動入力済みの最終席は上書きしない', () {
      final editor = HanchanRowEditor(
        gameNumber: 1,
        playerIds: const [1, 2, 3, 4],
        seatCount: 4,
      );
      editor.controllers[1]!.text = '30';
      editor.controllers[2]!.text = '10';
      editor.controllers[3]!.text = '-20';
      editor.controllers[4]!.text = '99';
      expect(editor.tryAutoFillOnFocus(4), isFalse);
      expect(editor.controllers[4]!.text, '99');
      editor.dispose();
    });

    test('自動記入済みなら再フォーカスで再計算', () {
      final editor = HanchanRowEditor(
        gameNumber: 1,
        playerIds: const [1, 2, 3, 4],
        seatCount: 4,
      );
      editor.controllers[1]!.text = '30';
      editor.controllers[2]!.text = '10';
      editor.controllers[3]!.text = '-20';
      expect(editor.tryAutoFillOnFocus(4), isTrue);
      expect(editor.controllers[4]!.text, '-20');
      editor.controllers[1]!.text = '40';
      expect(editor.tryAutoFillOnFocus(4), isTrue);
      expect(editor.controllers[4]!.text, '-30');
      editor.dispose();
    });

    test('休み人数が足りないと保存不可', () {
      final editor = HanchanRowEditor(
        gameNumber: 1,
        playerIds: const [1, 2, 3, 4, 5],
        seatCount: 4,
        initialSittingOutIds: {},
      );
      for (final id in [1, 2, 3, 4]) {
        editor.controllers[id]!.text = '0';
      }
      expect(editor.sitOutCountOk, isFalse);
      expect(editor.parsedScoresOrNull(), isNull);
      editor.dispose();
    });

    test('休タップ相当のトグルで入れ替え', () {
      final editor = HanchanRowEditor(
        gameNumber: 1,
        playerIds: const [1, 2, 3, 4, 5],
        seatCount: 4,
        initialSittingOutIds: {1},
      );
      editor.toggleSitOut(1); // 休み解除
      expect(editor.sittingOutIds, isEmpty);
      editor.toggleSitOut(3); // 3を休みに
      expect(editor.sittingOutIds, {3});
      editor.toggleSitOut(5); // 枠いっぱいなので入れ替え
      expect(editor.sittingOutIds, {5});
      editor.dispose();
    });
  });
}
