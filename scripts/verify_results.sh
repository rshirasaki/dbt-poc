#!/bin/bash
set -e

# 🔍 結果確認スクリプト
# 引数: 環境 S3バケット S3プレフィックス データベース スキーマ

ENVIRONMENT=$1
S3_BUCKET=$2
S3_PREFIX=$3
DATABASE=$4
SCHEMA=$5

echo "🔍 実行結果確認"
echo "=================================="

echo "📋 設定値確認:"
echo "  🌍 環境        : $ENVIRONMENT"
echo "  🪣 S3バケット  : $S3_BUCKET"
echo "  📁 S3プレフィックス: $S3_PREFIX"
echo "  🗄️ データベース: $DATABASE"
echo "  📋 スキーマ    : $SCHEMA"
echo ""

# PostgreSQLに接続してテーブル内容を確認
echo "🗄️ データベース接続確認..."

# データベースが存在するかチェック
DB_EXISTS=$(docker-compose exec -T postgres psql -U dbt_user -d dbt_database -tAc "SELECT 1 FROM pg_database WHERE datname='$DATABASE';" 2>/dev/null || echo "0")

if [[ "$DB_EXISTS" != "1" ]]; then
    echo "❌ データベース '$DATABASE' が存在しません"
    echo "💡 データベースを作成してから再実行してください"
    exit 1
fi

echo "✅ データベース '$DATABASE' が存在します"

# テーブルが存在するかチェック（実際のスキーマ名を検出）
ACTUAL_TABLE_SCHEMA=$(docker-compose exec -T postgres psql -U dbt_user -d "$DATABASE" -tAc "SELECT schemaname FROM pg_tables WHERE tablename = 'test_environment_tables' LIMIT 1;" 2>/dev/null | tr -d ' \n\r')

if [[ -n "$ACTUAL_TABLE_SCHEMA" ]]; then
    TABLE_EXISTS="1"
    echo "✅ テーブル '$ACTUAL_TABLE_SCHEMA.test_environment_tables' が存在します"
else
    TABLE_EXISTS="0"
fi

if [[ "$TABLE_EXISTS" != "1" ]]; then
    echo "❌ テーブル 'test_environment_tables' が存在しません"
    echo "💡 dbt runを実行してテーブルを作成してください"
    exit 1
fi
echo ""

# テーブル内容の確認
echo "📊 テーブル内容確認:"
echo "=================================="

# 実際のスキーマ名を使用してクエリを構築
QUERY="SELECT 
    current_environment,
    target_database,
    actual_database,
    target_schema,
    actual_schema,
    database_validation,
    schema_validation,
    environment_validation,
    test_identifier,
    environment_config
FROM $ACTUAL_TABLE_SCHEMA.test_environment_tables;"

# クエリ実行
RESULT=$(docker-compose exec -T postgres psql -U dbt_user -d "$DATABASE" -c "$QUERY" 2>/dev/null)

echo "$RESULT"
echo ""

# 設定値と実際の値の比較
echo "🔍 設定値 vs 実際の値 比較:"
echo "=================================="

# 実際の値を取得（実際のスキーマ名を使用）
ACTUAL_ENV=$(docker-compose exec -T postgres psql -U dbt_user -d "$DATABASE" -tAc "SELECT current_environment FROM $ACTUAL_TABLE_SCHEMA.test_environment_tables LIMIT 1;" 2>/dev/null | tr -d ' \n\r')
ACTUAL_DB=$(docker-compose exec -T postgres psql -U dbt_user -d "$DATABASE" -tAc "SELECT actual_database FROM $ACTUAL_TABLE_SCHEMA.test_environment_tables LIMIT 1;" 2>/dev/null | tr -d ' \n\r')

# actual_schemaは実際のテーブルが作成されたスキーマ名を使用
ACTUAL_SCHEMA=$ACTUAL_TABLE_SCHEMA

# 比較結果の表示
echo "🌍 環境:"
echo "  設定値: $ENVIRONMENT"
echo "  実際値: $ACTUAL_ENV"
if [[ "$ENVIRONMENT" == "$ACTUAL_ENV" ]]; then
    echo "  結果  : ✅ 一致"
else
    echo "  結果  : ❌ 不一致"
fi
echo ""

echo "🗄️ データベース:"
echo "  設定値: $DATABASE"
echo "  実際値: $ACTUAL_DB"
if [[ "$DATABASE" == "$ACTUAL_DB" ]]; then
    echo "  結果  : ✅ 一致"
else
    echo "  結果  : ❌ 不一致"
fi
echo ""

echo "📋 スキーマ:"
echo "  設定値: $SCHEMA"
echo "  実際値: $ACTUAL_SCHEMA"
if [[ "$SCHEMA" == "$ACTUAL_SCHEMA" ]]; then
    echo "  結果  : ✅ 一致"
else
    echo "  結果  : ❌ 不一致"
fi
echo ""

# S3パス確認
echo "📍 S3パス確認:"
echo "  設定S3バケット  : $S3_BUCKET"
echo "  設定S3プレフィックス: $S3_PREFIX"
echo ""
echo "  生成されるS3パス:"
echo "    顧客: s3://$S3_BUCKET/$S3_PREFIX/customers/"
echo "    注文: s3://$S3_BUCKET/$S3_PREFIX/orders/"
echo "    商品: s3://$S3_BUCKET/$S3_PREFIX/products/"
echo ""

# 総合判定
if [[ "$ENVIRONMENT" == "$ACTUAL_ENV" && "$DATABASE" == "$ACTUAL_DB" && "$SCHEMA" == "$ACTUAL_SCHEMA" ]]; then
    echo "🎉 総合判定: ✅ 全て一致 - 設定が正常に反映されています！"
else
    echo "⚠️ 総合判定: ❌ 不一致あり - 設定を確認してください"
fi

echo ""
echo "🔍 結果確認完了"
echo "==================================" 