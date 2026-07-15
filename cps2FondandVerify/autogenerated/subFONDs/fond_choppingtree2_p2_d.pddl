
(define (domain choppingtree2_p2_d)
    (:requirements :typing :non-deterministic)
    (:types	)
    (:predicates
    (vStart)
    (vGoal)
    (allChopped)
    (H)
    )
    
    (:action 8_virtual_source_act_0
    :parameters ()
        :precondition (and  (vStart)  )
        :effect (and (not(vStart)) (not(vGoal)) (not(allChopped)) (not(H)) )
    )
    (:action 0_chopBranch_1
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allChopped)) (not(H)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(allChopped)) (H) )
    )
    (:action 1_dropBranch_0_6
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allChopped)) (H) )
        :effect (oneof 
        (and (not(vStart)) (not(vGoal)) (not(allChopped)) (not(H)) )
        (and (not(vStart)) (vGoal) (allChopped) (not(H)) )
        )
    )
)