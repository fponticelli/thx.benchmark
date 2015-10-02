import thx.benchmark.speed.*;

class RGB {
  public var r:Int;
  public var g:Int;
  public var b:Int;

  public function new(inR:Int, inG:Int, inB:Int) {
    r = inR;
    g = inG;
    b = inB;
  }
}

class Complex {
  public var i:Float;
  public var j:Float;

  public function new(inI:Float, inJ:Float) {
    i = inI;
    j = inJ;
  }
}

class Demo {
  static inline var MaxIterations = 100;
  static inline var MaxRad = 1<<16;
  static inline var width = 35;
  static inline var height = 20;

  public static function main() {
    var stats = SpeedCase.execute(function() {
      var palette = [],
          image = [];
      @:measure {
        for(i in 0...MaxIterations+1)
          palette.push(createPalette(i/MaxIterations));

        var outPixel = 0;
        var scale = 0.1;
        for(y in 0...height) {
          for(x in 0...width) {
            var offset = new Complex(x*scale - 2.5,y*scale - 1);
            var val = new Complex(0.0,0.0);
            var iteration = 0;
            while(complexLength2(val)<MaxRad && iteration<MaxIterations) {
              val = complexAdd(complexSquare(val), offset );
              iteration++;
            }
            image[outPixel++] = palette[iteration];
          }
        }
      };
    });
    trace(stats.toString());
  }

  public static function complexLength2(val:Complex) : Float
    return val.i*val.i + val.j*val.j;

  public static function complexAdd(val0:Complex, val1:Complex)
    return new Complex(val0.i + val1.i, val0.j + val1.j);

  public static function complexSquare(val:Complex)
    return new Complex(val.i*val.i - val.j*val.j, 2.0 * val.i * val.j);

  inline public static function createPalette(inFraction:Float) {
    var r = Std.int(inFraction*255);
    var g = Std.int((1-inFraction)*255);
    var b = Std.int((0.5-Math.abs(inFraction-0.5))*2*255 );
    return new RGB(r,g,b);
  }
}
