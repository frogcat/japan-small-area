#!/usr/bin/env bash

s=cache/sac.json
if [ ! -e "${s}" ] ; then
curl -v -H 'Accept: application/sparql-results+json' --data-urlencode 'query@-' http://data.e-stat.go.jp/lod/sparql/alldata/query > ${s} << EOS
PREFIX rdfs:<http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms:<http://purl.org/dc/terms/>
PREFIX sacs:<http://data.e-stat.go.jp/lod/terms/sacs#>
select * where {
  ?s a sacs:StandardAreaCode ;
    rdfs:label ?label ;
    dcterms:identifier ?notation .
  optional { ?s dcterms:isPartOf ?parent}
  optional { ?s sacs:districtOfSubPrefecture ?gun. filter(lang(?gun)='ja') }
  optional { ?s dcterms:valid ?valid}
  filter (lang(?label)='ja')
} order by ?notation
EOS

fi

for code in `seq -w 1 1 47` ; do

g=cache/geom.${code}.json
h=cache/households.${code}.json
p=cache/population.${code}.json
j=docs/${code}.json

if [ ! -e "${g}" ] ; then
curl -v -H 'Accept: application/sparql-results+json' --data-urlencode 'query@-' http://data.e-stat.go.jp/lod/sparql/alldata/query > ${g} << EOS
PREFIX geo: <http://www.opengis.net/ont/geosparql#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ic: <http://imi.go.jp/ns/core/rdf#>
prefix sdmx-dimension: <http://purl.org/linked-data/sdmx/2009/dimension#>
prefix estat-measure: <http://data.e-stat.go.jp/lod/ontology/measure/>
prefix cd-dimension: <http://data.e-stat.go.jp/lod/ontology/crossDomain/dimension/>
PREFIX qb: <http://purl.org/linked-data/cube#>

select ?s ?wkt ?label ?parent where {
  ?s a <http://data.e-stat.go.jp/lod/terms/smallArea/SmallAreaCode> ; geo:hasGeometry/geo:asWKT ?wkt ; rdfs:label ?label ; dcterms:isPartOf ?parent.
  filter strstarts(str(?s),"http://data.e-stat.go.jp/lod/smallArea/g00200521/2015/S${code}") .
}
EOS

fi

if [ ! -e "${h}" ] ; then
curl -v -H 'Accept: application/sparql-results+json' --data-urlencode 'query@-' http://data.e-stat.go.jp/lod/sparql/alldata/query > ${h} << EOS
PREFIX geo: <http://www.opengis.net/ont/geosparql#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ic: <http://imi.go.jp/ns/core/rdf#>
prefix sdmx-dimension: <http://purl.org/linked-data/sdmx/2009/dimension#>
prefix estat-measure: <http://data.e-stat.go.jp/lod/ontology/measure/>
prefix cd-dimension: <http://data.e-stat.go.jp/lod/ontology/crossDomain/dimension/>
PREFIX qb: <http://purl.org/linked-data/cube#>

select ?s ?households where {
 ?x sdmx-dimension:refArea ?s .
 ?x qb:dataSet <http://data.e-stat.go.jp/lod/dataset/g00200521/ds012015002> .
 ?x estat-measure:households ?households.
filter strstarts(str(?s),"http://data.e-stat.go.jp/lod/smallArea/g00200521/2015/S${code}") .
}
EOS

fi

if [ ! -e "${p}" ] ; then
curl -v -H 'Accept: application/sparql-results+json' --data-urlencode 'query@-' http://data.e-stat.go.jp/lod/sparql/alldata/query > ${p} << EOS
PREFIX geo: <http://www.opengis.net/ont/geosparql#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ic: <http://imi.go.jp/ns/core/rdf#>
prefix sdmx-dimension: <http://purl.org/linked-data/sdmx/2009/dimension#>
prefix estat-measure: <http://data.e-stat.go.jp/lod/ontology/measure/>
prefix cd-dimension: <http://data.e-stat.go.jp/lod/ontology/crossDomain/dimension/>
PREFIX qb: <http://purl.org/linked-data/cube#>

select ?s ?population where {
  ?x sdmx-dimension:refArea ?s .
  ?x qb:dataSet <http://data.e-stat.go.jp/lod/dataset/g00200521/ds012015001> .
  ?x cd-dimension:sex <http://data.e-stat.go.jp/lod/ontology/crossDomain/code/sex-all> .
  ?x estat-measure:population ?population.
  filter strstarts(str(?s),"http://data.e-stat.go.jp/lod/smallArea/g00200521/2015/S${code}") .
}
EOS

fi

if [ ! -e "${j}" ] ; then
node main.js ${s} ${p} ${h} ${g} > ${j}
fi

wc -l ${j}

done
