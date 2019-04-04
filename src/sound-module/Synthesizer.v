module Synthesizer(
	input CLOCK_50,
	input isNoteOn,
	input [23:0] noteSampleTicks,
	input [7:0] modulationValue,
	output reg i2sBitClock,
	output reg i2sSoundData,
	output reg i2sLeftRightSelect
);

// 50,000,000 / 44,100 / 16 / 2 / 2 (DE0 Nano clock / sample rate / bits per sample / channels / edges);
localparam i2sTicks = 8'd18;  // 17.7154195

reg [11:0] i2sCount = 0;
reg [23:0] noteSampleCount = 0;
reg [7:0] bitCount = 15;
reg [7:0] sampleIndex = 0;
reg [7:0] waveTableIndex = 0;
reg [7:0] modulation = 0;
reg isSamplePlaying = 0;
reg isSoundPlaying = 0;

wire [15:0] waveTableSample0;
wire [15:0] waveTableSample1;
wire [15:0] waveTableSample2;
wire [15:0] renderedSample;

WaveTable0Rom waveTable0Rom(waveTableIndex, CLOCK_50, waveTableSample0);
WaveTable1Rom waveTable1Rom(waveTableIndex, CLOCK_50, waveTableSample1);
WaveTable2Rom waveTable2Rom(waveTableIndex, CLOCK_50, waveTableSample2);

SampleMixer sampleMixer(waveTableSample0, waveTableSample1, waveTableSample2, modulation, renderedSample);

always @(posedge CLOCK_50)
begin
	i2sCount <= i2sCount + 1'b1;
	
	if (i2sCount == i2sTicks)
		begin
			i2sCount <= 1'b0;
			
			i2sBitClock <= ~i2sBitClock;
			
			if (i2sBitClock == 1'b1)
				begin
					if (isSoundPlaying)
						i2sSoundData <= renderedSample[bitCount +: 1];
					else
						i2sSoundData <= 1'b0;
	
					if (bitCount == 0)
						begin
							i2sLeftRightSelect <= ~i2sLeftRightSelect;
							bitCount <= 15;
							
							if (i2sLeftRightSelect == 1'b1)
								begin
									waveTableIndex <= sampleIndex;
									modulation <= modulationValue;
									isSoundPlaying <= isSamplePlaying;
								end
						end
					else
						bitCount <= bitCount - 1'b1;
				end
		end
		
	noteSampleCount <= noteSampleCount + 1'b1;
	
	if (noteSampleCount >= noteSampleTicks)
		begin
			noteSampleCount <= 1'b0;
			sampleIndex <= isSamplePlaying ? sampleIndex + 1'b1 : 1'b0;
					
			if (isNoteOn == 1'b1)
				isSamplePlaying <= 1'b1;	
			else if (sampleIndex == 1'b0)
				isSamplePlaying <= 1'b0;
		end
end

endmodule
