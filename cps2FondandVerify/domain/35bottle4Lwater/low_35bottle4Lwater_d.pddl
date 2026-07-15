; Domain: 35bottle4Lwater
; Classic water-jug puzzle: obtain exactly 4 litres in the 5L jug (A),
; using a 3L jug (B). States are (amount_in_5L_jug, amount_in_3L_jug).
;
; The state is encoded by 10 mutually-exclusive boolean predicates:
; 5L jug level : zero5L one5L two5L three5L four5L five5L (A in 0..5)
; 3L jug level : zero3L one3L two3L three3L (B in 0..3)
; Exactly one 5L-level predicate and one 3L-level predicate is true
; in every reachable state, so the two together uniquely identify (A,B).
; The feature vector used by the policy is:
; <zero5L, one5L, two5L, three5L, four5L, five5L,
;  zero3L, one3L, two3L, three3L>
;
; Six actions (deterministic here; FOND non-determinism can be added by
; splitting pour effects into multiple outcomes):
;   fill5L     : A -> 5
;   fill3L     : B -> 3
;   empty5L    : A -> 0
;   empty3L    : B -> 0
;   pour5Lto3L : A' = max(0, A+B-3), B' = min(3, A+B)
;   pour3Lto5L : A' = min(5, A+B), B' = max(0, A+B-5)

(define (domain bottle4L)
    (:requirements :strips :typing :equality :conditional-effects :derived-predicates)
    (:types JugLevel)
    (:predicates
        ; 5L jug amount
        (zero5L)
        (one5L)
        (two5L)
        (three5L)
        (four5L)
        (five5L)
        ; 3L jug amount
        (zero3L)
        (one3L)
        (two3L)
        (three3L)
        ;;;;;;;;;;;;;;;
        (vStart)
        (vGoal)
    )
    ; Goal: "4 litres in the 5L jug" regardless of the 3L jug level.
    (:derived (vGoal)
        (four5L)
    )
    (:action fill5L
        :precondition (not (five5L))
        :effect (and (five5L) (not (zero5L)) (not (one5L)) (not (two5L)) (not (three5L)) (not (four5L)))
    )
    (:action fill3L
        :precondition (not (three3L))
        :effect (and (three3L) (not (zero3L)) (not (one3L)) (not (two3L)))
    )
    (:action empty5L
        :precondition (not (zero5L))
        :effect (and (zero5L) (not (one5L)) (not (two5L)) (not (three5L)) (not (four5L)) (not (five5L)))
    )
    (:action empty3L
        :precondition (not (zero3L))
        :effect (and (zero3L) (not (one3L)) (not (two3L)) (not (three3L)))
    )
    ; pour 5L jug into 3L jug until 3L jug is full or 5L jug is empty
    (:action pour5Lto3L
        :precondition (and (not (zero5L)) (not (three3L)))
        :effect (and
            ; ---- A = 1 ----
            (when (and (one5L) (zero3L))
                (and (not (one5L)) (zero5L) (not (zero3L)) (one3L)))
            (when (and (one5L) (one3L))
                (and (not (one5L)) (zero5L) (not (one3L)) (two3L)))
            (when (and (one5L) (two3L))
                (and (not (one5L)) (zero5L) (not (two3L)) (three3L)))
            ; ---- A = 2 ----
            (when (and (two5L) (zero3L))
                (and (not (two5L)) (zero5L) (not (zero3L)) (two3L)))
            (when (and (two5L) (one3L))
                (and (not (two5L)) (zero5L) (not (one3L)) (three3L)))
            (when (and (two5L) (two3L))
                (and (not (two5L)) (one5L) (not (two3L)) (three3L)))
            ; ---- A = 3 ----
            (when (and (three5L) (zero3L))
                (and (not (three5L)) (zero5L) (not (zero3L)) (three3L)))
            (when (and (three5L) (one3L))
                (and (not (three5L)) (one5L) (not (one3L)) (three3L)))
            (when (and (three5L) (two3L))
                (and (not (three5L)) (two5L) (not (two3L)) (three3L)))
            ; ---- A = 4 ----
            (when (and (four5L) (zero3L))
                (and (not (four5L)) (one5L) (not (zero3L)) (three3L)))
            (when (and (four5L) (one3L))
                (and (not (four5L)) (two5L) (not (one3L)) (three3L)))
            (when (and (four5L) (two3L))
                (and (not (four5L)) (three5L) (not (two3L)) (three3L)))
            ; ---- A = 5 ----
            (when (and (five5L) (zero3L))
                (and (not (five5L)) (two5L) (not (zero3L)) (three3L)))
            (when (and (five5L) (one3L))
                (and (not (five5L)) (three5L) (not (one3L)) (three3L)))
            (when (and (five5L) (two3L))
                (and (not (five5L)) (four5L) (not (two3L)) (three3L)))
        )
    )
    ; pour 3L jug into 5L jug until 5L jug is full or 3L jug is empty
    (:action pour3Lto5L
        :precondition (and (not (zero3L)) (not (five5L)))
        :effect (and
            ; ---- B = 1 ----
            (when (and (zero5L) (one3L))
                (and (not (zero5L)) (one5L) (not (one3L)) (zero3L)))
            (when (and (one5L) (one3L))
                (and (not (one5L)) (two5L) (not (one3L)) (zero3L)))
            (when (and (two5L) (one3L))
                (and (not (two5L)) (three5L) (not (one3L)) (zero3L)))
            (when (and (three5L) (one3L))
                (and (not (three5L)) (four5L) (not (one3L)) (zero3L)))
            (when (and (four5L) (one3L))
                (and (not (four5L)) (five5L) (not (one3L)) (zero3L)))
            ; ---- B = 2 ----
            (when (and (zero5L) (two3L))
                (and (not (zero5L)) (two5L) (not (two3L)) (zero3L)))
            (when (and (one5L) (two3L))
                (and (not (one5L)) (three5L) (not (two3L)) (zero3L)))
            (when (and (two5L) (two3L))
                (and (not (two5L)) (four5L) (not (two3L)) (zero3L)))
            (when (and (three5L) (two3L))
                (and (not (three5L)) (five5L) (not (two3L)) (zero3L)))
            (when (and (four5L) (two3L))
                (and (not (four5L)) (five5L) (not (two3L)) (one3L)))
            ; ---- B = 3 ----
            (when (and (zero5L) (three3L))
                (and (not (zero5L)) (three5L) (not (three3L)) (zero3L)))
            (when (and (one5L) (three3L))
                (and (not (one5L)) (four5L) (not (three3L)) (zero3L)))
            (when (and (two5L) (three3L))
                (and (not (two5L)) (five5L) (not (three3L)) (zero3L)))
            (when (and (three5L) (three3L))
                (and (not (three5L)) (five5L) (not (three3L)) (one3L)))
            (when (and (four5L) (three3L))
                (and (not (four5L)) (five5L) (not (three3L)) (two3L)))
        )
    )
    (:formula_for_initial_states (and (zero5L) (zero3L) (vStart)))
    (:formula_for_goals (four5L))
)
