# Nginx with Let's Encrypt

## Description
> This fork requests separate Let's Encrypt certificate for each domain unlike the original repository, includes some additions and fixes.

`setup.sh` fetches and ensures the renewal of a Let’s Encrypt certificate for one or multiple domains in a docker-compose setup with nginx.

## Usage
1. [Install docker-compose](https://docs.docker.com/compose/install/#install-compose).

2. Clone this repository: `git clone https://github.com/unimarijo/nginx-certbot.git .`.

3. Modify configuration:
- Add domains (recommended: add the valid email address too) to setup.sh;
- Replace all occurrences of example.org with your domain (the domain you added to setup.sh) in data/nginx/app.conf.

4. Run the script: `chmod +x ./setup.sh && ./setup.sh`

5. Run server: `docker-compose up`

## License
All code in this repository is licensed under the terms of the `MIT License`. For further information please refer to the `LICENSE` file.
