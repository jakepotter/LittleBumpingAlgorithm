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

    def plot(self):
        """Plot the line diagram of the given word list.
        For best effect:
        l = LCD(word); p = l.plot(); p.show(gridlines=True)
        """
        max_x = len(self.word)
        max_y = max(self.word) + 1 # max swap moves from max_y -> max_y + 1
        ordering = list(range(1,max_y+1))
        c_x = 0
        p = Graphics()
        for idx in range(len(self.word)):
            s = self.word[idx]
            for l in range(1,max_y+1):
                if l == s or l == s+1:
                    continue
                p = p + line([[c_x, l],   [c_x+1, l]])

            p = p + line([[c_x, s  ],   [c_x+1, s+1]])
            p = p + line([[c_x, s+1],   [c_x+1, s  ]])
            tmp = ordering[s-1]
            ordering[s-1] = ordering[s]
            ordering[s] = tmp
            c_x += 1
        for oidx in range(len(ordering)):
            p = p + text(str(ordering[oidx]), (max_x+0.1, oidx+1),
                         horizontal_alignment='right')
        print("Final permutation is {}".format(ordering))
        return(p)

if __name__ == "__main__":
    pass

