(define (problem RGBBlocks_p2) 
    (:domain RGBBlocks2)
    (:objects
        i1 - BlockType)
    (:init
        (on_table Bottom)
        (on i1 Bottom)
        (clear i1)
        (isGreen i1)
        (arm_empty)
    )
    (:goal (and
        (clear Bottom)
        (inGreenBox i1)
        ))
    
)
