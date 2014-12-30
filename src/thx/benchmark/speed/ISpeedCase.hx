package thx.benchmark.speed;

interface ISpeedCase {
  public var description(default, null) : String;
  public function test(repetitions : Int, done : Void -> Void) : Void;
}