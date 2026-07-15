
(define (domain treechop_p2_d)
    (:requirements :typing :non-deterministic)
    (:types	)
    (:predicates
    (vStart)
    (vGoal)
    (allBranchesChopped)
    (H)
    )
    
    (:action 8_virtual_source_act_0
    :parameters ()
        :precondition (and  (vStart)  )
        :effect (and (not(vStart)) (not(vGoal)) (not(allBranchesChopped)) (not(H)) )
    )
    (:action 0_chopBranch_1
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allBranchesChopped)) (not(H)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(allBranchesChopped)) (H) )
    )
    (:action 1_dropBranch_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allBranchesChopped)) (H) )
        :effect (and (not(vStart)) (not(vGoal)) (not(allBranchesChopped)) (not(H)) )
    )
)