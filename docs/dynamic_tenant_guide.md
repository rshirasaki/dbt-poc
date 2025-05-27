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

---

# 🏢 Dynamic Tenant Management Feature Guide

## 📋 Overview

In the dbt-poc project, you can dynamically create new S3 paths and databases using seed file data and tenant names by specifying the TENANT variable with make commands.

## 🎯 Available Make Commands

### **📖 Help & Information Display**
- `make help` - Display help for all commands
- `make examples` - Show usage examples
- `make info` - Display project information
- `make version` - Show version information

### **🚀 Basic Operations**
- `make setup` - Initial setup (Docker environment construction)
- `make clean` - Environment cleanup
- `make up` - Start PostgreSQL container
- `make down` - Stop all containers
- `make status` - Check container status

### **🏷️ Tenant Management**
- `make tenant-a` - Execute tenant A
- `make tenant-b` - Execute tenant B
- `make tenant-run TENANT=<name>` - Execute specified tenant
- `make tenant-create TENANT=<name>` - Create dynamic tenant
- `make tenant-create-and-run TENANT=<name>` - Create & execute dynamic tenant
- `make tenant-clean` - Clean predefined tenants
- `make tenant-clean-dynamic TENANT=<name>` - Clean dynamic tenant

### **📊 Data Analysis**
- `make analysis-basic TENANT=<name>` - Execute basic data analysis
- `make analysis-dashboard TENANT=<name>` - Execute dashboard analysis
- `make analysis-products TENANT=<name>` - Execute product analysis
- `make analysis-all TENANT=<name>` - Execute all analyses

### **🔧 dbt Operations**
- `make dbt-debug TENANT=<name>` - dbt connection check
- `make dbt-seed TENANT=<name>` - Load dbt seed data
- `make dbt-run TENANT=<name>` - Execute dbt models
- `make dbt-test TENANT=<name>` - Execute dbt tests
- `make dbt-snapshot TENANT=<name>` - Execute dbt snapshots
- `make dbt-compile TENANT=<name>` - Compile dbt

### **🗄️ Database Operations**
- `make db-connect TENANT=<name>` - Connect to PostgreSQL
- `make db-status` - Check database status
- `make db-list-tenants` - List tenant databases
- `make db-tables TENANT=<name>` - List tables
- `make db-schemas TENANT=<name>` - List schemas
- `make db-tenant-info TENANT=<name>` - Display tenant information
- `make db-create-schemas` - Create schemas

### **🧪 Testing**
- `make test-all` - Execute all tests
- `make test-tenant TENANT=<name>` - Test tenant functionality
- `make test-analysis TENANT=<name>` - Test analysis functionality

### **🎯 Demo & Quick Start**
- `make demo` - Execute full demo
- `make quick-start` - Quick start (tenant A)

### **🔧 Developer Tools**
- `make dev-shell TENANT=<name>` - Start development shell
- `make dev-logs` - Monitor development logs
- `make dev-reset` - Reset development environment

## 🎯 Main Features

### **1. Dynamic Configuration Generation**
- Automatically generate S3 buckets and database names from tenant names
- Automatic support for tenants not predefined
- Apply consistent naming conventions

### **2. Automatic Database Creation**
- Automatically create databases for specified tenants if they don't exist
- Automatically create required schemas (public_public, staging)
- Complete isolation in PostgreSQL environment

### **3. Seed File Integration**
- Use existing seed files (customers.csv, orders.csv, products.csv, regions.csv)
- Automatically load into tenant-specific databases
- Achieve complete data isolation

## 🚀 Usage

### **Basic Usage**

```bash
# 1. Create dynamic tenant
make tenant-create TENANT=my_company

# 2. Execute tenant (database creation + seed loading + model execution)
make tenant-run TENANT=my_company

# 3. Execute analysis
make analysis-all TENANT=my_company

# 4. Create & execute at once (recommended)
make tenant-create-and-run TENANT=my_company
```

### **Managing Multiple Tenants**

```bash
# Create multiple tenants
make tenant-create-and-run TENANT=acme_corp
make tenant-create-and-run TENANT=global_inc
make tenant-create-and-run TENANT=startup_xyz

# Execute analysis for each tenant
make analysis-all TENANT=acme_corp
make analysis-all TENANT=global_inc
make analysis-all TENANT=startup_xyz
```

### **Database & Table Verification**

```bash
# Check database list
make db-status                    # All databases
make db-list-tenants             # Tenant databases only

# Check tables & schemas
make db-tables TENANT=my_company    # Table list
make db-schemas TENANT=my_company   # Schema list
make db-tenant-info TENANT=my_company # Tenant information

# Connect to specific tenant database
make db-connect TENANT=my_company

# Check tables in PostgreSQL
\dt public_public.*  # Table list
\dn                  # Schema list
\l                   # Database list
```

## 📊 Dynamic Configuration Generation Rules

### **Naming Conventions**

| Item | Generation Rule | Example (TENANT=my_company) |
|------|-----------------|----------------------------|
| S3 Bucket | `{tenant_name}-data-lake` | `my_company-data-lake` |
| S3 Prefix | `ecommerce-data` | `ecommerce-data` |
| Database | `{tenant_name}_db` | `my_company_db` |

### **Generated S3 Paths**

```
s3://{tenant_name}-data-lake/ecommerce-data/customers/
s3://{tenant_name}-data-lake/ecommerce-data/orders/
s3://{tenant_name}-data-lake/ecommerce-data/products/
s3://{tenant_name}-data-lake/ecommerce-data/regions/
```

## 🔧 Technical Mechanisms

### **1. Macro-based Dynamic Configuration**

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

### **2. Automatic Database Creation**

```bash
# scripts/create_dynamic_tenant.sh
DATABASE="${TENANT_NAME}_db"
docker-compose exec -T postgres psql -U dbt_user -d dbt_database -c "CREATE DATABASE $DATABASE;"
```

### **3. Tenant Information Embedding**

```sql
-- models/staging/stg_customers_tenant.sql
select
    customer_id,
    customer_name,
    -- Add tenant information
    '{{ get_tenant_name() }}' as tenant_name,
    '{{ get_tenant_s3_bucket() }}' as source_s3_bucket,
    '{{ get_tenant_s3_prefix() }}' as source_s3_prefix
from {{ ref('customers') }}
```

## 📈 Verifying Execution Results

### **Verifying Tenant Information**

```sql
-- Check data for each tenant
SELECT tenant_name, source_s3_bucket, source_s3_prefix, count(*) as record_count 
FROM public_public.stg_customers_tenant 
GROUP BY tenant_name, source_s3_bucket, source_s3_prefix;
```

### **Verifying Database List**

```bash
# Check created tenant databases
make db-status
# Or direct PostgreSQL command
docker-compose exec postgres psql -U dbt_user -d dbt_database -c "\l" | grep -E "(tenant_|_db)"
```

## 🧹 Cleanup

### **Individual Tenant Cleanup**

```bash
# Delete specific dynamic tenant
make tenant-clean-dynamic TENANT=my_company
```

### **All Tenant Cleanup**

```bash
# Delete predefined tenants (tenant_a, tenant_b)
make tenant-clean

# Reset all environments
make dev-reset
```

## ⚠️ Notes

### **Tenant Name Restrictions**

- Only alphanumeric characters, hyphens (-), and underscores (_) allowed
- Maximum 50 characters
- Complies with PostgreSQL database name restrictions

### **Data Isolation**

- Each tenant uses completely independent databases
- S3 paths are also completely isolated
- No data sharing occurs between tenants

### **Resource Management**

- Independent databases are created for each tenant
- Be mindful of resource usage when creating many tenants
- Regular cleanup of unnecessary tenants is recommended

## 🎯 Best Practices

### **1. Unified Naming Conventions**

```bash
# Recommended: Use company or project names
make tenant-create-and-run TENANT=acme_corp
make tenant-create-and-run TENANT=global_inc

# Not recommended: Meaningless names
make tenant-create-and-run TENANT=test123
```

### **2. Staged Execution**

```bash
# 1. Create only first
make tenant-create TENANT=new_client

# 2. Execute after configuration check
make tenant-run TENANT=new_client

# 3. Execute analysis
make analysis-all TENANT=new_client
```

### **3. Regular Maintenance**

```bash
# Monthly cleanup
make tenant-clean-dynamic TENANT=old_client

# Development environment reset
make dev-reset
```

### **4. Database & Table Verification Flow**

```bash
# 1. Overall status check
make db-status                      # All databases
make db-list-tenants               # Tenant databases only

# 2. Specific tenant detailed check
make db-tables TENANT=my_company    # Table list
make db-schemas TENANT=my_company   # Schema list
make db-tenant-info TENANT=my_company # Tenant information

# 3. Connect to specific tenant (detailed check)
make db-connect TENANT=my_company

# 4. Check tables in PostgreSQL
\dt public_public.*  # Table list
SELECT * FROM public_public.stg_customers_tenant LIMIT 5;

# 5. End connection
\q
```

## 📚 Related Documentation

- [Basic Usage](../README.md)
- [Makefile Usage Examples](../Makefile) - `make examples`
- [Tenant Management Macros](../macros/tenant_management.sql)
- [Dynamic Tenant Creation Script](../scripts/create_dynamic_tenant.sh)

## 🔍 Troubleshooting

### **Common Issues and Solutions**

1. **Database Creation Error**
   ```bash
   # Check PostgreSQL container status
   make status
   
   # Restart container
   make down && make up
   ```

2. **Tenant Name Error**
   ```bash
   # Valid tenant name example
   make tenant-create TENANT=valid_name_123
   
   # Invalid tenant name (will cause error)
   make tenant-create TENANT="invalid name!"
   ```

3. **Overwriting Existing Tenant**
   ```bash
   # Delete existing tenant then recreate
   make tenant-clean-dynamic TENANT=existing_tenant
   make tenant-create-and-run TENANT=existing_tenant
   ```

4. **Database Connection Issues**
   ```bash
   # dbt connection check
   make dbt-debug TENANT=my_company
   
   # Direct PostgreSQL connection
   make db-connect TENANT=my_company
   ```

## 📝 Practical Usage Examples

### **New Client Setup**

```bash
# 1. Environment preparation
make setup
make up

# 2. Create client-specific environment
make tenant-create-and-run TENANT=new_client_2024

# 3. Execute data analysis
make analysis-all TENANT=new_client_2024

# 4. Check results
make db-connect TENANT=new_client_2024
```

### **Regular Maintenance**

```bash
# Weekly: Cleanup unnecessary tenants
make tenant-clean-dynamic TENANT=old_test_tenant

# Monthly: Reset all environments
make dev-reset

# Quarterly: Full demo for operation check
make demo
``` 