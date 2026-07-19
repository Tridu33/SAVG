
(define (domain TreeChop_d)
    (:requirements :typing :non-deterministic)
    (:types	)
    (:predicates
    (vStart)
    (vGoal)
    (allBranchesChopped)
    (H)
    (vGoal)
    )
    
    (:action 16_virtual_source_act_0_2
    :parameters ()
        :precondition (and  (vStart)  )
        :effect (oneof 
        (and (not(vStart)) (not(vGoal)) (not(allBranchesChopped)) (not(H)) )
        (and (not(vStart)) (not(vGoal)) (allBranchesChopped) (not(H)) )
        )
    )
    (:action 2_fellTree_6
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (allBranchesChopped) (not(H)) )
        :effect (and (not(vStart)) (vGoal) (allBranchesChopped) (not(H)) )
    )
    (:action 2_chopBranch_3
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (allBranchesChopped) (not(H)) )
        :effect (and (not(vStart)) (not(vGoal)) (allBranchesChopped) (H) )
    )
    (:action 0_chopBranch_1
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allBranchesChopped)) (not(H)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(allBranchesChopped)) (H) )
    )
    (:action 1_dropBranch_0_2
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allBranchesChopped)) (H) )
        :effect (oneof 
        (and (not(vStart)) (not(vGoal)) (not(allBranchesChopped)) (not(H)) )
        (and (not(vStart)) (not(vGoal)) (allBranchesChopped) (not(H)) )
        )
    )
    (:action 3_dropBranch_2
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (allBranchesChopped) (H) )
        :effect (and (not(vStart)) (not(vGoal)) (allBranchesChopped) (not(H)) )
    )
)