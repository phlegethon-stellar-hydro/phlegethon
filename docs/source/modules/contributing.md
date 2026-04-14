(contributing)=
# Contributing

Thank you for your interest in improving Phlegethon.

## Who can contribute?

Anyone can contribute, including first-time contributors. We welcome:

- Bug reports and reproducible test cases
- Feature requests and design discussions
- Documentation improvements
- Test additions and validation cases
- Code changes (bug fixes, performance improvements, and new features)

Write access to the main repository is limited to maintainers, but external contributors are encouraged to open pull requests from forks.

## Before opening a pull request

1. Opening an issue is optional, including for feature pull requests.
2. For larger changes, opening an issue or draft pull request early is encouraged for feedback.
3. Keep each pull request focused on one logical change.
4. Ensure documentation is updated when behavior, options, or workflows change.

## Suggested local checks

Run checks relevant to your change before opening a PR.

- Build at least one affected test case:

```bash
cd tests/<test-case>
make clean
make
```

- For runtime-sensitive changes, run a short test simulation where practical.
- For documentation changes, build docs locally when possible.

## How to open a pull request

1. Fork the repository and create a branch from `main`.
2. Use a clear branch name, for example `fix/hdf5-restart` or `docs/contributing-guide`.
3. Commit with concise messages explaining what and why.
4. Open a pull request against `main` and include:
   - A short summary of the change
   - Motivation and expected impact
   - Any related issue links
   - Notes on verification (what you built and ran)

Use the repository PR template at `.github/pull_request_template.md` and complete its checklist before requesting review.

Small and well-scoped pull requests are reviewed faster.

## Review and merge process

- Maintainers review incoming pull requests.
- At least one approval is required before merge.
- CI checks must pass before merge.
- Reviewers may request changes before approval.
- A maintainer performs the final merge.

Current maintainers are listed in the repository README.

## Questions

If you are unsure about approach, open a draft pull request or start a discussion in an issue. Early feedback is encouraged.