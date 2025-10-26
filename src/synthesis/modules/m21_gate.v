module m21_gate(I0, I1, S0, Y);

	input I0, I1, S0;
	output Y;

	wire notS0, T0, T1;

	not (notS0, S0);
	and (T0, I1, S0);
	and (T1, I0, notS0);
	or (Y, T0, T1);

endmodule
