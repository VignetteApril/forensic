#!/bin/bash

# pg_dump --host=74.7.8.78 --port=5432 --username=postgres --password=postgres --dbname=aom | gzip > /home/aom/aom$(date +%Y%m%d).backup.gz

PGPASSWORD=shike /home/shike/postgresql/postgresql/bin/pg_dump --host=localhost --port=5432 --username=shike --dbname=shike | gzip > /home/shike/shike$(date +%Y%m%d).backup.gz

