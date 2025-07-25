#!/usr/bin/env python 
# -*- coding:UTF-8 -*-
from collections import OrderedDict
from constants import * 
from HigState import HigState

class FondDomainAndOrGraph(): 
    """FOND state(initial problem) in the form of 'And/Or Graph(Tree) 
    Reference to the data structure "and-or-tree" definition in pddl-file stored by the tree pruning algorithm, 
    or reference "myND", "PRP", "FOND-SAT" internal parser to read the structure stored in memory, 
    convenient for seamless docking of the FOND-solver.
    """
    def __init__(self,the_initial_HL_state_fond_predicate_order:list()) -> None:
        """
        Fond initial problem, the same as And/Or Graph(Tree) equivalently:
        HL_fond_boolean_semantic_named_features: <virtual_super_source, h_goal_feature, n predicates>
        the 'virtual_start_act':
            map <1,_,...(there are n+1 '_' here)..._,> into set of Classical Planning "Initial HL states" <0,_,..._,>;
            then we delete the first '0' above from <0,_,..._,> to <_,..._,>, 
            and the initial states for each CP in each sufficient Classical Planning Set mapped to HL initial state set(HL_1,...,HL_*)
        'virtual_start_act' = {
            <1,_,..._,>_Bin : {
                set_of_xor_effect_after_'virtual_start_act'(
                    HL_1,
                    ...,
                    HL_*
                )
            }
        }

        there are 2^(1+n) states left in the And/Or Graph of Fond Domain&Porblems  <_,..._,>, 
        Half of total 2^(1+n) HL state, 2^(1+n) <1,...(there are n '_' here)..._,> , 
        states begin with "h_goal_feature = 1" means there are "HL goal states" we want ,
        so we never apply acts to them,which means we need to apply acts to 2^(n) states as follow states:
        
        High level Id for each HL state In decimal:
        'normal_fond_acts' = {
            <0,...(there are totally n '0' in this vector)...,0>_Bin === 0_Dec : {
                # appliable actions
                a_0_1:set(
                    # xor successors effects after apply(HL state '0_Dec','a_0_1')
                    HL state 'xor_successor_1',
                    ...,
                    HL state 'xor_successor_*' 
                    # 2^(1+n) HL states,"h_goal_feature = 1" may happens here
                ),
                a_0_2:set(...),
                ......,
                a_0_*:set(...)
            },
            ......,
            <1,...(there are totally n '1' in this vector)...,1>_Bin === (2^n-1)_Dec : {
                a_(2^n-1)_1:set(...),
                ......
                a_(2^n-1)_*:set(...)
            }
        }
        
        """
        self.HL_fond_boolean_semantic_named_features = the_initial_HL_state_fond_predicate_order #  High-order features OrderedDict.keys()
        self.n:int = len(the_initial_HL_state_fond_predicate_order)-2
        self.initial_states_set = set()
        self.all_HL_normal_fond_acts = dict()
        self.allHighStateCollection = set()
    
    def HL_state_add2_initial_states_set(self,HL_state:HigState()):
        """if HL_state not in initial_states_set, initial_states_set.add(HL_state)."""
        if HL_state not in self.initial_states_set:
            self.initial_states_set.add(HL_state)
    
    def morphism_add2_all_HL_normal_fond_acts(self,morphism:tuple()):
        """
        'morphism' add to 'self.all_HL_normal_fond_acts'
        """
        oldHighState_highStateid = morphism[0]
        act = morphism[1]
        nextHighState_highStateid = morphism[2]
        if oldHighState_highStateid in self.all_HL_normal_fond_acts :
            if act in self.all_HL_normal_fond_acts[oldHighState_highStateid] :
                if nextHighState_highStateid in self.all_HL_normal_fond_acts[oldHighState_highStateid][act]:
                    return # 'morphism' already inside 'self.all_HL_normal_fond_acts' 
                else:
                    self.all_HL_normal_fond_acts[oldHighState_highStateid][act].append(nextHighState_highStateid)
            else:
                self.all_HL_normal_fond_acts[oldHighState_highStateid][act] = [nextHighState_highStateid]
        else:
            self.all_HL_normal_fond_acts[oldHighState_highStateid] = {act:[nextHighState_highStateid]}

    def __str__ (self) -> str:
        return " FOND(NFA) transitive system:\n" + str(self.all_HL_normal_fond_acts)
    
    def __repr__(self) -> str():
        allHighStateCollection_prettystr = str(self.allHighStateCollection)
        all_HL_normal_fond_acts_prettystr = str(self.all_HL_normal_fond_acts)
        return allHighStateCollection_prettystr+'\n'+all_HL_normal_fond_acts_prettystr

    def ifcur_HighState_is_Goal(cur_HighState:HigState())->bool():
        n_add_one:int = self.n + 1
        if cur_HighState.highStateid >= pow(2,(n_add_one)): # Decimal
            # <virtual_start_act = 1,h_goal_feature = _,...(there are total n+1 '_')...>_Bin virtual initial state
            return False
        if cur_HighState.highStateid > pow(2,(self.n-1) ):# Decimal
            # <virtual_start_act = 0,h_goal_feature = 1,...(there are n '_' here)...>_Bin 
            return True
        else:
            return False

if __name__ == '__main__':
    pass







































































