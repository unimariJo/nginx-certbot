# Nginx with Let's Encrypt

> This fork requests separate Let's Encrypt certificate for each domain unlike the original repository, includes some additions and fixes.

`setup.sh` fetches and ensures the renewal of a Let’s Encrypt certificate for one or multiple domains in a docker-compose setup with nginx.

## Usage
1. You have to have [docker-compose](https://docs.docker.com/compose/install/#install-compose) installed on your server;

2. Modify the configuration to suit your needs:
- Add domains (recommended: add the valid email address too) to setup.sh;
- Replace all occurrences of example.org with your domain (the domain you added to setup.sh) in data/nginx/app.conf.

3. Run the script: `chmod +x ./setup.sh && ./setup.sh`;

## License
All code in this repository is licensed under the terms of the `MIT License`. For further information please refer to the `LICENSE` file.
