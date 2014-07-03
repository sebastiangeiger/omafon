#!/bin/sh
set -e
rspec --format documentation spec/unit
rspec --format documentation spec/integration
for file in spec/acceptance/*_spec.rb; do
  line_numbers=$(cat ${file} | grep -En "^ *it " | cut -d: -f1)
  for line_number in $line_numbers; do
    rspec --format documentation "${file}:${line_number}"
  done
done
