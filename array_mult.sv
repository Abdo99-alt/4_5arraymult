//The highest omega i achieved is around 14 with test set of 7 vectors
class pkt;
randc bit [3:0]x;
randc bit [4:0]y;
endclass
//Sub-modules of the design of 4 by 5 array multiplier
module HA(
	input x , y,
	output sum , cout);
assign sum = x ^ y;
assign cout = x & y;
endmodule

module FA(
	input x , y , cin,
	output sum , cout);
//internal signal between the 2 half adders
wire out1 , cout1 , cout2;
//implementation using structural modelling
HA stage1 (x , y , out1 , cout1);
HA stage2 (out1 , cin , sum , cout2);

assign cout = cout2 | cout1;
endmodule

////////Top level module/////////
module mult(
	input [3:0]x,
	input [4:0]y,
	output [8:0]z);
//internal signals decalration
wire [3:0]sum0 ;wire  [4:0]cout0;
wire [3:0]sum1 ;wire [4:0]cout1;
wire [3:0]cout2;

//implementation using structural modelling
//1st digit
and (z[0] , x[0] , y[0]);
//2nd digit
HA block0_0 (x[0] & y[1] , x[1] & y[0] , z[1] , cout0[0]);
//3rd digit
FA block0_1 (x[0] & y[2] , x[1] & y[1] , cout0[0] , sum0[0] , cout0[1]);
HA block1_0 (x[2] & y[0] , sum0[0] , z[2] , cout1[0]);
//4th digit
FA block0_2 (x[0] & y[3] , x[1] & y[2] , cout0[1] , sum0[1] , cout0[2]);
FA block1_1 (x[2] & y[1] , sum0[1] , cout1[0] , sum1[0] , cout1[1]);
HA block2_0 (x[3] & y[0] , sum1[0] , z[3] , cout2[0]);
//5th digit 
FA block0_3 (x[0] & y[4] , x[1] & y[3] , cout0[2] , sum0[2] , cout0[3]);
FA block1_2 (x[2] & y[2] , sum0[2] , cout1[1] , sum1[1] , cout1[2]);
FA block2_1 (x[3] & y[1] , sum1[1] , cout2[0] , z[4] , cout2[1]);
//6th digit 
HA block0_4 (x[1] & y[4] , cout0[3] , sum0[3] , cout0[4]);
FA block1_3 (x[2] & y[3] , sum0[3] , cout1[2] , sum1[2] , cout1[3]);
FA block2_2 (x[3] & y[2] , sum1[2] , cout2[1] , z[5] , cout2[2]);
//7th digit 
FA block1_4 (x[2] & y[4] , cout0[4] , cout1[3] , sum1[3] , cout1[4]);
FA block2_3 (x[3] & y[3] , sum1[3] , cout2[2] , z[6] , cout2[3]);
//8th & 9th digit 
FA block2_4 (x[3] & y[4] , cout1[4] , cout2[3] , z[7] , z[8]);
endmodule

//test bench for the array multiplier using different techniques
module mult_tb();
reg [3:0]a;reg [4:0]b;
wire [8:0]c;
mult dut (a , b ,c);
pkt p = new();

//declaring a cover group for x,y,z
covergroup g1 @(a or b);
x : coverpoint a;
y : coverpoint b;
z : coverpoint c; 
endgroup
g1 cover_ = new();

//using randomized tests to verify
//GOAL :100% toggle coverage with minimum test vectors
initial begin
$monitor("a = %d ,b = %d , c = %d" , a , b , c);
end

initial begin
repeat(5) begin
assert(p.randomize());
a = p.x;
b = p.y;
#10;
end
a = 'b1010;
b = 'b10100;
#10;
a = 'b1100;
b = 'b1;
#10;
end
endmodule