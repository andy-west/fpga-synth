module MidiByteReader(
	input CLOCK_50,
	input MIDI_RX,
	output reg isByteAvailable = 0,
	output reg [7:0] byteValue = 0
);

localparam
	midiTicks = 12'd1600,  // 50,000,000 / 31,250 (DE0 Nano clock / MIDI clock);
	debounceTicks = 8'd10;

localparam
	stateWaitingForSignal = 8'd0,
	stateSignalAvailable = 8'd1,
	stateByteComplete = 8'd2;

reg [7:0] midiState = stateWaitingForSignal;
reg [7:0] bitNumber = 0;
reg [11:0] midiCount = 0;
reg [7:0] debounceCountDown = debounceTicks;

always @(posedge CLOCK_50)
begin
	case (midiState)
		stateWaitingForSignal:
			begin
				isByteAvailable <= 1'b0;
			
				if (MIDI_RX == 1'b0)
					begin
						debounceCountDown <= debounceCountDown - 1'b1;
						
						if (debounceCountDown == 1'b0)
							begin
								debounceCountDown <= debounceTicks;
								midiState <= stateSignalAvailable;
								midiCount <= 1'b0;
								bitNumber <= 1'b0;
								byteValue <= 1'b0;
							end
					end
				else
					debounceCountDown <= debounceTicks;
			end
		stateSignalAvailable:
			begin
				midiCount <= midiCount + 1'b1;
			
				if (midiCount == midiTicks)
					begin
						midiCount <= 1'b0;
					
						bitNumber <= bitNumber + 1'b1;	

						if (MIDI_RX == 1'b1)
							byteValue <= byteValue | (1'b1 << bitNumber);
		
						if (bitNumber == 8'd7)
							midiState <= stateByteComplete;					
					end
			end
		stateByteComplete:
			begin
				midiCount <= midiCount + 1'b1;
			
				if (midiCount == midiTicks)
					begin
						isByteAvailable <= 1'b1;				
						midiState <= stateWaitingForSignal;
					end			
			end
	endcase
end

endmodule
