#!/usr/bin/env python 
# -*- coding:UTF-8 -*-

import json,copy
from collections import OrderedDict
class LowState():
    def __init__(self) -> None:
        self.low2highStateid = -1
        self.low2highStatedict = OrderedDict()
        self.posState = []
        self.negState = []

    def getposState(self,posState:list()):
        self.posState = posState

    def getnegState(self,negState:list()):
        self.negState = negState

    def __str__(self) -> str:
        return "positive: "+str(sorted(self.posState) ) +'\n'+ \
            "negative: "+str(sorted(self.negState)) # Sorted orthography looks better
    
    def unique_representation(self)->str():
        unique_str = json.dumps(sorted(copy.deepcopy(self.posState)))
        return unique_str
    def __hash__(self):
        """A hash value that uniquely identifies a low-order state=>hash(json.dumps(sorted(copy.deepcopy(lowState.posState))))  
         """ #  The _hash__ function's role is to find the location of the bucket, which barrel is the number.
        return hash(self.unique_representation()) # It is equivalent to this when making an x == y comparison hash(x) == hash(y)。

    def __eq__(self, other):
        """
        The only condition that determines whether the lower-order states are equal - hash value comparison
        """
        #  The function __eq__ of the function is that when there is already a ball in the barrel, 
        # but there is another ball, it claims that it should also be put into the barrel 
        # (__hash__ function gives it the position of the barrel), the two sides are deadlocked, 
        # then you have to use the __eq__ function to determine whether the two balls are equal ( equal ), 
        # if the judgment is equal, then the ball should not be put into the bucket later, 
        # the hash set to maintain the status quo.
 
        if isinstance(other, self.__class__):
            return hash(json.dumps(sorted(copy.deepcopy(self.posState)))) == hash(json.dumps(sorted(copy.deepcopy(other.posState))))
        else:
            return False    
        # When the class does not define a __eq__() method, 
        # then it should not define __hash__() method. 
        # If it defines __eq__() method but does not define __hash__() method, then an instance of this class cannot be used in a hashable set. 
        # If a class defines a mutable object (in this case one of the members of the class is a mutable object) and the implement __eq__() method, 
        # then the class should not be __hash__() method, 
        # because the implementation of the hashable object requires that the hash value of the key key be immutable
        #  (if the hash value of an object changes, then it will be placed in the wrong hash bucket)

if __name__ == '__main__':
    pass
    ls2,ls1 = LowState(),LowState()
    ls1.posState = [['act', 'o'], ['act1', 'o23'], ['act3', 'o', 'o2']]
    ls2.posState = [              ['act1', 'o23'], ['act3', 'o', 'o2'],['act', 'o']]
    print(ls1.unique_representation())
    print(ls2.unique_representation())
    print(ls1.__hash__())
    print(ls2.__hash__())
    print(ls1 == ls2)
    test_set = set()
    test_set.add(ls1)
    print(len(test_set))
    if ls2 not in test_set:
        test_set.add(ls2)
    print(len(test_set))


