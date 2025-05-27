#!/bin/bash
set -e

# 🏗️ 動的テナント作成スクリプト
# 使用方法: ./scripts/create_dynamic_tenant.sh <tenant_name>

TENANT_NAME=${1}

if [ -z "$TENANT_NAME" ]; then
    echo "❌ テナント名を指定してください"
    echo "💡 使用方法: ./scripts/create_dynamic_tenant.sh <tenant_name>"
    echo "💡 例: ./scripts/create_dynamic_tenant.sh my_company"
    exit 1
fi

echo "🏗️ 動的テナント作成開始"
echo "=================================="
echo "🏷️ テナント名: $TENANT_NAME"
echo ""

# テナント名の妥当性チェック
if [[ ! "$TENANT_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "❌ テナント名は英数字、ハイフン、アンダースコアのみ使用可能です"
    exit 1
fi

if [ ${#TENANT_NAME} -gt 50 ]; then
    echo "❌ テナント名は50文字以内で指定してください"
    exit 1
fi

# 動的設定生成
S3_BUCKET="${TENANT_NAME}-data-lake"
S3_PREFIX="ecommerce-data"
DATABASE="${TENANT_NAME}_db"

echo "📋 生成される設定:"
echo "  🪣 S3バケット  : $S3_BUCKET"
echo "  📁 S3プレフィックス: $S3_PREFIX"
echo "  🗄️ データベース: $DATABASE"
echo ""

echo "📍 生成されるS3パス:"
echo "  顧客データ: s3://$S3_BUCKET/$S3_PREFIX/customers/"
echo "  注文データ: s3://$S3_BUCKET/$S3_PREFIX/orders/"
echo "  商品データ: s3://$S3_BUCKET/$S3_PREFIX/products/"
echo "  地域データ: s3://$S3_BUCKET/$S3_PREFIX/regions/"
echo ""

# PostgreSQLコンテナが起動しているか確認
if ! docker-compose ps postgres | grep -q "Up"; then
    echo "⚠️ PostgreSQLコンテナが起動していません。起動中..."
    docker-compose up -d postgres
    echo "⏳ PostgreSQL起動待機中..."
    sleep 10
fi

# データベース存在確認
echo "🔍 データベース存在確認..."
DB_EXISTS=$(docker-compose exec -T postgres psql -U dbt_user -d dbt_database -tAc "SELECT 1 FROM pg_database WHERE datname='$DATABASE';" 2>/dev/null || echo "0")

if [[ "$DB_EXISTS" == "1" ]]; then
    echo "⚠️ データベース '$DATABASE' は既に存在します"
    read -p "🤔 既存のデータベースを削除して再作成しますか？ (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️ 既存データベースを削除中..."
        docker-compose exec -T postgres psql -U dbt_user -d dbt_database -c "DROP DATABASE IF EXISTS $DATABASE;"
    else
        echo "ℹ️ 既存のデータベースを使用します"
    fi
fi

# データベース作成
if [[ "$DB_EXISTS" != "1" ]] || [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔧 データベース '$DATABASE' を作成中..."
    docker-compose exec -T postgres psql -U dbt_user -d dbt_database -c "CREATE DATABASE $DATABASE;"
    echo "✅ データベース '$DATABASE' を作成しました"
fi

# スキーマ作成
echo "🏗️ 基本スキーマ作成中..."
docker-compose exec -T postgres psql -U dbt_user -d "$DATABASE" -c "CREATE SCHEMA IF NOT EXISTS public_public;" || true
docker-compose exec -T postgres psql -U dbt_user -d "$DATABASE" -c "CREATE SCHEMA IF NOT EXISTS staging;" || true
echo "✅ スキーマ作成完了"

echo ""
echo "🎉 動的テナント作成完了！"
echo "=================================="
echo "💡 次のステップ:"
echo "   1. make tenant-run TENANT=$TENANT_NAME"
echo "   2. make analysis-all TENANT=$TENANT_NAME"
echo "==================================" 