package thx.benchmark.speed;

using thx.core.Arrays;
using thx.core.Ints;
using thx.core.Strings;

class SpeedSuiteSummary {
  var list : Array<{ description : String, summary : SpeedTestSummary }>;
  public function new(list : Array<{ description : String, summary : SpeedTestSummary }>) {
    this.list = list;
  }

  public function toString() {
    var sub = "=".repeat(list.reduce(function(acc, item) {
                return item.description.length.max(acc);
              }, 0));
    return list.map(function(item) {
      return '${item.description}
$sub

${indent(item.summary.toString().trim())}
';
    }).join("\n");
  }

  public static function indent(s : String)
    return s.split("\n").pluck(_.length == 0 ? "" : '  $_').join("\n");
}