package thx.benchmark.speed;

using thx.Arrays;

class SpeedCase {
  macro public static function execute(expr : haxe.macro.Expr, ?minSamples : Int, ?maxTime : Float, ?maxSamples : Int) {
    var f = thx.benchmark.speed.macro.SpeedCaseBuilder.createF(expr);
    return macro new SpeedCase($e{f}).run($v{minSamples}, $v{maxTime}, $v{maxSamples});
  };
#if !macro
  static var desiredUncertainty = 0.01;
  static var minResolution = 1.0;
  static var threshold : Int = 1073741824;
  static var max : Int = 2147483647;
  var f : Int -> Float;
  public function new(f : Int -> Float) {
    this.f = f;
  }

  public function run(?minSamples : Int = 5, ?maxTime : Float = 5000.0, ?maxSamples : Int = 100000) {
    if(minSamples < 1)
      throw new thx.Error("At least one sample is needed get a valid case");
    var resolution = Timer.resolution();
    if(resolution < minResolution)
      resolution = minResolution;
    var uncertainty = resolution / 2.0,
        minimumTestTime = uncertainty / desiredUncertainty,
        ms = 0.0,
        count = 1,
        samples = minSamples;
    do {
      if(ms > resolution * 5) {
        // TODO add check for potential overflow (unlikely but possible)
        count = Math.ceil(count / ms * minimumTestTime * 1.075);
        ms = f(count);
      } else {
        count *= 2;
        ms = f(count);
        if(count >= threshold) {
          count = max;
          ms = f(count);
          break; // will overflow
        }
      }
    } while(ms <= minimumTestTime);
    var acc = ms;
    var sample = [ms];

    for(i in 1...minSamples) {
      var ms = f(count);
      acc += ms;
      sample.push(ms);
    }
    while(acc < maxTime && sample.length < maxSamples) {
      var ms = f(count);
      acc += ms;
      sample.push(ms);
    }
    return new Stats(sample, count);
  }
#end
}
