FROM acrunirjdcr.azurecr.io/nginx:latest

COPY index.html /usr/share/nginx/html

COPY nginx.conf /etc/nginx/nginx.conf

COPY .htpasswd /etc/nginx/.htpasswd

COPY WebServer.crt /etc/ssl/certs
RUN chmod 644 /etc/ssl/certs/WebServer.crt

COPY WebServer.key /etc/ssl/private
RUN chmod 600 /etc/ssl/private/WebServer.key