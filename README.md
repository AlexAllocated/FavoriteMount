# Favorite Mount

<img src="media/logo.png" alt="Favorite Mount" width="128">

One button for mounting in WoW Classic (TBC Anniversary, 2.5.6): it picks a
random mount from your bags that fits where you are standing, and shifts a
druid into the right travel form instead when that works better.

## Features

- **Knows where you may fly.** This client has no dependable flight check, so
  the addon carries an explicit zone list. Unlisted zones count as ground-only,
  and an unknown zone still flies if you are on a flight-enabled continent.
- **Finds your mounts by itself.** Your bags are scanned for mount items; the
  riding skill an item demands decides whether it flies. You can correct any
  item by hand.
- **Random every time.** Several flying (or ground) mounts in the bags means a
  different one on each click.
- **Druid forms.** Aquatic form while swimming, flight form where flying is
  allowed, travel form on the ground — each only if you know it. Optionally
  forms take priority over mounts.
- **Dismounts.** Clicking again while mounted or shifted puts you back on your
  feet.
- **Just a macro.** The addon keeps a `FavoriteMount` macro in your macro
  window up to date — drag it onto any button or keybind you like. No hidden
  buttons, and the action button shows the icon of whatever is currently in
  there.

## Usage

- `/fm` — what would the macro do right now? Plus zone, mount lists and forms
- `/fm macro` — create or repair the macro
- `/fm fly` / `/fm ground` — classify the mount your cursor rests on
- `/fm exclude` — skip (or use again) the mount your cursor rests on
- `/fm forms` — druids: forms before mounts
- `/fm help` — this list

## Compatibility

For WoW Classic TBC Anniversary (interface 2.5.6). No dependencies.

## License

MIT — see [LICENSE](LICENSE).
