package thx.benchmark.speed;

using thx.Floats;
using thx.Strings;

class SpeedResult {
  public var index : Int;
  public var isReference : Bool;
  public var description : String;
  public var time : Float = 0.0;
  public function new(index : Int, description : String, isReference : Bool) {
    this.index = index;
    this.description = description;
    this.isReference = isReference;
  };

  public function toString() {
    return '${isReference ? "* " : "  "} $description: ${time.roundTo(1)}ms';
  }

  public function toStringComparison(descriptionLen : Int, reference : Float) {
    var des = description.rpad(".", descriptionLen),
        round = 1,
        delta = 1 - time / reference,
        per = ""+(delta * 100).roundTo(round),
        parts = per.split(".");
    if(1 == parts.length)
      parts[1] = "0".repeat(round);
    else
      parts[1] = parts[1].rpad("0", round);

    per = parts.join(".") +"%";
    per = delta < 0 ? per : '+$per';
    return '${isReference ? "* " : "  "}$des..: ${(reference == time ? "- " : per).lpad(" ", 8)} (${time.roundTo(1)}ms)';
  }
}