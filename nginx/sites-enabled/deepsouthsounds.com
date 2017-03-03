server {
    listen 80;
    listen 443 default ssl;

    server_name deepsouthsounds.com ext-test.deepsouthsounds.com www.deepsouthsounds.com;
    root /files/static/;

    ssl_certificate     /etc/letsencrypt/live/deepsouthsounds.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/deepsouthsounds.com/privkey.pem;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';

    if ($ssl_protocol = "") {
       rewrite ^ https://$server_name$request_uri? permanent;
    }

    client_max_body_size 250M;

    location ~ /\.(eot|otf|ttf|woff)$ {
        add_header Access-Control-Allow-Origin *;

	types  {font/truetype ttf;}
	types  {application/font-woff woff;}
	types  {application/font-woff2 woff2;}
    }

    location /media {
        alias /files/media;
    }
    location /assets {
        alias /app/dist/public/assets;
    }
    location /images {
        alias /app/dist/public/assets/images;
    }
    location / {
        if ($request_filename ~* ^.*?/([^/]*?)$) {
            set $filename $1; 
        }
        if ($filename ~* ^.*?\.(eot)|(ttf)|(woff)$){
            add_header Access-Control-Allow-Origin *;
        }
        proxy_pass http://web:8088;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }    
}
server {
    listen 80;
    listen 443 ssl;

    server_name api.deepsouthsounds.com api-test.deepsouthsounds.com;
    client_max_body_size 0;
    
    ssl_certificate     /etc/letsencrypt/live/api.deepsouthsounds.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.deepsouthsounds.com/privkey.pem;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';

    if ($ssl_protocol = "") {
       rewrite ^ https://$server_name$request_uri? permanent;
    }

    location /assets/grappelli {
        alias /usr/local/lib/python2.7/site-packages/grappelli/static/grappelli;
    }
    
   location /assets {
        alias /files/static;
   }

    location / {
        proxy_pass http://api:8001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
#server {
#    listen 80;
#    server_name radio.deepsouthsounds.com;
#    
#    location /a {
#        proxy_pass http://radio:8888;
#        proxy_set_header Host $host;    
#        proxy_set_header X-Real-IP $remote_addr;
#        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#    }
#
#    location / {
#        proxy_pass http://icecast:8000;
#        proxy_set_header Host $host;    
#        proxy_set_header X-Real-IP $remote_addr;
#        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#    }
#}

