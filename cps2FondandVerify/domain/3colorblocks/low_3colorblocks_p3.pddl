(define (problem 3colorblocks_p3)
    (:domain 3colorblocks)
    (:objects
        i1 - BlockType)
    (:init
        (on_table Bottom)
        (on i1 Bottom)
        (clear i1)
        (isBlue i1)
        (arm_empty)
    )
    (:goal (and
        (clear Bottom)
        (inBlueBox i1)
        ))
)
