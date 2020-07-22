#IoT LoRa Controller Docker File
#(C) Pi Supply 2019
#Licensed under the GNU GPL V3 License.

FROM debian:buster-slim

WORKDIR /opt/iotloragateway/controller

RUN echo 'Acquire::http { Proxy "http://192.168.0.8:3142"; }' | sudo tee -a /etc/apt/apt.conf.d/proxy &&\
apt-get update && \
apt-get upgrade -y && \
apt-get install -y --no-install-recommends nginx-light php7.3-fpm  php7.3-json \
php7.3-curl curl php7.3-zip unzip wget \
libyaml-0-2 ca-certificates && \
apt-get autoremove -y && \
rm -rf /var/lib/apt/lists/* && \
apt-get clean

RUN apt-get update && \
apt-get install -y --no-install-recommends sudo build-essential php7.3-dev php-pear libyaml-dev && \
pecl channel-update pecl.php.net && pecl install yaml-2.0.4 && \
echo "extension=yaml.so" > /etc/php/7.3/fpm/conf.d/20-yaml.ini && \
pecl clear-cache && \
apt-get remove -y --no-install-recommends build-essential php7.3-dev php-pear libyaml-dev && \
apt-get autoremove -y && \
rm -rf /var/lib/apt/lists/* && \
apt-get clean

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

ARG moo=16071536

RUN wget https://github.com/PiSupply/iot-lora-controller/archive/yamlConversion.zip && unzip yamlConversion.zip && \
rm yamlConversion.zip && mv iot-lora-controller-yamlConversion iot-lora-controller

RUN rm /etc/nginx/sites-enabled/default & rm /etc/nginx/sites-available/default

WORKDIR /etc/nginx/sites-available

COPY files/iotloragateway .

RUN ln -s /etc/nginx/sites-available/iotloragateway /etc/nginx/sites-enabled/

EXPOSE 80 443

WORKDIR /opt/iotloragateway/controller
COPY files/dhparam.pem .
COPY files/gateway_configuration.yml .
COPY files/run.sh .

RUN chmod +x run.sh


ENTRYPOINT ["sh", "/opt/iotloragateway/controller/run.sh"]
