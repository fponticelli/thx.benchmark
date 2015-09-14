package thx.benchmark.test.macro;

using thx.Arrays;
using thx.macro.MacroFields;
using thx.macro.MacroTypes;
using thx.macro.MacroClassTypes;
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;

class SpeedSuiteBuilder {
  public static function build() {
    var cls = Context.getLocalClass().get(),
        fields = Context.getBuildFields();

    return fields;
  }
}
