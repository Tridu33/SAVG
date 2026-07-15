; Problem instance: start (0,0), goal = 4 litres in the 5L jug.
; Initial state : (A=0, B=0) -> <zero5L, zero3L>
; Goal state set : (4,0) or (4,3) -> <four5L, zero3L> / <four5L, three3L>

(define (problem bottle4L_problem_p1)
    (:domain bottle4L)
    (:init
        (zero5L)
        (zero3L)
        (vStart)
    )
    (:goal (or
        (and (four5L) (zero3L))
        (and (four5L) (three3L))
    ))
)
