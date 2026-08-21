# 15-150 Final Question Bank — Brainstorm

Seeded from the shape of `practice_final.tex` / `final.tex`. Both exams share
a spine (7 required sections + 1 bonus), so this bank is organized the same
way: pick one from each bucket for the real final, a *different* one from
each bucket for the practice final, and bank the rest for next semester.

Course arc referenced (lecture1–22): Prologue, Equivalence/Binding/Scope,
Induction/Recursion, Structural Induction/Tail Recursion, Trees, Asymptotic
Analysis, Sorting/Parallelism, Polymorphism, Higher-Order Functions,
Combinators/Staging, CPS, Exceptions, Regular Expressions, Modules I–III
(Structures/Signatures, Functors, Red-Black Trees), Sequences, Lazy
Programming, Imperative Programming, Compilers, Program Analysis.

Existing final/practice_final already spend their budget on: shrub proof
(commutativity + invert, structural induction), array/bubblesort in-place,
BDT compression (CPS partition, work/span), level-order traversal (streams),
file systems (rose tree, work/span, absolutize), farm animals (bonus type
design). Midterms already used: BSTs (twice), fusing transformations, cursed
predicates (exceptions), robust folding, matching with prefixes (twice),
deoptionalization nation, pausing fold. **New questions below avoid
re-treading these exact vehicles**, though some intentionally reuse a
*mechanism* (e.g. another CPS problem) since that's fair game for a final.

---

## Bucket 0: Types and Values (opener, always present)

This section is just a grab-bag of 6-8 short snippets. Treat these as a pool
to draw 6-8 from, not full "questions" — mix and match on the day.

1. Shadowing across a functor application:
   ```sml
   structure S = struct val x = 1 end
   val x = 2
   structure T = struct val x = S.x + x end
   val x = 3
   val res = T.x + x
   ```
   (type `int`, value `6` — tests static scoping through structures)

2. A polymorphic value restriction trap:
   ```sml
   val id = fn x => x
   val r = ref NONE
   val () = r := SOME id
   val f = valOf (!r)
   val res = (f 1, f "a")
   ```
   NWT — `r`'s type gets monomorphized to `('a -> 'a) option ref` pinned at
   the *first* instantiation site... actually resolve carefully: without an
   explicit instantiation before `r := SOME id`, `r : ('a -> 'a) option ref`
   stays polymorphic only if `id` is a syntactic value (it is), so this is
   actually well-typed and `f` gets instantiated once — pick apart whether
   `f` can be used at two different types after `valOf`. (Good "gotcha"
   because most students think value restriction always monomorphizes.)

3. Exception used as ordinary control, not error:
   ```sml
   exception Found of int
   val res =
     (List.app (fn x => if x > 3 then raise Found x else ()) [1,2,3,4,5])
     handle Found n => n
   ```
   (type `int`, value `4` — tests exceptions-as-nonlocal-return, `List.app`'s
   type)

4. Ref aliasing with function values:
   ```sml
   val counter = ref 0
   fun bump () = (counter := !counter + 1; !counter)
   val fs = List.tabulate (3, fn _ => bump)
   val res = List.map (fn f => f ()) fs
   ```
   (type `int list`, value `[1,2,3]` — shared mutable state across a list of
   closures, all aliasing the same `counter`)

5. Datatype with a function component evaluated eagerly vs. the constructor
   itself:
   ```sml
   datatype thunk = Delay of unit -> int
   fun force (Delay f) = f ()
   val x = Delay (fn () => 1 div 0)
   val res = "no crash yet"
   ```
   (type `string`, value same — tests that constructing `Delay (fn () => ...)`
   doesn't evaluate the body; classic lazy-vs-eager warm-up before the
   Lazy Programming section elsewhere on the exam)

6. Structural equality on a type containing `->` hidden inside a datatype
   without a comparison — a NWT snippet for equality typeclass reasoning:
   ```sml
   datatype 'a box = Box of 'a
   val res = Box (fn x => x) = Box (fn x => x)
   ```
   NWT — `''a` equality type constraint fails because `'a box` admits
   functions, which aren't equality types.

7. A tricky `let`/`local` scoping question reusing `val rec`:
   ```sml
   val rec f = fn 0 => 1 | n => n * f (n - 1)
   val f = fn 0 => 0 | n => n + f (n - 1)
   val res = f 3
   ```
   (type `int`, value `6` — second `f` shadows, its own body's `f` refers to
   *itself* only if written with `val rec`, but it's plain `val`, so the
   inner `f` refers to the *first* `f` (factorial). Trace: `f 3 = 3 + f 2`
   where inner `f` is factorial `= 3 + 2 = 5`... work this out carefully by
   hand before finalizing the "value" answer, this is a good but fiddly one)

8. Module sealing hiding a representation, tested via `op=`:
   ```sml
   signature S = sig type t val mk : int -> t end
   structure M :> S = struct type t = int val mk = fn x => x end
   val res = M.mk 1 = M.mk 1
   ```
   NWT — `t` is abstract outside `M`, so `=` isn't available on it even
   though the underlying representation is `int`. Tests opaque ascription.

---

## Bucket 1: Conceptual Questions (T/F + short answer, always present)

Draw 6-8. These should be quick (2 pts each), testing definitions precisely.

1. T/F: In CPS, every function call becomes a tail call. (True — that's the
   entire point of the transformation.)

2. T/F: A red-black tree's height is always exactly `O(log n)` in the worst
   case, never merely amortized. (True — it's a genuine worst-case bound,
   unlike e.g. splay trees.)

3. Given a spec with a vacuous REQUIRES (`true`), can ENSURES still fail to
   hold for some inputs and the implementation still be correct? (No —
   `REQUIRES true` means ENSURES must hold for *all* inputs.)

4. T/F: `map` and `filter`, in that order, can always be fused into a single
   `foldr` pass without changing behavior, for any `f` and `p`. (True in the
   pure/total case — good chance to ask them to write the one-line fused
   `foldr` body as the "brief justification.")

5. T/F: A functor is a compile-time-only construct; no functor application
   can fail at runtime due to a value inside the structure argument. (False
   — the *functor application itself* can't fail from type mismatches
   (that's caught statically), but code inside the resulting structure's
   `val` bindings can still raise exceptions/loop at elaboration-adjacent
   runtime, e.g. `struct val x = 1 div 0 end` — good for testing
   static-vs-dynamic boundary precision.)

6. What is the language of `Star (Char #"a")` unioned with the empty string
   regex, described set-theoretically? (`{a^n : n >= 0}` — same as `Star`
   alone, testing that students know `Star` already contains empty string.)

7. Work/span short-answer: if `W(n) = O(n)` and `S(n) = O(log n)`, what is
   the parallelism, and what does that number mean operationally? (`n /
   log n`; roughly how many processors you can usefully throw at the
   problem before you stop getting speedup.)

8. T/F: Two streams that produce the same *finite prefix* for all prefixes
   you've checked so far are provably equal streams. (False — bisimulation
   requires the *entire* (possibly infinite) unfolding to agree; finite
   testing is evidence, not proof. Nice one to pair with the actual
   "Level Order Traversal" style content already on the exam.)

9. True or false, no justification: a well-typed program can still raise an
   uncaught exception. (True.)

10. T/F: `ref` cells make it possible to write functions that violate
    referential transparency, but every SML function typed `int -> int` is
    automatically referentially transparent regardless of implementation.
    (False — a function of that type can close over/mutate a ref and behave
    differently on repeated calls with the same argument.)

---

## Bucket 2: Proof Question (structural/functional correctness induction)

The exam always has one heavyweight proof (shrubs/invert this time). For a
fresh vehicle, avoid trees-that-invert; use a different structure and a
different property so the *proof technique* transfers but the object is new.

### Option A — "Zippers and Reconstruction" (structural induction on a
zipper/context type)
Define a `crumb` / `context` type for a binary tree (used for O(1) local
edits), and a `plug : context -> tree -> tree` reconstruction function, plus
`go_left`/`go_right`/`go_up`. Ask students to prove that plugging back
immediately after going down and up is the identity:
`plug (up_of (down_left c t)) (down_left c t applied then re-plugged) = plug c t`
— basically a "zipper round-trip" theorem. This tests structural induction
over a *context* (not the data type itself), which the course likely hasn't
proved before, good final-only difficulty.

### Option B — "Church Numeral Arithmetic" (ties to lambda calculus lecture,
since `lambda.tex`/`lambda2.tex` are in the modified files — good sign this
unit needs final coverage)
Define SML-encoded Church-style numerals as
`type 'a church = ('a -> 'a) -> 'a -> 'a`, give `zero`, `succ`, `plus`.
Prove by induction on `n` that `plus (church_of n) (church_of m)` is
equivalent to `church_of (n + m)`, using a stated lemma about `succ`
commuting with application count. Good if lambda calculus made it onto the
syllabus for this offering (looks likely given the new `lambda.tex`).

### Option C — "Reduce Homomorphism" (parallelism-flavored proof, ties
Sequences + associativity, distinct from the shrub/commutativity proof
already used)
Given `Seq.reduce f z` and a claim that `f` is *associative* (not
commutative — deliberately the complementary algebraic property to what's
already tested), prove
`Seq.reduce f z (Seq.append (A, B)) ~= f (Seq.reduce f z A, Seq.reduce f z B)`
by induction on the structure of the sequence's (assumed) tree
representation, using a stated lemma `Seq.append` is total and associative
itself. This is the most "on-genre" pick — mirrors the shrub proof's shape
(binary op + reduce) but swaps commutative-invert for associative-append,
so it's testably distinct without being a foreign topic.

**Recommendation:** Option C for the real final (closest in spirit/difficulty
to what's already validated as fair), Option A for the practice final (zippers
are meatier/more final-caliber and a good practice differentiator), keep B
banked in case lambda calculus gets a dedicated slot instead of folded into
this proof.

---

## Bucket 3: Imperative/Arrays-style Question (mutation, in-place, specs)

Existing final: array-as-`ref Seq.t`, bubblesort in-place. For a new one,
keep the "build a mutable structure out of an immutable one" flavor but
change the object.

### "Union-Find (Disjoint Sets)"
Natural fit: it's the canonical teaching example for refs + in-place
algorithms, wasn't used yet, and has a clean escalating part structure:
1. `type uf = int ref Seq.t` representing parent pointers; implement
   `make : int -> uf` (each element its own parent).
2. Implement `find : uf -> int -> int` (follow parent pointers to the root;
   no path compression yet).
3. Implement `union : uf -> int * int -> unit` (point one root's ref at the
   other).
4. Work/span or just work: recurrence for `find` in terms of chain depth.
5. Harder finisher: implement `find` *with path compression* (mutate
   pointers along the way to point directly at the root), and ask students
   to informally justify why this doesn't change `find`'s specification's
   ENSURES clause even though it has a mutation side effect.

This is a strong final-tier question: reuses the ref-array idiom already
established in lecture, escalates naturally, and the path-compression part
is a great "aha" mutation-changes-performance-not-meaning capstone.

### "In-place Reversal / Rotation"
Lighter-weight alternative if Union-Find feels too meaty: implement
`reverse : 'a array -> unit` in-place via swapping from both ends inward,
then `rotate : 'a array -> int -> unit` (rotate left by k) via three
reversals — a classic trick (reverse first k, reverse rest, reverse whole).
Good if you want a shorter, more mechanical imperative question instead of
Union-Find's conceptual weight.

---

## Bucket 4: CPS / Continuations / Exceptions-flavored Question

Existing final already has a CPS `partition`/BDT-compression question, so a
new one should either go a different direction (exceptions-as-control) or
be clearly non-overlapping in vehicle.

### "Backtracking Search via Exceptions and CPS, compared"
Set up a small constraint-style search (e.g., placing non-attacking rooks,
or finding a subset summing to a target) and ask for **two** implementations:
1. One using `raise`/`handle` to short-circuit on the first success
   (exceptions as nonlocal exit).
2. One using CPS with a success continuation and failure continuation
   (`sc`/`fc`), matching the two-continuation `partition'` idiom already
   used in the practice final's extra credit — so this is a nice callback
   without being the same problem.
Then ask a conceptual part: what's the operational difference between the
two approaches in terms of what's on the "stack" versus explicit
continuation closures? Good synthesis question tying Exceptions + CPS
lectures together, which the existing final doesn't currently combine.

### Lighter alternative — "Early-Exit `forall`/`exists`"
Implement `forall : ('a -> bool) -> 'a list -> bool` and
`exists : ('a -> bool) -> 'a list -> bool` two ways (recursion using
`andalso`/`orelse` short-circuiting vs. exception-based early exit), then
ask which is asymptotically better and why (the naive recursive version is
already short-circuiting via `andalso`/`orelse`'s laziness, so the "trick"
is realizing the exception version buys you nothing here — a good
conceptual gotcha, shorter than the backtracking version above).

---

## Bucket 5: Laziness / Streams-flavored Question

Existing final: `levelord`/`zipAppend`/`flatten'` (level-order via streams).
Keep the "streams model an unusual traversal or infinite structure" flavor,
but change the object away from tree traversal (already spent).

### "The Sieve of Eratosthenes, Streamified"
1. Given `nats_from : int -> int stream`, implement `sieve : int stream ->
   int stream` that filters out multiples of the head, lazily, producing
   the stream of primes when seeded with `nats_from 2`.
2. Is your `sieve` maximally lazy? (Good chance to reuse the "is this
   maximally lazy, if not fix it" question type from the existing exam,
   but on new code — that's a fair, expected repeat since it's a *skill*
   question, not a content question.)
3. Implement `primes : int -> int list` that takes the first `n` primes
   using `Stream.take` (or hand-rolled), in terms of `sieve`.
4. Short conceptual: why would implementing the sieve directly on
   `int list` instead of `int stream` be either wrong or unacceptably
   inefficient? (Infinite list, or: eagerly filtering an infinite list
   never terminates — ties back to the finale on why laziness exists.)

This is a very canonical CS lazy-eval example that hasn't been used yet in
this exam family and reads well against the appendix's `STREAM` signature
that's already printed on the exam.

### Lighter alternative — "Merging Infinite Streams"
Implement `merge : int stream -> int stream -> int stream` that merges two
infinite *sorted* streams into one sorted stream (dedup optional as a
second part), then use it plus `nats_from`/`map` to build the stream of
"3-smooth numbers" (numbers of the form `2^a * 3^b`) — a fun, slightly
harder capstone if you want something showier than the sieve.

---

## Bucket 6: Modules-flavored Question (Structures/Signatures/Functors)

The existing final doesn't currently have a dedicated Modules question (it's
folded lightly into Types and Values #4 and the appendix signatures) despite
three lectures (14-16) on it. This is the biggest coverage gap worth filling.

### "A `PRIORITY_QUEUE` functor from an `ORDERED` structure"
1. Give the `ORDERED` signature (`type t`, `val cmp : t * t -> order`) and
   a `PRIORITY_QUEUE` signature (`empty`, `insert`, `deleteMin`, `isEmpty`).
2. Ask students to write the functor header
   `functor MakePQ (O : ORDERED) :> PRIORITY_QUEUE where type elt = O.t = ...`
   filling in a simple (e.g., sorted-list or leftist-heap-lite) `deleteMin`
   implementation using `O.cmp`.
3. Conceptual: why does `PRIORITY_QUEUE` need `where type elt = O.t` (or
   equivalent sharing) rather than plain opaque ascription — what breaks
   for the client if you drop it? (Good test of sharing constraints /
   translucency, likely lecture 15 material.)
4. Given two different `ORDERED` structures for `int` (ascending vs.
   descending), show that `MakePQ` applied to each produces priority queues
   that are *not* interchangeable even though both queue `int`s — testing
   that functors generate genuinely distinct types per application.

This directly exercises lecture 14/15 content that otherwise has no home on
the exam, and functors-generate-fresh-types is a classic "gotcha" final
question.

---

## Bucket 7: Trees / Red-Black / BSTs-flavored Question

Midterms already used BSTs three times and this final avoids them entirely
in favor of shrubs/BDTs — reasonable, since BSTs are heavily tested
elsewhere. If you want *some* red-black tree presence on the final (lecture
16 is dedicated to it), consider a short, self-contained question rather
than a full section, since a full RBT invariant-maintenance question is
usually midterm-tier already-covered territory:

### Short-answer insert: "Why Red-Black, not just BST"
Give a skewed insert sequence into a plain BST vs. a red-black tree; ask
for the resulting *heights* of each, and a one-line explanation of why the
red-black invariants force `O(log n)` height regardless of insertion order.
Good as a Bucket-1-style conceptual filler rather than a dedicated section
— i.e., fold 1-2 of these into Bucket 1 instead of making a whole section.

---

## Bucket 8: Bonus / Extra Credit (type design or synthesis, always present)

Existing final: farm animals (algebraic type design, no illegal states).
For variety, keep the "design a faithful, non-redundant type" genre (it's
clearly the house style for the bonus) but change the domain.

### "A Faithful Type for a Chess Clock / Tournament Bracket / Recipe"
Pick a domain with: (a) a few mutually exclusive variants, (b) at least one
optional/conditional field that only exists for some variants, (c) at least
one field that must never independently vary from another (the "illegal
representation" trap), (d) a deliberately irrelevant red-herring detail (the
existing exam's "not fans of Smash Mouth" gag) to signal students shouldn't
model *everything* mentioned in the prose.

Concrete pick — **recipe steps**:
- Every step has a duration (`int`, minutes).
- Some steps are "active" (chopping, stirring) and require no equipment;
  others are "passive" (baking, resting) and require naming which single
  piece of equipment is used and at what temperature (`real`, only for
  baking).
- Some steps depend on a previous step being done first (at most one
  prerequisite, since this is a linear recipe); the very first step has
  none.
- No step is a fan of cilantro. *(the red herring)*

This keeps the exact bonus genre (algebraic type design, illegal-state
elimination) while being a fresh domain, similarly scoped to ~5 points.

---

## Suggested assembly for two exams

| Section | Real final | Practice final |
|---|---|---|
| Types/Values | 6-8 items mixed from Bucket 0 | remaining Bucket 0 items |
| Conceptual | 6-8 items mixed from Bucket 1 (+ RBT short-answer) | remaining Bucket 1 items |
| Proof | Bucket 2, Option C (Reduce Homomorphism) | Bucket 2, Option A (Zippers) |
| Imperative | Union-Find | In-place Reversal/Rotation |
| CPS/Exceptions | Backtracking Search (exceptions vs. CPS) | Early-Exit forall/exists |
| Laziness | Sieve of Eratosthenes | Merging Infinite Streams |
| Modules | Priority Queue functor | (reuse/lightly vary Priority Queue, or skip if practice final runs short — modules is the one bucket without two independent options yet, flag for follow-up) |
| Bonus | Recipe Steps type design | Farm Animals (already written, reuse as-is) |

Note the Modules bucket only has one fleshed-out option — flagged above as a
follow-up if you want two truly independent modules questions rather than
reusing one with different parameter types (e.g., swap `ORDERED`+min-heap
for a `SET` functor from an `EQ` structure using association lists, as a
quick second option).
