module AVS_AVALONSLAVE #
(
  // you can add parameters here
  // you can change these parameters
  parameter integer AVS_AVALONSLAVE_DATA_WIDTH = 16,
  parameter integer AVS_AVALONSLAVE_ADDRESS_WIDTH = 4
)

(
  // from slave interface to module
  output wire go,
  input  wire done,
  output wire [15:0] outputAdd_offset,inputAdd_offset,
  
  // from slave interface to Avalon Bus
  
  input wire CSI_CLOCK_CLK,
  input wire CSI_CLOCK_RESET_N,
  input wire [AVS_AVALONSLAVE_ADDRESS_WIDTH - 1:0] AVS_AVALONSLAVE_ADDRESS,
  output wire AVS_AVALONSLAVE_WAITREQUEST,
  input wire AVS_AVALONSLAVE_READ,
  input wire AVS_AVALONSLAVE_WRITE,
  output wire [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] AVS_AVALONSLAVE_READDATA,
  input wire [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] AVS_AVALONSLAVE_WRITEDATA
  );
  
  reg wait_request=1'b0;
  reg [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] read_data;
  
  //   slave registers
  reg [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] slv_reg0;
  reg [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] slv_reg1;
  reg [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] slv_reg2; 
  
  
  
  
  always @(posedge CSI_CLOCK_CLK)
  begin
   
    if(~CSI_CLOCK_RESET_N == 1)
    begin
      slv_reg0 <= 0;
      slv_reg1 <= 0;
      slv_reg2 <= 0;
    end
      else begin
	  if(AVS_AVALONSLAVE_WRITE)
      begin
   
        case(AVS_AVALONSLAVE_ADDRESS)
        0: slv_reg0 <= AVS_AVALONSLAVE_WRITEDATA;
        1: slv_reg1 <= AVS_AVALONSLAVE_WRITEDATA;
        2: slv_reg2 <= AVS_AVALONSLAVE_WRITEDATA;
        default:
        begin
          slv_reg0 <= slv_reg0;
          slv_reg1 <= slv_reg1;
          slv_reg2 <= slv_reg2;
        end
        endcase
	    
      end
      // it is an example design
      else if(done)
      begin
        slv_reg0 <= (slv_reg0 | 16'h0002);
      end
	end
  end

  
  
 

 
assign inputAdd_offset= slv_reg1;
assign outputAdd_offset=slv_reg2;
assign go=slv_reg0[0];
assign AVS_AVALONSLAVE_WAITREQUEST= wait_request;
assign AVS_AVALONSLAVE_READDATA=read_data;
  
endmodule
  
  
  
  
  
  
  
  
  
  
  
  