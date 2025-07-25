#!/usr/bin/env python 
# -*- coding:UTF-8 -*-
import copy,os,sys,regex,re,json,codecs,time
from GologProgramTree import Nested_list2FOLExp

def PossVerfication(parser,whole_fond):
    # get the dict of "LowActs2Poss"
    LowActs2Poss = dict()
    domain_name = parser.domain_name
    global_var_int = 0
    myVar2Types = dict()
    for each_act in parser.actions:
        FOL_formula_cnf_right = "Exists([" # "v_1,v_2,...,v_n], FOL_CNF(v_1,v_2,...,v_n))"
        each_v_i2act_parameters = dict()
        for each_vars in each_act.parameters:
            for each_v_i in each_vars[0:-1]:
                each_v_i_str = 'v'+str(global_var_int)
                FOL_formula_cnf_right += each_v_i_str + ','
                each_v_i2act_parameters[each_v_i_str] = each_v_i
                global_var_int+=1
        act_parameters2each_v_i = get_invert_dict(each_v_i2act_parameters)
        # act_parameters2each_v_i = list(inverted(each_v_i2act_parameters))
        if FOL_formula_cnf_right[-1] == ',':
            FOL_formula_cnf_right = FOL_formula_cnf_right[0:-1]
        FOL_formula_cnf_right += '],And('
        # get the positive & negative precondition
        for each_pos_pre_f in each_act.positive_preconditions:
            if len(each_pos_pre_f)==3 and (each_pos_pre_f[0] == '==' or each_pos_pre_f[0] == '='):
                var1 = each_pos_pre_f[1]
                var2 = each_pos_pre_f[2]
                if var1[0] == '?':
                    var1 = act_parameters2each_v_i[var1]
                if var2[0] == '?':
                    var2 = act_parameters2each_v_i[var2] 
                FOL_formula_cnf_right += '('+var1+'=='+var2+')'+','
            elif len(each_pos_pre_f) == 1:
                FOL_formula_cnf_right += '('+ each_pos_pre_f[0] +')'+','
            else:
                each_pos_pre_f_str = each_pos_pre_f[0] + '('
                for each_parameter in each_pos_pre_f[1:]:
                    if each_parameter in act_parameters2each_v_i.keys(): # variablies
                        each_pos_pre_f_str += act_parameters2each_v_i[each_parameter]+','
                    else:# constants
                        each_pos_pre_f_str += each_parameter +','
                if each_pos_pre_f_str[-1] == ',':
                    each_pos_pre_f_str = each_pos_pre_f_str[0:-1]+')'
                FOL_formula_cnf_right += each_pos_pre_f_str+','
        for each_neg_pre_f in each_act.negative_preconditions:
            if len(each_neg_pre_f)==3 and (each_neg_pre_f[0] == '==' or each_neg_pre_f[0] == '='):
                var1 = each_neg_pre_f[1]
                var2 = each_neg_pre_f[2]
                if var1[0] == '?':
                    var1 = act_parameters2each_v_i[var1]
                if var2[0] == '?':
                    var2 = act_parameters2each_v_i[var2] 
                FOL_formula_cnf_right += 'Not('+var1+'=='+var2+')'+','
            elif len(each_neg_pre_f) == 1:
                FOL_formula_cnf_right += 'Not('+ each_neg_pre_f[0] +')'+','
            else:
                each_neg_pre_f_str = each_neg_pre_f[0] + '('
                for each_parameter in each_neg_pre_f[1:]:
                    if each_parameter in act_parameters2each_v_i.keys():
                        each_neg_pre_f_str += act_parameters2each_v_i[each_parameter]+','
                    else:# constant
                        each_neg_pre_f_str += each_parameter+','
                if each_neg_pre_f_str[-1] == ',':
                    each_neg_pre_f_str = each_neg_pre_f_str[0:-1]+')'
                FOL_formula_cnf_right += 'Not('+each_neg_pre_f_str+'),'
        if FOL_formula_cnf_right[-1] == ',':
            FOL_formula_cnf_right = FOL_formula_cnf_right[0:-1]
        FOL_formula_cnf_right += ')' # And(

        FOL_formula_cnf_right += ')' # "Exists(["
        LowActs2Poss[each_act.name] = FOL_formula_cnf_right
        # get myVar2Types:Type for spesific 'v*'
        for each_var_list in each_act.parameters:
            for each_var in each_var_list[0:-1]:
                myVar2Types[act_parameters2each_v_i[each_var]] = each_var_list[-1]

    # refinementMap
    refinementMap_Dict = dict()
    for fond_predicate,FOL_formula_cnf in parser.fond_predicates.items():
        refinementMap_Dict[fond_predicate] = Nested_list2FOLExp().run(copy.deepcopy(FOL_formula_cnf))

    # FOND abstract:
    HL_fond_boolean_semantic_named_features = whole_fond.HL_fond_boolean_semantic_named_features
    n = len(HL_fond_boolean_semantic_named_features)
    all_HL_normal_fond_acts = whole_fond.all_HL_normal_fond_acts
    each_pair_of_Hs_Action_name = set()
    # tranverse every abstract action and generate the verification files:
    for hs_id, low_act2hs_list in all_HL_normal_fond_acts.items():
        # print(type(hs))
        # print(type(low_act2hs_list))
        FOL_formula_cnf_left = 'And('
        hs = return_highstate_from_hs_int(hs_id,parser)
        for each_fond_predicate,true_or_false in hs.highState.items():
            if each_fond_predicate in refinementMap_Dict.keys():
                if true_or_false == True:
                    each_FOL_formula_cnf = refinementMap_Dict[each_fond_predicate]
                    each_FOL_formula_cnf = each_FOL_formula_cnf
                else:
                    each_FOL_formula_cnf = refinementMap_Dict[each_fond_predicate]
                    each_FOL_formula_cnf = 'Not(' +each_FOL_formula_cnf+')'
                FOL_formula_cnf_left += '\n    '+each_FOL_formula_cnf+','
        if FOL_formula_cnf_left[-1] == ',':
            FOL_formula_cnf_left = FOL_formula_cnf_left[0:-2]
        FOL_formula_cnf_left += ')'

        FOL_formula_cnf_left += ')' # 'And('
        if len(low_act2hs_list) == 1:
            for action_name,_ in low_act2hs_list.items():
                poss_formula = LowActs2Poss[action_name]
                write_hsMapping_actPoss_json(FOL_formula_cnf_left,poss_formula,parser,hs_id,action_name)
                each_pair_of_Hs_Action_name.add((hs_id,action_name))
        else:
            for action_name,_ in low_act2hs_list.items():
                poss_formula = LowActs2Poss[action_name]
                write_hsMapping_actPoss_json(FOL_formula_cnf_left,poss_formula,parser,hs_id,action_name)
                each_pair_of_Hs_Action_name.add((hs_id,action_name))
    # write template.py
    write_template_py(parser,myVar2Types)
    write_IG_template_py(parser,myVar2Types)
    
    # fill template.py with configuration LOW_THEOREM & HIG_THEOREM " hsMapping_actPoss_json(hs,action_name).json"
    for each_pair in each_pair_of_Hs_Action_name:
        hs_id = each_pair[0]
        action_name = each_pair[1]
        autogenerator_python_prove_file(parser.domain_name, hs_id, action_name,parser)


def return_highstate_from_hs_int(hs_id,parser):
    def dec2bin(num:int()):
        l = []
        if num < 0:
            return '-' + dec2bin(abs(num))
        while True:
            num, remainder = divmod(num, 2)
            l.append(str(remainder))
            if num == 0:
                return l#''.join(l[::-1])
    from HigState import HigState
    from collections import OrderedDict
    hs = HigState()
    fond_predicate_order = ['vStart','vGoal']
    for fond_predicate,_ in parser.fond_predicates.items():
        fond_predicate_order.append(fond_predicate)
    hs.fond_predicate_order = fond_predicate_order
    # Dec 2 Bin: in fond_predicate_order
    hs.highStateid = copy.deepcopy(hs_id)
    highState_OrderedDict = OrderedDict()
    for each in fond_predicate_order:
        highState_OrderedDict[each] = False
    hs_list = dec2bin(hs_id) # reverserd
    index_fond_predicates = -1
    for each in hs_list: 
        if each == '1':
            highState_OrderedDict[fond_predicate_order[index_fond_predicates]] = True
        index_fond_predicates = index_fond_predicates - 1
        if abs(index_fond_predicates) > len(hs_list):
            break
    hs.highState = highState_OrderedDict
    hs.highPredicates = set()
    for k,_ in highState_OrderedDict.items():
        hs.highPredicates.add(k)
    return hs
def get_invert_dict(each_v_i2act_parameters:dict()):
    act_parameters2each_v_i = dict()
    for each_k,each_item in each_v_i2act_parameters.items():
        act_parameters2each_v_i[each_item] = each_k
    return act_parameters2each_v_i

# ==========================================================
# write_hsMapping_actPoss_json
# ==========================================================

def write_hsMapping_actPoss_json(FOL_formula_cnf_left,poss_formula,parser,hs,action_name):
    cur_json_path =  "./autogenerated/domain_steps_configJSON/{0}_{1}_{2}_poss.json".format(parser.domain_name,hs,action_name)
    json_obj = {
        "file_name":cur_json_path,
        "HIG_THEOREM" : FOL_formula_cnf_left ,
        "LOW_THEOREM" : poss_formula, # right
        "domain_name" : parser.domain_name,
        "hs_id" : hs,
        "action_name" : action_name
    }
    with open(cur_json_path, mode='w',encoding='utf-8') as fs:
        fs.write(json.dumps(json_obj,ensure_ascii=False,indent=1))

# ==========================================================
# write template py
# ==========================================================
def write_template_py(parser,myVar2Types):
    """ 'poss' writed template py.
        write_template_py(template_py_to_be_writed,hig_name,each_hig_func_number,hig_num_prove_dict) """
    template_py_to_be_writed = r"{0}/autogenerated/domain_template/{1}_poss_template.py".format(\
                        os.path.dirname(os.path.abspath(__file__)), parser.domain_name)
    with open(template_py_to_be_writed,'w',encoding = 'utf-8') as templatefile:
        # The fixed head tags
        templatefile.write('# -*- coding: UTF-8 -*-\n')
        templatefile.write('#!/usr/bin/env python\n')
        templatefile.write('#-------------------------------------------------------------------------------\n')
        templatefile.write('# Name:        Automatic verification of $m(hs_\{pre\}) \impolies Poss(a_k)$ for FOND Abstraction.\n')
        templatefile.write('# Author:      this file is autogenerated by "PossVerification.py/autogenerator_python_prove_file()"\n')
        templatefile.write('# Created:     ' + time.strftime("%a %b %d %H:%M:%S %Y", time.localtime()) +'\n' )
        templatefile.write('# Copyright:   (c) Tridu33 2022\n')
        templatefile.write('# Licence:     <MIT licence>\n')
        templatefile.write('#-------------------------------------------------------------------------------\n')
        templatefile.write('from z3 import *\n')
        templatefile.write('from func_timeout import func_set_timeout\n')
        templatefile.write('import func_timeout,time,os\n')
        sys.path.append("..")
        templatefile.write('\n')

        # ==================================================================================  declare objs 2 types
        allVarConstants2Types = dict()# Dict(): for preprocess/define/DeclareSort()Cons()EnumSort()  
        allVarConstants2Types.update(parser.constants)
        allVarConstants2Types.update(parser.ConsForSorts) # Require global different variables can not be used for a while? x represents type one, which will be used for a while? x represents type two
        allVarConstants2Types.update(myVar2Types)

        allclassTypes = []
        templatefile.write('\n')
        # Dict:[x y ,...]--> theRightType
        for key,value in allVarConstants2Types.items():
            if value not in allclassTypes:
                allclassTypes.append(value)
                templatefile.write('{0} = DeclareSort("{0}")\n'.format(value))
            if key[0] == '?':
                templatefile.write('{0} = Const(\'{0}\', {1})\n'.format(key[1:],value))
            else:
                templatefile.write('{0} = Const(\'{0}\', {1})\n'.format(key,value))
        templatefile.write('\n')

        # ================================================================================== Predicates
        templatefile.write('# declare Predicates \n')
        for key,value in parser.predicates.items():
            if not value:
                templatefile.write('{0} = Bool(\'{0}\')\n'.format(key)) 
            else:
                parser_predicates_TypeInput = str()
                for TypeValues in value.values():
                    parser_predicates_TypeInput += ',' + TypeValues
                templatefile.write('{0} = Function(\'{0}\'{1},BoolSort())\n'.format(key,parser_predicates_TypeInput)) 

        # =============== load constrain axtioms         
        templatefile.write('\n')
        templatefile.write('# load and exec domain constraint file of \"{0}\" given by users(background information).\n'.format(parser.domain_name))
        templatefile.write('grader_father_src_path = os.path.abspath(os.path.dirname(__file__)+os.path.sep+"..")\n')
        templatefile.write('for line in open(\'./constrainsConfig/{0}_constrain.txt\',\'r\'): \n'.format(parser.domain_name)) 
        #templatefile.write('for line in open(grader_father_src_path+"/constrainsConfig/%(domain_name)s_constrain.txt",\'r\'): \n')
        templatefile.write('    exec(line)\n')

        # ================ 
        timeout_number = 1000
        templatefile.write('@func_set_timeout({0})\n'.format(timeout_number)) # timeout_number =  1000 s 
        templatefile.write('def myprove(f):\n')
        templatefile.write('    s = Solver()\n')
        templatefile.write('    s.add(Not(f))\n')
        templatefile.write('    # print(s.sexpr())\n')
        templatefile.write('    if s.check() == unsat:\n')
        templatefile.write('        del s\n')
        templatefile.write('        print(os.path.basename(__file__)[:-3]+" is proved.")\n')
        templatefile.write('    else:\n')
        templatefile.write('        print(os.path.basename(__file__)[:-3]+" failed to prove")\n')
        templatefile.write('############################### start to prove! ####################################\n')
        templatefile.write('hig = %(HIG_THEOREM)s\n')
        templatefile.write('low = %(LOW_THEOREM)s\n')
        templatefile.write('goal = And(\n')
        templatefile.write('    Implies(\n')
        templatefile.write('        And(constraint,simplify(hig)),\n')
        templatefile.write('        low\n')
        templatefile.write('    )\n')
        templatefile.write(')\n')

        templatefile.write('try:\n')
        templatefile.write('    # print(simplify(goal))\n')
        templatefile.write('    myprove(goal)\n')
        templatefile.write('except func_timeout.exceptions.FunctionTimedOut:\n')
        templatefile.write('    print(\'timeout and unknown,please open \\\'\'+os.path.basename(__file__)+\'\\\' and try.\')\n')

        templatefile.close()
        COMMAND_RUN = 'notepad {0}'.format(template_py_to_be_writed)
        #os.system(COMMAND_RUN) # automatic open and see the template_py_to_be_writed file.


# ==========================================================
# write template py
# ==========================================================
def write_IG_template_py(parser,myVar2Types):
    """ 'poss' writed template py.
        write_template_py(template_py_to_be_writed,hig_name,each_hig_func_number,hig_num_prove_dict) """
    template_py_to_be_writed = r"{0}/autogenerated/domain_template/{1}_IG_template.py".format(\
                        os.path.dirname(os.path.abspath(__file__)), parser.domain_name)
    with open(template_py_to_be_writed,'w',encoding = 'utf-8') as templatefile:
        # The fixed head tags
        templatefile.write('# -*- coding: UTF-8 -*-\n')
        templatefile.write('#!/usr/bin/env python\n')
        templatefile.write('#-------------------------------------------------------------------------------\n')
        templatefile.write('# Name:        Automatic verification of $m(hs_\{pre\}) \impolies Poss(a_k)$ for FOND Abstraction.\n')
        templatefile.write('# Author:      this file is autogenerated by "PossVerification.py/autogenerator_python_prove_file()"\n')
        templatefile.write('# Created:     ' + time.strftime("%a %b %d %H:%M:%S %Y", time.localtime()) +'\n' )
        templatefile.write('# Copyright:   (c) Tridu33 2022\n')
        templatefile.write('# Licence:     <MIT licence>\n')
        templatefile.write('#-------------------------------------------------------------------------------\n')
        templatefile.write('from z3 import *\n')
        templatefile.write('from func_timeout import func_set_timeout\n')
        templatefile.write('import func_timeout,time,os\n')
        sys.path.append("..")
        templatefile.write('\n')

        # ==================================================================================  declare objs 2 types
        allVarConstants2Types = dict()# Dict(): for preprocess/define/DeclareSort()Cons()EnumSort()  
        allVarConstants2Types.update(parser.constants)
        allVarConstants2Types.update(parser.ConsForSorts) # Require global different variables can not be used for a while? x represents type one, which will be used for a while? x represents type two
        allVarConstants2Types.update(myVar2Types)

        allclassTypes = []
        templatefile.write('\n')
        # Dict:[x y ,...]--> theRightType
        for key,value in allVarConstants2Types.items():
            if value not in allclassTypes:
                allclassTypes.append(value)
                templatefile.write('{0} = DeclareSort("{0}")\n'.format(value))
            if key[0] == '?':
                templatefile.write('{0} = Const(\'{0}\', {1})\n'.format(key[1:],value))
            else:
                templatefile.write('{0} = Const(\'{0}\', {1})\n'.format(key,value))
        templatefile.write('\n')

        # ================================================================================== Predicates
        templatefile.write('# declare Predicates \n')
        for key,value in parser.predicates.items():
            if not value:
                templatefile.write('{0} = Bool(\'{0}\')\n'.format(key)) 
            else:
                parser_predicates_TypeInput = str()
                for TypeValues in value.values():
                    parser_predicates_TypeInput += ',' + TypeValues
                templatefile.write('{0} = Function(\'{0}\'{1},BoolSort())\n'.format(key,parser_predicates_TypeInput)) 

        # =============== load constrain axtioms         
        templatefile.write('\n')
        templatefile.write('# load and exec domain constraint file of \"{0}\" given by users(background information).\n'.format(parser.domain_name))
        templatefile.write('grader_father_src_path = os.path.abspath(os.path.dirname(__file__)+os.path.sep+"..")\n')
        templatefile.write('for line in open(\'./constrainsConfig/{0}_constrain.txt\',\'r\'): \n'.format(parser.domain_name)) 
        #templatefile.write('for line in open(grader_father_src_path+"/constrainsConfig/%(domain_name)s_constrain.txt",\'r\'): \n')
        templatefile.write('    exec(line)\n')

        # ================ 
        timeout_number = 1000
        templatefile.write('@func_set_timeout({0})\n'.format(timeout_number)) # timeout_number =  1000 s 
        templatefile.write('def myprove(f):\n')
        templatefile.write('    s = Solver()\n')
        templatefile.write('    s.add(Not(f))\n')
        templatefile.write('    # print(s.sexpr())\n')
        templatefile.write('    if s.check() == unsat:\n')
        templatefile.write('        del s\n')
        templatefile.write('        print(os.path.basename(__file__)[:-3]+" is proved.")\n')
        templatefile.write('    else:\n')
        templatefile.write('        print(os.path.basename(__file__)[:-3]+" failed to prove")\n')
        templatefile.write('############################### start to prove! ####################################\n')
        templatefile.write('hig = %(HIG_THEOREM)s\n')
        templatefile.write('low = %(LOW_THEOREM)s\n')
        templatefile.write('goal = And(\n')
        templatefile.write('    Implies(\n')
        templatefile.write('        And(constraint,simplify(low)),\n')
        templatefile.write('        hig\n')
        templatefile.write('    )\n')
        templatefile.write(')\n')

        templatefile.write('try:\n')
        templatefile.write('    # print(simplify(goal))\n')
        templatefile.write('    myprove(goal)\n')
        templatefile.write('except func_timeout.exceptions.FunctionTimedOut:\n')
        templatefile.write('    print(\'timeout and unknown,please open \\\'\'+os.path.basename(__file__)+\'\\\' and try.\')\n')

        templatefile.close()
        COMMAND_RUN = 'notepad {0}'.format(template_py_to_be_writed)
        #os.system(COMMAND_RUN) # automatic open and see the template_py_to_be_writed file.


def autogenerator_python_prove_file(domainname, hs_id, action_name,parser):
    """generate the python_prove*_file we want
    using "jsonfiles" and "path_of_template_py", function autogenerator_python_prove_file will generate goals of provefiles in "./autogenerated/{0}_*.py".format(domainname)
    """
    config = {} 
    # 1. read config : get hsMapping_actPoss_json(hs,action_name).json 
    json_file =  "./autogenerated/domain_steps_configJSON/{0}_{1}_{2}_poss.json".format(parser.domain_name,hs_id,action_name)
    with codecs.open(json_file,"rb","UTF-8") as f: 
        config = json.loads(f.read())
    if not config:
        return

    # 2. read template.py file
    s = ""
    path_of_template_py = r"{0}/autogenerated/domain_template/{1}_poss_template.py".format(\
                        os.path.dirname(os.path.abspath(__file__)), parser.domain_name)
    with codecs.open(path_of_template_py, "rb", "UTF-8") as f:
        s = f.read()
    if not s:
        return
    # 3. replace template.py with config
    s = s % config    # save to file
    fn = r"{0}/autogenerated/{1}_{2}_{3}_poss.py".format(\
            os.path.dirname(os.path.abspath(__file__)), parser.domain_name,hs_id,action_name)
    with codecs.open(fn, "wb", "UTF-8") as f:
        f.write(s)
        f.flush()

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
                with open(path, 'rb') as read_stream:
                    contents = read_stream.read()
                    path1 = os.path.join(target_path, file)
                    with open(path1, 'wb') as write_stream:
                        write_stream.write(contents)
        return     True    
    else:
        return False    
