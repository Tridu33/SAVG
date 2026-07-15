# 35bottle4Lwater

How to obtain exactly 4 litres of water with a 3-litre jug (B) and a 5-litre jug (A)? This is the classic water-jug puzzle, formalised here as a PDDL domain whose state is a pair `(A, B)` with `A in {0..5}` and `B in {0..3}`, i.e. a finite state machine of `(5+1)*(3+1) = 24` states (16 of which are reachable from `(0,0)`).

## State encoding (boolean predicate feature vector)

Each state `(A, B)` is mapped to a 10‑dim boolean vector — exactly one 5L‑level predicate and one 3L‑level predicate is true:

| A | 5L predicate | B | 3L predicate |
|---|--------------|---|--------------|
| 0 | zero5L       | 0 | zero3L       |
| 1 | one5L        | 1 | one3L        |
| 2 | two5L        | 2 | two3L        |
| 3 | three5L      | 3 | three3L      |
| 4 | four5L       |   |              |
| 5 | five5L       |   |              |

Feature vector ordering:
```
<zero5L, one5L, two5L, three5L, four5L, five5L, zero3L, one3L, two3L, three3L>
```

Examples:
- `(1,0)` -> `<not zero5L, one5L, not two5L, not three5L, not four5L, not five5L, zero3L, not one3L, not two3L, not three3L>`
- `(0,1)` -> `<zero5L, not one5L, not two5L, not three5L, not four5L, not five5L, not zero3L, one3L, not two3L, not three3L>`

## Actions (6 per state, most are no‑ops when already at boundary)

| action     | precondition                    | effect (A', B')                         |
|------------|---------------------------------|-----------------------------------------|
| fill5L     | not five5L                      | A'=5, B'=B                              |
| fill3L     | not three3L                     | A'=A, B'=3                              |
| empty5L    | not zero5L                      | A'=0, B'=B                              |
| empty3L    | not zero3L                      | A'=A, B'=0                              |
| pour5Lto3L | not zero5L, not three3L        | A'=max(0,A+B-3), B'=min(3,A+B)          |
| pour3Lto5L | not zero3L, not five5L         | A'=min(5,A+B), B'=max(0,A+B-5)          |

`fill5L/fill3L/empty5L/empty3L` use plain STRIPS add/delete effects (removing a non‑present predicate is harmless, so all level predicates of the other value can be unconditionally deleted). The two `pour` actions need `:conditional-effects` because the resulting level depends on the sum `A+B`; every reachable `(A,B)` branch is enumerated explicitly.

## Initial / goal

- **Initial state:** `(0,0)` -> `<zero5L, zero3L>` (+ vStart)
- **Goal:** 4 litres in the 5L jug, i.e. `four5L`, which admits two concrete absorbing states `(4,0)` and `(4,3)`. `vGoal` is a derived predicate equal to `four5L`.

## Files

- `low_35bottle4Lwater_d.pddl` — domain (predicates + 6 actions)
- `low_35bottle4Lwater_p1.pddl` — problem instance (init `(0,0)`, goal 4L)

## Two equivalent strong‑cyclic solutions (semicircles)

**Upper semicircle** (start by filling the 5L jug):
```
(0,0) -fill5L-> (5,0) -pour5Lto3L-> (2,3) -empty3L-> (2,0) -pour5Lto3L-> (0,2) -fill5L-> (5,2) -pour5Lto3L-> (4,3) [goal]
```

**Lower semicircle** (start by filling the 3L jug):
```
(0,0) -fill3L-> (0,3) -pour3Lto5L-> (3,0) -fill3L-> (3,3) -pour3Lto5L-> (5,1) -empty5L-> (0,1) -pour3Lto5L-> (1,0) -fill3L-> (1,3) -pour3Lto5L-> (4,0) [goal]
```

At the two branching states `(0,0)` and `(5,3)` the upper / lower policies pick different successors, giving two distinct but equivalent FOND policies (see `policy/fond_35bottle4Lwater_human_policy1.out` and `..._policy2.out`).


