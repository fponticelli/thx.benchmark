package thx.benchmark.speed.macro;

using thx.Arrays;
using thx.macro.MacroFields;
using thx.macro.MacroTypes;
using thx.macro.MacroClassTypes;
using thx.macro.MacroExprs;
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Context;

class SpeedCaseBuilder {
  macro public static function create(f : Expr) {
    return createF(f);
  }

#if macro
  public static function createF(f : Expr) {
    return switch f.expr {
      case EFunction(_, {
          args : [],
          ret  : null,
          expr : expr
        }), EFunction(_, {
          args : [],
          ret  : macro : Void,
          expr : expr
        }):
        return transformFunction(expr);
      case EFunction(_, {
          args : [{
            value : null,
            opt : false,
            type : macro : Int,
            name : _
          }],
          ret : macro : Float
        }):
        f;
      case other: Context.error('unexpected expression $other', f.pos);
    };
  }

  static function transformFunction(expr : Expr) {
    var setup = [],
        measure = null,
        teardown = [],
        phase = 0;
    ExprTools.iter(expr, function(e) {
      switch [e.expr, phase] {
      case [EMeta({ name : ":measure" }, e), 0]:
          measure = e;
          phase = 2;
        case [EMeta({ name : ":measure" }, _), _]:
          Context.error('@:measure can only be used once', e.pos);
        case [_, 0]: // setup
          setup.push(e);
        case [_, 1]: // measure
          phase = 2;
          measure = e;
        case [_, 2]: // teardown
          teardown.push(e);
        case [_, _]:
          Context.error('should never happen', e.pos);
      }
    });

    if(measure == null) {
      measure = expr;
      setup = [];
      teardown = [];
    }

    var exprs = [
      [macro var __timer__ = new thx.benchmark.measure.Stopwatch()],
      setup,
      [macro __timer__.start()],
      [macro while(--__counter__ >= 0.0) $e{measure}],
      [macro __timer__.stop()],
      teardown,
      [macro return __timer__.elapsed]
    ].flatten();

    return macro function(__counter__ : Int) : Float $b{exprs};
  }
#end
}
