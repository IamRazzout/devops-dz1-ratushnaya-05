#!/bin/bash

docker rm -f ratushnaya-05-web ratushnaya-05-db 2>/dev/null || true

docker build --build-arg VERSION=2.0 -t ratushnaya-05/probe:2.0 .

docker volume create ratushnaya-05-data

docker run -d \
  --name ratushnaya-05-db \
  -e POSTGRES_PASSWORD=lab \
  -e POSTGRES_DB=lab \
  -p 8017:5432 \
  -v ratushnaya-05-data:/var/lib/postgresql/data \
  postgres:16-alpine

docker run -d \
  --name ratushnaya-05-web \
  -p 8015:5005 \
  --add-host host.docker.internal:host-gateway \
  -e DATABASE_URL=postgresql://postgres:lab@host.docker.internal:8017/lab \
  ratushnaya-05/probe:2.0

SECONDS=0
until curl -sf -m 3 localhost:8015/notes > /dev/null || [ $SECONDS -ge 60 ]; do
  sleep 2
done

curl -s localhost:8015/notes
