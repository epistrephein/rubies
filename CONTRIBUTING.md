# Contributing

First off, thank you for considering contributing to this project.

As part of the open source community, this project thrives thanks to the help
and contributions of its users. There are many ways to contribute — from
submitting bug reports and feature requests, to improving the documentation, or
writing code that can be incorporated into the codebase.

This project is intended to be a safe, welcoming space for collaboration,
and contributors are expected to adhere to the
[Code of Conduct](CODE_OF_CONDUCT.md).

## Opening an issue

Opening an issue on GitHub is the fastest way to get in touch with the maintainers
of the project and start a discussion about a problem you're experiencing or a
missing feature you'd like to suggest.

Upon opening a new issue, you'll be able to choose between a bug report and a
feature request template, with pre-allocated sections to fill in. Please try to
follow the existing structure and provide as much detail as possible about your
situation. This helps maintainers reproduce the problem or accurately evaluate
the feature you'd like to see implemented.

If your issue doesn't fit either template, simply open a blank issue and
describe the problem in the clearest way possible.

Security vulnerabilities are a special case — please do not report them through
public issues. See [SECURITY.md](SECURITY.md) for how to reach out responsibly.

## Contributing with code

If you'd like to contribute by writing code, you can open a Pull Request on
GitHub with your changes and ask a maintainer for a review.

### Tools and integrations

We use [RSpec](https://rspec.info/) as the testing framework. The test suite
lives in the `spec` directory and can be run with `bundle exec rake spec`.

We use [RuboCop](https://rubocop.org/) to enforce a consistent code style.
You can check your changes against the project's configuration with
`bundle exec rake rubocop`.

You can run both together with `bundle exec rake test`. Both checks are also run
automatically on every push to `main` via GitHub Actions.

### Submitting a PR

This project follows the [GitHub flow](https://docs.github.com/en/get-started/using-github/github-flow)
for Pull Request submissions.

To submit a PR with your proposed changes, follow these steps:

1. [Fork the repo](https://github.com/epistrephein/rubies/fork) in your GitHub
   userspace and clone it locally
2. Install the dependencies with `bundle install`
3. Create a feature branch (`git checkout -b my-new-feature`)
4. Add your code and commit the changes
5. Run the test suite (`bundle exec rake test`) and make sure all existing and
   newly introduced tests pass
6. Push your branch to GitHub and open a
   [new pull request](https://github.com/epistrephein/rubies/pulls)

When opening a pull request, please fill out the template with all the relevant
information to help reduce the review effort on the maintainers' side.
