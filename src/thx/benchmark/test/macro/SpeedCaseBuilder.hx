package thx.benchmark.test.macro;

using thx.Arrays;
using thx.macro.MacroFields;
using thx.macro.MacroTypes;
using thx.macro.MacroClassTypes;
using thx.macro.MacroExprs;
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;

class SpeedCaseBuilder {
  public static function build() {
    var cls = Context.getLocalClass().get(),
        fields = Context.getBuildFields();

    ensureDescription(cls, fields);

    // constructor
    ensureEmptyFunction(cls, fields, "new");

    ensureEmptyFunction(cls, fields, "setup");
    ensureEmptyFunction(cls, fields, "test");
    ensureEmptyFunction(cls, fields, "teardown");

    // construct sub-type
    constructSubType(cls, fields);
    return fields;
  }

  static function extractExpression(kind : FieldType) {
    return switch kind {
      case FVar(_, e): e;
      case FFun(f): f.expr;
      case FProp(_, _, _, e): e;
    };
  }

  static function constructSubType(cls : ClassType, fields : Array<Field>) {
    var description = fields.find(function(field) return field.name == "description");
    $type(description.kind);
    var descriptionExpression = extractExpression(description.kind);
    var setup = fields.find(function(field) return field.name == "setup");
    var setupExpression = extractExpression(setup.kind);
    var teardown = fields.find(function(field) return field.name == "teardown");
    var teardownExpression = extractExpression(teardown.kind);
    var test = fields.find(function(field) return field.name == "test");
    var testExpression = extractExpression(test.kind);

    var loopExpression = macro {
      var start, end, span;
      start = thx.Timer.time();
      while(--loop >= 0)
        $e{testExpression}
      end = thx.Timer.time();
      span = end - start;
    };
    var closingExpression = macro return span;
    var testSpeedExpressions = [
          setupExpression.unwrapBlock(),
          loopExpression.unwrapBlock(),
          teardownExpression.unwrapBlock(),
          [closingExpression]
        ].flatten();
    trace(haxe.macro.ExprTools.toString(macro $b{testSpeedExpressions}));
    var fields = [{
      pos: cls.pos,
      name: "description",
      kind: FVar(macro : String, descriptionExpression),
      access: [APublic],
    }, {
      pos: cls.pos,
      name: "testSpeed",
      kind: FFun({
        ret : macro : Float,
        expr : macro $b{testSpeedExpressions},
        args : [{name : "counter", type : macro : Int}]
      }),
      access: [APublic],
    }];
    var interfaces = [{ pack : ["thx","benchmark","test"], name : "ISpeedTest" }];
    var typeDefinition = {
      pos: cls.pos,
      params: null,
      pack: cls.pack,
      name: '${cls.name}_SpeedTest',
      meta: null,
      kind: TDClass(null, interfaces, false),
      isExtern: false,
      fields: fields
    };
    Context.defineType(typeDefinition);
  }

  static function ensureDescription(cls : ClassType, fields : Array<Field>) {
    var field = cls.fieldsInHierarchy().find(function(field) return field.name == "description");
    if(null != field) {
      ensureClassFieldIsPublic(field);
      return;
    }
    var field = fields.find(function(field) return field.name == "description");
    if(null == field) {
      var description = thx.Strings.humanize(cls.name);
      field = {
        pos : Context.getLocalClass().get().pos,
        name : "description",
        access : [APublic],
        kind : FVar(
          macro : String,
          macro $v{description}
        )
      };
      fields.push(field);
    } else {
      ensureFieldIsPublic(field);
    }
  }

  static function ensureClassFieldIsPublic(field : ClassField) {
    //field.isPublic = true;
  }

  static function ensureFieldIsPublic(field : Field) {
    if(MacroFields.isPublic(field))
      return;
    field.access.push(APublic);
  }

  static function ensureEmptyFunction(cls : ClassType, fields : Array<Field>, name : String) {
    var field = cls.fieldsInHierarchy().find(function(field) return field.name == name);
    if(null != field) {
      ensureClassFieldIsPublic(field);
      return;
    }
    var field = fields.find(function(field) return field.name == name);
    if(null == field) {
      field = {
        pos : Context.getLocalClass().get().pos,
        name : name,
        access : [APublic],
        kind : FFun({
          ret : macro : Void,
          args : [],
          expr : macro {}
        })
      };
      fields.push(field);
    } else {
      ensureFieldIsPublic(field);
    }
  }
}
