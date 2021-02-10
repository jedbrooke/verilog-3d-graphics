WIDTH = 16
def main():

    lines = [line.strip() for line in open('divdump.txt')]
    # ignore header line
    lines = lines[1:]
    tests = [[int(s,base=2) for s in line.split(',')] for line in lines]
    errors = [0] * len(tests)
    test_results = [None] * len(tests)
    
    for i,t in enumerate(tests):
        n,d,q,f = t
        actual = n / d
        result = q + (f / (2 ** WIDTH))
        errors[i] = abs(100 - (100 * (abs(result / actual))))
        test_results[i] = (n,d,result,errors[i])
        # print(n,"/",d,"=",result,"error:",errors[i])

    print("max error:", max(errors))
    print("avg error:", sum(errors) / len(errors))
    print("median error:",[e for e in sorted(errors)][len(errors)//2])
    sorted_results = [t for t in sorted(test_results, key=lambda s: s[-1])]
    with open("results.txt",'w') as out:
        out.write("\n".join([f"{n}/{d}={r:0.3f},\t\terror: {e:0.2f}" for n,d,r,e in sorted_results]))

if __name__ == "__main__":
    main()