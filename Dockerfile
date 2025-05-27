FROM python:3.9-slim

WORKDIR /dbt_project

# Install PostgreSQL client libraries and git
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    git \
    && rm -rf /var/lib/apt/lists/*

# 必要なPythonパッケージをインストール
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# dbtプロジェクトとprofiles.ymlをコピー
COPY . /dbt_project
# COPY profiles.yml /root/.dbt/profiles.yml # 必要であれば profiles.yml をコピーする

CMD ["dbt"]