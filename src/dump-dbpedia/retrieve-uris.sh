#!/bin/bash
# Query all unique DBpedia URIs from the annotations generated by DBpedia Spotlight

# Set here the number of URIs to retrieve
size=39215

# Max number of URIs to retrieve at once (limit of the SPARQL endpoint)
limit=10000

# select distinct ?uri
# from <http://ns.inria.fr/covid19/graph/dbpedia-spotlight>
# where { ?annot oa:hasBody ?uri. }
# limit 10000
# offset 
query="select%20distinct%20%3Furi%0Afrom%20%3Chttp%3A%2F%2Fns.inria.fr%2Fcovid19%2Fgraph%2Fdbpedia-spotlight%3E%0Awhere%20%7B%20%3Fannot%20oa%3AhasBody%20%3Furi.%20%7D%0Alimit%20${limit}%0Aoffset%20"

result=dbpedia-ne-uris.ttl
echo -n "" > $result

resulttmp=/tmp/sparql-response-$$.ttl
echo -n "" > $resulttmp

offset=0
while [ "$offset" -lt "$size" ]
do
    echo "Retrieving URIs starting at $offset..."
    curl -H "accept: text/csv" \
        "http://covidontheweb.inria.fr/sparql?query=${query}${offset}" \
        | grep -v '"uri"' | sed 's|"||g' >> $resulttmp
     offset=$(($offset + $limit))
done

cat $resulttmp | sort | uniq > $result
