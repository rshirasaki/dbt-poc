# dbt-poc: テナント管理型データ分析プラットフォーム

## 🎯 プロジェクト目的

このプロジェクトは以下の3つの重要な機能を検証・実装しています：

1. **dbtの動作確認** - PostgreSQLを使用したdbtパイプラインの構築
2. **テナント別のパス＆テーブル管理** - 環境変数による動的なテナント切り替え
3. **dbt_external_tablesによるGlue Crawler機能の補完** - S3外部テーブル定義の管理

## 🏗️ アーキテクチャ

```
環境変数 TENANT_NAME
    ↓
テナント設定 (dbt_project.yml)
    ↓
┌─────────────────┬─────────────────┐
│   tenant_a      │   tenant_b      │
├─────────────────┼─────────────────┤
│ tenant_a_db     │ tenant_b_db     │
│ tenant-a-data-  │ tenant-b-data-  │
│ lake/ecommerce- │ lake/ecommerce- │
│ data/           │ data/           │
└─────────────────┴─────────────────┘
    ↓
共通テーブル名: customers, orders, products, regions
```

## 📁 プロジェクト構成

### 🔧 コア機能
- `macros/tenant_management.sql` - テナント管理マクロ
- `models/staging/schema_tenant_external.yml` - テナント対応外部テーブル定義
- `models/staging/stg_customers_tenant.sql` - テナント対応ステージングモデル
- `scripts/run_tenant.sh` - テナント実行スクリプト

### 📊 データモデル
- `seeds/` - サンプルデータ（customers, orders, products, regions）
- `models/staging/` - ステージングレイヤー
- `models/marts/` - データマートレイヤー
- `snapshots/` - SCD Type 2スナップショット

### 🔍 分析・検証
- `analyses/` - 外部テーブル機能のデモ・検証クエリ
- `tests/` - データ品質テスト

## 🚀 使用方法

### 🎯 Makefileを使った簡単操作

#### **クイックスタート**
```bash
# 最も簡単な開始方法
make quick-start

# 全機能デモ実行
make demo

# ヘルプ表示
make help
```

#### **基本的な使用方法**
```bash
# 1. 環境構築
make setup                          # 初期セットアップ
make up                             # PostgreSQL起動

# 2. テナント実行
make tenant-a                       # テナントA実行
make tenant-b                       # テナントB実行
make tenant-run TENANT=tenant_a     # 指定テナント実行

# 3. データ分析
make analysis-all TENANT=tenant_a   # 全分析実行
make analysis-basic TENANT=tenant_a # 基本分析のみ
make analysis-products              # 商品分析（デフォルト: tenant_a）
```

#### **開発・デバッグ**
```bash
# dbt操作
make dbt-debug TENANT=tenant_a      # dbt接続確認
make dbt-seed TENANT=tenant_a       # シードデータ投入
make dbt-run TENANT=tenant_a        # モデル実行

# データベース操作
make db-connect TENANT=tenant_a     # PostgreSQL接続
make db-status                      # データベース状態確認

# 開発支援
make dev-shell TENANT=tenant_a      # 開発用シェル起動
make dev-logs                       # ログ監視
```

#### **情報表示**
```bash
make info                           # プロジェクト情報
make examples                       # 使用例表示
make version                        # バージョン情報
```

### 📋 従来のスクリプト実行（上級者向け）

Makefileを使わない場合の直接実行方法：

#### **1. 環境構築**
```bash
# PostgreSQLコンテナ起動
docker-compose up -d postgres

# データベース作成確認
docker-compose exec postgres psql -U dbt_user -d dbt_database -c "\l"
```

#### **2. テナント実行**
```bash
# テナントAで実行
./scripts/run_tenant.sh tenant_a

# テナントBで実行
./scripts/run_tenant.sh tenant_b
```

#### **3. データ分析実行**
```bash
# 全分析実行
./scripts/run_analysis.sh tenant_a

# 特定分析のみ
./scripts/run_analysis.sh tenant_a basic      # 基本分析
./scripts/run_analysis.sh tenant_a dashboard # ダッシュボード
./scripts/run_analysis.sh tenant_a products  # 商品分析
```

### 🎯 実行内容

各テナント実行では以下が自動実行されます：

1. **dbt debug** - 接続確認
2. **dbt seed** - サンプルデータ投入
3. **dbt run** - テナント対応モデル実行
4. **結果確認** - テーブル作成とデータ確認

## 📋 テナント設定

### tenant_a
- 🗄️ データベース: `tenant_a_db`
- 🪣 S3バケット: `tenant-a-data-lake`
- 📁 S3プレフィックス: `ecommerce-data`

### tenant_b
- 🗄️ データベース: `tenant_b_db`
- 🪣 S3バケット: `tenant-b-data-lake`
- 📁 S3プレフィックス: `ecommerce-data`

## 🔧 技術スタック

- **dbt**: 1.8.0
- **PostgreSQL**: 13
- **Docker**: コンテナ化
- **dbt_external_tables**: 0.11.1

## 📊 生成されるS3パス例

```
s3://tenant-a-data-lake/ecommerce-data/customers/
s3://tenant-a-data-lake/ecommerce-data/orders/
s3://tenant-a-data-lake/ecommerce-data/products/
s3://tenant-a-data-lake/ecommerce-data/regions/
```

## 🎯 検証ポイント

### ✅ dbt動作確認
- PostgreSQL接続
- Seeds、Models、Snapshots実行
- データ品質テスト

### ✅ テナント管理
- 環境変数による動的切り替え
- テナント別データベース分離
- 共通テーブル名での統一

### ✅ dbt_external_tables
- 外部テーブル定義の管理
- S3パスの動的生成
- Glue Crawler代替機能

## 🔍 確認コマンド

```bash
# テナント別データ確認
docker-compose exec postgres psql -U dbt_user -d tenant_a_db -c "SELECT * FROM public_public.stg_customers_tenant;"

# 外部テーブル定義確認
docker-compose run --rm -e TENANT_NAME="tenant_a" dbt dbt compile --models models/staging/stg_customers_tenant.sql
```

## 📊 ナイーブなdbtを使ったデータ分析例

### 🎯 分析の目的
このプロジェクトでは、dbtを使った基本的なデータ分析の例を提供しています。ECサイトのサンプルデータを使用して、以下の分析を実行できます：

### 📈 提供している分析例

#### 1. 基本データ分析 (`analyses/basic_data_analysis.sql`)
- **顧客別売上分析**: 顧客ごとの注文数、売上、平均注文額
- **商品別売上分析**: 商品ごとの注文回数、売上、販売数量
- **月別売上トレンド**: 月次の売上推移と顧客数
- **顧客セグメンテーション**: VIP/Premium/Regular/Newの分類

#### 2. 売上ダッシュボード (`analyses/sales_dashboard.sql`)
- **KPI指標**: 総顧客数、総注文数、総売上、平均注文額
- **日別売上トレンド**: 日次の売上推移
- **カテゴリ別売上**: 商品カテゴリごとの売上分析
- **商品ランキング**: 売上上位商品のランキング

### 🚀 分析の実行方法

#### 基本的な実行
```bash
# 全ての分析を実行
./scripts/run_analysis.sh tenant_a

# 特定の分析のみ実行
./scripts/run_analysis.sh tenant_a basic      # 基本分析のみ
./scripts/run_analysis.sh tenant_a dashboard # ダッシュボード分析のみ
./scripts/run_analysis.sh tenant_a products  # 商品分析のみ
```

#### テナント別分析
```bash
# テナントAの分析
./scripts/run_analysis.sh tenant_a

# テナントBの分析
./scripts/run_analysis.sh tenant_b
```

### 📊 分析結果の例

#### KPI指標
```
顧客数: 5人
総売上: 3,464.89円
アクティブ顧客: 5人
平均注文額: 692.98円
```

#### 商品ランキング（実際のデータ）
```
1位: Laptop (Electronics) - 1,999.98円 (2回注文)
2位: Smartphone (Electronics) - 1,199.98円 (2回注文)
3位: Running Shoes (Sports) - 129.99円 (1回注文)
4位: Book (Books) - 74.97円 (1回注文)
5位: Coffee Mug (Home & Kitchen) - 59.97円 (2回注文)
```

#### カテゴリ別売上分析
```
Electronics: 3,199.96円 (全体の92.4%)
Sports: 129.99円 (全体の3.8%)
Books: 74.97円 (全体の2.2%)
Home & Kitchen: 59.97円 (全体の1.7%)
```

#### 顧客セグメント分布
```
VIP顧客: 0人 (LTV ≥ 1,000円)
Premium顧客: 5人 (500-999円)
Regular顧客: 0人 (100-499円)
New顧客: 0人 (< 100円)
```

### 🔧 分析のカスタマイズ

#### 新しい分析の追加
1. `analyses/` ディレクトリに新しいSQLファイルを作成
2. dbtの `{{ ref() }}` 関数を使用してテーブル参照
3. `scripts/run_analysis.sh` に新しい分析タイプを追加

#### セグメント基準の変更
`analyses/basic_data_analysis.sql` の顧客セグメンテーション部分を編集：
```sql
case 
    when total_sales >= 1000 then 'VIP'
    when total_sales >= 500 then 'Premium'
    when total_sales >= 100 then 'Regular'
    else 'New'
end as customer_segment
```

### 💡 分析のベストプラクティス

1. **CTEの活用**: 複雑な分析はCTEで段階的に構築
2. **dbt関数の使用**: `{{ ref() }}` でテーブル参照の一貫性を保つ
3. **テナント対応**: 環境変数でテナント別分析を実現
4. **結果の可視化**: UNION ALLで分析結果を統合表示

### 🎯 ビジネス価値

- **顧客理解**: セグメント別の購買行動分析
- **商品戦略**: 売上貢献度の高い商品の特定
- **売上予測**: トレンド分析による将来予測の基盤
- **マーケティング**: ターゲット顧客の特定と施策立案

## 📝 注意事項

- PostgreSQLアダプターでは`stage_external_sources`は未対応
- 外部テーブル定義の設定確認は可能
- 実際のS3アクセスにはAWS認証情報が必要 