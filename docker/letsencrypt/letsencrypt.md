# Lets encrypt

Adding encryption to the http server using letsencrypt.

This involve 3 things getting the letsencrypt *cert*ificate, change to https
and renew the certs.

## Create certs.

Letsencrypt [certbot](https://certbot.eff.org/#ubuntuxenial-nginx) creates
the certs by answer some http request for webroot files.
If you turn of the server it can handle every thing but if you do not want to go offline
your own server must serve the files for every subdomain.

The renew use the same process of optaining the certs going offline first time is ok but not for 
renewal. So our server must serve the files.
The rezder already serve root /var/www/html/rezder we need to add to battleline file.

```
location ~ /.well-known{
    root /var/www/html/battleline;
}
```
The question files is put in "/.well-known/acme-challenge" and then removed.

First idea was to make image with letsencrypt but the letsencrypt and nginx 
need each others files and letsencrypt is not a running container.
Nginx need certs and letsencrypt need webroot and both need consistent data.

Nginx: "/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"
Letsencrypt: "/etc/letsencrypt", "/var/lib/letsencrypt","/var/log/letsencrypt"

I could make a letsencrypt image:
```
RUN apt-get update && apt-get install -y letsencrypt
CMD ["/bin/bash"]
```
Create letsencrypt data container
```
docker run \
  --name letsencrypt-data \
  --volume /etc/letsencrypt \
  --volume /var/log/letsencrypt \
  imletsencrypt
  
```
Run letsencrypt commands linking to the data and nginx container
```
docker run --rm \
  --volumes-from cnginx \
  --volumes-from letsencrypt-data \
  imletsencrypt \
  letsencrypt certonly \
  --webroot \
  -w /var/www/html/rezder \
  -d rezder.com \
  -d www.rezder.com \
  -w /var/www/html/battleline \
  -d battleline.rezder.com \
  -m wwwrene@runbox.com \
  --agree-tos \
  --dry-run \
  -n;
  cp /etc/letsencrypt/live/rezder.com/privkey.pem  /etc/nginx/certs/rezder; \
  cp /etc/letsencrypt/live/rezder.com/fullchain.pem  /etc/nginx/certs/rezder; 
```
Remove dry-run.
The copy was remove to script installcerts.sh


Calculate the dhparmes.pem
```
docker run \
  --rm
  --volumes-from letsencrypt-data \
  ubuntu \
  openssl dhparam -out /etc/letsencrypt/dhparams.pem 2048
```

 I could just use nginx image with all the volumes except etc/nginx/certs
 maybe keep out dhparms first untill it works as it take time.
Add letsencrypt-data volumes to nginx image and run.


I do not know it would be easier to use letsencrypt to update another webserver
but more difficult to maintain and error trace as data is two places.


**Remember ufw allow https**

## Install certs

The https protocol does not allow name resolve as name is not exchanged only
ip my ssl\_certificate ssl\_certificate_key must be setup in the main conf block.
As all my servers will be https I set up as much as I can there.

Follow this [guide](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04)
for the ssl settings. A few modification based on [bjoern](https://bjornjohansen.no/optimizing-https-nginx) also looked in
to [session tickets vs session ids](https://vincent.bernat.im/en/blog/2011-ssl-session-reuse-rfc5077.html)
it is about who keeps the cache ticket client id server. Memory vs security I think.
Ticket of for now but as I do not have memory it proberly should not be.

The  guide for [websocket](https://siriux.net/2013/06/nginx-and-websockets/)

### Main conf
```
ssl_certificate /etc/nginx/certs/rezder.com/fullchain.pem;
ssl_certificate_key /etc/nginx/certs/rezder/privkey.pem;

# from https://cipherli.st/
# and https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html

ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
ssl_ecdh_curve secp384r1;
ssl_session_cache shared:SSL:20m;
ssl_session_timeout 60m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
# Disable preloading HSTS for now.  You can use the commented out header line that includes
# the "preload" directive if you understand the implications.
#add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;
ssl_dhparam /etc/ssl/certs/dhparam.pem;

```
### Rezder conf
```
listen 443 ssl http2 default_server;

```
### Battleline conf
```
listen 443 ssl http2;
```
Stop old container and start new with same volumes
```
docker run -d --name nginx -p 80:80 -p 443:443 --network webnet --volumes-from vgninx nginx
```
remove old container.

## Update certs
The certs only last for 3 months and it is recomended to upgrade a 1 month before.

```
docker run --rm \
  --volumes-from cnginx \
  --volumes-from letsencrypt-data \
  imletsencrypt \
  letsencrypt renew;
```
test 
```
docker run --rm \
  --volumes-from cnginx \
  --volumes-from letsencrypt-data \
  imletsencrypt \
  letsencrypt renew \
  --dry-run \
  --agree-tos;
```
It is recommended to run renew in a batch job every day at a time
that everybody else does not use ex 16.17.
It has a pre and post hook --post-hook "service nginx start"
The post hook is only called when change have been made but it is not
totaly clear we will see. It is properly be easier to check for change time stamp.

The update certs only needs ubuntu remember docker kill --signal=HUP cnginx
