(define (problem llvisitall_p1) (:domain llvisitall)
(:objects 
    ; there is no node exists
)

(:init
    ;todo: put the initial state's facts and numeric values here
    (visited vH)
    (visited vT)
    (curpoint2 vH)
    (llnext vH vT)
)

(:goal (and
    (visited vH)
    (visited vT)
    ; the initial state is the goal "\forall n.visited(n)" when n is not exist.
    )
)

)