#!/bin/sh
set -e
rspec spec/unit
rspec spec/integration
for file in spec/acceptance/*_spec.rb; do
  line_numbers=$(cat ${file} | grep -En "^ *it " | cut -d: -f1)
  for line_number in $line_numbers; do
    rspec "${file}:${line_number}"
  done
done
