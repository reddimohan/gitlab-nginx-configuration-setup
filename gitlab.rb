# Add or Modify your `/etc/gitlab/gitlab.rb` file as follows and leave the other lines as it is.

external_url 'https://gitlab.yourdomain.com:8081'


# Cetificates path
nginx['ssl_certificate'] = "/etc/letsencrypt/live/gitlab.yourdomain.com/fullchain.pem"
nginx['ssl_certificate_key'] = "/etc/letsencrypt/live/gitlab.yourdomain.com/privkey.pem"


# This example renews every 7th day at 12:30 as per the documentation
letsencrypt['auto_renew_hour'] = "12"
letsencrypt['auto_renew_minute'] = "30"
letsencrypt['auto_renew_day_of_month'] = "*/7"

nginx['custom_gitlab_server_config'] = "location /.well-known/acme-challenge/ {\n root /var/opt/gitlab/nginx/www/; \n}\n"
