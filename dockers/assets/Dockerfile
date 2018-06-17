FROM ajacques/certmanager:latest

FROM nginx:latest

COPY --from=0 /rails-app/public /var/www
ADD default.conf /etc/nginx/conf.d/default.conf
