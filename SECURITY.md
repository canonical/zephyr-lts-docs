# Security Policy

This repository is part of **Zephyr 24.04** — Canonical's downstream
redistribution of the upstream
[Zephyr RTOS](https://github.com/zephyrproject-rtos/zephyr) Long-Term Support
(LTS) v3.7 line.

We take the security of our software seriously and appreciate your efforts to
responsibly disclose your findings.

## Reporting a Vulnerability

To report a security issue, please email
[security@ubuntu.com](mailto:security@ubuntu.com) with a description of the
issue, the steps you took to reproduce the issue, affected versions, and, if
known, mitigations for the issue.

You do not need a complete analysis or a proof-of-concept to get in touch:
partial, uncertain, or "this looks wrong" reports are welcome, and we would
rather hear about a suspicion early than not at all. If you are unsure whether
something is a security problem, please report it anyway and we will help
assess it.

Please **do not** open a public GitHub issue, pull request, or discussion for
security problems, and do not disclose the issue publicly until we have had a
chance to investigate and coordinate a fix.

The [Ubuntu Security disclosure and embargo
policy](https://ubuntu.com/security/disclosure-policy) contains more
information about what you can expect when you contact us and what we expect
from you. This product adopts that policy.

## Supported Versions

Security maintenance follows the upstream Zephyr **v3.7 LTS** line as published
for Zephyr 24.04.

| Version / track                     | Supported          |
| ----------------------------------- | ------------------ |
| Zephyr 24.04 (latest update)        | :white_check_mark: |
| Older Zephyr 24.04 updates          | :x: (upgrade to the latest Zephyr 24.04 update) |
| Edge / non-LTS tracks               | :x:                |
| Releases prior to 24.04             | :x:                |

Only the **latest update of the Zephyr 24.04 release series** is actively
maintained. Users are expected to track the latest Zephyr 24.04 update to
receive security fixes.

## Product Lifetime and Support Phases

- **Standard security maintenance.** The Zephyr 3.7 LTS distribution receives
  security maintenance for as long as the upstream Zephyr Project provides LTS
  security maintenance for the v3.7 line. Upstream Zephyr LTS releases receive
  approximately 2.5 years of standard maintenance.
- **Extended support.** Where upstream provides an extended maintenance window
  for v3.7, and/or where a customer or contractual Extended Security
  Maintenance (ESM) commitment applies, the Zephyr 24.04 release series is
  maintained for that longer period.
- **End of life (EOL).** When the applicable maintenance window ends, the track
  stops receiving security updates. The authoritative maintenance window and
  EOL date are published on the Zephyr LTS product documentation/security page
  and are kept in sync with the
  [upstream Zephyr release/LTS schedule](https://docs.zephyrproject.org/latest/project/release_process.html).

Support periods may vary by track and by customer agreement; the specific dates
for a given deployment are documented on the product's security/documentation
page.

## What We Commit To Fix

In line with Canonical's Secure Software Development Lifecycle (SSDLC), for
supported versions we will remediate, at a minimum:

- All vulnerabilities rated **High** or **Critical** (CVSS 3.1/4.0, score ≥ 7.0), and
- Any vulnerability listed in the CISA
  [Known Exploited Vulnerabilities (KEV)](https://www.cisa.gov/known-exploited-vulnerabilities-catalog)
  catalog, regardless of its CVSS score.

Lower-severity issues are addressed on a best-effort basis and are typically
folded into routine rebuilds.

## How Fixes Are Delivered

Security fixes are delivered as new revisions published for Zephyr 24.04.
Users receive fixes by updating to the new revision. Fixes are announced
through:

- [Ubuntu Security Notices (USN)](https://ubuntu.com/security/notices) where applicable;
- the release notes/changelog accompanying each rebuild; and
- the Zephyr LTS product documentation/security page.

## Disclosure

We follow a coordinated (responsible) disclosure process under the Ubuntu
Security disclosure and embargo policy. Details of a vulnerability are published
after a fix is available and any applicable embargo period has ended
(upstream Zephyr embargoes last at most 90 days).
