package thx.benchmark.speed;

class SpeedCase implements ISpeedCase {
  public var description(default, null) : String;
  var _test : Int -> (Void -> Void) -> Void;

  public function new(description : String, test : Int -> (Void -> Void) -> Void) {
    this.description = description;
    this._test = test;
  }
  public function test(repetitions : Int, done : Void -> Void) {
    _test(repetitions, done);
  }
}