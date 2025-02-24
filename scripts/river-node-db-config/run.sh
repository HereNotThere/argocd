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

  if [ -z "$NODE_TYPE" ]; then
      echo "NODE_TYPE is not set. Exiting."
      exit 1
  fi

  if [ -z "$NODE_NUMBER" ]; then
      echo "NODE_NUMBER is not set. Exiting."
      exit 1
  fi

  if [ $NODE_TYPE == "stream" ]; then
    # The schema name is saved to /tmp/schema-name. read it, and use it:
    SCHEMA_NAME=$(cat /tmp/schema-name)
    echo "Schema name is $SCHEMA_NAME"
    echo "Beginning pgdump... on $SOURCE_DB_HOST"

    mkdir -p /tmp/pg-dump

    export PGPASSWORD=$SOURCE_DB_PASSWORD
    pg_dump \
      -n $SCHEMA_NAME \
      -h $SOURCE_DB_HOST \
      -U $SOURCE_DB_USER \
      -d $SOURCE_DB_DATABASE \
      -F d \
      -j 12 \
      -v \
      -f /tmp/pg-dump

    echo "Finished pgdump. Restoring to target db..."

    export PGPASSWORD=$TARGET_DB_APP_PASSWORD
    pg_restore \
      -h $TARGET_DB_HOST \
      -U $TARGET_DB_APP_USER \
      -d $TARGET_DB_DATABASE \
      -j 12 \
      -O \
      -x \
      -v \
      -F d \
      /tmp/pg-dump

    echo "Finished migrate-db"
  elif [ $NODE_TYPE == "archive" ]; then
    echo "Archive node. Skipping pgdump and restore."
  else
    exit 1
  fi
}

init
migrate