(define (problem llvisitall_p2) (:domain llvisitall)
(:objects 
    n1 - NodeType
)

(:init
    ;todo: put the initial state's facts and numeric values here
    (visited vH)
    (visited vT)
    (curpoint2 vH)
    (llnext vH n1)
    (llnext n1 vT)
    (not (visited n1))
)

(:goal (and
    (visited vH)
    (visited vT)
    (visited n1)
    )
)
)