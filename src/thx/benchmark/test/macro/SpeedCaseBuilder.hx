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

  static function getFieldExpression(name : String, fields : Array<Field>) {
    var field = fields.find(function(field) return field.name == name);
    return extractExpression(field.kind);
  }

  static function constructSubType(cls : ClassType, fields : Array<Field>) {
    var usings = Context.getLocalUsing(),
        imports = Context.getLocalImports();
    var descriptionExpression = getFieldExpression("description", fields);
    var setupExpression = getFieldExpression("setup", fields);
    var teardownExpression = getFieldExpression("teardown", fields);
    var testExpression = getFieldExpression("test", fields);

    // TODO locals are missing
    var remaining = fields.filter(function(field) return !["description", "setup", "teardown", "test"].contains(field.name));
    trace(remaining.map(function(field) return field.name));

    var loopExpression = macro {
      var start, end, span;
      start = thx.Timer.time();
      while(--counter >= 0)
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
    var fields = remaining.concat([{
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
    }]);
    var interfaces = [{ pack : ["thx","benchmark","test"], name : "ISpeedTest" }];
    var clsName = '${cls.name}_SpeedTest';
    var typeDefinition = {
      pos: cls.pos,
      params: null,
      pack: cls.pack,
      name: clsName,
      meta: null,
      kind: TDClass(null, interfaces, false),
      isExtern: false,
      fields: fields
    };
    var modulePath = cls.pack.concat([clsName]).join(".");
    Context.defineModule(modulePath, [typeDefinition], imports, usings.map(function(use) {
      var cls = use.get(),
          parts = cls.module.split("."),
          name = parts.pop();
      return {
        sub : null,
        params : null,
        pack : parts,
        name : name
      };
    }));
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
