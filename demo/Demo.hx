import thx.benchmark.speed.SpeedTest;

class Demo {
  public static function main() {
    var test = new SpeedTest();
    var s = 0.0,
        m = 0.0;
    test.add("summation", function() {
      s = 1 + s;
    }, true);
    test.add("multiplication", function() {
      m = 2 * m;
    });
    test.execute(10000000, function(results) {
      trace(results.toString());
    });
  }
}