package thx.benchmark.speed;

using thx.core.Arrays;
using thx.core.Iterators;
import thx.core.Timer;

class SpeedTest {
  var cases : Map<ISpeedCase, SpeedResult>;
  var reference : ISpeedCase;
  var index = 0;
  public function new() {
    cases = new Map();
  }

  public function addCase(test : ISpeedCase, isReference = false) {
    if(isReference && null != reference) throw 'reference already set to ${reference.description}';
    cases.set(test, new SpeedResult(index++, test.description, isReference));
  }

  public function add(description : String, test : Void -> Void, ?isReference = false)
    addAsync(
      description,
      function(repetitions, done) {
        for(i in 0...repetitions)
          test();
        done();
      },
      isReference
    );

  public function addAsync(description : String, test : Int -> (Void -> Void) -> Void, ?before : Void -> Void, ?after : Void -> Void, ?isReference = false)
    addCase(
      new SpeedCase(
        description,
        test
      ),
      isReference);

  public function execute(repetitions = 100000, callback : SpeedTestSummary -> Void) {
    var overallStart = Timer.time();
    function done() {
      var delta = Timer.time() - overallStart;
      var results = cases.iterator().toArray();
      callback(new SpeedTestSummary(repetitions, delta, results));
    }
    function loop() {
      // collect randomized test sequence
      var tests = cases.keys().toArray().shuffle();
      function test() {
        if(tests.length == 0) {
          done();
        } else {
          var t = tests.shift(),
              start = Timer.time();
          t.test(repetitions, function() {
            var delta = Timer.time() - start;
            cases.get(t).time = delta;
            test();
          });
        }
      }
      test();
    }
    loop();
  }

  public function run(?repetitions : Int)
    execute(repetitions, function(summary) {
      trace(summary.toString());
    });
}