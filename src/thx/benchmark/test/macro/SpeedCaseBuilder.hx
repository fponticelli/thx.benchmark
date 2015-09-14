package thx.benchmark.test.macro;

using thx.Arrays;
using thx.macro.MacroFields;
using thx.macro.MacroTypes;
using thx.macro.MacroClassTypes;
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

    return fields;
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
