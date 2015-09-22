package thx.benchmark.test;

using thx.format.Format;

class TestCase {
  static var desiredUncertainty = 0.01;
  static var minResolution = 1.0;
  var f : Float -> Float;
  public function new(f : Float -> Float) {
    this.f = f;
  }

  public function run() {
    var resolution = Timer.resolution();
    if(resolution < minResolution) resolution = minResolution;
    var uncertainty = resolution / 2.0,
        minimumTestTime = uncertainty / desiredUncertainty,
        stats = null,
        count = 1.0;
    // var start = Timer.time(),
    //     end, loop = 0.0;
    // do {
    //   loop++;
    //   end = Timer.time();
    // } while(end - start == 0);
    // trace('start ${start.f("f")}');
    // trace('end ${end.f("f")}, span ${end - start}');
    //trace('resolution ${resolution.f("d")} ($resolution), minimumTestTime $minimumTestTime');
    //return;
    do {
      count *= 2.0;
      stats = new Stats(count, f(count));
      //trace(count, stats.ms);
    } while(stats.ms <= minimumTestTime);

    trace(stats);
  }
}

class Stats {
  public var count(default, null) : Float;
  public var ms(default, null) : Float;
  public var secs(default, null) : Float;
  public var period(default, null) : Float;
  public var hz(default, null) : Float;
  public function new(count : Float, ms : Float) {
    this.count = count;
    this.ms = ms;
    this.secs = ms / 1000.0;
    this.period = this.secs / this.count;
    this.hz = 1.0 / period;
  }

  public function toString()
    return '\nexecution....: ${ms.f("#,##0.###")} ms\nrepetitions..: ${count.f("#,##0")}\ncycles.......: ${hz.f("#,##0")} hz';
}
