
(define (domain TrashCollection_d)
    (:requirements :typing :non-deterministic)
    (:types	)
    (:predicates
    (vStart)
    (vGoal)
    (allCollected)
    (h_carrying)
    )
    
    (:action 8_virtual_source_act_6
    :parameters ()
        :precondition (and  (vStart)  )
        :effect (and (not(vStart)) (vGoal) (allCollected) (not(h_carrying)) )
    )
)