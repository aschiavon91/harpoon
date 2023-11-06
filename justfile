start_dev:
  docker compose -f docker-compose-dev.yaml up -d
  mix setup

start_prod:
  docker compose -f docker-compose.yaml up -d --build

logs_prod:
  docker compose -f docker-compose.yaml logs -f

stop_prod:
    docker compose -f docker-compose.yaml down
