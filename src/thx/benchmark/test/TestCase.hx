package thx.benchmark.test;

using thx.format.Format;

class TestCase {
  static var desiredUncertainty = 0.01;
  static var minResolution = 1.0;
  static var threshold : Int = 1073741824;
  static var max : Int = 2147483647;
  var f : Int -> Float;
  public function new(f : Int -> Float) {
    this.f = f;
  }

  public function run() {
    var resolution = Timer.resolution();
    if(resolution < minResolution) resolution = minResolution;
    var uncertainty = resolution / 2.0,
        minimumTestTime = uncertainty / desiredUncertainty,
        stats = null,
        count = 1;
    do {
      stats = new Stats(count, f(count));
      count *= 2;
      if(count >= threshold) {
        count = max;
        stats = new Stats(count, f(count));
        break; // will overflow
      }
    } while(stats.ms <= minimumTestTime);
  }
}

class Stats {
  public var count(default, null) : Int;
  public var ms(default, null) : Float;
  public var secs(default, null) : Float;
  public var period(default, null) : Float;
  public var hz(default, null) : Float;
  public function new(count : Int, ms : Float) {
    this.count = count;
    this.ms = ms;
    this.secs = ms / 1000.0;
    this.period = this.secs / this.count;
    this.hz = 1.0 / period;
  }

  public function toString()
    return '\nexecution....: ${ms.f("#,##0.###")} ms\nrepetitions..: ${count.f("#,##0")}\ncycles.......: ${hz.f("#,##0")} hz';
}
