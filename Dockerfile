FROM ubuntu:16.04
MAINTAINER Yanfu Zhou <yanfu.zhou@outlook.com>
LABEL Vendor="TBD" \
      Version=1.0.0

ENV WORKER_NUM 4
ENV PORT 4000
ENV APP_START viewshed
ARG APP_NAME=viewshed-wps

RUN apt-get -y update && \
	apt-get install -y software-properties-common && \
	add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable && \
	apt-get -y update && \
	apt-get -y upgrade && \
	apt-get -y install python-pip && \
	pip install -U pip && \
	pip install wheel==0.30.0a0 && \ 
	apt-get -y install gdal-bin python-gdal python3-gdal && \
	pip install gdal && \
	pip install -U numpy && \
	apt-get clean && \
	apt-get autoclean && \
	apt-get autoremove

COPY ${APP_NAME}.tar.gz /${APP_NAME}.tar.gz
RUN tar -xzf ${APP_NAME}.tar.gz && \
	rm ${APP_NAME}.tar.gz && \
	mv ${APP_NAME} /src

WORKDIR /src
ADD requirements.txt .
RUN echo "#!/bin/bash" >> setenv.sh && \
	echo "pip install --no-cache-dir -r requirements.txt" >> setenv.sh && \
	chmod +x setenv.sh && \
	./setenv.sh && \
	rm -f requirements.txt && \
	rm -f setenv.sh && \
	echo "#!/bin/bash" >> startup.sh && \
	echo "gunicorn -w ${WORKER_NUM} -k gevent -b 0.0.0.0:${PORT} ${APP_START}:app" >> startup.sh && \
	chmod +x startup.sh

EXPOSE ${PORT}

CMD ["./startup.sh"]