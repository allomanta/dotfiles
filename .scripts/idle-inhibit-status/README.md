# idle-inhibit-status

Prints `inhibited`, `active` or `unknown` (one line per change) for status bars.

Wayland doesn't expose idle inhibitors, so this compares two ext-idle-notify-v1
(v2) notifications: one that respects inhibitors and one that only tracks input.
If input has been idle but the inhibitor-aware one never fired, something
(ironbar's inhibit, browser video, a fullscreen app...) is inhibiting idle.
The state updates about 2 s after you stop using keyboard/mouse; while you're
active the last known state is kept.

`--stasis` also polls `stasis info --json` and reports `inhibited` when Stasis
sees its own blockers (media players, games, D-Bus inhibit requests).

    idle-inhibit-status [--timeout MS] [--stasis] [--stasis-interval SECS]

## Build / install

    cd packaging && makepkg -si      # pacman package, installs /usr/bin/idle-inhibit-status
    cargo build --release            # or just build to target/release/

## ironbar

    $idle_status = {
        name = "idle-status"
        class = "idleStatus"
        type = "script"
        mode = "watch"
        cmd = "idle-inhibit-status --stasis | sed -u 's/^inhibited$/󰅶/; s/^active$//; s/^unknown$//'"
    }
