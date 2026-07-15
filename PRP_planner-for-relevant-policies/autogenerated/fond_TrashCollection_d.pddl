
(define (domain TrashCollection_d)
    (:requirements :typing :non-deterministic)
    (:types	)
    (:predicates
    (vStart)
    (vGoal)
    (allCollected)
    (h_carrying)
    )
    
    (:action 8_virtual_source_act_0
    :parameters ()
        :precondition (and  (vStart)  )
        :effect (and (not(vStart)) (not(vGoal)) (not(allCollected)) (not(h_carrying)) )
    )
    (:action 0_moveToLoc_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allCollected)) (not(h_carrying)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(allCollected)) (not(h_carrying)) )
    )
    (:action 0_collectTrash_1
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allCollected)) (not(h_carrying)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(allCollected)) (h_carrying) )
    )
    (:action 0_moveToDump_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allCollected)) (not(h_carrying)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(allCollected)) (not(h_carrying)) )
    )
    (:action 1_moveToDump_1
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allCollected)) (h_carrying) )
        :effect (and (not(vStart)) (not(vGoal)) (not(allCollected)) (h_carrying) )
    )
    (:action 1_depositTrash_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allCollected)) (h_carrying) )
        :effect (and (not(vStart)) (not(vGoal)) (not(allCollected)) (not(h_carrying)) )
    )
    (:action 1_moveToLoc_1
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allCollected)) (h_carrying) )
        :effect (and (not(vStart)) (not(vGoal)) (not(allCollected)) (h_carrying) )
    )
    (:action patched_goal_act
    :parameters ()
        :precondition (and (not (vStart)) )
        :effect (and (vGoal) (not (vStart)) )
    )
)
