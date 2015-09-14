import utest.UTest;
import utest.Assert;
import ForVsMap;

class TestAll {
  public static function main() {
    UTest.run([new TestAll()]);
  }

  public function new() {}

  public function testBase() {
    var f = new For();

  }
}
