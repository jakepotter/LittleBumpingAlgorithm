import sage.combinat.permutation as permutation

class LCD(object):
    def __init__(self, word, n):
    #word should be a list of integers between 1 and n-1 representing an 
    #ordering of adjacent transpositions that form a permutation (sigma) in S_n
        self.word = word
        m = len(word)
        self.sigma = permutation.from_reduced_word(word)
        assert (n >= self.sigma.size()), "!!! The imposed size is too small !!!"
        self.size = n

        #ensure self.sigma has the correct size by multiplying by the identity of S_n
        self.sigma = self.sigma.left_action_product(Permutations(n).identity())

        self.sigmaInverse = self.sigma.inverse()
        mat = self.sigma.to_matrix()
        self.reduced = True

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

        #set locations for dots (for pretty print)
        dots = []
        for i in range(n):
            for j in range(n):
                if diagram[i][j] == '-':
                    dots += [(i+1,j+1)]
        self.dots = dots

        #circles is a list of locations and labels of circles (for pretty print)
        circles = []

        #turn the circle diagram into a labeled circle diagram
        partial_permutations = []
        g = Permutations(n).identity()
        for i in range(m):
            h = Permutation( [(word[i],word[i]+1)] )
            g = g.left_action_product(h)
            partial_permutations += [g]
        for i in range(m):
            row = partial_permutations[i](word[i]+1)
            col = self.sigmaInverse(partial_permutations[i](word[i]))
            #diagram indices start at 1
            if diagram[row - 1][col - 1] != '0':
                self.reduced = False
            diagram[row - 1][col - 1] = '%d' % (i+1)
            circles += [(row, col, i+1)]
        self.diagram = diagram
        self.circles = circles


    #def __str__(self):
    #    return "%d + %di + %dj + %dk" % (self.real_part, self.i_part, 
    #            self.j_part, self.k_part)

    def __str__(self):
        ret = "\n"
        for i in range(self.size):
            row = ""
            for j in range(self.size):
                row += "    "
                row += self.diagram[i][j]
                #if row[-1] != '*':
                #    row += " "
            row += "\n"
            if i != self.size - 1:
                row += "\n"
            ret += row
        return ret


    def pp(self, scale = 1.0, includeWord = False):
        texString = "\n\\begin{tikzpicture}[very thick,"
        texString += "scale=%4.2f, every node/.style={scale=%4.2f}]\n" % (scale, 1.8*scale)
        texString += "%\\n is the number of rows/columns in diagram\n"
        texString += "\\def\\n{%d}\n\n" % self.size

        texString += "%draw grid\n"
        texString += "\\foreach \\x in {0,...,\\n} {\n"
        texString += "\\draw (\\x, -\\n) -- (\\x, 0);\n"
        texString += "\\draw (0, {-\\x}) -- (\\n, {-\\x}); }\n\n"

        texString += "%draw an 'X' in box (row,col) (presented as i/j)\n"
        texString += "\\foreach \\i/\\j in {"
        for i in range(1, self.size+1):
            if i != 1:
                texString += ", "
            texString += "%d/%d" % (i, self.sigmaInverse(i))
        texString += "} {\n"
        texString += "\\draw ({\\j-.85}, {.85-\\i}) -- ({\\j-.15}, {.15-\\i});\n"
        texString += "\\draw ({\\j-.85}, {.15-\\i}) -- ({\\j-.15}, {.85-\\i});\n"
        texString += "\\node at (-.4, {.5-\\j}) {\\j};\n"
        texString += "\\node at ({\\j-.5}, .4) {\\i};}\n\n"

        texString += "%draw a dot in box (i,j)\n"
        texString += "\\draw[fill=black] \\foreach \\i/\\j in {"
        for i in range(len(self.dots)):
            if i != 0:
                texString += ", "
            texString += "%d/%d" % self.dots[i]
        texString += "}\n"
        texString += "{({\\j-.5}, {.5-\\i}) circle(.1)};\n\n"

        texString += "%draw a labeled circle in box (i,j)\n"#good up to here
        texString += "\\draw \\foreach \\i/\\j/\\label in {"
        for i in range(len(self.circles)):
            if i != 0:
                texString += ", "
            texString += "%d/%d/%d" % self.circles[i]
        texString += "}\n"
        texString += "{({\\j-.5}, {.5-\\i}) circle(.5) node {\\label}};\n\n"

        if includeWord:
            wordString = ""
            for i in self.word:
                wordString += "%d " % i
            texString += "\\node[anchor=west] at ({\\n + 2}, {-.5*\\n}) {word = %s};\n" % wordString

        texString += "\\end{tikzpicture}\n"
        return texString


    #def __add__(self, other):
    #    real_part = self.real_part + other.real_part
    #    i_part = self.i_part + other.i_part
    #    j_part = self.j_part + other.j_part
    #    k_part = self.k_part + other.k_part
    #    return Quaternion(real_part, i_part, j_part, k_part)


if __name__ == "__main__":
    pass












