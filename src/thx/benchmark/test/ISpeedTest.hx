package thx.benchmark.test;

interface ISpeedTest {
  public var description : String;
  public function testSpeed(iterations : Int) : Float;
}
