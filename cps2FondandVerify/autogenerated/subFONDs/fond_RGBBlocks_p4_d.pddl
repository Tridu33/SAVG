
(define (domain RGBBlocks_p4_d)
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
    (:action 0_pickTop_4_2_1_12
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(BlocksCleared)) (not(HRed)) (not(HGreen)) (not(HBlue)) )
        :effect (oneof 
        (and (not(vStart)) (not(vGoal)) (not(BlocksCleared)) (HRed) (not(HGreen)) (not(HBlue)) )
        (and (not(vStart)) (not(vGoal)) (not(BlocksCleared)) (not(HRed)) (HGreen) (not(HBlue)) )
        (and (not(vStart)) (not(vGoal)) (not(BlocksCleared)) (not(HRed)) (not(HGreen)) (HBlue) )
        (and (not(vStart)) (not(vGoal)) (BlocksCleared) (HRed) (not(HGreen)) (not(HBlue)) )
        )
    )
    (:action 4_putTop_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(BlocksCleared)) (HRed) (not(HGreen)) (not(HBlue)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(BlocksCleared)) (not(HRed)) (not(HGreen)) (not(HBlue)) )
    )
    (:action 4_colR_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(BlocksCleared)) (HRed) (not(HGreen)) (not(HBlue)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(BlocksCleared)) (not(HRed)) (not(HGreen)) (not(HBlue)) )
    )
    (:action 2_putTop_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(BlocksCleared)) (not(HRed)) (HGreen) (not(HBlue)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(BlocksCleared)) (not(HRed)) (not(HGreen)) (not(HBlue)) )
    )
    (:action 2_colG_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(BlocksCleared)) (not(HRed)) (HGreen) (not(HBlue)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(BlocksCleared)) (not(HRed)) (not(HGreen)) (not(HBlue)) )
    )
    (:action 1_putTop_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(BlocksCleared)) (not(HRed)) (not(HGreen)) (HBlue) )
        :effect (and (not(vStart)) (not(vGoal)) (not(BlocksCleared)) (not(HRed)) (not(HGreen)) (not(HBlue)) )
    )
    (:action 1_colB_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(BlocksCleared)) (not(HRed)) (not(HGreen)) (HBlue) )
        :effect (and (not(vStart)) (not(vGoal)) (not(BlocksCleared)) (not(HRed)) (not(HGreen)) (not(HBlue)) )
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