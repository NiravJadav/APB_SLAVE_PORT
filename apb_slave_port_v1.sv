// Design : apb_slave port for LPDDR3-4 MC
// Datawidth supported by design 8/16/32 [APB_DATAWIDTH]
 


module apb_slave_port
#(
   parameter APB_ADDRWIDTH =16 , 
   parameter APB_DATAWIDTH = 32,
   parameter NB_RANK=2 
)
( 
  input 			 pclk_i		,
  input 			 prst_ni	,
  input  [APB_ADDRWIDTH-1:0]	 paddr_i	,
  input 			 psel_i		,
  input 			 penable_i	,
  input  			 pwrite_i	,
  input  [APB_DATAWIDTH-1:0]	 pwdata_i	,
  input  [3:0]			 pstrb_i	,
  output 			 pready_o	,
  output reg [APB_DATAWIDTH-1:0] prdata_o	,
  output 			 pslverr_o     	, 

  output 			rank_mrw_o	,
  output 			rank_mrr_o	,
  input 			mrw_done_status_i,
  input 			mrr_done_status_i

);

wire 				r_en	;	// read enable 	, prdata_i <-- register_bank
wire 			  	w_en	;	// write enable	, register_bank <-- pwdata_i 
wire [31:0] 			wdata_c	;	
wire [APB_DATAWIDTH-1:0]	prdata_c;

localparam ADDR_LSB = (APB_DATAWIDTH/8)>>1;  // paramter to generalize paddr_i LSB in generate loop 

// Rank Specific Registers 
wire add_00h	;	//	0x00h -->	Mode Register Address Register 
wire add_01h	;	//	0x01h -->	Mode Register Data Register
wire add_02h	;	//	0x02h --> 	Rank Access Control/Status Register
wire add_03h	;	//	0x03h --> 	Rank Index register	
wire add_04h	;	// 	0x04h --> 	PPR Control/Status Register
wire add_05h 	;	//	0x05h --> 	PPR Bank Address Register
wire add_06h  	;	//	0x06h --> 	PPR Row Address Register
wire add_07h	;	


wire [31:0] reg_data	;
// Logic for APB control signal 

	assign pready_o  = psel_i ? 1 :	0 ; 	// if slave select than salve ready 
	assign pslverr_o = 0		  ;	// not implemented 
	
	assign r_en = (psel_i & !pwrite_i 		)	;	// read_enable signal
	assign w_en = (psel_i &  pwrite_i & penable_i	)	;	// write_enable signal

// Logic for address select as datawidth is variable [8/16/32]
	generate 
		begin
		if(APB_DATAWIDTH == 8)
			begin
			assign add_00h 	= (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h00>>ADDR_LSB)) ? 1 :  0	;
			assign add_01h 	= (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h01>>ADDR_LSB)) ? 1 :  0	;
			assign add_02h	= (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h02>>ADDR_LSB)) ? 1 :  0 	;
			assign add_03h 	= (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h03>>ADDR_LSB)) ? 1 :  0	;
			assign add_04h 	= (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h04>>ADDR_LSB)) ? 1 :  0	;
			assign add_05h	= (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h05>>ADDR_LSB)) ? 1 :  0	;
			assign add_06h 	= (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h06>>ADDR_LSB)) ? 1 :  0	;
			assign add_07h 	= (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h07>>ADDR_LSB)) ? 1 :  0	;
			end
		if(APB_DATAWIDTH == 16)
			begin
			assign add_00h 	= ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h00>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_01h 	= ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h01>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;
			
			assign add_02h	= ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h02>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_03h 	= ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h03>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_04h 	= ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h04>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_05h	= ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h05>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_06h 	= ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h06>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_07h 	= ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h07>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;
			end
		if(APB_DATAWIDTH == 32)
			begin
			assign add_00h 	= ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h00>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_01h 	= ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h01>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;
			assign add_02h	= ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h02>>ADDR_LSB) & pstrb_i[2]) ? 1 :  0 ;
			assign add_03h 	= ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h03>>ADDR_LSB) & pstrb_i[3]) ? 1 :  0 ;

			assign add_04h 	= ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h04>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_05h	= ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h05>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;
			assign add_06h 	= ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h06>>ADDR_LSB) & pstrb_i[2]) ? 1 :  0 ;
			assign add_07h 	= ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h07>>ADDR_LSB) & pstrb_i[3]) ? 1 :  0 ;
			
			
			end
		end
	endgenerate	
// - * - * - * - - * - * - * - - * - * - * - - * - * - * - - * - * - * - - * - * - * - - * - * - * - 	
// Write Transfer :- 
//			pwdata_i is assigned to wdata_c [as per datawidth and given paddr_i]
//			register which address is selected, save data from  wdata_c [as per w_en]
//
// Read Transfer :-	reg_data sample data from register_bank whose address being selected !
//			prdata_c take data from reg_data [as per datawidth and paddr_i]
//			prdata_o is sample data from pwdata_c [as per r_en]		

	generate
	begin
		if(APB_DATAWIDTH == 8)
		begin
		assign wdata_c [7 : 0] =(paddr_i[1:0]==0) ? pwdata_i  : 0;
		assign wdata_c [15: 8] =(paddr_i[1:0]==1) ? pwdata_i  : 0;
		assign wdata_c [23:16] =(paddr_i[1:0]==2) ? pwdata_i  : 0;
		assign wdata_c [31:24] =(paddr_i[1:0]==3) ? pwdata_i  : 0;

		assign prdata_c		= (paddr_i[1:0]==0) ? reg_data[ 7: 0] :
					  	(paddr_i[1:0]==1) ? reg_data[15: 8] :
					  		(paddr_i[1:0]==2) ? reg_data[23:16] :
					  			(paddr_i[1:0]==3) ? reg_data[31:24] : 0 ;	 
		
		end
				
		if(APB_DATAWIDTH == 16)
		begin
		assign wdata_c [15: 0] = (paddr_i[1] ==0) ? pwdata_i  : 0;
		assign wdata_c [31:16] = (paddr_i[1] ==1) ? pwdata_i  : 0;

		assign prdata_c		= (paddr_i[1] ==0) ? reg_data[15:0] :
						(paddr_i[1] == 1)? reg_data[31:16] : 0;
		end

		if(APB_DATAWIDTH == 32)
		begin
		assign wdata_c = pwdata_i;
		assign prdata_c= reg_data;
		end
	end
	endgenerate

// - * - * - * - - * - * - * - - * - * - * - - * - * - * - - * - * - * - - * - * - * - - * - * - * - 	





// 1. Rank Specific Registers 

reg [7:0] mr_addr 	; // addr = 00h | RW
reg [7:0] mr_data 	; // addr = 01h | RW

reg  rank_mrw 		; // addr = 02h | SET
reg  rank_mrr 		; //		| SET
reg  rank_busy 		; // 		| RO
reg  mrw_done_status	; // 		| RO
reg  mrr_done_status	; // 		| RO




assign rank_mrw_o  = rank_mrw;
assign rank_mrr_o  = rank_mrr;

assign rank_busy_c = (rank_mrw | rank_mrr) ? 1'b1 :
		     (mrr_done_status_i | mrw_done_status_i)? 1'b0: rank_busy;

assign mrw_done_c  = (mrw_done_status_i) ? 1'b1 :
		     (add_02h & r_en & prdata_o[5])? 1'b0 : mrw_done_status ;

assign mrr_done_c  = (mrr_done_status_i) ? 1'b1 :
		     (add_02h & r_en & prdata_o[6])? 1'b0 :0;
//assign rank_busy_hc = (add_02h & w_en & (wdata_c[16] | wdata_c[17]));
//assign rank_busy_lc = (mrr_done_status_i | mrw_done_status_i);

//assign mrw_done_lc = add_02h & r_en & prdata_o[5];
//assign mrr_done_lc = add_02h & r_en & prdata_o[6];

///////////////////////////////////////////////////////////////////////////////////////////////

	always@(posedge pclk_i or negedge prst_ni)
	begin
		if(!prst_ni)
		begin
		// Rank Specific Reset Value 
			mr_addr 		<= 0	; // addr = 00h
			mr_data			<= 0	; // addr = 01h
			rank_mrw 		<= 0	; // addr = 02h
			rank_mrr 		<= 0	;
			rank_busy		<= 0	;
			mrw_done_status 	<= 0	;
			mrr_done_status 	<= 0	;
		end
		else 
		begin
			if(add_00h & w_en) mr_addr  <=  wdata_c[7 : 0]		;
			if(add_01h & w_en) mr_data  <=  wdata_c[15: 8]		;
			if(add_02h & w_en & wdata_c[16]) rank_mrw <=1; else rank_mrw <=0;
			if(add_02h & w_en & wdata_c[17]) rank_mrr <=1; else rank_mrr <=0;
 	
			rank_busy <=rank_busy_c; 
			mrw_done_status <= mrw_done_c;
			mrr_done_status <= mrr_done_c;		
	
			//if(rank_busy_hc) rank_busy <=1;
			//else  if (rank_busy_lc) rank_busy <=0;
		    
			//if(mrw_done_status_i) mrw_done_status <=1;
			//else if (mrw_done_lc) mrw_done_status <=0;
			
			//if(mrr_done_status_i) mrr_done_status <=1;
			//else if (mrr_done_lc) mrr_done_status <=0;  

		/*	if(add_02h & w_en) 
			begin 
			    if(wdata_c[16]) 
				begin
				rank_mrw  <=  1; rank_busy <=1; 
				end	
			end
			else 
				rank_mrw <= 0;
			

			if(add_02h & w_en)
			begin 
			    if(wdata_c[17])
				begin
				rank_mrr <=  1; rank_busy<=1;
				end
			end
			else rank_mrr <= 0;
			
	
			if(mrw_done_status_i)  begin mrw_done_status <=1; rank_busy <=0; end 
			if(mrr_done_status_i)  begin mrr_done_status <=1; rank_busy <=0; end
			if(add_02h & r_en)     begin if(prdata_o[5]) mrw_done_status <=0; if(prdata_o[6]) mrr_done_status <=0; end */
		end	
	end
	

assign reg_data[7 : 0] =(add_00h ) ? mr_addr : 0;
assign reg_data[15: 8] =(add_01h ) ? mr_data : 0;
assign reg_data[23:16] =(add_02h ) ? {1'b0, mrr_done_status, mrw_done_status, 1'b0, 1'b0 , rank_busy_c, 2'b0}	: 0;
//assign reg_data[31:24] = (add_03h) ? {all_rank_mr, 4'b0, rank_index} : 0;	

	always@(posedge pclk_i or negedge prst_ni)
	begin
		if(!prst_ni)
			prdata_o <= 0;
		else if (r_en) 
			prdata_o <= prdata_c;
	end		
	



endmodule
