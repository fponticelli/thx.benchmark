import thx.benchmark.speed.*;

class MapVsNativeMap {
  public static function main() {
    var suite = new Suite(10, 2500),
        test = [1,2,4,8,16,32,64,128,256,512,1024];
    suite.add("native map", function() {
      var t = null;
      @:measure { t = test.map(double); };
      if(t.length != test.length && t[0] != 2)
        throw 'unexpected result $t';
    });
    suite.add("static map", function() {
      var t = null;
      @:measure { t = map(test, double); };
      if(t.length != test.length && t[0] != 2)
        throw 'unexpected result $t';
    });
    trace(suite.run().toString());
  }

  static function double(v : Int)
    return v * 2;

  public static function map<A, B>(arr : Array<A>, f : A -> B) : Array<B> {
    var result = [];
    for(v in arr)
      result.push(f(v));
    return result;
  }
}
