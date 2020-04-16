import sys

size1,size2 = sys.argv[1],sys.argv[2]
bit_width = int(sys.argv[3])
mat1 = [int(s) for s in size1.split('x')]
mat2 = [int(s) for s in size2.split('x')]
fp = False
qnum = []
if "-f" in sys.argv:
    fp = True
if fp:
    qnum = [int(s) for s in sys.argv[5][1:].split('.')]
    if (qnum[0] + qnum[1]) != bit_width:
        print("Error: Qnotation does not match bit width",file=sys.stderr)
        sys.exit(1)

if mat1[1] != mat2[0]:
    print("Error: Matrix size mismatch",file=sys.stderr)
    sys.exit(1)

'''
generate core multiplication
'''
assignments = []
m_size_1d = (mat1[0] * mat2[1] * bit_width  - 1)
mat1_size_1d = (mat1[0] * mat1[1] * bit_width  - 1)
mat2_size_1d = (mat2[0] * mat2[1] * bit_width - 1)

for i in range(mat1[0]):
    for j in range(mat2[1]):
        sums = []
        for k in range(mat1[1]):
            alsb = mat1_size_1d - ((i*mat1[0] + k + 1) * bit_width - 1)
            amsb = mat1_size_1d - ((i*mat1[0] + k) * bit_width)
            blsb = mat2_size_1d - ((k*mat2[0] + j + 1) * bit_width - 1)
            bmsb = mat2_size_1d - ((k*mat2[0] + j) * bit_width)
            if fp:
                sums.append("(A[{}:{}] * B[{}:{}])")
            else:
                sums.append(f"(A[{amsb}:{alsb}] * B[{bmsb}:{blsb}])")
        mlsb = m_size_1d - ((i*mat1[0] + j + 1) * bit_width - 1)
        mmsb = m_size_1d - (i*mat1[0] + j) * bit_width
        sums = " + ".join(sums)
        assignments.append(f"\tassign M[{mmsb}:{mlsb}] = {sums};\n")
assignments = "".join(assignments)
'''
print to file
'''
'''
print model and register definitions
'''
name = "matmul_{}by{}".format(size1,size2)
print(f'''
//Module for Calculating M = A*B
//A is a {size1} matrix, B is a {size2} matrix, M is a {mat1[0]}x{mat2[1]} matrix
module {name}(A,B,M);
\t//input and outputs
\tinput wire [{mat1_size_1d}:0] A;\t//A is {mat1_size_1d+1} bits, for {mat1[0]}*{mat1[1]}={mat1[0]*mat1[1]} elements, each of which is {bit_width} bits wide
\tinput wire [{mat2_size_1d}:0] B;\t//B is {mat2_size_1d+1} bits, for {mat2[0]}*{mat2[1]}={mat2[0]*mat2[1]} elements, each of which is {bit_width} bits wide
\toutput wire [{m_size_1d}:0] B;\t//M is {m_size_1d+1} bits, for {mat1[0]}*{mat2[1]}={mat1[0]*mat2[1]} elements, each of which is {bit_width} bits wide
{assignments}
endmodule
''')


def print_usage():
    print("Usage: python3 generate_matmul.py N1xN2 N2xN3 bit_width (-f QI.F)")