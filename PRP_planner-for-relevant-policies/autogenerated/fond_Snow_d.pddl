
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
    (:action 0_shovelDry_0_8
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allDryCleared)) (not(allWetCleared)) (not(allCleared)) )
        :effect (oneof 
        (and (not(vStart)) (not(vGoal)) (not(allDryCleared)) (not(allWetCleared)) (not(allCleared)) )
        (and (not(vStart)) (vGoal) (not(allDryCleared)) (not(allWetCleared)) (not(allCleared)) )
        )
    )
    (:action 0_moveWet_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allDryCleared)) (not(allWetCleared)) (not(allCleared)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(allDryCleared)) (not(allWetCleared)) (not(allCleared)) )
    )
    (:action 0_shovelWet_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allDryCleared)) (not(allWetCleared)) (not(allCleared)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(allDryCleared)) (not(allWetCleared)) (not(allCleared)) )
    )
    (:action 0_moveDry_0_8
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allDryCleared)) (not(allWetCleared)) (not(allCleared)) )
        :effect (oneof 
        (and (not(vStart)) (not(vGoal)) (not(allDryCleared)) (not(allWetCleared)) (not(allCleared)) )
        (and (not(vStart)) (vGoal) (not(allDryCleared)) (not(allWetCleared)) (not(allCleared)) )
        )
    )
)