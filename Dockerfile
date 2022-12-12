FROM nginx
COPY app /usr/share/nginx/html
VOLUME /usr/share/nginx/html
VOLUME /etc/nginx