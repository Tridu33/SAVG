(define (problem RGBBlocks_p1) 
    (:domain RGBBlocks)
    (:objects
        i1 - BlockType)
    (:init
        (on_table Bottom)
        (on i1 Bottom)
        (clear i1)
        (isRed i1)
        (arm_empty)
    )
    (:goal (and
        (clear Bottom)
        (inRedBox i1)
        ))
)
