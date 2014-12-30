package thx.benchmark;

using thx.core.Arrays;
using thx.core.Floats;
using thx.core.Functions;
using thx.core.Ints;
using thx.core.Iterators;
import thx.core.Timer;


interface ISpeedCase {
  public var description(default, null) : String;
  public function test(repetitions : Int, done : Void -> Void) : Void;
}

class SpeedCase implements ISpeedCase {
  public var description(default, null) : String;
  var _test : Int -> (Void -> Void) -> Void;

  public function new(description : String, test : Int -> (Void -> Void) -> Void) {
    this.description = description;
    this._test = test;
  }
  public function test(repetitions : Int, done : Void -> Void) {
    _test(repetitions, done);
  }
}

class SpeedResult {
  public var index : Int;
  public var isReference : Bool;
  public var description : String;
  public var time : Float = 0.0;
  public function new(index : Int, description : String, isReference : Bool) {
    this.index = index;
    this.description = description;
    this.isReference = isReference;
  };

  public function toString() {
    return '$description${isReference ? " (reference)" : ""}: ${time.roundTo(3)}ms';
  }
}

class SpeedSummary {
  public var repetitions : Int;
  public var totalTime : Float;
  public var results : Array<SpeedResult>;
  public function new(repetitions : Int, totalTime : Float, results : Array<SpeedResult>) {
    this.repetitions = repetitions;
    this.totalTime = totalTime;
    this.results = results;

    sortAndEndureReference();
  }

  function sortAndEndureReference() {
    if(results.filterPluck(_.isReference).length == 0) {
      results.sort(function(a, b) {
        return a.time.compare(b.time);
      });
      results[0].isReference = true;
    }
    results.sort(function(a, b) {
      return a.index.compare(b.index);
    });
  }

  public function toString() {
    return '
repetitions: $repetitions
total time: ${totalTime.roundTo(2)}ms

${results.pluck(_.toString()).join("\n")}
';
  }
}

class SpeedTest {
  var cases : Map<ISpeedCase, SpeedResult>;
  var reference : ISpeedCase;
  var index = 0;
  public function new() {
    cases = new Map();
  }

  public function addCase(test : ISpeedCase, isReference = false) {
    if(isReference && null != reference) throw 'reference already set to ${reference.description}';
    cases.set(test, new SpeedResult(index++, test.description, false));
  }

  public function add(description : String, test : Void -> Void, ?isReference = false)
    addAsync(
      description,
      function(repetitions, done) {
        for(i in 0...repetitions)
          test();
        done();
      },
      isReference
    );

  public function addAsync(description : String, test : Int -> (Void -> Void) -> Void, ?before : Void -> Void, ?after : Void -> Void, ?isReference = false)
    addCase(
      new SpeedCase(
        description,
        test
      ),
      isReference);

  public function execute(repetitions = 100000, callback : SpeedSummary -> Void) {
    var overallStart = Timer.time();
    function done() {
      var delta = Timer.time() - overallStart;
      var results = cases.iterator().toArray();
      callback(new SpeedSummary(repetitions, delta, results));
    }
    function loop() {
      // collect randomized test sequence
      var tests = cases.keys().toArray().shuffle();
      function test() {
        if(tests.length == 0) {
          done();
        } else {
          var t = tests.shift(),
              start = Timer.time();
          t.test(repetitions, function() {
            var delta = Timer.time() - start;
            cases.get(t).time = delta;
            test();
          });
        }
      }
      test();
    }

    loop();
  }
}

/*
class SpeedTest2 {
  public function new(repetitions = 100000, testDelay = 0, averages = 5) {
    this.testDelay = testDelay;
    this.averages = averages;
    this.repetitions = repetitions;
    this.tests = [];
    this.descriptions = [];
    this.reference = -1;
  }

  public function addLoop(description : String, f : Int -> Void, isReference = false) {
    if(isReference && reference >= 0)
      throw 'reference is already set to "${descriptions[reference]}"';
    descriptions.push(description);
    if(isReference)
      reference = tests.length;
    tests.push(f);
    return this;
  }

  public function add(description : String, f : Void -> Void, isReference = false)
    return addLoop(description, function(tot) for(i in 0...tot) f(), isReference);

  public function execute(?handler : String -> Void) {
    this.handler = handler;
    if (null == this.handler)
      this.handler = function(s) trace("\n" + s);
    results = [];
    for (i in 0...tests.length)
      results[i] = 0.0;
    toPerform = averages;
    start = getTimer();
    handleRound();
  }

  var reference : Int;
  var testDelay : Int;
  var averages : Int;
  var repetitions : Int;
  var tests : Array<Int -> Void> ;
  var descriptions : Array<String>;
  var results : Array<Float>;
  var toPerform : Int;
  var handler : String -> Void;
  var start : Float;

  function test(f : Int -> Void) {
    var start = getTimer();
    f(repetitions);
    return getTimer() - start;
  }

  static inline function getTimer() : Float
#if flash
    return flash.Lib.getTimer();
#elseif php
    return php.Sys.cpuTime() * 1000;
#elseif neko
    return neko.Sys.cpuTime() * 1000;
#elseif cpp
    return cpp.Sys.cpuTime() * 1000;
#else
    return Date.now().getTime();
#end

  function takeRound() {
    var indexes = Arrays.shuffle(Ints.range(0, tests.length));
    for (i in indexes)
      results[i] += test(tests[i]);
    handleRound();
  }

  function handleRound() {
    toPerform--;
    if (toPerform >= 0)
#if (flash || js)
      if(testDelay > 0)
        Timer.delay(takeRound, testDelay);
      else
        takeRound();
#else
      takeRound();
#end
    else
      handler(getOutput());
  }

  function getOutput() {
    var total = getTimer() - start;
    var sl = 0;
    var slowest = -1.0;
    var bd = 0;
    var ad = 0;
    var r = [];
    var sep = '.';
    for (i in 0...descriptions.length) {
      var d = descriptions[i];
      if (d.length > sl)
        sl = d.length;
      if (slowest < 0 || slowest > results[i])
        slowest = results[i];

      var v = formatDecimal(results[i] / averages, 1);
      var n = (v).split(sep);
      if (bd < n[0].length)
        bd = n[0].length;
      r.push(n);
    }
    sl += 3;
    var s = new StringBuf();
    s.add("test repeated " + repetitions + " time(s), average on " + averages + " cycle(s)\n\n");

    if (reference >= 0)
      slowest = results[reference];

    for (i in 0...descriptions.length) {
      var d = descriptions[i];
      s.add(StringTools.rpad(d, ".", sl));
      s.add(": ");

      s.add(StringTools.lpad(r[i][0], " ", bd));
      s.add(".");
      s.add(r[i][1]);

      s.add(" ms. ");
      if (reference < 0) {
        s.add(formatPercent(Math.round(100 * slowest / results[i])));
      } else if (reference == i) {
        s.add("        reference");
      } else {
        var v = Math.round(100 * slowest / results[i]);
        if (v < 100)
          s.add("(" + StringTools.lpad(formatPercentInt(100-v), " ", 5) + ") slower");
        else if(v == 100)
          s.add("        same");
        else
          s.add(" " + StringTools.lpad(formatPercentInt(v-100), " ", 5) + "  faster");
      }
      s.add("\n");
    }
    s.add("\n");
    s.add("total execution time: " + formatInt(total) + " ms.");
    return s.toString();
  }

  static function formatInt(v : Float)
    return '' + Math.round(v);

  static function formatPercentInt(v : Float)
    return formatInt(v) + '%';

  static function formatPercent(v : Float)
    return formatDecimal(v, 2) + '%';

  static function formatDecimal(v : Float, decimals = 2) {
    var p = Math.pow(10, decimals),
      s = '' + Math.round(v * p) / p;
    if(s.indexOf('.') < 0)
      s += '.' + StringTools.lpad('', '0', decimals);
    return s;
  }
}
*/