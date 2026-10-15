# docker-homework-19

Студент: Штыфман Георгий Владимирович, вариант 19.
Уникальный id - `0e9cccb4`

## Требования

Docker (без Docker Compose), bash, доступ в интернет для загрузки базовых образов (`golang`, `alpine`, `nginx`).

## Запуск

```bash
./scripts/start.sh
```

1. создаёт сеть и volume, если их нет;
2. создаёт в volume `message.txt` с начальным текстом, если файла ещё нет (существующий не перезаписывается);
3. собирает оба образа;
4. пересоздаёт контейнеры и запускает их с лимитами CPU и памяти.

После запуска стенд доступен на http://localhost:8019/.

## Остановка

```bash
./scripts/stop.sh                   # удаляет контейнеры и сеть, volume сохраняется
REMOVE_VOLUME=1 ./scripts/stop.sh   # дополнительно удаляет volume
```

## Проверка

```bash
curl http://localhost:8019/            # стартовая страница
curl http://localhost:8019/api         # 200 OK
curl http://localhost:8019/api/info    # данные студента, hostname, message из volume

docker ps                              # оба контейнера, статус (healthy)
docker network inspect docker-homework-19
docker stats --no-stream               # применённые лимиты CPU и памяти
docker port docker-homework-19-backend # пусто: порт backend не опубликован
```

Healthcheck:

```bash
docker inspect -f '{{.State.Health.Status}}' docker-homework-19-backend
docker inspect -f '{{.State.Health.Status}}' docker-homework-19-frontend
```

Лимиты:

```bash
docker inspect -f 'cpu={{.HostConfig.NanoCpus}} mem={{.HostConfig.Memory}}' docker-homework-19-backend
docker inspect -f 'cpu={{.HostConfig.NanoCpus}} mem={{.HostConfig.Memory}}' docker-homework-19-frontend
```

Backend недоступен с хоста напрямую: порт не опубликован, IP из сети с хоста не используется. Достижимость изнутри сети по имени:

```bash
docker exec docker-homework-19-frontend wget -qO- http://backend:8019/api/info
```

### Данные в volume

Изменить файл:

```bash
docker exec docker-homework-19-backend sh -c 'echo "новый текст" > /data/message.txt'
curl http://localhost:8019/api/info
```

Проверить, что данные переживают пересоздание backend:

```bash
docker rm -f docker-homework-19-backend
./scripts/start.sh
curl http://localhost:8019/api/info
```

## Скриншот

[![docker-homework-19.jpg](https://i.postimg.cc/fyw10bkY/docker-homework-19.jpg)](https://postimg.cc/G85XWdFp)
