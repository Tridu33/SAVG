
(define (domain low_treetraversal_p1_d)
    (:requirements :typing :non-deterministic)
    (:types	)
    (:predicates
    (vStart)
    (vGoal)
    (curIsRoot)
    (allvisited)
    (SomeNodesMissed)
    (lenis0)
    (lenis1)
    (curhasunpushedkids)
    )
    
    (:action 128_virtual_source_act_36
    :parameters ()
        :precondition (and  (vStart)  )
        :effect (and (not(vStart)) (not(vGoal)) (curIsRoot) (not(allvisited)) (not(SomeNodesMissed)) (lenis0) (not(lenis1)) (not(curhasunpushedkids)) )
    )
    (:action 36_rootiscur2q_34
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (curIsRoot) (not(allvisited)) (not(SomeNodesMissed)) (lenis0) (not(lenis1)) (not(curhasunpushedkids)) )
        :effect (and (not(vStart)) (not(vGoal)) (curIsRoot) (not(allvisited)) (not(SomeNodesMissed)) (not(lenis0)) (lenis1) (not(curhasunpushedkids)) )
    )
    (:action 34_extract_84
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (curIsRoot) (not(allvisited)) (not(SomeNodesMissed)) (not(lenis0)) (lenis1) (not(curhasunpushedkids)) )
        :effect (and (not(vStart)) (vGoal) (not(curIsRoot)) (allvisited) (not(SomeNodesMissed)) (lenis0) (not(lenis1)) (not(curhasunpushedkids)) )
    )
)