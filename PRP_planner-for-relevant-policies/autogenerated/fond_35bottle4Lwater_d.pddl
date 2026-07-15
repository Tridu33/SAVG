
(define (domain 35bottle4Lwater_d)
    (:requirements :typing :non-deterministic)
    (:types	)
    (:predicates
    (vStart)
    (vGoal)
    (vGoal)
    )
    
    (:action 4_virtual_source_act_0
    :parameters ()
        :precondition (and  (vStart)  )
        :effect (and (not(vStart)) (not(vGoal)) )
    )
    (:action patched_goal_act
    :parameters ()
        :precondition (and (not (vStart)) )
        :effect (and (vGoal) (not (vStart)) )
    )
)
