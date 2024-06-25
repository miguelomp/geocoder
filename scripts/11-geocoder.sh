#!/bin/bash
# https://postgis.net/docs/postgis_installation.html#install_tiger_geocoder_extension 
set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# Create the 'template_postgis' template db
"${psql[@]}" <<- 'EOSQL'
--step 0
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_raster;
CREATE EXTENSION IF NOT EXISTS postgis_sfcgal;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch; --needed for postgis_tiger_geocoder
--optional used by postgis_tiger_geocoder, or can be used standalone
CREATE EXTENSION IF NOT EXISTS address_standardizer;
CREATE EXTENSION IF NOT EXISTS address_standardizer_data_us;
CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
--step 1
UPDATE tiger.loader_lookuptables SET load = true WHERE table_name = 'zcta520';
EOSQL

# step 3 gen script
psql -c "SELECT Loader_Generate_Nation_Script('sh')" -d geocoder -tA > /gisdata/nation_script_load.sh

# step 4
sh /gisdata/nation_script_load.sh

# step 5
"${psql[@]}" <<- 'EOSQL'
UPDATE tiger.loader_lookuptables SET load = true WHERE load = false AND lookup_name IN('tract', 'bg', 'tabblock');
EOSQL

# step 6
STATES="WV FL IL MN MD RI ID NH NC VT CT DE NM CA NJ WI OR NE PA WA LA GA AL UT OH TX CO SC OK TN WY HI ND KY MP GU ME NY NV AK AS MI AR MS MO MT KS IN PR SD MA VA DC IA AZ VI"
# STATES="WY"
# Load PostGIS into both template_database and $POSTGRES_DB
for STATE in $STATES; do
    FILENAME=$STATE"_load.sh"
    QUERY="Loader_Generate_Script(ARRAY['"$STATE"'], 'sh')"
    echo "On $STATE with $FILENAME"
    psql -d geocoder -tA -c "SELECT $QUERY" > "/gisdata/$FILENAME"
    sh "/gisdata/$FILENAME"
    rm -rf /gisdata/*/
done

# step 7
"${psql[@]}" <<- 'EOSQL'
SELECT install_missing_indexes();
vacuum (analyze, verbose) tiger.addr;
vacuum (analyze, verbose) tiger.edges;
vacuum (analyze, verbose) tiger.faces;
vacuum (analyze, verbose) tiger.featnames;
vacuum (analyze, verbose) tiger.place;
vacuum (analyze, verbose) tiger.cousub;
vacuum (analyze, verbose) tiger.county;
vacuum (analyze, verbose) tiger.state;
vacuum (analyze, verbose) tiger.zip_lookup_base;
vacuum (analyze, verbose) tiger.zip_state;
vacuum (analyze, verbose) tiger.zip_state_loc;
EOSQL