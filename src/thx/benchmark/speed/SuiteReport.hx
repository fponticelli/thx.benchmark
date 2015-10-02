package thx.benchmark.speed;

import thx.OrderedMap;
using thx.Arrays;
using thx.Floats;
using thx.Ints;
using thx.Strings;
using thx.format.Format;
using thx.format.NumberFormat;

class SuiteReport {
  var tests : OrderedMap<String, Stats>;
  public function new(tests : OrderedMap<String, Stats>) {
    this.tests = tests;
  }

  public function toString() {
    var max = Math.NEGATIVE_INFINITY,
        min = Math.NEGATIVE_INFINITY,
        cols = [0, 0, 0, 0, 0],
        align = [true, false, false, false, false],
        values = [];
    for(k in tests.keys()) {
      var test = tests.get(k);
      max = test.cycles.max(max);
      min = test.cycles.min(min);
      var cycles =  if(test.cycles >= 100)
                      test.cycles.number(0)
                    else if(test.cycles > 10)
                      test.cycles.number(1)
                    else if(test.cycles > 1)
                      test.cycles.number(2)
                    else if(test.cycles > 0.1)
                      test.cycles.number(3)
                    else if(test.cycles > 0.01)
                      test.cycles.number(4)
                    else if(test.cycles > 0.001)
                      test.cycles.number(5)
                    else if(test.cycles > 0.0001)
                      test.cycles.number(6)
                    else if(test.cycles > 0.00001)
                      test.cycles.number(7)
                    else
                      test.cycles.number(8)
                    ;
      var row = [
        k,
        cycles,
        test.relativeMarginOfError.f("±0.00%"),
        test.size.f("#,##0")
      ];
      values.push(row);
    }
    var counter = 0;

    function percent(cycles : Float) {
      return (1 - cycles / max).f("0%");
    }

    for(k in tests.keys()) {
      var row = values[counter],
          test = tests.get(k);

      if(test.cycles == max) {
        row.push('fastest');
      } else {
        row.push('${percent(test.cycles)} slower');
      }

      counter++;
    }

    values.insert(0, ["description","ops/sec", "error", "samples", "performance"]);
    values.insert(1, ["","","","",""]);

    for(row in values) {
      for(i in 0...5)
        cols[i] = row[i].length.max(cols[i]);
    }

    var vb = "┃",
        hb = "━";

    return "\n" + values.map(function(row) {
      return vb + row.mapi(function(cell, i) {
        if(cell == "")
          return "".rpad(hb, cols[i] + 2);
        else if(align[i])
          return " " + cell.rpad(" ", cols[i]) + " ";
        else
          return " " + cell.lpad(" ", cols[i]) + " ";
      }).join(vb) + vb;
    }).join("\n");
  }
}
