package thx.benchmark.speed;

using thx.core.Arrays;
using thx.core.Floats;

class SpeedTestSummary {
  public var repetitions : Int;
  public var totalTime : Float;
  public var results : Array<SpeedResult>;
  public function new(repetitions : Int, totalTime : Float, results : Array<SpeedResult>) {
    this.repetitions = repetitions;
    this.totalTime = totalTime;
    this.results = results;

    sortAndEndureReference();
  }

  function sortAndEndureReference() {
    if(results.filterPluck(_.isReference).length == 0) {
      results.sort(function(a, b) {
        return a.time.compare(b.time);
      });
      results[0].isReference = true;
    }
    results.sort(function(a, b) {
      return a.index.compare(b.index);
    });
  }

  public function toString() {
    return '
repetitions: $repetitions
total time: ${totalTime.roundTo(2)}ms

${results.pluck(_.toString()).join("\n")}
';
  }
}