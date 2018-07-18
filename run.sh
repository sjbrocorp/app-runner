#!/usr/bin/env bash

export REGISTRY=samjbro
export APP_NAME=customer-services
export RUN_NAME=app-runner
export WEB_NAME=vuejs-frontend
export API_NAME=laravel-backend
export E2E_NAME=codeceptjs-e2e-tests
export SERVER_NAME=server
export PATH_TO_WEB="../web"
export PATH_TO_API="../api"
export PATH_TO_E2E="../e2e"

export SERVICE_NAME=$RUN_NAME

export DB_ROOT_PASS=${DB_ROOT_PASS:-root}
export DB_USER=${DB_USER:-$APP_NAME-user}
export DB_PASS=${DB_PASS:-$APP_NAME-pass}
export DB_NAME=${DB_NAME:-$APP_NAME}
export DB_HOST=${DB_HOST:-mysql}

if [ "$1" == "e2e" ]; then
export SERVER_PORT=${SERVER_PORT:-83}
export WEB_PORT=${WEB_PORT:-3003}
export API_PORT=${API_PORT:-8083}
export DB_PORT=${DB_PORT:-3308}
export APP_ENV=${APP_ENV:-testing}
COMPOSE="docker-compose -f ./docker-compose.yml -p  $APP_NAME-$SERVICE_NAME-e2e"

else

export SERVER_PORT=${SERVER_PORT:-82}
export WEB_PORT=${WEB_PORT:-3002}
export API_PORT=${API_PORT:-8082}
export DB_PORT=${DB_PORT:-3307}
COMPOSE="docker-compose -f ./docker-compose.yml -p $APP_NAME-$SERVICE_NAME"

fi

if [ $# -gt 0 ]; then
  if [ "$1" == "web" ]; then
    shift 1
    if [ "$1" == "test" ]; then
      $COMPOSE run --rm web yarn test

    elif [ "$1" == "lint" ]; then
      $COMPOSE run --rm web yarn lint
    elif [ "$1" == "shell" ]; then
      $COMPOSE run --rm web /bin/sh
    else
      $COMPOSE run --rm web "$@"
    fi
  elif [ "$1" == "api" ]; then
    shift 1
    if [ "$1" == "art" ]; then
      shift 1
      $COMPOSE run --rm api php artisan "$@"
    elif [ "$1" == "test" ]; then
      shift 1
      $COMPOSE run --rm api vendor/bin/phpunit
    elif [ "$1" == "setup" ]; then
      ./run.sh api configure
      ./run.sh api migrate
      ./run.sh api seed
    elif [ "$1" == "configure" ]; then
      cp ./api/.env.example ./api/.env
      ./run.sh api art key:generate
      ./run.sh api art jwt:secret
    elif [ "$1" == "migrate" ]; then
      $COMPOSE run --rm api php artisan migrate --seed
    elif [ "$1" == "seed" ]; then
      $COMPOSE run --rm api php artisan db:seed --class=ThreadSeeder
    elif [ "$1" == "dump" ]; then
      $COMPOSE run --rm api composer dump-autoload
    elif [ "$1" == "shell" ]; then
      $COMPOSE run --rm api /bin/sh
    else
      $COMPOSE run --rm api "$@"
    fi
  elif [ "$1" == "e2e" ]; then
    shift 1
    if [ "$1" == "test" ]; then
      shift 1
#      $COMPOSE up -d
      $COMPOSE run --rm e2e yarn test "$@"
#      $COMPOSE down
    elif [ "$1" == "art" ]; then
      shift 1
      $COMPOSE exec api php artisan "$@"
    elif [ "$1" == "yarn" ]; then
      $COMPOSE run --rm e2e "$@"
    elif [ "$1" == "test:debug" ]; then
      shift 1
      $COMPOSE up -d
      $COMPOSE run --rm e2e yarn test:debug "$@"
      $COMPOSE down
    elif [ "$1" == "shell" ]; then
      $COMPOSE run --rm e2e /bin/sh
    else
      $COMPOSE "$@"
    fi
  elif [ "$1" == "db" ]; then
  shift 1
  if [ "$1" == "creds" ]; then
    echo "User: ${DB_USER}"
    echo "Password: ${DB_PASS}"
    echo "Database name: ${DB_NAME}"
    echo "Port: ${DB_PORT}"
   fi
  else
    $COMPOSE "$@"
  fi
else
  $COMPOSE ps
fi
