#!/bin/sh
rm thx.benchmark.zip
zip -r thx.benchmark.zip hxml src test doc/ImportBenchmark.hx extraParams.hxml haxelib.json README.md
haxelib submit thx.benchmark.zip