# Changelog

## [1.0.1](https://github.com/chodeus/orpheusmorebetter/compare/v1.0.0...v1.0.1) (2026-04-19)


### Bug Fixes

* **deps:** update all non-major dependencies ([#38](https://github.com/chodeus/orpheusmorebetter/issues/38)) ([3b1702a](https://github.com/chodeus/orpheusmorebetter/commit/3b1702a27ce03902d97977c68d10dd5ea580abd1))
* **deps:** update dependency requests to &gt;=2.33.0,&lt;3.0.0 [security] ([#31](https://github.com/chodeus/orpheusmorebetter/issues/31)) ([c2561c7](https://github.com/chodeus/orpheusmorebetter/commit/c2561c70cbe09fb5522761e12243472177716975))

## 1.0.0 (2026-04-19)


### Features

* add idle mode and optional command execution via Post Arguments ([42244d4](https://github.com/chodeus/orpheusmorebetter/commit/42244d4e53c2e602660b3fea1a9708b2e1014925))
* add OMB logo for Unraid template ([3515b69](https://github.com/chodeus/orpheusmorebetter/commit/3515b69b77ac1609909839b9df97cf2c2c9e525c))
* add workflow to cleanup old releases and images ([15a9078](https://github.com/chodeus/orpheusmorebetter/commit/15a9078aa5377d83e0eddbb8ba7f2f9052009701))
* auto-cleanup logs, keep only last 5 files ([c7c6994](https://github.com/chodeus/orpheusmorebetter/commit/c7c699430a5cd44d342e731295de5d7751f1050f))
* Dockerized orpheusmorebetter with GHCR support ([e3880e1](https://github.com/chodeus/orpheusmorebetter/commit/e3880e1d8a022281e9450e79a1db8dd583d7d892))
* enrich sync notifications with diff stats and artifact ([2a1ba4b](https://github.com/chodeus/orpheusmorebetter/commit/2a1ba4b68d96df68e0c719436e101b760c86b27e))
* harden Docker build with source builds, SHA256 verification and security ([6783f84](https://github.com/chodeus/orpheusmorebetter/commit/6783f848f69cec41356db2c8a155e8e198a69d30))
* quality of life improvements ([7710d38](https://github.com/chodeus/orpheusmorebetter/commit/7710d3897c7c17a0c4f35cea21a81ba8a9f1e7bd))
* replace unmaintained SoX with sox_ng in Docker build ([d3b7855](https://github.com/chodeus/orpheusmorebetter/commit/d3b7855beb30fce7cadb452d6af08f6b39268ea4))


### Bug Fixes

* add missing commit_sha to security notification and fix Discord links ([54acd9c](https://github.com/chodeus/orpheusmorebetter/commit/54acd9c5d66e8a327a4aa5a7fdcaa9d269091474))
* allow Docker Hub workflow to run from dev branch ([c6f2e69](https://github.com/chodeus/orpheusmorebetter/commit/c6f2e690b7f4633a9fde47ef2ace527496c67711))
* change working directory to /config for logs ([9f0b636](https://github.com/chodeus/orpheusmorebetter/commit/9f0b6362da7697c195999296d4695fe8bbc444ee))
* Discord notification issues and cleanup improvements ([5cc017e](https://github.com/chodeus/orpheusmorebetter/commit/5cc017e17f0bfe446b50f5b820a9e435564d2142))
* move start.sh into ENTRYPOINT to prevent tini from consuming app flags ([d8bbed3](https://github.com/chodeus/orpheusmorebetter/commit/d8bbed3ea0fbf361753a43ca15ac257af0e25e9b))
* only trigger Docker builds when image-relevant files change ([83288a9](https://github.com/chodeus/orpheusmorebetter/commit/83288a94031d63b8c3352bd6e53ef7e3dcef986b))
* preserve latest and dev tags during cleanup ([61596a9](https://github.com/chodeus/orpheusmorebetter/commit/61596a9f2e56dd894274b790f0e3f5f3df4acd38))
* **repo-events:** update chodeus-ops path to .github/workflows/ ([8a10f24](https://github.com/chodeus/orpheusmorebetter/commit/8a10f2484c4d252299d1579e4ce3c9fa67d2d25a))
* resolve workflow annotation warnings ([980534b](https://github.com/chodeus/orpheusmorebetter/commit/980534b9181cdd43f602a127226856ed87750605))
* update unraid template based on working config ([e27a585](https://github.com/chodeus/orpheusmorebetter/commit/e27a5857364ca78b027294d0796f69b9039c8575))
* workflow bugs and container improvements ([74c64ac](https://github.com/chodeus/orpheusmorebetter/commit/74c64acd640a00c0cc0eb95f8eb8a56cb8c2688a))
* workflow improvements and main branch as primary ([3e0143c](https://github.com/chodeus/orpheusmorebetter/commit/3e0143c37ceff2775b02e0929ffece9e709edf6a))
* YAML syntax errors from literal newlines breaking workflow parsing ([4f5091f](https://github.com/chodeus/orpheusmorebetter/commit/4f5091fb5210a38ecc0d61ffbe5782ea11a680b8))


### Refactoring

* consolidate workflows and add Trivy scanning ([22f757d](https://github.com/chodeus/orpheusmorebetter/commit/22f757d097ce1fe9eb9bfb72436e5928999c19ea))


### Documentation

* add Unraid template and improve documentation ([23d582a](https://github.com/chodeus/orpheusmorebetter/commit/23d582ab0018b35a81194ef73f05ac5d61b68fb7))
