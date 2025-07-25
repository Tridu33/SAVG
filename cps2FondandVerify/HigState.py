#!/usr/bin/env python 
# -*- coding:UTF-8 -*-
from collections import OrderedDict
class HigState():
    def __init__(self) -> None:
        self.highStateid = int()
        self.highPredicates = set()
        self.highState = OrderedDict() # map() : prediacates ==> True/False
        self.fond_predicate_order = []
        self.isInitialState = bool()
        self.isGoalState = bool()
    
    def __repr__(self) -> str:
        return self.highStateid

    def __str__(self) -> str:
        return str(self.highState) + '  ' +str(self.highStateid)
    
    def __hash__(self):
        """The only low-order state hash value is judged => hash(self.highStateid)
         """ # _hash__ The function's role is to find the location of the bucket, which barrel is the number.
        return hash(self.highStateid) #  When making the x == y comparison, it is the equivalent hash(x) == hash(y) equivalent to this.

    def __eq__(self, other):
        """
        The only condition that determines whether the lower-order states are equal - hash value comparison
        """
        if isinstance(other, self.__class__):
            return hash(self.highStateid) == hash(other.highStateid)
        else:
            return False    


    def dumplowlevelCNFfromhighstateId(self)->str():
        condition_str = "(and "
        for each,boolValue in self.highState.items():
            if (boolValue == True):
                condition_str += '('+str(each)+') ' 
            else: # (boolValue == False)
                condition_str += '(not' + '('+str(each)+')' + ') ' 
        condition_str += ')'
        return condition_str


if __name__ == '__main__':
    pass


