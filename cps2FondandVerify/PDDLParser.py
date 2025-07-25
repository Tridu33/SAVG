
#!/usr/bin/env python 
# -*- coding:UTF-8 -*-
from os import curdir
import re,sys, pprint,copy,json
from PDDLaction import Action

class PDDLProblem:
    def __init__(self):
        self.problem_name = 'unknown'
        self.objects = dict()
        self.initialstate = []
        self.initialstateNestList = []
        self.positive_initialstate = []
        self.negative_initialstate = []
        self.goalstateNestList = []
        self.positive_goals = []
        self.negative_goals = []

class TCfml:
    def __init__(self, name, parameters, fmlcnf):
        self.name = name
        self.parameters = parameters
        self.fmlcnf = fmlcnf
        self.countingTermArg = str()
    def get_default_args_str(self)->str():
        default_args_str  = str() 
        for list in self.parameters:
            if(list[0][0]=='?'):
                element = list[0][1:]
            else:
                element = list[0]
            default_args_str+= element + ','
        if(default_args_str[-1] == ','):
            default_args_str = default_args_str[:-1]
        return default_args_str

class PDDLParser:
    
    SUPPORTED_REQUIREMENTS = [
        ':strips', 
        ':negative-preconditions', 
        ':typing',
        ':equality',
        ':disjunctive-preconditions',
        ':universal-preconditions', 
        ':derived-predicates',# ':derived', here just for learning FOND predicates but not ':derived-predicates' and ':derived-action' in tradditional PDDL
        ':conditional-effects',# when
        ':transitive_closure',
        ':transitive_closure_fml']
    def __init__(self) -> None:
        pass

    # ------------------------------------------
    # Tokens
    # ------------------------------------------
    def scan_tokens(self, filename):
        with open(filename,'r', encoding='utf-8') as f:
            # Remove single line comments
            str = re.sub(r';.*$', '', f.read(), flags=re.MULTILINE)#.lower()
        # Tokenize
        stack = []
        list = []
        for t in re.findall(r'[()]|[^\s()]+', str):
            if t == '(':
                stack.append(list)
                list = []
            elif t == ')':
                if stack:
                    l = list
                    list = stack.pop()
                    list.append(l)
                else:
                    raise Exception('Missing open parentheses')
            else:
                list.append(t)
        if stack:
            raise Exception('Missing close parentheses')
        if len(list) != 1:
            raise Exception('Malformed expression')
        return list[0]

    #-----------------------------------------------
    # Parse domain
    #-----------------------------------------------
    def parse_domain(self, domain_filename):
        tokens = self.scan_tokens(domain_filename)
        if type(tokens) is list and tokens.pop(0) == 'define':
            self.domain_name = 'unknown'
            self.requirements = []
            self.types = []
            self.actions = []
            self.predicates = {}
            self.predicates_transitive_closure = {}
            self.predicates_transitive_closure_fml = {}
            self.fond_predicates = {}
            # self.fond_predicates_order = []
            self.ConsForSorts = {}
            self.constants = {}
            self.aset_bset_pairs = []
            self.formula_for_initial_states = []
            self.formula_for_goals = []
            while tokens:
                group = tokens.pop(0)
                t = group.pop(0)
                if   t == 'domain':
                    self.domain_name = group[0]
                elif t == ':requirements':
                    for req in group:
                        if not req in self.SUPPORTED_REQUIREMENTS:
                            raise Exception('Requirement ' + req + ' not supported')
                    self.requirements = group
                elif t == ':predicates':
                    self.parse_predicates(group)
                elif t == ':types':
                    self.types = group
                elif t == ':action':
                    self.parse_action(group)
                elif t == ':constants':
                    self.parse_constants(group)
                elif t == ':transitive_closure':
                    self.parse_transitive_closure(group)
                elif t == ':transitive_closure_fml':
                    self.parse_transitive_closure_fml(group)
                elif t == ':derived':
                    self.parse_derived(group)
                elif t == ':conditionfairness':
                    self.parse_conditionfairness(group)
                elif t == ':formula_for_initial_states':
                    self.parse_formula_for_initial_states(group)
                elif t == ':formula_for_goals':
                    self.parse_formula_for_goals(group)
                else: print(str(t) + ' is not recognized in domain')
        else:
            raise Exception('File ' + domain_filename + ' does not match domain pattern')

    #-----------------------------------------------
    # Parse formula for initial states (z3 syntax)
    #-----------------------------------------------
    def parse_formula_for_initial_states(self, group):
        self.formula_for_initial_states = group

    #-----------------------------------------------
    # Parse parse formula for goals (z3 syntax)
    #-----------------------------------------------
    def parse_formula_for_goals(self, group):
        self.formula_for_goals = group

    #-----------------------------------------------
    # Parse condition fairness --- action pairs whose numeric effects are mutually exclusive.
    #-----------------------------------------------
    def parse_conditionfairness(self, group):
        a_set = []
        b_set = []
        while group:
            t = group.pop(0)
            if t == ':a':
                curlist = group.pop(0)
                while type(curlist) is list and len(group) != 0:
                    a_set.append(curlist[0])
                    curlist = group.pop(0)
                t = curlist
                if t == ':b':
                    while len(group) != 0:
                        curlist = group[0]
                        b_set.append(curlist[0])
                        group.pop(0) 
        self.aset_bset_pairs.append( (a_set,b_set) )

    #-----------------------------------------------
    # Parse predicates
    #-----------------------------------------------
    def parse_predicates(self, group):
        for pred in group:
            predicate_name = pred.pop(0)
            if predicate_name in self.predicates:
                raise Exception('Predicate ' + predicate_name + ' redefined')
            arguments = {}
            untyped_variables = []
            while pred:
                t = pred.pop(0)
                if t == '-':
                    if not untyped_variables:
                        raise Exception('Unexpected hyphen in predicates')
                    type = pred.pop(0)
                    while untyped_variables:
                        OneOfUntyped_variableslist = untyped_variables.pop(0)
                        arguments[OneOfUntyped_variableslist] = type
                        self.insertConsForSort(OneOfUntyped_variableslist,type)
                else:
                    untyped_variables.append(t)
            while untyped_variables:  
                OneOfUntyped_variableslist = untyped_variables.pop(0)
                arguments[untyped_variables.pop(0)] = 'object' # default,
                self.insertConsForSort(OneOfUntyped_variableslist,'object')
            self.predicates[predicate_name] = arguments

    def insertConsForSort(self,OneOfUntyped_variableslist,curtype):
        """add to self.ConsForSort if not added before"""
        if OneOfUntyped_variableslist not in self.ConsForSorts:
                    self.ConsForSorts[OneOfUntyped_variableslist] = curtype
        else:
            if self.ConsForSorts[OneOfUntyped_variableslist] == curtype:
                pass # already added before,just pass
            else:
                raise Exception(OneOfUntyped_variableslist +' is already defined as ' \
                                + self.ConsForSorts[OneOfUntyped_variableslist] \
                                + '.It can not defined again with another sort:' + curtype)
                                
    #-----------------------------------------------
    # Parse :derive-predicate(refinementMap) by ":derive":
        # map(hig-level boolean fluents) --> (low-level FOL formula)
        # map(hig-level variables) --> (low-level FOL formula with counting Operator "#")
    #-----------------------------------------------
    def parse_derived(self,group):
        fond_predicate_name = group.pop(0)[0]
        if not type(fond_predicate_name) is str:
            raise Exception('Action without fond_predicate_name definition') 
        formulaCNF = group.pop(0)
        # self.fond_predicates_order.append(fond_predicate_name)
        self.fond_predicates[fond_predicate_name] = formulaCNF

    #-----------------------------------------------
    # Parse transitive_closure
    #-----------------------------------------------
    def parse_transitive_closure(self,group):
        for each in group:
            tc = each[0].split(',')
            self.predicates_transitive_closure[tc[0]] = tc[1]
        #print("\n\n\nparse_transitive_closure\n\n\n")

    #-----------------------------------------------
    # Parse constants
    #-----------------------------------------------

    def parse_constants(self,group):
        if not type(group) is list:
            raise Exception('Error with ' + tc_name + ' parameters')
        parameters = []
        untyped_parameters = []
        p = group
        while p:
            t = p.pop(0)
            if t == '-':
                if not untyped_parameters:
                    raise Exception('Unexpected hyphen in ' + tc_name + ' parameters')
                ptype = p.pop(0)
                while untyped_parameters:
                    OneOfUntyped_variableslist = untyped_parameters.pop(0)
                    self.constants[OneOfUntyped_variableslist] = ptype
                    #self.insertConsForSort(OneOfUntyped_variableslist,ptype) # update self.ConsForSorts if necessary
            else:
                untyped_parameters.append(t) # list for variables share the same Sort like:[?from,?to] - roomType
        while untyped_parameters:
            OneOfUntyped_variableslist = untyped_parameters.pop(0)
            parameters.append([OneOfUntyped_variableslist, 'object'])# default 'object'
            #self.insertConsForSort(OneOfUntyped_variableslist,'object') # update self.ConsForSorts if necessary
        
    #-----------------------------------------------
    # Parse parse_transitive_closure_fml
    #-----------------------------------------------
    def parse_transitive_closure_fml(self,group):
        tc_name = group.pop(0)
        if not type(tc_name) is str:
            raise Exception('Action without tc_name definition') 
        parameters = []
        formulaCNF =str()
        tc_args = [] 
        while group:
            t = group.pop(0)
            if t == ':parameters':
                if not type(group) is list:
                    raise Exception('Error with ' + tc_name + ' parameters')
                parameters = []
                untyped_parameters = []
                p = group.pop(0)
                while p:
                    t = p.pop(0)
                    if t == '-':
                        if not untyped_parameters:
                            raise Exception('Unexpected hyphen in ' + tc_name + ' parameters')
                        ptype = p.pop(0)
                        while untyped_parameters:
                            OneOfUntyped_variableslist = untyped_parameters.pop(0)
                            parameters.append([OneOfUntyped_variableslist, ptype]) # region
                            #self.insertConsForSort(OneOfUntyped_variableslist,ptype) # update self.ConsForSorts if necessary
                    else:
                        untyped_parameters.append(t) # list for variables share the same Sort like:[?from,?to] - roomType
                while untyped_parameters:
                    OneOfUntyped_variableslist = untyped_parameters.pop(0)
                    parameters.append([OneOfUntyped_variableslist, 'object'])# default 'object'
                    #self.insertConsForSort(OneOfUntyped_variableslist,'object') # update self.ConsForSorts if necessary
                tc_args = parameters
            elif t == ':formula':
                formulaCNF = group.pop(0)
                if not type(formulaCNF) is list:
                    raise Exception('Error with ' + name )
        self.predicates_transitive_closure_fml[tc_name] = TCfml(tc_name,tc_args,formulaCNF)
        
    #-----------------------------------------------
    # Parse action
    #-----------------------------------------------

    def parse_action(self, group):
        name = group.pop(0)
        if not type(name) is str:
            raise Exception('Action without name definition')
        for act in self.actions:
            if act.name == name:
                raise Exception('Action ' + name + ' redefined')
        parameters = []
        positive_preconditions = []
        negative_preconditions = []
        add_effects = []
        del_effects = []
        while group:
            t = group.pop(0)
            if t == ':parameters':
                if not type(group) is list:
                    raise Exception('Error with ' + name + ' parameters')
                parameters = []
                untyped_parameters = []
                p = group.pop(0)
                while p:
                    t = p.pop(0)
                    if t == '-':
                        if not untyped_parameters:
                            raise Exception('Unexpected hyphen in ' + name + ' parameters')
                        ptype = p.pop(0)
                        while untyped_parameters:
                            OneOfUntyped_variableslist = untyped_parameters.pop(0)
                            parameters.append([OneOfUntyped_variableslist, ptype]) # region
                            self.insertConsForSort(OneOfUntyped_variableslist,ptype) # update self.ConsForSorts if necessary
                    else:
                        untyped_parameters.append(t) # list for variables share the same Sort like:[?from,?to] - roomType
                while untyped_parameters:
                    OneOfUntyped_variableslist = untyped_parameters.pop(0)
                    parameters.append([OneOfUntyped_variableslist, 'object'])# default 'object'
                    self.insertConsForSort(OneOfUntyped_variableslist,'object') # update self.ConsForSorts if necessary
            elif t == ':precondition':
                self.split_predicates(group.pop(0), positive_preconditions, negative_preconditions, name, ' preconditions')
            elif t == ':effect':
                self.split_predicates(group.pop(0), add_effects, del_effects, name, ' effects')
            else: print(str(t) + ' is not recognized in action')
        self.actions.append(Action(name, parameters, positive_preconditions, negative_preconditions, add_effects, del_effects))

    #-----------------------------------------------
    # Parse problem
    #-----------------------------------------------
    def parse_problem(self, problem_filename):
        tokens = self.scan_tokens(problem_filename)
        if type(tokens) is list and tokens.pop(0) == 'define':
            pddl_problem = PDDLProblem()
            while tokens:
                group = tokens.pop(0)
                t = group[0]
                if   t == 'problem':
                    pddl_problem.problem_name = group[-1]
                elif t == ':domain':
                    if self.domain_name != group[-1]:
                        raise Exception('Different domain specified in problem file')
                elif t == ':requirements':
                    pass # Ignore requirements in problem, parse them in the domain
                elif t == ':objects':
                    group.pop(0)
                    object_list = []
                    while group:
                        if group[0] == '-':
                            group.pop(0)
                            pddl_problem.objects[group.pop(0)] = object_list# Blocktype-->[A,G]
                            object_list = []
                        else:
                            object_list.append(group.pop(0))
                    if object_list:
                        if not 'object' in pddl_problem.objects:
                            pddl_problem.objects['object'] = []
                        pddl_problem.objects['object'] += object_list
                elif t == ':variablesInQuantifiedFormula': # (:variablesInQuantifiedFormula ?xp - PlantType ?loc - LocationType)
                    group.pop(0)
                    variables_list = []
                    while group:
                        if group[0] == '-':
                            group.pop(0)# '-'
                            curtype = group.pop(0) # BlockType
                            for each in variables_list : # [?x,?y,...]-->BlockType in Dict "self.ConsForSort"
                                self.insertConsForSort(each,curtype)
                            variables_list = []
                        else:
                            variables_list.append(group.pop(0))
                elif t == ':init':
                    group.pop(0)
                    pddl_problem.initialstateNestList = group
                    # pddl_problem.initialstate = group
                    self.split_predicates_initial(pddl_problem.initialstateNestList, pddl_problem.positive_initialstate, pddl_problem.negative_initialstate, '', 'iniital')
                elif t == ':goal':
                    pddl_problem.goalstateNestList = group[1]
                    self.split_predicates(group[1], pddl_problem.positive_goals, pddl_problem.negative_goals, '', 'goals')
                else: print(str(t) + ' is not recognized in problem')
            return pddl_problem
        else:
            raise Exception('File ' + problem_filename + ' does not match problem pattern')

    #-----------------------------------------------
    # Split predicates (goal)
    #-----------------------------------------------

    def split_predicates(self, group, pos, neg, name, part):
        if not type(group) is list:
            raise Exception('Error with ' + name + part)
        if group[0] == 'and':
            group.pop(0)
        else:
            group = [group]
        for predicate in group:
            if predicate[0] == 'not':
                if len(predicate) != 2:
                    raise Exception('Unexpected not in ' + name + part)
                neg.append(predicate[-1])
            else:
                pos.append(predicate)


    #-----------------------------------------------
    # Split predicates (initial)
    #-----------------------------------------------

    def split_predicates_initial(self, group, pos, neg, name, part):
        if not type(group) is list:
            raise Exception('Error with ' + name + part)
        if group[0] == 'and':
            group.pop(0)
        else:
            pass # group = [group]
        for predicate in group:
            if predicate[0] == 'not':
                if len(predicate) != 2:
                    raise Exception('Unexpected not in ' + name + part)
                neg.append(predicate[-1])
            else:
                pos.append(predicate)


# ==========================================
# Main 
# ==========================================

if __name__ == '__main__':
    #domain = sys.argv[1]
    import os
    domainname = "bfs"
    cpn = 3
    # ==========================================================
    # classical plan(CPs) domain parser
    # ==========================================================
    dir2cp_d = os.getcwd()+"/domain/{0}/low_{0}_d.pddl".format(domainname)
    parser = PDDLParser()
    parser.parse_domain(dir2cp_d)

    # ==========================================================
    # classical plan(CPs) problems parser
    # ==========================================================
    DEBUG = True
    problems_list = []
    for cpi in range(1,cpn+1):
        dir2cpi = os.getcwd()+"/domain/{0}/low_{0}_p{1}.pddl".format(domainname,cpi)
        pi = parser.parse_problem(dir2cpi)
        problems_list.append(pi)
        if DEBUG == True:
            # print('----------------------------scan_tokens(domain)')
            # pprint.pprint(parser.scan_tokens(domain))
            # print('----------------------------scan_tokens(problem)')
            # pprint.pprint(parser.scan_tokens(problem))
            # print('----------------------------Domain name + Actions')
            print('--------- domain -----------')
            print('Domain name: ' + parser.domain_name)
            print("types :",end = '')
            print(parser.types)
            print('Objects: ' + str(parser.objects)) # 
            print("predicates :",end = '')
            print(parser.predicates)
            print("ConsForSorts :",end = '')
            print(parser.ConsForSorts)
            print("predicates_transitive_closure :",end = '')
            print(parser.predicates_transitive_closure)
            print("actions is:")
            for act in parser.actions:
                print(act)
            print('---------problem -----------')
            print('Problem name: ' + parser.problem_name)
            print('State: ' + str(parser.state))
            print('Positive goals: ' + str(parser.positive_goals))
            print('Negative goals: ' + str(parser.negative_goals))
            DEBUG = False




