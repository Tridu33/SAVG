(define (domain treetraversal)
	(:requirements :typing :equality :negative-preconditions
    :disjunctive-preconditions :universal-preconditions :derived-predicates
    :conditional-effects );:non-deterministic )	
	(:types
		NodeType
	)
	(:constants
		vqtail vqhead - NodeType
	)

	(:predicates
		(left_child ?child ?parent - NodeType)
		(right_child ?child ?parent - NodeType)
		(internal ?node - NodeType)
		(root ?node - NodeType)
		(visited ?node - NodeType)
		(curpoint2 ?node - NodeType)
		; vqhead -> a1->...->an -> vqtail
		(qnext ?node ?sucnode - NodeType)
		(inq ?node  - NodeType)

            (vStart)
            (VGoal)
            (curIsRoot)
		(allvisited)
		(SomeNodesMissed)
		(lenis0)
		(lenis1)
		(curhasunpushedkids)
	)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; abstract predicates ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	(:derived 
		(curIsRoot)
		(exists 
			(?node - NodeType)
			(and (curpoint2 ?node) (root ?node) ))
		)
	(:derived 
		(allvisited)
		(forall 
			(?node - NodeType)
			(and (visited ?node) ))
		)
	(:derived
		(SomeNodesMissed)
		(exists 
			(?node ?l ?r - NodeType )
			(and 
			(visited ?node); already pop but have not add its kids into memory Queue
			(internal ?node)
			(left_child ?l ?node)
			(right_child ?r ?node)
			(not (inq ?node))
			(not (inq ?l))
			(not (inq ?r))
			(not (visited ?l))
			(not (visited ?r))
			)
		)
	)
	(:derived 
		(lenis0)
		(and (qnext vqhead vqtail))
		)
	(:derived 
		(lenis1)
		(exists 
			(?node - NodeType ) 
			(and 
				(qnext vqhead ?node)
				(qnext ?node vqtail)
				))
		)
	(:derived 
		(curhasunpushedkids)
		(exists 
			(?node ?l ?r - NodeType ) 
			(and 
				(curpoint2 ?node)
				(qnext vqhead ?node)
				(internal ?node)
				(left_child ?l ?node)
				(right_child ?r ?node)
				(not (inq ?l))
				(not (inq ?r))
				))
		)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;; low-level actions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	(:action rootiscur2q 
		:parameters (?node - NodeType)
		:precondition (and 
			(curpoint2  ?node) ;(not(inq ?node))
			(root ?node)
			(qnext vqhead vqtail) 
		)
		:effect (and
			(not (qnext vqhead vqtail))
			(qnext vqhead ?node)
			(qnext ?node vqtail)
			(inq ?node)
		)
	)
	(:action pushkids2q; before 'qpoll' kids of ?parent current sptr point to
		:parameters ( ?pre ?parent ?l ?r  - NodeType)
		:precondition (and 
			(curpoint2 ?parent)
			(qnext vqhead ?parent)
			(internal ?parent)
			(left_child ?l ?parent)
			(right_child ?r ?parent)
			(qnext ?pre vqtail)
			(not (= ?parent ?pre))
		)
		:effect (and
			; 'vqhead -> ?parent -> ... -> ?prepre -> ?pre -> vqtail'  
			; 'vqhead -> ?parent -> ... -> ?pre -> ?l -> ?r -> vqtail'
			(not (qnext ?pre vqtail))
			(qnext ?pre ?l)
			(qnext ?l ?r)
			(qnext ?r vqtail)
			(inq ?l)
			(inq ?r)
		)
	)
	(:action pushkids2qOne
		; vQHead->n1->vQTail does not duplicate when enumerating parameter objects resulting in the vQHead->n1-> vQTail special case cannot handle this action because the enumerated objects are not written in duplicate form if the number of repeated enumerations is too redundant
		; In the previous action pushhkidsoftop2q ( ?pre ?parent ?l −r - NodeType) is a variable for n1 and the enumeration state I implemented is not duplicated the circumvention method is to set a new action like this
		:parameters ( ?parentispre ?l ?r  - NodeType)
		:precondition (and 
			(curpoint2 ?parentispre)
			(qnext vqhead ?parentispre)
			(internal ?parentispre)
			(left_child ?l ?parentispre)
			(right_child ?r ?parentispre)
			(qnext ?parentispre vqtail)
		)
		:effect (and
			; 'vqhead -> ?parentispre -> vqtail' 
			; 'vqhead -> ?parentispre -> ?l -> ?r -> vqtail'
			(not (qnext ?parentispre vqtail))
			(qnext ?parentispre ?l)
			(qnext ?l ?r)
			(qnext ?r vqtail)
			(inq ?l)
			(inq ?r)
		)
	)
	
	(:action extract ; cur=q.top() & q.pop() a.k.a "extract"
		:parameters (?suc ?sucsuc - NodeType)
		:precondition (and 
			(not (qnext vqhead vqtail)) ; ?old can be NULL in the initial state  
			(curpoint2 ?suc) (qnext vqhead ?suc) (not (= vqtail ?suc)) ; poll appliable means : q must not be an empty queue
			(qnext ?suc ?sucsuc) (inq ?suc) 
		)
		:effect (and 
			(not(qnext vqhead ?suc))
			(not(qnext ?suc ?sucsuc))
			(qnext vqhead ?sucsuc)
			(curpoint2 ?sucsuc) (not (curpoint2 ?suc))
			;  This points to the ejected head node in order to continue with pushhkids
			(not (inq ?suc))
			(visited ?suc)
		)
	)
    (:formula_for_initial_states
      (and
      	(exists(?node - NodeType) (and(curpoint2 node) (root ?node)))
        (not(forall(?node - NodeType) ((visited ?node))))
        (not(exists(?node ?l ?r - NodeType)(and (visited ?node)(internal ?node)(left_child ?l ?node)(right_child ?r ?node)(not (inq ?node))(not (inq ?l))(not (inq ?r))(not(visited ?l))(not(visited ?r)))))
        ((qnext vqhead vqtail))
        (not(exists(?node - NodeType)(and (qnext vqhead ?node)(qnext ?node vqtail))))
        (not(exists(?node ?l ?r - NodeType) (and(curpoint2 ?node)(qnext vqhead ?node)(internal ?node)(left_child ?l ?node)(right_child ?r ?node)(not (inq ?l))(not (inq ?r)))))
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














