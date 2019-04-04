module SoundModule(
	input CLOCK_50,
	input MIDI_RX,
	output reg I2S_BIT_CLOCK,
	output reg I2S_SOUND_DATA,
	output reg I2S_LEFT_RIGHT_SELECT,
	output reg [7:0] LED
);

wire i2sBitClock;
wire i2sSoundData;
wire i2sLeftRightSelect;

wire isNoteOn;
wire [23:0] noteSampleTicks;
wire [7:0] modulationValue;

MidiProcessor midiProcessor(CLOCK_50, MIDI_RX, isNoteOn, noteSampleTicks, modulationValue);
Synthesizer synthesizer(CLOCK_50, isNoteOn, noteSampleTicks, modulationValue, i2sBitClock, i2sSoundData, i2sLeftRightSelect);

always @(posedge CLOCK_50)
begin
	I2S_BIT_CLOCK <= i2sBitClock;
	I2S_SOUND_DATA <= i2sSoundData;
	I2S_LEFT_RIGHT_SELECT <= i2sLeftRightSelect;

	LED <= isNoteOn ? noteSampleTicks[7:0] : 8'h00;
end

endmodule
