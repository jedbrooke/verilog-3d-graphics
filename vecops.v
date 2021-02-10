
/* 
    in software:
    6 multiplies, 3 adds
*/
module vectorCrossProduct #(parameter WIDTH=32) (
    a1,a2,a3,b1,b2,b3,c1,c2,c3
);
    input [WIDTH-1:0] a1,a2,a3,b1,b2,b3;
    output [WIDTH-1:0] c1,c2,c3;

    assign c1 = (a2*b3) - (a3*b2);
    assign c2 = (a3*b1) - (a1*b3);
    assign c3 = (a1*b2) - (a2*b1);
    
endmodule

/* 
    one solution do expanding the paralellization even further
    not sure if this is the best way to do it since you end up with ports that are WIDTH*N long
    in the case of 16*32 that's 512 bits, which i suppose isn't too crazy
*/
module vectorCrossProductMany #(
    parameter WIDTH=32, parameter N=16
) (
    a1,a2,a3,b1,b2,b3,c1,c2,c3
);

    input [(WIDTH-1) * N:0] a1,a2,a3,b1,b2,b3;
    output [(WIDTH-1) * N:0] c1,c2,c3;

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin
            vectorCrossProduct vcross (
                a1[((i + 1) * WIDTH) - 1 : i * WIDTH],
                a2[((i + 1) * WIDTH) - 1 : i * WIDTH],
                a3[((i + 1) * WIDTH) - 1 : i * WIDTH],
                b1[((i + 1) * WIDTH) - 1 : i * WIDTH],
                b2[((i + 1) * WIDTH) - 1 : i * WIDTH],
                b3[((i + 1) * WIDTH) - 1 : i * WIDTH],
                c1[((i + 1) * WIDTH) - 1 : i * WIDTH],
                c2[((i + 1) * WIDTH) - 1 : i * WIDTH],
                c3[((i + 1) * WIDTH) - 1 : i * WIDTH],
            );
        end
    endgenerate


    
endmodule

/* 
    in software:
    3 multiplies, 2 adds
*/
module vectorDotProduct #(parameter WIDTH=32) (
    a1,a2,a3,b1,b2,b3,p
);

    input [WIDTH-1:0] a1,a2,a3,b1,b2,b3;
    output [WIDTH-1:0] p;

    assign p = (a1 * b1) + (a2 * b2) + (a3 * b3);

endmodule


/* 
    implementing this algo:
    https://en.wikipedia.org/wiki/M%C3%B6ller%E2%80%93Trumbore_intersection_algorithm
    the c++ version
    right now everything is treated as unsigned, the only thing that needs to be updated for signed is a few equality operators 
*/
module rayTriIntersect #(parameter WIDTH=32) (
    p1,p2,p3,
    d1,d2,d3,
    a1,a2,a3,
    b1,b2,b3,
    c1,c2,c3,
    o1,o2,o3,
    valid
);
    // ray origin
    input [WIDTH-1:0] p1,p2,p3;
    
    // ray direction
    input [WIDTH-1:0] d1,d2,d3;
    
    // triangle vertex 1
    input [WIDTH-1:0] a1,a2,a3;
    
    // triangle vertex 2
    input [WIDTH-1:0] b1,b2,b3;
    
    // triangle vertex 3
    input [WIDTH-1:0] c1,c2,c3;
    
    // intersection point
    output [WIDTH-1:0] o1,o2,o3;
    
    // valid intersection flag
    output valid;

    // edge 1 = b - a
    wire [WIDTH-1:0] e1x = b1 - a1;
    wire [WIDTH-1:0] e1y = b2 - a2;
    wire [WIDTH-1:0] e1z = b3 - a3;

    // edge 2 = c - a
    wire [WIDTH-1:0] e2x = c1 - a1;
    wire [WIDTH-1:0] e2y = c2 - a2;
    wire [WIDTH-1:0] e2z = c3 - a3;

    wire [WIDTH-1:0] h1;
    wire [WIDTH-1:0] h2;
    wire [WIDTH-1:0] h3;

    // h = rayVector.crossProduct(edge2);
    vectorCrossProduct rayDirCrossEdge2 (
        d1,d2,d3,
        e2x,e2y,e2z,
        h1,h2,h3
    );

    // a = edge1.dotProduct(h);
    wire [WIDTH-1:0] a;

    vectorDotProduct edge1DotH (
        e1x,e1y,e1z,
        h1,h2,h3,
        a
    );

    // s = rayOrigin - vertex0;
    wire [WIDTH-1:0] s1 = p1 - a1;
    wire [WIDTH-1:0] s2 = p3 - a3;
    wire [WIDTH-1:0] s2 = p3 - a3;

    // u = f * s.dotProduct(h);
    wire [WIDTH-1:0] u_int;
    wire [WIDTH-1:0] u_frac;
    wire [WIDTH-1:0] s_dot_h;

    vectorDotProduct sDotH (
        s1,s2,s3,
        h1,h2,h3,
        s_dot_h
    );

    divideND s_dot_h_div_a (
        s_dot_h,
        a,
        u_int,
        u_frac
    );

    // q = s.crossProduct(edge1);
    wire [WIDTH-1:0] q1;
    wire [WIDTH-1:0] q2;
    wire [WIDTH-1:0] q1;

    vectorCrossProduct sCrossEdge1(
        s1,s2,s3,
        e1x,e1y,e1z,
        q1,q2,q3
    );

    // v = f * rayVector.dotProduct(q);
    wire [WIDTH-1:0] v_int;
    wire [WIDTH-1:0] v_frac;
    wire [WIDTH-1:0] d_dot_q;

    vectorDotProduct dDotQ (
        d1,d2,d3,
        q1,q2,q3,
        d_dot_q
    );

    divideND d_dot_q_div_a (
        d_dot_q,
        a,
        v_int,
        v_frac
    );

    wire [WIDTH-1:0] t_int;
    wire [WIDTH-1:0] t_frac;
    wire [WIDTH-1:0] e2_dot_q;

    vectorDotProduct e2DotQ (
        e2x,e2y,e2z,
        q1,q2,q3,
        e2_dot_q
    );

    divideND e2_dot_q_div_a (
        e2_dot_q,
        a,
        t_int,
        t_frac
    );

    wire [(WIDTH + WIDTH) - 1:0] one_point_0 = ({(WIDTH + WIDTH){1'b0}} + 1'b1) << WIDTH;
    assign valid = ~((a == 0) | (u_int != 0) | (u_frac == 0) | (v_int != 0 | v_frac == 0) | ({u_int,u_frac} + {v_int,v_frac} > one_point_0) | {t_int,t_frac} > 0);
    
    
    

endmodule
