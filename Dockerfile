FROM python:3.7.4-alpine3.10
MAINTAINER D_BISWAL<chiku71@live.com>

RUN apk update
RUN apk add nginx
RUN apk add --update supervisor

# Check installed packages
RUN apk info -vv | sort

# Install required packages
RUN apk add --no-cache --virtual .build-deps \
		gcc \
		libc-dev \
		linux-headers \
		curl


RUN apk add gfortran

# Install UWSGI
RUN pip3 install uwsgi

# Install Python requirements for Flask Server
COPY ./requirements.txt /project/requirements.txt
RUN pip3 install -r /project/requirements.txt

# Expose the Listener Port
EXPOSE 7777

# Setup the UWSGI-NGINX configurations
COPY nginx.conf /etc/nginx/
COPY flask-site-nginx.conf /etc/nginx/conf.d/
COPY uwsgi.ini /etc/uwsgi/
COPY supervisord.conf /etc/

# Copy the App folder
COPY /app /project

# Add extra file permission to the folder if not available
RUN chmod -R 777 /project

WORKDIR /project

CMD ["/usr/bin/supervisord"]
