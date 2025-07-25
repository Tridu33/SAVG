(define (problem low_treetraversal_p2)
  (:domain treetraversal)
  (:objects 
    n1 n2 n3 - NodeType)

  (:init
	( curpoint2 n1 )
	( root n1 )
	( internal n1 )
	( left_child n2 n1 )
	( right_child n3 n1 )
	(not (visited n1))
	(not (visited n2))
	(not (visited n3))
	(qnext vqhead vqtail)
	; (not (inq n1))
	; (not (inq n2))
	; (not (inq n3))
	( visited vqtail )
	( visited vqhead )
  )
  
  (:goal
	( and 
	( visited n3 )
	( visited n1 )
	( visited n2 )
	)
  )
)
; Solution action sequence:

; (visit curptr n3)
; (push2q curptr n3 vqhead n1)
; (right2cur curptr curptr n1 n3)
; (visit curptr n1)
; (qpoll curptr n3 vqtail n1)
; (right2cur curptr curptr n2 n3)
; (visit curptr n2)
; ; cost = 7 (unit cost)