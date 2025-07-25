(define (domain RGBBlocks2)
  (:requirements :strips :equality :typing )
  (:types BlockType)
  (:constants
    Bottom - BlockType
  )
  (:predicates 
    (on_table ?x - BlockType)
    (clear ?x - BlockType)
    (on  ?x ?y - BlockType)
    (holding ?x - BlockType)  
    (isRed ?x - BlockType)
    (isGreen ?x - BlockType)
    (isBlue ?x - BlockType)
    (inRedBox ?x - BlockType)
    (inGreenBox ?x - BlockType)
    (inBlueBox ?x - BlockType)
    (arm_empty)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (vStart)
    (VGoal)
    (BlocksCleared)
    (HRed)
    (HGreen)
    (HBlue)
  )
 ;(:transitive_closure (above,on)); 
  (:derived
      (BlocksCleared)
      (clear Bottom))
  (:derived
    (HRed)
      (exists (?x - BlockType) (and (isRed ?x) (holding ?x) )))
  (:derived
    (HGreen)
      (exists (?x - BlockType) (and (isGreen ?x) (holding ?x) )))
  (:derived
    (HBlue)
      (exists (?x - BlockType) (and (isBlue ?x) (holding ?x) )))
  ;; ##### ACTIONS #####
  (:action pickTop
    :parameters  (?x ?y - BlockType)
    :precondition (and (on ?x ?y) (clear ?x) (arm_empty))
    :effect (and (holding ?x) (clear ?y)
                (not (on ?x ?y)) (not (clear ?x)) (not (arm_empty))))
  (:action putTop
        :parameters (?x ?y - BlockType)
        :precondition (and (holding ?x) (clear ?y) )
        :effect (and (on ?x ?y) (clear ?x) (arm_empty)
                     (not (holding ?x)) (not (clear ?y))))
  (:action colR
    :parameters (?x - BlockType)
    :precondition (and 
		      (holding ?x) (isRed ?x) )
    :effect (and (inRedBox ?x) (arm_empty) (not (holding ?x))    )
  )
  (:action colG
    :parameters (?x - BlockType)
    :precondition (and 
		      (holding ?x) (isGreen ?x) )
    :effect (and (inGreenBox ?x) (arm_empty) (not (holding ?x))    )
  )
  (:action colB
    :parameters (?x - BlockType)
    :precondition (and 
		      (holding ?x) (isBlue ?x) )
    :effect (and (inBlueBox ?x) (arm_empty) (not (holding ?x))    )
  )
  ; (:formula_for_initial_states
  ;     (and
  ;       (arm_empty)
  ;       (not (clear Bottom))
  ;     )
  ; )
  (:formula_for_initial_states
      (and
        (arm_empty)
        (not (clear Bottom))
        (not (exists (?x - BlockType)(and((isRed ?x) (holding ?x)))))
        (not (exists (?x - BlockType)(and((isGreen ?x) (holding ?x)))))
        (not (exists (?x - BlockType)(and((isBlue ?x) (holding ?x)))))
      )
  )
  (:formula_for_goals 
    (and
      (clear Bottom))
  )
  (:conditionfairness
    :a (pickTop)
    :b (putTop)
  )
)