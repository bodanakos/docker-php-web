FROM alpine:3.17.2

# Define args that came from Makefile
ARG PHP_VERSION
ARG WEB_SERVER

# Install packages
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk --update --no-cache add \
                           ${WEB_SERVER} \
                           php${PHP_VERSION}-gd \
                           php${PHP_VERSION}-mysqli \
                           php${PHP_VERSION}-pdo_mysql && \
    if [ "${WEB_SERVER}" = "apache2" ]; then \
        chown apache:apache /var/www/localhost/htdocs; \
        sed -i 's/#LoadModule\ rewrite_module/LoadModule\ rewrite_module/g' /etc/apache2/httpd.conf;  \
    fi; \
    if [ "${WEB_SERVER}" = "nginx" ]; then \
        sed -i 's/user nginx;/user root;/' /etc/nginx/nginx.conf; \
        sed -i 's/worker_processes  auto;/worker_processes  1;/' /etc/nginx/nginx.conf; \
#        ln -s /dev/stdout /var/log/nginx/access.log; \
#        ln -s /dev/stderr /var/log/nginx/error.log; \
    fi

# Set the working directory to /var/www/localhost/htdocs
WORKDIR /var/www/localhost/htdocs

# Copy the current directory contents into the container at /var/www/localhost/htdocs
COPY ./htdocs /var/www/localhost/htdocs

# Expose port 80 for Apache/Nginx
EXPOSE 80

# Copy start script
COPY inc/start-${WEB_SERVER}.sh /opt/start.sh
RUN chmod +x /opt/start.sh

CMD /opt/start.sh
