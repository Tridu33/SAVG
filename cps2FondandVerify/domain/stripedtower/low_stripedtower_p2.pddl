(define (problem stripedtower_p2) 
    (:domain stripedtower)
    (:objects
        r1 r2 b1 - BlockType)
    (:init
        (on_table Bottom)
        (on b1 Bottom)
        (on r2 b1)
        (on r1 r2)
        (clear r1)
        (isred r1)
        (isred r2)
        (isblue b1)
        (arm_empty)
        (not (OneBinBox))
        (not (OneRinBox))
    )
    (:goal (and
        (inbox r1)
        (inbox b1)
        ))
)
