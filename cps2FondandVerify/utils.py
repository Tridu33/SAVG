#!/usr/bin/env python 
# -*- coding:UTF-8 -*-
import os
from HigState import HigState

def copy_dir(src_path, target_path):
    if os.path.isdir(src_path) and os.path.isdir(target_path):
        filelist_src = os.listdir(src_path)
        for file in filelist_src:
            path = os.path.join(os.path.abspath(src_path), file)    
            if os.path.isdir(path):
                path1 = os.path.join(os.path.abspath(target_path), file)    
                if not os.path.exists(path1):                        
                    os.mkdir(path1)
                copy_dir(path,path1)            
            else:                                
                with open(path, 'r', encoding='utf-8') as read_stream:
                    contents = read_stream.read()
                    path1 = os.path.join(target_path, file)
                    with open(path1, 'w', encoding='utf-8') as write_stream:
                        write_stream.write(contents)
        return True
    else:
        return False

def run_all_python_prove_file_in_dir_autogenerated():
    """run all python prove file in autogenerated path,like ./autogenerated/*.py"""
    copy_dir("constrainsConfig",".\\autogenerated\\constrainsConfig")# print("start to prove all theorem:\n")
    cur_path = os.path.dirname(os.path.realpath(__file__))
    os.putenv("PYTHONPATH", cur_path)
    case_path = os.path.join(cur_path, "autogenerated")
    lst = os.listdir(case_path)
    count_process_number = 0
    total_prove_files_count = 0
    for each in lst:
        if os.path.splitext(each)[1] == '.py':
            total_prove_files_count = total_prove_files_count + 1
    total_prove_files_count = total_prove_files_count - 1
    for c in lst:
        curr_ps = count_process_number/total_prove_files_count
        progress_width = 28
        progress_str = '{0:s}'.format(int(progress_width * curr_ps) * '>').ljust(progress_width, '-')        # progress_str = '{0:s}'.format(int(progress_width * curr_ps) * '|~_~)').ljust(progress_width, ' ')
        msg_str = '{0:.0%}:'.format(curr_ps)
        if os.path.splitext(c)[1] == '.py':
            print(f'\r{progress_str} {msg_str}')#, end='')
            count_process_number += 1
            #print('py .\\autogenerated\\{0}'.format(c))
            #os.system('py .\\autogenerated\\{0}'.format(c))
            os.system('python {1}'.format(case_path,os.path.join(case_path, c)))

# def run_all_python_prove_file_in_dir_autogenerated():
#     """run all python prove file in autogenerated path,like ./autogenerated/*.py"""
#     copy_dir("constrainsConfig",".\\autogenerated\\constrainsConfig")
#     # print("start to prove all theorem:\n")
#     cur_path = os.path.dirname(os.path.realpath(__file__))
#     os.putenv("PYTHONPATH", cur_path)
#     case_path = os.path.join(cur_path, "autogenerated")
#     lst = os.listdir(case_path)
#     # print(lst)
#     count_process_number = 0
#     total_prove_files_count = 0
#     for each in lst:
#         if os.path.splitext(each)[1] == '.py':
#             total_prove_files_count = total_prove_files_count + 1
#     total_prove_files_count = total_prove_files_count - 1
#     for c in lst:
#         curr_ps = count_process_number/total_prove_files_count
#         progress_width = 28
#         progress_str = '{0:s}'.format(int(progress_width * curr_ps) * '>').ljust(progress_width, '-')
#         # progress_str = '{0:s}'.format(int(progress_width * curr_ps) * '|~_~)').ljust(progress_width, ' ')
#         msg_str = '{0:.0%}:'.format(curr_ps)
        
#         if os.path.splitext(c)[1] == '.py':
#             print(f'\r{progress_str} {msg_str}')#, end='')
#             count_process_number += 1
#             #print('py .\\autogenerated\\{0}'.format(c))
#             #os.system('py .\\autogenerated\\{0}'.format(c))
#             os.system('python {1}'.format(case_path,os.path.join(case_path, c)))

def delete_all_files_in_dir_autogenerated():
    cur_path = os.path.dirname(os.path.realpath(__file__))
    path = os.path.join(cur_path, "autogenerated")
    for maindir,subdir,file_name_list in os.walk(path):  
        for filename in file_name_list:
            if(filename.endswith(".bitefile") or filename.endswith(".json") or filename.endswith(".png") or filename.endswith(".txt") or filename.endswith(".pddl")  or filename.endswith(".dot")):  
                os.remove(maindir+"/"+filename)  
    # print("all ./autogenerated/*.py have been deleted.")
    path = os.path.join(cur_path, "autogenerated/subFONDs")
    for maindir,subdir,file_name_list in os.walk(path):  
        for filename in file_name_list:
            if(filename.endswith(".json") or filename.endswith(".png") or filename.endswith(".txt") or filename.endswith(".pddl") or filename.endswith(".dot")):  
                os.remove(maindir+"/"+filename)  
    path = os.path.join(cur_path, "autogenerated/cache")
    for maindir,subdir,file_name_list in os.walk(path):  
        for filename in file_name_list:
            if(filename.endswith(".json") or filename.endswith(".png") or filename.endswith(".txt") or filename.endswith(".pddl") or filename.endswith(".dot")):  
                os.remove(maindir+"/"+filename)  
    path = os.path.join(cur_path, "autogenerated/domain_steps_configJSON")
    for maindir,subdir,file_name_list in os.walk(path):  
        for filename in file_name_list:
            if(filename.endswith(".json") or filename.endswith(".png") or filename.endswith(".txt") or filename.endswith(".pddl") or filename.endswith(".dot")):  
                os.remove(maindir+"/"+filename)  
    path = os.path.join(cur_path, "autogenerated/domain_template")
    for maindir,subdir,file_name_list in os.walk(path):  
        for filename in file_name_list:
            if(filename.endswith(".json") or filename.endswith(".png") or filename.endswith(".txt") or filename.endswith(".pddl") or filename.endswith(".dot")):  
                os.remove(maindir+"/"+filename)  

def delete_all_py_files_in_dir_autogenerated():
    cur_path = os.path.dirname(os.path.realpath(__file__))
    path = os.path.join(cur_path, "autogenerated")
    for maindir,subdir,file_name_list in os.walk(path):  
        for filename in file_name_list:
            if(filename.endswith(".py")):  
                os.remove(maindir+"/"+filename)  
    # print("all ./autogenerated/*.py have been deleted.")
    path = os.path.join(cur_path, "autogenerated/subFONDs")
    for maindir,subdir,file_name_list in os.walk(path):  
        for filename in file_name_list:
            if(filename.endswith(".py")):  
                os.remove(maindir+"/"+filename)  
    path = os.path.join(cur_path, "autogenerated/cache")
    for maindir,subdir,file_name_list in os.walk(path):  
        for filename in file_name_list:
            if(filename.endswith(".py")):  
                os.remove(maindir+"/"+filename)  
    path = os.path.join(cur_path, "autogenerated/domain_steps_configJSON")
    for maindir,subdir,file_name_list in os.walk(path):  
        for filename in file_name_list:
            if(filename.endswith(".py")):  
                os.remove(maindir+"/"+filename)  
    path = os.path.join(cur_path, "autogenerated/domain_template")
    for maindir,subdir,file_name_list in os.walk(path):  
        for filename in file_name_list:
            if(filename.endswith(".py")):  
                os.remove(maindir+"/"+filename)  


    
def delFilesPRPGenerated():
    """
    delete Files by PRP Generated as follow:
    """
    cur_path = os.path.dirname(os.path.realpath(__file__))
        
    files_path = [  cur_path + "/" + "plan_numbers_and_cost",
                    cur_path + "/" + "output.sas",
                    cur_path + "/" + "output",
                    cur_path + "/" + "policy.fsap",
                    cur_path + "/" + "sas_plan",
                    cur_path + "/" + "policy.out",
                    cur_path + "/" + "elapsed.time",
                    cur_path + "/" + "human_policy.out",
                    cur_path + "/" + "action.map",
                    cur_path + "/" + "graph.dot",
                    cur_path + "/" + "graphGenerated.png",
                    cur_path + "/" + "graphGenerated.dot",
                    cur_path + "/" + "graph.png"]
    # Handle errors while calling os.remove()
    for file_path in files_path:
        try:
            if os.path.exists(file_path):
                os.remove(file_path)
        except:
            pass
def create_dir_not_exist(path):
    if not os.path.exists(path):
            os.mkdir(path)
def dumpFONDfiles(planner_PRP_or_FONDASP,destination_father_dir,h_sub_fond_domain_and_or_graph,domainname,parser,is_subFONDs = 'default'):
    if is_subFONDs == 'default':
        fond_d_gen = "autogenerated/fond_{0}_d.pddl".format(domainname)
        fond_p_gen = "autogenerated/fond_{0}_p.pddl".format(domainname)
    elif is_subFONDs == 'subFONDs':
        fond_d_gen = "autogenerated/subFONDs/fond_{0}_d.pddl".format(domainname)
        fond_p_gen = "autogenerated/subFONDs/fond_{0}_p.pddl".format(domainname)
        sub_fond_dot = "autogenerated/subFONDs/fond_{0}.dot".format(domainname) 
        sub_fond_png = "autogenerated/subFONDs/fond_{0}.png".format(domainname)
        RUN_CMD_For_Dot  = "dot -Tpng {0} -o {1}".format(sub_fond_dot,sub_fond_png)
        sub_fond_dot_str = "digraph G {\n    node [shape=plaintext]"

    # cur_path = os.path.dirname(os.path.realpath(__file__))
    fond_p_gen_path = os.path.join(destination_father_dir,fond_p_gen)
    fond_d_gen_path = os.path.join(destination_father_dir,fond_d_gen)
    create_dir_not_exist(os.path.join(destination_father_dir,"autogenerated"))
    HL_fond_boolean_semantic_named_features = h_sub_fond_domain_and_or_graph.HL_fond_boolean_semantic_named_features
    n = len(HL_fond_boolean_semantic_named_features)
    
    domain_str = """
(define (domain {0}_d)
    (:requirements :typing :non-deterministic)
    (:types	)
    (:predicates
    (vStart)
    (vGoal)
""".format(domainname)
    predicates_str = ""
    for each in parser.fond_predicates:
        predicates_str += ("    (" + each + ")\n")
    domain_str += predicates_str
    domain_str += """    )
    """
    # get HLid map to CNF:
    goal_states_set = set()
    HLid2CNF = {}
    for eachhs in h_sub_fond_domain_and_or_graph.allHighStateCollection:
        HLid2CNF[eachhs.highStateid] = eachhs.dumplowlevelCNFfromhighstateId()
        if eachhs.isGoalState == True:
            goal_states_set.add(eachhs.highStateid)
    initial_states_set = h_sub_fond_domain_and_or_graph.initial_states_set
    all_HL_normal_fond_acts = h_sub_fond_domain_and_or_graph.all_HL_normal_fond_acts
    begin_states_normal_fond_acts_set = list(HLid2CNF.keys())

    # to get the virtual action for super vsinks (1:n)

    virtual_HL_super_source_state = HigState()
    virtual_HL_super_source_state.isGoalState = False
    virtual_HL_super_source_state.highStateid = pow(2,1+len(HL_fond_boolean_semantic_named_features))
    initial_states_set_str = ""
    for iHLState in initial_states_set:
        initial_states_set_str += "_"+str(iHLState)
    virtual_HL_super_source_state2CNF = " (vStart) "
    # for each in HL_fond_boolean_semantic_named_features:
    #     virtual_HL_super_source_state2CNF += "not({0}) ".format(each)
    # virtual_HL_super_source_state2CNF += ')'
    HLid2CNF[virtual_HL_super_source_state.highStateid] = virtual_HL_super_source_state2CNF

    # :action virtualsourcesstart
    vsourcesaction_str = """\n    (:action """
    action_name = "{0}_virtual_source_act{1}".format(virtual_HL_super_source_state.highStateid,initial_states_set_str)
    if is_subFONDs == 'subFONDs': 
        sub_fond_dot_str += '\n' + str(virtual_HL_super_source_state.highStateid) + '->' + initial_states_set_str.strip('_') + '[label = "vAct"]' 
        sub_fond_dot_str += '\n'
    vsourcesaction_str += action_name
    vsourcesaction_str += """
    :parameters ()"""
    pre = "\n        :precondition (and {0} )".format(virtual_HL_super_source_state2CNF)
    vsourcesaction_str += pre
    eff = "\n        :effect "
    if len(initial_states_set) == 1:
        for iHLState in initial_states_set:
            eff += HLid2CNF[iHLState]
    else: # >= 1 'oneof' + different CNF
        eff += '(oneof \n'
        for eachhs in initial_states_set:
            eff += ('        ' + HLid2CNF[eachhs] + '\n')
        eff += '        )' # 'oneof'
    vsourcesaction_str += eff
    domain_str += (vsourcesaction_str + '\n    )') # (:action
    
    # aset_bset_pairs
    asets = set()
    bsets = set()
    for each_pair in parser.aset_bset_pairs:
        for each_action_name in each_pair[0]:
            asets.add(each_action_name)
        for each_action_name in each_pair[1]:
            bsets.add(each_action_name)
    if planner_PRP_or_FONDASP != 'PRP' and is_subFONDs != 'subFONDs':# conditional fairness
        low_action_name_2_FOND_action_names_list = dict()
        all_FOND_action_names = set()
        
    # actions    
    for hs, low_act2hs_list in all_HL_normal_fond_acts.items():
        # print(type(hs))
        # print(type(low_act2hs_list))
        for low_act,hs_list in low_act2hs_list.items():
            if planner_PRP_or_FONDASP != 'PRP' and is_subFONDs != 'subFONDs':# conditional fairness
                if low_act not in low_action_name_2_FOND_action_names_list :
                    low_action_name_2_FOND_action_names_list[low_act] = []
            action_str = """\n    (:action """
            action_name = str(hs)+'_'+low_act
            if len(hs_list) == 1:
                action_name += '_' + str(hs_list[0])
            else:
                for each_sucssor_hs in hs_list:
                    action_name += '_' + str(each_sucssor_hs)
            action_str += action_name
            
            if planner_PRP_or_FONDASP != 'PRP' and is_subFONDs != 'subFONDs': # conditional fairness
                all_FOND_action_names.add(action_name)
                cur_low_action_mapped_FOND_acts_list = low_action_name_2_FOND_action_names_list[low_act]
                cur_low_action_mapped_FOND_acts_list.append(action_name)
            if is_subFONDs == 'subFONDs':
                temp_list_actionname = action_name.split('_')
                if len(temp_list_actionname) == 3:
                    sub_fond_dot_str += temp_list_actionname[0] + '->' + temp_list_actionname[2] + '[label = "{0}"]'.format(temp_list_actionname[1])
                else:
                    targets = temp_list_actionname[2:]
                    for each_target in targets:
                        sub_fond_dot_str += temp_list_actionname[0] + '->' + each_target + '[label = "{0}"]'.format(temp_list_actionname[1])
                sub_fond_dot_str += '\n'
            action_str += """
            :parameters ()"""

            pre = "\n        :precondition "
            pre += HLid2CNF[hs]
            action_str += pre

            eff = "\n        :effect "
            if len(hs_list) == 1:
                for temp_vale_can_never_the_same_name_as_global_name_hs in hs_list:
                    eff += HLid2CNF[temp_vale_can_never_the_same_name_as_global_name_hs]
            else: # >= 1 'oneof' + different CNF
                eff += '(oneof \n'
                for eachhs in hs_list:
                    eff += ('        ' + HLid2CNF[eachhs] + '\n')
                eff += '        )' # 'oneof'
            action_str += eff

            domain_str += (action_str + '\n    )') # (:action

    # last ")"
    domain_str += """
)"""
    with open(fond_d_gen_path, 'w+', encoding='utf-8') as f:
        f.write(domain_str)

    if is_subFONDs == 'subFONDs': 
        sub_fond_dot_str += '\n}'
        with open(sub_fond_dot, 'w+', encoding='utf-8') as f:
            f.write(sub_fond_dot_str)
        os.system(RUN_CMD_For_Dot) 
    
    if planner_PRP_or_FONDASP != 'PRP' and is_subFONDs != 'subFONDs':# conditional fairness
        low_action_name_2_FOND_action_names_list
        conditional_fairness_str = "(:fairness\n        "
        for each_aset_and_bset_low in parser.aset_bset_pairs:
            aset_list_low = each_aset_and_bset_low[0]
            conditional_fairness_str += ':a '
            for eacha_low in aset_list_low:
                eacha_hig_list = low_action_name_2_FOND_action_names_list[eacha_low]
                for eacha_hig in eacha_hig_list:
                    conditional_fairness_str += '(' + eacha_hig + ')'
            bset_list_low = each_aset_and_bset_low[1]
            conditional_fairness_str += '\n        :b '
            for eachb_low in bset_list_low:
                eachb_hig_list = low_action_name_2_FOND_action_names_list[eachb_low]
                for eachb_hig in eachb_hig_list:
                    conditional_fairness_str += '(' + eachb_hig + ')'
        conditional_fairness_str += '\n    )'
    problem_str = """
(define (problem {0}_p)  
(:domain {0}_d)  
(:objects )  
    (:init	(vStart)	)  
    (:goal	( and 	(vGoal)	)  )\n
    """.format(domainname)
    if planner_PRP_or_FONDASP != 'PRP' and is_subFONDs != 'subFONDs':# conditional fairness
        problem_str += conditional_fairness_str+'\n'
    problem_str += ")"
    with open(fond_p_gen_path, 'w+', encoding='utf-8') as f:
        f.write(problem_str)


if __name__ == '__main__':
    delete_all_files_in_dir_autogenerated()
    delete_all_py_files_in_dir_autogenerated()









































































