import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/presentation/widgets/game_texts.dart';

void main() {
  test('the clock reaches midnight exactly when the minutes run out', () {
    expect(GameTexts.clock(0, max: 10), '23:50');
    expect(GameTexts.clock(10, max: 10), '00:00');
    expect(GameTexts.clock(0, max: 13), '23:47');
    expect(GameTexts.clock(13, max: 13), '00:00');
    expect(GameTexts.clock(4, max: 5), '23:59');
  });
}
