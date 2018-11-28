# Rubies.io [![Build Status](https://travis-ci.org/epistrephein/rubies.svg?branch=master)](https://travis-ci.org/epistrephein/rubies)

An API interface to Ruby versions status and filters.

## API

The endpoint is `https://rubies.io/api`.  
All successful requests return a JSON with Content-Type `application/json; charset=utf-8`.  
CORS is enabled by default.

### Status

`/active` - returns the latest releases currently active (meaning in either normal or security maintenance).

```bash
$ curl -s https://rubies.io/api/active | jq
[
  "2.5.1",
  "2.4.4",
  "2.3.7",
  "2.2.10"
]
```

---

`/preview` - returns the latest releases currently in preview.

```bash
$ curl -s https://rubies.io/api/preview | jq
[
  "2.6.0-preview1"
]
```

---

`/normal` - returns the latest releases in normal maintenance (receiving bug fixes and security fixes).

```bash
$ curl -s https://rubies.io/api/normal | jq
[
  "2.5.1",
  "2.4.4"
]
```

---

`/security` - returns the latest releases in security maintenance (receiving security fixes only).

```bash
$ curl -s https://rubies.io/api/security | jq
[
  "2.3.7",
  "2.2.10"
]
```

---

`/eol` - returns the latest end-of-life releases (no longer supported and not receiving any fixes).

```bash
$ curl -s https://rubies.io/api/eol | jq
[
  "2.1.10",
  "2.0.0-p648",
  "1.9.3-p551"
]
```

### Errors

Invalid requests return a JSON with 404 status code.

```bash
$ curl -s https://rubies.io/api/invalid_path | jq
{
  "error": "Not Found",
  "status": 404
}
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
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new pull request

## License

This project is released as open source under the terms of the [MIT License](https://github.com/epistrephein/rubies/blob/master/LICENSE).
