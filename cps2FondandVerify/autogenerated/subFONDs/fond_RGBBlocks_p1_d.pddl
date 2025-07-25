
(define (domain RGBBlocks_p1_d)
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
    (:action 0_pickTop_12
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(BlocksCleared)) (not(HRed)) (not(HGreen)) (not(HBlue)) )
        :effect (and (not(vStart)) (not(vGoal)) (BlocksCleared) (HRed) (not(HGreen)) (not(HBlue)) )
    )
    (:action 12_putTop_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (BlocksCleared) (HRed) (not(HGreen)) (not(HBlue)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(BlocksCleared)) (not(HRed)) (not(HGreen)) (not(HBlue)) )
    )
    (:action 12_colR_24
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (BlocksCleared) (HRed) (not(HGreen)) (not(HBlue)) )
        :effect (and (not(vStart)) (vGoal) (BlocksCleared) (not(HRed)) (not(HGreen)) (not(HBlue)) )
    )
)