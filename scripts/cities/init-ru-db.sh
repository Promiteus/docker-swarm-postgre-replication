#!/bin/bash

docker exec -i postgresdb bash -c "psql -h localhost -d strelka_chat -U sa -f /etc/cities/ru/script.sql"