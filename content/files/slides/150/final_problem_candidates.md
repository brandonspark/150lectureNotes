# 15-150 Final — Specification-Driven Problem Candidates

Generator, extracted from what already works on your exams (BDT compression,
Fusing Transformations):

1. **State a property, invariant, or algebraic fact** — precisely, in one or
   two sentences. ("A compressed BDT never contains `Choice(Final b, Final b)`."
   "Any sequence of affine maps is itself a single affine map.")
2. **Pin the behavior down with worked examples**, not with an algorithm.
3. **Hand them the primitives** they're allowed to use, so the insight is the
   bottleneck, not recall of library functions.
4. **Let the ladder of parts do the scaffolding**: an early cheap part that
   forces them to notice the key fact, then the part that uses it.
5. **Use constraints to force the intended shape** (point-free, no `fun`,
   must be CPS, must be in-place, single traversal).

The student must discover *how to exploit* the stated fact. They are never
told the algorithm.

Each candidate below is annotated with **the insight** — the thing actually
being graded. If a problem has no crisp insight line, it's a transcription
problem and should be cut.

---

## A. Permutation Check, In Place

**Slot:** imperative / mutation. **Setup cost:** ~3 sentences. No algorithm
given.

Using the established `type 'a array = 'a ref Seq.t`, ask for:

```
isPerm : int array -> bool
REQUIRES: true
ENSURES: isPerm A ~= true iff A's elements are exactly 0..n-1, each once,
         where n = length A. May leave A in any state.
```

**Constraint:** O(1) extra space. You may not allocate another array,
sequence, or list. You *may* destroy `A`.

**The insight:** the array itself is the scratchpad. Since you're permitted
to destroy `A`, you can mark "I have seen value `i`" by mutating slot `i`
(e.g. negating it, or writing a sentinel), and a duplicate is detected when
you arrive at an already-marked slot. Students who don't see it will reach
for a `bool array` or a sorted copy and hit the space constraint.

**Ladder:**
1. (2 pts) Why does the obvious approach — sort a copy and compare to
   `0..n-1` — fail the constraint? One sentence.
2. (3 pts) Write `inRange : int array -> bool`, checking every element is in
   `[0, n)`. Cheap, gets them fluent with the array ops, and it's a genuine
   precondition for the marking scheme to be safe.
3. (10 pts) `isPerm`. The marking insight lands here.
4. (2 pts) Your function is allowed to destroy `A`. Give a caller for whom
   that is a problem, and say what it costs to fix.

**Why it's final-tier:** the space constraint is what generates the
problem-solving. Remove it and it's a one-line `List.exists` exercise.

**Grading caution (verified in SML/NJ):** the negate-to-mark encoding has a
wrinkle — once slot `i` is marked, *reading* it later gives you the marked
value, not the original, so a correct solution must unmark on read
(`if v < 0 then ~v - 1 else v`). Students will trip on this and produce
solutions that are right in spirit but wrong on inputs where a later index
reads an already-marked slot (e.g. `[3,1,0,2]`). Decide in advance whether
that costs full credit. If you'd rather avoid the wrinkle entirely, permit
a sentinel-based marking scheme instead by loosening the spec to "elements
are in `0..n-1`" as a REQUIRES, which lets them mark with any out-of-range
value and sidesteps the read-back problem.

---

## B. Longest Common Prefix of a Bitstring Set — Reusing Your Own BDT

**Slot:** could *replace* part of the BDT question, or stand alone if you
retire BDTs. **Setup cost:** near zero if BDTs are already on the exam.

Given the compressed BDT type already defined:

```
lcp : bdt -> bit list
REQUIRES: bdt is a compressed BDT representing a non-empty set
ENSURES: lcp b ~= the longest bit sequence that every bitstring in the set
         represented by b begins with.
```

**The insight:** in a *compressed* BDT, a `Choice` node whose two children
are not both-dead is exactly a branch point — so the common prefix is the
path you walk while one side is `Final false` (a dead subtree). The student
must realize that "everything in this set agrees on the next bit" is
*visible structurally* as one child being a dead end, and that compression
is what makes this true. This directly tests whether they understood the
invariant from the earlier part rather than just coding to examples.

**Worked examples to give:**
- set `{100, 101}` → `lcp` is `[One, Zero]`
- set `{0, 1}` (i.e. `Final true`) → `[]`
- singleton `{110}` → `[One, One, Zero]`

**Ladder:** (a) 3 pts: what does `Final false` mean as a subtree? (b) 8 pts:
`lcp`. (c) 2 pts: what goes wrong if the BDT is *not* compressed?

---

## C. Balanced Parentheses via Fold — The Accumulator Discovery

**Slot:** higher-order functions / folding. **Setup cost:** 2 sentences.

```
datatype paren = L | R    (* '(' and ')' *)

balanced : paren list -> bool
ENSURES: balanced ps ~= true iff ps is a well-matched sequence.
```

**Constraint:** exactly one traversal, written as a single `foldl`. No
explicit recursion, no `rev`, no auxiliary list.

**The insight:** a `bool` accumulator is not enough and a naive `int` depth
counter is not enough either — you need *depth plus a validity flag*, or the
cleverer encoding `int option` where `NONE` is "already broken." Discovering
that the fold's accumulator type must be richer than the return type, and
then that you need a post-processing step (`depth = 0`), is the whole
problem. This is the single most transferable idea in the folding unit and
it's not tested anywhere on the current exam.

**Ladder:**
1. (3 pts) Show `[R, L]` and `[L, R]` both have "equal counts," so counting
   is insufficient. What property distinguishes them? *(forces the insight
   before they write code)*
2. (8 pts) `balanced`, under the constraint.
3. (3 pts) Generalize to `datatype bracket = Round of side | Square of side`
   — what must the accumulator become? Just describe the type and why.

Part 3 is a good discriminator: the answer is a stack (`bracket list`), and
recognizing "my accumulator was secretly a stack all along, and depth was
just its length" is a genuinely satisfying capstone.

---

## D. Streams: Detecting Eventual Periodicity

**Slot:** laziness. **Setup cost:** 3 sentences. Replaces the tired sieve.

A stream is *eventually periodic with period p* if after some finite prefix,
it repeats forever with period `p`.

```
isPeriodic : int stream -> int -> int -> bool
REQUIRES: S is productive; k >= 0; p > 0
ENSURES: isPeriodic S k p ~= true iff the first k elements after position k
         agree with the p-shifted stream ... (state precisely on the exam)
```

**The insight:** you cannot inspect an infinite stream, so the *only* way to
answer is to compare finitely — the student must realize the check reduces
to zipping the stream against a shifted copy of itself and testing a bounded
number of elements. Building "the same stream, shifted by p" and comparing
elementwise is the move. It's laziness reasoning, not algorithm recall.

**Ladder:** (a) 3 pts: implement `drop : 'a stream -> int -> 'a stream`.
(b) 3 pts: implement `zipWith`, maximally lazy — reuses your existing
"is this maximally lazy" skill-check on new code. (c) 8 pts: `isPeriodic` in
terms of them. (d) 2 pts: why can no function of type `int stream -> bool`
decide periodicity for *arbitrary* p? (Answer: it would need to inspect
unboundedly much — a nice, honest brush with undecidability that costs two
lines to answer.)

---

## E. The Functor That Forces an Invariant

**Slot:** modules — the biggest coverage gap (lectures 14–16, no question).
**Setup cost:** moderate, but it's signature-reading, which is the skill.

Give `ORDERED` (`type t`, `val cmp : t * t -> order`) and:

```
signature SORTED_LIST = sig
  type elt
  type t
  val empty  : t
  val insert : elt -> t -> t
  val toList : t -> elt list      (* always ascending *)
end
```

Ask for `functor MakeSorted (O : ORDERED) :> SORTED_LIST where type elt = O.t`.

**The insight (part c is the real question):** the representation invariant
"the list is always sorted" is only *enforceable* because the ascription is
opaque — the client cannot fabricate a `t` from an unsorted list. Students
must explain what breaks under transparent ascription, and why `where type
elt = O.t` is nonetheless required for the client to be able to *call*
`insert` at all. That tension — hide the representation, expose the element
type — is precisely the lecture 14/15 payoff and is a real problem-solving
question, not recall.

**Ladder:** (a) 4 pts: write the functor. (b) 3 pts: why can the client not
break the sortedness invariant? (c) 4 pts: drop `where type elt = O.t` —
give a concrete client expression that stops compiling, and say why.
(d) 3 pts: `MakeSorted(IntAsc)` and `MakeSorted(IntDesc)` both hold `int`s;
are their `t` types interchangeable? Justify.

---

## F. Work/Span Where the Recurrence Must Be Discovered

**Slot:** asymptotic analysis. Most work/span questions hand over the code
and ask for the recurrence — mechanical. Invert it.

Give a *specification* and a cost target, and ask them to produce an
implementation that meets it:

```
maxPath : int tree -> int
ENSURES: maxPath T ~= the maximum sum along any root-to-leaf path in T.
```

**Constraint:** `W(n) = O(n)` and `S(n) = O(d)` where `d` is the depth. Then:
"State your recurrences and justify that your implementation meets the
bound."

**The insight:** the naive version that recomputes subtree sums is
`O(n log n)` or worse; the linear one returns the answer bottom-up in a
single pass. And the span bound is only achievable if the two recursive
calls are genuinely independent — so they must notice their code is already
parallel, and say why. Asking for *code that meets a bound* rather than
*the bound of this code* is the difference between problem-solving and
transcription.

**Optional harder second part:** same, but `maxPath` over a rose tree
(`Node of int * rose list`), where the student must decide between
`List.map`-then-`foldl` and a single fold, and analyze span under the
"pretend `List.map` is parallel" convention you already use on the exam.

---

## Ranking, for what it's worth

If you want the exam's problem-solving load concentrated where it discriminates
best:

| Candidate | Insight quality | Setup cost | Verdict |
|---|---|---|---|
| C. Balanced parens | **Highest** — accumulator-richer-than-result is *the* fold idea | Lowest | Take it |
| A. Permutation in place | High — constraint generates the problem | Low | Take it |
| E. Modules functor | High — and fills the one real coverage gap | Medium | Take it |
| F. Meet-the-bound | High — inverts a stale question type | Low | Strong filler |
| D. Stream periodicity | Medium-high | Low | Good practice-final pick |
| B. LCP on BDTs | High, but only if BDTs stay on the exam | ~Zero | Bonus part on existing Q |

C, A, and E are the three I'd build around. F is the cheapest way to make the
asymptotics section non-mechanical. B is nearly free if the BDT question
survives, since it reuses setup the student has already read.
