import utest.UTest;
import utest.Assert;
import thx.benchmark.test.macro.SpeedCaseBuilder;
import thx.benchmark.test.TestCase;

class TestAll {
  public static function main() {
    UTest.run([new TestAll()]);
  }

  public function new() {}

  public function testTestCase() {
    var test = new TestCase(SpeedCaseBuilder.create(function() {
            var value = 0.1;
            @:measure { value *= value; }
            if(value < 0)
              throw 'error';
          }));
    test.run();
    var stats = test.run(2, 50);
    Assert.isTrue(stats.size >= 2);
    Assert.isTrue(stats.ms > 0);
    Assert.isTrue(stats.cycles > 0);
  }

  public function testFunctionBuilderResult() {
    var f = SpeedCaseBuilder.create(function() {
      var result = 0;
      @:measure { result++; }
      if(result == 0)
        throw 'invalid value returned';
    });

    Assert.isTrue(f(1000) >= 0);
  }

  public function testFunctionBuilderValues() {
    var setupValue = 0,
        measureValue = 0,
        teardownValue = 0;

    var f = SpeedCaseBuilder.create(function() : Void {
      setupValue++;
      @:measure { measureValue++; }
      teardownValue++;
    });

    f(100);

    Assert.equals(1, setupValue);
    Assert.equals(100, measureValue);
    Assert.equals(1, teardownValue);
  }

  public function testFunctionBuilderMeasureOnly() {
    var measureValue = 0;

    var f = SpeedCaseBuilder.create(function() : Void {
      measureValue++;
    });

    f(100);

    Assert.equals(100, measureValue);
  }

  public function testFunctionBuilderCompatFunction() {
    var setupValue = 0,
        measureValue = 0,
        teardownValue = 0;

    var f = SpeedCaseBuilder.create(function(counter : Int) : Float {
      setupValue++;
      var start = thx.Timer.time();
      while(--counter >= 0) {
        measureValue++;
      }
      var end = thx.Timer.time();
      teardownValue++;
      return end - start;
    });

    f(100);

    Assert.equals(1, setupValue);
    Assert.equals(100, measureValue);
    Assert.equals(1, teardownValue);
  }
}
