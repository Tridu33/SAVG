(define (problem stripedtower_p1)
    (:domain stripedtower)
    (:objects
        r1 b1 - BlockType)
    (:init
        (on_table Bottom)
        (on b1 Bottom)
        (on r1 b1)
        (clear r1)
        (isred r1)
        (isblue b1)
        (arm_empty)
        (not (OneBinBox))
        (not (OneRinBox))
    )
    (:goal (and
        (inbox r1)
        (inbox b1)
        )
    )
)
