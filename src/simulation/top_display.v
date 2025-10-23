module top_display;

	reg i0, i1, s0;
	wire out;

	m21_gate m21(.I0(i0), .I1(i1), .S0(s0), .Y(out));

	initial begin
		i0 = 1'b0;
		i1 = 1'b0;
		s0 = 1'b0;
		#10 i0 = 1'b1;
		#10 s0 = 1'b1;
		#10 i1 = 1'b1;
		#10 $stop;
	end

	always @(out)
		$display("Vreme = %0d, Izlaz = %d", $time, out); 

endmodule
