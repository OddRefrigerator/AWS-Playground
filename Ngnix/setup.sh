#!/bin/bash
#: Title : Setup Nginx revers proxy
#: Date : 2018-09-10
#: Author : "Stephen Ancliffe" <stephen.ancliffe@gmail.com>
#: Version : 1.0
#: Description : Update & Upgrade Ubuntu 16.04. Install nginx-full openssl wget. Configure proxy.
#: Options : IP address, SSL certificate, SSL key


#------------------------------------------
# Variables
#------------------------------------------
WebSrvAddress=192.168.1.2:8080
SSLcert="https://www.dropbox.com/s/yozclk8gakxy137/fullchain.pem?dl=1"
SSLkey="https://www.dropbox.com/s/0h5itorxai1b9xu/privkey.pem?dl=1"


#------------------------------------------
# Installation starts
#------------------------------------------
 apt-get update -y && apt-get upgrade -y
 apt-get install nginx-full openssl wget -y
 
 nginx -t
 rm -rf /etc/nginx/sites-enabled/default
 cat > /etc/nginx/sites-available/stevehome.online <<'EOF'
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
        proxy_pass http://127.0.0.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # re-write redirects to http as to https
        proxy_redirect http:// https://;
    }
}
EOF
 sed -i "s/127.0.0.1/$WebSrvAddress/" /etc/nginx/sites-available/stevehome.online
 
 ln -s /etc/nginx/sites-available/stevehome.online /etc/nginx/sites-enabled/stevehome.online
 mkdir /etc/nginx/ssl
 openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
 wget -O /etc/nginx/ssl/stevehome.online-cert.pem $SSLcert
 wget -O /etc/nginx/ssl/stevehome.online-key.pem $SSLkey
 
 nginx -t
 systemctl reload nginx
 
#------------------------------------------
# Post install customizations
#------------------------------------------
 wget https://raw.githubusercontent.com/SuperFlea2828/BASHScripts/master/.bashrc -O ~/.bashrc && . ~/.bashrc
 
#------------------------------------------
# Print info banner 
#------------------------------------------

cat <<EOF
#------------------------------------------
# Install complete
#------------------------------------------
Base Docker image ubuntu-16.04
SSH 2222 (guest)
HTTP 80 (guest) => 8080 (host)
Log location /var/logs/nginx
Cert location /etc/nginx/ssl/
Version 0.0.1b
Keywords nginx unrar ssl certificate tls ubuntu

EOF


