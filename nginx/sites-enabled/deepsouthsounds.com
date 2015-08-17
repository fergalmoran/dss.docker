server {
    listen 81;
    server_name api.deepsouthsounds.com api-test.deepsouthsounds.com;
    client_max_body_size 25M;

    location / {
        proxy_pass http://api:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

server {
    listen 80;
    listen 443 default ssl;

    server_name www.deepsouthsounds.com ext-test.deepsouthsounds.com deepsouthsounds.com;

    ssl_certificate /etc/nginx/ssl/dss.crt;
    ssl_certificate_key /etc/nginx/ssl/dss.key;

    #if ($ssl_protocol = "") {
    #   rewrite ^ https://$server_name$request_uri? permanent;
    #}

    client_max_body_size 250M;

    location /api {
        proxy_pass http://api:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }    

    location /media {
        alias /files/media;
    }

    location / {
        proxy_pass http://web:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }    
}
