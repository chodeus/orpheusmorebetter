# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |
| dev     | :warning: Development only |

## Reporting a Vulnerability

If you discover a security vulnerability in this Docker wrapper, please report it by:

1. **Opening a private security advisory** via GitHub's Security tab
2. **Or emailing** the maintainer directly

Please do **not** open public issues for security vulnerabilities.

### What to include

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

## Security Measures

This container implements the following security practices:

### Container Security
- **Non-root execution**: Runs as configurable PUID/PGID (default: 99/100)
- **Minimal base image**: Alpine Linux with reduced attack surface
- **No unnecessary packages**: Only required runtime dependencies
- **Read-only where possible**: Application code in `/app` is not writable by runtime user

### CI/CD Security
- **Automated vulnerability scanning**: Trivy scans on every build
- **Dependency updates**: Dependabot monitors for outdated packages
- **Pinned dependencies**: All Python packages have version bounds
- **Build provenance**: SBOM and attestation for supply chain security

### Credentials
- **No hardcoded secrets**: All credentials stored in user config files
- **Config file permissions**: Owned by runtime user only
- **No secrets in images**: Credentials never baked into container

## Best Practices for Users

1. **Protect your config directory**: Contains plaintext credentials
2. **Use non-root PUID/PGID**: Avoid running as root (PUID=0)
3. **Keep updated**: Pull latest images regularly for security patches
4. **Restrict network access**: Container only needs outbound HTTPS to orpheus.network
