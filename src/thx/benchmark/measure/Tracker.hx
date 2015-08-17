package thx.benchmark.measure;

using thx.Maps;

class Tracker {
  public static var instance(default, null) = new Tracker();

  inline public static function getTimer(name : String)
    return instance.get(name);

  inline public static function startTimer(name : String)
    return instance.start(name);

  inline public static function stopTimer(name : String)
    return instance.stop(name);

  inline public static function resetTimer(name : String)
    return instance.reset(name);

  inline public static function restartTimer(name : String)
    return instance.restart(name);

  inline public static function elapsedForTimer(name : String)
    return instance.elapsed(name);

  inline public static function elapsedSecondsForTimer(name : String)
    return instance.elapsedSeconds(name);

  inline public static function timers()
    return instance.iterator();

  var watches : Map<String, Stopwatch>;
  var timer : Void -> Float;
  public function new(?timer : Void -> Float) {
    this.timer = null == timer ? thx.Timer.time : timer;
    this.watches = new Map();
  }

  public function get(name : String)
    return watches.get(name);

  public function start(name : String)
    return ensureStopwatch(name).start();

  public function stop(name : String)
    return ensureStopwatch(name).stop();

  public function reset(name : String)
    return ensureStopwatch(name).reset();

  public function restart(name : String)
    return ensureStopwatch(name).restart();

  public function iterator()
    return watches.tuples();

  public function elapsed(name : String)
    return ensureStopwatch(name).elapsed;

  public function elapsedSeconds(name : String)
    return ensureStopwatch(name).elapsedSeconds;

  function ensureStopwatch(name : String) {
    if(!watches.exists(name))
      watches.set(name, new Stopwatch(timer));
    return watches.get(name);
  }
}
