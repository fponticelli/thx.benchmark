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
  public var samples(default, null) : Array<Float>;
  public var size(get, null) : Int;
  public var ms(get, null) : Float;
  public var standardDeviation(get, null) : Float;
  public var standardErrorOfMean(get, null) : Float;
  public var seconds(get, null) : Float;
  public var period(get, null) : Float;
  public var cycles(get, null) : Float;
  public function new(samples : Array<Float>, count : Int) {
    this.count = count;
    this.samples = samples;
  }

  inline function get_size()
    return samples.length;

  inline function get_ms()
    return samples.average();

  inline function get_standardDeviation()
    return samples.standardDeviation();

  function get_standardErrorOfMean()
    return standardDeviation / Math.sqrt(size);

  function get_seconds()
    return ms / 1000.0;

  function get_period()
    return seconds / count;

  function get_cycles()
    return 1.0 / period;

  public function toString()
    return 'stats on $size samples
cycles...................: ${cycles.f("#,##0")} hz
execution................: ${seconds > 1 ? seconds.f("#,##0.### s") : ms.f("#,##0.### ms")}
repetitions..............: ${count.f("#,##0")}
standard deviation.......: ${standardDeviation.f("n")}
standard error of mean...: ${standardErrorOfMean.f("n")}';
}
