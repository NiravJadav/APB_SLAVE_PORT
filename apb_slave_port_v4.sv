// Design : apb_slave port for LPDDR3-4 MC
// Datawidth supported by design 8/16/32 [APB_DATAWIDTH]
 
module apb_slave_port
#(
   parameter APB_ADDRWIDTH =16 	, 
   parameter APB_DATAWIDTH = 32	,
   parameter NB_RANK=2		,
   parameter APB_PULSEWIDTH= 1	,			// clk period in micro-sec
   parameter PULSE_INTERVAL= 2  	 		// pulse interval 
)
( 
  input 			 pclk_i			    ,  // apb_signals
  input 			 prst_ni		    ,
  input  [APB_ADDRWIDTH-1:0]	 paddr_i		    ,
  input 			 psel_i			    ,
  input 			 penable_i		    ,
  input  			 pwrite_i		    ,
  input  [APB_DATAWIDTH-1:0]	 pwdata_i		    ,
  input  [3:0]			 pstrb_i		    ,
  output 			 pready_o		    ,
  output reg [APB_DATAWIDTH-1:0] prdata_o		    ,
  output 			 pslverr_o     		    , 
 
  output 			 mc_intr_o		    ,  // mc_intr_out_pin

  output [NB_RANK-1:0]		 rank_mrw_o		    ,  // slave backend interface
  output [NB_RANK-1:0]		 rank_mrr_o		    ,
  input  [NB_RANK-1:0]		 mrw_done_status_i	    ,
  input  [NB_RANK-1:0]		 mrr_done_status_i	    ,
  input  [NB_RANK-1:0]		 ppr_status_i		    ,
  output [NB_RANK-1:0]		 ppr_en_o		    ,
  input  [NB_RANK-1:0]  	 ppr_done_status_i	    ,				

  output reg    		ca_training_start_o	    ,
  output reg    		wr_dq_training_start_o	    ,
  output reg    		wr_lvl_training_start_o	    ,
  output reg    		rd_lvl_training_start_o     ,
  output reg    		rd_gate_training_start_o    ,
  output reg    		zq_training_start_o	    ,
  output reg    		all_training_start_o	    ,  
  
  input   			ca_training_done_i	    ,
  input   			wr_dq_training_done_i	    ,
  input   			wr_lvl_training_done_i 	    ,
  input   			rd_lvl_training_done_i 	    ,
  input   			rd_gate_training_done_i     ,      
  input   			zq_training_done_i	    ,
  input   			all_training_done_i	    ,      	

  input 			 mc_ready_i		    ,
  output 			 system_traffic_enable_o    ,  
  output 			 start_initialization_o	    ,  
  
  output 			 start_freq_change_o	    ,
  output 			 pll_freq_chng_done_o	    , 

  input 			 init_resp_error_i 	    ,  // mc_err_intr_pins
  input 			 ca_resp_error_i	    ,
  input 			 read_gate_resp_error_i	    ,
  input 			 read_level_resp_error_i    ,
  input 			 write_level_resp_error_i   ,
  input 			 write_dq_resp_error_i      ,
  input 			 mc_error_i		    ,
  input 			 test_mode_intr_i	    ,  // mc_intr_pins
  input 			 freq_change_error_i	    ,
  input 			 freq_change_done_i	    ,
  input 			 freq_change_ready_i	    ,
  input 			 watch_dog_timeout_i	    ,
  input 			 refresh_x_trm_i	    ,    
  
  output 			 mr_rd_pulse_o				
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
wire add_07h	;	// 	0x07h --> 	PPR Row Address Register

wire add_10h	;	// 	0x10h --> 	Training Register
wire add_14h	;	//	0x14h --> 	MC Control/Status Register
wire add_19h	;	//	0x19h --> 	Power Down Control/Status Register-2 
wire add_1ch	;	//	0x1ch --> 	Frequency Change Register
wire add_20h	;	//	0x20h --> 	Strap Configuration Register

wire add_40h	;	// 	0x40h --> 	Timer5 register

wire add_60h	;	//	0x60h --> 	Rank Interrupt Status Register
wire add_61h	;	//	0x61h -->   	MC Error Interrupt Satatus Regsiter	
wire add_62h	;	//	0x62h -->	MC Inerrupt Status Register
wire add_64h	;	//	0x64h -->	Rank Interrupt Enable Register
wire add_65h	;	//	0x65h -->	MC Error Interrupt Enable Register
wire add_66h	;	//	0x66h -->	MC Interrupt Enable Register

wire [31:0] reg_data	;
// Logic for APB control signal 

	assign pready_o  = psel_i ? 1 :	0 ; 	// if slave select than salve ready 
	assign pslverr_o = 0		  ;	// not implemented 
	
	assign r_en = (!pwrite_i & penable_i	)	;	// read_enable signal
	assign w_en = ( pwrite_i & penable_i	)	;	// write_enable signal

// Logic for address select as datawidth is variable [8/16/32]
	generate 
		begin
		if(APB_DATAWIDTH == 8)
			begin
			assign add_00h 	= (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h00>>ADDR_LSB)) ) ? 1 :  0	;
			assign add_01h 	= (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h01>>ADDR_LSB)) ) ? 1 :  0	;
			assign add_02h	= (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h02>>ADDR_LSB)) ) ? 1 :  0 	;
			assign add_03h 	= (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h03>>ADDR_LSB)) ) ? 1 :  0	;
			assign add_04h 	= (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h04>>ADDR_LSB)) ) ? 1 :  0	;
			assign add_05h	= (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h05>>ADDR_LSB)) ) ? 1 :  0	;
			assign add_06h 	= (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h06>>ADDR_LSB)) ) ? 1 :  0	;
			assign add_07h 	= (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h07>>ADDR_LSB)) ) ? 1 :  0	;
			
			assign add_10h 	= (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h10>>ADDR_LSB)) ) ? 1 :  0	;
			assign add_14h 	= (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h14>>ADDR_LSB)) ) ? 1 :  0	;	
			assign add_19h 	= (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h19>>ADDR_LSB)) ) ? 1 :  0	;
			
			assign add_1ch 	= (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h1c>>ADDR_LSB)) ) ? 1 :  0	;
			
			assign add_20h 	= (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h20>>ADDR_LSB)) ) ? 1 :  0	;

			assign add_40h 	= (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h40>>ADDR_LSB)) ) ? 1 :  0	;
			
			assign add_60h 	= (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h60>>ADDR_LSB)) ) ? 1 :  0	;
			assign add_61h 	= (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h61>>ADDR_LSB)) ) ? 1 :  0	;
			assign add_62h 	= (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h62>>ADDR_LSB)) ) ? 1 :  0	;
			assign add_64h 	= (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h64>>ADDR_LSB)) ) ? 1 :  0	;
			assign add_65h 	= (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h65>>ADDR_LSB)) ) ? 1 :  0	;
			assign add_66h 	= (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h66>>ADDR_LSB)) ) ? 1 :  0	;
			end
		if(APB_DATAWIDTH == 16)
			begin
			assign add_00h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h00>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_01h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h01>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;
			
			assign add_02h	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h02>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_03h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h03>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;

			assign add_04h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h04>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_05h	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h05>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;

			assign add_06h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h06>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_07h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h07>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;
			
			assign add_10h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h10>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_14h	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h14>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			
			assign add_19h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h19>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;
			
			assign add_1ch 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h1c>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			
			assign add_20h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h20>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			
			assign add_40h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h40>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			
			assign add_60h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h60>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_61h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h61>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;

			assign add_62h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h62>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;

			assign add_64h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h64>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_65h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h65>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;

			assign add_66h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h66>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			
			end
		if(APB_DATAWIDTH == 32)
			begin
			assign add_00h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h00>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_01h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h01>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;
			assign add_02h	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h02>>ADDR_LSB) & pstrb_i[2]) ) ? 1 :  0 ;
			assign add_03h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h03>>ADDR_LSB) & pstrb_i[3]) ) ? 1 :  0 ;

			assign add_04h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h04>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_05h	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h05>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;
			assign add_06h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h06>>ADDR_LSB) & pstrb_i[2]) ) ? 1 :  0 ;
			assign add_07h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h07>>ADDR_LSB) & pstrb_i[3]) ) ? 1 :  0 ;

			
			assign add_10h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h10>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_14h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h14>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;


			assign add_19h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h19>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;
			
			assign add_1ch 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h1c>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;

			assign add_20h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h20>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
		
			assign add_40h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h40>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			
			assign add_60h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h60>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_61h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h61>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;
			assign add_62h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h62>>ADDR_LSB) & pstrb_i[2]) ) ? 1 :  0 ;

			assign add_64h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h64>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_65h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h65>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;
			assign add_66h 	= ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h66>>ADDR_LSB) & pstrb_i[2]) ) ? 1 :  0 ;
			
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

reg [NB_RANK-1:0][7:0] mr_addr 		; // addr = 00h | RW
reg [NB_RANK-1:0][7:0] mr_data 		; // addr = 01h | RW

reg [NB_RANK-1:0] rank_mrw 		; // addr = 02h | SET
reg [NB_RANK-1:0] rank_mrr 		; //		| SET
reg [NB_RANK-1:0] rank_busy 		; // 		| RO
reg [NB_RANK-1:0] mrw_done_status	; // 		| RO
reg [NB_RANK-1:0] mrr_done_status	; // 		| RO
reg [NB_RANK-1:0] ppr_done_status	; // 		| RO

reg [2:0]	  rank_index		; // addr = 03h | RW
reg		  all_rank_mr		; // 		| RW

reg [NB_RANK-1:0] ppr_enable		; // addr = 04h | SET
reg [NB_RANK-1:0] ppr_status		; // 		| RO

reg [NB_RANK-1:0][2:0]  ppr_bank_addr	; // addr = 05h | RW 
reg [NB_RANK-1:0][15:0] ppr_row_addr	; // addr = 06h,07h | RW

reg 		  ca_training 		; // addr = 10h | RW
reg 		  wr_dq_training 	; // 		| Rw
reg 		  wr_lvl_training 	; // 		| Rw
reg 		  rd_lvl_training 	; // 		| Rw
reg 		  rd_gate_training 	; // 		| Rw
reg 		  zq_training		; // 		| Rw
reg 		  all_training		; // 		| Rw

reg 		  mc_ready		; // addr = 14h | RO
reg 		  soft_reset		; // 		| R/Set
reg 		  system_traffic_enable ; // 		| RW

reg 		  mr_rd_disable		; // addr = 19h | RW

reg [4:0]	  freq_index		; // addr = 1ch | RW
reg 		  start_freq_change	; // 		| SET
reg 		  pll_freq_chng_done	; // 		| SET

reg 		  lpddr3		; // addr = 20h | RW
reg 		  start_initialization	; //            | RW

reg [5:0] 	  mr4rd_interval_timer	; // addr = 40h | RW

reg [7:0]	  rank_intr		; // addr = 60h | RO/COR

reg 		  init_resp_error	; // addr = 61h | RO/COR
reg 		  ca_resp_error		;
reg 		  read_gate_resp_error	;
reg 		  read_level_resp_error	;
reg 		  write_level_resp_error;
reg 		  write_dq_resp_error	;
reg 		  mc_error		;

reg 		 test_mode_intr		; // addr = 62h  | RO/CPR
reg 		 freq_change_error	; //		 | RO/COR
reg 		 freq_change_done	; //		 | RO/COR
reg 		 freq_change_ready 	; //		 | RO/COR
reg 		 watch_dog_timeout	; //		 | RO/COR
reg 		 refresh_x_trm		; //		 | RO/COR	   

reg [7:0] 	  rank_intr_en		; // addr = 64h | RW

reg 		  init_resp_error_en		; // addr = 65h | RW 
reg 		  ca_resp_error_en		; //		| RW
reg 		  read_gate_resp_error_en	; //		| RW
reg 		  read_level_resp_error_en	; //		| RW
reg 		  write_level_resp_error_en	; //		| RW
reg 		  write_dq_resp_error_en	; //		| RW
reg 		  mc_error_en			; //		| RW

reg		intr_0_en	; // addr = 66h  | RW
reg		intr_1_en	; //		 | RW
reg		intr_2_en	; //		 | RW
reg		intr_3_en	; //		 | RW
reg		intr_4_en	; //		 | RW
reg		intr_5_en	; //		 | RW

reg [31:0] 	mr4rd_count	; // hold count value for mr4rd_interval_timer
///////////////////////////////////////////////////////////////////////////////////////////////

wire [NB_RANK-1:0] rank_busy_c	;
wire [NB_RANK-1:0] mrw_done_c	;
wire [NB_RANK-1:0] mrr_done_c	;
wire [NB_RANK-1:0] rank_intr_c	;
wire [NB_RANK-1:0] ppr_done_c	;
wire [NB_RANK-1:0] ppr_status_c	;

wire 		ca_training_c		;
wire 		wr_dq_training_c	;
wire 		wr_lvl_training_c	;
wire 		rd_lvl_training_c	;
wire 		rd_gate_training_c	;
wire 		zq_training_c		;
wire 		all_training_c		;


wire 		mc_ready_c		;
genvar i;

generate 
    for(i =0;i<NB_RANK ;i++)
	begin  
	    assign rank_mrw_o[i]    = rank_mrw[i]; // output pin
	    assign rank_mrr_o[i]    = rank_mrr[i]; // output pin
	    
	    assign rank_busy_c[i]    = (rank_mrw[i] | rank_mrr[i])  ? 1'b1 :
			 		     (mrr_done_status_i[i] | mrw_done_status_i[i])? 1'b0: rank_busy[i];
	    
	    assign mrw_done_c[i]    = (mrw_done_status_i[i]) ? 1'b1 :
					     (add_02h & r_en & (rank_index == i))? 1'b0 : mrw_done_status[i] ;
	    
	    assign mrr_done_c[i]    = (mrr_done_status_i[i]) ? 1'b1 :
			 		     (add_02h & r_en & (rank_index == i)) ? 1'b0 :mrr_done_status[i];
	
	    assign ppr_done_c[i]    = (ppr_done_status_i[i]) ? 1'b1 :
					     (add_02h & r_en & (rank_index == i)) ? 1'b0 :ppr_done_status[i]; 

	    assign rank_intr_c[i]   = (mrr_done_status_i[i] | mrw_done_status_i[i] | ppr_done_status_i[i]) ? 1'b1 :
					    (add_60h & r_en) ? 1'b0 : rank_intr[i];  
	   
	    assign ppr_en_o [i]	    = ppr_enable[i]; // output pin 

	    assign ppr_status_c[i]  = (ppr_status_i[i])	     ? 1'b1 :
					    (add_04h & r_en & (rank_index == i)) ? 1'b0 : ppr_status[i];
				      
					     
	    
	end
endgenerate 


assign ca_training_c	 	= (add_10h & w_en & wdata_c[0]) ? 1'b1 :
				  (ca_training_done_i	)	? 1'b0 : ca_training	;		
assign wr_dq_training_c		= (add_10h & w_en & wdata_c[1]) ? 1'b1 :
				  (wr_dq_training_done_i)	? 1'b0 : wr_dq_training	;  
assign wr_lvl_training_c	= (add_10h & w_en & wdata_c[2]) ? 1'b1 :
				  (wr_lvl_training_done_i)      ? 1'b0 : wr_lvl_training;
assign rd_lvl_training_c	= (add_10h & w_en & wdata_c[3]) ? 1'b1 :
				  (rd_lvl_training_done_i) 	? 1'b0 : rd_lvl_training;
assign rd_gate_training_c	= (add_10h & w_en & wdata_c[4]) ? 1'b1 :
				  (rd_gate_training_done_i)	? 1'b0 : rd_gate_training;
assign zq_training_c		= (add_10h & w_en & wdata_c[5]) ? 1'b1 :
				  (zq_training_done_i	)	? 1'b0 : zq_training	;
assign all_training_c		= (add_10h & w_en & wdata_c[6]) ? 1'b1 :
				  (all_training_done_i	)	? 1'b0 : all_training	;


assign start_initialization_o 	= start_initialization ;
assign system_traffic_enable_o  = system_traffic_enable;

assign start_freq_change_o 	= start_freq_change;
assign pll_freq_chng_done_o 	= pll_freq_chng_done;
assign mc_ready_c = (mc_ready_i) ? 1'b1 :
		    (!mc_ready_i)? 1'b0	:
		    (add_14h & r_en) ? 1'b0 : mc_ready;
		     	 

assign init_resp_error_c 	= (init_resp_error_i)	    ? 1'b1 :
					(add_61h & r_en)    ? 1'b0 : init_resp_error	    ;
assign ca_resp_error_c 		= (ca_resp_error_i)	    ? 1'b1 :
					(add_61h & r_en)    ? 1'b0 : ca_resp_error	    ;
assign read_gate_resp_error_c	= (read_gate_resp_error_i)  ? 1'b1 :
					(add_61h & r_en)    ? 1'b0 : read_gate_resp_error   ;
assign read_level_resp_error_c 	= (read_level_resp_error_i) ? 1'b1 :
					(add_61h & r_en)    ? 1'b0 : read_level_resp_error  ;
assign write_level_resp_error_c = (write_level_resp_error_i)? 1'b1 :
					(add_61h & r_en)    ? 1'b0 : write_level_resp_error ;
assign write_dq_resp_error_c 	= (write_dq_resp_error_i)   ? 1'b1 :
					(add_61h & r_en)    ? 1'b0 : write_dq_resp_error    ;
assign mc_error_c 		= (mc_error_i)		    ? 1'b1 :
					(add_61h & r_en)    ? 1'b0 : mc_error		    ;

assign test_mode_intr_c 	= (test_mode_intr_i)	    ? 1'b1 :
					(add_62h & r_en)    ? 1'b0 : test_mode_intr	    ;
assign freq_change_error_c 	= (freq_change_error_i)	    ? 1'b1 :
					(add_62h & r_en)    ? 1'b0 : freq_change_error	    ;
assign freq_change_done_c 	= (freq_change_done_i)	    ? 1'b1 : 
					(add_62h & r_en)    ? 1'b0 : freq_change_done	    ;
assign freq_change_ready_c	= (freq_change_ready_i)	    ? 1'b1 :
					(add_62h & r_en)    ? 1'b0 : freq_change_ready	    ;
assign watch_dog_timeout_c 	= (watch_dog_timeout_i)	    ? 1'b1:
					(add_62h & r_en)    ? 1'b0 : watch_dog_timeout	    ;
assign refresh_x_trm_c 		= (refresh_x_trm_i)	    ? 1'b1 : 
					(add_62h & r_en)    ? 1'b0 : refresh_x_trm	    ; 

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//--> Interrupt FLAG Logic
wire [NB_RANK-1:0]rank_intr_or;
wire mc_err_intr_or;
wire mc_intr_or;

    assign mc_intr_o = (  rank_intr_or | mc_intr_or ) ;  // Interrupt pin logic 

genvar j;

generate
for(j=0; j<NB_RANK; j++)
 begin
    assign rank_intr_or[j] = (rank_intr_en[j]  & ( mrw_done_status_i[j] | mrr_done_status_i[j] | ppr_done_status_i[j]) ) ;
 end
endgenerate 

    assign mc_err_intr_or = (	( init_resp_error_en	    & init_resp_error_i 	) |
			    	( ca_resp_error_en	    & ca_resp_error_i 		) |
			    	( read_gate_resp_error_en   & read_gate_resp_error_i 	) |
			    	( read_level_resp_error_en  & read_level_resp_error_i 	) |
			    	( write_level_resp_error_en & write_level_resp_error_i 	) |
			    	( write_dq_resp_error_en    & write_dq_resp_error_i	) |
			    	( mc_error_en		    & mc_error_i		) 	);	
    
   assign mc_intr_or = ( 	( intr_1_en      & freq_change_error_i	)|
				( intr_2_en      & freq_change_done_i	)|               
				( intr_3_en      & freq_change_ready_i	)|              
				( intr_4_en      & watch_dog_timeout_i	)|              
				( intr_5_en      & refresh_x_trm_i	)	);       
				
///////////////////////////////////////////////////////////////////////////////////////////////
// --> Pulse output Logic

	assign mr_rd_pulse_o = (mr4rd_count == ((mr4rd_interval_timer * PULSE_INTERVAL)/APB_PULSEWIDTH))? 1'b1 : 1'b0;  // 	count = interval_timer*PULSE_INTERVAL 
	assign mr_rd_cnt_rst = mr_rd_pulse_o ? 1'b1 :1'b0;														//  		 	APB_PULSEWIDTH

///////////////////////////////////////////////////////////////////////////////////////////////

	always@(posedge pclk_i or negedge prst_ni)
	begin
		if(!prst_ni | soft_reset)
		begin
		// Rank Specific Reset Value 
			mr_addr 			<= 0	; // addr = 00h
			mr_data				<= 0	; // addr = 01h
			rank_mrw 			<= 0	; // addr = 02h
			rank_mrr 			<= 0	;
			rank_busy			<= 0	;
			mrw_done_status 		<= 0	;
			mrr_done_status 		<= 0	;
			ppr_done_status			<= 0	;
			rank_index 			<= 0	; // addr = 03h
			all_rank_mr			<= 0 	;

			ppr_enable			<= 0	; // addr = 04h
			ppr_status			<= 0	;
			
			ppr_bank_addr 			<= 0	; // addr = 05h
			ppr_row_addr			<= 0	; // addr = 06h,07h
			
			ca_training 			<= 0    ; // addr = 10h 	
		        wr_dq_training 	                <= 0	;
			wr_lvl_training 	        <= 0    ;
                        rd_lvl_training 	        <= 0    ;
                        rd_gate_training 	        <= 0    ;
                        zq_training		        <= 0    ;
	                all_training		        <= 0    ;
			
			ca_training_start_o 		<= 0    ; // output pin 	
		        wr_dq_training_start_o          <= 0	;
			wr_lvl_training_start_o 	<= 0    ;
                        rd_lvl_training_start_o 	<= 0    ;
                        rd_gate_training_start_o        <= 0    ;
                        zq_training_start_o		<= 0    ;
	                all_training_start_o		<= 0    ;
			
			mc_ready			<= 0	; // addr = 14h
			soft_reset			<= 0	; 
			system_traffic_enable		<= 0	;

			mr_rd_disable			<= 0	; // addr = 19h

			freq_index			<= 0	; // addr = 1ch
			start_freq_change		<= 0	;
			pll_freq_chng_done		<= 0	;
			
			lpddr3				<= 0	; // addr = 20h
			start_initialization		<= 0	; 
 
			 if(lpddr3) mr4rd_interval_timer <= 'h2 ; else mr4rd_interval_timer <= 'h2 ; // addr 40h			 
			 
			rank_intr			<= 0	; // addr = 60h

			init_resp_error			<= 0    ; // addr = 61h
			ca_resp_error			<= 0	;
                        read_gate_resp_error		<= 0    ;
                        read_level_resp_error		<= 0    ;
                        write_level_resp_error 		<= 0    ;
	                write_dq_resp_error		<= 0    ;
			mc_error			<= 0    ;
		
			test_mode_intr			<= 0	; // addr = 62h
			freq_change_error		<= 0	;
			freq_change_done		<= 0 	;
			freq_change_ready		<= 0	;
			watch_dog_timeout		<= 0	;
			refresh_x_trm 			<= 0	;	

			rank_intr_en			<= 'hff	; // addr = 64h
						
			init_resp_error_en		<= 1    ; // addr = 65h 		
			ca_resp_error_en		<= 1	;		
	                read_gate_resp_error_en		<= 1    ;
	                read_level_resp_error_en	<= 1    ; 	
	                write_level_resp_error_en	<= 1    ; 
	                write_dq_resp_error_en		<= 1    ;
	                mc_error_en			<= 1    ; 
			
			intr_0_en			<= 1    ; // addr = 66h	
			intr_1_en               	<= 1	; 
			intr_2_en               	<= 1    ;
			intr_3_en               	<= 1    ; 
			intr_4_en               	<= 1    ; 
			intr_5_en			<= 1    ;
		end
		else 
		begin
			if(add_00h & w_en)		    mr_addr[rank_index]  <=  wdata_c[7 : 0]		    ;
			if(add_01h & w_en)		    mr_data[rank_index] <=  wdata_c[15: 8]		    ;
			if(add_02h & w_en & wdata_c[16])    rank_mrw[rank_index] <=1; else rank_mrw [rank_index]<=0 ;
			if(add_02h & w_en & wdata_c[17])    rank_mrr[rank_index] <=1; else rank_mrr [rank_index]<=0 ;
 	
			rank_busy	 <= rank_busy_c; 
			mrw_done_status  <= mrw_done_c;
			mrr_done_status  <= mrr_done_c;		
			ppr_done_status  <= ppr_done_c;
 
			if(add_03h & w_en) {all_rank_mr , rank_index} <= {wdata_c[31],wdata_c[26:24]};
			
			if(add_04h & w_en & wdata_c[0])	    ppr_enable[rank_index] <= 1;else ppr_enable[rank_index] <=0; 	
			ppr_status	<= ppr_status_c;	
			if(add_05h & w_en) ppr_bank_addr[rank_index] <= wdata_c[10:8]		; // addr = 05h
			if(add_06h & w_en) ppr_row_addr [rank_index][7:0] <= wdata_c[23:16]	; // addr = 06h
			if(add_07h & w_en) ppr_row_addr [rank_index][15:8]<= wdata_c[31:24]	; // addr = 07h
		
			ca_training 	       <= ca_training_c	   	    ; // addr = 10h
			wr_dq_training 	       <= wr_dq_training_c   	    ;
			wr_lvl_training        <= wr_lvl_training_c 	    ;
			rd_lvl_training        <= rd_lvl_training_c 	    ;
			rd_gate_training       <= rd_gate_training 	    ;
			zq_training	       <= zq_training_c	            ;
			all_training	       <= all_training_c	    ;
			
			if(add_10h & w_en & wdata_c[0]) ca_training_start_o 	<= 1; else ca_training_start_o 		<= 0 ;	 // output pin
                        if(add_10h & w_en & wdata_c[1]) wr_dq_training_start_o 	<= 1; else wr_dq_training_start_o 	<= 0 ;   //
                        if(add_10h & w_en & wdata_c[2]) wr_lvl_training_start_o	<= 1; else wr_lvl_training_start_o	<= 0 ;   //
                        if(add_10h & w_en & wdata_c[3]) rd_lvl_training_start_o <= 1; else rd_lvl_training_start_o	<= 0 ;   //
                        if(add_10h & w_en & wdata_c[4]) rd_gate_training_start_o<= 1; else rd_gate_training_start_o	<= 0 ;   //
                        if(add_10h & w_en & wdata_c[5]) zq_training_start_o	<= 1; else zq_training_start_o		<= 0 ;   //
                        if(add_10h & w_en & wdata_c[6]) all_training_start_o 	<= 1; else all_training_start_o 	<= 0 ;   //

			
			mc_ready <= mc_ready_c;
			
			if(add_14h & w_en) system_traffic_enable <= wdata_c[7]	; // addr = 14h
			if(add_14h & w_en & wdata_c[4]) soft_reset <= 1		; 

			if(add_19h & w_en) mr_rd_disable <= wdata_c[11]		; // addr = 19h
			
			
			if(add_1ch & w_en) freq_index   <= wdata_c[4:0]						; // addr = 1ch
			if(add_1ch & w_en & wdata_c[5]) start_freq_change <= 1; else start_freq_change <=0	;
			if(add_1ch & w_en & wdata_c[6]) pll_freq_chng_done <= 1;else pll_freq_chng_done <= 0	;  


			if(add_20h & w_en) lpddr3 <= wdata_c[0]			; // addr = 20h
			if(add_20h & w_en) start_initialization <= wdata_c[7]	; else start_initialization <=0	     ;
		
			if(add_40h & w_en) mr4rd_interval_timer <= wdata_c[5:0]	; // addr = 40h
	
			rank_intr	<= rank_intr_c				; // addr = 60h 	

			init_resp_error		<=   init_resp_error_c		; // addr = 61h
                        ca_resp_error		<=   ca_resp_error_c		;
                        read_gate_resp_error	<=   read_gate_resp_error_c	;
                        read_level_resp_error	<=   read_level_resp_error_c	;
                        write_level_resp_error  <=   write_level_resp_error_c	;
                        write_dq_resp_error	<=   write_dq_resp_error_c	;
	                mc_error		<=   mc_error_c			;
		
			test_mode_intr		<=   test_mode_intr_c		; // addr = 62h			
			freq_change_error	<=   freq_change_error_c	;
                        freq_change_done	<=   freq_change_done_c		;
                        freq_change_ready 	<=   freq_change_ready_c 	;
                        watch_dog_timeout	<=   watch_dog_timeout_c	;
                        refresh_x_trm		<=   refresh_x_trm_c		;
		
			if(add_64h & w_en) 		    rank_intr_en <= wdata_c[7:0]; // addr = 64h
			
			if(add_65h & w_en) { mc_error_en,write_dq_resp_error_en,  write_level_resp_error_en, read_gate_resp_error_en, read_level_resp_error_en, ca_resp_error_en,init_resp_error_en} <= wdata_c[15:8];	//addr = 65h
			if(add_66h & w_en) {intr_5_en , intr_4_en, intr_3_en, intr_2_en, intr_1_en, intr_0_en} <= wdata_c[21:16];

		end	
	end
	

assign reg_data[7 : 0] =(add_00h ) ? mr_addr[rank_index] :
			(add_04h ) ? {6'b0,ppr_status[rank_index],1'b0} :
			(add_10h ) ? {1'b0 , all_training, zq_training, rd_gate_training,rd_lvl_training, wr_lvl_training, wr_dq_training, ca_training} :
			(add_14h ) ? {system_traffic_enable , 2'b0, soft_reset, 3'b0, mc_ready} : 				
			(add_1ch ) ? {3'b0, freq_index} :
			(add_20h ) ? {start_initialization, 6'b0 , lpddr3} :
			(add_40h ) ? {2'b0,mr4rd_interval_timer} :
			(add_60h ) ? {rank_intr}:
			(add_64h ) ? {rank_intr_en} : 8'b0;


assign reg_data[15: 8] =(add_01h ) ? mr_data[rank_index] :
			(add_05h ) ? {5'b0, ppr_bank_addr[rank_index]} :
			(add_19h ) ? {4'b0, mr_rd_disable, 3'b0} :
			(add_61h ) ? {1'b0, mc_error, write_dq_resp_error, write_level_resp_error, read_level_resp_error, read_gate_resp_error, ca_resp_error, init_resp_error} :
			(add_65h ) ? {1'b0, mc_error_en,write_dq_resp_error_en,  write_level_resp_error_en, read_gate_resp_error_en, read_level_resp_error_en, ca_resp_error_en,init_resp_error_en} 	 : 8'b0;

assign reg_data[23:16] =(add_02h ) ? {ppr_done_status[rank_index], mrr_done_status[rank_index], mrw_done_status[rank_index], 1'b0, 1'b0 , rank_busy_c[rank_index], 2'b0} :
			(add_06h ) ? {ppr_row_addr[7:0]} :
			(add_62h ) ? {2'b0,refresh_x_trm, watch_dog_timeout, freq_change_ready, freq_change_done, freq_change_error, test_mode_intr} :
			(add_66h ) ? {2'b0, intr_5_en , intr_4_en, intr_3_en, intr_2_en, intr_1_en, intr_0_en} : 8'b0;

assign reg_data[31:24] =(add_03h ) ? {all_rank_mr, 4'b0, rank_index} :
			(add_07h ) ? {ppr_row_addr[15:8]}	     : 8'b0;	

	always@(posedge pclk_i or negedge prst_ni)
	begin
		if(!prst_ni | soft_reset)
			prdata_o <= 0;
		else  
			prdata_o <= prdata_c;
	end		
	


always@(posedge pclk_i or negedge prst_ni)
begin
 if(!prst_ni | mr_rd_disable | mr_rd_pulse_o )  
       mr4rd_count <=0;
 else if(!mr_rd_disable) 
       mr4rd_count <= mr4rd_count +1;
end
 
 


endmodule
