# PythonでMySQLを使用する

## 環境構築の流れ
以下のようなcsvファイルをDBのテーブルに挿入し、Pythonからアクセスしたい。
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
$ cd Python_DB/MySQL/project
$ docker-compose up
```
DBの起動を少し待った後、`myproject`ディレクトリ下の`main.ipynb`を順に実行すれば、データを呼び出せる。

## 各要素の説明

本節では`Dockerfile`と`docker-compose.yml`の詳しい内容を説明する。
### ディレクトリ構成
```
project/
　├ DB/
　│ 　├ Dockerfile
　│ 　├ init.sh
　│ 　└ mytable.csv
　├ Jupyter/
　│ 　├ Dockerfile
　│ 　└ requirements.txt
　├ docker-compose.yml
　└ mountpoint/
```

### `DB/Dockerfile`

```Dockerfile
FROM mysql:8.0

COPY init.sh /docker-entrypoint-initdb.d/
COPY mytable.csv /var/lib/mysql-files/
```
MySQLイメージでは、`docker-entrypoint-init.d`下に`.sh`ファイルをおくと、コンテナ作成時に自動実行される。init.shは次のようになっている。

```sh
# init.sh

COMMAND='
CREATE DATABASE db;
USE db;

CREATE TABLE mytable 
( 
    id int, 
    name char(20)
);

LOAD DATA INFILE "/var/lib/mysql-files/mytable.csv" INTO TABLE mytable FIELDS TERMINATED BY "," LINES TERMINATED BY "\r\n" IGNORE 1 LINES;'

mysql --user=root --password=root --execute="$COMMAND"
```
データベース`db`とテーブル`mytable`を作成し、`mytable.csv`のデータを取り込んでいる。

### `Jupyter/Dockerfile`

```Dockerfile
FROM python:3.7

COPY requirements.txt ./

RUN pip install --upgrade pip \
  && pip install -r requirements.txt

WORKDIR /home/

EXPOSE 8888

CMD jupyter lab --ip=0.0.0.0 --port=8888 --allow-root
```
`pip install -r requirements.txt`では、各種主要パッケージと、PythonでMySQLを扱うためのパッケージ`mysqlclient`をインストールしている。

```t
# requirements.txt

jupyterlab
matplotlib
mysqlclient
numpy
pandas
```

### `docker-compose.yml`
```yaml
version: "2"
services:
  jupyter:
    build:
     context: Jupyter
     dockerfile: Dockerfile
    volumes:
      - ./mountpoint:/home
    ports:
      - "8888:8888"
    depends_on:
      db:
        condition: service_started
  db:
    build:
      context: DB
      dockerfile: Dockerfile
    environment:
      - MYSQL_ROOT_PASSWORD=root
```
作業ディレクトリ`/home`をローカルディレクトリ`./mountpoint`にマウントしている。

`jupyter`は`db`起動後に起動させたいため、`depends_on`で`condition: service_started`の設定をしている。

`MYSQL_ROOT_PASSWORD`は、MySQLのrootユーザーのパスワードである。