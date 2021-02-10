 `timescale 1ns / 100ps  
/* 
    implement goldschmidt division
    https://lauri.võsandi.com/hdl/arithmetic/goldschmidt-division-algorithm.html
    https://projectf.io/posts/fixed-point-numbers-in-verilog/
    floor style rounding
*/
module divideND #(
    // integer bits
    parameter WIDTH=32, 
    // number of iterations, probably going to hardcode 4 for now
    // but might come back and loopify it
    parameter ITERS=4
) (
    n,d,q,f
);  

    input [WIDTH-1:0] n,d;  
    output [WIDTH-1:0] q,f;

    // intermediate calculations represented in QWIDTH.WIDTH fixed point

    wire [(WIDTH + WIDTH) - 1:0] one_point_0 = ({(WIDTH + WIDTH){1'b0}} + 1'b1) << WIDTH;


    // pad d and d with extra intermediate fractional bits
    wire [(WIDTH + WIDTH) - 1:0] N_initial = {n,{{WIDTH}{1'b0}}};
    wire [(WIDTH + WIDTH) - 1:0] D_initial = {d,{{WIDTH}{1'b0}}};

    // F_-1 = (D_initial >> (WIDTH-1))
    wire [(WIDTH + WIDTH) - 1:0] F_initial = {{{WIDTH}{1'b0}},d};
    
    wire [(WIDTH + WIDTH) - 1:0] D_array [0:ITERS];
    wire [((WIDTH + WIDTH) * 2) - 1:0] D_array_double [0:ITERS];

    wire [(WIDTH + WIDTH) - 1:0] N_array [0:ITERS];
    wire [((WIDTH + WIDTH) * 2) - 1:0] N_array_double [0:ITERS];

    wire [(WIDTH + WIDTH) - 1:0] F_array [0:ITERS];
    wire [((WIDTH + WIDTH) * 2) - 1:0] F_array_double [0:ITERS];

    assign N_array_double[0] = F_initial * N_initial;
    assign N_array[0] = N_array_double[0][(3 * WIDTH) - 1 : WIDTH];

    assign D_array_double[0] = F_initial * D_initial;
    assign D_array[0] = D_array_double[0][(3 * WIDTH) - 1 : WIDTH];

    genvar i;
    // main algorithm loop
    for (i = 0; i < ITERS; i = i + 1) begin
        assign F_array[i] = (one_point_0 << 1) - D_array[i];
        
        assign N_array_double[i + 1] = F_array[i] * N_array[i];
        assign N_array[i + 1] = N_array_double[i + 1][(3 * WIDTH) - 1 : WIDTH];

        assign D_array_double[i + 1] = F_array[i] * D_array[i];
        assign D_array[i + 1] = D_array_double[i + 1][(3 * WIDTH) - 1 : WIDTH];
    end

    
    // take the integer part of the calculation
    assign q = N_array[ITERS][(WIDTH * 2) - 1 : WIDTH];
    assign f = N_array[ITERS][WIDTH - 1 : 0];

endmodule


/* 
    returns a^POWER. a and y are integers
 
*/
module power #(
    parameter WIDTH=32,
    parameter POWER=1
) (
    a,y
);

    input [WIDTH-1:0] a;
    output [WIDTH-1:0] y;

    wire [WIDTH-1:0] sums [0:POWER];
    assign sums[0] = {{(WIDTH-1){1'b0}},1'b1};
    genvar i;


    for (i = 0; i < POWER; i = i + 1) begin
        assign sums[i + 1] = sums[i] * a;
    end

    assign y = sums[POWER];
    
endmodule
    
/* 
    implementing a reciprocal module for 0 < a < 1
    we can use the taylor polynomial expansion for 1/a around x=1 to approximate 1/x
    while only using integer operations
    r is the integer component of the calculation
*/

module reciprocal #(
    parameter WIDTH=32,
    parameter ITERS=8
) (
    a,r
);

    input [WIDTH-1:0] a;  // a is in Q0.W notation
    output [WIDTH-1:0] r; // r is in QW.0 notation
   
    // Qw.W
    wire [(WIDTH + WIDTH) - 1:0] one_point_0 = ({(WIDTH + WIDTH){1'b0}} + 1'b1) << WIDTH;
    wire [(WIDTH + WIDTH) - 1:0] a_double = {{WIDTH{1'b0}},a};

    // QW.W
    wire [(WIDTH + WIDTH) - 1:0] minus_1 = a - one_point_0;
    wire [(WIDTH + WIDTH) - 1:0] sums_double [0:ITERS];

    wire [WIDTH-1:0] sums [0:ITERS];
    wire [WIDTH-1:0] finals [0:ITERS];
    assign finals[0] = {WIDTH{1'b0}};

    genvar i;

    for (i = 1; i <= ITERS; i = i + 1) begin
        power #(.WIDTH(WIDTH),.POWER(i)) p(minus_1,sums_double[i]);
    end

    for (i = 0; i < ITERS; i = i + 1) begin
        assign finals[i + 1] = ((i % 2) == 0) ? finals[i] - sums[i + 1] : finals[i] + sums[i + 1];
    end

    assign r = 1 - finals[ITERS];
    
endmodule