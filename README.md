# Full-Website-Setup

```
docker build -f dockerfiles/Dockerfile-mysql -t full-website-db . &&
docker run -d --name fllws-database-master --hostname master.madlabbrazil.com full-website-db &&
docker run -d --name fllws-database-slave --hostname slave.madlabbrazil.com --link fllws-database-master full-website-db
```
### Espere 5 min para o MySQL finalizar algumas configurações internas

```
docker cp my-master.cnf fllws-database-master:/etc/mysql/my.cnf &&
docker cp my-slave.cnf fllws-database-slave:/etc/mysql/my.cnf &&
docker restart fllws-database-master fllws-database-slave
```
### Espere 5 min para o MySQL estar pronto para receber conexões
```
docker exec -it fllws-database-master mysql -pVoYTuebBX5srpCz -e 'CREATE USER "replication_server1"@"172.17.0.%" IDENTIFIED BY "084T92x0x0B998M"; GRANT REPLICATION SLAVE ON *.* TO "replication_server1"@"172.17.0.%";' &&
docker exec -it fllws-database-slave mysql -pVoYTuebBX5srpCz -e 'CHANGE MASTER TO MASTER_HOST = "master.madlabbrazil.com", MASTER_PORT = 3306, MASTER_USER = "replication_server1", MASTER_PASSWORD = "084T92x0x0B998M", MASTER_LOG_FILE="mysql-bin.000001", MASTER_LOG_POS=0;START SLAVE;'
```

Criar o disco de arquivos

```
docker  create --name fllws-website-data --volume /www debian:jessie
```

criar as instancias PHP
```
docker build -f dockerfiles/Dockerfile-php5-6 -t full-website-php5-6 . &&
docker  run -d --name fllws-php5-6 --volumes-from fllws-website-data --link fllws-database-master --link fllws-database-slave full-website-php5-6
```

```
docker build -f dockerfiles/Dockerfile-nginx -t full-website-nginx . &&
docker run -d --name fllws-nginx --volumes-from fllws-website-data  --link fllws-php5-6  full-website-nginx &&
docker exec fllws-nginx /start-nginx.sh &&
docker restart fllws-nginx
```

```
docker build -f dockerfiles/Dockerfile-varnish -t full-website-varnish .
docker run -d --name fllws-varnish --link fllws-nginx --volumes-from fllws-website-data --env 'VCL_CONFIG=/default.vlc' full-website-varnish
```