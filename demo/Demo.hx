import thx.benchmark.test.*;

class Demo {
  public static function main() {
    var suite = new Suite(10, 2500);
    suite.add("multiplication", function() {
      var t = 1.2;
      @:measure { t = t * 3.0; };
      if(t < 0)
        throw 'unexpected result';
    });
    suite.add("division", function() {
      var t = 1.2;
      @:measure { t = t / 3.0; };
      if(t < 0)
        throw 'unexpected result';
    });
    suite.add("sum", function() {
      var t = 1.2;
      @:measure { t = t + 3.0; };
      if(t < 0)
        throw 'unexpected result';
    });
    suite.add("subtraction", function() {
      var t = -1.2;
      @:measure { t = t - 3.0; };
      if(t > 0)
        throw 'unexpected result';
    });
    suite.add("modulo", function() {
      var t = 1.2;
      @:measure { t = t % 3.0; };
      if(t < 0)
        throw 'unexpected result';
    });
    trace(suite.run().toString());
  }
}
