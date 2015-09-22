package thx.benchmark.test;

class Suite {
  var tests : Array<TestCase>;
  public function new() {
    tests = [];
  }

  macro public function add(description : String, f : Expr) {

  }
}
