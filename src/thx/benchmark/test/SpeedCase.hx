package thx.benchmark.test;

import haxe.macro.Context;
import haxe.macro.Expr;

class SpeedCase {
  macro public static function create(test : ExprOf<Class<ISpeedCase>>) : ExprOf<ISpeedTest> {
    var id = switch test.expr {
                case EConst(CIdent(id)): id;
                case _: Context.error('invalid expression $test', Context.currentPos());
              },
        cls = '${id}_SpeedTest';
    trace(cls);
    return macro ($i{cls}.new)(); // TODO, there must be a better way
  }
}
