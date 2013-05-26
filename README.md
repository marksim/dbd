# Dbd: A data store that (almost) never forgets

This is facts based data store, inspired by [RDF] concepts, but adding a log based structure and fine-grained provenance.

* [Why?][Rationale]
* <http://github.com/petervandenabeele/dbd>

[![Gem Version](https://badge.fury.io/rb/dbd.png)](http://badge.fury.io/rb/dbd)
[![Build Status](https://travis-ci.org/petervandenabeele/dbd.png?branch=master)](http://travis-ci.org/petervandenabeele/dbd)

## Features

* Facts are immutable and ordered (log structured "fact stream")
  * "Big Data" mantra: base facts are immutable (store now, analyse later)
  * only 1 backup file needed: the fact stream contains the full history
  * synchronisation between remote sources is cheap (easy caching)
  * 1 data source has _all_ my data : never more loose stuff :-)
  * facts can be invalidated (and replaced) later on
* Privacy
  * a "hard delete" is possible: all downstream readers of the fact stream  
    must remove this fact and replace the back-up
  * since one single back-up file suffices, replacing the *single* back-up  
    file will actually remove the hard deleted fact(s) for good
* Fine grained Provenance
  * Each base Fact points to a ProvenanceResource, so separate provenance  
    possible for different facts about 1 resource
  * can keep the original_source reference, creator, date, …
  * can have a context that allows filtering data (e.g. private, professional, …)
  * separate encryption schemes per context are possible
  * ProvenanceResource is flexible, since built itself from Facts
* Schemaless
  * uses the [RDF] (subject, predicate, object) concepts
  * predicates, types can be defined in an ontology for declaring meaning
* Graph based
  * the object of each Fact can be another Resource
  * aimed at exporting to a graph database (e.g. Neo4j) for analysis


## License

Open Source [MIT]

## Installation

    $ gem install dbd      # Ruby 1.9.2, 1.9.3, 2.0.x, jruby (see .travis.yml)

## Examples

```
require 'dbd'

provenance = Dbd::ProvenanceResource.new

# PREFIX prov: <https://data.vandenabeele.com/ontologies/provenance#>
# PREFIX dcterms: <http://purl.org/dc/terms/>
fact_context_public  = Dbd::ProvenanceFact.new(predicate: "prov:context", object: "public")
fact_source_dbd      = Dbd::ProvenanceFact.new(predicate: "prov:source",  object: "http://github.com/petervandenabeele/dbd")
fact_creator_peter_v = Dbd::ProvenanceFact.new(predicate: "dcterms:creator", object: "@peter_v")
fact_created_now     = Dbd::ProvenanceFact.new(predicate: "dcterms:created", object: Time.now.utc)
provenance << fact_context_public
provenance << fact_source_dbd
provenance << fact_creator_peter_v
provenance << fact_created_now

nobel_peace_2012 = Dbd::Resource.new(provenance_subject: provenance.subject)

# PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
# PREFIX base: <https://data.vandenabeele.com/ontologies/base#>
fact_nobel_peace_2012 = Dbd::Fact.new(predicate: "base:nobelPeacePriceWinner", object: "2012")
fact_EU_label = Dbd::Fact.new(predicate: "rdfs:label", object: "EU") #  this will use some RDF predicates in future
fact_EU_comment = Dbd::Fact.new(predicate: "rdfs:comment", object: "European Union")
fact_EU_story = Dbd::Fact.new(predicate: "base:story", object: "A long period of peace,\n that is a \"bliss\".")
nobel_peace_2012 << fact_nobel_peace_2012
nobel_peace_2012 << fact_EU_label
nobel_peace_2012 << fact_EU_comment
nobel_peace_2012 << fact_EU_story

graph = Dbd::Graph.new

graph << provenance
graph << nobel_peace_2012

puts "facts in short representation:"
puts graph.map(&:short)
# [ prov ] : bbc2248e : prov:context             : public
# [ prov ] : bbc2248e : prov:source              : http://github.com/petervandenabeele/dbd
# [ prov ] : bbc2248e : dcterms:creator          : @peter_v
# [ prov ] : bbc2248e : dcterms:created          : 2013-05-26 22:01:50 UTC
# bbc2248e : 78edb900 : base:nobelPeacePriceWinn : 2012
# bbc2248e : 78edb900 : rdfs:label               : EU
# bbc2248e : 78edb900 : rdfs:comment             : European Union
# bbc2248e : 78edb900 : base:story               : A long period of peace,_ that is a "bliss".

puts "facts in full detail in CSV:"
puts graph.to_CSV
```

[RDF]:              http://www.w3.org/RDF/
[Rationale]:        http://github.com/petervandenabeele/dbd/blob/master/docs/rationale.md
[MIT]:              https://github.com/petervandenabeele/dbd/blob/master/LICENSE.txt
