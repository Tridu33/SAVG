import copy 
class T9backtracking:
    def __init__(self,letter_map):
        self.answers : list() = []
        self.answer: dict() = dict()
        self.letter_map = letter_map

    def letterCombinations(self, digits: str)->list():
        self.answers.clear()
        if not digits: return []
        self.backtracking(digits, 0)
        return self.answers
    
    def backtracking(self, digits: str, index: int) -> None:
        # The backtracking function has no return value
        # Base Case
        if index == len(digits):    #  When traversing the next layer after exhaustion
            self.answers.append(copy.deepcopy(self.answer))
            # print(type(self.answer))
            return 
        # Single-layer recursive logic  
        letters: list() = self.letter_map[digits[index]]
        for letter in letters:
            cur_letter:dict() = letter
            self.answer.update(cur_letter)   #  Union Merge Here is an unordered set of merges, and the order of the keys does not affect the uniqueness of the result of the final combination.
            self.backtracking(digits, index + 1)    # Recursive to the next layer
            for k in cur_letter.keys():
                self.answer.pop(k)  #  The difference set --- backtracking



if __name__ == '__main__':
    letter_map:dict() = {
                '2': [{'2':'a'},{'2':'b'},{'2':'c'}],
                '3': [{'3':'d'},{'3':'e'},{'3':'f'}],
                '4': [{'4':'g'},{'4':'h'},{'4':'i'}],
                '5': [{'5':'j'},{'5':'k'},{'5':'l'}],
                '6': [{'6':'m'},{'6':'n'},{'6':'o'}],
                '7': [{'7':'p'},{'7':'q'},{'7':'r'},{'7':'s'}],
                '8': [{'8':'t'},{'8':'u'},{'8':'v'}],
                '9': [{'9':'w'},{'9':'x'},{'9':'y'},{'9':'z'}]
    }
    sol = T9backtracking(letter_map)
    digits = []
    for each_char in letter_map.keys():
        digits.append(each_char) 
    res = sol.letterCombinations(digits)
    import pprint
    pp = pprint.PrettyPrinter(indent=4)
    # pp.pprint(res)
    print(len(res) == 3*3*3*3*3*4*3*4)

    # digits = "23456789"
    # res1= sorted(sol.letterCombinations(digits))
    # print(res1)

    # digits = "98765432"
    # res2= sorted(sol.letterCombinations(digits))
    # print(res2)

    # print(list(res1) == list(res2))
    # print(list(res1) == list(res3))
