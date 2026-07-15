(define (domain 3delivery)
    (:requirements :strips :typing :equality :derived-predicates :negative-preconditions :universal-preconditions)
    (:types PackageType)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (:predicates
        (atDepotPkg ?p - PackageType)
        (inTruck ?p - PackageType)
        (delivered ?p - PackageType)
        (arm_empty)
        (vStart)
        (Vgoal)
        (allDelivered)
        (h_carrying)
    )
    (:derived (allDelivered)
        (forall (?p - PackageType) (delivered ?p))
    )
    (:derived (h_carrying)
        (exists (?p - PackageType) (inTruck ?p))
    )
    ;; ##### ACTIONS #####
    (:action loadPkg
        :parameters (?p - PackageType)
        :precondition (and (atDepotPkg ?p) (arm_empty))
        :effect (and (inTruck ?p) (not (atDepotPkg ?p)) (not (arm_empty)))
    )
    (:action deliverPkg
        :parameters (?p - PackageType)
        :precondition (inTruck ?p)
        :effect (and (delivered ?p) (arm_empty) (not (inTruck ?p)))
    )
    (:formula_for_initial_states
        (and
            (arm_empty)
            (not (exists (?p - PackageType) (inTruck ?p)))
            (not (forall (?p - PackageType) (delivered ?p)))
            (exists (?p - PackageType) (atDepotPkg ?p))
        )
    )
    (:formula_for_goals
        (and (forall (?p - PackageType) (delivered ?p)))
    )
)
