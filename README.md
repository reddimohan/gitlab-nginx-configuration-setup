## Gitlab + Nginx configuration

I came accross with a problem recently with Nginx sites (multiple domain/subdomains pointed to default port 80) and Gitlab. I was unable to use the port 80 for Gitlab since It is already being used by other domains.

So here is the solution worked for me.

 - Let's install the Gitlab first - I used this [Tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-gitlab-on-ubuntu-18-04), but things dint work as expected since my Nginx sites are already using port 80.
 - Used port 8081 (which is free in my Server) and redirected 8081 to 80 by creating nginx conf file in sites-available folder.
 ```sh
    $ external_url 'https://gitlab.yourdomain.com:8081'
 ```
  - Then create symblink and reload the nginx and it is done.

#### Generate Free SSL sertificate from [Letsencrypt](https://letsencrypt.org)
Command to generate certificates
```sh
  $ sudo certbot -d gitlab.yourdomain.com --manual --preferred-challenges dns certonly
```

###### Add/Modify following code in gitlab.rb file -  `/etc/gitlab/gitlab.rb`
```sh
# give your subdomain with the port number
external_url 'https://gitlab.yourdomain.com:8081'

# Cetificates path
nginx['ssl_certificate'] = "/etc/letsencrypt/live/gitlab.yourdomain.com/fullchain.pem"
nginx['ssl_certificate_key'] = "/etc/letsencrypt/live/gitlab.yourdomain.com/privkey.pem"

# This example renews every 7th day at 12:30 as per the documentation
letsencrypt['auto_renew_hour'] = "12"
letsencrypt['auto_renew_minute'] = "30"
letsencrypt['auto_renew_day_of_month'] = "*/7"

nginx['custom_gitlab_server_config'] = "location /.well-known/acme-challenge/ {\n root /var/opt/gitlab/nginx/www/; \n}\n"
```

###### This is how my gitlab-nginx.conf file looks - `/etc/nginx/sites-available/gitlab_proxy`
```sh
server {
    listen *:80;
    # listen [::]:80 ipv6only=on default_server; # Enable this line If you are using 80 port for only one domain

    server_name gitlab.yourdomain.com; # your sub domain
    return 301 https://$server_name$request_uri;

    # redirecting gitlab logs to nginx logs - Optional
    access_log /var/log/nginx/gitlab_access.log;
    error_log /var/log/nginx/gitlab_error.log;
}

server{
    listen 0.0.0.0:443 ssl http2;
    # listen [::]:443 ipv6only=on ssl default_server;  # Enable this line If you are using 80 port for only one domain
    server_name gitlab.yourdomain.com;
    server_tokens off;

    ssl off;
    # ssl certificate path
    ssl_certificate /etc/letsencrypt/live/gitlab.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/gitlab.yourdomain.com/privkey.pem;

    location ~ /.well-known {
        allow all;
    }

    location /{
        proxy_pass https://localhost:8081;
        proxy_redirect off;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Protocol $scheme;
        proxy_set_header X-Url-Scheme $scheme;
    }
}
```
