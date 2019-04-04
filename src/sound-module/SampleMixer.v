module SampleMixer(
	input [15:0] sample0,
	input [15:0] sample1,
	input [15:0] sample2,
	input [7:0] modulationValue,
	output [15:0] renderedSample
);

reg [15:0] mixSample0 = 0;
reg [15:0] mixSample1 = 0;
reg [15:0] mixSample2 = 0;

always @(sample0 or sample1 or sample2 or modulationValue)
begin
	if (sample0[15] == 1'b1)
		begin
			mixSample0 = ((~sample0 + 16'd1) > (((~sample0 + 16'd1) >> 16'd6) * modulationValue)) ?
				~((~sample0 + 16'd1) - (((~sample0 + 16'd1) >> 16'd6) * modulationValue)) + 16'd1 :
				16'd0;
		end
	else
		begin
			mixSample0 = (sample0 > ((sample0 >> 16'd6) * modulationValue)) ?
				(sample0 - ((sample0 >> 16'd6) * modulationValue)) :
				16'd0;
		end
	
	if (sample1[15] == 1'b1)
		begin
			if (modulationValue >= 64)
				begin
					mixSample1 = ((~sample1 + 16'd1) > (((~sample1 + 16'd1) >> 16'd6) * (modulationValue - 16'd64))) ?
						~((~sample1 + 16'd1) - (((~sample1 + 16'd1) >> 16'd6) * (modulationValue - 16'd64))) + 16'd1 :
						16'd0;
				end
			else
				begin
					mixSample1 = ((~sample1 + 16'd1) > (((~sample1 + 16'd1) >> 16'd6) * (16'd64 - modulationValue))) ?
						~((~sample1 + 16'd1) - (((~sample1 + 16'd1) >> 16'd6) * (16'd64 - modulationValue))) + 16'd1 :
						16'd0;
				end
		end
	else
		begin
			if (modulationValue >= 64)
				begin
					mixSample1 = (sample1 > ((sample1 >> 16'd6) * (modulationValue - 16'd64))) ?
						(sample1 - ((sample1 >> 16'd6) * (modulationValue - 16'd64))) :
						16'd0;
				end
			else
				begin
					mixSample1 = (sample1 > ((sample1 >> 16'd6) * (16'd64 - modulationValue))) ?
						(sample1 - ((sample1 >> 16'd6) * (16'd64 - modulationValue))) :
						16'd0;
				end
		end
		
	if (sample2[15] == 1'b1)
		begin
			mixSample2 = ((~sample2 + 16'd1) > (((~sample2 + 16'd1) >> 16'd6) * (16'd127 - modulationValue))) ?
				~((~sample2 + 16'd1) - (((~sample2 + 16'd1) >> 16'd6) * (16'd127 - modulationValue))) + 16'd1 :
				16'd0;
		end
	else
		begin
			mixSample2 = (sample2 > ((sample2 >> 16'd6) * (16'd127 - modulationValue))) ?
				(sample2 - ((sample2 >> 16'd6) * (16'd127 - modulationValue))) :
				16'd0;
		end
end

assign renderedSample = mixSample0 + mixSample1 + mixSample2;

endmodule
