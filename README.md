# Rubies [![CI](https://github.com/epistrephein/rubies/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/epistrephein/rubies/actions/workflows/main.yml)

A Sinatra API interface to Ruby versions, releases and branches.

The application is live at [https://rubies.io](https://rubies.io).

## Usage

The API endpoint is `https://rubies.io/api`.  
All successful requests return a JSON response with Content-Type `application/json`
and status `200`.  
CORS is enabled by default.

### Statuses

[`/normal`](https://rubies.io/api/normal) - returns the branches and the latest
releases in normal maintenance (receiving bug fixes and security fixes).

```bash
$ curl -s https://rubies.io/api/normal | jq
{
  "status": "normal",
  "branches": [
    "3.4",
    "3.3"
  ],
  "latest": [
    "3.4.4",
    "3.3.8"
  ]
}
```

[`/security`](https://rubies.io/api/security) - returns the branches and the latest
releases in security maintenance (receiving security fixes only).

```bash
$ curl -s https://rubies.io/api/security | jq
{
  "status": "security",
  "branches": [
    "3.2"
  ],
  "latest": [
    "3.2.8"
  ]
}
```

[`/preview`](https://rubies.io/api/preview) - returns the branches and the latest
releases currently in preview.

```bash
$ curl -s https://rubies.io/api/preview | jq
{
  "status": "preview",
  "branches": [
    "3.5"
  ],
  "latest": [
    "3.5.0-preview1"
  ]
}
```

[`/eol`](https://rubies.io/api/eol) - returns the end-of-life branches and latest
releases (no longer supported and not receiving any fixes).

```bash
$ curl -s https://rubies.io/api/eol | jq
{
  "status": "eol",
  "branches": [
    "3.1",
    "3.0",
    "2.7",
    "2.6",
    "2.5",
    "2.4",
    "2.3",
    "2.2",
    "2.1",
    "2.0",
    "1.9"
  ],
  "latest": [
    "3.1.7",
    "3.0.7",
    "2.7.8",
    "2.6.10",
    "2.5.9",
    "2.4.10",
    "2.3.8",
    "2.2.10",
    "2.1.10",
    "2.0.0-p648",
    "1.9.3-p551"
  ]
}
```

### Branches

[`/<major>.<minor>`](https://rubies.io/api/3.3) - returns the status, release date,
eol date (if any), latest release and all releases of a branch.  
Lowest branch returned: `1.9`.

```bash
$ curl -s https://rubies.io/api/3.3 | jq
{
  "branch": "3.3",
  "status": "normal",
  "release_date": "2023-12-25",
  "eol_date": null,
  "latest": "3.3.8",
  "releases": [
    "3.3.8",
    "3.3.7",
    "3.3.6",
    "3.3.5",
    "3.3.4",
    "3.3.3",
    "3.3.2",
    "3.3.1",
    "3.3.0",
    "3.3.0-rc1",
    "3.3.0-preview3",
    "3.3.0-preview2",
    "3.3.0-preview1"
  ]
}
```

```bash
$ curl -s https://rubies.io/api/2.7 | jq
{
  "branch": "2.7",
  "status": "eol",
  "release_date": "2019-12-25",
  "eol_date": "2023-03-31",
  "latest": "2.7.8",
  "releases": [
    "2.7.8",
    "2.7.7",
    "2.7.6",
    "2.7.5",
    "2.7.4",
    "2.7.3",
    "2.7.2",
    "2.7.1",
    "2.7.0",
    "2.7.0-rc2",
    "2.7.0-rc1",
    "2.7.0-preview3",
    "2.7.0-preview2",
    "2.7.0-preview1"
  ]
}
```

### Releases

[`/<major>.<minor>.<patch>`](https://rubies.io/api/3.3.5) - returns the branch,
status and release date of a release, and whether it's the latest version of the
branch and/or a prerelease.  
Lowest release returned: `1.9.0`.

```bash
$ curl -s https://rubies.io/api/3.3.5 | jq
{
  "release": "3.3.5",
  "branch": "3.3",
  "status": "normal",
  "release_date": "2024-09-03",
  "latest": false,
  "prerelease": false
}
```

```bash
$ curl -s https://rubies.io/api/3.2.8 | jq
{
  "release": "3.2.8",
  "branch": "3.2",
  "status": "security",
  "release_date": "2025-03-26",
  "latest": true,
  "prerelease": false
}
```

```bash
$ curl -s https://rubies.io/api/2.7.7 | jq
{
  "release": "2.7.7",
  "branch": "2.7",
  "status": "eol",
  "release_date": "2022-11-24",
  "latest": false,
  "prerelease": false
}
```

### Meta

[`/last_update`](https://rubies.io/api/last_update) - returns the time the data
was updated. Time format is `%Y-%m-%d %H:%M:%S %z`.

```bash
$ curl -s https://rubies.io/api/last_update | jq
{
  "last_update": "2025-05-21 09:00:00 +0000"
}
```

### Errors

Invalid requests return a `404` status with no body.

```bash
$ curl -I https://rubies.io/api/invalid
HTTP/1.1 404 Not Found
```

## Development

After checking out the repo, run `bin/setup -d` to install dependencies for the
development environment.

This application fetches data regarding Ruby branches and releases from the official
repo [ruby/www.ruby-lang.org](https://github.com/ruby/www.ruby-lang.org) and stores
it in Redis for fast access.  
Use `rake redis` to populate Redis with the latest data.

Use `rake dev` to start the development server locally.

Use `rake spec` to run the tests and `rake rubocop` to run RuboCop.

Use `bin/console` to start a console session.

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/epistrephein/rubies).

This project is intended to be a safe, welcoming space for collaboration,
and contributors are expected to adhere to the [Code of Conduct](CODE_OF_CONDUCT.md).

You can contribute changes by forking the project and submitting a pull request.
To get started:

1. Fork the repo
2. Install the dependencies (`bin/setup -d`)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Pass the test suite (`bundle exec rake spec rubocop`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create a new pull request

## License

This project is released as open source under the terms of the [MIT License](LICENSE).
