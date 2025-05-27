# 🏢 動的テナント管理機能ガイド

## 📋 概要

dbt-pocプロジェクトでは、makeコマンドでTENANT変数を指定することで、seedファイルのデータとテナント名を使って新しいS3パス、データベースを動的に作成できます。

## 🎯 利用可能なMakeコマンド

### **📖 ヘルプ・情報表示**
- `make help` - 全コマンドのヘルプを表示
- `make examples` - 使用例を表示
- `make info` - プロジェクト情報を表示
- `make version` - バージョン情報を表示

### **🚀 基本操作**
- `make setup` - 初期セットアップ（Docker環境構築）
- `make clean` - 環境クリーンアップ
- `make up` - PostgreSQLコンテナを起動
- `make down` - 全コンテナを停止
- `make status` - コンテナ状態を確認

### **🏷️ テナント管理**
- `make tenant-a` - テナントA実行
- `make tenant-b` - テナントB実行
- `make tenant-run TENANT=<name>` - 指定テナント実行
- `make tenant-create TENANT=<name>` - 動的テナント作成
- `make tenant-create-and-run TENANT=<name>` - 動的テナント作成＆実行
- `make tenant-clean` - 事前定義テナントクリーンアップ
- `make tenant-clean-dynamic TENANT=<name>` - 動的テナントクリーンアップ

### **📊 データ分析**
- `make analysis-basic TENANT=<name>` - 基本データ分析実行
- `make analysis-dashboard TENANT=<name>` - ダッシュボード分析実行
- `make analysis-products TENANT=<name>` - 商品分析実行
- `make analysis-all TENANT=<name>` - 全分析実行

### **🔧 dbt操作**
- `make dbt-debug TENANT=<name>` - dbt接続確認
- `make dbt-seed TENANT=<name>` - dbtシードデータ投入
- `make dbt-run TENANT=<name>` - dbtモデル実行
- `make dbt-test TENANT=<name>` - dbtテスト実行
- `make dbt-snapshot TENANT=<name>` - dbtスナップショット実行
- `make dbt-compile TENANT=<name>` - dbtコンパイル

### **🗄️ データベース操作**
- `make db-connect TENANT=<name>` - PostgreSQLに接続
- `make db-status` - データベース状態確認
- `make db-list-tenants` - テナントデータベース一覧表示
- `make db-tables TENANT=<name>` - テーブル一覧表示
- `make db-schemas TENANT=<name>` - スキーマ一覧表示
- `make db-tenant-info TENANT=<name>` - テナント情報表示
- `make db-create-schemas` - スキーマ作成

### **🧪 テスト**
- `make test-all` - 全テスト実行
- `make test-tenant TENANT=<name>` - テナント機能テスト
- `make test-analysis TENANT=<name>` - 分析機能テスト

### **🎯 デモ・クイックスタート**
- `make demo` - フルデモ実行
- `make quick-start` - クイックスタート（テナントA）

### **🔧 開発者向け**
- `make dev-shell TENANT=<name>` - 開発用シェル起動
- `make dev-logs` - 開発用ログ監視
- `make dev-reset` - 開発環境リセット

## 🎯 主な機能

### **1. 動的設定生成**
- テナント名から自動的にS3バケット、データベース名を生成
- 事前定義されていないテナントでも自動対応
- 一貫性のある命名規則を適用

### **2. 自動データベース作成**
- 指定されたテナント用データベースが存在しない場合、自動作成
- 必要なスキーマ（public_public, staging）も自動作成
- PostgreSQL環境での完全な分離

### **3. seedファイル連携**
- 既存のseedファイル（customers.csv, orders.csv, products.csv, regions.csv）を使用
- テナント別データベースに自動投入
- データの完全な分離を実現

## 🚀 使用方法

### **基本的な使用方法**

```bash
# 1. 動的テナント作成
make tenant-create TENANT=my_company

# 2. テナント実行（データベース作成＋seed投入＋モデル実行）
make tenant-run TENANT=my_company

# 3. 分析実行
make analysis-all TENANT=my_company

# 4. 作成＆実行を一度に（推奨）
make tenant-create-and-run TENANT=my_company
```

### **複数テナントの管理**

```bash
# 複数のテナントを作成
make tenant-create-and-run TENANT=acme_corp
make tenant-create-and-run TENANT=global_inc
make tenant-create-and-run TENANT=startup_xyz

# 各テナントで分析実行
make analysis-all TENANT=acme_corp
make analysis-all TENANT=global_inc
make analysis-all TENANT=startup_xyz
```

### **データベース・テーブル確認**

```bash
# データベース一覧確認
make db-status                    # 全データベース一覧
make db-list-tenants             # テナントデータベースのみ

# テーブル・スキーマ確認
make db-tables TENANT=my_company    # テーブル一覧
make db-schemas TENANT=my_company   # スキーマ一覧
make db-tenant-info TENANT=my_company # テナント情報

# 特定テナントのデータベースに接続
make db-connect TENANT=my_company

# PostgreSQL内でテーブル確認
\dt public_public.*  # テーブル一覧
\dn                  # スキーマ一覧
\l                   # データベース一覧
```

## 📊 動的設定生成ルール

### **命名規則**

| 項目 | 生成ルール | 例（TENANT=my_company） |
|------|------------|-------------------------|
| S3バケット | `{tenant_name}-data-lake` | `my_company-data-lake` |
| S3プレフィックス | `ecommerce-data` | `ecommerce-data` |
| データベース | `{tenant_name}_db` | `my_company_db` |

### **生成されるS3パス**

```
s3://{tenant_name}-data-lake/ecommerce-data/customers/
s3://{tenant_name}-data-lake/ecommerce-data/orders/
s3://{tenant_name}-data-lake/ecommerce-data/products/
s3://{tenant_name}-data-lake/ecommerce-data/regions/
```

## 🔧 技術的な仕組み

### **1. マクロベースの動的設定**

```sql
-- macros/tenant_management.sql
{% macro generate_dynamic_tenant_config(tenant_name) %}
  {% set config = {
    's3_bucket': tenant_name ~ '-data-lake',
    's3_prefix': 'ecommerce-data',
    'database': tenant_name ~ '_db'
  } %}
  {{ return(config) }}
{% endmacro %}
```

### **2. 自動データベース作成**

```bash
# scripts/create_dynamic_tenant.sh
DATABASE="${TENANT_NAME}_db"
docker-compose exec -T postgres psql -U dbt_user -d dbt_database -c "CREATE DATABASE $DATABASE;"
```

### **3. テナント情報の埋め込み**

```sql
-- models/staging/stg_customers_tenant.sql
select
    customer_id,
    customer_name,
    -- テナント情報を追加
    '{{ get_tenant_name() }}' as tenant_name,
    '{{ get_tenant_s3_bucket() }}' as source_s3_bucket,
    '{{ get_tenant_s3_prefix() }}' as source_s3_prefix
from {{ ref('customers') }}
```

## 📈 実行結果の確認

### **テナント情報の確認**

```sql
-- 各テナントのデータを確認
SELECT tenant_name, source_s3_bucket, source_s3_prefix, count(*) as record_count 
FROM public_public.stg_customers_tenant 
GROUP BY tenant_name, source_s3_bucket, source_s3_prefix;
```

### **データベース一覧の確認**

```bash
# 作成されたテナントデータベースを確認
make db-status
# または直接PostgreSQLコマンド
docker-compose exec postgres psql -U dbt_user -d dbt_database -c "\l" | grep -E "(tenant_|_db)"
```

## 🧹 クリーンアップ

### **個別テナントのクリーンアップ**

```bash
# 特定の動的テナントを削除
make tenant-clean-dynamic TENANT=my_company
```

### **全テナントのクリーンアップ**

```bash
# 事前定義テナント（tenant_a, tenant_b）を削除
make tenant-clean

# 全環境リセット
make dev-reset
```

## ⚠️ 注意事項

### **テナント名の制限**

- 英数字、ハイフン（-）、アンダースコア（_）のみ使用可能
- 50文字以内
- PostgreSQLデータベース名の制限に準拠

### **データの分離**

- 各テナントは完全に独立したデータベースを使用
- S3パスも完全に分離
- テナント間でのデータ共有は発生しない

### **リソース管理**

- 各テナントごとに独立したデータベースが作成される
- 大量のテナント作成時はリソース使用量に注意
- 不要なテナントは定期的にクリーンアップを推奨

## 🎯 ベストプラクティス

### **1. 命名規則の統一**

```bash
# 推奨: 会社名やプロジェクト名を使用
make tenant-create-and-run TENANT=acme_corp
make tenant-create-and-run TENANT=global_inc

# 非推奨: 意味のない名前
make tenant-create-and-run TENANT=test123
```

### **2. 段階的な実行**

```bash
# 1. まず作成のみ
make tenant-create TENANT=new_client

# 2. 設定確認後に実行
make tenant-run TENANT=new_client

# 3. 分析実行
make analysis-all TENANT=new_client
```

### **3. 定期的なメンテナンス**

```bash
# 月次でのクリーンアップ
make tenant-clean-dynamic TENANT=old_client

# 開発環境のリセット
make dev-reset
```

### **4. データベース・テーブル確認の流れ**

```bash
# 1. 全体状況確認
make db-status                      # 全データベース一覧
make db-list-tenants               # テナントデータベースのみ

# 2. 特定テナントの詳細確認
make db-tables TENANT=my_company    # テーブル一覧
make db-schemas TENANT=my_company   # スキーマ一覧
make db-tenant-info TENANT=my_company # テナント情報

# 3. 特定テナントに接続（詳細確認）
make db-connect TENANT=my_company

# 4. PostgreSQL内でテーブル確認
\dt public_public.*  # テーブル一覧
SELECT * FROM public_public.stg_customers_tenant LIMIT 5;

# 5. 接続終了
\q
```

## 📚 関連ドキュメント

- [基本的な使用方法](../README.md)
- [Makefile使用例](../Makefile) - `make examples`
- [テナント管理マクロ](../macros/tenant_management.sql)
- [動的テナント作成スクリプト](../scripts/create_dynamic_tenant.sh)

## 🔍 トラブルシューティング

### **よくある問題と解決方法**

1. **データベース作成エラー**
   ```bash
   # PostgreSQLコンテナの状態確認
   make status
   
   # コンテナ再起動
   make down && make up
   ```

2. **テナント名エラー**
   ```bash
   # 有効なテナント名の例
   make tenant-create TENANT=valid_name_123
   
   # 無効なテナント名（エラーになる）
   make tenant-create TENANT="invalid name!"
   ```

3. **既存テナントの上書き**
   ```bash
   # 既存テナントを削除してから再作成
   make tenant-clean-dynamic TENANT=existing_tenant
   make tenant-create-and-run TENANT=existing_tenant
   ```

4. **データベース接続問題**
   ```bash
   # dbt接続確認
   make dbt-debug TENANT=my_company
   
   # PostgreSQL直接接続
   make db-connect TENANT=my_company
   ```

## 📝 実用的な使用例

### **新規クライアント向けセットアップ**

```bash
# 1. 環境準備
make setup
make up

# 2. クライアント専用環境作成
make tenant-create-and-run TENANT=new_client_2024

# 3. データ分析実行
make analysis-all TENANT=new_client_2024

# 4. 結果確認
make db-connect TENANT=new_client_2024
```

### **定期メンテナンス**

```bash
# 週次: 不要なテナントクリーンアップ
make tenant-clean-dynamic TENANT=old_test_tenant

# 月次: 全環境リセット
make dev-reset

# 四半期: フルデモで動作確認
make demo
``` 