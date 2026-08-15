# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) /
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-08-15

### Added
- Warlock and paladin steeds and the shaman's ghost wolf: class mounts are
  spells, not bag items, and were invisible to the addon until now.
- French localization.

### Changed
- Flight zones are matched by map id instead of by zone name, so any client
  language works; the name list stays as a fallback.
- `/fm` prints the map id, and every message it prints is translatable.

## [1.0.0] - 2026-08-15

### Added
- Druids indoors: cat form, where no mount comes out and travel form is refused.

### Changed
- Druids: form or mount is decided by speed now (a tie goes to the form, since
  shifting is instant) — flight form over a drake, a ground mount over travel form.
- `/fm forms` now means "always shift", instead of "forms before mounts".

### Fixed
- Swimming and roofs are detected again: neither fires a reliable event, so both
  are sampled.
- `/fm` shows how form and mount are being weighed.

## [0.1.1] - 2026-08-15

### Added
- Project artwork. No changes in the game.

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
