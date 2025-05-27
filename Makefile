# 🏢 dbt-poc: テナント管理型データ分析プラットフォーム Makefile
# 使用方法: make help

.PHONY: help setup clean build up down logs status
.PHONY: tenant-a tenant-b tenant-run tenant-clean
.PHONY: analysis-basic analysis-dashboard analysis-products analysis-all
.PHONY: dbt-debug dbt-seed dbt-run dbt-test dbt-snapshot dbt-compile
.PHONY: db-connect db-status db-create-schemas
.PHONY: docs-serve docs-generate
.PHONY: test-all test-tenant test-analysis
.PHONY: demo quick-start

# デフォルトターゲット
.DEFAULT_GOAL := help

# 変数定義
TENANT_A := tenant_a
TENANT_B := tenant_b
DEFAULT_TENANT := $(TENANT_A)

# カラー定義
BLUE := \033[34m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

##@ 🚀 基本操作

help: ## 📖 ヘルプメッセージを表示
	@echo "$(BLUE)🏢 dbt-poc: テナント管理型データ分析プラットフォーム$(RESET)"
	@echo "$(BLUE)================================================================$(RESET)"
	@awk 'BEGIN {FS = ":.*##"; printf "\n使用方法:\n  make $(GREEN)<target>$(RESET)\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  $(GREEN)%-20s$(RESET) %s\n", $$1, $$2 } /^##@/ { printf "\n$(BLUE)%s$(RESET)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

setup: ## 🔧 初期セットアップ（Docker環境構築）
	@echo "$(BLUE)🔧 初期セットアップ開始...$(RESET)"
	@chmod +x scripts/*.sh
	@docker-compose build
	@echo "$(GREEN)✅ セットアップ完了！$(RESET)"

clean: ## 🧹 環境クリーンアップ
	@echo "$(YELLOW)🧹 環境クリーンアップ中...$(RESET)"
	@docker-compose down -v
	@docker system prune -f
	@echo "$(GREEN)✅ クリーンアップ完了！$(RESET)"

##@ 🐳 Docker操作

build: ## 🏗️ Dockerイメージをビルド
	@echo "$(BLUE)🏗️ Dockerイメージビルド中...$(RESET)"
	@docker-compose build

up: ## ⬆️ PostgreSQLコンテナを起動
	@echo "$(BLUE)⬆️ PostgreSQLコンテナ起動中...$(RESET)"
	@docker-compose up -d postgres
	@echo "$(GREEN)✅ PostgreSQL起動完了！$(RESET)"

down: ## ⬇️ 全コンテナを停止
	@echo "$(YELLOW)⬇️ コンテナ停止中...$(RESET)"
	@docker-compose down
	@echo "$(GREEN)✅ コンテナ停止完了！$(RESET)"

logs: ## 📋 コンテナログを表示
	@docker-compose logs -f postgres

status: ## 📊 コンテナ状態を確認
	@echo "$(BLUE)📊 コンテナ状態:$(RESET)"
	@docker-compose ps

##@ 🏷️ テナント管理

tenant-a: ## 🏢 テナントA実行
	@echo "$(BLUE)🏢 テナントA実行開始...$(RESET)"
	@./scripts/run_tenant.sh $(TENANT_A)

tenant-b: ## 🏢 テナントB実行
	@echo "$(BLUE)🏢 テナントB実行開始...$(RESET)"
	@./scripts/run_tenant.sh $(TENANT_B)

tenant-run: ## 🏢 指定テナント実行 (TENANT=tenant_name)
	@if [ -z "$(TENANT)" ]; then \
		echo "$(RED)❌ TENANT変数を指定してください: make tenant-run TENANT=tenant_a$(RESET)"; \
		exit 1; \
	fi
	@echo "$(BLUE)🏢 テナント$(TENANT)実行開始...$(RESET)"
	@./scripts/run_tenant.sh $(TENANT)

tenant-create: ## 🏗️ 動的テナント作成 (TENANT=tenant_name)
	@if [ -z "$(TENANT)" ]; then \
		echo "$(RED)❌ TENANT変数を指定してください: make tenant-create TENANT=my_company$(RESET)"; \
		exit 1; \
	fi
	@echo "$(BLUE)🏗️ 動的テナント作成開始...$(RESET)"
	@./scripts/create_dynamic_tenant.sh $(TENANT)

tenant-create-and-run: ## 🚀 動的テナント作成＆実行 (TENANT=tenant_name)
	@if [ -z "$(TENANT)" ]; then \
		echo "$(RED)❌ TENANT変数を指定してください: make tenant-create-and-run TENANT=my_company$(RESET)"; \
		exit 1; \
	fi
	@echo "$(BLUE)🚀 動的テナント作成＆実行開始...$(RESET)"
	@./scripts/create_dynamic_tenant.sh $(TENANT)
	@sleep 2
	@./scripts/run_tenant.sh $(TENANT)

tenant-clean: ## 🧹 全テナントデータベースをクリーンアップ
	@echo "$(YELLOW)🧹 テナントデータベースクリーンアップ中...$(RESET)"
	@docker-compose exec postgres psql -U dbt_user -d dbt_database -c "DROP DATABASE IF EXISTS tenant_a_db;" || true
	@docker-compose exec postgres psql -U dbt_user -d dbt_database -c "DROP DATABASE IF EXISTS tenant_b_db;" || true
	@echo "$(GREEN)✅ テナントクリーンアップ完了！$(RESET)"

tenant-clean-dynamic: ## 🧹 動的テナントデータベースをクリーンアップ (TENANT=tenant_name)
	@if [ -z "$(TENANT)" ]; then \
		echo "$(RED)❌ TENANT変数を指定してください: make tenant-clean-dynamic TENANT=my_company$(RESET)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)🧹 動的テナント$(TENANT)クリーンアップ中...$(RESET)"
	@docker-compose exec postgres psql -U dbt_user -d dbt_database -c "DROP DATABASE IF EXISTS $(TENANT)_db;" || true
	@echo "$(GREEN)✅ テナント$(TENANT)クリーンアップ完了！$(RESET)"

##@ 📊 データ分析

analysis-basic: ## 📈 基本データ分析実行 (TENANT=tenant_name)
	@$(eval TENANT := $(or $(TENANT),$(DEFAULT_TENANT)))
	@echo "$(BLUE)📈 基本データ分析実行 ($(TENANT))...$(RESET)"
	@./scripts/run_analysis.sh $(TENANT) basic

analysis-dashboard: ## 📊 ダッシュボード分析実行 (TENANT=tenant_name)
	@$(eval TENANT := $(or $(TENANT),$(DEFAULT_TENANT)))
	@echo "$(BLUE)📊 ダッシュボード分析実行 ($(TENANT))...$(RESET)"
	@./scripts/run_analysis.sh $(TENANT) dashboard

analysis-products: ## 🛍️ 商品分析実行 (TENANT=tenant_name)
	@$(eval TENANT := $(or $(TENANT),$(DEFAULT_TENANT)))
	@echo "$(BLUE)🛍️ 商品分析実行 ($(TENANT))...$(RESET)"
	@./scripts/run_analysis.sh $(TENANT) products

analysis-all: ## 📊 全分析実行 (TENANT=tenant_name)
	@$(eval TENANT := $(or $(TENANT),$(DEFAULT_TENANT)))
	@echo "$(BLUE)📊 全分析実行 ($(TENANT))...$(RESET)"
	@./scripts/run_analysis.sh $(TENANT) all

##@ 🔧 dbt操作

dbt-debug: ## 🔍 dbt接続確認 (TENANT=tenant_name)
	@$(eval TENANT := $(or $(TENANT),$(DEFAULT_TENANT)))
	@echo "$(BLUE)🔍 dbt接続確認 ($(TENANT))...$(RESET)"
	@docker-compose run --rm -e TENANT_NAME="$(TENANT)" dbt dbt debug

dbt-seed: ## 🌱 dbtシードデータ投入 (TENANT=tenant_name)
	@$(eval TENANT := $(or $(TENANT),$(DEFAULT_TENANT)))
	@echo "$(BLUE)🌱 dbtシードデータ投入 ($(TENANT))...$(RESET)"
	@docker-compose run --rm -e TENANT_NAME="$(TENANT)" dbt dbt seed

dbt-run: ## 🏗️ dbtモデル実行 (TENANT=tenant_name)
	@$(eval TENANT := $(or $(TENANT),$(DEFAULT_TENANT)))
	@echo "$(BLUE)🏗️ dbtモデル実行 ($(TENANT))...$(RESET)"
	@docker-compose run --rm -e TENANT_NAME="$(TENANT)" dbt dbt run

dbt-test: ## 🧪 dbtテスト実行 (TENANT=tenant_name)
	@$(eval TENANT := $(or $(TENANT),$(DEFAULT_TENANT)))
	@echo "$(BLUE)🧪 dbtテスト実行 ($(TENANT))...$(RESET)"
	@docker-compose run --rm -e TENANT_NAME="$(TENANT)" dbt dbt test

dbt-snapshot: ## 📸 dbtスナップショット実行 (TENANT=tenant_name)
	@$(eval TENANT := $(or $(TENANT),$(DEFAULT_TENANT)))
	@echo "$(BLUE)📸 dbtスナップショット実行 ($(TENANT))...$(RESET)"
	@docker-compose run --rm -e TENANT_NAME="$(TENANT)" dbt dbt snapshot

dbt-compile: ## 📝 dbtコンパイル (TENANT=tenant_name)
	@$(eval TENANT := $(or $(TENANT),$(DEFAULT_TENANT)))
	@echo "$(BLUE)📝 dbtコンパイル ($(TENANT))...$(RESET)"
	@docker-compose run --rm -e TENANT_NAME="$(TENANT)" dbt dbt compile

##@ 🗄️ データベース操作

db-connect: ## 🔌 PostgreSQLに接続 (TENANT=tenant_name)
	@$(eval TENANT := $(or $(TENANT),$(DEFAULT_TENANT)))
	@$(eval DATABASE := $(if $(filter $(TENANT),tenant_a),tenant_a_db,$(if $(filter $(TENANT),tenant_b),tenant_b_db,dbt_database)))
	@echo "$(BLUE)🔌 PostgreSQL接続 ($(DATABASE))...$(RESET)"
	@docker-compose exec postgres psql -U dbt_user -d $(DATABASE)

db-status: ## 📊 データベース状態確認
	@echo "$(BLUE)📊 データベース状態確認...$(RESET)"
	@docker-compose exec postgres psql -U dbt_user -d dbt_database -c "\l"

db-list-tenants: ## 📋 テナントデータベース一覧表示
	@echo "$(BLUE)📋 テナントデータベース一覧...$(RESET)"
	@docker-compose exec postgres psql -U dbt_user -d dbt_database -c "\l" | grep -E "(tenant_|_db|Name)" || echo "テナントデータベースが見つかりません"

db-tables: ## 📊 テーブル一覧表示 (TENANT=tenant_name)
	@$(eval TENANT := $(or $(TENANT),$(DEFAULT_TENANT)))
	@$(eval DATABASE := $(if $(filter $(TENANT),tenant_a),tenant_a_db,$(if $(filter $(TENANT),tenant_b),tenant_b_db,$(TENANT)_db)))
	@echo "$(BLUE)📊 $(DATABASE)のテーブル一覧...$(RESET)"
	@docker-compose exec postgres psql -U dbt_user -d $(DATABASE) -c "\dt public_public.*" || echo "テーブルが見つかりません"

db-schemas: ## 📋 スキーマ一覧表示 (TENANT=tenant_name)
	@$(eval TENANT := $(or $(TENANT),$(DEFAULT_TENANT)))
	@$(eval DATABASE := $(if $(filter $(TENANT),tenant_a),tenant_a_db,$(if $(filter $(TENANT),tenant_b),tenant_b_db,$(TENANT)_db)))
	@echo "$(BLUE)📋 $(DATABASE)のスキーマ一覧...$(RESET)"
	@docker-compose exec postgres psql -U dbt_user -d $(DATABASE) -c "\dn"

db-tenant-info: ## ℹ️ テナント情報表示 (TENANT=tenant_name)
	@$(eval TENANT := $(or $(TENANT),$(DEFAULT_TENANT)))
	@$(eval DATABASE := $(if $(filter $(TENANT),tenant_a),tenant_a_db,$(if $(filter $(TENANT),tenant_b),tenant_b_db,$(TENANT)_db)))
	@echo "$(BLUE)ℹ️ テナント$(TENANT)の情報...$(RESET)"
	@echo "🗄️ データベース: $(DATABASE)"
	@docker-compose exec postgres psql -U dbt_user -d $(DATABASE) -c "SELECT tenant_name, source_s3_bucket, source_s3_prefix, count(*) as record_count FROM public_public.stg_customers_tenant GROUP BY tenant_name, source_s3_bucket, source_s3_prefix;" 2>/dev/null || echo "テナント情報テーブルが見つかりません"

db-create-schemas: ## 🏗️ スキーマ作成
	@echo "$(BLUE)🏗️ スキーマ作成中...$(RESET)"
	@docker-compose exec postgres psql -U dbt_user -d tenant_a_db -c "CREATE SCHEMA IF NOT EXISTS staging;" || true
	@docker-compose exec postgres psql -U dbt_user -d tenant_b_db -c "CREATE SCHEMA IF NOT EXISTS staging;" || true
	@echo "$(GREEN)✅ スキーマ作成完了！$(RESET)"


##@ 🧪 テスト

test-all: ## 🧪 全テスト実行
	@echo "$(BLUE)🧪 全テスト実行開始...$(RESET)"
	@$(MAKE) test-tenant TENANT=$(TENANT_A)
	@$(MAKE) test-tenant TENANT=$(TENANT_B)
	@$(MAKE) test-analysis TENANT=$(TENANT_A)
	@echo "$(GREEN)✅ 全テスト完了！$(RESET)"

test-tenant: ## 🧪 テナント機能テスト (TENANT=tenant_name)
	@$(eval TENANT := $(or $(TENANT),$(DEFAULT_TENANT)))
	@echo "$(BLUE)🧪 テナント機能テスト ($(TENANT))...$(RESET)"
	@./scripts/run_tenant.sh $(TENANT)
	@echo "$(GREEN)✅ テナント$(TENANT)テスト完了！$(RESET)"

test-analysis: ## 🧪 分析機能テスト (TENANT=tenant_name)
	@$(eval TENANT := $(or $(TENANT),$(DEFAULT_TENANT)))
	@echo "$(BLUE)🧪 分析機能テスト ($(TENANT))...$(RESET)"
	@./scripts/run_analysis.sh $(TENANT) all
	@echo "$(GREEN)✅ 分析機能テスト完了！$(RESET)"

##@ 🎯 デモ・クイックスタート

demo: ## 🎬 フルデモ実行
	@echo "$(BLUE)🎬 フルデモ実行開始...$(RESET)"
	@echo "$(BLUE)================================================================$(RESET)"
	@$(MAKE) setup
	@$(MAKE) up
	@sleep 5
	@$(MAKE) tenant-a
	@$(MAKE) analysis-all TENANT=$(TENANT_A)
	@$(MAKE) tenant-b
	@$(MAKE) analysis-all TENANT=$(TENANT_B)
	@echo "$(GREEN)🎉 フルデモ完了！$(RESET)"

quick-start: ## ⚡ クイックスタート（テナントA）
	@echo "$(BLUE)⚡ クイックスタート開始...$(RESET)"
	@$(MAKE) up
	@sleep 5
	@$(MAKE) tenant-a
	@$(MAKE) analysis-basic TENANT=$(TENANT_A)
	@echo "$(GREEN)🎉 クイックスタート完了！$(RESET)"

##@ 🔧 開発者向け

dev-shell: ## 🐚 開発用シェル起動 (TENANT=tenant_name)
	@$(eval TENANT := $(or $(TENANT),$(DEFAULT_TENANT)))
	@echo "$(BLUE)🐚 開発用シェル起動 ($(TENANT))...$(RESET)"
	@docker-compose run --rm -e TENANT_NAME="$(TENANT)" dbt bash

dev-logs: ## 📋 開発用ログ監視
	@echo "$(BLUE)📋 開発用ログ監視開始...$(RESET)"
	@docker-compose logs -f

dev-reset: ## 🔄 開発環境リセット
	@echo "$(YELLOW)🔄 開発環境リセット中...$(RESET)"
	@$(MAKE) down
	@$(MAKE) clean
	@$(MAKE) setup
	@$(MAKE) up
	@echo "$(GREEN)✅ 開発環境リセット完了！$(RESET)"

##@ 📋 情報表示

info: ## ℹ️ プロジェクト情報表示
	@echo "$(BLUE)ℹ️ プロジェクト情報$(RESET)"
	@echo "$(BLUE)================================================================$(RESET)"
	@echo "📁 プロジェクト名: dbt-poc"
	@echo "🎯 目的: テナント管理型データ分析プラットフォーム"
	@echo "🏷️ 利用可能テナント: $(TENANT_A), $(TENANT_B)"
	@echo "📊 分析タイプ: basic, dashboard, products, all"
	@echo "🗄️ データベース: PostgreSQL 13"
	@echo "🔧 dbtバージョン: 1.8.0"
	@echo "$(BLUE)================================================================$(RESET)"

version: ## 📌 バージョン情報表示
	@echo "$(BLUE)📌 バージョン情報$(RESET)"
	@echo "dbt-poc: v1.0.0"
	@docker-compose run --rm dbt dbt --version

##@ 📝 使用例

examples: ## 📝 使用例表示
	@echo "$(BLUE)📝 使用例$(RESET)"
	@echo "$(BLUE)================================================================$(RESET)"
	@echo "$(GREEN)# 基本的な使用方法$(RESET)"
	@echo "make quick-start                    # クイックスタート"
	@echo "make tenant-a                       # テナントA実行"
	@echo "make analysis-all TENANT=tenant_a   # 全分析実行"
	@echo ""
	@echo "$(GREEN)# 動的テナント作成$(RESET)"
	@echo "make tenant-create TENANT=my_company           # 動的テナント作成"
	@echo "make tenant-create-and-run TENANT=my_company   # 作成＆実行"
	@echo "make tenant-run TENANT=my_company              # 動的テナント実行"
	@echo "make analysis-all TENANT=my_company            # 動的テナント分析"
	@echo ""
	@echo "$(GREEN)# テナント別実行$(RESET)"
	@echo "make tenant-run TENANT=tenant_a     # 指定テナント実行"
	@echo "make analysis-basic TENANT=tenant_b # テナントB基本分析"
	@echo ""
	@echo "$(GREEN)# 開発・デバッグ$(RESET)"
	@echo "make dbt-debug TENANT=tenant_a      # dbt接続確認"
	@echo "make db-connect TENANT=tenant_a     # DB接続"
	@echo "make dev-shell TENANT=tenant_a      # 開発シェル"
	@echo ""
	@echo "$(GREEN)# データベース・テーブル確認$(RESET)"
	@echo "make db-status                      # 全データベース一覧"
	@echo "make db-list-tenants                # テナントDB一覧"
	@echo "make db-tables TENANT=my_company    # テーブル一覧"
	@echo "make db-schemas TENANT=my_company   # スキーマ一覧"
	@echo "make db-tenant-info TENANT=my_company # テナント情報"
	@echo ""
	@echo "$(GREEN)# クリーンアップ$(RESET)"
	@echo "make tenant-clean                   # 事前定義テナントクリーンアップ"
	@echo "make tenant-clean-dynamic TENANT=my_company # 動的テナントクリーンアップ"
	@echo ""
	@echo "$(GREEN)# フルデモ$(RESET)"
	@echo "make demo                           # 全機能デモ"
	@echo "$(BLUE)================================================================$(RESET)" 