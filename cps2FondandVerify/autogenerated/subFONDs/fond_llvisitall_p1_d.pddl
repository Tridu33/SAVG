
(define (domain llvisitall_p1_d)
    (:requirements :typing :non-deterministic)
    (:types	)
    (:predicates
    (vStart)
    (vGoal)
    (allvisited)
    (h_curvisted)
    )
    
    (:action 8_virtual_source_act_7
    :parameters ()
        :precondition (and  (vStart)  )
        :effect (and (not(vStart)) (vGoal) (allvisited) (h_curvisted) )
    )
)