import sys

size1,size2 = sys.argv[1],sys.argv[2]
bit_width = int(sys.argv[3])
mat1 = [int(s) for s in size1.split('x')]
mat2 = [int(s) for s in size2.split('x')]
fp = False
if "-f" in sys.argv:
    fp = True

if mat1[1] != mat2[0]:
    print("Error: Matrix size mismatch")
    sys.exit(1)

name = "matmul_{}by{}".format(size1,size2)
print("//Module for Calculating M = A*B")
print("//A is a {} matrix, B is a {} matrix, M is a {} matrix".format(size1,size2,"{}x{}".format(mat1[0],mat2[1])))
print("module {}(A,B,M);".format(name))
print("\t//input and outputs")
m_size_1d = (mat1[0] * mat2[1] * bit_width  - 1)
mat1_size_1d = (mat1[0] * mat1[1] * bit_width  - 1)
mat2_size_1d = (mat2[0] * mat2[1] * bit_width - 1)
print("\t//A is {} bits, for {}*{}={} elements, each of which is {} bits wide".format(mat1_size_1d,mat1[0],mat1[1],mat1[0]*mat1[1],bit_width))
print("\tinput wire [{}:0] A;".format(mat1_size_1d))
print("\t//B is {} bits, for {}*{}={} elements, each of which is {} bits wide".format(mat2_size_1d,mat2[0],mat2[1],mat2[0]*mat2[1],bit_width))
print("\tinput wire [{}:0] B;".format(mat2_size_1d))
print("\t//M is {} bits, for {}*{}={} elements, each of which is {} bits wide".format(m_size_1d,mat1[0],mat2[1],mat1[0]*mat2[1],bit_width))
print("\toutput wire [{}:0] B;".format(m_size_1d))




assignments = []

for i in range(mat1[0]):
    for j in range(mat2[1]):
        sums = []
        for k in range(mat1[1]):
            alsb = mat1_size_1d - ((i*mat1[0] + k + 1) * bit_width - 1)
            amsb = mat1_size_1d - ((i*mat1[0] + k) * bit_width)
            blsb = mat2_size_1d - ((k*mat2[0] + j + 1) * bit_width - 1)
            bmsb = mat2_size_1d - ((k*mat2[0] + j) * bit_width)
            sums.append("(A[{}:{}] * B[{}:{}])".format(amsb,alsb,bmsb,blsb))
        mlsb = m_size_1d - ((i*mat1[0] + j + 1) * bit_width - 1)
        mmsb = m_size_1d - (i*mat1[0] + j) * bit_width
        assignments.append("\tassign M[{}:{}] = ".format(mmsb,mlsb) + " + ".join(sums) + ";")
print(*assignments,sep="\n")
print("endmodule")




def print_usage():
    print("Usage: python3 generate matmul N1xN2 N2xN3 bit_width")