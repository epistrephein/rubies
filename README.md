# Rubies.io [![Build Status](https://travis-ci.org/epistrephein/rubies.svg?branch=master)](https://travis-ci.org/epistrephein/rubies)

An API interface to Ruby versions status and filters.

## API

The endpoint is `https://rubies.io/api`.

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

## Work in progres...
