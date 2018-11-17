#!/bin/sh

# команда для загрузки файла в MONGO
/usr/bin/mongoimport --host $APP_MONGO_HOST --port $APP_MONGO_PORT --db movies --collection tags --file /data/simple_tags.json

/usr/bin/mongo $APP_MONGO_HOST:$APP_MONGO_PORT/movies /home/agg.js