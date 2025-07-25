(define (domain llvisitall)
    (:requirements :strips :typing :equality :conditional-effects :universal-preconditions :derived-predicates :negative-preconditions)
    (:types
        NodeType
    )
    (:constants
        vH vT - NodeType
    )
    (:predicates
        (curpoint2 ?node - NodeType) ;cur
        (llnext ?x ?y - NodeType); Transitive Closure : before
        (visited ?x - NodeType)
        
            (vStart)
            (VGoal); There are 2 high-order fond predicates:
        (allvisited)
        (h_curvisted)
    )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (:derived 
		(allvisited)
		(forall 
			(?node - NodeType)
			(and (visited ?node) ))
	)
    (:derived 
		(h_curvisted)
		(exists 
			(?node - NodeType)
			(and (curpoint2 ?node)(visited ?node) ))
	)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (:action updatecur2llnext
        :parameters (?x ?y - NodeType)
        :precondition (and 
            (curpoint2 ?x)
            (llnext ?x  ?y))
        :effect (and 
            (not (curpoint2 ?x))
            (curpoint2 ?y))
    )
    (:action visitcur; New one temp ptr for store
        :parameters (?x - NodeType)
        :precondition (and 
            (curpoint2 ?x)
            (not (visited ?x)))
        :effect (and 
            (visited ?x))
    )
    (:formula_for_initial_states
    (and
        (exists 
            (?node - NodeType)
            (and  (curpoint2 ?node) (visited ?node) ))
        (or
        (exists 
                (?node - NodeType)
                (and (not (visited ?node)) ))
        (forall 
                (?node - NodeType)
                (and (visited ?node) ))
        )
    )
    )
    (:formula_for_goals 
    (and
        (forall 
                (?node - NodeType)
                (and (visited ?node) ))
    )
    )
)