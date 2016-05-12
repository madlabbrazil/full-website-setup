# Full-Website-Setup

```
docker build -f dockerfiles/Dockerfile-mariadb -t full-website-db . &&
docker run -d --name fllws-database --hostname madlab-full-website-db full-website-db
```

Criar o disco de arquivos

```
docker  create --name fllws-website-data --volume /www debian:jessie
```

criar as instancias PHP
```
docker build -f dockerfiles/Dockerfile-php5-6 -t full-website-php5-6 . &&
docker  run -d --name fllws-php5-6 --volumes-from fllws-website-data --link fllws-database full-website-php5-6
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