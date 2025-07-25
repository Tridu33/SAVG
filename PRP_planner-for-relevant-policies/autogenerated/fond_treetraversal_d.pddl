
(define (domain treetraversal_d)
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
    (:action 36_rootiscur2q_34_35
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (curIsRoot) (not(allvisited)) (not(SomeNodesMissed)) (lenis0) (not(lenis1)) (not(curhasunpushedkids)) )
        :effect (oneof 
        (and (not(vStart)) (not(vGoal)) (curIsRoot) (not(allvisited)) (not(SomeNodesMissed)) (not(lenis0)) (lenis1) (not(curhasunpushedkids)) )
        (and (not(vStart)) (not(vGoal)) (curIsRoot) (not(allvisited)) (not(SomeNodesMissed)) (not(lenis0)) (lenis1) (curhasunpushedkids) )
        )
    )
    (:action 34_extract_84
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (curIsRoot) (not(allvisited)) (not(SomeNodesMissed)) (not(lenis0)) (lenis1) (not(curhasunpushedkids)) )
        :effect (and (not(vStart)) (vGoal) (not(curIsRoot)) (allvisited) (not(SomeNodesMissed)) (lenis0) (not(lenis1)) (not(curhasunpushedkids)) )
    )
    (:action 35_pushkids2qOne_32
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (curIsRoot) (not(allvisited)) (not(SomeNodesMissed)) (not(lenis0)) (lenis1) (curhasunpushedkids) )
        :effect (and (not(vStart)) (not(vGoal)) (curIsRoot) (not(allvisited)) (not(SomeNodesMissed)) (not(lenis0)) (not(lenis1)) (not(curhasunpushedkids)) )
    )
    (:action 35_extract_12
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (curIsRoot) (not(allvisited)) (not(SomeNodesMissed)) (not(lenis0)) (lenis1) (curhasunpushedkids) )
        :effect (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (SomeNodesMissed) (lenis0) (not(lenis1)) (not(curhasunpushedkids)) )
    )
    (:action 32_extract_0_1
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (curIsRoot) (not(allvisited)) (not(SomeNodesMissed)) (not(lenis0)) (not(lenis1)) (not(curhasunpushedkids)) )
        :effect (oneof 
        (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (not(SomeNodesMissed)) (not(lenis0)) (not(lenis1)) (not(curhasunpushedkids)) )
        (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (not(SomeNodesMissed)) (not(lenis0)) (not(lenis1)) (curhasunpushedkids) )
        )
    )
    (:action 0_extract_2_1_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (not(SomeNodesMissed)) (not(lenis0)) (not(lenis1)) (not(curhasunpushedkids)) )
        :effect (oneof 
        (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (not(SomeNodesMissed)) (not(lenis0)) (lenis1) (not(curhasunpushedkids)) )
        (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (not(SomeNodesMissed)) (not(lenis0)) (not(lenis1)) (curhasunpushedkids) )
        (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (not(SomeNodesMissed)) (not(lenis0)) (not(lenis1)) (not(curhasunpushedkids)) )
        )
    )
    (:action 2_extract_84
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (not(SomeNodesMissed)) (not(lenis0)) (lenis1) (not(curhasunpushedkids)) )
        :effect (and (not(vStart)) (vGoal) (not(curIsRoot)) (allvisited) (not(SomeNodesMissed)) (lenis0) (not(lenis1)) (not(curhasunpushedkids)) )
    )
    (:action 1_pushkids2q_0
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (not(SomeNodesMissed)) (not(lenis0)) (not(lenis1)) (curhasunpushedkids) )
        :effect (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (not(SomeNodesMissed)) (not(lenis0)) (not(lenis1)) (not(curhasunpushedkids)) )
    )
    (:action 1_extract_11_8_10
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (not(SomeNodesMissed)) (not(lenis0)) (not(lenis1)) (curhasunpushedkids) )
        :effect (oneof 
        (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (SomeNodesMissed) (not(lenis0)) (lenis1) (curhasunpushedkids) )
        (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (SomeNodesMissed) (not(lenis0)) (not(lenis1)) (not(curhasunpushedkids)) )
        (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (SomeNodesMissed) (not(lenis0)) (lenis1) (not(curhasunpushedkids)) )
        )
    )
    (:action 11_pushkids2qOne_8
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (SomeNodesMissed) (not(lenis0)) (lenis1) (curhasunpushedkids) )
        :effect (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (SomeNodesMissed) (not(lenis0)) (not(lenis1)) (not(curhasunpushedkids)) )
    )
    (:action 11_extract_12
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (SomeNodesMissed) (not(lenis0)) (lenis1) (curhasunpushedkids) )
        :effect (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (SomeNodesMissed) (lenis0) (not(lenis1)) (not(curhasunpushedkids)) )
    )
    (:action 8_extract_8_10
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (SomeNodesMissed) (not(lenis0)) (not(lenis1)) (not(curhasunpushedkids)) )
        :effect (oneof 
        (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (SomeNodesMissed) (not(lenis0)) (not(lenis1)) (not(curhasunpushedkids)) )
        (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (SomeNodesMissed) (not(lenis0)) (lenis1) (not(curhasunpushedkids)) )
        )
    )
    (:action 10_extract_12
            :parameters ()
        :precondition (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (SomeNodesMissed) (not(lenis0)) (lenis1) (not(curhasunpushedkids)) )
        :effect (and (not(vStart)) (not(vGoal)) (not(curIsRoot)) (not(allvisited)) (SomeNodesMissed) (lenis0) (not(lenis1)) (not(curhasunpushedkids)) )
    )
)