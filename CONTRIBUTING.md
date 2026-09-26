# Contributing

This guide covers bug reports, feature requests, and pull requests. It applies to everyone, including AI agents filing on someone's behalf.

In the GitHub web interface, issue forms guide you through the structure. If you file through the API or the `gh` CLI, the forms are bypassed: copy the matching skeleton from [Skeletons](#skeletons) and keep the headings exactly as written.

Bug reports and pull requests are welcome on
[GitHub](https://github.com/elektronaut/vector2d). Everyone participating is
expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

## Principles

### For all issues and pull requests

**Report only what you observed or verified.** Whoever investigates, human or agent, anchors on the claims in a report. Unverified claims cost more time than they save.

**No hypotheses about causes.** Diagnosis is the maintainers' job. They add theories as comments, where the author shows how much weight to give them. Speculation in a report misleads everyone who reads it.

**Keep it short.** Length hides the useful information. A long report usually means two reports, or padding.

**One concern per issue or pull request.** Mixed concerns can't be tracked, reviewed, or reverted independently.

**Use the exact headings.** Maintainers and their tools rely on them to process reports.

### Bug reports

**Minimal, numbered steps you actually ran.** A reproduction nobody has run is speculation too.

**Raw output, not a paraphrase.** The details that matter are the ones a summary drops.

**Ruled out: negative results only.** "Still happens with caching disabled" narrows the search without steering it.

### Feature requests

**Problem before solution.** A proposed solution constrains the design before anyone familiar with the code has weighed in.

### Pull requests

**Open an issue before writing non-trivial code.** Code is cheap to write; choosing the right change is the expensive part. An issue lets maintainers weigh in on the approach before anything is built, while an unsolicited implementation anchors the discussion on one solution. Open a pull request directly only when there's one obvious way to make the change: typos, broken links, or a clear-cut fix. Reporting those costs more than fixing them. They don't need the template; a one-line description is ideal.

**Describe what changed, not what it might fix.** The diff shows how. Broad claims steer reviewers the same way hypotheses steer investigators.

**List deployment requirements.** Migrations, environment variables, config changes, and ordering across services are easy to miss in a diff and costly to discover during a deploy.

### Security

**Never report vulnerabilities publicly.** Report them privately as described in [SECURITY.md](SECURITY.md).

## Getting started

Install the dependencies and run the test suite:

```sh
bundle install
bundle exec rspec
```

Check style before pushing:

```sh
bundle exec rubocop
```

## Pull requests

- Add tests for any behavior you change.
- Write commit messages using
  [Conventional Commits](https://www.conventionalcommits.org). The
  changelog and releases are generated from them, so the `feat:` and
  `fix:` prefixes decide what ends up in the next release.
- Leave the version and the changelog alone. Both are updated
  automatically when a release is cut.

## Skeletons

Leave out optional sections you have nothing for.

### Bug report

```markdown
### Expected behavior

<!-- What should happen. -->

### Actual behavior

<!-- What happened instead, as observed. Include the error message, if any. -->

### Steps to reproduce

1.
2.
3.

### Error output

<!-- Optional. Raw stack trace or log lines in a code block. -->

### Ruled out

<!-- Optional. Negative results only, e.g. "Still happens with caching disabled." -->
```

### Feature request

```markdown
### Problem

<!-- What you're trying to do, and what's blocking you. -->

### Current workaround

<!-- Optional. How you get around it today, if at all. -->

### Proposed solution

<!-- Optional, and brief. -->
```

### Pull request

See [.github/pull_request_template.md](.github/pull_request_template.md).
