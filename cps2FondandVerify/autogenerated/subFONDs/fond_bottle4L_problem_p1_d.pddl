
(define (domain bottle4L_problem_p1_d)
    (:requirements :typing :non-deterministic)
    (:types	)
    (:predicates
    (vStart)
    (vGoal)
    (vGoal)
    )
    
    (:action 4_virtual_source_act_0
    :parameters ()
        :precondition (and  (vStart)  )
        :effect (and (not(vStart)) (not(vGoal)) )
    )
)