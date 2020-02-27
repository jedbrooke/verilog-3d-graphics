import sys

size1,size2 = sys.argv[1],sys.argv[2]
bit_width = int(sys.argv[3])
mat1 = [int(s) for s in size1.split('x')]
mat2 = [int(s) for s in size2.split('x')]

if mat1[1] != mat2[0]:
    print("Error: Matrix size mismatch")
    sys.exit(1)

size_1d = (mat1[0] * mat2[1] * bit_width  - 1)
assignments = []

for i in range(mat1[0]):
    for j in range(mat2[1]):
        sums = []
        for k in range(mat1[1]):
            amsb = (i*mat1[0] + k + 1) * bit_width - 1
            alsb = (i*mat1[0] + k) * bit_width
            bmsb = (k*mat2[0] + j + 1) * bit_width - 1
            blsb = (k*mat2[0] + j) * bit_width
            sums.append("(A[{}:{}] * B[{}:{}])".format(amsb,alsb,bmsb,blsb))
        mlsb = size_1d - ((i*mat1[0] + j + 1) * bit_width - 1)
        mmsb = size_1d - (i*mat1[0] + j) * bit_width
        assignments.append("assign M[{}:{}] = ".format(mmsb,mlsb) + " + ".join(sums) + ";")

print(*assignments,sep="\n")

def print_usage():
    print("Usage: python3 generate matmul N1xN2 N2xN3 bit_width")