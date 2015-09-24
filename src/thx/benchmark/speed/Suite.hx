package thx.benchmark.speed;

#if macro
import haxe.macro.Expr;
#else
using thx.OrderedMap;
#end

class Suite {
#if !macro
  var tests : OrderedMap<String, SpeedCase>;
  public var maxExecutionTime : Float;
  public var minSamples : Int;
  public function new(?minSamples : Int = 5, ?maxExecutionTime : Float = 5000.0) {
    tests = OrderedMap.createString();
    this.maxExecutionTime = maxExecutionTime;
    this.minSamples = minSamples;
  }

  public function addCase(description : String, f : Int -> Float) {
    tests.set(description, new SpeedCase(f));
  }

  public function run() {
    var map = OrderedMap.createString();
    for(k in tests.keys()) {
      var test = tests.get(k);
      var stats = test.run(minSamples, maxExecutionTime);
      map.set(k, stats);
    }
    return new SuiteReport(map);
  }
#end

  macro public function add(ethis : Expr, description : String, f : ExprOf<haxe.Constraints.Function>) {
    var t = thx.benchmark.speed.macro.SpeedCaseBuilder.createF(f);
    return macro $ethis.addCase($v{description}, $t);
  }
}
