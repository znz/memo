target "myimage" {
  dockerfile-inline = <<EOT
ARG BASE_IMAGE="ghcr.io/cloudnative-pg/postgresql:17.6-standard-bookworm"
FROM $BASE_IMAGE AS builder

ARG PG_VERSION=17

# rootユーザーに切り替えて必要なパッケージをインストール
USER root

# ビルドに必要なツールとunzipをインストール
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libaio1 \
    postgresql-server-dev-$PG_VERSION \
    curl \
    unzip \
    git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/oracle

# Oracle Instant ClientのZIPファイルをダウンロード
# 注意: ダウンロードURLは変更される可能性があります。事前にOracleのサイトで確認してください。
#       ライセンス契約に同意する必要があります。

# https://www.oracle.com/jp/database/technologies/instant-client/linux-x86-64-downloads.html
# https://www.oracle.com/database/technologies/instant-client/linux-arm-aarch64-downloads.html

# Instant Client (basic)のダウンロードと展開
RUN if [ `uname -m` = aarch64 ]; then \
      ORACLE_CLIENT_URL=https://download.oracle.com/otn_software/linux/instantclient/1928000/instantclient-basic-linux.arm64-19.28.0.0.0dbru.zip ; \
    else \
      ORACLE_CLIENT_URL=https://download.oracle.com/otn_software/linux/instantclient/1927000/instantclient-basic-linux.x64-19.27.0.0.0dbru.zip ; \
    fi && \
    curl -o instantclient-basic.zip "$ORACLE_CLIENT_URL" && \
    unzip instantclient-basic.zip && \
    rm instantclient-basic.zip

# Instant Client (SDK)のダウンロードと展開
RUN if [ `uname -m` = aarch64 ]; then \
      ORACLE_SDK_URL=https://download.oracle.com/otn_software/linux/instantclient/1928000/instantclient-sdk-linux.arm64-19.28.0.0.0dbru.zip ; \
    else \
      ORACLE_SDK_URL=https://download.oracle.com/otn_software/linux/instantclient/1927000/instantclient-sdk-linux.x64-19.27.0.0.0dbru.zip ; \
    fi && \
    curl -o instantclient-sdk.zip "$ORACLE_SDK_URL" && \
    unzip -o instantclient-sdk.zip && \
    rm instantclient-sdk.zip

# ライブラリパスの設定
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_19_28:/opt/oracle/instantclient_19_27
RUN echo /opt/oracle/instantclient_* > /etc/ld.so.conf.d/oracle-instantclient.conf && \
    ldconfig

# oracle_fdwのソースコードを取得してビルド
# USE_PGXS=1 を使うことで、pg_config を使った標準的な拡張機能のビルドプロセスが実行される
WORKDIR /tmp
RUN export ORACLE_HOME=$(echo /opt/oracle/instantclient_*) && \
    git clone https://github.com/laurenz/oracle_fdw.git /tmp/oracle_fdw && \
    cd /tmp/oracle_fdw && \
    make USE_PGXS=1 && \
    make USE_PGXS=1 install

# postgresユーザーに戻す
USER postgres

# CloudNative-PGの公式イメージをベースにした最終的なイメージ
FROM $BASE_IMAGE AS myimage

# --- Arguments (for consistency) ---
ARG PG_VERSION=17

# --- Switch to root user for installation ---
USER root

# --- Install Runtime Dependencies ---
# Oracle Clientの実行時に必要なライブラリをインストール
RUN apt-get update && \
    apt-get install -y --no-install-recommends libaio1 && \
    rm -rf /var/lib/apt/lists/*

# --- Copy Artifacts from Builder Stage ---
# builderステージから必要なファイルのみをコピーする
# 1. Oracle Instant Client の実行時ライブラリ
COPY --from=builder /opt/oracle /opt/oracle
# 2. コンパイルされた oracle_fdw 拡張機能
COPY --from=builder /usr/lib/postgresql/$PG_VERSION/lib/oracle_fdw.so /usr/lib/postgresql/$PG_VERSION/lib/
COPY --from=builder /usr/share/postgresql/$PG_VERSION/extension/oracle_fdw* /usr/share/postgresql/$PG_VERSION/extension/

# --- Configure Dynamic Linker ---
# OSがOracleの共有ライブラリを見つけられるように設定
RUN echo /opt/oracle/instantclient_* > /etc/ld.so.conf.d/oracle-instantclient.conf && \
    ldconfig

# --- Switch back to postgres user ---
USER postgres
EOT

  matrix = {
    tgt = [
      "myimage"
    ]
    pgVersion = [
      "17.6",
    ]
  }
  name = "postgresql-${index(split(".",cleanVersion(pgVersion)),0)}-standard-bookworm"
  target = "${tgt}"
  args = {
    BASE_IMAGE = "ghcr.io/cloudnative-pg/postgresql:${cleanVersion(pgVersion)}-standard-bookworm",
    PG_VERSION = "${index(split(".",cleanVersion(pgVersion)),0)}",
  }
}
