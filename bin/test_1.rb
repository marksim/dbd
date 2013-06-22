#!/usr/bin/env ruby

# This is a very primitive implementation:
# the CSV is first fully built and only then
# written to disk. Needs to be modified to
# stream to disk.

count = ARGV[0].to_i
unless count > 0
  puts "Give a 'count' as first argument."
  exit(1)
end

filename = ARGV[1]
unless filename.size > 0
  puts "Give a 'filename' as second argument."
  exit(1)
end

require 'dbd'
provenance_resource = Dbd::ProvenanceResource.new
provenance_resource << Dbd::ProvenanceFact.new(predicate: "prov:test" , object: "A" * 10)

resource = Dbd::Resource.new(provenance_subject: provenance_resource.subject)
(0...count).each do |i|
  resource << Dbd::Fact.new(predicate: "test" , object: "#{'B' * 100} #{i}")
end

graph = Dbd::Graph.new
graph << provenance_resource << resource

File.open(filename, 'w') do |f|
  f << graph.to_CSV
end
