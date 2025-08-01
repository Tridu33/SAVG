Main Page {#mainpage}
=========

[TOC]



```bash
# PRP_planner-for-relevant-policies
sudo apt install -y python2 graphviz 
# FOND-ASP  
conda create -n potassco -c potassco clingo psutil pandas
conda activate potassco
```



Installation dependencies:

```cmd
pip install z3 z3-solver==4.8.10.0 networkx func_timeout matplotlib 
```

Based on python3.8, this tool automatically verifies whether high-level modeling is a "sound abstraction" corresponding to low-level models. 
Some windows users may need the following installation scripts if they are not using miniconda:

```
python -m pip install z3 z3-solver==4.8.10.0 networkx func_timeout matplotlib 
```

Parameters:

```cmd
>python main.py --help
usage: main.py [-h] [-domainname DOMAINNAME] [-cpn CPN] [-deletehistory DELETEHISTORY] [-debug DEBUG]
               [-planner PLANNER]

code autoGenerator

optional arguments:
  -h, --help            show this help message and exit
  -domainname DOMAINNAME
                        Path to fond domain files(default=dfs). -- OPTIONAL
  -cpn CPN              number of classical plans,like '3' for '*p1,*p2,*p3'. -- NOT OPTIONAL
  -deletehistory DELETEHISTORY
                        delete history output files or not. -- OPTIONAL
  -debug DEBUG          print DEBUG message or not. -- OPTIONAL FOR TEST
  -planner PLANNER      PRP(fairness) or FONDASP(conditional fairness). -- OPTIONAL FOR TEST
```

## System function introduction

The main algorithm of the FOND$^{+}$ generation and verification, including two fucntions Function $cps2fond$ and $verify$.

Function $cps2fond$ for FOND$^+$ abstraction generation consists of four steps as follows:

- For each instance $p_i \in \mathcal{P}$, traverse every reachable concrete states and its state transitions from $p_i$, and get the sampled abstract state transitions graph $\mathcal{E}(p_i)$  with the given $m$;
- Merge all $\mathcal{E}(p_i)$ for the state transitions graph $\mathcal{E}_{fond}$;
- Get the FOND$^+$ planning problem from $\mathcal{E}_{fond}$;

If all passed it returns the FOND$^+$ problem $\mathcal{G}_h$,else it returns $No$ which means the refinement mapping $m$ given is is not fine-grained enough.
- Function $verify$ will firstly check whether each action $a \in A$ satisfies the formula $m(s_h) \supset \exists \vec{x}.Poss(a_k(\vec{x}))$, where $Poss(a_k(\vec{x}))$ means a formula describing the precondition of low-level action $a_k$.	
- Function $verify$ also check whether the conjunctive normal form of all initial states(goals) from any classical planning instance of  $\mathcal{P}$ and the first order formula $\phi_{I}$ describing the initial state(goal) of the original generalized planning is equivalent, respectively.
Let $\phi_{I}$($\phi_{G}$) denotes the first order formula describing the initial state $S_0$(goal $G$) in the original generalized planning problem, there is $m$ instances in $\mathcal{S}$, then we need to verify the $m(hs_I^1,...,hs_I^m) \supset \phi_{I}$ and $m(hs_G^1,...,hs_G^m) \supset \phi_{G}$.

## The Main Process and usage

```cmd
python main.py -domainname blocks_clear -cpn 1 -deletehistory False -debug True
python main.py -domainname llvisitall -cpn 3 -deletehistory False -debug True
python main.py -domainname reversell -cpn 1 -deletehistory False -debug True
python main.py -domainname stripedtower -cpn 4 -deletehistory False -debug True 
python main.py -domainname treetraversal -cpn 4 -deletehistory False -debug True 
python main.py -domainname RGBBlocks -cpn 4 -deletehistory False -debug True 

python main.py -domainname blocks_clear2 -cpn 1 -deletehistory False -debug True -planner FONDASP
python main.py -domainname RGBBlocks2 -cpn 4 -deletehistory False -debug True -planner FONDASP

```

the out put files is under folder `autogenerated`.

## get the policy

### by PRP

```bash
./RunPRPForCurDomain.sh llvisitall
./PrintHuman_Policy.sh llvisitall
python ./DrawDotPolicy.py -domainname llvisitall

./RunPRPForCurDomain.sh reversell
./PrintHuman_Policy.sh reversell
python ./DrawDotPolicy.py -domainname reversell

./RunPRPForCurDomain.sh blocks_clear
./PrintHuman_Policy.sh blocks_clear
python ./DrawDotPolicy.py -domainname blocks_clear

./RunPRPForCurDomain.sh stripedtower
./PrintHuman_Policy.sh stripedtower
python ./DrawDotPolicy.py -domainname stripedtower

./RunPRPForCurDomain.sh treetraversal
./PrintHuman_Policy.sh treetraversal
python ./DrawDotPolicy.py -domainname treetraversal

./RunPRPForCurDomain.sh RGBBlocks
./PrintHuman_Policy.sh RGBBlocks
python ./DrawDotPolicy.py -domainname RGBBlocks


```

out files is generated under folder `solutionsByPRP`

### by FOND-ASP

copy `fond_RGBBlocks2_d.pddl` and `fond_RGBBlocks2_p.pddl` to folder `/mnt/d/FOND-ASP/domains/pddl/autogenerated/`,  ` cd /mnt/d/FOND-ASP `and run:

```
$ python -m fcfond.main -stats -out output.RGBBlocks2 -planner fcfond/planner_clingo/fondplus_show_pretty.lp -pddl domains/pddl/autogenerated/fond_RGBBlocks2_d.pddl domains/pddl/autogenerated/fond_RGBBlocks2_p.pddl 
$ python -m fcfond.main -stats -out output.block_clear -planner fcfond/planner_clingo/fondplus_show_pretty.lp -pddl domains/pddl/autogenerated/fond_blocks_clear2_d.pddl domains/pddl/autogenerated/fond_blocks_clear2_p.pddl

```

output is the file `output.RGBBlocks2/stdout-asp.txt`.
