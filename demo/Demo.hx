import thx.benchmark.speed.SpeedSuite;
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

    var suite = new SpeedSuite();
    suite.addTest("math operators", test, 10000000);
    suite.run();
  }
}