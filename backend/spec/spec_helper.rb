require 'simplecov'

SimpleCov.minimum_coverage 95

SimpleCov.start do
  add_filter do |src|
    src.filename =~ /.*_spec.rb$/
  end
end
