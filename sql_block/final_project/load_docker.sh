#создаем директорию для хранения и обмена данными
mkdir -p $HOME/docker/volumes/postgres
#запускаем докер-контейнер имя pg-docker порт 5432 в background mode и маппим директории с localhost на директорию постгрес в контейнере
docker run --rm   --name pg-docker -e POSTGRES_PASSWORD=docker -d -p 5432:5432 -v $HOME/docker/volumes/postgres:/var/lib/postgresql/data  postgres
#запускаем bash от контейнера
sudo  docker exec -it pg-docker  bash
#подключаемся к постгрес
psql -h localhost -U postgres -d postgres