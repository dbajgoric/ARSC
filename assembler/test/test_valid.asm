// Another comment
//ANCHOR 0
// A comment
BEGIN:// A comment
LDA A
WHATEVS:
ADD B
ADD C
STA D
ADD *A
LDX B,3
TDX D, 3
TIX *W,1
BRU WHATEVS
HLT
A   BSC 5
B   BSC 7, -4, 34
U   ALIAS 10
H   ALIAS B
Y   ALIAS A +   3
M   ALIAS A - 5
C   BSC -3
D   BSS 10
W   BSS 1
END BEGIN