# FOG Project in Docker

This project is maintained by [Linkat](http://linkat.xtec.cat).

In this repository there are provided the files for building a docker image for running the [FOG Project](https://fogproject.org/).


## DockerHub

You can find the docker image releases at https://hub.docker.com/r/linkat/fogproject


## Repository

Public repository in GitLab: https://gitlab.com/linkatedu/fogproject

## Releases

Code releases are found at https://gitlab.com/linkatedu/fogproject/tags

Docker image releases are found at https://hub.docker.com/r/linkat/fogproject/tags


## Build

The [Dockerfile](https://gitlab.com/linkatedu/fogproject/blob/master/Dockerfile) file defines all needed for building the image. It can be built with:

```
VERSION=0.0.1
docker build -t linkat/fogproject:$VERSION .
```


**(!)** *The previous version code `0.0.1` is an example.*


## Run

### Environment parameters

The following environment variables must be defined:

* **IP**. (Mandatory) The IP address assigned to the Docker Host which will be run this container.
* **APACHE_ROOT_REDIRECTION**. (Optional) An URL to redirect from root path "/". If not preset, it redirects to "/fog".
* **WEBSERVER_HTTP_PORT**. (REMOVED since version 1.0.3) The Apache running port. Default value: 80.

### docker-run

If you want to mount a volume data for images and MySQL data, you can use:

```
docker run -d --restart=always -e IP=192.168.1.225 -p 80:80 -p 69:69/tcp -p 69:69/udp -p 21:21 -p 9000:9000 -v "<PATH_TO_LOCAL_IMAGES_FOLDER>":"/images" -v "<PATH_TO_LOCAL_MYSQL_DATA_FOLDER>":"/var/lib/mysql" --name fogproject linkat/fogproject:1.0.3
```

If not (not recommended), you can use

```
docker run -d --restart=always -e IP=192.168.1.225 -p 80:80 -p 69:69/tcp -p 69:69/udp -p 21:21 -p 9000:9000 --name fogproject linkat/fogproject:1.0.3
```

### docker-compose

Or using [docker-compose.yml](https://gitlab.com/linkatedu/fogproject/blob/master/docker-compose.yml) file:

```
docker-compose up -d
```
