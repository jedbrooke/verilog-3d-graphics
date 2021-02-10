`timescale 1ns / 100ps
module divND_tb (
    
);
    parameter WIDTH = 16;
    parameter ITERS = 64;
    parameter SF = 2.0**(-WIDTH);
    integer i,j;

    reg [WIDTH-1:0] n,d;
    wire [WIDTH-1:0] q,f;
    // divideND #(.WIDTH(WIDTH), .ITERS(ITERS)) uut (n,d,q,f);
    reciprocal #(.WIDTH(WIDTH), .ITERS(ITERS)) uut (d,q,f);

    initial begin
        $dumpfile("divide.vcd");    
        $dumpvars(0,divND_tb);
        
        
        /* for(i = 1; i < 512; i = i + 1) begin
            for(j = i; j < 512; j = j + 1) begin
                #5;
                n = i;
                d = j;
                #5;
                $display("%b,%b,%b,%b",n,d,q,f);
            end
        end */

        for(i = 1; i < 512; i = i + 1) begin
                #5;
                n = 1;
                d = i;
                #5;
                $display("%b,%b,%b,%b",n,d,q,f);
        end
        
        

    end

    
endmodule