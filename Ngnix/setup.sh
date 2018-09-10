#!/bin/bash

#------------------------------------------
# Tested with Docker image ubuntu:16.04
#------------------------------------------


#------------------------------------------
# Variables
#------------------------------------------
IP=127.0.0.1
SSLcert=www
SSLkey=keywww


#------------------------------------------
# Installation starts
#------------------------------------------
 apt-get update -y && apt-get upgrade -y
 apt-get install nginx-full openssl wget curl -y
 nginx -t
 rm -rf /etc/nginx/sites-enabled/default
 
 cat > /etc/nginx/sites-available/stevehome.online <<EOF
server{
        listen 80;
        server_name stevehome.online;
        return 301 https://stevehome.online;
}
server{
        listen 443 ssl;
        server_name stevehome.online;

        ### SSL Part
        ssl on;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;
        ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
        ssl_certificate /etc/nginx/ssl/stevehome.online-cert.pem;
        ssl_certificate_key /etc/nginx/ssl/stevehome.online-key.pem;
        ### Protect weak Diffie-Hellman (DH) key exchange
        ssl_dhparam /etc/nginx/ssl/dhparam.pem;

    location / {
        proxy_pass http://$IP:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # re-write redirects to http as to https
        proxy_redirect http:// https://;
    }
}
EOF
 ln -s /etc/nginx/sites-available/stevehome.online /etc/nginx/sites-enabled/stevehome.online
 mkdir /etc/nginx/ssl
 openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
 #curl -L -o /etc/nginx/ssl/stevehome.online-cert.pem "https://drive.google.com/uc?export=download&id=1P7Cv1O03EgdW-PtLOiytynSkDX530huI"
 #curl -L -o /etc/nginx/ssl/stevehome.online-key.pem "https://drive.google.com/uc?export=download&id=1vE5ytGVBOtYNZIwmUVQMZa1JA1Sm27E7"
 #nginx -t
 #systemctl reload nginx
 
#------------------------------------------
# Post install customizations
#------------------------------------------
 wget https://raw.githubusercontent.com/SuperFlea2828/BASHScripts/master/.bashrc -O ~/.bashrc && . ~/.bashrc
 
#------------------------------------------
# Print info banner 
#------------------------------------------

cat <<EOF
         _nnnn_
        dGGGGMMb
       @p~qp~~qMb
       M|@||@) M|        Base box bento/ubuntu-16.04
       @,----.JM|        SSH 2222 (guest)
      JS^\__/  qKL       HTTP 80 (guest) => 8080 (host)
     dZP        qKRb     HTTPS 443 (guest) => 4444 (host)
    dZP          qKKb    Log location /var/logs/nginx
   fZP            SMMb   Cert location /etc/nginx/ssl/
   HZM            MMMM   Version 0.0.1b
   FqM            MMMM   Keywords nginx unrar ssl certificate tls ubuntu
 __| '.        |\dS'qML  
 |    `.       | `' \Zq
_)      \.___.,|     .'
\____   )MMMMMP|   .'
     `-'       `--'
EOF


