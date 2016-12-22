import Map as MuMap;
import utest.UTest;
import utest.Assert;
import thx.benchmark.speed.macro.SpeedCaseBuilder;
import thx.benchmark.speed.*;
import thx.fp.Map as ImMap;
using thx.Arrays;
using thx.Ints;
using thx.fp.Maps;

class TestAll {
  public static function main() {
    UTest.run([new TestAll()]);
  }

  public function new() {}

  public function testSuite() {
    var suite = new Suite(2, 100);
    suite.addCase("case #1", function(loop) return loop * 4);
    suite.addCase("case #2", function(loop) return loop * 3);
    suite.addCase("case #3", function(loop) return loop * 2);
    var report = suite.run();
    // trace(report.toString());
    Assert.pass();
  }

  public function testSpeedCase() {
    var test = new SpeedCase(SpeedCaseBuilder.create(function() {
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

  public function testMapsGetSet() {
    var suite = new Suite(2, 5000);

    suite.add('mutable map', function() {
      var map : MuMap<String, Int> = new MuMap();
      var result = 0;
      var key : String = null;
      @:measure {
        key = '${Math.random()}';
        map.set(key, 42);
        result = map.get(key);
      }
      if (result != 42) throw 'expected 42';
    });

    suite.add('immutable map', function() {
      var map : ImMap<String, Int> = ImMap.empty();
      var result = 0;
      var key : String = null;
      @:measure {
        key = '${Math.random()}';
        map = map.set(key, 42);
        result = switch map.get(key) {
          case Some(value) : value;
          case None : throw 'expected value for key $key';
        };
      }
      if (result != 42) throw 'expected 42';
    });

    var report = suite.run();
    trace(report.toString());
    Assert.pass();
  }
}
