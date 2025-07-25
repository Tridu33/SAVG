
(define (domain stripedtower_d)
    (:requirements :typing :non-deterministic)
    (:types	)
    (:predicates
    (vStart)
    (vGoal)
    (h_OneBRinBox)
    (h_OneBinBox)
    (h_OneRinBox)
    (H)
    (HoldingR)
    (HoldingB)
    )
    
    (:action 128_virtual_source_act_0
    :parameters ()
        :precondition (and  (vStart)  )
        :effect (and (not(vStart)) (not(vGoal)) (not(h_OneBRinBox)) (not(h_OneBinBox)) (not(h_OneRinBox)) (not(H)) (not(HoldingR)) (not(HoldingB)) )
    )
    (:action 0_picktop_6_5
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(h_OneBRinBox)) (not(h_OneBinBox)) (not(h_OneRinBox)) (not(H)) (not(HoldingR)) (not(HoldingB)) )
        :effect (oneof 
        (and (not(vStart)) (not(vGoal)) (not(h_OneBRinBox)) (not(h_OneBinBox)) (not(h_OneRinBox)) (H) (HoldingR) (not(HoldingB)) )
        (and (not(vStart)) (not(vGoal)) (not(h_OneBRinBox)) (not(h_OneBinBox)) (not(h_OneRinBox)) (H) (not(HoldingR)) (HoldingB) )
        )
    )
    (:action 6_putRinbox_8
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(h_OneBRinBox)) (not(h_OneBinBox)) (not(h_OneRinBox)) (H) (HoldingR) (not(HoldingB)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(h_OneBRinBox)) (not(h_OneBinBox)) (h_OneRinBox) (not(H)) (not(HoldingR)) (not(HoldingB)) )
    )
    (:action 8_picktop_13_14
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(h_OneBRinBox)) (not(h_OneBinBox)) (h_OneRinBox) (not(H)) (not(HoldingR)) (not(HoldingB)) )
        :effect (oneof 
        (and (not(vStart)) (not(vGoal)) (not(h_OneBRinBox)) (not(h_OneBinBox)) (h_OneRinBox) (H) (not(HoldingR)) (HoldingB) )
        (and (not(vStart)) (not(vGoal)) (not(h_OneBRinBox)) (not(h_OneBinBox)) (h_OneRinBox) (H) (HoldingR) (not(HoldingB)) )
        )
    )
    (:action 13_putBinbox_120
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(h_OneBRinBox)) (not(h_OneBinBox)) (h_OneRinBox) (H) (not(HoldingR)) (HoldingB) )
        :effect (and (not(vStart)) (vGoal) (h_OneBRinBox) (h_OneBinBox) (h_OneRinBox) (not(H)) (not(HoldingR)) (not(HoldingB)) )
    )
    (:action 14_putRaside_8
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(h_OneBRinBox)) (not(h_OneBinBox)) (h_OneRinBox) (H) (HoldingR) (not(HoldingB)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(h_OneBRinBox)) (not(h_OneBinBox)) (h_OneRinBox) (not(H)) (not(HoldingR)) (not(HoldingB)) )
    )
    (:action 5_putBinbox_16
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(h_OneBRinBox)) (not(h_OneBinBox)) (not(h_OneRinBox)) (H) (not(HoldingR)) (HoldingB) )
        :effect (and (not(vStart)) (not(vGoal)) (not(h_OneBRinBox)) (h_OneBinBox) (not(h_OneRinBox)) (not(H)) (not(HoldingR)) (not(HoldingB)) )
    )
    (:action 16_picktop_22
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(h_OneBRinBox)) (h_OneBinBox) (not(h_OneRinBox)) (not(H)) (not(HoldingR)) (not(HoldingB)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(h_OneBRinBox)) (h_OneBinBox) (not(h_OneRinBox)) (H) (HoldingR) (not(HoldingB)) )
    )
    (:action 22_putRinbox_120
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(h_OneBRinBox)) (h_OneBinBox) (not(h_OneRinBox)) (H) (HoldingR) (not(HoldingB)) )
        :effect (and (not(vStart)) (vGoal) (h_OneBRinBox) (h_OneBinBox) (h_OneRinBox) (not(H)) (not(HoldingR)) (not(HoldingB)) )
    )
)