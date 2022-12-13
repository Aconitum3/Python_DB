# PythonでSQLiteを使用する

## 環境構築の流れ
以下のようなcsvファイルをDBのテーブルに挿入し、JupyterLabからアクセスしたい。
|id|name|
|--|--|
|1|Taro|
|2|Jiro|
|3|Hanako|
|4|Pochi|

### リポジトリのクローン
はじめに、リポジトリをローカル環境にクローンする。
```bash
$ git clone https://github.com/Aconitum3/Python_DB
```

### プロジェクトの起動
次のコマンドを実行してコンテナに接続する。
```bash
$ cd Python_DB/SQLite/project
$ docker-compose up
```
DBの起動を少し待った後、`myproject`ディレクトリ下の`main.R`を順に実行すれば、データを呼び出せる。

## 各要素の説明

本節では`Dockerfile`と`docker-compose.yml`の詳しい内容を説明する。
### ディレクトリ構成
```
project/
　├ Dockerfile
　├ init.sql
　├ mytable.csv
　├ packages.R
　├ docker-compose.yml
　└ mountpoint/
```

### `Dockerfile`

```Dockerfile
FROM rocker/rstudio:4

COPY init.sql ./
COPY mytable.csv ./

RUN apt-get update \
  && apt-get install sqlite3 -y \
  && sqlite3 -init init.sql mydb

COPY packages.R ./

EXPOSE 8787

RUN Rscript packages.R
```
rocker/rstudioイメージをベースにsqlite3をインストールしている。`sqlite3 -init init.sql mydb`では、新規データベース`mydb`を作成し、`init.sql`で初期化している。`init.sql`は次のようになっている。

```sql
# init.sql
.mode csv
.import ./mytable.csv mytable
```
テーブル`mytable`を作成し、`mytable.csv`のデータを取り込んでいる。

packages.Rでは、RでSQLiteを扱うためのパッケージ`RSQLite`をインストールしている。ここで、`Rcpp`は`RSQLite`の依存パッケージである。
```R
# packages.R

install.packages(c("Rcpp", "RSQLite"))
```

### `docker-compose.yml`
```yaml
version: "2"
services:
  r:
    build:
      context: .
      dockerfile: Dockerfile
    volumes:
      - ./mountpoint:/home/rstudio/myproject
    ports:
     - "8787:8787"
```
作業ディレクトリ`/home/rstudio`下の`myproject`ディレクトリをローカルディレクトリ`./mountpoint`にマウントしている。