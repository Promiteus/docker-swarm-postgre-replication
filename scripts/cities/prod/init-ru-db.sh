#!/bin/bash

name=""
name=$(docker container ls | awk '{print $NF}' | grep rep_postgres_master)
echo $name

docker exec -i $name bash -c "psql -h localhost -d docker_replica -U sa -f /etc/cities/ru/script.sql"