#!/bin/bash
set -e

# 🏢 テナント実行スクリプト
# 使用方法: ./scripts/run_tenant.sh <tenant_name>

TENANT_NAME=${1:-tenant_a}

echo "🏢 テナント実行スクリプト開始"
echo "=================================="
echo "🏷️ テナント名: $TENANT_NAME"
echo ""

# テナント設定の確認（動的生成対応）
case $TENANT_NAME in
    "tenant_a")
        S3_BUCKET="tenant-a-data-lake"
        S3_PREFIX="ecommerce-data"
        DATABASE="tenant_a_db"
        ;;
    "tenant_b")
        S3_BUCKET="tenant-b-data-lake"
        S3_PREFIX="ecommerce-data"
        DATABASE="tenant_b_db"
        ;;
    *)
        echo "ℹ️ 事前定義されていないテナント名: $TENANT_NAME"
        echo "🔧 動的設定を生成します..."
        
        # 動的設定生成
        S3_BUCKET="${TENANT_NAME}-data-lake"
        S3_PREFIX="ecommerce-data"
        DATABASE="${TENANT_NAME}_db"
        
        echo "✅ 動的設定生成完了"
        ;;
esac

echo "📋 テナント設定:"
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

# データベース存在確認と自動作成
echo "🔍 データベース存在確認..."
DB_EXISTS=$(docker-compose exec -T postgres psql -U dbt_user -d dbt_database -tAc "SELECT 1 FROM pg_database WHERE datname='$DATABASE';" 2>/dev/null || echo "0")

if [[ "$DB_EXISTS" != "1" ]]; then
    echo "ℹ️ データベース '$DATABASE' が存在しません"
    echo "🔧 データベースを自動作成中..."
    docker-compose exec -T postgres psql -U dbt_user -d dbt_database -c "CREATE DATABASE $DATABASE;"
    
    # 基本スキーマ作成
    echo "🏗️ 基本スキーマ作成中..."
    docker-compose exec -T postgres psql -U dbt_user -d "$DATABASE" -c "CREATE SCHEMA IF NOT EXISTS public_public;" || true
    docker-compose exec -T postgres psql -U dbt_user -d "$DATABASE" -c "CREATE SCHEMA IF NOT EXISTS staging;" || true
    
    echo "✅ データベース '$DATABASE' を作成しました"
else
    echo "✅ データベース '$DATABASE' が存在します"
fi
echo ""

# dbt実行
echo "🏗️ dbt実行開始..."
echo "⏰ 開始時刻: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

echo "🔧 1. dbt debug実行..."
docker-compose run --rm -T -e TENANT_NAME="$TENANT_NAME" dbt dbt debug

echo ""
echo "🏗️ 2. Seeds実行..."
docker-compose run --rm -T -e TENANT_NAME="$TENANT_NAME" dbt dbt seed

echo ""
echo "🏗️ 3. テナント対応モデル実行..."
docker-compose run --rm -T -e TENANT_NAME="$TENANT_NAME" dbt dbt run --models models/staging/stg_customers_tenant.sql

echo ""
echo "📊 4. テナント情報確認..."
docker-compose run --rm -T -e TENANT_NAME="$TENANT_NAME" dbt dbt compile --models models/staging/stg_customers_tenant.sql

echo ""
echo "⏰ 終了時刻: $(date '+%Y-%m-%d %H:%M:%S')"

echo ""
echo "🔍 5. 結果確認..."
echo "=================================="

# テーブル存在確認
TABLE_EXISTS=$(docker-compose exec -T postgres psql -U dbt_user -d "$DATABASE" -tAc "SELECT 1 FROM information_schema.tables WHERE table_name='stg_customers_tenant' AND table_schema='public_public';" 2>/dev/null || echo "0")

if [[ "$TABLE_EXISTS" == "1" ]]; then
    echo "✅ テーブル 'public_public.stg_customers_tenant' が存在します"
    
    # テーブル内容の確認
    echo ""
    echo "📊 テーブル内容確認（最初の5行）:"
    docker-compose exec -T postgres psql -U dbt_user -d "$DATABASE" -c "SELECT tenant_name, source_s3_bucket, source_s3_prefix, count(*) as record_count FROM public_public.stg_customers_tenant GROUP BY tenant_name, source_s3_bucket, source_s3_prefix;"
    
else
    echo "❌ テーブル 'public_public.stg_customers_tenant' が存在しません"
fi

echo ""
echo "🎉 テナント実行完了！"
echo "==================================" 