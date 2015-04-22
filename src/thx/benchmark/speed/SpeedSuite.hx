package thx.benchmark.speed;

using thx.Arrays;
using thx.Floats;
using thx.Timer;

class SpeedSuite {
  var tests : Array<{ description : String, test : SpeedTest, repetitions : Null<Int> }>;
  public function new() {
    tests = [];
  }

  public function addTest(description : String, test : SpeedTest, ?repetitions : Int) {
    tests.push({
      description : description,
      test : test,
      repetitions : repetitions
    });
  }

  public function execute(samples : Int = 1, ?outliers : Int, callback : SpeedSuiteSummary -> Void) {
    var collect = new Map(),
        index = 0,
        counter = 0;
    if(samples < 1)
      samples = 1;
    if(null == outliers || outliers * 2 >= samples) {
      outliers = (samples * 0.25).floor();
    }
    tests.pluck(collect.set(_, []));

    var loop = null;

    function sample() {
      if(index == tests.length) {
        index = 0;
        loop();
      } else {
        var item = tests[index++];
#if (js || flash)
//        Timer.delay(function() {
#end
          item.test.execute(item.repetitions, function(summary) {
            collect.get(item).push(summary);
            sample();
          });
#if (js || flash)
//        }, 100);
#end
      }
    }

    loop = function() {
      if(counter == samples) {
        var list = tests.pluck({
            description : _.description,
            summary : summaryAverage(collect.get(_), outliers)
          });
        callback(new SpeedSuiteSummary(list));
      } else {
        counter++;
        sample();
      }
    }

    loop();
  }

  static function summaryAverage(summaries : Array<SpeedTestSummary>, outliers : Int) {
    var repetitions = summaries[0].repetitions,
        totalTime = summaries.pluck(_.totalTime).average(),
        results = summaries
          .map(function(summary : SpeedTestSummary) {
            return summary.results.order(function(a, b) return a.index - b.index);
          })
          .rotate()
          .map(function(results) {
            results.sort(function(a, b) return a.time.compare(b.time));
            results = results.slice(outliers, results.length - outliers);
            // TODO we can collect more stats here
            var result = new SpeedResult(results[0].index, results[0].description, results[0].isReference);
            result.time = results.pluck(_.time).average();
            return result;
          });
    // TODO can provide more info here (number of sampling and outliers)
    return new SpeedTestSummary(repetitions, totalTime, summaries[0].results);
  }

  public function run() {
    execute(function(summary) {
      trace(summary.toString());
    });
  }
}