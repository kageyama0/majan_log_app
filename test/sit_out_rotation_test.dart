import 'package:flutter_test/flutter_test.dart';
import 'package:majan_log_app/utils/sit_out_rotation.dart';

void main() {
  group('defaultSittingOutPlayerIds', () {
    test('席数＝参加者なら休みなし', () {
      expect(
        defaultSittingOutPlayerIds(
          participantIds: [1, 2, 3, 4],
          seatCount: 4,
          gameNumber: 1,
        ),
        isEmpty,
      );
    });

    test('四麻5人: 半荘ごとに1人ずつローテ', () {
      const ids = [10, 20, 30, 40, 50];
      expect(
        defaultSittingOutPlayerIds(
          participantIds: ids,
          seatCount: 4,
          gameNumber: 1,
        ),
        [10],
      );
      expect(
        defaultSittingOutPlayerIds(
          participantIds: ids,
          seatCount: 4,
          gameNumber: 2,
        ),
        [20],
      );
      expect(
        defaultSittingOutPlayerIds(
          participantIds: ids,
          seatCount: 4,
          gameNumber: 5,
        ),
        [50],
      );
      expect(
        defaultSittingOutPlayerIds(
          participantIds: ids,
          seatCount: 4,
          gameNumber: 6,
        ),
        [10],
      );
    });

    test('三麻4人: 半荘ごとに1人休み', () {
      const ids = [1, 2, 3, 4];
      expect(
        defaultSittingOutPlayerIds(
          participantIds: ids,
          seatCount: 3,
          gameNumber: 1,
        ),
        [1],
      );
      expect(
        defaultSittingOutPlayerIds(
          participantIds: ids,
          seatCount: 3,
          gameNumber: 4,
        ),
        [4],
      );
    });

    test('四麻6人: 半荘ごとに2人休み', () {
      const ids = [1, 2, 3, 4, 5, 6];
      expect(
        defaultSittingOutPlayerIds(
          participantIds: ids,
          seatCount: 4,
          gameNumber: 1,
        ),
        [1, 2],
      );
      expect(
        defaultSittingOutPlayerIds(
          participantIds: ids,
          seatCount: 4,
          gameNumber: 2,
        ),
        [3, 4],
      );
      expect(
        defaultSittingOutPlayerIds(
          participantIds: ids,
          seatCount: 4,
          gameNumber: 3,
        ),
        [5, 6],
      );
    });
  });

  group('seatedPlayerIds', () {
    test('休み以外を返す', () {
      expect(
        seatedPlayerIds(
          participantIds: [1, 2, 3, 4, 5],
          sittingOutIds: {2},
        ),
        [1, 3, 4, 5],
      );
    });
  });

  group('isSittingOut', () {
    test('ローテ結果と一致', () {
      expect(
        isSittingOut(
          playerId: 10,
          participantIds: [10, 20, 30, 40, 50],
          seatCount: 4,
          gameNumber: 1,
        ),
        isTrue,
      );
      expect(
        isSittingOut(
          playerId: 20,
          participantIds: [10, 20, 30, 40, 50],
          seatCount: 4,
          gameNumber: 1,
        ),
        isFalse,
      );
    });
  });
}
