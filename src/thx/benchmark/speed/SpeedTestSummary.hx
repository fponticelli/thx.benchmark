package thx.benchmark.speed;

using thx.Arrays;
using thx.Floats;
using thx.Functions;
using thx.Ints;

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
    if(results.filter.fn(_.isReference).length == 0) {
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
    var referenceTime = results.find(function(item) return item.isReference).time,
        descriptionLength = results.reduce(function(acc : Int, item : SpeedResult) : Int {
            return acc.max(item.description.length);
          }, 0),
        fastest = results.reducei(function(acc, item, i) {
            if(acc < 0 || results[acc].time > item.time)
              return i;
            return acc;
          }, -1),
        slowest = results.reducei(function(acc, item, i) {
            if(acc < 0 || results[acc].time < item.time)
              return i;
            return acc;
          }, -1);

    return '
repetitions..: $repetitions
total time...: ${totalTime.roundTo(2)}ms

${results.mapi.fn((_1 == fastest ? "+ " : _1 == slowest ? "- " : "  ") + _.toStringComparison(descriptionLength, referenceTime)).join("\n")}
';
  }
}
