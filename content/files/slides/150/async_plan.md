# Lecture plan: Asynchronous Programming (Promises and the Event Loop)

Status: **prototype validated; draft deck written.** Working runtime +
tests + live demo at `~/exp/async_sml` (SML/NJ 110.99.8 + CML). All
transcripts below are machine-checked by the test suite; live timings
measured on this machine.
Draft slides: `async.tex` (same dir) — deliberately over-complete
("everything" deck, ~65 frames + backup section, one frame per plan
beat, in act order) for manual reordering and cutting. Builds clean via
`crucible/mkSlides async`. No title.png yet (text-only title frame,
TODO marker inside). Open questions at the bottom still stand.

## Placement and prerequisites

Everything this lecture needs exists by lecture 19:

- **CPS (L11)** — promises are revealed as "CPS where the continuation
  list lives in a ref."
- **Functors (L15)** — the scripted/live host swap *is* a functor
  application; this is the payoff lecture for modules.
- **Laziness (L18)** — `'a susp` vs `'a Promise.t` contrast: force is a
  synchronous *pull* by you; a promise is *pushed* by the world and you
  cannot force it.
- **Imperative (L19)** — the `Pending`/`Resolved` ref machine.

Natural slot: lecture 20-ish (currently Compilers) or a bonus/final-week
lecture. It also works as a "everything you learned, composed" capstone:
HOFs + types + modules + refs + CPS in one artifact.

## Thesis (say it verbatim, twice)

> Nonblocking host operations create independently progressing work.
> Promises represent their eventual results. Functional combinators
> describe dependencies among those results. `async`/`await` is
> direct-style notation for this composition.

And the one-line takeaway for exams:
**`await` expresses a local data dependency, not global blocking.**

## TypeScript strategy

Most students have *used* async/await (web projects, internships)
without a model — that's the hook, stated in the act-0 teaser: "by the
end you can implement `await`." Discipline: no TS syntax on screen until
act 6. But every act carries a named *TS shadow* — a fact about TS/JS
the instructor says out loud in passing — so the act-6 reveal is a
montage of payoffs ("you already proved this") rather than new material.
Framing sentence for the reveal: *TypeScript is this promise model with
compiler support; SML is the version where you can see all the parts.*
Misconception-driven throughout: each common JS async misconception is
busted by a demo or a test, never by assertion (list in the assessment
bank).

## The narrative spine (the story the lecture tells)

Seven beats, one story — and as of arc v2, this is also the literal act
order: *we want a program that can wait without stopping the world; the
language says no; everything in async programming is fallout from that
refusal.*

1. **The desire** (acts 0–1): a REPL that answers you while work runs —
   code that *waits for something without stopping everything*.
2. **The wall** (act 1): SML evaluates one expression to completion;
   there is no "meanwhile." Two distinct powers are missing:
   (a) no pausing an in-flight computation to come back later;
   (b) no events — nothing happens that our code didn't just do, so a
   sequential program's future contains no *arrivals*.
   Crucial twist: this is not an SML deficiency. JavaScript stands
   behind the *same* wall — one thread, run-to-completion, no
   continuations. The wall is the shared premise, not the contrast.
3. **First move — chop it yourself** (act 2, = CPS, L11): if the
   language can't pause you, pre-shatter the program and pass your
   future around as closures. Cooperative concurrency in bog-standard
   SML is therefore *possible* (cf. the coroutines hw) — but the price
   is your program's shape. The price has a name: callback hell
   (stage 1 of `app/evolution.fun`).
4. **Second move — organize the pieces** (act 3, promises): reify
   eventual results as values, express dependencies with combinators,
   let an event loop run the pieces. Still 100% sequential vanilla
   SML — the scripted host proves it by running the whole world
   deterministically. But every continuation is still written by hand.
5. **The missing ingredient — a world** (introduced act 2, made
   swappable act 5): a trampoline in a sealed box computes, but never
   *waits* — nothing ever arrives. Waiting-without-stopping needs host
   operations that return immediately while the work progresses
   elsewhere, and beat 2(b) says user code cannot build them. They are
   gifts from below: kernel / CML threads under our host, libuv /
   workers under Node. Same theorem, same architecture, both ecosystems.
6. **The last mile — straight-line code again** (act 6): nobody wants
   to write CPS forever. TypeScript's escape is the "hack" of this
   story's title: JS *still* cannot pause a function, so the **compiler
   performs beat 3 for you** — async/await compiles to the state
   machine (`notes/tsc-sum-es5.js`: `await` is `return [4, promise]`;
   the switch cases are your continuations, numbered; hoisted vars are
   the saved stack frame; `trys` is the reified handler stack).
   Suspension is *simulated* by returning plus re-entry. The SML/NJ
   callcc variant (`src/direct.fun`) is the other escape: a language
   with first-class continuations needs no compiler hack — await is a
   library function.
7. **Punchline** (act 8): nobody tore the wall down. JavaScript
   *institutionalized* it — run-to-completion became a guarantee, and
   an ecosystem where nothing blocks. Every async ecosystem is the
   same two gifts: event sources from the host, and continuations
   written by *someone* — you (callbacks, promises), the compiler
   (async/await), or the runtime (callcc, green threads). SML shows
   every layer bare; TypeScript fuses them behind two keywords. That
   is the whole difference.

## The two central artifacts

Same script, two dependency structures (both transcripts verified by
`test/test-repl.sml`; the same contrast reproduces live in a terminal):

Script: `run 40` · `help` · *job 0 completes* · `quit`

```
RESPONSIVE                          SERIAL
jobs> run 40                        jobs> run 40
[0] started                         [0] started
jobs> help                          help                  <- typed, ignored
commands: run n | help | quit       [0] finished: 80
jobs> [0] finished: 80              jobs> commands: run n | help | quit
quit                                jobs> quit
```

The only code difference (one line each):

```sml
| dispatch (Run n) = (launch n; loop ())                    (* responsive *)
| dispatchSerial (Run n) = launchAwaited n thenDo (fn () => loopSerial ())
```

## 80-minute arc (v2 — problem-driven)

v2 note (2026-07): reordered from the original demo-first/top-down arc
to a problem-driven discovery arc at the instructor's direction: hit the
blocking wall, suffer callback hell, then earn promises, the host, and
await. The finished demo survives as a 4-minute teaser so the goal stays
concrete. The cut sequence students should feel: *can't say it*
(blocking) → *can say it, gross* (callbacks) → *can say it cleanly*
(promises) → *can still say it wrong* (dependency bugs) → *can say it
beautifully* (await). Vehicles, split by role: the **jobs REPL** on the
projector (blocking is only visceral when your own keystrokes are
ignored), the **sum workflow** on slides (~25 lines per stage; all four
stagings in `app/evolution.fun`, transcripts machine-checked identical).

**0. Teaser — the goal (0–4)**
Live: responsive REPL. `run 43` (≈3s), `help` answers instantly,
`run 38`, `[1] finished` lands before `[0] finished`, `quit`. One
sentence: "this program is impossible with what you know so far — by
the end you'll have built it, and you'll know what `await` in
TypeScript actually is." Do NOT show the serial variant yet — it is
act 4's lesson.
*TS shadow:* "many of you have written `await` without knowing what it
is; in 80 minutes you can implement it."

**1. The wall (4–12)**
Write the obvious REPL: `loop { print prompt; TextIO.inputLine; dispatch }`.
Two distinct walls — keep them separate, they get separate gifts later:
- `TextIO.inputLine : instream -> string option` must stall *by its
  type*: it promises an answer to a question the world hasn't answered
  yet. Blocking I/O — the world is slow.
- `fib 43` run inline freezes everything for 3 seconds (demo the
  freeze). Blocking compute — *we* are slow.
Then the deeper, logical impossibility: the REPL must react to
*whichever happens first* — next command or job completion — and
sequential code must commit to waiting for exactly one thing. Any
choice is wrong. Sharpen: a sequential program has exactly one future
and no *arrivals*; we need a program with several pending futures.
Say the twist now, cash it in act 6: JavaScript stands behind the same
wall — one thread, run-to-completion, no way to pause a function.

**2. Shatter it yourself: callbacks and the two gifts (12–26)**
The move they know from L11: if you can't pause, invert control — stop
asking for values, hand over what-to-do-with-them:
`startInputLine : (string option -> unit) -> unit`.
Immediately puncture the false hope: **callbacks alone change nothing.**
`fun startInputLine k = k (TextIO.inputLine stdIn)` is fully
continuation-packaged and fully blocking. CPS is a *shape*; asynchrony
is a *contract*. Two gifts must be postulated, and neither is buildable
in user code:
*Gift 1 — host operations* with the two-clause contract: "start*
**returns immediately** AND the work **progresses independently of the
event loop**, with completion enqueued later." Separate gifts for the
two walls: `startInputLine` (nonblocking I/O) and `startComputation`
(independently progressing compute — nonblocking I/O does nothing for a
CPU-bound job). Ladder of three `startComputation` implementations to
show why both clauses are needed:
  1. `k (thunk ())` — runs inline; violates "returns immediately";
  2. `defer (fn () => k (thunk ()))` — returns immediately, but freezes
     the event loop for the job's whole duration when it runs;
  3. hand the thunk to independently progressing work (green thread /
     worker / process) — the loop stays idle and live.
Why the boundary is *necessary*, not just convenient: variant 3 is not
implementable in portable user-level SML at all. Interleaving a running
computation needs either preemption (runtime machinery: timers, signals,
capturable continuations — what CML packages on SML/NJ) or cooperation
(yield points — impossible for an opaque `unit -> 'a`; cf. the
coroutines hw in the lazy unit, where the type changes to expose steps).
Bog-standard SML has neither, so `spawn` *must* be a trusted host
capability — exactly as `setTimeout`/`fetch`/`Worker` cannot be written
in pure JavaScript. (Escape hatches and their tells, staff footnote:
`Posix.Process.fork` is in the optional Basis but forces monomorphic/
serialized results; SML/NJ's callcc + timer signals exist sans CML but
are just CML, unpackaged.) No parallelism ≠ blocking: preemption bounds
any thread's turn at one quantum, so responsiveness survives even
single-core (measured: `help` answered in ~20ms mid-fib-43); single-core
costs *speedup*, not liveness. JS mapping: variant 2 is a long
synchronous computation on Node's main thread (which really does freeze
Node); our `spawn` is a worker, not inline code.
*Gift 2 — the event loop*: a run queue of ready thunks, executed one at
a time to completion; `defer` to enqueue; the host's only permitted
action is queue insertion (the serialization firewall — deep dive in
act 4). Nonblocking operations without a loop are as useless as
callbacks without nonblocking operations; they are a matched set.
Now spend the pain: sum workflow, stage 1 (`CallbackSum`): the pyramid,
EOF handled at every level, the counter-dance join with two option refs
and an `arrive` check. Nothing returns a value — the result evaporates
into effects. Bug taxonomy (all real): the join fires early/twice/drops
a result; callbacks called twice or never; sometimes-sync-sometimes-
async invocation (Zalgo — order becomes nondeterministic at the call
site); an error handler forgotten at one level swallows failures; code
placed after a registration runs "too early" (the tail-position trap).
*TS shadows:* 2009-era Node looked exactly like this (error-first
callbacks, `if (err) return cb(err)` at every level); the same
impossibility theorem holds in JS.

**3. Promises: organize the shattering (26–40)**
Preferred opening — **the derivation** (instructor's construction):
start promise-free with request-style pausing,
`datatype 'r paused = Done of 'r | NeedLine of string -> 'r paused |
NeedJob of (unit -> int) * (int -> 'r paused)` — a shattered program as
an inert first-class value a driver interprets. Continuity gift: this
is the lazy-unit coroutines hw, nearly verbatim. Five forced moves:
(1) it works for sequential workflows; (2) the wall — pausing IS
requesting, so exactly one operation can be outstanding; "both in
flight" / "whichever first" are inexpressible in the type;
(3) the fix — decouple *start* from *wait*: starting returns a handle
to in-flight work, and that handle IS the promise, invented under
duress (best concept-image in the topic: eager fetch, spawn-without-
await, launch ≠ launchAwaited all fall out); (4) the handle's
requirements dictate `Pending of ('a -> unit) list | Resolved of 'a` —
observer list = attach-before-done + sharing, Resolved arm =
may-complete-before-waited = memoization, once = single assignment —
every arm answers a stated need; (5) the wrapper dissolves — the
driver's only move on `Paused (h, k)` is attach, so `thenDo` directly,
and paused scaffolding collapses. Promises derived from structural
necessity (concurrency forces start ≠ wait), with callback hell as the
historical exhibit of living at step 1 with bare callbacks.
Then the standard framing: `'a Promise.t`: one eventual result of one
already-started execution; shared by all observers; remembered after
resolution.
Contrast with `unit -> 'a` (a recipe, re-runnable) and `'a susp` (L18:
you pull; here the world pushes).
*TS shadow:* `async function f(a: A): Promise<B>` — `async` is a
return-*type* statement. JS promises are eager: `const p = fetch(url)`
has already started, and awaiting `p` twice does not refetch; the thunk
`() => fetch(url)` is the recipe, the promise is the execution.
The datatype (twenty lines that ended callback hell):

```sml
datatype 'a state = Pending of ('a -> unit) list | Resolved of 'a
```

Promise = CPS (L11) + single-assignment ref (L19). The `t`/`resolver`
split as type-driven design: observers can't fabricate results (the test
`resolve twice raises` is the invariant made executable).
Scheduler vocabulary worth teaching: the `Pending` observer list is a
**wait queue**, the loop's callback queue is the **run queue**, and
`resolve` is what moves work from one to the other. `await`/`thenDo`
parks work on a *condition*, not on the scheduler — which is why an
unresolved promise is a clean detectable deadlock, not a spin.
Why the split is forced, not chosen — two board-ready arguments:
(1) *types*: `defer : (unit -> unit) -> unit` runs thunks, but a parked
continuation is `'a -> unit` and only the promise will ever have the
`'a`; `resolve` is where the argument finally exists and the
continuation downgrades to a runnable thunk. (2) *the one-queue
alternative is busy-polling*: "resolved yet? re-enqueue me" burns CPU
and destroys quiescence detection, exit semantics, and the deadlock
warning — waiting must be a *state*, not an activity. Payoff picture:
the wait queues scattered across promises ARE the dependency DAG (cf.
work/span from the sequences unit, now as a runtime data structure);
the run queue is just its ready frontier; `resolve` advances the
frontier; the serial-REPL bug is one spurious edge.
Structure of the graph, precisely: multi-source (every host op mints a
world-fired source; no single root — that plurality IS the concurrency),
dynamically unfolded by its own traversal (steps mint new sources), and
a true DAG rather than a forest of trees for exactly one reason:
**joins**. Join-free programs (`thenDo` chains) are forests of paths —
the case raw callbacks survive; `both` gives in-degree 2, the shape
callbacks could only hand-roll as the counter dance. "Tree-ness fails
exactly at the joins, and the joins are why promises had to exist."
(Fork-join work/span DAGs are non-trees for the same reason.)
Discipline rules: state flips to `Resolved` *before* observers are
scheduled; observers are always `defer`red, never run synchronously.
Then the five-line `fromCallback` adapter: hand the host the promise's
own `resolve` as its callback — custody splits, write-end down into the
host, read-end up into user code.
Combinators as dependency edges: `upon`, `thenMap` (`map`), `thenDo`
(`bind`), `both`:
- `p thenDo f` — the next *async* step needs p's value.
- `p thenMap f` — only pure computation remains after p.
- `both (p, q)` joins two *already-started* operations — it creates no
  concurrency; the calls that produced p and q did. It kills the
  counter dance forever, written once in the library.
- `upon p k` observes without making your workflow depend on p.
Sum workflow, stage 2 (`PromiseSum`) — transcript machine-checked
identical to stage 1. Honest accounting: fixed = join, exactly-once,
sharing, result-as-value; remaining = the nesting is still CPS (flat is
a formatting idiom) and the per-step `NONE` handling — that tax is
exactly what JS's rejection channel removes (why rejection exists —
backup slide).
*TS shadows:* JS's `.then` is `map` and `bind` *overloaded* (inspects
the callback's return and auto-flattens) — SML's types force them
apart; `both` ≈ `Promise.all`; `upon` ≈ the deliberately-un-awaited
`.then` (`void promise` idiom). `Promise.withResolvers()` (ES2024) is
literally `Promise.new : unit -> 'a t * 'a resolver`;
`new Promise(executor)` is `fromCallback`; Node's `util.promisify` is
the adapter exercise. The always-defer rule is JS's law that `.then`
callbacks never fire synchronously even on settled promises ("don't
release Zalgo"). Design note: JS silently ignores a second resolve; we
raise — same invariant, different enforcement.

**4. The REPL, done right — and the bug that survives all abstraction (40–50)**
Build the responsive loop: `launch` = spawn + `upon`, deliberately don't
wait. NOW show the serial variant live (same commands, REPL dead for
3 seconds) and the one-line diff. The question: both use promises and
background computation — why does only one respond? Answer: the serial
version adds an unnecessary dependency edge between "read the next
command" and "current job finishes." State the takeaway: **await is a
local data dependency, not global blocking.** Even with all machinery,
you can reintroduce the act-1 freeze *logically* — dependency bugs are
the failure mode that survives every abstraction layer.
The complete state of an async program fits in exactly three holding
places — a strong slide: (1) the **run queue** (ready thunks), (2) the
**promise wait queues** (parked continuations, read side), (3) the
**host's registration slots** (held resolvers / in-flight operations,
write side — Node calls these *handles*; our live host's `pending`
counter is a census of them). The concurrent world's only permitted
action is queue insertion — the serialization firewall; fulfillment
itself always runs on the loop. Expect the sharp objection "isn't
host-enqueues-vs-host-fulfills extensionally the same?" — concede it
fully for the scripted host (it is; the hop is redundant there), then:
under true concurrency the hop is what lets promise internals stay
single-threaded and lock-free (direct fulfillment would race `resolve`
against a mid-callback `upon` on the same ref — lost observer = silent
deadlock), keeps "the world advances only between steps" true, and is
the signal-handler rule (self-pipe trick: never work in the handler,
only enqueue) in new clothes. Twin hop of the same species: `resolve`
defers observers rather than calling them (Zalgo). One principle twice:
every queue hop is an isolation firewall, and each costs one transit —
the price visible in the T0–T4 trace.
All fulfillment happens ON the loop — two flavors: **root resolutions**
(host-queued tasks whose body is the resolver, via `fromCallback` — the
only doorway for outside values) and **derived resolutions** (the
cascade: map/bind adapters resolving downstream promises as their steps
run). Corollary students should say out loud: no promise ever changes
state underneath a running callback — the world advances only *between*
steps.
Board moment for the runtime-state picture: ask "where IS the REPL loop
right now?" Answer: nowhere — workflows have no runtime identity. A
workflow exists only as (at most) one parked continuation in some
promise's wait queue; it's a chain of continuations threaded through
queues over time, never an inspectable thing. Contrast threads (stack +
identity + listable). Real-world fallout worth one sentence: Node can
only *count* pending handles (our `pending` ref), async stack traces
are bad because the stack dies at every await, and structured
concurrency exists to give workflows identity back.
Also the UI principle: jobs produce *values*; `upon` runs the UI update
on the serialized loop — completion order nondeterministic, UI
transitions sequential.
*TS shadow:* the responsive loop is every browser event handler ever
written; the serial loop is `for (const u of urls) await fetch(u)` —
the accidental-serialization bug.

**5. Swap the world (50–58)**
The L15 payoff — the host is a functor argument:

```sml
structure TestRuntime = MakeAsyncRuntime (ScriptedHost)
structure LiveRuntime = MakeAsyncRuntime (LiveHost)
```

ScriptedHost replaces the *world* with a list of arrivals — it
simulates event order, not compute time, with zero concurrency; that's
why every run is deterministic. Live-run the test suite (24 checks,
instant). Show the deadlock transcript: serial REPL + a job that never
completes ⇒ loop quiescent, main workflow unresolved, runtime warns —
"an await nobody will satisfy." And "empty run queue" splits in two:
idle-with-pending (census > 0: the loop *sleeps* — `Mailbox.recv` /
`poll`) vs quiescent (census = 0: exit, and the moment to check the
main promise for the deadlock warning).
*TS shadow:* ScriptedHost is `jest.useFakeTimers()` + mocked `fetch`:
deterministic async tests, which anyone who has debugged a flaky JS
test will feel.

**6. Straight-line again: the evolution + TypeScript reveal (58–70)**
Recap the ladder on one slide (all stages of `app/evolution.fun`,
transcripts machine-checked identical): stage 1 callbacks (the pain),
stage 2 promises (organized), stage 3 async/await — first as TS
pseudocode. Timeline mapped to the syllabus: callbacks = CPS (L11);
combinator libraries taming callbacks (async.js, 2011) = HOFs (L10);
promises (ES6, 2015) = CPS + single-assignment state (L19); async/await
(ES2017) = the CPS transform done by the compiler (L11 again).
**"Industry recapitulated this course, in order, over eight years."**
Only now does TS syntax appear — a montage paying off every shadow:
`Promise<A>` / `A Promise.t` · `await p` / `p thenDo (fn x => ...)` ·
`.then(f)` / `thenMap`-or-`thenDo` · `Promise.all` / `both` ·
`async (a: A) => B` / `A -> B Promise.t` · `Promise.withResolvers()` /
`Promise.new` · `util.promisify` / `fromCallback` · fake timers /
`ScriptedHost`. The desugaring rule:

```
val x = await p          p thenDo (fn x =>
rest             ==>       rest)
```

"The code after `await` is the continuation — you already knew
async/await; it's `bind` wearing syntax."
The course-specific kicker: async/await is a **CPS transform performed
by the compiler** — real `tsc` output of the sum workflow (typescript@5.5,
saved at `~/exp/async_sml/notes/tsc-sum.ts` / `tsc-sum-es5.js`): the
emitted `switch (label)` machine is a *defunctionalized* thenDo-chain —
numbered continuations instead of allocated closures — and each `await`
compiles to `return [4, promise]`: suspension is returning. The label is
the function's program counter, evicted to a variable because the
function must keep giving the CPU away. Killer side-by-side slide:
`MachineSum` in `app/evolution.fun` is the tsc output hand-transliterated
into SML (hoisted refs = `var x, y`; `label` ref = `_b.label`;
`upon ... step` = `return [4, p]`; the `sent` datatype = `_b.sent()`,
where SML's types expose defunctionalization's hidden cost — the union
of everything the function ever awaits, which JS's `any` hides).
"The TypeScript compiler does to your code what Lecture 11 taught you
to do by hand." Optional named rung between thenDo-chains and the
machine (instructor's construction, verified against the runtime):
`datatype 'r paused = Val of 'r | Paused of 'r paused Promise.t` —
suspension reified as an inert, inspectable value; the driver is
`fun drive (Val r) = ... | drive (Paused pp) = upon pp drive`. This IS
the generator protocol (`Val` = `{done:true}`, `Paused` = yielded
promise, `drive` = `__awaiter`'s pump), and it re-derives `bind` (the
driver's only possible move is `upon`). Two teachable walls inside it:
the continuation must receive the resolved value (not unit), and the
per-pause awaited type is existential — seal it in a `thenMap` closure
or enumerate it (= MachineSum's `sent` union). What reification buys
over thenDo isn't power but *governance*: the driver owns every
suspension point (logging, timeouts, fair interleaving, cancellation =
declining to continue). And a `paused` value is the lecture's best
proof object for "shattering manufactures no asynchrony": pure inert
data until some host fulfills the promise inside it. Ladder complete:
attach (thenDo) → reify (paused/generators) → defunctionalize
(label machine) → capture (callcc).
Who-writes-the-continuation trichotomy: the programmer
(callbacks/promises), the compiler (TS async/await), or the runtime —
optional wow-slide: `src/direct.fun` + `DirectSum`, `await` as a
*library function* via SML/NJ callcc; exceptions work across await
again (EOF handled once — machine-checked); cf. Filinski, "Representing
Monads" (POPL '94), done in SML/NJ decades before the `async` keyword.
Staff notes: SML/NJ-only; keep off the CML live host; callcc stays out
of student scope. Close by live-translating the jobs REPL into TS
pseudocode: the `while(true)`/`await inputLine()` loop with the
deliberately-un-awaited `spawn`.

Fidelity ledger (how much of Node we actually simulate — staff notes):
- *Faithful:* single-threaded run-to-completion callbacks (the mailbox
  gives this, not CML); `spawn` ≈ Worker / libuv pool (CML gives this);
  completion nondeterminism; `both` ≈ `Promise.all`; and the
  "don't block the event loop" pathology reproduces exactly — a long
  computation inside a *callback* freezes command processing while the
  reader thread buffers input, just as the kernel buffers packets while
  Node's JS thread is stuck. Even single-core-ness is faithful: Node
  never promises parallel JS.
- *Contract vs construction:* JS workers share nothing by fiat
  (structured clone); our spawned thunks share the heap and must be pure
  by discipline. (A fork host would enforce isolation and its
  encode/decode requirement is literally structured clone — nice
  symmetry for a backup slide.)
- *Missing, cheap, high-value:* **timers.** `setTimeout` is JS's
  canonical async primitive; adding `startTimer` to `ASYNC_HOST` yields
  `sleep : int -> unit Promise.t` and unlocks fake `fetch`
  (spawn+sleep), `Promise.race`, timeouts, debounce — most JS tutorial
  exercises then port 1:1. CML side is trivial (`CML.timeOutEvt`);
  scripted side needs a logical clock (moderate rework of the
  event-at-idle model). Decide before writing homework.
- *Excluded by design:* rejection (students will ask — backup slide),
  microtask/macrotask split, async/await syntax itself.

**7. Trace exercise (70–78)**
Method: "find each root resolution, unroll its cascade to quiescence."
Slide-ready worked exemplar (queue states T0–T4 for one keystroke):
`~/exp/async_sml/notes/trace-input-line.md`. Then predict the transcript
for `run 46` · `run 42` · *complete 1* · *complete 0* · `quit`
(out-of-order completion).

**8. Punchline (78–80)**
Spine beat 7, verbatim: nobody tore the wall down — JS institutionalized
it; every async ecosystem is two gifts plus someone writing your
continuations. Restate the thesis. One slide of what we hid: threads,
sockets, scheduling, rejection, cancellation, microtasks — "none of it
was needed to reason correctly."

## Cutting to 60 minutes

Drop act 7 (becomes homework), compress act 6 to
ladder + desugaring rule + one side-by-side (8 min), trim act 2's bug
taxonomy to three items. Acts 1, 2, 3, 4 are load-bearing and uncuttable.

## Assessment bank

- *The* question: both variants use promises and background computation —
  why does only one remain responsive? (unnecessary dependency edge)
- Adapter: given `Host.lookup : key * (value -> unit) -> unit`, implement
  `lookup : key -> value Promise.t`. (= `fromCallback`)
- Trace: script of events → exact transcript. The scripted host generates
  and *checks* unlimited instances mechanically.
- Why does `Promise.pure (TextIO.inputLine stdIn)` not make input async?
- Prove from the datatype + code: a promise is `Resolved` at most once,
  and every observer runs with the same value, exactly once.
- Implement `both` from `bind`/`map`/`pure`; explain why it adds no
  concurrency.
- Predict the deadlock: which scripts leave the main promise unresolved?
- Type sort: given six type signatures, which denote async operations?
- TS-facing: given `for (const u of urls) results.push(await fetch(u))`,
  name the accidental dependency and rewrite with `both`/`Promise.all`;
  translate a `thenDo` chain to async/await and back; desugar a
  two-await TS function into promise combinators by hand.
- Evolution: given a raw-callback pyramid (CallbackSum-shaped), rewrite
  as a promise chain; state which pathologies disappeared (manual join,
  exactly-once, result-as-value) and which only changed clothes (the
  nesting is still CPS; option handling persists sans rejection).
- The tail-position trap: show code with a print *after* an
  `upon`/`thenDo` registration; ask when it prints (immediately — the
  registration must be the activation's final act; everything "after the
  await" must live inside the handed-off continuation). Note the TS
  compiled form enforces this structurally (`return [4, p]` registers
  and returns in one statement); hand-written CPS makes it a discipline.

Misconceptions to bust (each by demo or test, never assertion):
1. "`await` blocks the program" — act 4 demo; local dependency only.
2. "`async`/promises make things run in the background" — act 3:
   combinators create zero concurrency; only host operations do.
3. "A promise is a recipe I can rerun" — act 3: eager, one execution,
   memoized (`await` twice ≠ run twice).
4. "Wrapping code in a promise makes it async" — act 2:
   `new Promise(r => r(blockingCall()))` is `Promise.pure` around a
   blocking call; the work already happened.

Homework idea: students get `PROMISE` + `ASYNC_RUNTIME` sigs and write
combinators + a small app; autograding is transcript comparison against
`ScriptedHost` — deterministic, no flakiness, no systems knowledge.

## Student-visible vs staff code

| Students must understand | Staff-supplied, opaque |
|---|---|
| `PROMISE` sig + `Pending/Resolved` impl | `ScriptedHost` internals (concept yes, code no) |
| `ASYNC_HOST` *signature and contract* | `LiveHost` (CML green threads) |
| `fromCallback`, `MakeAsyncRuntime` shape | `RunCML` driver scripts |
| the whole `JobsRepl` functor | |

## Deviations from the handoff proposal (all embodied in the code)

1. `ASYNC_HOST` gained `val print : string -> unit`. Without it transcript
   tests can't capture output, and a socket host couldn't emit output at
   all. Output is a host capability, same as input.
2. Live host = CML green threads on stdin, not a localhost socket console.
   One terminal, zero moving parts, and the proposal's own argument ("the
   mechanism is not course content") says the socket tax buys nothing.
   Socket host stays a plausible optional appendix.
3. Scripted input *buffers and echoes on arrival* (like a real terminal)
   instead of erroring when no read is pending. This is what makes one
   script drive both REPL variants — the contrast transcript is the
   lecture's centerpiece and the proposal's stricter model can't produce it.
4. `run` semantics pinned: drive to quiescence, warn if the main promise
   never resolved. Node-like, testable, and yields the deadlock beat.
5. Scripts are ordered events delivered at loop-idle rather than
   timestamped; same determinism, simpler model (timestamps can stay as
   slide decoration).
6. (v2, 2026-07) The proposal's top-down lecture order (demo the finished
   thing, then reveal) is replaced by a problem-driven discovery arc at
   the instructor's direction; the finished demo survives as the act-0
   teaser.

Agreed with and kept: promises (not raw CPS `('a -> unit) -> unit`) as
the public abstraction; the resolver split; success-only promises;
defer-always discipline; the excluded-topics list.

## Concurrency, not parallelism (measured)

The CML host provides true *concurrency* — preemptive interleaving,
independent progress, genuinely racy completion order — but no
*parallelism*: SML/NJ multiplexes all green threads on one OS thread.
Measured: fib 43 alone ≈ 2.8s; two overlapped fib 43s both finish ≈ 11s
(no speedup; timeslicing overhead actually loses to running them
back-to-back). Consequences:

- The demo demonstrates **responsiveness**, never throughput. Do not run
  two long jobs and imply they compute simultaneously; a student who
  times it will catch it.
- This is the honest JS analogy anyway: Node's event loop is
  single-threaded; parallelism lives in the host (libuv pool, workers) —
  exactly where it would live here.
- Course tie-in (very 15-150): parallelism is the *deterministic cost
  story* students already have from sequences/work-span (L17); this
  lecture is the *concurrency* story — nondeterministic order, dependency
  structure. Harper: "parallelism is not concurrency." Keep the axes
  separate on a slide.
- The `ASYNC_HOST` contract is deliberately agnostic, so a genuinely
  parallel host is a drop-in: fork-per-job + result over a pipe gives
  real multicore speedup in SML/NJ with zero student-code changes. The
  type wrinkle is itself teachable: a polymorphic `'a` cannot cross an
  address space, so a forking host op must be monomorphic
  (`(unit -> string) * (string -> unit) -> unit`) or take encode/decode —
  serialization surfaces in the type. Optional staff project (~a day),
  good stretch demo; Poly/ML (real OS threads) would be cleaner still but
  is a different compiler than the course toolchain.

How CML preempts sequentially-written code (staff background, optional
slide): SML/NJ compiles via CPS with heap-allocated frames, so *every
function call* performs a heap-limit check. When the quantum timer fires,
the runtime invalidates the heap-limit pointer; the next check traps to a
continuation-based signal handler (`signal * count * unit cont -> unit
cont`), and CML's handler enqueues the interrupted thread's continuation
and returns another thread's. A context switch is a callcc swap — O(1)
because frames live on the heap. Same architecture as an OS scheduler
(timer interrupt + saved context), one level down from the OS; Erlang's
reduction counting and Go's async preemption are the same move.
Verified empirically: `probe-interleave.sml` shows two spawned fib
workers round-robining `A B A B ...` on a shared log.

**Semantic caveat this creates (must appear in lecture):** spawned thunks
are preemptively interleaved, so mutation of shared refs from inside a
spawned computation is observably racy (interleaving races only — single
core means no torn values). Event-loop callbacks keep JS-style
run-to-completion atomicity: they execute one at a time on the loop
thread. So the rule "jobs are pure functions that produce values; only
`upon`/loop callbacks touch UI state" is not a style preference — it is
the safety condition under which the abstraction never leaks. (JS gets
the same guarantee by fiat: workers share nothing.)

## Demo logistics and risks

- Machine dependency: SML/NJ + CML only (no MLton for the live host).
  Precision for staff: nonblocking/poll primitives could replace CML for
  the **input** side only — readiness notification cannot advance an
  opaque computation. A poll-only host freezes the REPL for the duration
  of every job (kernel buffers keystrokes; nothing processes them) —
  browser-JS-before-Web-Workers, whose historical fix (setTimeout
  chunking, React Fiber) is the cooperative type change. `spawn` with a
  responsive loop requires green threads (CML), a process (fork), OS
  threads (Poly/ML), or cooperation; there is no poll-shaped option.
  ScriptedHost is exempt: it simulates event *order*, not compute time,
  which is all the tests need — real concurrency is load-bearing for the
  live demo only.
  Verified 2026-07: CML ships enabled in the default SML/NJ 110.99 build
  at every layer of the course toolchain — the Gradescope `setup.sh`
  installs from the official `config.tgz` whose default `config/targets`
  requests `cml`/`cml-lib`; the mac and AFS setup flows are the same
  distribution. No install changes needed. Grading never imports `$cml`
  anyway: autograding runs entirely on ScriptedHost (plain SML); CML is
  live-demo-only. (Caveat: `$cml` is CM-only — the millet/molasses MLB
  toolchain doesn't know it.)
  fib timings on this laptop: 40≈1s, 43≈3s, 45≈8s — rehearse and pick n
  so jobs outlive your typing.
- The `jobs> ` prompt needs explicit flush (LiveHost does this) — if the
  prompt ever vanishes, that's the first thing to check.
- Backup for live-demo failure: piped-input run with timestamps (command
  in the README) produces the same evidence non-interactively; worst case,
  the scripted transcripts are the same content and cannot fail.
- Students *will* ask "what if the computation raises?" Backup slide:
  add `Rejected of exn` / make it `'a result Promise.t`; explicitly out of
  scope for the core model.

## Open questions before writing the .tex

1. Schedule: displace a lecture (which?) or run as bonus/final-week?
2. Naming: `thenDo`/`thenMap` vs `>>=`-style — course convention check.
3. Show `resolver` in lecture (I vote yes — it's the type-design lesson)
   or keep `new`/`resolve` staff-only until the reveal act?
4. Does this pair with a homework/lab, or lecture-only? (The scripted
   host makes a hw cheap to grade; see assessment bank.)
