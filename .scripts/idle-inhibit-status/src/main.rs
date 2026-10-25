//! Prints whether idle is currently inhibited, one line per state change:
//! `inhibited`, `active` or `unknown`.
//!
//! Wayland compositors do not expose idle inhibitors directly, so this compares
//! two ext-idle-notify-v1 (version 2) notifications:
//!   * "aware": idle after TIMEOUT ms, but never while an inhibitor is active
//!   * "input": idle after TIMEOUT + 1000 ms of no input, ignoring inhibitors
//! If the input notification fires while the aware one has not, something is
//! inhibiting idle. While the user is active the last known state is kept, so the
//! state updates about TIMEOUT + 1 s after input stops.
//!
//! With `--stasis`, `stasis info --json` is polled as well, and the state is also
//! `inhibited` when Stasis reports its own blockers (media, games, D-Bus, apps).

use std::io::Write;
use std::process::{exit, Command};
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::Duration;

use wayland_client::{
    globals::{registry_queue_init, GlobalListContents},
    protocol::{wl_registry, wl_seat},
    Connection, Dispatch, QueueHandle,
};
use wayland_protocols::ext::idle_notify::v1::client::{
    ext_idle_notification_v1::{self, ExtIdleNotificationV1},
    ext_idle_notifier_v1::ExtIdleNotifierV1,
};

#[derive(Clone, Copy, PartialEq, Eq)]
enum Status {
    Unknown,
    Active,
    Inhibited,
}

impl Status {
    fn as_str(self) -> &'static str {
        match self {
            Status::Unknown => "unknown",
            Status::Active => "active",
            Status::Inhibited => "inhibited",
        }
    }
}

/// Combined state shared between the Wayland loop and the Stasis poller.
struct Shared {
    wayland: Status,
    stasis: bool,
    printed: Option<Status>,
}

impl Shared {
    fn emit(&mut self) {
        let combined = if self.stasis { Status::Inhibited } else { self.wayland };
        if self.printed == Some(combined) {
            return;
        }
        self.printed = Some(combined);
        let mut out = std::io::stdout().lock();
        // Exit quietly when the reader (e.g. ironbar) goes away.
        if writeln!(out, "{}", combined.as_str()).and_then(|_| out.flush()).is_err() {
            exit(0);
        }
    }
}

#[derive(Clone, Copy)]
enum Kind {
    Aware,
    Input,
}

struct State {
    aware_idle: bool,
    input_idle: bool,
    shared: Arc<Mutex<Shared>>,
}

impl State {
    /// Called after each batch of events has been dispatched.
    fn evaluate(&self) -> Option<Status> {
        if self.aware_idle {
            Some(Status::Active)
        } else if self.input_idle {
            Some(Status::Inhibited)
        } else {
            None // user is active: keep the last known state
        }
    }
}

impl Dispatch<wl_registry::WlRegistry, GlobalListContents> for State {
    fn event(_: &mut Self, _: &wl_registry::WlRegistry, _: wl_registry::Event,
             _: &GlobalListContents, _: &Connection, _: &QueueHandle<Self>) {}
}

impl Dispatch<wl_seat::WlSeat, ()> for State {
    fn event(_: &mut Self, _: &wl_seat::WlSeat, _: wl_seat::Event,
             _: &(), _: &Connection, _: &QueueHandle<Self>) {}
}

impl Dispatch<ExtIdleNotifierV1, ()> for State {
    fn event(_: &mut Self, _: &ExtIdleNotifierV1,
             _: <ExtIdleNotifierV1 as wayland_client::Proxy>::Event,
             _: &(), _: &Connection, _: &QueueHandle<Self>) {}
}

impl Dispatch<ExtIdleNotificationV1, Kind> for State {
    fn event(state: &mut Self, _: &ExtIdleNotificationV1, event: ext_idle_notification_v1::Event,
             kind: &Kind, _: &Connection, _: &QueueHandle<Self>) {
        let idle = match event {
            ext_idle_notification_v1::Event::Idled => true,
            ext_idle_notification_v1::Event::Resumed => false,
            _ => return,
        };
        match kind {
            Kind::Aware => state.aware_idle = idle,
            Kind::Input => state.input_idle = idle,
        }
    }
}

/// True when Stasis reports anything holding its full idle plan.
///
/// The status class only becomes `idle_inhibited` for some sources (e.g. media
/// players); D-Bus holds such as Firefox's portal inhibit leave it at
/// `idle_waiting`, so the tooltip fields are checked as well. Suspend-only holds
/// are ignored because locking still happens.
fn stasis_inhibited() -> bool {
    let Ok(out) = Command::new("stasis").args(["info", "--json"]).output() else {
        return false;
    };
    let text = String::from_utf8_lossy(&out.stdout);
    if text.contains("\"idle_inhibited\"")
        || text.contains("D-Bus Inhibiting: yes")
        || text.contains("Paused: yes")
    {
        return true;
    }
    ["Games Inhibiting: ", "Apps Inhibiting: ", "Media Players Playing: "]
        .iter()
        .any(|label| count_after(&text, label) > 0)
}

/// Parses the number following `label` in the tooltip, 0 if absent.
fn count_after(text: &str, label: &str) -> u64 {
    text.find(label)
        .map(|i| &text[i + label.len()..])
        .map(|rest| rest.chars().take_while(|c| c.is_ascii_digit()).collect::<String>())
        .and_then(|digits| digits.parse().ok())
        .unwrap_or(0)
}

fn usage() -> ! {
    eprintln!(
        "usage: idle-inhibit-status [--timeout MS] [--stasis] [--stasis-interval SECS]\n\
         \n  --timeout MS            inactivity before the state is checked (default 1000)\n  \
         --stasis                also report Stasis blockers (polls `stasis info --json`)\n  \
         --stasis-interval SECS  Stasis poll interval (default 3)"
    );
    exit(2);
}

fn main() {
    let mut timeout_ms: u32 = 1000;
    let mut use_stasis = false;
    let mut stasis_interval = 3u64;

    let mut args = std::env::args().skip(1);
    while let Some(arg) = args.next() {
        match arg.as_str() {
            "--timeout" => timeout_ms = args.next().and_then(|v| v.parse().ok()).unwrap_or_else(|| usage()),
            "--stasis" => use_stasis = true,
            "--stasis-interval" => {
                stasis_interval = args.next().and_then(|v| v.parse().ok()).filter(|v| *v > 0).unwrap_or_else(|| usage())
            }
            _ => usage(),
        }
    }

    let conn = Connection::connect_to_env().unwrap_or_else(|e| {
        eprintln!("idle-inhibit-status: cannot connect to Wayland: {e}");
        exit(1);
    });
    let (globals, mut queue) = registry_queue_init::<State>(&conn).unwrap_or_else(|e| {
        eprintln!("idle-inhibit-status: registry error: {e}");
        exit(1);
    });
    let qh = queue.handle();

    let seat: wl_seat::WlSeat = globals.bind(&qh, 1..=1, ()).unwrap_or_else(|_| {
        eprintln!("idle-inhibit-status: compositor has no wl_seat");
        exit(1);
    });
    let notifier: ExtIdleNotifierV1 = globals.bind(&qh, 2..=2, ()).unwrap_or_else(|_| {
        eprintln!("idle-inhibit-status: compositor lacks ext_idle_notifier_v1 version 2");
        exit(1);
    });

    let _aware = notifier.get_idle_notification(timeout_ms, &seat, &qh, Kind::Aware);
    let _input = notifier.get_input_idle_notification(timeout_ms.saturating_add(1000), &seat, &qh, Kind::Input);

    let shared = Arc::new(Mutex::new(Shared { wayland: Status::Unknown, stasis: false, printed: None }));
    shared.lock().unwrap().emit();

    if use_stasis {
        let shared = Arc::clone(&shared);
        thread::spawn(move || loop {
            let inhibited = stasis_inhibited();
            {
                let mut s = shared.lock().unwrap();
                s.stasis = inhibited;
                s.emit();
            }
            thread::sleep(Duration::from_secs(stasis_interval));
        });
    }

    let mut state = State { aware_idle: false, input_idle: false, shared: Arc::clone(&shared) };
    loop {
        if let Err(e) = queue.blocking_dispatch(&mut state) {
            eprintln!("idle-inhibit-status: Wayland connection lost: {e}");
            exit(1);
        }
        let mut candidate = state.evaluate();
        // When input resumes, the compositor resumes both notifications, possibly in
        // separate batches. Before reporting "inhibited", flush pending events so a
        // half-delivered resume is not mistaken for a new inhibitor.
        if candidate == Some(Status::Inhibited) && shared.lock().unwrap().wayland != Status::Inhibited {
            if queue.roundtrip(&mut state).is_err() {
                exit(1);
            }
            candidate = state.evaluate();
        }
        if let Some(status) = candidate {
            let mut s = state.shared.lock().unwrap();
            s.wayland = status;
            s.emit();
        }
    }
}
