///////////////////////////////////
///// Sajjad Roohi 810101175///////
///////////////////////////////////

module Addcnt(clk,rst,go,readEn,writeEn,done,addressBUS,readBus,writeBUS,outputAdd_offset,inputAdd_offset);


// AVALON BUS DIRECT COMMUNICATION
input clk,rst;

// AVALON SLAVE MM PORT COMMUNICATION
input go;
output done;
input [15:0] inputAdd_offset,outputAdd_offset;

// AVALON MASTER MM PORT COMMUNICATION
output [31:0]addressBUS;
output [7:0]writeBUS;
input [7:0]readBus;
output readEn;
output writeEn;

//input waitreq;




reg readEn;
reg [7:0] pixel_x,pixel_y;
reg pixel_x_init,pixel_y_init;
parameter[1:0] idle=0, starting =1 , loading=2, run=3;
parameter[2:0] addgen=0,data_grab=1,data_save_in=2,matix_cal=3, abs_calculation=4, final_add=5, final_dev=6,data_save_out=7;
reg [1:0] ns,ps; // main state machine states
reg [2:0]process_ns,process_ps;
reg[7:0]input_Matrix[8:0]; // har matris khunde shode az ram to in miad
reg iteration_go; // counteri ke az 0 ta 8 neshun mide chand data gereftim
reg[3:0] iteration;
reg save_datain; //flag baraye shoro e save input dar register input matrix
//wire save_datain;
reg[10:0]matrix_convolved_x; // save convolousion input matix ba gx
reg[10:0]matrix_convolved_y; // save convolousion input matix ba gy
reg[10:0]matrix_absed_x;
reg[10:0]matrix_absed_y;
reg matrix_absed_x_init;
reg matrix_absed_y_init;
reg [10:0]after_cal_value;
reg [10:0]new_pixel_value; // meghdare jadid har pixel ke mire be ram
reg convoloution_go;
reg abs_calculation_go;
reg final_add_go;
reg final_dev_go;
reg matrix_convolved_x_init;
reg matrix_convolved_y_init;
reg [15:0] writeAddx;
reg writeAdd_gen_go;
reg pixel_x_go;
reg done;
reg col_init;
reg row_init;
reg col_go;
reg writeAdd_reg_init;
reg iteration_init;
reg [1:0]col,row;
reg writeEn;
wire [15:0]readAdd;
wire [15:0]writeAdd;
//reg readAdd_gen;

//state machine begin
always @(*)begin
	pixel_x_init=1'b0;
	pixel_y_init=1'b0;
	//readAdd_gen=1'b0;
	process_ns=3'b0;
	ns=2'b0;
	row_init=1'b0;
	col_init=1'b0;
	col_go=1'b0;
	iteration_go=1'b0;
	iteration_init=1'b0;
	save_datain=1'b0;
	convoloution_go=1'b0;
	abs_calculation_go=1'b0;
	final_add_go=1'b0;
	final_dev_go=1'b0;
	matrix_convolved_y_init=1'b0;
	matrix_convolved_x_init=1'b0;
	writeAdd_reg_init=1'b0;
	writeAdd_gen_go=1'b0;
	done=1'b0;
	writeEn=1'b0;
	matrix_absed_x_init=0;
	matrix_absed_y_init=0;
	readEn=0;
	case(ps)
	idle :  ns= go ? starting : idle;
	starting : ns= go ? starting : loading;
	loading : begin 
		row_init=1'b1; col_init=1'b1; iteration_init=1'b1;
		matrix_convolved_x_init=1'b1;matrix_convolved_y_init=1'b1;
		writeAdd_reg_init=1'b1;
		matrix_absed_x_init=1'b1;
		matrix_absed_y_init=1'b1;
		pixel_x_init=1'b1;
		pixel_y_init=1'b1;
		
		ns=run;
		end
	
	run : begin
	
				case(process_ps)
					addgen : begin
						readEn=1;
						//readAdd_gen=1;
						process_ns=data_grab;end
					
					data_grab : begin
						save_datain=1;
						//dinAdd_gen=1;
						process_ns=data_save_in;end
						
					data_save_in : begin
						col_go=1;
						if(iteration==8)begin
							process_ns=matix_cal;
							iteration_init=1;end
						
						else 
							begin
								iteration_go=1;
								process_ns=addgen; end
								
						end
								
							
						
						
					
					
					matix_cal :	begin
						convoloution_go=1;
						process_ns=abs_calculation; end
					
					abs_calculation : begin
						abs_calculation_go=1;
						process_ns=final_add; end
						
					final_add : begin
						final_add_go=1;
						process_ns=final_dev; end
						
					final_dev : begin
						final_dev_go=1;
						process_ns=data_save_out; end
						
					data_save_out : begin
						writeEn=1;
						process_ns=addgen;
						writeAdd_gen_go=1;
						end
						
					default : process_ns=addgen;
					endcase
					
					if(writeAddx==64516)begin
						ns=idle;
						done=1;
						end
					else ns=run;
			end
			
			default : ns= idle;
		endcase
			
					
	end					
					
					
						
								
				
		
//
assign writeBUS= (writeEn) ? ( new_pixel_value > 255 ? 255 : new_pixel_value[7:0]): 8'bz;

// Write & read address generation

assign readAdd=(pixel_y<<8)+(pixel_x)+(col)+(row<<8)+inputAdd_offset;
assign writeAdd=writeAddx + outputAdd_offset;


assign addressBUS= writeEn ? writeAdd : readEn ? readAdd : 18'bz;



//DoutAdd generation

always @ (posedge clk or negedge rst)
	if(~rst)
	writeAddx<=0;
	else if (writeAdd_reg_init)
	writeAddx<=0;
	else if (writeAdd_gen_go)
	writeAddx<=writeAddx+1;
	
	
// final dev by 2;

always@(posedge clk or negedge rst)
	if(~rst)
		new_pixel_value<=0;
	else if(final_dev_go)
		new_pixel_value<=after_cal_value>>1;

		
//final add

always@(posedge clk or negedge rst)
	if (~rst)
		after_cal_value<=0;
	else if(final_add_go)
		after_cal_value<=matrix_absed_x + matrix_absed_y;

		
//abs_gx

always @ (posedge clk or negedge rst)begin
	if(~rst)
		matrix_absed_x<=0;
	else if(matrix_absed_x_init)
		matrix_absed_x<=0;
	else if(abs_calculation_go)begin
		if(matrix_convolved_x[10])
			matrix_absed_x<=(~matrix_convolved_x)+1;
		else matrix_absed_x<= matrix_convolved_x;
		end
		end
		
//abs_gy
always @ (posedge clk or negedge rst) begin
	if(~rst)
		matrix_absed_y<=0;
	else if(matrix_absed_y_init)
		matrix_absed_y<=0;
	else if(abs_calculation_go)begin
		if(matrix_convolved_y[10])
			matrix_absed_y<=(~matrix_convolved_y)+1;
		else matrix_absed_y<= matrix_convolved_y;
		end 
		end


//convolved value gx

always @ (posedge clk or negedge rst)
	if(~rst)
	matrix_convolved_x<=0;
	else if (matrix_convolved_x_init)
	matrix_convolved_x<=0;
	else if(convoloution_go)
		matrix_convolved_x<=(input_Matrix[0])-(input_Matrix[2])+
		(input_Matrix[3]<<1)-(input_Matrix[5]<<1)+(input_Matrix[6])-(input_Matrix[8]);
		
		
//convolved value gy		
always @ (posedge clk or negedge rst)
	if(~rst)
	matrix_convolved_y<=0;
	else if (matrix_convolved_y_init)
	matrix_convolved_y<=0;
	else if(convoloution_go)
		matrix_convolved_y<=(input_Matrix[0])+(input_Matrix[1]<<1)
		+(input_Matrix[2])-(input_Matrix[6])-(input_Matrix[7]<<1)-(input_Matrix[8]);
				
		
		
		
		
		
		
//save_datain calculation
	
always @(posedge clk  or negedge rst)
		 if(~rst)begin
				 
					input_Matrix[0]<=8'b0;
					input_Matrix[1]<=8'b0;
					input_Matrix[2]<=8'b0;
					input_Matrix[3]<=8'b0;
					input_Matrix[4]<=8'b0;
					input_Matrix[5]<=8'b0;
					input_Matrix[6]<=8'b0;
					input_Matrix[7]<=8'b0;
					input_Matrix[8]<=8'b0;
		 end
		 else if(save_datain)
			input_Matrix[iteration]<=readBus;
			
	

//iteration counter

always @(posedge clk or negedge rst)
	if(~rst)
		iteration<=0;
	else if (iteration_init)
		iteration<=0;
	else if (iteration_go)
		iteration<=iteration+1;
	
	
//col counter	

always @ (posedge clk or negedge rst)
	if(~rst)
		col<=2'b0;
	else if(col_init)
		col<=2'b0;
	else if(col_go) begin
		if(col == 2)
			col<=2'b0;
		else
			col<=col+1;
	end
		
		
// Row counter
always @ (posedge clk or negedge rst)
	if(~rst)
		row<=2'b0;
	else if(row_init)
		row<=2'b0;
	else if(col_go) begin
		if(row==2 && col==2)
			row<=2'b0;
		else if(col==2)
			row<=row+1;
		end
		

		
//pixel count x	
	
always @ (posedge clk or negedge rst )
	if(~rst)
		pixel_x<=8'b0;
	else if(pixel_x_init)
		pixel_x<=8'b0;
	else if(pixel_x==253 && row==2 && col==2 && col_go==1)
		pixel_x<=8'b0;
	else if(col==2 && row==2 && col_go==1)
		pixel_x<=pixel_x+1;
		


// pixel count y
		
always @ (posedge clk or negedge rst)
	if(~rst)
		pixel_y<=8'b0;
	else if(pixel_y_init)
		pixel_y<=8'b0;
	else if(pixel_x==253 && col==2 && row==2 && col_go==1)
		pixel_y<=pixel_y+1;

		
// next state ---> present state		
always @(posedge clk or negedge rst)
	if(~rst)
		ps<=0;
	else
		ps<=ns;
		
		
// inner next state ---> inner present state		
always @(posedge clk or negedge rst)
	if(~rst)
		process_ps<=0;
	else
		process_ps<=process_ns;		
		
		
		
		
		
		
endmodule
