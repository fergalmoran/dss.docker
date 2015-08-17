server {
    listen 81;

    server_name api.deepsouthsounds.com api-test.deepsouthsounds.com;
    client_max_body_size 0;

    location /assets/grappelli {
	alias /usr/local/lib/python2.7/site-packages/grappelli/static/grappelli;
    }

    location / {
        proxy_pass http://api:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

server {
    listen 81;
    server_name www.deepsouthsounds.com ext-test.deepsouthsounds.com deepsouthsounds.com;
    
    client_max_body_size 250M;

    location /media {
        alias /files/media;
    }

    location / {
        proxy_pass http://web:8080;
	proxy_set_header Upgrade $http_upgrade;
	proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }    
}
