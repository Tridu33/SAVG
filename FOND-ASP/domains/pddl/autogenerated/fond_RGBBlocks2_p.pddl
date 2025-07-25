
(define (problem RGBBlocks2_p)  
(:domain RGBBlocks2_d)  
(:objects )  
    (:init	(vStart)	)  
    (:goal	( and 	(vGoal)	)  )

    (:fairness
        :a (0_pickTop_12_10_9_4_2_1)
        :b (12_putTop_0)(10_putTop_0)(9_putTop_0)(4_putTop_0)(2_putTop_0)(1_putTop_0)
    )
)