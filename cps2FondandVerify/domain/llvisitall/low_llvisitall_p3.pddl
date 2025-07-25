(define (problem llvisitall_p3) (:domain llvisitall)
(:objects 
    n1 n2 - NodeType
)

(:init
    ;todo: put the initial state's facts and numeric values here
    (visited vH)
    (visited vT)
    (curpoint2 vH)
    (llnext vH n1)
    (llnext n1 n2)
    (llnext n2 vT)
    (not (visited n1))
    (not (visited n2))
)

(:goal (and
    (visited vH)
    (visited vT)
    (visited n1)
    (visited n2)
    )
)

)