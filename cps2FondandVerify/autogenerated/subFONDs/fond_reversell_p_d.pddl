
(define (domain reversell_p_d)
    (:requirements :typing :non-deterministic)
    (:types	)
    (:predicates
    (vStart)
    (vGoal)
    (allvisited)
    (h_curispophead1)
    (h_curinserted)
    )
    
    (:action 16_virtual_source_act_0
    :parameters ()
        :precondition (and  (vStart)  )
        :effect (and (not(vStart)) (not(vGoal)) (not(allvisited)) (not(h_curispophead1)) (not(h_curinserted)) )
    )
    (:action 0_pophead1_2
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allvisited)) (not(h_curispophead1)) (not(h_curinserted)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(allvisited)) (h_curispophead1) (not(h_curinserted)) )
    )
    (:action 2_insert2_1_13
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allvisited)) (h_curispophead1) (not(h_curinserted)) )
        :effect (oneof 
        (and (not(vStart)) (not(vGoal)) (not(allvisited)) (not(h_curispophead1)) (h_curinserted) )
        (and (not(vStart)) (vGoal) (allvisited) (not(h_curispophead1)) (h_curinserted) )
        )
    )
    (:action 1_gethead1_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(allvisited)) (not(h_curispophead1)) (h_curinserted) )
        :effect (and (not(vStart)) (not(vGoal)) (not(allvisited)) (not(h_curispophead1)) (not(h_curinserted)) )
    )
)