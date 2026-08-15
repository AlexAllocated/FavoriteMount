# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) /
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-08-09

First version.

### Added
- A macro that summons a random mount from your bags, chosen by an explicit
  zone list (flying zones vs ground-only).
- Automatic bag scan; flying is derived from the required riding skill, with
  `/fm fly` and `/fm ground` to correct it and `/fm exclude` to skip a mount.
- Druid travel forms: aquatic while swimming, flight where flying is allowed,
  travel on the ground; `/fm forms` puts them before mounts.
- A `FavoriteMount` macro, kept current by the addon, that you drag onto a
  button of your choice.
- Clicking again while mounted or shifted dismounts.
- German localization.
