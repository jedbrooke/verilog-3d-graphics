import sys

size1,size2 = sys.argv[1],sys.argv[2]
bit_width = int(sys.argv[3])
mat1 = [int(s) for s in size1.split('x')]
mat2 = [int(s) for s in size2.split('x')]

if mat1[1] != mat2[0]:
    print("Error: Matrix size mismatch")
    sys.exit(1)

m_size_1d = (mat1[0] * mat2[1] * bit_width  - 1)
mat1_size_1d = (mat1[0] * mat1[1] * bit_width  - 1)
mat2_size_1d = (mat2[0] * mat2[1] * bit_width - 1)
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
        assignments.append("assign M[{}:{}] = ".format(mmsb,mlsb) + " + ".join(sums) + ";")

print(*assignments,sep="\n")

def print_usage():
    print("Usage: python3 generate matmul N1xN2 N2xN3 bit_width")