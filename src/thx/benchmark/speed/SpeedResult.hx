package thx.benchmark.speed;

using thx.core.Floats;

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
    return '$description${isReference ? " (reference)" : ""}: ${time.roundTo(3)}ms';
  }
}