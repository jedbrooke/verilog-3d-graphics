module makeOnePtX_tb (
    
);
    parameter WIDTH = 8;
    reg [WIDTH-1:0] d;
    wire [WIDTH:0] e;
    wire [WIDTH-1:0] w;

    makeOnePtX #(WIDTH) uut (d,e,w);
    integer i;
    initial begin
        for (i = 0; i < (2 << (WIDTH-1)); i = i + 1) begin
            #5 d = i;
            #5 $display("%b -> %b.%b, w =%d",d,e[WIDTH],e[WIDTH-1:0],w);
        end

    end

endmodule