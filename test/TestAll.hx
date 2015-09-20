import utest.UTest;
import utest.Assert;
import thx.benchmark.test.macro.SpeedCaseBuilder;

class TestAll {
  public static function main() {
    UTest.run([new TestAll()]);
  }

  public function new() {}

  public function testFunctionBuilderResult() {
    var f = SpeedCaseBuilder.create(function() {
      var result;
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
      var start = haxe.Timer.stamp();
      while(--counter >= 0) {
        measureValue++;
      }
      var end = haxe.Timer.stamp();
      teardownValue++;
      return end - start;
    });

    f(100);

    Assert.equals(1, setupValue);
    Assert.equals(100, measureValue);
    Assert.equals(1, teardownValue);
  }
}
