# mosk-wikijs-backup


Восстановление.


1. Запустить Сервисы (в том числе базу, куда вливается бекап).

`docker-compose up -d` (или `docker-compose up`  если нужно наблюдлать логи)


2. Восстановить базу из дампа

`docker exec -i wikijs_db_1  pg_restore  -U wikijs -d wiki -c   -v < wikibackup.dump`


3. Перезапустить сервисы

`docker-compose down; docker-compose up -d`


4. В браузере: http://127.0.0.1:80/

  login: `superadmin@no-such-domain.tld`
  password: `superadmin`
