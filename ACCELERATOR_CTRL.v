module ACCELERATOR_CTRL #
(
  // you can add parameters here
  // you can change these parameters

  // control interface parameters
  parameter integer avs_avalonslave_data_width = 16,
  parameter integer avs_avalonslave_address_width = 4,

  // control interface parameters
  parameter integer avm_avalonmaster_data_width = 8,
  parameter integer avm_avalonmaster_address_width = 32
)

(
  // user ports begin

  // user ports end
  // dont change these ports

  // clock and reset
  input wire csi_clock_clk,
  input wire csi_clock_reset_n,

  // control interface ports
  input wire [avs_avalonslave_address_width - 1:0] avs_avalonslave_address,
  output wire avs_avalonslave_waitrequest,
  input wire avs_avalonslave_read,
  input wire avs_avalonslave_write,
  output wire [avs_avalonslave_data_width - 1:0] avs_avalonslave_readdata,
  input wire [avs_avalonslave_data_width - 1:0] avs_avalonslave_writedata,

  // magnitude interface ports
  output wire [avm_avalonmaster_address_width - 1:0] avm_avalonmaster_address,
  input wire avm_avalonmaster_waitrequest,
  output wire avm_avalonmaster_read,
  output wire avm_avalonmaster_write,
  input wire [avm_avalonmaster_data_width - 1:0] avm_avalonmaster_readdata,
  output wire [avm_avalonmaster_data_width - 1:0] avm_avalonmaster_writedata
);


wire [17:0]addressBUS;
wire [7:0]writeBUS;
wire [7:0]readBUS;
wire readEn;
wire writeEn;
wire [15:0] outputAdd_offset,inputAdd_offset;
wire go;
wire done;

//wire waitrequest;


//accelerator module instantiation

Addcnt Addcnt_int(.clk(csi_clock_clk),
.rst(csi_clock_reset_n),.go(go),.readEn(readEn),.writeEn(writeEn),
.done(done),.addressBUS(addressBUS),.readBus(readBUS),.writeBUS(writeBUS),
.outputAdd_offset(outputAdd_offset),.inputAdd_offset(inputAdd_offset));

// AVALON MM MASTER port instantiation

AVM_AVALONMASTER_MAGNITUDE #
(
  
    .AVM_AVALONMASTER_DATA_WIDTH (avm_avalonmaster_data_width),
    .AVM_AVALONMASTER_ADDRESS_WIDTH (avm_avalonmaster_address_width)
) AVM_AVALONMASTER_MAGNITUDE_INST(

	.addressBUS(addressBUS),
	.writeBUS(writeBUS),
	.readBUS(readBUS),
	.readEn(readEn),
	.WriteEn(writeEn),
	.waitrequest(waitrequest),


	.CSI_CLOCK_CLK(csi_clock_clk),
	.CSI_CLOCK_RESET_N(csi_clock_reset_n),
	.AVM_AVALONMASTER_ADDRESS(avm_avalonmaster_address),
	.AVM_AVALONMASTER_WAITREQUEST(avm_avalonmaster_waitrequest),
	.AVM_AVALONMASTER_READ(avm_avalonmaster_read),
	.AVM_AVALONMASTER_WRITE(avm_avalonmaster_write),
	.AVM_AVALONMASTER_READDATA(avm_avalonmaster_readdata),
	.AVM_AVALONMASTER_WRITEDATA(avm_avalonmaster_writedata)


);

// AVALON MM SLAVE port instantiation

AVS_AVALONSLAVE #
(
 
    .AVS_AVALONSLAVE_DATA_WIDTH(avs_avalonslave_data_width) ,
    .AVS_AVALONSLAVE_ADDRESS_WIDTH(avs_avalonslave_address_width)
) AVS_AVALONSLAVE_INST(

.go(go),
.done(done),
.outputAdd_offset(outputAdd_offset),
.inputAdd_offset(inputAdd_offset),


.CSI_CLOCK_CLK(csi_clock_clk),
.CSI_CLOCK_RESET_N(csi_clock_reset_n),
.AVS_AVALONSLAVE_ADDRESS(avs_avalonslave_address),
.AVS_AVALONSLAVE_WAITREQUEST(avs_avalonslave_waitrequest),
.AVS_AVALONSLAVE_READ(avs_avalonslave_read),
.AVS_AVALONSLAVE_WRITE(avs_avalonslave_write),
.AVS_AVALONSLAVE_READDATA(avs_avalonslave_readdata),
.AVS_AVALONSLAVE_WRITEDATA(avs_avalonslave_writedata)

);




endmodule












