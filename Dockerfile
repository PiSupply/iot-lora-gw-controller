#IoT LoRa Controller Docker File
#(C) Pi Supply 2019
#Licensed under the GNU GPL V3 License.

FROM arm32v6/alpine:latest

WORKDIR /opt/iotloragateway/controller

RUN apk update && apk upgrade

RUN apk add  nginx php7-fpm  php7-json php7-curl git curl \
 php7-zip unzip yaml-dev php7-pear php7-dev php7-openssl build-base gcc 

RUN pecl install yaml-2.0.4

RUN echo "extension=yaml.so" > /etc/php/7.3/fpm/conf.d/20-yaml.ini

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

ARG moo=107

RUN git clone -b yamlConversion --single-branch https://github.com/PiSupply/iot-lora-controller.git

RUN rm /etc/nginx/sites-enabled/default & rm /etc/nginx/sites-available/default

WORKDIR /etc/nginx/sites-available

COPY files/iotloragateway .

RUN ln -s /etc/nginx/sites-available/iotloragateway /etc/nginx/sites-enabled/




EXPOSE 80 443

WORKDIR /opt/iotloragateway/controller
COPY files/gateway_configuration.yml .
COPY files/run.sh .

RUN chmod +x run.sh


ENTRYPOINT ["sh", "/opt/iotloragateway/controller/run.sh"]
