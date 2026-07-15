
(define (domain Snow_d)
    (:requirements :typing :non-deterministic)
    (:types	)
    (:predicates
    (vStart)
    (vGoal)
    (allDryCleared)
    (allWetCleared)
    (allCleared)
    )
    
    (:action 16_virtual_source_act_0
    :parameters ()
        :precondition (and  (vStart)  )
        :effect (and (not(vStart)) (not(vGoal)) (not(allDryCleared)) (not(allWetCleared)) (not(allCleared)) )
    )
    (:action 0_shovelDry_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allDryCleared)) (not(allWetCleared)) (not(allCleared)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(allDryCleared)) (not(allWetCleared)) (not(allCleared)) )
    )
    (:action patched_goal_act
    :parameters ()
        :precondition (and (not (vStart)) )
        :effect (and (vGoal) (not (vStart)) )
    )
)
