FROM postgis/postgis:16-3.4

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget postgis unzip && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /gisdata/temp && \
    chmod -R 777 /gisdata
