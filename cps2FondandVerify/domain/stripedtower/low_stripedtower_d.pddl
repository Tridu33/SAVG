; ADD (transitive_closure (above,on))
; means:predicate 'above' is transitive_closure of predicate 'on'.
; will be used in describe high level action with low level language 
(define (domain stripedtower)
    (:requirements :strips :equality :typing :transitive_closure)
    (:types BlockType)
    (:constants
      Bottom - BlockType
    )
    (:predicates 
      (arm_empty)
      (clear ?x - BlockType)
      (inbox ?x - BlockType)
      (isblue ?x - BlockType)
      (isred ?y - BlockType)
      (on_table ?x - BlockType)
      (holding ?x - BlockType)
      (on ?x ?y - BlockType)
      (OneBinBox)
        (OneRinBox)
      ;;;;;;;;;;;;;;;;;;;;;;;;
      (vStart)
      (VGoal)
      (h_OneBRinBox); Box Has 1R & 1B
        (h_OneBinBox);
        (h_OneRinBox);
      (H)
        (HoldingR)
        (HoldingB)
    )
    (:derived
        (h_OneBRinBox)
        (exists (?x ?y - BlockType) (and (inbox ?x) (inbox ?y) (isblue ?x) (isred ?y))))
    (:derived
        (h_OneBinBox)
        (exists (?x - BlockType) (and (inbox ?x) (isblue ?x))))
    (:derived
        (h_OneRinBox)
        (exists (?x - BlockType) (and (inbox ?x) (isred ?x))))
    (:derived
        (H)
        (exists (?x - BlockType) (holding ?x)))
    (:derived
        (HoldingR)
        (exists (?x - BlockType) (and (holding ?x) (isred ?x))))
    (:derived
        (HoldingB)
        (exists (?x - BlockType) (and (holding ?x) (isblue ?x))))

    (:action putRaside
      :parameters  (?x - BlockType)
      :precondition (and (holding ?x) (isred ?x) (OneRinBox) )
      :effect (and (clear ?x) (arm_empty) (on_table ?x) 
                  (not (holding ?x))))

    (:action putBaside
      :parameters  (?x - BlockType)
      :precondition (and (holding ?x) (isblue ?x) (OneBinBox) )
      :effect (and (clear ?x) (arm_empty) (on_table ?x) 
                  (not (holding ?x))))

    (:action putBinbox
      :parameters  (?x - BlockType)
      :precondition (and (not (OneBinBox)) (holding ?x) (isblue ?x))
      :effect (and (OneBinBox) (inbox ?x) (arm_empty) (not (holding ?x))))

    (:action putRinbox
      :parameters  (?x - BlockType)
      :precondition (and (not (OneRinBox)) (holding ?x) (isred ?x))
      :effect (and (OneRinBox) (inbox ?x) (arm_empty) (not (holding ?x))))

    (:action picktop
      :parameters  (?x ?y - BlockType)
      :precondition (and (on ?x ?y) (clear ?x) (arm_empty))
      :effect (and (holding ?x) (clear ?y)
                  (not (on ?x ?y)) (not (clear ?x)) (not (arm_empty))))
    (:formula_for_initial_states
        (and
          (arm_empty)
          (not (exists (?x ?y - BlockType) (and (inbox ?x) (inbox ?y) (isblue ?x) (isred ?y))) )
          (not (exists (?x - BlockType) (and (inbox ?x) (isblue ?x))) )
          (not (exists (?y - BlockType) (and (inbox ?y) (isred ?y))) )
          (not (exists (?x - BlockType) (and (holding ?x) )) ) 
          (not (exists (?x - BlockType) (and (holding ?x) (isred ?x) ))) 
          (not (exists (?x - BlockType) (and (holding ?x) (isblue ?x) ))) 
        )
    )
    (:formula_for_goals 
      (and 
        (exists (?x ?y - BlockType) (and (inbox ?x) (inbox ?y) (isblue ?x) (isred ?y)))
      )
    )
)