package thx.benchmark.measure;

class Stopwatch {
  public static function go() {
    var inst = new Stopwatch();
    inst.start();
    return inst;
  }

/**
Elapsed time in milliseconds.
*/
  public var elapsed(get, null) : Float;

/**
Elapsed time in seconds.
*/
  public var elapsedSeconds(get, null) : Float;

  public var isRunning(default, null) : Bool;

  var _elapsed : Float;
  var startTime : Float;
  var endTime : Null<Float>;
  var endTemp : Float;
  var timer : Void -> Float;
  public function new(?timer : Void -> Float) {
    this.timer = null == timer ? thx.Timer.time : timer;
    _elapsed = 0;
    isRunning = false;
  }

  public function start() {
    if(isRunning) return;
    isRunning = true;
    startTime = timer();
  }

  public function stop() {
    endTemp = timer();
    if(!isRunning) return;
    endTime = endTemp;
    isRunning = false;
    _elapsed += endTime - startTime;
  }

  public function reset() {
    _elapsed = 0;
  }

  public function restart() {
    reset();
    start();
  }

  function get_elapsed()
    return _elapsed + (isRunning ? timer() - startTime : 0);


  function get_elapsedSeconds()
    return elapsed / 1000;
}
