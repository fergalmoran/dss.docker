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

server {
    listen 80;
    server_name api.deepsouthsounds.com api-test.deepsouthsounds.com;
    client_max_body_size 0;
    
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

server {
	listen 80;
	server_name deepsouthsounds.com;
	return 301 http://www.deepsouthsounds.com$request_uri;
}

server {
    listen 80;
    listen 443 default ssl;

    server_name www.deepsouthsounds.com ext-test.deepsouthsounds.com;
    root /files/static/;

    ssl_certificate /etc/nginx/ssl/dss.crt;
    ssl_certificate_key /etc/nginx/ssl/dss.key;

    #if ($ssl_protocol = "") {
    #   rewrite ^ https://$server_name$request_uri? permanent;
    #}

    client_max_body_size 250M;

    location ~ /\.(eot|otf|ttf|woff)$ {
        add_header Access-Control-Allow-Origin *;
    }

    location /media {
        alias /files/media;
    }
    location / {
        #if ($request_filename ~* ^.*?/([^/]*?)$) {
        #    set $filename $1; 
        #}
        #if ($filename ~* ^.*?\.(eot)|(ttf)|(woff)$){
        #    add_header Access-Control-Allow-Origin *;
        #}
        proxy_pass http://web:8080;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }    
}
