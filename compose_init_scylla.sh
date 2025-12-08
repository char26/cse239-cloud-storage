#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
  image_name="cse239-cloud-storage-scylla-1"
else
  image_name="cse239-cloud-storage_scylla_1"
fi

until docker exec $image_name cqlsh -e "CREATE KEYSPACE IF NOT EXISTS ycsb WITH REPLICATION = {'class': 'SimpleStrategy', 'replication_factor': 3};"; do
      sleep 1
    done

docker exec $image_name cqlsh -e "CREATE TABLE ycsb.usertable (
  y_id varchar primary key,
  field0 varchar,
  field1 varchar,
  field2 varchar,
  field3 varchar,
  field4 varchar,
  field5 varchar,
  field6 varchar,
  field7 varchar,
  field8 varchar,
  field9 varchar);"
