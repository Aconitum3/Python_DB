FROM python:3.7

COPY init.sql ./
COPY mytable.csv ./

RUN apt-get update \
  && apt-get install sqlite3 -y \
  && sqlite3 -init init.sql mydb

COPY requirements.txt ./

RUN pip install --upgrade pip \
  && pip install -r requirements.txt

WORKDIR /home/

EXPOSE 8888

CMD jupyter lab --ip=0.0.0.0 --port=8888 --allow-root