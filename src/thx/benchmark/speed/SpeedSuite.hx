package thx.benchmark.speed;

class SpeedSuite {
  var tests : Array<{ description : String, test : SpeedTest, repetitions : Null<Int> }>;
  public function new() {
    tests = [];
  }

  public function addTest(description : String, test : SpeedTest, ?repetitions : Int) {
    tests.push({
      description : description,
      test : test,
      repetitions : repetitions
    });
  }

  public function execute(callback : SpeedSuiteSummary -> Void) {
    var collect = [],
        index = 0;
    function loop() {
      if(index == tests.length) {
        callback(new SpeedSuiteSummary(collect));
      } else {
        var item = tests[index++];
        item.test.execute(item.repetitions, function(summary) {
          collect.push({
            description : item.description,
            summary : summary
          });
          loop();
        });
      }
    }
    loop();
  }

  public function run() {
    execute(function(summary) {
      trace(summary.toString());
    });
  }
}