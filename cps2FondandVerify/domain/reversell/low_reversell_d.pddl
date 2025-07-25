(define (domain reversell)
    (:requirements :strips :typing :equality :conditional-effects :universal-preconditions :derived-predicates :negative-preconditions)
    (:types
        node
    )
    (:constants
        vH1 vT1 vH2 vT2 - NodeType
        ;vH1 -> ... -> vT1 "unreversed ll"
        ;vH2 -> vT2 "reversed ll"
    )
    (:predicates
        (curpoint2 ?x - NodeType) ;cur
        (llnext ?x ?y - NodeType); Transitive Closure : before
        (curispophead1)
        (reversed ?node - NodeType)
            (vStart)
            (VGoal)
        (allvisited)
        (h_curispophead1)
        (h_curinserted)
    )
    (:derived;
		(allvisited)
		(forall (?node - NodeType)
		    (or 
		        (reversed ?node) 
		        (= vH1 ?node )
		        (= vT1 ?node )
		        (= vH2 ?node)
		        (= vT2 ?node)
		    )
		)
	)
    (:derived
		(h_curispophead1)
		(and (curispophead1))
	)
    (:derived 
		(h_curinserted)
		(exists 
			(?node - NodeType)
			(and (curpoint2 ?node) (llnext vH2 ?node)))
	)
    
    (:action pophead1;fromunreversedll 
        :parameters (?head1 ?suc - NodeType)
        :precondition (and 
            (curpoint2 ?head1)
            (llnext vH1 ?head1)
            (llnext ?head1 ?suc)
            (not (= ?head1 vT1))
            )
        :effect (and 
            (curpoint2 ?head1)
            (not (llnext vH1 ?head1))
            (curispophead1)
            (not (llnext ?head1 ?suc))
            (llnext vH1 ?suc)
            )
    )
    (:action insert2;reversedll ; head insert: ?head1 insert  vH2->?y to vH2->?head1->?y
        :parameters (?oldhead1newhead2 ?head2 - NodeType)
        :precondition (and 
            (curpoint2 ?oldhead1newhead2)
            (curispophead1)
            (llnext vH2 ?head2)
            ); ?head2 can be "vT2"
        :effect (and 
            (reversed ?oldhead1newhead2)
            (llnext vH2 ?oldhead1newhead2)
            (llnext ?oldhead1newhead2 ?head2)
            (not (llnext vH2 ?head2))
            (not (curispophead1))
            )
    )
    (:action gethead1
        :parameters (?oths ?node - NodeType)
        :precondition (and 
            (llnext vH1 ?node)
            (curpoint2 ?oths)
            (not(curpoint2 ?node))
            (not(= ?oths ?node))
            (not (curispophead1))
        )
        :effect (and 
            (not(curpoint2 ?oths))
            (curpoint2 ?node)
        )
    )
    (:formula_for_initial_states
      (and
        (exists 
            (?node - NodeType)
            (and (not (reversed ?node)) ))
        (not (curispophead1))
        (not (exists (?node - NodeType)
                (and
                    (curpoint2 ?node)
                    (llnext vH2 ?node))))
      )
    )
    (:formula_for_goals 
        (and
        (forall 
            (?node - NodeType)
            (and (reversed ?node) ))
        ;(next vH1 vT1)
        )
    )
)
