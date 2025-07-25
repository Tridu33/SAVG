(define (problem low_treetraversal_p1)
  (:domain treetraversal)
  (:objects 
    n1 - NodeType)

  (:init
	( curpoint2 n1 ) 
	(not (visited n1))
	(qnext vqhead vqtail)
	( root n1 )
	( visited vqtail )
	( visited vqhead )
  )
  
  (:goal
	( and 
		(visited n1)
	)
  )
)
