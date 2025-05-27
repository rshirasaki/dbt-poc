#!/bin/bash
set -e

# 複数データベース作成スクリプト
# POSTGRES_MULTIPLE_DATABASES環境変数からカンマ区切りのデータベース名を取得

if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
    echo "Creating multiple databases: $POSTGRES_MULTIPLE_DATABASES"
    
    for db in $(echo $POSTGRES_MULTIPLE_DATABASES | tr ',' ' '); do
        echo "Creating database: $db"
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
            CREATE DATABASE $db;
            GRANT ALL PRIVILEGES ON DATABASE $db TO $POSTGRES_USER;
EOSQL
    done
    
    echo "Multiple databases created successfully!"
else
    echo "POSTGRES_MULTIPLE_DATABASES not set, skipping multiple database creation"
fi 