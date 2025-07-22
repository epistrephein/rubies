# Deploy

The repository contains all the configuration files needed to deploy the application
on a standard Linux server.

## Requirements

* Ruby
* Redis
* Nginx
* Systemd

## Installation

### Clone

First off, clone the repository

```bash
mkdir -p /var/www/rubies.io
cd /var/www/rubies.io
git clone https://github.com/epistrephein/rubies.git .
```

### Bundler

Use `bin/setup` to configure bundler automatically for production

```bash
bin/setup -p
```

or manually set the needed bundler flags and install

```bash
bundle config set --local deployment true
bundle config set --local without development test
bundle config set --local clean true
bundle install
```

### Redis

Populate Redis manually once and setup cron for automatic updates

```bash
bundle exec rake redis
bundle exec whenever --update-crontab
```

### Systemd

Copy the systemd service and enable it

```bash
sudo cp config/rubies.service /etc/systemd/system/rubies.service
sudo systemctl enable --now /etc/systemd/system/rubies.service
sudo systemctl status rubies
```

### Nginx

Copy the nginx configuration and enable it.  
SSL certificates are expected in `/etc/nginx/certs/rubies.io/`.

```bash
sudo cp config/rubies.nginx /etc/nginx/sites-available/rubies.io
sudo ln -s /etc/nginx/sites-available/rubies.io /etc/nginx/sites-enabled/rubies.io
sudo systemctl restart nginx
```

### Logrotate

Both the Redis cron and unicorn produce logs in `/var/www/rubies/log/` so it's recommended
to setup logrotate.  
Create a `/etc/logrotate.d/rubies` file with the following content:

```
/var/www/rubies.io/log/*.log {
  monthly
  missingok
  rotate 7
  compress
  delaycompress
  notifempty
  copytruncate
}
```
