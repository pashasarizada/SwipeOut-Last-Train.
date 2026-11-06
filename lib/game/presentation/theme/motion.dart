/// Animation timings from docs/ART_DIRECTION.md. Input is locked while the
/// pulse plays.
const Duration kPulseMove = Duration(milliseconds: 400);
const Duration kSwitchFlip = Duration(milliseconds: 180);
const Duration kSignalFade = Duration(milliseconds: 150);
const Duration kPulseWave = Duration(milliseconds: 100);
const Duration kArrival = Duration(milliseconds: 300);
const Duration kCollisionFlash = Duration(milliseconds: 300);
const Duration kCollisionBump = Duration(milliseconds: 300);
const Duration kDeliveryTapGap = Duration(milliseconds: 100);
const Duration kLevelComplete = Duration(milliseconds: 700);
const Duration kScreenIntro = Duration(milliseconds: 450);

/// One run of the forecast arrows' dots, and how many runs play after the
/// board changes before it rests (D-030).
const Duration kForecastLoop = Duration(milliseconds: 1600);
const int kForecastLoops = 3;
