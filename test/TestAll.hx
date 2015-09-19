import utest.UTest;
import utest.Assert;
// import ForVsMap;
// import thx.benchmark.test.SpeedCase;
import thx.benchmark.test.macro.SpeedCaseBuilder;


class TestAll {
  public static function main() {
    UTest.run([new TestAll()]);
  }

  public function new() {}

  // public function testBase() {
  //   var test = SpeedCase.create(For);
  //   trace(test.description);
  //   trace(test.testSpeed(10000));
  //
  //   var test = SpeedCase.create(TestMap);
  //   trace(test.description);
  //   trace(test.testSpeed(10000));
  //
  //   var test = SpeedCase.create(Reduce);
  //   trace(test.description);
  //   trace(test.testSpeed(10000));
  // }

  public function testFunctionBuilder() {
    SpeedCaseBuilder.create(function() {
      var result;
      @:measure result = 1;
      if(result == 0)
        throw 'invalid value returned';
    });

    SpeedCaseBuilder.create(function() : Void {
      var result;
      @:measure result = 1;
      if(result == 0)
        throw 'invalid value returned';
    });
  }
}
