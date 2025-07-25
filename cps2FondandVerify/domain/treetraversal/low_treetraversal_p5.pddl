(define (problem low_treetraversal_p5)
  (:domain treetraversal)
  (:objects 
    n1 n2 n3 n6 n7 - NodeType)
  
  (:init
	( curpoint2 n1 )
	(qnext vqhead vqtail)
	( visited vqtail )
	( visited vqhead )
	( root n1 )
	; (not (inq n1))
	; (not (inq n2))
	; (not (inq n3))
	(internal n1) ;  Internal, non-leaf nodes, with children
	(left_child n2 n1)
	(right_child n3 n1)
	(internal n3)
	(left_child n6 n3)
	(right_child n7 n3)
	(not( visited n1 ))
	(not( visited n2 ))
	(not( visited n3 ))
	(not( visited n6 ))
	(not( visited n7 ))
  )
  
  (:goal
	( and 
	( visited n1 )
	( visited n2 )
	( visited n3 )
	( visited n6 )
	( visited n7 )
	)
  )
)
; Solution action sequence:

; (visit curptr n3)
; (push2q curptr n3 vqhead n1)
; (left2cur curptr curptr n2 n3)
; (visit curptr n2)
; (qpoll curptr n3 vqtail n2)
; (right2cur curptr curptr n1 n3)
; (visit curptr n1)
; ; cost = 7 (unit cost)