using thx.Arrays;

class For extends BaseForVsMap implements thx.benchmark.test.ISpeedCase {
  function test() {
    var result = 0;
    for(v in arr)
      result += v;
    value = result;
  }
}

class TestMap extends BaseForVsMap implements thx.benchmark.test.ISpeedCase {
  var description = "map";
  function test() {
    var result = 0;
    arr.map(function(v) result += v);
    value = result;
  }
}

class Reduce extends BaseForVsMap implements thx.benchmark.test.ISpeedCase {
  function test() {
    value = arr.reduce(function(acc, v) return acc + v, 0);
  }
}

class BaseForVsMap {
  var arr : Array<Int>;
  var value : Int;
  public function setup() {
    arr = [for(i in 0...10000) i % 100];
  }

  public function teardown() {
    if(value < 0)
      throw 'invalid value returned';
  }
}

// suite
class ForVsMap implements thx.benchmark.test.ISpeedSuite {
  var arr : Array<Int>;
  var value : Int;
  @:setup
  public function setup() {
    arr = [for(i in 0...10000) i % 100];
  }

  @:teardown
  public function teardown() {
    if(value < 0)
      throw 'invalid value returned';
  }

  @:test
  @:description("for")
  function testFor() {
    var result = 0;
    for(v in arr)
      result += v;
    value = result;
  }

  @:test
  function map() {
    var result = 0;
    arr.map(function(v) result += v);
    value = result;
  }

  @:test
  function reduce() {
    value = arr.reduce(function(acc, v) return acc + v, 0);
  }
}
