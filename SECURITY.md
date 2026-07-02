# Security Policy

attest runs inside CI with access to source code and the build environment, so
security issues are treated with high priority — anything that could affect
that environment gets an expedited fix outside the normal release cadence.

## Reporting a vulnerability

Please do **not** open a public issue for a vulnerability.

- Preferred: open a private report via GitHub —
  **Security → Report a vulnerability** on
  [github.com/sahland/attest](https://github.com/sahland/attest/security).
- Or email **sahland@mail.ru** with the details.

You will get an acknowledgement within a few days. Confirmed issues are fixed
under embargo and shipped as an expedited release with a security advisory and
a `Security` CHANGELOG entry.

## Supported versions

Security fixes land on the latest release of each package. Once 1.0 is out,
the current major is supported with patches; a fix may be backported to the
previous major for a stated window.

## What attest will never do

The OSS packages make **no network calls and collect no telemetry**. They run
in your CI and never phone home; any change that violates this is treated as a
security defect, not a feature.
