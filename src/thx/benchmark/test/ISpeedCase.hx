package thx.benchmark.test;

@:autoBuild(thx.benchmark.test.macro.SpeedCaseBuilder.build())
interface ISpeedCase {
  public var description : String;
  public function setup() : Void;
  public function teardown() : Void;
  public function test() : Void;
}
