
(define (domain DeliveryFuel_d)
    (:requirements :typing :non-deterministic)
    (:types	)
    (:predicates
    (vStart)
    (vGoal)
    (allDelivered)
    (h_carrying)
    )
    
    (:action 8_virtual_source_act_0
    :parameters ()
        :precondition (and  (vStart)  )
        :effect (and (not(vStart)) (not(vGoal)) (not(allDelivered)) (not(h_carrying)) )
    )
    (:action 0_loadPkg_1
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allDelivered)) (not(h_carrying)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(allDelivered)) (h_carrying) )
    )
    (:action 1_loadPkg_1
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allDelivered)) (h_carrying) )
        :effect (and (not(vStart)) (not(vGoal)) (not(allDelivered)) (h_carrying) )
    )
    (:action patched_goal_act
    :parameters ()
        :precondition (and (not (vStart)) )
        :effect (and (vGoal) (not (vStart)) )
    )
)
