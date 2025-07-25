#!/usr/bin/env python 
# -*- coding:UTF-8 -*-
# 
"""
main
"""
import sys, pprint,os,json,time, copy,re
from .PDDLParser import PDDLParser 
from .Simulator import Simulator
from .HigState import HigState
from .LowState import LowState
from .constants import *
from .utils import *
from .FondDomainAndOrGraph import FondDomainAndOrGraph

def mCPs2fond(father_dir,destination_father_dir,domainname,cpn,DEBUG):
    """
    main function entry here.
    mCPs2fond(father_dir,destination_father_dir,domainname,cpn,DEBUG):
    """
    # ==========================================================
    # classical plan(CPs) domain_parser
    # ==========================================================
    dir2cp_d = father_dir + "/domain/{0}/low_{0}_d.pddl".format(domainname)
    parser = PDDLParser()
    parser.parse_domain(dir2cp_d)

    # ==========================================================
    # classical plan(CPs) problems_parser
    # ==========================================================
    problems_list = []
    for cpi in range(1,cpn+1):
        dir2cpi = father_dir + "/domain/{0}/low_{0}_p{1}.pddl".format(domainname,cpi)
        pi = parser.parse_problem(dir2cpi)
        problems_list.append(pi)

    # ==========================================================
    # classical plan(CPs) problems 
    # Breadth First Search from the initial state 
    # (every map('LL state')='HL state' ) for the high level action
    # simulation and get the final FOND Regex automata graph,the throw out Regex it recognized
    # ==========================================================

    fond_predicate_order = []
    for fond_predicate,_ in parser.fond_predicates.items():
        fond_predicate_order.append(fond_predicate) 
    h_sub_fond_domain_and_or_graph = FondDomainAndOrGraph(fond_predicate_order)
    for ll_problem in problems_list: 
        simulator = Simulator(parser)
        h_sub_fond_domain_and_or_graph = simulator.getsubHLactions(ll_problem,h_sub_fond_domain_and_or_graph)
    
    # ==========================================================
    # generial plan: FOND model file and problem file write out.(policy) from `graphInTotal`
    # ==========================================================        
    dumpFONDfiles(planner_PRP_or_FONDASP, destination_father_dir,h_sub_fond_domain_and_or_graph,domainname,parser)
    
if __name__ == '__main__':
    import argparse
    args_parser = argparse.ArgumentParser(description='code autoGenerator')
    args_parser.add_argument('-domainname', default = "bfs", help='Path to fond domain files(default=dfs). -- OPTIONAL')
    args_parser.add_argument('-cpn', default="5", help='number of classical plans,like \'3\' for \'*p1,*p2,*p3\'. -- NOT OPTIONAL')
    args_parser.add_argument('-debug', default = 'True', help='print DEBUG message or not. -- OPTIONAL FOR TEST')
    # args_parser.add_argument('-timeout_number', default = 10, help='timeout_number(s). -- OPTIONAL FOR PROVE')
    params = vars(args_parser.parse_args()) #  Pass in parameters, parent directory of the domain folder, read contents, cpn, debug true or false values are optional
    # timeout_number = params['timeout_number']

    if params['debug'] == 'False':
        DEBUG = False
    else:
        DEBUG = True

    domainname = params['domainname']
    cpn = int(params['cpn']) # 1,2,...,cpn = range(1,cpn+1)

    import time
    start_time = time.perf_counter()
    mCPs2fond( os.getcwd(),os.getcwd(),          domainname,cpn,DEBUG)
    # mCPs2fond(father_dir,destination_father_dir,domainname,cpn,DEBUG)
    end_time = time.perf_counter()
    print('it cost: ',end_time - start_time,'(s).')