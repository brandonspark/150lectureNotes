# Practical Final — Question Bank Status

## SPLIT DECISIONS (first cut)
- **PROOF** (both exams need one, comparable difficulty, genuinely different theorems):
  - Real Final: **Commutative Shrubs** (vetted; reduce commutes with invert — crux is one commutativity swap).
  - Practice Final: **Checking Every Element** = `draft_treeall_inorder.tex` — `treeAll p T ~= List.all p (inorder T)`. NEW, verified. The tree-to-list bridge; crux is splitting the inorder append via a SUPPLIED lemma (`List.all` over `@`). Keeps `treeAll`. Difficulty matched to Shrubs BECAUSE the append lemma is given (that lemma was the only hard part). Different theorem + different crux from Shrubs.
  - SUPERSEDED drafts (keep on disk but DON'T use): `draft_treeall_distrib.tex` (distributivity `A p T ∧ A q T ~= A r T` — correct but long/bulky, six-term regroup); `draft_treeall_proof.tex` (treeAll commutes with invert — too close to Shrubs).
  - Also rejected: RLE round-trip (difficulty spike, list case-split); inorder(invert)~=rev(inorder) (works, backup — but also needs a rev-append lemma so no easier than the chosen one). RLE round-trip proof is embedded in the RLE folding problem.

- **CPS** (TENTATIVE — Brandon not positive yet):
  - Practice Final: **Filling in the Blanks** (`draft_fill.tex`) — collecting/accept-reject CPS (inspect-return, NOT tail-faithful; framed honestly as "different from lecture's sc/fc"). Easier: 1 clean idea (nest right-fill in left's continuation), 3 parts.
  - Real Final: **Binary Decision Trees** (native) — faithful CPS `partition`, but a hard flagship (the 12-pt `compress` stacks CPS+recursion+fullness-counting; hardest thing in the bank).
  - NOTE: Fill is clearly EASIER than BDT. This puts the harder CPS problem on the real final. (Considered the reverse — Fill on real, BDT as hard practice stress-test — Brandon chose Fill-on-practice. Revisit if BDT feels too hard for the real final.)

- **STREAMS:**
  - Practice Final: **The Fringe of the Matter** (`draft_samefringe.tex`) — build lazy `fringe` stream (real content) + maximal-laziness check + `sameFringe` (= stream equality, lockstep expose+compare) + why-streams-beat-lists. NOTE: samefringe's `walk` IS stream equality; part (c) is light given part (a), but stream equality is NOT assigned (lazy hw does transforms + a rationals digit-compare, no general streamEq/samefringe), so it's fair. Meat is in part (a) + the laziness reasoning.
  - Real Final: **Level Order Traversal** (native; zipAppend + reasoning-via-spec, slightly meatier).

- **WORK/SPAN** (both exams need one WITH a real span part):
  - Real Final: **Balanced?** = `draft_isbalanced.tex` — NEW, verified. 5 parts: (a) naive isBalanced work balanced = O(n log n) [2W(n/2)+O(n), hidden height cost]; (b) naive work on a SPINE = O(n^2) [the imbalanced wrinkle]; (c) implement single-pass isBalanced (helper returns (bool,height) — fusion trick); (d) single-pass work = O(n) shape-independent; (e) single-pass SPAN = O(log n) [S(n/2)+O(1), two independent calls run parallel — the 2→1 in the recurrence IS the parallelism]. Tree method + span + imbalanced case + real impl. Fresh (isBalanced not assigned; NOT inord/treeSum/insert which ARE the assigned tree work/span fns). NOTE: `inord` work/span via @ is ASSIGNED (workspan lab handout — inord-nodes-balanced/unbalanced/depth) — do NOT use inorder-append as a work/span vehicle.
  - Practice Final: **Flattening a Tree** = `draft_fringe_workspan.tex` — NEW, verified, 16pts/5 parts, deliberately MIRRORS Balanced?'s structure: (a) derive work of append-based `fringe` balanced = O(n log n) [2W(n/2)+O(n)]; (b) solve given `W(n-1)+O(n)` for left-leaning = O(n^2); (c) implement accumulator version `fringeAcc t acc` (no @); (d) solve given `2W(n/2)+O(1)` = O(n) shape-independent; (e) span of accumulator = **O(n), NOT O(log n)** — `fringeAcc l (fringeAcc r acc)` makes the calls DEPENDENT so no parallelism; threading the accumulator serializes it. Nice CONTRAST with Balanced? (where independent calls gave O(log n)) and a concrete instance of the span-conceptual item. Measured: balanced (64,192)≈n log n, left-lean (64,2016)≈n^2, accumulator = 64 on both.
    NOTE: this is append-analysis, i.e. lab-adjacent (`inord` work/span IS assigned in the workspan lab). Acceptable on PRACTICE as reinforcement.
  - Rejected/spare for practice: **File Systems** (native, 32pts; rose/k-ary tree so recurrences look DIFFERENT from Balanced? — `k·W(n/k)`, `O(k·log_k n)` span, parallel-map convention; + `absolutize` impl part) — RECOMMENDED, more differentiated. **Meeting the Bound** (26pts; `maxPath` — but it's a near-TWIN of Balanced?: binary tree, implement-then-derive `2W(n/2)`, span via independent-calls. Holding as spare.) Splitting Trees is work-only, NO span — doesn't qualify alone.
  - **Span conceptual item** = `draft_span_conceptual.tex` (4pts, NEW, verified): "does W with two recursive calls imply span with one?" NO — only if the calls are INDEPENDENT. Counterexample: `sumTree` (independent, S=O(log n)) vs `sumAcc` (accumulator threaded, so `sumAcc r` needs `sumAcc l`'s result → sequential, S=O(n)); same work-recurrence shape, both compute 28. This is the direct ANTIDOTE to Balanced? part (e) ("the 2 becomes a 1") — so put them on OPPOSITE exams, else the conceptual item telegraphs part (e). Suggests: Balanced? → real, this item → practice.

- **FOLDING:**
  - Practice Final: **Run-Length Encoding** (`draft_rle.tex`) — PROOF PART CUT (was 27pts/4 parts, now **15pts/3 parts**): (a) `encode` as a single `foldr` (8), (b) `decode` (4), (c) why `foldr` not `foldl` (3). The `decode(encode L)~=L` round-trip proof was removed because both exams already have a dedicated proof and RLE's was the hardest (3-way case split). Backup of the with-proof version: `/tmp/draft_rle_with_proof.tex.bak`.
  - Real Final: **Balancing Act** (native, 4 parts) — `foldl` + `int option` accumulator, PLUS the parallel `Seq.reduce` half. NOTE: this means the REAL final carries the SEQUENCES content (reduce/associativity/span).
  - Spare: **Two Accumulators / fold2** (16pts) — purest fold problem (the "is fold2 stronger than foldl? no" insight). Unplaced.

- **IMPERATIVE:**
  - Practice Final: **Arrays** (native, 27pts) — `'a ref Seq.t` in-place ops + bubblesort. Vetted.
  - Real Final: **Memoize Anything** (`draft_memoize.tex`, 23pts) — HOF+mutation: implement `memoize`, motivated fold use, `memoize f ~= f` only if `f` pure, and the inline-memoize-fib trap. The more interesting of the two.

## CONSOLIDATED: practice_final.tex is now the full staging bank — 18 questions, 74 parts.
All drafts `\input`-ed in. Native: Types&Values, Conceptual, Shrubs, Arrays, BDT,
Level Order, File Systems, Balancing Act, Meeting the Bound, + 2 pools (wrapped as
questions for now). Inputted: Splitting Trees, Fringe, Filling in the Blanks,
Two Accumulators, Memoize Anything, RLE, Inversion Preserves the Verdict.
Still untested lecture: EXCEPTIONS. Stale duplicate drafts (balanced_parens,
meet_the_bound) exist on disk but are NOT input (those are native questions).


Last updated: 2026-07-24

## Placed in `practice_final.tex`
(compiles; exam currently 10 questions)
- **Balancing Act** — 4 parts, same problem (paren balancing) SEQUENTIAL then PARALLEL: (a) implement `balanced` via single `foldl` with `int option` accumulator; (b) give `single`/`combine`, the associative `(unmatchedCloses, danglingOpens)` summary; (c) implement `balancedPar` via `Seq.map single` + `Seq.reduce combine (0,0)`; (d) O(log n) span + why-associativity-is-required. Absorbs the SEQUENCES gap (reduce/associativity/span — untested elsewhere; Arrays uses Seq for mutation, not parallelism). foldl running-counter O(n) span vs. reduce associative-summary O(log n) span. All verified incl. combine associativity. Parens-via-reduce NOT assigned.
  (TRIMMED from an overgrown 7-part version: cut two "give an input that breaks this" counterexample parts — NOT 150 questions, they're code-reasoning puzzles with no SML/type/proof content — and cut the bracket-kinds→stack tangent.)
- **Meeting the Bound** — write code to meet a stated work/span bound; `maxPath` on trees + rose trees. Inserted.
- **Splitting Trees** — `split` a BST by a pivot in O(height); naive-cost / write-fast / fast-cost. Inserted via `\input{draft_split.tex}` (line 1816); confirmed rendering in the PDF. **But see "pending edits"** — currently has TWO cost parts and leans algorithms-y. Part (c) intended to be swapped for the equivalence proof below.

(NOTE: `\input`-ed questions — Splitting Trees, and samefringe in final.tex — do NOT show up when you grep the main file for `\titledquestion`. They're there; the grep just can't see inside the input.)

## Placed in `final.tex`
- **The Fringe of the Matter** (samefringe) — fringe as a stream, `sameFringe` short-circuits. Inserted via `\input{draft_samefringe.tex}`.

## Drafted & verified in SML/NJ, NOT yet placed
- **draft_fill.tex** — "Filling in the Blanks." CPS tree-fill (collecting / accept-reject continuation). Fill a `skel` skeleton's blank operators to hit a target. Non-tail-faithful (inspect-return) by design; framed honestly as collecting CPS.
- **draft_rle.tex** — Run-length encoding. `encode` (single `foldr`) + `decode` + foldr-vs-foldl reasoning + proof `decode (encode L) ~= L` (structural induction, verified clean).
- **draft_fold2.tex** — `fold2` combinator (two accumulators), `bestPrefix` showcase, "is fold2 stronger than foldl?" (no — equivalent).
- **draft_treeall_proof.tex** — proof `treeAll p (invert T) ~= treeAll p T` by structural induction (uses commuting-conjunction lemma).
- **draft_types_pool.tex** — 5 "most general type + value" items: if-unification, poly-looking NWT (`fn f => (f 1, f true)`), composition (`o`'s type), nested-tuple reorder, `map o map`.
- **draft_conceptual_pool.tex** — 4 items targeting misconceptions: body-not-run-until-applied, static scope, equivalence-≠-cost, mutation-breaks-referential-transparency.
- **draft_memoize.tex** — "Memoize Anything." `memoize : (int -> 'a) -> (int -> 'a)` HOF combinator: closure with private `ref` cache. Combines MUTATION + HIGHER-ORDER FUNCTIONS (a pairing the imperative hw doesn't make). 4 parts, all built around ONE theme — *a cache only helps if allocated once and shared*:
  (a) implement `memoize` (closure + ref cache — the mechanism).
  (b) USE it (MOTIVATED): store `items : (string*int) list` tagged by category; expensive `price : int -> int`; many items share categories. Implement `total` via `memoize` + `List.foldl`, computing `price` once per distinct category. Graded subtlety = WHERE the memoize goes: `let val fastPrice = memoize price in foldl (...fastPrice cat...)` (correct, one shared cache across the fold) vs. `(memoize price) cat` inside the fold body (wrong, fresh cache per item). Motivated fold-over-list use case shows memoize's real value. Verified: 7 items / 3 categories → correct=3 price calls, buggy=7.
  (c) is `memoize f ~= f`? (only if `f` pure — impure `noisy` counterexample).
  (d) "what's wrong": `fib` with `(memoize fib)` inlined at each recursive call — correct but still exponential (fresh empty cache per call, never shared). Diagnose-only; NOT asked to write the fix (open recursion too hard for exam).
  (b) and (d) are the SAME misconception at two scales (memoize-once-not-per-iteration), which makes the problem cohere. Part (b) WORKS (external repeats); the recursion-doesn't-work issue is quarantined in (d). The honest replacement for burned memofib: GENERAL combinator, not assigned fib-specific `memo : unit -> int -> int`. All verified (broken inline = 242785 calls for fib 25).

  (Held in reserve, NOT in the draft: `memoFix` combinator — memoize + fixpoint via open recursion + ref knot — makes any open-recursive fn self-memoizing, fib 30 in 31 calls. Too hard to ask students to write; kept as background for the part (d) answer.)

## Burned (found ASSIGNED — do NOT use)
- **merge two BSTs** (both structural `split`+`mergeBSTs` AND list-roundtrip) — `polysort` treeSort lab + `continuations/staging` treeSort. draft deleted.
  - NOTE: the polysort *lab* was NOT run m26, but staging's `treeSort` (list→balanced BST, inorder-sorted) likely was, so the list-roundtrip merge is burned. Structural `split`-by-pivot itself is clean for this cohort (only in un-run polysort) — that's why "Splitting Trees" is OK.
- **memofib** — `imperative/array` homework has a task literally named `memofib` ("Did You Get The Memo?"). `draft_memofib.tex` deleted 2026-07-24.

## Pending edits
- **Splitting Trees part (c):** swap the second work-recurrence for the extensional-equivalence proof (below), to rebalance toward FP. Brandon flagged the current version tests algorithms more than FP.

### On hand: the Splitting Trees equivalence proof (verified true in SML/NJ)
**Theorem.** For BST `T`, if `split (p, T) ~= (T1, T2)` then
`inorder T1 ~= List.filter (fn y => y < p) (inorder T)`.

Extensional-equivalence genre (house style). Structural induction on `T`.
Lemmas to supply:
1. `filter` distributes over `@` and cons.
2. BST invariant: at `Node(l,x,r)`, every value in `l` is `< x`.

Key case (`x < p`): `T1 = Node(l, x, rl)` where `(rl,rr)=split(p,r)`.
- LHS `inorder(Node(l,x,rl)) = inorder l @ (x :: inorder rl)`.
- RHS `filter(<p)(inorder l @ x :: inorder r)`
  = `filter(<p)(inorder l) @ x :: filter(<p)(inorder r)`  (lemma 1, `x<p`)
  = `inorder l @ (x :: inorder rl)`  (lemma 2 kills the first filter; IH on `r` gives `filter(<p)(inorder r) = inorder rl`).
- LHS = RHS. Base + `x>p` + `x=p` cases are easy/symmetric.

## Collision sweep — INCOMPLETE
Two drafts already turned out assigned under aliased names (merge-BST, memofib), so remaining drafts must be checked against the **m26-run units** before finalizing. git log is the reliable signal for what actually ran m26.
- [ ] **fill** — check against CPS/continuations units (partition/backtracking families).
- [ ] **RLE** — check `encode`/`decode`/run-length across units (clear on first pass, re-verify).
- [ ] **fold2** — check against `use-fold` / hofs (express-as-fold family).
- [ ] **samefringe** — check against lazy/streams units.
- [x] merge-BST — ASSIGNED (burned).
- [x] memofib — ASSIGNED (burned).

## Notes on taste (from this session)
- Wants problems with a real idea at the center (like BDT/memofib), not utilities-in-disguise or "programming problem in the presence of [technique]."
- CPS: the well is genuinely shallow at this level — `fill` is the one keeper; load-bearing CPS is backtracking/search, most of which is assigned. Accept one CPS problem.
- Proofs must be **extensional equivalence** (`e1 ~= e2`), the house genre — not "predicate holds on output."
- Possibly cutting BDTs from the real final (too hard).
