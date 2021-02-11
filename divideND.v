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

module makeOnePtX #(
    parameter WIDTH=32
) (
    d,e,w
);
    input [WIDTH-1:0] d; // input integer to be shifted
    output [WIDTH:0] e; // d shifted to 1.xxx  in Q1.W
    output [WIDTH-1:0] w; // amount shifted to normalize so we can shift back later

    wire [(WIDTH + WIDTH) - 1:0] d_double = {d,{(WIDTH){1'b0}}};


    wire [WIDTH:0] e_temp [0:WIDTH];
    assign e_temp[0] = {(WIDTH+1){1'b0}};
    wire w_found [0:WIDTH];
    assign w_found[0] = 1'b0;

    wire [WIDTH-1:0] w_temp [0:WIDTH];
    assign w_temp[0] = {(WIDTH){1'b0}};

    genvar i; 
    for (i = 0; i < WIDTH-1; i=i+1) begin
        assign w_temp[i+1] = w_found[i] ? w_temp[i] : i;
        assign e_temp[i+1] = w_found[i] ? e_temp[i] : d_double >> i;
        assign w_found[i+1] = w_found[i] ? w_found[i] : d[i] & (~|d[WIDTH-1:(i+1)]);
    end

    assign e = w_found[WIDTH-1] ? e_temp[WIDTH-1] : d_double >> (WIDTH-1);
    assign w = w_found[WIDTH-1] ? w_temp[WIDTH-1] : WIDTH-1;
   
endmodule
    
/* 
    implementing a reciprocal module for 0 < a < 1
    we can use the taylor polynomial expansion for 1/a around x=1 to approximate 1/x
    while only using integer operations
    r is the integer component of the calculation
*/

/* module reciprocal #(
    parameter WIDTH=32,
    parameter ITERS=8
) (
    d,r_int,r_frac
);

    input [WIDTH-1:0] d;  // a is in QW.W notation
    output [WIDTH-1:0] r; // r is in QW.W notation
   
    // QW.W
    wire [(WIDTH + WIDTH) - 1:0] one_point_0 = ({(WIDTH + WIDTH){1'b0}} + 1'b1) << WIDTH;
    wire [(WIDTH + WIDTH) - 1:0] e; //e is d shifted to be 0 < e < 2, in the form of 1.xxx


    // QW.W
    wire [(WIDTH + WIDTH) - 1:0] minus_1 = e - one_point_0;
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
    
endmodule */