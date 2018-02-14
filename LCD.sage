import sage.combinat.permutation as permutation

class LCD(object):
    def __init__(self, word):
    #word should be a list of integers between 1 and n-1 representing an 
    #ordering of adjacent transpositions that form a permutation (sigma) in S_n
        self.word = word
        m = len(word)
        self.sigma = permutation.from_reduced_word(word)
        self.sigmaInverse = self.sigma.inverse()
        n = self.sigma.size()
        self.size = n
        mat = self.sigma.to_matrix()
        self.reduced = True

        #define r (from the Little algorithm)
        r = 0
        for i in range(1,n):
            if self.sigma(i) > self.sigma(i+1):
                r = i
        self.r = r

        #define s (from the Little algorithm)
        s = r + 1
        for i in range(r+2,n+1):
            if self.sigma(i) < self.sigma(r):
                s = i
        self.s = s

        #create the circle diagram
        diagram = []
        for matRow in mat:
            row = []
            switch = False
            for entry in matRow:
                if entry == 1:
                    row += ['X']
                    switch = True
                if entry == 0:
                    if switch:
                        row += ['-']
                    else:
                        row += ['0'] 
            diagram += [row]
        for i in range(n):
            for j in range(n):
                if diagram[i][j] == 'X':
                    for k in range(i+1,n):
                        diagram[k][j] = '-'
                    continue

        #circle diagram ~> labeled circle diagram
        partial_permutations = []
        g = Permutations(n).identity()
        #partial_permutations += [g]
        for i in range(m):
            h = Permutation( [(word[i],word[i]+1)] )
            g = g.left_action_product(h)
            partial_permutations += [g]
        
        for i in range(m):
            row = partial_permutations[i](word[i]+1)
            col = self.sigmaInverse(partial_permutations[i](word[i]))
            if diagram[row - 1][col - 1] == '0':
                diagram[row - 1][col - 1] = '%d' % (i+1)
            else:
                self.reduced = False
                diagram[row - 1][col - 1] = '%d' % (i+1)
        self.diagram = diagram


    #def __str__(self):
    #    return "%d + %di + %dj + %dk" % (self.real_part, self.i_part, 
    #            self.j_part, self.k_part)

    def __repr__(self):
        ret = "\n"
        for i in range(self.size):
            row = ""
            for j in range(self.size):
                row += "   "
                row += self.diagram[i][j]
                if row[-1] != '*':
                    row += " "
            row += "\n"
            if i != self.size - 1:
                row += "\n"
            ret += row
        return ret

    #def __add__(self, other):
    #    real_part = self.real_part + other.real_part
    #    i_part = self.i_part + other.i_part
    #    j_part = self.j_part + other.j_part
    #    k_part = self.k_part + other.k_part
    #    return Quaternion(real_part, i_part, j_part, k_part)


if __name__ == "__main__":
    pass












