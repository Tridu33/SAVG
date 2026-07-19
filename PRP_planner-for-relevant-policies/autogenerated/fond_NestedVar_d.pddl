
(define (domain NestedVar_d)
    (:requirements :typing :non-deterministic)
    (:types	)
    (:predicates
    (vStart)
    (vGoal)
    (h_x1empty)
    (h_hasX2)
    (vGoal)
    )
    
    (:action 16_virtual_source_act_0
    :parameters ()
        :precondition (and  (vStart)  )
        :effect (and (not(vStart)) (not(vGoal)) (not(h_x1empty)) (not(h_hasX2)) )
    )
    (:action 0_decX1_1_3
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(h_x1empty)) (not(h_hasX2)) )
        :effect (oneof 
        (and (not(vStart)) (not(vGoal)) (not(h_x1empty)) (h_hasX2) )
        (and (not(vStart)) (not(vGoal)) (h_x1empty) (h_hasX2) )
        )
    )
    (:action 1_decX2_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(h_x1empty)) (h_hasX2) )
        :effect (and (not(vStart)) (not(vGoal)) (not(h_x1empty)) (not(h_hasX2)) )
    )
    (:action 3_decX2_6
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (h_x1empty) (h_hasX2) )
        :effect (and (not(vStart)) (vGoal) (h_x1empty) (not(h_hasX2)) )
    )
)