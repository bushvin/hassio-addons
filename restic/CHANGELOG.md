# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.1] - 2024-12-10

### Added

- Print version of restic before backing up

## [1.4.0] - 2024-10-22

### Added

- support for insecure certificates (--insecure-tls)

## [1.3.0] - 2023-01-07

### Fixed

- change default for keep\_daily to 7
- config.yaml url correction
- Additional Translations
- updated README.md

## [1.2.0] - 2022-12-26

### Added

- only fail pre and post commands if their exit is not 0

## [1.1.1] - 2022-12-26

### Fixed

- bugfix: /share should be r/w

## [1.1.0] - 2022-12-26

### Added

- (re)introduction of `pre_commands` and `post_commands`
- install mysql and postgresql clients

## [1.0.0] - 2022-12-26

### Added

- restic 1.4
- bump to 1.0.0
- allow backup of `/addons`, `/backup`, `/config`, `/media`, `/share`, `/ssl`
- support (most) restic environment variables
- allow to forget snapshots based on days, weeks, months, years
