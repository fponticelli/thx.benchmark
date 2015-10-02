package thx.benchmark.speed;

using thx.format.NumberFormat;
using thx.Arrays;

class Stats {
  public static function compare(a : Stats, b : Stats)
    return Floats.compare(a.ms + a.marginOfError, b.ms + b.marginOfError);

  public var count(default, null) : Int;
  public var samples(default, null) : Array<Float>;
  public var size(get, null) : Int;
  public var ms(get, null) : Float;
  public var standardDeviation(get, null) : Float;
  public var standardErrorOfMean(get, null) : Float;
  public var seconds(get, null) : Float;
  public var period(get, null) : Float;
  public var cycles(get, null) : Float;
  public var criticalValue(get, null) : Float;
  public var marginOfError(get, null) : Float;
  public var relativeMarginOfError(get, null) : Float;
  public function new(samples : Array<Float>, count : Int) {
    this.count = count;
    this.samples = samples;
  }

  public function compareTo(that : Stats)
    return compare(this, that);

  inline function get_size()
    return samples.length;

  var _ms : Float = -1;
  function get_ms() {
    if(0.0 > _ms)
      _ms = samples.average();
    return _ms;
  }

  var _standardDeviation : Float = -1;
  function get_standardDeviation() {
    if(0.0 > _standardDeviation)
      _standardDeviation = samples.standardDeviation();
    return _standardDeviation;
  }

  function get_standardErrorOfMean()
    return standardDeviation / Math.sqrt(size);

  function get_seconds()
    return ms / 1000.0;

  function get_period()
    return seconds / count;

  function get_cycles()
    return 1.0 / period;


  function get_criticalValue() : Float {
    var df = size-1;
    if(tTable.exists(df)) {
      return tTable.get(df);
    } else {
      return tTable_infinity;
    }
  }

  function get_marginOfError() : Float
    return standardErrorOfMean * criticalValue;

  function get_relativeMarginOfError() : Float
    return marginOfError / ms;

  public function toString()
    return '${cycles < 100 ? cycles.format("#,##0.##") : cycles.format("#,##0")} ops/sec ±${relativeMarginOfError.format("#,##0.##%")} ($size run${size == 1 ? "" : "s"} sampled)';

  static var tTable_infinity = 1.96;
  static var tTable = [
    1=>  12.706, 2=>  4.303, 3=>  3.182, 4=>  2.776, 5=>  2.571, 6=>  2.447,
    7=>  2.365,  8=>  2.306, 9=>  2.262, 10=> 2.228, 11=> 2.201, 12=> 2.179,
    13=> 2.16,   14=> 2.145, 15=> 2.131, 16=> 2.12,  17=> 2.11,  18=> 2.101,
    19=> 2.093,  20=> 2.086, 21=> 2.08,  22=> 2.074, 23=> 2.069, 24=> 2.064,
    25=> 2.06,   26=> 2.056, 27=> 2.052, 28=> 2.048, 29=> 2.045, 30=> 2.042
  ];
}
