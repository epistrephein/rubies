# Rubies.io [![Build Status](https://travis-ci.org/epistrephein/rubies.svg?branch=master)](https://travis-ci.org/epistrephein/rubies)

A Sinatra API interface to Ruby versions, releases and branches.

## API

The API endpoint is `https://rubies.io/api`.  
All successful requests return a JSON response body with Content-Type `application/json; charset=utf-8` and status code `200`.  
CORS is enabled by default.

[Invalid requests](https://rubies.io/api/invalid_path) return a `404` status code with no body.

### Statuses

[`/normal`](https://rubies.io/api/normal) - returns the branches and the latest releases in normal maintenance (receiving bug fixes and security fixes).

```bash
$ curl -s https://rubies.io/api/normal | jq
{
  "status": "normal",
  "branches": [
    "2.7",
    "2.6"
  ],
  "latest": [
    "2.7.1",
    "2.6.6"
  ]
}
```

---

[`/security`](https://rubies.io/api/security) - returns the branches and the latest releases in security maintenance (receiving security fixes only).

```bash
$ curl -s https://rubies.io/api/security | jq
{
  "status": "security",
  "branches": [
    "2.5"
  ],
  "latest": [
    "2.5.8"
  ]
}
```

---

[`/preview`](https://rubies.io/api/preview) - returns the branches and the latest releases currently in preview.

```bash
$ curl -s https://rubies.io/api/preview | jq
{
  "status": "preview",
  "branches": [],
  "latest": []
}
```

---

[`/eol`](https://rubies.io/api/eol) - returns the end-of-life branches and latest releases (no longer supported and not receiving any fixes).

```bash
$ curl -s https://rubies.io/api/eol | jq
{
  "status": "eol",
  "branches": [
    "2.4",
    "2.3",
    "2.2",
    "2.1"
  ],
  "latest": [
    "2.4.10",
    "2.3.8",
    "2.2.10",
    "2.1.10"
  ]
}
```

### Branches

[`/<major>.<minor>`](https://rubies.io/api/2.7) - returns the status, release date, eol date (if any), latest release and all releases of a branch.

```bash
$ curl -s https://rubies.io/api/2.7 | jq
{
  "branch": "2.7",
  "status": "normal",
  "release_date": "2019-12-25",
  "eol_date": null,
  "latest": "2.7.1",
  "releases": [
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

```bash
$ curl -s https://rubies.io/api/2.3 | jq
{
  "branch": "2.3",
  "status": "eol",
  "release_date": "2015-12-25",
  "eol_date": "2019-03-31",
  "latest": "2.3.8",
  "releases": [
    "2.3.8",
    "2.3.7",
    "2.3.6",
    "2.3.5",
    "2.3.4",
    "2.3.3",
    "2.3.2",
    "2.3.1",
    "2.3.0",
    "2.3.0-preview2",
    "2.3.0-preview1"
  ]
}
```

### Releases

[`/<major>.<minor>.<patch>`](https://rubies.io/api/2.7.0) - returns the status, release date, eol date (if any), latest release and all releases of a branch.

```bash
$ curl -s https://rubies.io/api/2.7.0 | jq
{
  "release": "2.7.0",
  "branch": "2.7",
  "status": "normal",
  "release_date": "2019-12-25",
  "latest": false,
  "prerelease": false
}
```

```bash
$ curl -s https://rubies.io/api/2.6.6 | jq
{
  "release": "2.6.6",
  "branch": "2.6",
  "status": "normal",
  "release_date": "2020-03-31",
  "latest": true,
  "prerelease": false
}
```

```bash
$ curl -s https://rubies.io/api/2.2.4 | jq
{
  "release": "2.2.4",
  "branch": "2.2",
  "status": "eol",
  "release_date": "2015-12-16",
  "latest": false,
  
  "prerelease": false
}
```


### Errors

[Invalid requests](https://rubies.io/api/invalid_path) return a `404` status code with no body.

```bash
$ curl -I https://rubies.io/api/invalid_path
HTTP/1.1 404 Not Found
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/epistrephein/rubies).

This project is intended to be a safe, welcoming space for collaboration,
and contributors are expected to adhere to the [Code of Conduct](https://github.com/epistrephein/rubies/blob/master/CODE_OF_CONDUCT.md).

You can contribute changes by forking the project and submitting a pull request. To get started:

1. Fork the repo
2. Install the dependencies (`bin/setup`)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Pass the test suite (`bundle exec rspec`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create a new pull request

## License

This project is released as open source under the terms of the [MIT License](https://github.com/epistrephein/rubies/blob/master/LICENSE).
