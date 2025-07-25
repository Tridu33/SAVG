
(define (domain RGBBlocks_p3_d)
    (:requirements :typing :non-deterministic)
    (:types	)
    (:predicates
    (vStart)
    (vGoal)
    (BlocksCleared)
    (HRed)
    (HGreen)
    (HBlue)
    )
    
    (:action 32_virtual_source_act_0
    :parameters ()
        :precondition (and  (vStart)  )
        :effect (and (not(vStart)) (not(vGoal)) (not(BlocksCleared)) (not(HRed)) (not(HGreen)) (not(HBlue)) )
    )
    (:action 0_pickTop_9
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(BlocksCleared)) (not(HRed)) (not(HGreen)) (not(HBlue)) )
        :effect (and (not(vStart)) (not(vGoal)) (BlocksCleared) (not(HRed)) (not(HGreen)) (HBlue) )
    )
    (:action 9_putTop_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (BlocksCleared) (not(HRed)) (not(HGreen)) (HBlue) )
        :effect (and (not(vStart)) (not(vGoal)) (not(BlocksCleared)) (not(HRed)) (not(HGreen)) (not(HBlue)) )
    )
    (:action 9_colB_24
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (BlocksCleared) (not(HRed)) (not(HGreen)) (HBlue) )
        :effect (and (not(vStart)) (vGoal) (BlocksCleared) (not(HRed)) (not(HGreen)) (not(HBlue)) )
    )
)