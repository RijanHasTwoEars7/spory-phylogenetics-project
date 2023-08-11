import sys

InputFileName = sys.argv[1]
AlnFileName = sys.argv[2]

def Die(s):
    print("\n", file=sys.stderr)
    print(sys.argv, file=sys.stderr)
    print("**ERROR**", s, file=sys.stderr)
    sys.exit(1)

def ReadSeqs(FileName):
    Seqs = {}
    Id = ""
    with open(FileName) as File:
        while True:
            Line = File.readline()
            if len(Line) == 0:
                return Seqs
            if len(Line) == 0:
                continue
            if Line[0] == ">":
                Id = Line[1:].strip()
                Seqs[Id] = ""
            else:
                if Id == "":
                    Die("FASTA file '{}' does not start with '>'".format(FileName))
                Seqs[Id] += Line.strip()

def ReadSeqs2(FileName):
    Seqs = []
    Labels = []
    with open(FileName) as File:
        while True:
            Line = File.readline()
            if len(Line) == 0:
                return Labels, Seqs
            Line = Line.strip()
            if len(Line) == 0:
                continue
            if Line[0] == ">":
                Id = Line[1:]
                Labels.append(Id)
                Seqs.append("")
            else:
                i = len(Seqs) - 1
                Seqs[i] += Line

InLabels, InSeqs = ReadSeqs2(InputFileName)
AlnSeqs = ReadSeqs(AlnFileName)

for Label in InLabels:
    if Label not in AlnSeqs.keys():
        Die("Not found in alignment: " + Label)
    print(">" + Label)
    print(AlnSeqs[Label])

