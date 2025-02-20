#!/bin/bash

set -eo pipefail


init() {
  echo "Running init-db"
  yarn install
  yarn db:init
}

migrate() {
  echo "Running migrate-db"

  if [ -z "$TARGET_DB_HOST" ]; then
      echo "TARGET_DB_HOST is not set. Exiting."
      exit 1
  fi 

  if [ -z "$TARGET_DB_DATABASE" ]; then
      echo "TARGET_DB_DATABASE is not set. Exiting."
      exit 1
  fi

  if [ -z "$TARGET_DB_APP_USER" ]; then
      echo "TARGET_DB_APP_USER is not set. Exiting."
      exit 1
  fi

  if [ -z "$TARGET_DB_APP_PASSWORD" ]; then
      echo "TARGET_DB_APP_PASSWORD is not set. Exiting."
      exit 1
  fi

  if [ -z "$SOURCE_DB_HOST" ]; then
      echo "SOURCE_DB_HOST is not set. Exiting."
      exit 1
  fi

  if [ -z "$SOURCE_DB_DATABASE" ]; then
      echo "SOURCE_DB_DATABASE is not set. Exiting."
      exit 1
  fi

  if [ -z "$SOURCE_DB_USER" ]; then
      echo "SOURCE_DB_USER is not set. Exiting."
      exit 1
  fi

  if [ -z "$SOURCE_DB_PASSWORD" ]; then
      echo "SOURCE_DB_PASSWORD is not set. Exiting."
      exit 1
  fi

  # The schema name is saved to /tmp/schema-name. read it, and use it:
  SCHEMA_NAME=$(cat /tmp/schema-name)

  echo "Schema name is $SCHEMA_NAME"
  echo "Beginning pgdump..."

  export PGPASSWORD=$SOURCE_DB_PASSWORD
  pg_dump -n $SCHEMA_NAME -h $SOURCE_DB_HOST -U $SOURCE_DB_USER -d $SOURCE_DB_DATABASE -F d -j 4 -v -f /tmp/dump

  echo "Finished pgdump. Restoring to target db..."

  export PGPASSWORD=$TARGET_DB_APP_PASSWORD
  pg_restore -h $TARGET_DB_HOST -U $TARGET_DB_APP_USER -d $TARGET_DB_DATABASE -j 4 -O -x -v -F d /tmp/dump

  echo "Finished migrate-db"
}

init
migrate