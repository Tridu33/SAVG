
(define (domain DeliveryFuel_d)
    (:requirements :typing :non-deterministic)
    (:types	)
    (:predicates
    (vStart)
    (vGoal)
    (vGoal)
    (allDelivered)
    (h_carrying)
    )
    
    (:action 16_virtual_source_act_0
    :parameters ()
        :precondition (and  (vStart)  )
        :effect (and (not(vStart)) (not(vGoal)) (not(allDelivered)) (not(h_carrying)) )
    )
    (:action 0_loadPkg_1
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allDelivered)) (not(h_carrying)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(allDelivered)) (h_carrying) )
    )
    (:action 0_moveToCustomer_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allDelivered)) (not(h_carrying)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(allDelivered)) (not(h_carrying)) )
    )
    (:action 1_moveToCustomer_1
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allDelivered)) (h_carrying) )
        :effect (and (not(vStart)) (not(vGoal)) (not(allDelivered)) (h_carrying) )
    )
    (:action 1_unloadPkg_2_0_1
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allDelivered)) (h_carrying) )
        :effect (oneof 
        (and (not(vStart)) (not(vGoal)) (allDelivered) (not(h_carrying)) )
        (and (not(vStart)) (not(vGoal)) (not(allDelivered)) (not(h_carrying)) )
        (and (not(vStart)) (not(vGoal)) (not(allDelivered)) (h_carrying) )
        )
    )
    (:action 1_loadPkg_1
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allDelivered)) (h_carrying) )
        :effect (and (not(vStart)) (not(vGoal)) (not(allDelivered)) (h_carrying) )
    )
)