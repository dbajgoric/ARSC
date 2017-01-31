/// MEMORY CONTROLLER
///
/// Memory controller abstracts the logic for interfacing with the main system
/// memory, which may be an off-chip SDRAM or on-chip RAM. What type of memory
/// is used depends on the value of the parameter MEMORY_TYPE (0 - on-chip and
/// 1 - off-chip SDRAM)
module memory_controller
#(
	parameter MEMORY_TYPE = 0,		/// On-chip RAM is used by default
	parameter N						/// Word width
)
(
	input wire clk,
	input wire reset_n,
	input wire [N-1:0] address,		/// Memory address to be read or written to
	input wire [N-1:0] wr_data,		/// Data to be written to memory
	input wire read_n,				/// Set to low to start a memory read
	input wire write_n,				/// Set to low to start a memory write
	
	output wire [N-1:0] rd_data,	/// Data read from the memory
	output wire rd_data_valid,		/// Set for one cycle after data has been read. Note that rd_data
									/// is guaranteed to be stable during this cycle only
	output wire wait_req,			/// Active if controller is busy
	
	/// To SDRAM (these signals are properly defaulted if on-chip memory
	/// is selected
	output wire [12:0] dram_addr,	/// RAM address generated by the SDRAM controller
	output wire [1:0] dram_ba,		/// RAM bank address
	output wire dram_cas_n,			/// Column address strobe
	output wire dram_cke,			/// Clock enable
	output wire dram_cs_n,			/// Chip select
	inout wire  [15:0] dram_dq,		/// Data to write to or data read from RAM
	output wire [1:0]  dram_dqm,	/// Data mask
	output wire dram_ras_n,			/// Row address strobe
	output wire dram_we_n			/// Write enable
);

	generate
		if (MEMORY_TYPE == 0)
		begin
			/// Use on-chip RAM as the main memory
			onchip_main_ram main_ram_unit
			(
				.address(address),
				.byteenable(2'b11),
				.chipselect(1'b1),
				.clk(clk),
				.clken(1'b1),
				.reset(),
				.reset_req(~reset_n),
				.write(~write_n),
				.writedata(wr_data),
				.readdata(rd_data)
			);
			
			/// Read/Write operations involving on-chip memory are completed within
			/// one clock cycle so rd_data_valid is always high and wait_req is never
			/// high as there is no possibility that on-chip memory gets busy
			assign rd_data_valid = 1'b1;
			assign wait_req = 1'b0;
			
			/// Set SDRAM signals to proper values so SDRAM chip will be inactive
			assign dram_addr = 13'bz;
			assign dram_ba = 2'bz;
			assign dram_cas_n = 1'bz;
			assign dram_cke = 1'bz;
			assign dram_cs_n = 1'bz;
			assign dram_dq = 16'bz;
			assign dram_dqm = 2'bz;
			assign dram_ras_n = 1'bz;
			assign dram_we_n = 1'bz;
		end
		else
		begin
			/// Use off-chip SDRAM as the main memory
			sdram_control_wrapper
				sdram_ctrl_unit
				(
					.clk(clk),
					.address(address),
					.byteenable_n(2'b00),
					.chipselect(1'b1),
					.writedata(wr_data),
					.read_n(read_n),
					.write_n(write_n),
					.readdata(rd_data),
					.readdatavalid(rd_data_valid),
					.waitrequest(wait_req),
					.reset_n(reset_n),
					
					/// To SDRAM
					.dram_addr(dram_addr),
					.dram_ba(dram_ba),
					.dram_cas_n(dram_cas_n),
					.dram_cke(dram_cke),
					.dram_cs_n(dram_cs_n),
					.dram_dq(dram_dq),
					.dram_dqm(dram_dqm),
					.dram_ras_n(dram_ras_n),
					.dram_we_n(dram_we_n)
				);
		end
	endgenerate
endmodule
		