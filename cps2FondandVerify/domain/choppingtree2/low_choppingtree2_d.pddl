(define (domain choppingtree2)
    (:requirements :strips :typing :equality :derived-predicates :negative-preconditions :universal-preconditions)
    (:types BranchType)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (:predicates
        (onTree ?b - BranchType)
        (chopped ?b - BranchType)
        (clear ?b - BranchType)
        (arm_empty)
        (holding ?b - BranchType)
        ;;;;;;;;;;;;;;;;;;;;;;;;
        (vStart)
        (Vgoal)
        (allChopped)
        (H)
    )
    (:derived (allChopped)
        (forall (?b - BranchType) (chopped ?b))
    )
    (:derived (H)
        (exists (?b - BranchType) (holding ?b))
    )
    ;; ##### ACTIONS #####
    (:action chopBranch
        :parameters (?b - BranchType)
        :precondition (and (onTree ?b) (clear ?b) (arm_empty))
        :effect (and (holding ?b) (not (onTree ?b)) (not (clear ?b)) (not (arm_empty)))
    )
    (:action dropBranch
        :parameters (?b - BranchType)
        :precondition (holding ?b)
        :effect (and (chopped ?b) (arm_empty) (not (holding ?b)))
    )
    (:formula_for_initial_states
        (and
            (arm_empty)
            (not (exists (?b - BranchType) (holding ?b)))
            (forall (?b - BranchType) (onTree ?b))
        )
    )
    (:formula_for_goals
        (and (forall (?b - BranchType) (chopped ?b)))
    )
)
