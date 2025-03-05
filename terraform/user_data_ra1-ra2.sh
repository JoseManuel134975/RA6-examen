#!/bin/bash

sudo apt update -y
sudo apt install git -y
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt install docker-ce docker-ce-cli containerd.io -y

sudo git clone https://github.com/JoseManuel134975/salvesequienpueda-parte2.git /tmp/mi_proyecto

sudo touch dockerfile

sudo tee dockerfile <<EOF
FROM ubuntu/apache2:latest
RUN apt update -y
RUN apt install coreutils -y
WORKDIR /var/www/html
RUN mkdir otro
WORKDIR /var/www/html/otro
COPY /tmp/mi_proyecto/src/* .
WORKDIR /etc/apache2
RUN cp sites-available/000-default.conf sites-available/otro.conf

RUN tee sites-available/otro.conf <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/otro
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

RUN tee -a apache2.conf <<EOF
<Directory /var/www/html/otro>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    Require all granted
</Directory>
EOF

WORKDIR /var/www/html/otro
RUN touch .htaccess
RUN tee .htaccess <<EOF
RewriteEngine On
ReWriteRule ^index$ index.html [NC]
EOF
RUN a2enmod rewrite
RUN a2dissite 000-default.conf
RUN a2ensite otro.conf
EXPOSE 80
EXPOSE 443
EOF

sudo rm -rf /tmp/mi_proyecto

sudo docker build -t my-image:my-image .
sudo docker run -d --name my-container -p 8080:80 -p 8443:443 my-image:my-image