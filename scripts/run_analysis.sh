#!/bin/bash
set -e

# 📊 データ分析実行スクリプト
# 使用方法: ./scripts/run_analysis.sh <tenant_name> [analysis_type]

TENANT_NAME=${1:-tenant_a}
ANALYSIS_TYPE=${2:-all}

echo "📊 データ分析実行開始"
echo "=================================="
echo "🏷️ テナント名: $TENANT_NAME"
echo "📈 分析タイプ: $ANALYSIS_TYPE"
echo ""

# テナント設定の確認（動的生成対応）
case $TENANT_NAME in
    "tenant_a")
        DATABASE="tenant_a_db"
        ;;
    "tenant_b")
        DATABASE="tenant_b_db"
        ;;
    *)
        echo "ℹ️ 事前定義されていないテナント名: $TENANT_NAME"
        echo "🔧 動的設定を使用します..."
        
        # 動的設定生成
        DATABASE="${TENANT_NAME}_db"
        
        echo "✅ 動的設定適用完了"
        ;;
esac

echo "🗄️ データベース: $DATABASE"
echo ""

# データベース存在確認
echo "🔍 データベース存在確認..."
DB_EXISTS=$(docker-compose exec -T postgres psql -U dbt_user -d dbt_database -tAc "SELECT 1 FROM pg_database WHERE datname='$DATABASE';" 2>/dev/null || echo "0")

if [[ "$DB_EXISTS" != "1" ]]; then
    echo "❌ データベース '$DATABASE' が存在しません"
    echo "💡 先にテナント実行を行ってください: ./scripts/run_tenant.sh $TENANT_NAME"
    exit 1
fi

echo "✅ データベース '$DATABASE' が存在します"
echo ""

# 分析実行
echo "📊 分析実行開始..."
echo "⏰ 開始時刻: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

if [[ "$ANALYSIS_TYPE" == "all" || "$ANALYSIS_TYPE" == "basic" ]]; then
    echo "📈 1. 基本データ分析実行..."
    docker-compose run --rm -T -e TENANT_NAME="$TENANT_NAME" dbt dbt compile --select analyses/basic_data_analysis.sql
    
    echo ""
    echo "📊 基本分析結果:"
    docker-compose exec -T postgres psql -U dbt_user -d "$DATABASE" -f /dev/stdin << 'EOF'
-- 基本的な分析結果を表示
WITH customer_sales AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        COUNT(o.order_id) as total_orders,
        COALESCE(SUM(o.total_amount), 0) as total_sales
    FROM public_public.customers c
    LEFT JOIN public_public.orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT 
    '=== 基本分析結果 ===' as analysis_section,
    '' as metric,
    '' as value
UNION ALL
SELECT 
    '顧客数',
    'total_customers',
    COUNT(*)::text
FROM customer_sales
UNION ALL
SELECT 
    '総売上',
    'total_revenue',
    SUM(total_sales)::text || '円'
FROM customer_sales
UNION ALL
SELECT 
    'アクティブ顧客',
    'active_customers', 
    COUNT(*)::text
FROM customer_sales
WHERE total_orders > 0;
EOF
fi

if [[ "$ANALYSIS_TYPE" == "all" || "$ANALYSIS_TYPE" == "dashboard" ]]; then
    echo ""
    echo "📊 2. ダッシュボード分析実行..."
    docker-compose run --rm -T -e TENANT_NAME="$TENANT_NAME" dbt dbt compile --select analyses/sales_dashboard.sql
    
    echo ""
    echo "📈 売上ダッシュボード結果:"
    docker-compose exec -T postgres psql -U dbt_user -d "$DATABASE" -f /dev/stdin << 'EOF'
-- ダッシュボード用KPI
SELECT 
    '=== KPI指標 ===' as section,
    '' as metric,
    '' as value
UNION ALL
SELECT 
    'KPI',
    'total_orders',
    COUNT(*)::text || '件'
FROM public_public.orders
UNION ALL
SELECT 
    'KPI',
    'total_revenue',
    SUM(total_amount)::text || '円'
FROM public_public.orders
UNION ALL
SELECT 
    'KPI',
    'avg_order_value',
    ROUND(AVG(total_amount), 2)::text || '円'
FROM public_public.orders;
EOF
fi

if [[ "$ANALYSIS_TYPE" == "all" || "$ANALYSIS_TYPE" == "products" ]]; then
    echo ""
    echo "🛍️ 3. 商品分析実行..."
    
    echo ""
    echo "🏆 商品ランキング:"
    docker-compose exec -T postgres psql -U dbt_user -d "$DATABASE" -f /dev/stdin << 'EOF'
-- 商品別売上ランキング
SELECT 
    p.product_name,
    p.product_category,
    COUNT(o.order_id) as order_count,
    SUM(o.total_amount) as revenue
FROM public_public.products p
LEFT JOIN public_public.orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name, p.product_category
HAVING COUNT(o.order_id) > 0
ORDER BY revenue DESC;
EOF
fi

echo ""
echo "⏰ 終了時刻: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "🎉 データ分析完了！"
echo "==================================" 