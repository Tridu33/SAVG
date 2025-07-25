#!/usr/bin/env python 
# -*- coding:UTF-8 -*- 
import copy,os,re,itertools,json
from constants import * 
try:
    import reduce
except:
    from functools import reduce
from HigState import HigState
from LowState import LowState
from T9backtracking import T9backtracking
from FondDomainAndOrGraph import FondDomainAndOrGraph


class Simulator():
    def __init__(self,parser) -> None:
        self.parser = parser

        self.all_state_set = set() #= final done_set " high states with given features mapping " when : BFS traverse from cur initial start state
        self.all_high_level_action_pair_from_low_BFS = set() # <pre state, low action name, the single eff state>
        # we merge triples above into this following:
        self.final_fond_action_pairs =set() # lowactionname_startid_endid1_endid2_..._endid_n : <pre state, many eff states>
        
        return


    def updateLowState_add_del(self,curlowState:LowState(),add_effect_list:list(),del_effect_list:list())->LowState():
        nextlowState = copy.deepcopy(curlowState)
        def updateLowState_add(curLowState_local,add_effect_list):
            if (add_effect_list[0][0] == 'when'):
                for index in range(0,len(add_effect_list)):
                    eachwhenitem = add_effect_list[index]
                    if eachwhenitem[1][0] != 'and' or eachwhenitem[2][0] != 'and':
                        raise Exception("wrong when Effect format in pddl file.") 
                    whensituation = eachwhenitem[1][1:] #  [0] is 'and'
                    allfit = False
                    for sentencefit in whensituation:# find every sentence fitted in when situation
                        if sentencefit in curLowState_local.posState:
                            if index == (len(whensituation)-1):
                                allfit = True
                                break
                            continue
                        else:# not in means this whenitem do not fit current low state,try next
                            break
                    if (allfit == True):
                        wheneffect = eachwhenitem[2][1:] # [0] is 'and'
                        for each_pos_sentence in wheneffect:
                            if each_pos_sentence[0] != 'not':
                                # add in new pos sentence truth
                                if each_pos_sentence not in curLowState_local.posState:
                                    nextlowState.posState.append(each_pos_sentence)
                                if each_pos_sentence in curLowState_local.negState:
                                    nextlowState.negState.remove(each_pos_sentence)
                            else : # each_pos_sentence[0] !='not'
                                if each_pos_sentence[1] not in curLowState_local.negState:
                                    nextlowState.negState.append(each_pos_sentence[1])
                                if each_pos_sentence[1] in curLowState_local.posState:
                                    nextlowState.posState.remove(each_pos_sentence[1])
                        # only one situation fit cur low state, break after once change
                        break 
            else:# 'and'
                for sentence in add_effect_list:
                    if sentence[0] != 'not':
                        # add in new pos sentence truth
                        if sentence not in curLowState_local.posState:
                            nextlowState.posState.append(sentence)
                        if sentence in curLowState_local.negState:
                            nextlowState.negState.remove(sentence)
                    else : # each_pos_sentence[0] =='not'
                        if sentence[1] not in curLowState_local.negState:
                            nextlowState.negState.append(sentence[1])
                        if sentence[1] in curLowState_local.posState:
                            nextlowState.posState.remove(sentence[1])
        def updateLowState_del(curLowState_local,del_effect_list):
            if (del_effect_list[0][0] == 'when'): # never comes here because 'when' will always happen in 'add_effect' in code logic before
                for index in range(0,len(del_effect_list)):
                    eachwhenitem = del_effect_list[index]
                    if eachwhenitem[1][0] != 'and' or eachwhenitem[2][0] != 'and':
                        raise Exception("wrong when Effect format in pddl file.") 
                    whensituation = eachwhenitem[1][1:] #  [0] is 'and'
                    allfit = False
                    for sentencefit in whensituation:# find every sentence fitted in when situation
                        if sentencefit in curLowState_local.posState:
                            if index == (len(whensituation)-1):
                                allfit = True
                                break
                            continue
                        else:# not in means this whenitem do not fit current low state,try next
                            break
                    if (allfit == True):
                        wheneffect = eachwhenitem[2][1:] # [0] is 'and'
                        for each_pos_sentence in wheneffect:
                            if each_pos_sentence[0] != 'not':
                                # add in new pos sentence truth
                                if each_pos_sentence not in curLowState_local.posState:
                                    nextlowState.posState.append(each_pos_sentence)
                                if each_pos_sentence in curLowState_local.negState:
                                    nextlowState.negState.remove(each_pos_sentence)
                            else : # each_pos_sentence[0] =='not'
                                if each_pos_sentence[1] not in curLowState_local.negState:
                                    nextlowState.negState.append(each_pos_sentence[1])
                                if each_pos_sentence[1] in curLowState_local.posState:
                                    nextlowState.posState.remove(each_pos_sentence[1])
                        # only one situation fit cur low state, break after once change
                        break 
            else:# 'and'
                for sentence in del_effect_list:
                    if sentence[0] != 'not':
                        # del in new pos sentence truth
                        if sentence in curLowState_local.posState:# Text to be deleted In the text, delete
                            nextlowState.posState.remove(sentence)
                        if sentence not in curLowState_local.negState:
                            nextlowState.negState.append(sentence)
                    else : # each_pos_sentence[0] =='not' # act.del_effects there is no not beginning and should not be entered here.
                        raise Exception("Wrong entry act.del_effects there is no not beginning and should not be entered here.")
                        # if sentence[1] in curLowState_local.negState:
                        #     nextlowState.negState.append(sentence[1])
                        # if sentence[1] in curLowState_local.posState:
                        #     nextlowState.posState.remove(sentence[1])            

        if (add_effect_list!= [] and del_effect_list != []):
            # add_effect_list
            updateLowState_add(nextlowState,add_effect_list)
            # del_effect_list
            updateLowState_del(nextlowState,del_effect_list)
        elif (add_effect_list== [] and del_effect_list != []):
            # add_effect_list
            pass
            # del_effect_list
            updateLowState_del(nextlowState,del_effect_list)
        elif (add_effect_list!= [] and del_effect_list == []):
            # add_effect_list
            updateLowState_add(nextlowState,add_effect_list)
            # del_effect_list
            pass
        elif (add_effect_list== [] and del_effect_list == []):
            pass
        else :
            raise Exception("wrong")
        return nextlowState
    def update(self,curLowState,ai):
        newLowState = LowState()
        curlowpos = curLowState.posState
        action_name = ai[0]
        action_args = ai[1:]
        for act in self.parser.actions:
            if (action_name == act.name):
                variables2ai = {}
                if(len(act.parameters) != len(action_args)):
                    raise Exception('len(act.parameters) != len(action_args)')
                for index in range(0,len(act.parameters)):
                    variables2ai[act.parameters[index][0]] = action_args[index]
                add_effect_list_old = act.add_effects
                add_effect_list_str = str(add_effect_list_old)
                for v,ai in variables2ai.items():
                    add_effect_list_str = add_effect_list_str.replace('\''+v+'\'','\''+ai+'\'') 
                add_effect_list = eval(add_effect_list_str)
                
                del_effect_list_old = act.del_effects # 'and'
                del_effect_list_str = str(del_effect_list_old)
                for v,ai in variables2ai.items():
                    del_effect_list_str = del_effect_list_str.replace('\''+v+'\'','\''+ai+'\'') 
                del_effect_list = eval(del_effect_list_str)
                nextLowState = self.updateLowState_add_del(curLowState,add_effect_list,del_effect_list)
                return nextLowState
        return newLowState
    def parse_quantifier_objs2map(self,strobjs)->{}:
        parameters = {}
        untyped_parameters = []
        p = strobjs
        while p:
            t = p.pop(0)
            if t == '-':
                if not untyped_parameters:
                    raise Exception('Unexpected hyphen in ' + tc_name + ' parameters')
                ptype = p.pop(0)
                while untyped_parameters:
                    OneOfUntyped_variableslist = untyped_parameters.pop(0)
                    parameters[OneOfUntyped_variableslist]=ptype
            else:
                untyped_parameters.append(t)
        while untyped_parameters:
            OneOfUntyped_variableslist = untyped_parameters.pop(0)
            parameters[OneOfUntyped_variableslist]='object'
        return parameters
    def sort2objsSet(self,obj2sort):
        sort2bjs = {}
        sortSet = set(obj2sort.values())
        for sort in sortSet:
            sort_mapped_set = set()
            for obj,s in obj2sort.items():
                if(sort==s):
                    sort_mapped_set.add(obj)
            sort2bjs[sort] = sort_mapped_set
        return sort2bjs
    

    # data = [1, 2, 3, 4, 5, 6]
    # l The number of elements to output per group, step cursor
    def combine(self,dataset, l):
        """
        The number of combinations of n unknown variables taken out of the current type in fml enumeration case
        """
        data = list(dataset)
        result = []
        combineresult = []
        tmp = [0]*l
        length = len(data)
        def next_num(li=0, ni=0):
            if ni == l:
                combineresult.append(copy.copy(tmp))
                return
            for lj in range(li,length):
                tmp[ni] = data[lj]
                next_num(lj+1, ni+1)
        next_num() 
        for arr in combineresult:
            restuplelists = list(itertools.permutations(arr)) # The full permutation of the number of combinations of n unknown variables
            reslists = []
            for each in restuplelists:
                reslists.append(list(each))
            result += reslists
            # print()
            # print(result)
            # print()
        return result
    # combine(data,3)
    

    def fmlsatlowState(self,curLowStateobj,unchanged_fml,curp)->bool():
        fml = copy.deepcopy(unchanged_fml)
        curLowStatePos = curLowStateobj.posState
        curLowStateNeg = curLowStateobj.negState
        def lists_combination(lists, code=''):
            '''
            Enter a list composed of multiple lists, processing all possible permutations of all elements of each list
            '''            
            def myfunc(list1, list2):
                return [i+j for i in list1 for j in list2]
            return reduce(myfunc, lists) 
        def replaceList(fml_list,arg_u,arg_real):
            for elements in fml_list:
                if isinstance(elements,list) or isinstance(elements, tuple): 
                    replaceList(elements,arg_u,arg_real) # The recursive call function itself performs a deep traversal
                elif isinstance(elements, dict):
                    for elekey,elevalue in elements.items():
                        elekey.replace(arg_u,arg_real)
                        elevalue.replace(arg_u,arg_real)
                        print(elekey,elevalue)
                else:
                    elements = elements.replace(arg_u,arg_real)
                    print(elements)
            return fml_list
        def ifStrlistEqual(l1,l2)->bool():
            if len(l1) != len(l2):
                return False
            for i in range(0,len(l1)):
                if l1[i] != l2[i]:
                    return False
            return True# Exactly equal is true
        def eachIsStr(listinput:list())->bool():
            for each in listinput:
                if type(each) == str:
                    continue
                else:
                    return False
            return True
        
        def fmltrySATIncurLowState_pos(fmltrypos,curLowStatePos)->bool():
            if len(fmltrypos) == 0:
                return True
            for each_pos_fact in fmltrypos:
                if each_pos_fact in curLowStatePos:
                    continue
                else:
                    return False # fmltry: Each pos orthographic fact sentence needs to be in the curLowPos orthographic knowledge base
            return True
        def  fmltrySATIncurLowState_neg(fmltryneg,curLowStatePos,curLowStateNeg)->bool():
            if len(fmltryneg) == 0:
                return True
            for each_neg_fact in fmltryneg:
                # fmltry  Each neg negative text fact sentence is either in the curLowNeg negative text knowledge base or not in the negative text knowledge base (omitted not written out)
                # Anyway, it can't appear in the orthographic knowledge base curLowStatePos
                if each_neg_fact not in curLowStatePos:
                    continue
                else:
                    return False 
            return True

        def fmltrySATIncurLowState(fmltry,curLowStatePos,curLowStateNeg)->bool():
            fmltryneg = []
            fmltrypos = []
            if fmltry[0] == 'or':
                onceTrueBeTrue = False
                for each_f in fmltry[1:]:
                    if each_f[0] == '=':
                        if each_f[1] == each_f[2]:
                            onceTrueBeTrue = True
                            return True
                    elif each_f[0] == 'not': #
                        if each_f[0][0] == '=': # Equal sign predicates, where there needs to be no equality
                            if each_f[1] != each_f[2]:
                                onceTrueBeTrue = True
                                return True
                        else:# General predicates each_f ['not',[predicates, arguments]] # No longer expand here to handle not(not) nesting # It is best to use recursion, here is not written as a self function, the number of layers is generally not too deep
                            if each_f[1] not in curLowStatePos:# Negative text Takes the positive part, if not in the positive text, the description is either negative or closed world as negative. "Negative text can be satisfied by the environment to return to truth"
                                return True 
                    else: # General predicates , positive literal
                        if each_f in curLowStatePos:
                            return True
                if onceTrueBeTrue == False:
                    return False #
            elif fmltry[0] == 'and':
                fmltry = fmltry[1:]#  Traversing or every word cannot be satisfied by the environment, indicating that the current environment does not meet this dissective paradigm formula
                for each in fmltry:
                    if each[0] == 'not':
                        fmltryneg.append(each[1])
                    else:
                        fmltrypos.append(each)
            

            elif len(fmltry)==1 and type(fmltry) == type([]):
                if fmltry[0][0] == 'not':
                    fmltryneg.append(fmltry[0])
                else:
                    fmltrypos.append(fmltry[0])
            else: # Common predicates with references [clear , A] [holding , y]
                if fmltry in curLowStatePos:
                    return True
                else: 
                    return False
            boolPos = fmltrySATIncurLowState_pos(fmltrypos,curLowStatePos)
            boolNeg = fmltrySATIncurLowState_neg(fmltryneg,curLowStatePos,curLowStateNeg)
            if boolNeg and boolPos:
                return True
            else:
                return False
            # if  type(fmltry[0]) == list and fmltry[0][0] != 'not':
            #     for thm in fmltry:
            #         ifthmcanfindEqualStr = False
            #         for eachsentence in curLowStatePos:
            #             if not ifStrlistEqual(thm,eachsentence):
            #                 continue
            #             else:
            #                 ifthmcanfindEqualStr = True
            #                 break
            #         if (ifthmcanfindEqualStr == False): 
            #             #  As long as you find a formula in fml, you still can't find a perfectly equivalent of the current curlLowStatePos low-order fact set, the formula is not satisfied
            #             return False
            #     return True
            #     # for thm in fmltry, The formula thm in each fml in the loop can be satisfied at curllowsatte, and no False can be said to satisfy the cff conjugation paradigm
            # elif type(fmltry[0]) == list and fmltry[0][0] == 'not':
            #     neg_fmltry = fmltry[0][1]
            #     if fmltrySATIncurLowState(neg_fmltry,curLowStatePos,curLowStateNeg):
            #         return False
            #     else:
            #         return True
            # elif type(fmltry) == list and eachIsStr(fmltry) and fmltry[0] != 'not':
            #     # simple positive sentive,with pure string element in list
            #     if fmltry in curLowStatePos:
            #         return True
            #     else:
            #         return False
            # else:# fmltry[0][0] == 'not'
            #     print("unknown fmltry in function fmltrySATIncurLowState")
            #     return False
        
        def getallunknown2objects(fml):
            str_objs = fml.pop(0)
            # the specific sort2objs variables
            obj2sort = self.parse_quantifier_objs2map(str_objs)
            sort2objs = self.sort2objsSet(obj2sort)
            # get all sort2objs
            constants2sort = self.parser.constants
            sort2constants = self.sort2objsSet(constants2sort)
            all_objs = {}
            for s in self.parser.types:
                all_objs[s] ={}
            all_objs.update(sort2constants)
            for sort,objlist in curp.objects.items():
                objectsSet = set()
                for o in objlist:
                    objectsSet.add(o)
                olddict2set = set(all_objs[sort]) # dict2set
                sumSet = olddict2set.union(objectsSet)
                all_objs[sort] = sumSet
            # get obj->type from parser and tranverse
            args_variables_enumeration = []
            args_variables_sort = [] # the right order here
            for fmlsort,_ in sort2objs.items():
                n = len(sort2objs[fmlsort])#  The number of permutations of n unknown variables taken out of the current type
                for asort,aobjset in all_objs.items():# one true it true and throw out
                    if(asort == fmlsort):
                        cur_sort_combine_list = self.combine(aobjset, n) # The number of combinations of n unknown variables is taken out of the current type in fml and then the number of the enumeration case is arranged
                        args_variables_sort.append(fmlsort)
                        args_variables_enumeration.append(cur_sort_combine_list)
                        break
            unknown_args2args_variables_enumeration_list = []
            def findindexofsort(fmlsort,args_variables_sort):
                index = 0
                for i in range(0,len(args_variables_sort)):
                    if(fmlsort == args_variables_sort[i]):
                        index = i
                        break
                return index
            for fmlsort,unknown_argset in sort2objs.items():
                index = findindexofsort(fmlsort,args_variables_sort)
                cursort_args_variables_enumeration_list = args_variables_enumeration[index]
                cursortmapping = []
                for c_a_v_e in cursort_args_variables_enumeration_list:
                    unknown_args2enumerative_args = list(zip(list(unknown_argset),c_a_v_e))
                    # print(unknown_args2enumerative_args)
                    cursortmapping.append(unknown_args2enumerative_args)
                unknown_args2args_variables_enumeration_list.append(cursortmapping)
            
            allunknown2objects = lists_combination(unknown_args2args_variables_enumeration_list) 
            return allunknown2objects
        
        
        res = False # default
        quantifier = fml.pop(0)
        if quantifier == 'exists':
            allunknown2objects = getallunknown2objects(fml)
            for allmaponetry in allunknown2objects:
                newfmlstr = str(fml)
                for eachtuplemap in allmaponetry:
                    arg_unknown = eachtuplemap[0]
                    arg_try = eachtuplemap[1]
                    # replaceList(fml,arg_unknown,arg_try) 
                    newfmlstr = newfmlstr.replace(arg_unknown,arg_try) 
                fmltry = eval(newfmlstr)
                # exists 
                if fmltrySATIncurLowState(fmltry[0],curLowStatePos,curLowStateNeg):
                    return True # Existence, one truth, return to truth
                else :
                    continue
            return False # Iterate through all possibilities, or can't find it as false
        elif quantifier == 'forall':
            allunknown2objects = getallunknown2objects(fml) 
            # one wrong all wrong and throw out
            for allmaponetry in allunknown2objects:
                newfmlstr = str(fml)
                for eachtuplemap in allmaponetry:
                    arg_unknown = eachtuplemap[0]
                    arg_try = eachtuplemap[1]
                    # replaceList(fml,arg_unknown,arg_try) 
                    newfmlstr = newfmlstr.replace(arg_unknown,arg_try) 
                fmltry = eval(newfmlstr)
                # exists As if there is a problem, what needs to be traversed is that all objects of this type combining Cartesian product can meet the need to support sentences
                if fmltrySATIncurLowState(fmltry[0],curLowStatePos,curLowStateNeg):
                    continue# The present moment is content
                else:
                    return False # There is a "combination of variables tentatively tested for a given type" that is not satisfied, one false, and false
            return True# Iterates through all the possibilities, still can not find the unsatisfied explanation, res is still the initial value, the statement is true
        elif quantifier == 'and':            # others
            # for task in fml:# for 'and' cnf, one wrong all wrong
            firstbool = fmltrySATIncurLowState(fml,curLowStatePos,curLowStateNeg)
            if(firstbool == False): # cnf, one wrong all wrong
                    return False
            for eachfml in fml[1:]:
                boolforeachfml = fmltrySATIncurLowState(eachfml,curLowStatePos,curLowStateNeg) #self.fmlsatlowState(curLowStateobj,eachfml,curp)
                if(boolforeachfml == False): # cnf, one wrong all wrong
                    return False
            return True
        elif len(fml) == 0:
            # Unary predicates
            if list(quantifier) in curLowStatePos:
                return True
            else:
                return False
            
        else: 
            # print(quantifier,fml,": the same fond predicate interpretation for cur low level state")
            fml.insert(0,quantifier)
            if fml in curLowStatePos:
                return True
            else:
                return False
        return res

    def lowState2highState(self,curLowState,curp,if_vStart = ''):
        highState = HigState() # map() : predicates ==> True/False
        isInitialState = True
        # isInitialState The messenger tells whether it is the first state
        if if_vStart == 'vStart' :
            highState.highState['vStart'] = True
            isInitialState = True
        else:
            highState.highState['vStart'] = False
            isInitialState = False
        # all in will be True,else False, It is possible to do a certain action to restore (refer back) to the initial state, you need to judge:
        #  The current problem initial negative text in the negative text of the environment snapshot;
        # for curp_neg in curp.negative_initialstate:
        #     if curp_neg not in curLowState.negState:
        #         isInitialState = False
        # The current problem is in the orthography of the environment snapshot.
        # for curp_pos in curp.positive_initialstate:
        #     if curp_pos not in curLowState.posState:
        #         isInitialState = False
        highState.isInitialState = isInitialState
        # 'VGoal' means the set of Goal state for every classical planning problem instance
        curp_positive_goals_ALLIN_curLowState_posState = True
        for each_positive_goal in curp.positive_goals: 
            if each_positive_goal not in curLowState.posState:
                curp_positive_goals_ALLIN_curLowState_posState = False
                break
        curp_negative_goals_ALLNOTIN_curLowState_negState = True
        for each_negative_goal in curp.negative_goals:
            if each_negative_goal in curLowState.posState:
                curp_negative_goals_ALLNOTIN_curLowState_negState = False
                break
        if curp_positive_goals_ALLIN_curLowState_posState == True and curp_negative_goals_ALLNOTIN_curLowState_negState == True: 
            highState.highState['vGoal'] = True
        else:
            highState.highState['vGoal'] = False

        # fond_predicate_order
        fond_predicate_order = ['vStart','vGoal'] 
        for fond_predicate,fml in self.parser.fond_predicates.items():
            fond_predicate_order.append(fond_predicate)
            if self.fmlsatlowState(curLowState,fml,curp):
                highState.highState[fond_predicate] = True
            else:
                highState.highState[fond_predicate] = False
        highState.fond_predicate_order = fond_predicate_order
        curid = 0
        bit_offset = 1
        pow2 = 1 << len(highState.highState.values())
        for fond_predicate,v in highState.highState.items():
            if(v):
                curid += (1)* (pow2 >> bit_offset) 
            else:
                curid += (0)* (pow2 >> bit_offset)
            bit_offset += 1
        highState.highStateid = curid
        
        # isGoalState
        isGoalState = True
        # all in will be True,else False
        for curp_neg in curp.negative_goals:
            if curp_neg not in curLowState.negState:
                isGoalState = False
        for curp_pos in curp.positive_goals:
            if curp_pos not in curLowState.posState:
                isGoalState = False
        highState.isGoalState = isGoalState
        return highState
    
    def enumerate_all_vars2objs_and_constants(self,p,act_parameters,type2vars_list,parameter_vars)->list():
        def get_unknown_vars_order(act_parameters)->[]:
            unknown_vars_order = []
            for each in act_parameters:
                unknown_vars_order.append(each[0]) 
            return unknown_vars_order
        def combination_of_typemaps_and_permutation_each_typemap_for_var_specialization2objs(\
                unknown_vars_order,\
                type2vars_list,\
                type2set_of_cons_and_objs)->dict():
            """
                Each type enumerates a map and then consolidates it into all_unknown_vars2objs_and_cons_enumerate:
                for example:
                    t(ype)1 - ?v(ariable)1,?v2 && t(ype)1 - o(bject)1,o2,o3
                    t2      - ?v3,?v4          && t2      - o4,o5
                    t3      - ?v6              && t3      - o6
                (1). we get "permutation_each_typemap_for_var_specialization2objs"
                t1:6 = permutation(2,3)= [
                    {v1->o1;v2->o2},
                    {v1->o2;v2->o1},
                    {v1->o1;v2->o3},
                    {v1->o3;v2->o1},
                    {v1->o2;v2->o3},
                    {v1->o3;v2->o2},
                ]
                t2:2 = permutation(2,2)= [
                    {v3->o4;v4->o5},
                    {v3->o5;v4->o4},
                ]
                t3:1 = permutation(1,1)= [
                    {v6->o6}
                ]
                
                (2). "combination_of_typemaps" for each type like "t1,t2,t3"
                all_unknown_vars2objs_and_cons_enumerate: len(t1)*len(t2)*len(t3) 
                = 6*2*1 = {
                    {v1->o1;v2->o2}+{v3->o4;v4->o5}+{v6->o6}
                    ...,
                    {v1->o3;v2->o2}+{v3->o5;v4->o4}+{v6->o6}
                }
            """
            # (1). we get "permutation_each_typemap_for_var_specialization2objs"
            all_types_type2vars_map = dict() # {t1:[{v1->o1;v2->o2}, ...], ...} etc. 
            for cur_type,vars_list_for_cur_type in type2vars_list.items():
                cur_type_vars_cnt = len(vars_list_for_cur_type) # number of vars_list_for_cur_type
                cur_type_objs = type2set_of_cons_and_objs[cur_type]

                cur_type_vars2objs_permutation = list()
                cur_type_vars2objs_permutation_list = list( itertools.permutations(cur_type_objs,cur_type_vars_cnt) )
                for cur_permulation in cur_type_vars2objs_permutation_list:
                    cur_type_vars2objs = dict() # {v1->o1;v2->o2} etc. 
                    for each_index in range(0,cur_type_vars_cnt):
                        each_var = vars_list_for_cur_type[each_index]
                        each_obj = cur_permulation[each_index]
                        cur_type_vars2objs[each_var] = each_obj
                    cur_type_vars2objs_permutation.append(cur_type_vars2objs)
                all_types_type2vars_map[cur_type] = cur_type_vars2objs_permutation
            # (2). "combination_of_typemaps" for each type like "t1,t2,t3"
            # unknown_vars_order
            all_unknown_vars2objs_and_cons_enumerate = dict()
            tmp_unknown_vars2objs_and_cons_enumerate = dict()
            # algorithm for T9 input method (combination for arbitory loop
            
            sol = T9backtracking(all_types_type2vars_map)
            all_types_random_order_is_the_same = []
            for each_char in all_types_type2vars_map.keys():
                all_types_random_order_is_the_same.append(each_char) 
            all_unknown_vars2objs_and_cons_enumerate = sol.letterCombinations(all_types_random_order_is_the_same)
            # print(all_unknown_vars2objs_and_cons_enumerate)
            return all_unknown_vars2objs_and_cons_enumerate
        
        # --------------------------------------------------------
        unknown_vars_order = get_unknown_vars_order(act_parameters)
        # Merge objs and type2cons to get "type2set_of_cons_and_objs"
        type2cons = {}
        for varname,vartype in self.parser.constants.items():
            if vartype not in list(type2cons): # make acopy for type2cons.keys()
                initialvarnameslist = []
                initialvarnameslist.append(varname)
                type2cons[vartype] = initialvarnameslist # change type2cons when reverse it's old copy
            else: #  in 
                initialvarnameslist = type2cons[vartype]
                initialvarnameslist.append(varname) 
        type2set_of_cons_and_objs = {}
        type2objs = p.objects
        for con_type,conslist in type2cons.items():
            curtype = con_type
            cur_set_of_cons_and_objs = set()
            if con_type in type2objs.keys():
                for each in type2objs[con_type]:
                    conslist.append(each)
                cur_set_of_cons_and_objs = conslist
            else:
                cur_set_of_cons_and_objs = conslist
            type2set_of_cons_and_objs[curtype] = cur_set_of_cons_and_objs
        type_in_objs_not_in_cons = set(type2objs.keys()) - set(type2cons.keys())
        for each_type_in_objs_not_in_cons in type_in_objs_not_in_cons:
            type2set_of_cons_and_objs[each_type_in_objs_not_in_cons] = type2objs[each_type_in_objs_not_in_cons]
        # "type2set_of_cons_and_objs" got above
        
        # Each type enumerates a map and then consolidates it into all_unknown_vars2objs_and_cons_enumerate
        all_unknown_vars2objs_and_cons_enumerate = \
            combination_of_typemaps_and_permutation_each_typemap_for_var_specialization2objs(\
                unknown_vars_order,\
                type2vars_list,\
                type2set_of_cons_and_objs)
        return all_unknown_vars2objs_and_cons_enumerate

    def getsubHLactions(self,p,whole_merged_all_sub_fond_domain_and_or_graph,empty_sub_fond_graph):
        cur_sub_fond_graph = empty_sub_fond_graph
        if DEBUG:
            print("\npositive_initialstate and negative_initialstate")
        def get_all_appliable_successors(oldLowState,act,p):
            pos_satify = True
            type2vars_list = {} #  specific objects in oldLowState ==>  Variant with '?' specialization 
            for tuple_for_cur_var in act.parameters:
                vartype = tuple_for_cur_var[1]
                if vartype not in list(type2vars_list): # make acopy for type2vars_list.keys()
                    varname = tuple_for_cur_var[0]
                    initialvarnameslist = []
                    initialvarnameslist.append(varname)
                    type2vars_list[vartype] = initialvarnameslist # change type2vars_list when reverse it's old copy
                else:
                    varname = tuple_for_cur_var[0]
                    initialvarnameslist = type2vars_list[vartype]
                    initialvarnameslist.append(varname)

            parameter_vars = []
            for t,vs in type2vars_list.items():
                parameter_vars+=list(vs)
                parameter_vars.append('-')
                parameter_vars.append(t)
            
            # enumerate all vars2objs-and-constants Variable specialization for "act.parameters":
            all_enumerate = self.enumerate_all_vars2objs_and_constants(p,act.parameters,type2vars_list,parameter_vars)
            # check if the Env-snapshot satify the *_fml of current action's precondition:
            appliable_vars_specifition_for_curlowState_act_map2_successor_lowStates = dict()
            # var_specification ==> successor_lowState
            has_at_least_one_successor = False
            def cur_var_specification_in_List(cnf:list(),var_specification):
                def replace_cur_f_with_cur_var_specification(each_f,var_specification)->list():
                    for index in range(0,len(each_f)):
                        each_str = each_f[index]
                        for cur_var,cur_specification in var_specification.items():
                            if each_str == cur_var:# variables
                                each_f[index] = cur_specification  # var specification
                    return each_f
                # 
                cnf_cp = []
                for each_f in cnf:
                    new_each_f = replace_cur_f_with_cur_var_specification(each_f,var_specification)
                    cnf_cp.append(new_each_f)
                return cnf_cp
            def fml_list_not_in_LowState_nestedlist(each_f,LowState)->bool():
                for each_truth_sentence in LowState:
                    if each_f == each_truth_sentence:
                        return False
                return True
            def fml_list_in_LowState_nestedlist(each_f,LowState)->bool():
                for each_truth_sentence in LowState:
                    if each_f == each_truth_sentence:
                        return True
                return False
            for var_specification in all_enumerate:
                cur_appliable_means_has_successor = False
                cnf_positive_preconditions = copy.deepcopy(act.positive_preconditions)
                cnf_negative_preconditions = copy.deepcopy(act.negative_preconditions)
                successor_lowState = copy.deepcopy(oldLowState)
                
                # 1. pos_fml should be : 
                    #    ['exists',['?x', '?y', '-', 'node'],['and',[..],[..], ..., [..]]] 
                    #       where map '?'vars sepcific objects for the types
                    #              pos "cnf" is all "inside the posState truth sentences set"
                cnf_positive_preconditions = cur_var_specification_in_List(cnf_positive_preconditions,var_specification)
                default_all_pos_in_pos = True
                for each_posf in cnf_positive_preconditions:
                    if len(each_posf) == 3 and (each_posf[0] == '=' or each_posf[0] == '=='):
                        if each_posf[2]  != each_posf[1] :
                            default_all_pos_in_pos = False #  You want the variable specialization result the_diff_var_specific_obj to be equal to the object the_var_specific_obj in the real environment, but not equal, and returns false
                            break
                        else:
                            continue
                    else: # normal sentence descripts the positive fact
                        if fml_list_not_in_LowState_nestedlist(each_posf, oldLowState.posState):
                            default_all_pos_in_pos = False #  As long as there is a each_posf does not return False at postState
                            break
                        else:
                            continue

                # 2. neg_fml should be : 
                    #    ['forall',['?x', '?y', '-', 'node'],['and',['not',..],['not',..], ..., ['not',..]]] 
                    #       where map '?'vars 2 types, 
                    #             neg "cnf" is all not "not in the posState truth" === "inside the neg truths"/"not in the pos trut and not in the neg truth set"
                cnf_negative_preconditions = cur_var_specification_in_List(cnf_negative_preconditions,var_specification)
                default_all_neg_not_in_pos = True
                for each_negf in cnf_negative_preconditions:
                    if len(each_negf) == 3 and (each_negf[0] == '=' or each_negf[0] == '=='):
                        if each_negf[2] != each_negf[1]:
                            continue
                        else:
                            default_all_pos_in_pos = False # You want the variable to be specialized the_diff_var_specific_obj not equal to the object the_var_specific_obj in the real environment, but equal and returns false
                            break
                    else:# normal sentence descripts the positive fact
                        if fml_list_in_LowState_nestedlist(each_negf, oldLowState.posState):
                            default_all_neg_not_in_pos = False #  As long as there is a each_negf return False in posState
                            break
                        else:
                            continue
                # 3. if 'act' appliable "oldLowState", get the "successor_lowState" and mark the result
                if default_all_pos_in_pos==True and default_all_neg_not_in_pos==True: # pos_fml and neg_fml
                    if has_at_least_one_successor == False:
                        has_at_least_one_successor = True
                    cur_appliable_means_has_successor = True
                    add_effects = copy.deepcopy(act.add_effects)
                    add_effects = cur_var_specification_in_List(add_effects,var_specification)
                    del_effects = copy.deepcopy(act.del_effects)
                    del_effects = cur_var_specification_in_List(del_effects,var_specification)
                    
                    for each_add_f in add_effects:
                        if each_add_f not in successor_lowState.posState:
                            successor_lowState.posState.append(each_add_f)
                        if fml_list_in_LowState_nestedlist(each_add_f, successor_lowState.negState):
                            # remove 'each_add_f'
                            for each in successor_lowState.negState:
                                if each == each_add_f:
                                    successor_lowState.negState.remove(each)
                    for each_del_f in del_effects:
                        successor_lowState.negState.append(each_del_f)    # can do this,For the sake of safety. We also can do not do this because "Closed-world assumption"
                        if fml_list_in_LowState_nestedlist(each_del_f, successor_lowState.posState):# must inside when satisfy the act's "precondition", need not to check whether inside
                            # remove 'each_del_f'
                            for each in successor_lowState.posState:
                                if each == each_del_f:
                                    successor_lowState.posState.remove(each)
                    # json_str=json.dumps(data)  # Dictionary conversion to string hashable
                    # d=json.loads(json_str) # The string is converted to a dictionary
                    appliable_vars_specifition_for_curlowState_act_map2_successor_lowStates[\
                        json.dumps(copy.deepcopy(var_specification))] = successor_lowState
                        
            return has_at_least_one_successor,appliable_vars_specifition_for_curlowState_act_map2_successor_lowStates # def act_appliable(oldLowState,act,p):
        
        def highStateid_notin_HighStateCollection(highStateid,allHighStateCollection)->bool:
            for each in allHighStateCollection:
                if each == highStateid:
                    return False
            return True
        
        def morphism_notin_h_sub_all_high_level_action_pair_from_low_BFS(morphism,h_sub_all_high_level_action_pair_from_low_BFS)->bool:
            for each in h_sub_all_high_level_action_pair_from_low_BFS:
                if  each[0] == morphism[0] and \
                    each[1] == morphism[1] and \
                    each[2] == morphism[2]:
                    return False
            return True

        # ================================================= simulator begin 
        # High level:
        h_sub_all_state_set = set() #= final done_set "high states with given features mapping " when : BFS traverse from cur initial start state
        h_sub_all_high_level_action_pair_from_low_BFS = set() # <pre state, low action 2 high level morphism, the single eff state>
        # we merge triples above into this following:
        h_sub_final_fond_action_pairs =set() # lowactionname_startid_endid1_endid2_..._endid_n : <pre state, many eff states>
        
        # Low level:
            # low_done_states       | nodes have seen and do not need try 'acts' again(etc.Goal & DeadEnd)
            # low_edges_states      | nodes in the edges where being current visited
            # low_front_next_states | nodes unvisited but touchable with a step appliable action from edges_state_nodes(edges_states)
        low_done_states,low_edges_states,low_front_next_states = set(),set(),set()
        
        the_initial_state_low = LowState()
        the_initial_state_low.posState = p.positive_initialstate
        the_initial_state_low.negState = p.negative_initialstate
        low_edges_states.add(the_initial_state_low) # low_edges_states.add(json.dumps(sorted(copy.deepcopy(the_initial_state_low.posState))))

        the_initial_state_hig = HigState()
        the_initial_state_hig = self.lowState2highState(the_initial_state_low,p,'vStart')
        if the_initial_state_hig.isInitialState != True:
            raise "Error:the_initial_state_hig.isInitialState != True"

        the_initial_state_hig_vStart_False = HigState()
        the_initial_state_hig_vStart_False = self.lowState2highState(the_initial_state_low,p)
        whole_merged_all_sub_fond_domain_and_or_graph.HL_state_add2_initial_states_set(the_initial_state_hig_vStart_False.highStateid)
        cur_sub_fond_graph.HL_state_add2_initial_states_set(the_initial_state_hig_vStart_False.highStateid)

        if DEBUG:
            print(the_initial_state_low) # the initial state hig vStart=True
            print(the_initial_state_hig)
            print(the_initial_state_hig_vStart_False) # the initial state hig vStart=False
        
        # modify 'whole_merged_all_sub_fond_domain_and_or_graph', merge it with 'cur_sub_fond_graph'
        low_edges_states_remove_list = set()
        while len(low_edges_states) > 0:# front is "Goal" or "deadend"(will not appliable and has no next low state)
            for del_low_state in low_edges_states_remove_list:
                if del_low_state in low_edges_states:
                    low_edges_states.remove(del_low_state)
            low_edges_states_remove_list = set()
            for oldLowState in low_edges_states:
                oldHighState = self.lowState2highState(oldLowState,p); oldLowState.low2highStatedict = oldHighState.highState; oldLowState.low2highStateid = oldHighState.highStateid
                if highStateid_notin_HighStateCollection(oldHighState.highStateid, h_sub_all_state_set):
                    h_sub_all_state_set.add(oldHighState)
                if oldHighState.isGoalState == True: # Low-order isGoalState judgment logic normally needs to be consistent with the second abstract predicate h_goal
                    low_done_states.add(oldLowState) 
                    low_edges_states_remove_list.add(oldLowState) # low_edges_states.remove(oldLowState)
                    continue
                for act in self.parser.actions:
                    # for each action ,check HL states in "low_edges_states" contain precondition state of every_action
                    has_at_least_one_successor,successor_lowStates= get_all_appliable_successors(oldLowState,act,p)
                    if has_at_least_one_successor==True: # get 'appliable_actions' for 'olsLowState'
                        for cur_appliable_var_spec_str,nextLowState in successor_lowStates.items(): 
                            cur_var_spec=json.loads(cur_appliable_var_spec_str)
                            nextHighState = self.lowState2highState(nextLowState,p); nextLowState.low2highStatedict = nextHighState.highState; nextLowState.low2highStateid = nextHighState.highStateid
                            if highStateid_notin_HighStateCollection(nextHighState.highStateid, h_sub_all_state_set):
                                h_sub_all_state_set.add(nextHighState) # unit set 
                            if DEBUG:
                                print('*'*30)
                                print(act.name,str(cur_var_spec),'\n','old: \n',oldLowState,'\n','new: \n',nextLowState,'\n')
                                print(' old: \n',oldHighState.highStateid,oldHighState.highState,'\n',"new: \n",nextHighState.highStateid,nextHighState.highState,'\n')
                            morphism = (\
                                oldHighState.highStateid,\
                                act.name,\
                                nextHighState.highStateid)
                            if morphism_notin_h_sub_all_high_level_action_pair_from_low_BFS(morphism,h_sub_all_high_level_action_pair_from_low_BFS):
                                h_sub_all_high_level_action_pair_from_low_BFS.add(morphism)
                                whole_merged_all_sub_fond_domain_and_or_graph.morphism_add2_all_HL_normal_fond_acts(morphism)
                                cur_sub_fond_graph.morphism_add2_all_HL_normal_fond_acts(morphism)
                            # the hashable-unique lowlevel State 
                            low_front_next_states.add(nextLowState)
                            low_front_next_states -= low_done_states # go back forbiden 
                            low_front_next_states -= low_edges_states # go back forbiden
            for item in low_edges_states:
                low_done_states.add(item) 
            low_edges_states = set(); 
            for item in low_front_next_states:
                low_edges_states.add(item) 
            low_front_next_states = set() # \emptyset
        
        whole_merged_all_sub_fond_domain_and_or_graph.allHighStateCollection = whole_merged_all_sub_fond_domain_and_or_graph.allHighStateCollection.union( h_sub_all_state_set)
        cur_sub_fond_graph.allHighStateCollection = cur_sub_fond_graph.allHighStateCollection.union( h_sub_all_state_set)
        return whole_merged_all_sub_fond_domain_and_or_graph,cur_sub_fond_graph

 

if __name__ == '__main__':
    pass






