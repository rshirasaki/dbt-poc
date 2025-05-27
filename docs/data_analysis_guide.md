# 📊 dbt データ分析ガイド

## 🎯 概要

このガイドでは、dbt-pocプロジェクトで提供されているデータ分析機能について詳しく説明します。ECサイトのサンプルデータを使用して、実際のビジネス分析を体験できます。

## 📈 提供している分析

### 1. 基本データ分析 (`analyses/basic_data_analysis.sql`)

#### 分析内容
- **顧客別売上分析**: 各顧客の購買行動を詳細に分析
- **商品別売上分析**: 商品ごとの売上パフォーマンス
- **月別売上トレンド**: 時系列での売上推移
- **顧客セグメンテーション**: 購買金額と頻度による顧客分類

#### 実行方法
```bash
./scripts/run_analysis.sh tenant_a basic
```

#### 出力例
```
=== 基本分析結果 ===
顧客数: 5人
総売上: 3,464.89円
アクティブ顧客: 5人
```

### 2. 売上ダッシュボード (`analyses/sales_dashboard.sql`)

#### 分析内容
- **KPI指標**: 重要業績評価指標の一覧
- **日別売上トレンド**: 日次の売上変動
- **カテゴリ別売上**: 商品カテゴリごとの売上分析
- **商品ランキング**: 売上上位商品の特定

#### 実行方法
```bash
./scripts/run_analysis.sh tenant_a dashboard
```

### 3. 商品分析 (`scripts/run_analysis.sh products`)

#### 分析内容
- **商品別売上ランキング**: 売上順での商品一覧
- **注文回数分析**: 商品ごとの注文頻度
- **カテゴリ別パフォーマンス**: カテゴリごとの売上比較

#### 実行方法
```bash
./scripts/run_analysis.sh tenant_a products
```

#### 出力例
```
商品ランキング:
1位: Laptop (Electronics) - 1,999.98円 (2回注文)
2位: Smartphone (Electronics) - 1,199.98円 (2回注文)
3位: Running Shoes (Sports) - 129.99円 (1回注文)
```

## 🔧 分析のカスタマイズ

### 顧客セグメント基準の変更

`analyses/basic_data_analysis.sql` の以下の部分を編集：

```sql
case 
    when total_sales >= 1000 then 'VIP'
    when total_sales >= 500 then 'Premium'
    when total_sales >= 100 then 'Regular'
    else 'New'
end as customer_segment
```

### 新しい分析の追加

1. `analyses/` ディレクトリに新しいSQLファイルを作成
2. dbtの `{{ ref() }}` 関数を使用してテーブル参照
3. `scripts/run_analysis.sh` に新しい分析タイプを追加

例：
```sql
-- analyses/custom_analysis.sql
select 
    customer_name,
    sum(total_amount) as lifetime_value
from {{ ref('orders') }} o
join {{ ref('customers') }} c on o.customer_id = c.customer_id
group by customer_name
order by lifetime_value desc
```

## 📊 実際のデータ分析結果

### KPI指標（tenant_a）
- **総顧客数**: 5人
- **総売上**: 3,464.89円
- **平均注文額**: 692.98円
- **アクティブ顧客**: 5人

### 商品カテゴリ分析
| カテゴリ | 売上 | 構成比 |
|----------|------|--------|
| Electronics | 3,199.96円 | 92.4% |
| Sports | 129.99円 | 3.8% |
| Books | 74.97円 | 2.2% |
| Home & Kitchen | 59.97円 | 1.7% |

### 顧客セグメント分布
- **VIP顧客** (≥1,000円): 0人
- **Premium顧客** (500-999円): 5人
- **Regular顧客** (100-499円): 0人
- **New顧客** (<100円): 0人

## 💡 分析のベストプラクティス

### 1. CTEの活用
複雑な分析は段階的にCTEで構築：
```sql
with customer_sales as (
    -- 顧客別売上計算
),
product_performance as (
    -- 商品別パフォーマンス計算
),
final_analysis as (
    -- 最終分析結果
)
select * from final_analysis
```

### 2. dbt関数の使用
テーブル参照は必ず `{{ ref() }}` を使用：
```sql
from {{ ref('customers') }} c
join {{ ref('orders') }} o on c.customer_id = o.customer_id
```

### 3. テナント対応
環境変数でテナント別分析を実現：
```bash
TENANT_NAME=tenant_b ./scripts/run_analysis.sh tenant_b
```

### 4. 結果の可視化
UNION ALLで分析結果を統合表示：
```sql
select 'KPI' as section, 'total_customers' as metric, count(*)::text as value
union all
select 'KPI', 'total_revenue', sum(amount)::text
```

## 🎯 ビジネス価値

### 顧客理解
- セグメント別の購買行動分析
- 顧客ライフタイムバリューの算出
- リピート率の分析

### 商品戦略
- 売上貢献度の高い商品の特定
- カテゴリ別パフォーマンス比較
- 在庫最適化のための需要分析

### 売上予測
- トレンド分析による将来予測の基盤
- 季節性の把握
- 成長率の計算

### マーケティング
- ターゲット顧客の特定
- 効果的な施策立案
- ROI測定の基盤

## 🔍 トラブルシューティング

### データが表示されない場合
1. テナント実行が完了しているか確認
2. データベース接続を確認
3. テーブルが正しく作成されているか確認

### 分析結果が期待と異なる場合
1. サンプルデータの内容を確認
2. 分析ロジックを見直し
3. セグメント基準を調整

### パフォーマンスが遅い場合
1. インデックスの追加を検討
2. CTEの最適化
3. 不要な結合の削除

## 📚 参考資料

- [dbt公式ドキュメント](https://docs.getdbt.com/)
- [PostgreSQL分析関数](https://www.postgresql.org/docs/current/functions-window.html)
- [SQL分析パターン集](https://github.com/dbt-labs/dbt-utils)

---

# 📊 dbt Data Analysis Guide

## 🎯 Overview

This guide provides detailed explanations of the data analysis features available in the dbt-poc project. You can experience real business analysis using sample e-commerce data.

## 📈 Available Analyses

### 1. Basic Data Analysis (`analyses/basic_data_analysis.sql`)

#### Analysis Content
- **Customer Sales Analysis**: Detailed analysis of each customer's purchasing behavior
- **Product Sales Analysis**: Sales performance by product
- **Monthly Sales Trends**: Time-series sales trends
- **Customer Segmentation**: Customer classification based on purchase amount and frequency

#### Execution Method
```bash
./scripts/run_analysis.sh tenant_a basic
```

#### Output Example
```
=== Basic Analysis Results ===
Customer Count: 5
Total Sales: ¥3,464.89
Active Customers: 5
```

### 2. Sales Dashboard (`analyses/sales_dashboard.sql`)

#### Analysis Content
- **KPI Metrics**: List of key performance indicators
- **Daily Sales Trends**: Daily sales fluctuations
- **Category Sales**: Sales analysis by product category
- **Product Rankings**: Identification of top-selling products

#### Execution Method
```bash
./scripts/run_analysis.sh tenant_a dashboard
```

### 3. Product Analysis (`scripts/run_analysis.sh products`)

#### Analysis Content
- **Product Sales Rankings**: Product list sorted by sales
- **Order Frequency Analysis**: Order frequency by product
- **Category Performance**: Sales comparison by category

#### Execution Method
```bash
./scripts/run_analysis.sh tenant_a products
```

#### Output Example
```
Product Rankings:
1st: Laptop (Electronics) - ¥1,999.98 (2 orders)
2nd: Smartphone (Electronics) - ¥1,199.98 (2 orders)
3rd: Running Shoes (Sports) - ¥129.99 (1 order)
```

## 🔧 Analysis Customization

### Changing Customer Segment Criteria

Edit the following section in `analyses/basic_data_analysis.sql`:

```sql
case 
    when total_sales >= 1000 then 'VIP'
    when total_sales >= 500 then 'Premium'
    when total_sales >= 100 then 'Regular'
    else 'New'
end as customer_segment
```

### Adding New Analysis

1. Create a new SQL file in the `analyses/` directory
2. Use dbt's `{{ ref() }}` function for table references
3. Add new analysis type to `scripts/run_analysis.sh`

Example:
```sql
-- analyses/custom_analysis.sql
select 
    customer_name,
    sum(total_amount) as lifetime_value
from {{ ref('orders') }} o
join {{ ref('customers') }} c on o.customer_id = c.customer_id
group by customer_name
order by lifetime_value desc
```

## 📊 Actual Data Analysis Results

### KPI Metrics (tenant_a)
- **Total Customers**: 5
- **Total Sales**: ¥3,464.89
- **Average Order Value**: ¥692.98
- **Active Customers**: 5

### Product Category Analysis
| Category | Sales | Percentage |
|----------|-------|------------|
| Electronics | ¥3,199.96 | 92.4% |
| Sports | ¥129.99 | 3.8% |
| Books | ¥74.97 | 2.2% |
| Home & Kitchen | ¥59.97 | 1.7% |

### Customer Segment Distribution
- **VIP Customers** (≥¥1,000): 0
- **Premium Customers** (¥500-999): 5
- **Regular Customers** (¥100-499): 0
- **New Customers** (<¥100): 0

## 💡 Analysis Best Practices

### 1. Using CTEs
Build complex analyses step by step with CTEs:
```sql
with customer_sales as (
    -- Customer sales calculation
),
product_performance as (
    -- Product performance calculation
),
final_analysis as (
    -- Final analysis results
)
select * from final_analysis
```

### 2. Using dbt Functions
Always use `{{ ref() }}` for table references:
```sql
from {{ ref('customers') }} c
join {{ ref('orders') }} o on c.customer_id = o.customer_id
```

### 3. Tenant Support
Achieve tenant-specific analysis with environment variables:
```bash
TENANT_NAME=tenant_b ./scripts/run_analysis.sh tenant_b
```

### 4. Result Visualization
Integrate analysis results with UNION ALL:
```sql
select 'KPI' as section, 'total_customers' as metric, count(*)::text as value
union all
select 'KPI', 'total_revenue', sum(amount)::text
```

## 🎯 Business Value

### Customer Understanding
- Purchase behavior analysis by segment
- Customer lifetime value calculation
- Repeat rate analysis

### Product Strategy
- Identification of high-contributing products
- Category performance comparison
- Demand analysis for inventory optimization

### Sales Forecasting
- Foundation for future predictions through trend analysis
- Understanding seasonality
- Growth rate calculation

### Marketing
- Target customer identification
- Effective strategy planning
- ROI measurement foundation

## 🔍 Troubleshooting

### When Data is Not Displayed
1. Verify tenant execution is complete
2. Check database connection
3. Verify tables are created correctly

### When Analysis Results Differ from Expectations
1. Check sample data content
2. Review analysis logic
3. Adjust segment criteria

### When Performance is Slow
1. Consider adding indexes
2. Optimize CTEs
3. Remove unnecessary joins

## 📚 References

- [dbt Official Documentation](https://docs.getdbt.com/)
- [PostgreSQL Window Functions](https://www.postgresql.org/docs/current/functions-window.html)
- [SQL Analysis Pattern Collection](https://github.com/dbt-labs/dbt-utils) 