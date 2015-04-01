#!/bin/sh
rm thx.benchmark.zip
zip -r thx.benchmark.zip hxml src test doc/ImportBenchmark.hx extraParams.hxml haxelib.json README.md -x "*/\.*"
haxelib submit thx.benchmark.zip
