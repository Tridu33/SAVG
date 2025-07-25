
(define (domain llvisitall_d)
    (:requirements :typing :non-deterministic)
    (:types	)
    (:predicates
    (vStart)
    (vGoal)
    (allvisited)
    (h_curvisted)
    )
    
    (:action 8_virtual_source_act_1_7
    :parameters ()
        :precondition (and  (vStart)  )
        :effect (oneof 
        (and (not(vStart)) (not(vGoal)) (not(allvisited)) (h_curvisted) )
        (and (not(vStart)) (vGoal) (allvisited) (h_curvisted) )
        )
    )
    (:action 1_updatecur2llnext_0_1
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allvisited)) (h_curvisted) )
        :effect (oneof 
        (and (not(vStart)) (not(vGoal)) (not(allvisited)) (not(h_curvisted)) )
        (and (not(vStart)) (not(vGoal)) (not(allvisited)) (h_curvisted) )
        )
    )
    (:action 0_updatecur2llnext_1_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allvisited)) (not(h_curvisted)) )
        :effect (oneof 
        (and (not(vStart)) (not(vGoal)) (not(allvisited)) (h_curvisted) )
        (and (not(vStart)) (not(vGoal)) (not(allvisited)) (not(h_curvisted)) )
        )
    )
    (:action 0_visitcur_7_1
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allvisited)) (not(h_curvisted)) )
        :effect (oneof 
        (and (not(vStart)) (vGoal) (allvisited) (h_curvisted) )
        (and (not(vStart)) (not(vGoal)) (not(allvisited)) (h_curvisted) )
        )
    )
)