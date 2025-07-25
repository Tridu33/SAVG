(define (problem reversell_p) (:domain reversell)
(:objects 
    n1 n2 - NodeType
)

(:init
    (curpoint2 n1)
    (llnext vH1 n1)    (llnext n1 n2)    (llnext n2 vT1)
    (llnext vH2 vT2) 
)

(:goal (and
    (llnext vH1 vT1)
    (llnext vH2 n2)    (llnext n2 n1)    (llnext n1 vT2)
    )
)

)