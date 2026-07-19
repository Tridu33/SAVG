source ../.venv/bin/activate
python main.py -domainname blocks_clear -cpn 1 -deletehistory False -debug True
python main.py -domainname llvisitall -cpn 3 -deletehistory False -debug True
python main.py -domainname reversell -cpn 1 -deletehistory False -debug True
python main.py -domainname stripedtower -cpn 4 -deletehistory False -debug True 
python main.py -domainname treetraversal -cpn 4 -deletehistory False -debug True 
python main.py -domainname RGBBlocks -cpn 4 -deletehistory False -debug True 
python main.py -domainname TreeChop -cpn 2 -deletehistory False -debug True

@REM python main.py -domainname blocks_clear2 -cpn 1 -deletehistory False -debug True -planner FONDASP
@REM python main.py -domainname RGBBlocks2 -cpn 4 -deletehistory False -debug True -planner FONDASP

python main.py -domainname NestedVar -cpn 4 -deletehistory False -debug True 
python main.py -domainname Snow -cpn 4 -deletehistory False -debug True 
python main.py -domainname DeliveryFuel -cpn 4 -deletehistory False -debug True 
python main.py -domainname TrashCollection -cpn 4 -deletehistory False -debug True 