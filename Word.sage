load('LCD.sage')

#a Word object is a (reduced) word with which we can start the Little Bumping Algorithm
class Word(object):
    def __init__(self, word, n = -1):
        self.word = word
        m = len(word)
        self.sigma = permutation.from_reduced_word(word)

        if n == -1:
            n = self.sigma.size() #set size if no size was provided
        assert (n >= self.sigma.size()), "!!! The imposed size is too small !!!"
        self.size = n

        #ensure self.sigma has the correct size by multiplying by the identity of S_n
        self.sigma = self.sigma.left_action_product(Permutations(n).identity())

        self.lcd = LCD(word, self.size)
        self.reduced = self.lcd.reduced

        self.Grassmanian = True
        #descents is a list of all i such that sigma(i) > sigma(i+1)
        descents = []
        for i in range(1, self.size):
            if self.sigma(i) > self.sigma(i+1):
                descents += [i]
        if len(descents) > 1:
            self.Grassmanian = False
        if descents == []:
            print "!!!Warning: the identity permutation may not act as expected!!!"
        self.descents = descents

    def Bump(self, t):
        bumpedWord = self.word[:] #copy of w.word list
        resize = False
        #times t are all indexed starting from 1
        if self.word[t-1] == 1:
            for i in range(len(self.word)):
                bumpedWord[i] += 1
            resize = True
        bumpedWord[t-1] -= 1
        return Word(bumpedWord, self.size + resize) #adds 1 to size if needed


    def LBA(self):
        #define r (from the Little algorithm)
        r = 0
        for i in range(1,self.size):
            if self.sigma(i) > self.sigma(i+1):
                r = i

        #define s (from the Little algorithm)
        s = r + 1
        for i in range(r+2,self.size+1):
            if self.sigma(i) < self.sigma(r):
                s = i
        sigma_s = self.sigma(s)

        wordList = [self]
        #times[i] is the "time" where the ith bump takes place.
        #Values are in {1,2,...,m} where m is the length of the word.
        #Also, diagram indices start at 1.
        t = self.lcd.diagram[sigma_s - 1][r - 1]
        if t == 'X' or t == '-':
            print "!!!!!!!!!!!!!!!!! SOMETHING WENT WRONG (outside)!!!!!!!!!!!!!!!!!", "t = ", t
        times = [int(t)]

        #keep bumping until the word is reduced
        while True: 
            v = wordList[-1].Bump(times[-1])
            wordList += [v]

            #stop if the word is reduced
            if v.reduced: 
                break
            t = v.lcd.diagram[sigma_s - 1][r - 1]
            if t == 'X' or t == '-':
                print "!!!!!!!!!!!!!!!!! SOMETHING WENT WRONG (inside)!!!!!!!!!!!!!!!!!", "t = ", t
            times += [int(t)]
        return wordList[-1]


    #returns a list which is a path down the L-S tree to a leaf (Grassmanian permutation)
    def LStraversal(self):
        path = [self]
        while not path[-1].Grassmanian:
            path += [path[-1].LBA()]
        part = path[-1].FindPartition()
        return path, part


    #returns the partition (as a tuple) corresponding to the final (Grassmanian) permutation
    def FindPartition(self):
        part = []
        loc = self.descents[0] #the location of the (only) descent
        for i in range(loc, self.size):
            p = 0
            for j in range(loc):
                if self.sigma(i+1) < self.sigma(j+1):
                    p += 1
            if p > 0:
                part += [p]
        return tuple(part)


    def __repr__(self):
        ret = ""
        for i in self.word:
            ret += " %d" % (i)
        return ret


    def __eq__(self, other):
        if self.word == other.word:
            return True
        return False


#Given a permutation, print out partitions corresponding to leaves of the L-S tree 
#and number of reduced words for sigma corresponding to each of these partitions.
def LittleCorrespondence(sigma = -1):
    if sigma == -1:
        print "Using default permutation: [2,4,1,6,5,7,3]"
        sigma = Permutation([2,4,1,6,5,7,3])
    leaves = {}
    for w in sigma.reduced_words():
        word = Word(w)
        path, part = word.LStraversal()
        if part in leaves:
            leaves[part] += [w]
            continue
        leaves[part] = [w]
    #row1Max is used for lining up text output
    row1Max = 0
    for part in leaves:
        if row1Max < part[0]:
            row1Max = part[0]

    #print out results (partitions along with frequency)
    for part in leaves:
        firstRow = True
        print "-----------------------"
        for p in part:
            row = ""
            for i in range(p):
                row += "#"
            if firstRow:
                for i in range(row1Max - p):
                    row += " "
                row += "  x%d" % (len(leaves[part]))
                firstRow = False
            print row
    print "-----------------------"



