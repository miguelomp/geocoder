# Postgres - geocoder

### .env

```
ROOT_DIR=<set to a location where the database will be stored>
POSTGRES_DB=<db name>
POSTGRES_USER=<user name>
POSTGRES_PASSWORD=<password>
```

### Deploy

```
docker compose up -d
```

Change default password for `postgres` user after geocoder installation.

### Install geocoder

For testing the deployment/installation process, make the `step 6` from [11-geocoder.sh](./scripts/11-geocoder.sh) only get `WY` state since is one with the lighest volume of data.

- Log into the container shell
    ```
    docker exec -it dbs-geocoder-1 bash
    ```
- You should be logged as root. Assign exec permissions to script, run it and wait (it can take some time).
    ```
    cd /scripts
    chmod +x 11-geocoder.sh
    nohup ./11-geocoder.sh &
    ```
- Meanwhile you can monitor the proccess running:
    ```
    tail -f nohup.out
    ```
- When done, exit current terminal and log in again with user `postgres` for changing password.
    ```
    docker exec -it -u postgres dbs-geocoder-1 psql
    ALTER USER postgres WITH ENCRYPTED PASSWORD 'new_password';
    ```
- Restart container to eliminate any temp file let by geocoder installation.



