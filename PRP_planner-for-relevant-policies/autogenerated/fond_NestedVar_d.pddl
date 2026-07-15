
(define (domain NestedVar_d)
    (:requirements :typing :non-deterministic)
    (:types	)
    (:predicates
    (vStart)
    (vGoal)
    (x1empty)
    (h_hasX1)
    )
    
    (:action 8_virtual_source_act_1
    :parameters ()
        :precondition (and  (vStart)  )
        :effect (and (not(vStart)) (not(vGoal)) (not(x1empty)) (h_hasX1) )
    )
    (:action 1_decX1_1_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(x1empty)) (h_hasX1) )
        :effect (oneof 
        (and (not(vStart)) (not(vGoal)) (not(x1empty)) (h_hasX1) )
        (and (not(vStart)) (not(vGoal)) (not(x1empty)) (not(h_hasX1)) )
        )
    )
    (:action 1_decX2_1
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(x1empty)) (h_hasX1) )
        :effect (and (not(vStart)) (not(vGoal)) (not(x1empty)) (h_hasX1) )
    )
    (:action 0_decX2_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(x1empty)) (not(h_hasX1)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(x1empty)) (not(h_hasX1)) )
    )
    (:action patched_goal_act
    :parameters ()
        :precondition (and (not (vStart)) )
        :effect (and (vGoal) (not (vStart)) )
    )
)
