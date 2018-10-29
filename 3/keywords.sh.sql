psql --host  $APP_POSTGRES_HOST -U postgres -c \
"DROP TABLE IF EXISTS keywords;"

psl --host $APP_POSTGRES_HOST -U postgres -c \
"CREATE TABLE keywords (
    movieId bigint,
    tags text
);"

psql --host $APP_POSTGRES_HOST -U postgres -c \
"\\copy keywords from '/data/keywords.csv' DELIMITER ',' CSV HEADER"
