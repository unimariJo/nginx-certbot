#!/bin/bash

domains=(example.com example.org)
rsa_key_size=4096
data_path="./data/certbot"
email="" # Adding a valid address is strongly recommended
staging=0 # Set to 1 if you're testing your setup to avoid hitting request limits

if [ "$EUID" -ne 0 ]; then
  read -p "You ran this script without root privileges, do you want to continue? (Y/n) " decision
  if [ "$decision" = "n" ] || [ "$decision" = "N" ]; then
    exit
  fi
fi


if [ ! -d "$data_path" ]; then mkdir -p "$data_path"; fi


if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  echo
fi


for domain in "${domains[@]}"; do
  if [ -d "$data_path/conf/live/$domain" ]; then
    read -p "There is already folder with $domain domain data, do you want to remove it? (Y/n) " decision
    case $decision in
      [Y]* ) rm -rf "$data_path/conf/live/$domain" && mkdir -p "$data_path/conf/live/$domain";;
      [n]* ) domains=(${domains[@]/$domain});;
    esac
  else
    mkdir -p "$data_path/conf/live/$domain"
  fi
done


for domain in "${domains[@]}"; do
  echo "### Creating dummy certificate for $domain domain..."

  path="/etc/letsencrypt/live/$domain"
  docker-compose run --rm --entrypoint "openssl req -x509 -nodes -newkey rsa:1024 \
  -days 1 -keyout '$path/privkey.pem' -out '$path/fullchain.pem' -subj '/CN=localhost'" certbot
done

echo "### Starting nginx ..."
docker-compose up -d --force-recreate nginx

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--staging"; fi

for domain in "${domains[@]}"; do
  echo "### Deleting dummy certificate for $domain domain ..."
  rm -rf "$data_path/conf/live/$domain"

  echo "### Requesting Let's Encrypt certificate for $domain domain ..."
  mkdir -p "$data_path/www"
  docker-compose run --rm --entrypoint "certbot certonly --webroot -w /var/www/certbot -d $domain \
  $staging_arg $email_arg --rsa-key-size $rsa_key_size --agree-tos --force-renewal" certbot
done

echo "### Restarting nginx and certbot ..."
docker-compose up -d --force-recreate
