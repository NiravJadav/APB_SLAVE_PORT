// Design : apb_slave port for LPDDR3-4 MC
// Datawidth supported by design 8/16/32 [APB_DATAWIDTH]
 
module apb_slave_port
#(
   parameter APB_ADDRWIDTH =16				    ,
   parameter APB_DATAWIDTH = 32				    ,
   parameter NB_RANK=2					    , // number of rank
   parameter APB_PULSEWIDTH= 1				    , // clk period in micro-sec
   parameter PULSE_INTERVAL= 10 			      // unit pulse interval 
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
  output [2:0][NB_RANK-1:0] 	 ppr_bank_addr_o	    ,
  output [15:0][NB_RANK-1:0]	 ppr_row_addr_o		    ,

  output [6:0] 	 		 act2pre_timer_o	    ,       
  output [4:0] 	 		 rd2pre_timer_o		    ,
  output [5:0] 	 		 act2rw_timer_o		    ,
  output [5:0] 	 		 pre_pb2any_timer_o	    ,
  output [5:0] 	 		 pre_ab2any_timer_o	    ,     	 		                         
  output [5:0] 	 		 write_recovery_timer_o     ,       
  output [4:0] 	 		 write2read_timer_o	    ,
  output [3:0] 	 		 wpre_rpst_dqsck_o	    ,       
  output [4:0] 	 		 act2act_timer_o	    ,       
  output [5:0] 	 		 mrr2any_timer_o	    ,       
  output [5:0] 	 		 mrw2any_timer_o	    ,            	 		                         
  output [9:0] 	 		 ref_per_bank_timer_o	    ,
  output [10:0]	 		 ref_all_bank_timer_o	    ,     	 		                         
  output [5:0] 	 		 min_zq_latch_timer_o	    ,
  output [9:0] 	 		 vref_chng2any_timer_o	    ,
  output [10:0]	 		 refresh_interval_timer_o   ,	
  output [4:0] 	 		 min_pd_timer_o		    ,     	 		                         
  output [5 :0]	 		 mr4rd_interval_timer_o     ,       
  output [11:0]	 		 min_zqcal_timer_o	    ,       
  output [2:0] 	 		 derated_timer_o	    ,       
  output [7 :0]	 		 vref_current_mode_dis_o    ,	     	 		                         
  output [16:0]	 		 min_pprdis2any_o	    ,       
  output [5:0] 	 		 m_in_sr_timer_o	    ,             	 		                         
  output [4:0] 	 		 ca_data_out_delay_o	    ,
  output [5:0] 	 		 f_out_act_window_o	    ,     	 		                         
  output [7:0] 	 		 dfi_tphywrdata_o	    ,       
  output [7:0] 	 		 dfi_tphywrlat_o	    ,       
  output [7:0] 	 		 dfi_tphyrddataen_o	    ,
  output [7:0] 	 		 dfi_tphyrdlat_o	    ,       
  output [31:0]		 	 ppr_program_time_o	    ,            			                         
  output 			 update_all_timers_o	    ,

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
  
  output [4:0]			 freq_index_o		    ,
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
  
  output 			 mr_rd_pulse_o			// mr4rd pulse output		
);

wire 				r_en	;	// read enable 	, prdata_i <-- register_bank
wire 			  	w_en	;	// write enable	, register_bank <-- pwdata_i 
wire [31:0] 			wdata_c	;	
wire [APB_DATAWIDTH-1:0]	prdata_c;
wire [31:0]			reg_data;

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

// Common Registers
wire add_10h	;	// 	0x10h --> 	Training Register
wire add_14h	;	//	0x14h --> 	MC Control/Status Register
wire add_19h	;	//	0x19h --> 	Power Down Control/Status Register-2 
wire add_1ch	;	//	0x1ch --> 	Frequency Change Register
wire add_20h	;	//	0x20h --> 	Strap Configuration Register

// Timer Registers
wire add_30h	;	//	0x30h -->	Timer1 Register
wire add_31h	;	
wire add_32h	;
wire add_33h	;
wire add_34h	;	//	0x34h --> 	Timer2 Register
wire add_35h	;
wire add_36h	;
wire add_37h	;	
wire add_38h 	;	//	0x38h --> 	Timer3 Register
wire add_39h	;	
wire add_3ah	;
wire add_3bh	;
wire add_3ch 	;	//	0x3ch -->	Timer4 Register
wire add_3dh	;
wire add_3eh	;
wire add_3fh	;
wire add_40h	;	//	0x40h --> 	Timer5 Register
wire add_41h	;
wire add_42h	;
wire add_43h	;
wire add_44h	;	//	0x44h -->	Timer6 Register
wire add_45h	;
wire add_46h	;
wire add_47h	;
wire add_48h	;	//	0x48h --> 	Timer7 Register
wire add_49h	;
wire add_4ah	;
wire add_4bh	;
wire add_4ch	;	//	0x4ch --> 	DFI Timer Register
wire add_4dh	;
wire add_4eh	;
wire add_4fh	;
wire add_50h	;	//	0x50h --> 	PPR Timer Register
wire add_51h	;
wire add_52h	;
wire add_53h	;
wire add_5ch	;	//	0x5ch -->	Timer Control Register

// Interrupt Registers
wire add_60h	;	//	0x60h --> 	Rank Interrupt Status Register
wire add_61h	;	//	0x61h -->   	MC Error Interrupt Satatus Regsiter	
wire add_62h	;	//	0x62h -->	MC Inerrupt Status Register
wire add_64h	;	//	0x64h -->	Rank Interrupt Enable Register
wire add_65h	;	//	0x65h -->	MC Error Interrupt Enable Register
wire add_66h	;	//	0x66h -->	MC Interrupt Enable Register


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
			
			assign add_30h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h30>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_31h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h31>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_32h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h32>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_33h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h33>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_34h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h34>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_35h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h35>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_36h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h36>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_37h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h37>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_38h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h38>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_39h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h39>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_3ah =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h3a>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_3bh =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h3b>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_3ch =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h3c>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_3dh =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h3d>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_3eh =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h3e>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_3fh =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h3f>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_40h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h40>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_41h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h41>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_42h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h42>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_43h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h43>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_44h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h44>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_45h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h45>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_46h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h46>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_47h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h47>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_48h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h48>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_49h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h49>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_4ah =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h4a>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_4bh =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h4b>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_4ch =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h4c>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_4dh =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h4d>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_4eh =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h4e>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_4fh =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h4f>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_50h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h50>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_51h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h51>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_52h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h52>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_53h =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h53>>ADDR_LSB)) ) ? 1 :  0  ;
			assign add_5ch =  (psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h5c>>ADDR_LSB)) ) ? 1 :  0  ;

			
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

			assign add_30h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h30>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_31h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h31>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;

			assign add_32h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h32>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_33h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h33>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;

			assign add_34h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h34>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_35h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h35>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;

			assign add_36h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h36>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_37h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h37>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;

			assign add_38h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h38>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_39h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h39>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;

			assign add_3ah =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3a>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_3bh =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3b>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;

			assign add_3ch =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3c>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_3dh =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3d>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;

			assign add_3eh =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3e>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_3fh =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3f>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;

			assign add_40h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h40>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_41h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h41>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;

			assign add_42h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h42>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_43h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h43>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;

			assign add_44h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h44>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_45h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h45>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;

			assign add_46h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h46>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_47h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h47>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;

			assign add_48h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h48>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_49h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h49>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;
			
			assign add_4ah =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4a>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_4bh =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4b>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;
			
			assign add_4ch =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4c>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_4dh =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4d>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;

			assign add_4eh =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4e>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_4fh =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4f>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;

			assign add_50h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h50>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_51h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h51>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;

			assign add_52h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h52>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_53h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h53>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;

			assign add_5ch =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h5c>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			
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
			
			assign add_30h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h30>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_31h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h31>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;
			assign add_32h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h32>>ADDR_LSB) & pstrb_i[2]) ) ? 1 :  0 ;
			assign add_33h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h33>>ADDR_LSB) & pstrb_i[3]) ) ? 1 :  0 ;

			assign add_34h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h34>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_35h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h35>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;
			assign add_36h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h36>>ADDR_LSB) & pstrb_i[2]) ) ? 1 :  0 ;
			assign add_37h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h37>>ADDR_LSB) & pstrb_i[3]) ) ? 1 :  0 ;

			assign add_38h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h38>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_39h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h39>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;
			assign add_3ah =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3a>>ADDR_LSB) & pstrb_i[2]) ) ? 1 :  0 ;
			assign add_3bh =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3b>>ADDR_LSB) & pstrb_i[3]) ) ? 1 :  0 ;

			assign add_3ch =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3c>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_3dh =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3d>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;
			assign add_3eh =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3e>>ADDR_LSB) & pstrb_i[2]) ) ? 1 :  0 ;
			assign add_3fh =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3f>>ADDR_LSB) & pstrb_i[3]) ) ? 1 :  0 ;

			assign add_40h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h40>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_41h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h41>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;
			assign add_42h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h42>>ADDR_LSB) & pstrb_i[2]) ) ? 1 :  0 ;
			assign add_43h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h43>>ADDR_LSB) & pstrb_i[3]) ) ? 1 :  0 ;

			assign add_44h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h44>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_45h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h45>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;
			assign add_46h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h46>>ADDR_LSB) & pstrb_i[2]) ) ? 1 :  0 ;
			assign add_47h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h47>>ADDR_LSB) & pstrb_i[3]) ) ? 1 :  0 ;

			assign add_48h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h48>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_49h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h49>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;
			assign add_4ah =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4a>>ADDR_LSB) & pstrb_i[2]) ) ? 1 :  0 ;
			assign add_4bh =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4b>>ADDR_LSB) & pstrb_i[3]) ) ? 1 :  0 ;
			
			assign add_4ch =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4c>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_4dh =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4d>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;
			assign add_4eh =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4e>>ADDR_LSB) & pstrb_i[2]) ) ? 1 :  0 ;
			assign add_4fh =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4f>>ADDR_LSB) & pstrb_i[3]) ) ? 1 :  0 ;

			assign add_50h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h50>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
			assign add_51h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h51>>ADDR_LSB) & pstrb_i[1]) ) ? 1 :  0 ;
			assign add_52h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h52>>ADDR_LSB) & pstrb_i[2]) ) ? 1 :  0 ;
			assign add_53h =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h53>>ADDR_LSB) & pstrb_i[3]) ) ? 1 :  0 ;

			assign add_5ch =  ((psel_i & (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h5c>>ADDR_LSB) & pstrb_i[0]) ) ? 1 :  0 ;
		
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

reg [NB_RANK-1:0][7:0] mr_addr		       ; // addr = 00h | RW
reg [NB_RANK-1:0][7:0] mr_data 		       ; // addr = 01h | RW

reg [NB_RANK-1:0] rank_mrw 		       ; // addr = 02h | SET
reg [NB_RANK-1:0] rank_mrr 		       ; //		| SET
reg [NB_RANK-1:0] rank_busy 		       ; // 		| RO
reg [NB_RANK-1:0] mrw_done_status	       ; // 		| RO
reg [NB_RANK-1:0] mrr_done_status	       ; // 		| RO
reg [NB_RANK-1:0] ppr_done_status	       ; // 		| RO

reg [2:0]	  rank_index		       ; // addr = 03h | RW
reg		  all_rank_mr		       ; // 		| RW

reg [NB_RANK-1:0] ppr_enable		       ; // addr = 04h | SET
reg [NB_RANK-1:0] ppr_status		       ; // 		| RO

reg [NB_RANK-1:0][2:0]  ppr_bank_addr	       ; // addr = 05h | RW 
reg [NB_RANK-1:0][15:0] ppr_row_addr	       ; // addr = 06h,07h | RW


// Commmon Registers
reg 		  ca_training 		       ; // addr = 10h | RW
reg 		  wr_dq_training 	       ; // 		| Rw
reg 		  wr_lvl_training 	       ; // 		| Rw
reg 		  rd_lvl_training 	       ; // 		| Rw
reg 		  rd_gate_training 	       ; // 		| Rw
reg 		  zq_training		       ; // 		| Rw
reg 		  all_training		       ; // 		| Rw

reg 		  mc_ready		       ; // addr = 14h | RO
reg 		  soft_reset		       ; // 		| R/Set
reg 		  system_traffic_enable        ; // 		| RW

reg 		  mr_rd_disable		       ; // addr = 19h | RW

reg [4:0]	  freq_index		       ; // addr = 1ch | RW
reg 		  start_freq_change	       ; // 		| SET
reg 		  pll_freq_chng_done	       ; // 		| SET

reg 		  lpddr3		       ; // addr = 20h | RW
reg 		  start_initialization	       ; //            | RW

// Timer Registers
reg [6:0] 	act2pre_timer			; // addr = 30h | RW
reg [4:0] 	rd2pre_timer			; // 		| RW
reg [5:0] 	act2rw_timer			; //		| RW
reg [5:0] 	pre_pb2any_timer		; // 		| RW
reg [5:0] 	pre_ab2any_timer		; //		| RW
reg [5:0] 	write_recovery_timer		; // addr = 34h | RW
reg [4:0] 	write2read_timer		; //		| RW
reg [3:0] 	wpre_rpst_dqsck			; //		| RW
reg [4:0] 	act2act_timer		      	; //		| RW
reg [5:0] 	mrr2any_timer			; //		| RW
reg [5:0] 	mrw2any_timer			; //		| RW
reg [9:0] 	ref_per_bank_timer		; // addr = 38h | RW
reg [10:0]	ref_all_bank_timer		; //		| RW
reg [5:0] 	min_zq_latch_timer		; // addr = 3ch | RW
reg [9:0] 	vref_chng2any_timer		; //		| RW
reg [10:0]	refresh_interval_timer		; //		| RW
reg [4:0] 	min_pd_timer			; //		| RW
reg [5 :0]	mr4rd_interval_timer		; // addr = 40h | RW
reg [11:0]	min_zqcal_timer			; //		| RW	
reg [2:0] 	derated_timer			; //		| RW
reg [7 :0]	vref_current_mode_dis		; //		| RW
reg [16:0]	min_pprdis2any			; // addr = 44h | RW
reg [5:0] 	m_in_sr_timer			; //		| RW
reg [4:0] 	ca_data_out_delay		; // addr = 48h | RW
reg [5:0] 	f_out_act_window		; //		| RW
reg [7:0] 	dfi_tphywrdata			; // addr = 4ch | RW
reg [7:0] 	dfi_tphywrlat			; //		| RW
reg [7:0] 	dfi_tphyrddataen		; //		| RW
reg [7:0] 	dfi_tphyrdlat		  	; //		| RW
reg [31:0] 	ppr_program_time		; // addr = 50h | RW
reg 		update_all_timers		; // addr = 5ch | RW

// Interrupt Registers
reg [7:0]	  rank_intr			; // addr = 60h | RO/COR

reg 		  init_resp_error		; // addr = 61h | RO/COR
reg 		  ca_resp_error			;
reg 		  read_gate_resp_error		;
reg 		  read_level_resp_error		;
reg 		  write_level_resp_error	;
reg 		  write_dq_resp_error		;
reg 		  mc_error			;

reg 		  test_mode_intr			; // addr = 62h  | RO/CPR
reg 		  freq_change_error		; //		 | RO/COR
reg 		  freq_change_done		; //		 | RO/COR
reg 		  freq_change_ready 		; //		 | RO/COR
reg 		  watch_dog_timeout		; //		 | RO/COR
reg 		  refresh_x_trm			; //		 | RO/COR	   

reg [7:0] 	  rank_intr_en			; // addr = 64h | RW

reg 		  init_resp_error_en		; // addr = 65h | RW 
reg 		  ca_resp_error_en		; //		| RW
reg 		  read_gate_resp_error_en	; //		| RW
reg 		  read_level_resp_error_en	; //		| RW
reg 		  write_level_resp_error_en	; //		| RW
reg 		  write_dq_resp_error_en	; //		| RW
reg 		  mc_error_en			; //		| RW

reg		  intr_0_en			; // addr = 66h  | RW
reg		  intr_1_en			; //		 | RW
reg		  intr_2_en			; //		 | RW
reg		  intr_3_en			; //		 | RW
reg		  intr_4_en			; //		 | RW
reg		  intr_5_en			; //		 | RW

reg [31:0] 	  mr4rd_count			; // hold count value for mr4rd_interval_timer
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
	    assign rank_mrw_o[i]    = rank_mrw[i]			; // output pin
	    assign rank_mrr_o[i]    = rank_mrr[i]			; // output pin
	    
	    assign rank_busy_c[i]   = (rank_mrw[i] | rank_mrr[i])  ? 1'b1 :
			 		     (mrr_done_status_i[i] | mrw_done_status_i[i])? 1'b0: rank_busy[i]		;
	    assign mrw_done_c[i]    = (mrw_done_status_i[i]) ? 1'b1 :
					     (add_02h & r_en & (rank_index == i))? 1'b0 : mrw_done_status[i]		;
	    assign mrr_done_c[i]    = (mrr_done_status_i[i]) ? 1'b1 :
			 		     (add_02h & r_en & (rank_index == i)) ? 1'b0 :mrr_done_status[i]		;
	    assign ppr_done_c[i]    = (ppr_done_status_i[i]) ? 1'b1 :
					     (add_02h & r_en & (rank_index == i)) ? 1'b0 :ppr_done_status[i]		; 
	    assign rank_intr_c[i]   = (mrr_done_status_i[i] | mrw_done_status_i[i] | ppr_done_status_i[i]) ? 1'b1 :
					    (add_60h & r_en) ? 1'b0 : rank_intr[i]					;  	
	    assign ppr_status_c[i]  = (ppr_status_i[i])	     ? 1'b1 :
					    (add_04h & r_en & (rank_index == i)) ? 1'b0 : ppr_status[i]			;
	    
	    assign ppr_en_o [i]	    = ppr_enable[i]			; // output pin 
	    assign ppr_row_addr_o[i] = ppr_row_addr[i]		    	;
 	    assign ppr_bank_addr_o[i]= ppr_bank_addr[i]		    	;			
	end
endgenerate 

    assign act2pre_timer_o	    	= act2pre_timer			;
    assign rd2pre_timer_o		= rd2pre_timer			;      
    assign act2rw_timer_o		= act2rw_timer			;      
    assign pre_pb2any_timer_o	    	= pre_pb2any_timer		;      
    assign pre_ab2any_timer_o	    	= pre_ab2any_timer		;       
    assign write_recovery_timer_o     	= write_recovery_timer		;
    assign write2read_timer_o	    	= write2read_timer		; 
    assign wpre_rpst_dqsck_o	    	= wpre_rpst_dqsck		;  
    assign act2act_timer_o	    	= act2act_timer		      	;
    assign mrr2any_timer_o	    	= mrr2any_timer			;
    assign mrw2any_timer_o	    	= mrw2any_timer			;
    assign ref_per_bank_timer_o	    	= ref_per_bank_timer		;    
    assign ref_all_bank_timer_o	    	= ref_all_bank_timer		;     
    assign min_zq_latch_timer_o	    	= min_zq_latch_timer		;    
    assign vref_chng2any_timer_o	= vref_chng2any_timer		;    
    assign refresh_interval_timer_o   	= refresh_interval_timer	;
    assign min_pd_timer_o		= min_pd_timer			;  
    assign mr4rd_interval_timer_o     	= mr4rd_interval_timer		;
    assign min_zqcal_timer_o	    	= min_zqcal_timer		;  
    assign derated_timer_o	    	= derated_timer			;
    assign vref_current_mode_dis_o    	= vref_current_mode_dis		;
    assign min_pprdis2any_o	    	= min_pprdis2any		;
    assign m_in_sr_timer_o	    	= m_in_sr_timer			;
    assign ca_data_out_delay_o	    	= ca_data_out_delay		;       
    assign f_out_act_window_o	    	= f_out_act_window		;       
    assign dfi_tphywrdata_o	    	= dfi_tphywrdata		;
    assign dfi_tphywrlat_o	    	= dfi_tphywrlat			;
    assign dfi_tphyrddataen_o	    	= dfi_tphyrddataen		;      
    assign dfi_tphyrdlat_o	    	= dfi_tphyrdlat		  	;
    assign ppr_program_time_o	    	= ppr_program_time		;       
    assign update_all_timers_o	    	= update_all_timers		;       
    
    assign ca_training_c	 	= (add_10h & w_en & wdata_c[0]) ? 1'b1 :			 // Software set this bit to run training 
	 				  (ca_training_done_i	)	? 1'b0 : ca_training	    ;    // training done clear bit 		
    assign wr_dq_training_c		= (add_10h & w_en & wdata_c[1]) ? 1'b1 :
					  (wr_dq_training_done_i)	? 1'b0 : wr_dq_training	    ;  
    assign wr_lvl_training_c		= (add_10h & w_en & wdata_c[2]) ? 1'b1 :
					  (wr_lvl_training_done_i)      ? 1'b0 : wr_lvl_training    ;
    assign rd_lvl_training_c	        = (add_10h & w_en & wdata_c[3]) ? 1'b1 :
					  (rd_lvl_training_done_i) 	? 1'b0 : rd_lvl_training    ;
    assign rd_gate_training_c		= (add_10h & w_en & wdata_c[4]) ? 1'b1 :
					  (rd_gate_training_done_i)	? 1'b0 : rd_gate_training   ;
    assign zq_training_c		= (add_10h & w_en & wdata_c[5]) ? 1'b1 :
					  (zq_training_done_i	)	? 1'b0 : zq_training	    ;
    assign all_training_c		= (add_10h & w_en & wdata_c[6]) ? 1'b1 :
					  (all_training_done_i	)	? 1'b0 : all_training	    ;
    
    
    assign start_initialization_o 	= start_initialization		;
    assign system_traffic_enable_o	= system_traffic_enable		;
    
    assign freq_index_o			= freq_index			;
    assign start_freq_change_o		= start_freq_change		;
    assign pll_freq_chng_done_o 	= pll_freq_chng_done		;
    assign mc_ready_c			= (mc_ready_i) ? 1'b1 :
					    (!mc_ready_i)? 1'b0	:
						(add_14h & r_en) ? 1'b0 : mc_ready;
    		     	 
    
    assign init_resp_error_c		= (init_resp_error_i)	    ? 1'b1 :
					  (add_61h & r_en)	    ? 1'b0 : init_resp_error	    ;
    assign ca_resp_error_c 		= (ca_resp_error_i)	    ? 1'b1 :
					  (add_61h & r_en)	    ? 1'b0 : ca_resp_error	    ;
    assign read_gate_resp_error_c	= (read_gate_resp_error_i)  ? 1'b1 :
    					  (add_61h & r_en)	    ? 1'b0 : read_gate_resp_error   ;
    assign read_level_resp_error_c 	= (read_level_resp_error_i) ? 1'b1 :
    					  (add_61h & r_en)	    ? 1'b0 : read_level_resp_error  ;
    assign write_level_resp_error_c	= (write_level_resp_error_i)? 1'b1 :
					  (add_61h & r_en)	    ? 1'b0 : write_level_resp_error ;
    assign write_dq_resp_error_c 	= (write_dq_resp_error_i)   ? 1'b1 :
    					  (add_61h & r_en)	    ? 1'b0 : write_dq_resp_error    ;
    assign mc_error_c			= (mc_error_i)		    ? 1'b1 :
    					  (add_61h & r_en)	    ? 1'b0 : mc_error		    ;
    
    assign test_mode_intr_c		= (test_mode_intr_i)	    ? 1'b1 :
    					  (add_62h & r_en)	    ? 1'b0 : test_mode_intr	    ;
    assign freq_change_error_c		= (freq_change_error_i)	    ? 1'b1 :
    					  (add_62h & r_en)	    ? 1'b0 : freq_change_error	    ;
    assign freq_change_done_c		= (freq_change_done_i)	    ? 1'b1 : 
    					  (add_62h & r_en)	    ? 1'b0 : freq_change_done	    ;
    assign freq_change_ready_c		= (freq_change_ready_i)	    ? 1'b1 :
    					  (add_62h & r_en)	    ? 1'b0 : freq_change_ready	    ;
    assign watch_dog_timeout_c		= (watch_dog_timeout_i)	    ? 1'b1:
    					  (add_62h & r_en)	    ? 1'b0 : watch_dog_timeout	    ;
    assign refresh_x_trm_c 		= (refresh_x_trm_i)	    ? 1'b1 : 
    					  (add_62h & r_en)	    ? 1'b0 : refresh_x_trm	    ; 

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//--> Interrupt FLAG Logic

wire [NB_RANK-1:0]	rank_intr_or	;
wire 			mc_err_intr_or	;
wire 			mc_intr_or	;

    assign mc_intr_o = (  rank_intr_or | mc_intr_or | mc_ready_i ) ;  // Interrupt pin logic 

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

    assign mr_rd_pulse_o = (mr4rd_count == ((mr4rd_interval_timer * PULSE_INTERVAL)/APB_PULSEWIDTH))? 1'b1 : 1'b0;  	// 	count = interval_timer*PULSE_INTERVAL 
    assign mr_rd_cnt_rst = mr_rd_pulse_o;										 	//  		 	APB_PULSEWIDTH

///////////////////////////////////////////////////////////////////////////////////////////////
//--> register reset and write logic
 
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
		// Common Registers Reset Value 	
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
    
   		// Timer Registers
   			if(lpddr3) act2pre_timer 	<='h3	; else  act2pre_timer 		<='hc	;// addr = 30h 
   			if(lpddr3) rd2pre_timer  	<='h4	; else  rd2pre_timer  		<='h8	;
   			if(lpddr3) act2rw_timer		<='h3	; else  act2rw_timer		<='h5	;
   			if(lpddr3) pre_pb2any_timer	<='h3	; else  pre_pb2any_timer	<='h5	;
   			if(lpddr3) pre_ab2any_timer	<='h3	; else  pre_ab2any_timer	<='h6	;
                                                                                                       
   			if(lpddr3) write_recovery_timer	<='h4	; else  write_recovery_timer	<='h6	;// addr = 34h
   			if(lpddr3) write2read_timer 	<='h4	; else  write2read_timer 	<='h8	;
   			if(lpddr3) wpre_rpst_dqsck	<='h2	; else  wpre_rpst_dqsck		<='h3	;
   			if(lpddr3) act2act_timer	<='h2	; else  act2act_timer		<='h4	;
   			if(lpddr3) mrr2any_timer	<='h4	; else  mrr2any_timer		<='h8	;
   			if(lpddr3) mrw2any_timer	<='ha	; else  mrw2any_timer		<='ha	;
   		                                                                                    
   			if(lpddr3) ref_per_bank_timer	<='h5	; else  ref_per_bank_timer	<='h26	;// addr = 38h
   			if(lpddr3) ref_all_bank_timer	<='hb	; else  ref_all_bank_timer	<='h4b	;
   		                                                                                    
   			if(lpddr3) min_zq_latch_timer	<='h0	; else  min_zq_latch_timer	<='h8	;// addr = 3ch
   			if(lpddr3) vref_chng2any_timer	<='h0	; else  vref_chng2any_timer	<='h43	;
   			if(lpddr3) refresh_interval_timer<='h18	; else  refresh_interval_timer	<='h82	;
   			if(lpddr3) min_pd_timer		<='h3	; else  min_pd_timer		<='h5	;
   		                                                                                    
   			if(lpddr3) mr4rd_interval_timer	<='h5	; else  mr4rd_interval_timer	<='h5	;// addr = 40h
   			if(lpddr3) min_zqcal_timer	<='h32	; else  min_zqcal_timer		<='h10b	;
   			if(lpddr3) derated_timer	<='h1	; else  derated_timer		<='h1	;
   			if(lpddr3) vref_current_mode_dis <='h0	; else 	vref_current_mode_dis	<='h1c	;
   		                                                                                   
   			if(lpddr3) min_pprdis2any	<='h0	; else  min_pprdis2any		<='h3416;// addr = 44h
   			if(lpddr3) m_in_sr_timer	<='h3	; else  m_in_sr_timer		<='h4	;
   		                                                                                    
   			if(lpddr3) ca_data_out_delay	<='h1	; else  ca_data_out_delay	<='h0	;// addr = 48h
   			if(lpddr3) f_out_act_window	<='h8	; else  f_out_act_window	<='h0	;
   		                                                                                   
   			if(lpddr3) dfi_tphywrdata	<='h4	; else  dfi_tphywrdata		<='h2	;// addr = 4ch
   			if(lpddr3) dfi_tphywrlat	<='h2	; else  dfi_tphywrlat		<='h2	;
   			if(lpddr3) dfi_tphyrddataen	<='h4	; else  dfi_tphyrddataen	<='h4	;
   			if(lpddr3) dfi_tphyrdlat	<='h8	; else  dfi_tphyrdlat		<='h2	;
   		                                                                                    
   			ppr_program_time	<='hfe502ab ; // addr = 50h                                                                             
   			update_all_timers	<='h0	; // addr = 5ch
   
   		// Interrupt Registers Reset Value 	 
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
   
   			//
   			if(add_30h & w_en) {rd2pre_timer[0], act2pre_timer[6:0]} 			<= wdata_c[7:0]			;
   			if(add_31h & w_en) {act2rw_timer[3:0], rd2pre_timer[4:1]} 			<= wdata_c[15:8]		;
   			if(add_32h & w_en) {pre_pb2any_timer[5:0], act2rw_timer[5:4]} 			<= wdata_c[23:16]		;
   			if(add_33h & w_en) {pre_ab2any_timer [5:0]} 					<= wdata_c[29:24]		;
   
   			if(add_34h & w_en) {write2read_timer[1:0],write_recovery_timer[5:0]}   			<= wdata_c[7:0]		;
   			if(add_35h & w_en) {act2act_timer[0],wpre_rpst_dqsck[3:0], write2read_timer[4:2]}	<= wdata_c[15:8]	;
   			if(add_36h & w_en) {mrr2any_timer[3:0],act2act_timer[4:1]} 				<= wdata_c[23:16]	;
   			if(add_37h & w_en) {mrw2any_timer[5:0],mrr2any_timer[5:4]} 				<= wdata_c[31:24]	;
   
   			if(add_38h & w_en) {ref_per_bank_timer[7:0]} 					<= wdata_c[7:0]			;
   			if(add_39h & w_en) {ref_all_bank_timer[5:0], ref_per_bank_timer[9:8] } 		<= wdata_c[15:0]		;
   			if(add_3ah & w_en) {ref_all_bank_timer[10:6]}					<= wdata_c[20:16]		;
   			// add_3bh & w_en reserved !
   
   			if(add_3ch & w_en) {vref_chng2any_timer[1:0],min_zq_latch_timer[5:0]} 		<= wdata_c[7:0]			;		
   			if(add_3dh & w_en) {vref_chng2any_timer[9:2]} 					<= wdata_c[15:8]		;
   			if(add_3eh & w_en) {refresh_interval_timer[7:0]} 				<= wdata_c[23:16]		;
   			if(add_3fh & w_en) {min_pd_timer[4:0],refresh_interval_timer[10:8]} 		<= wdata_c[31:24]		;
   	
   			if(add_40h & w_en) {mr4rd_interval_timer[5:0]} 					<= wdata_c[5:0]			;
   			if(add_41h & w_en) {min_zqcal_timer[7:0]} 					<= wdata_c[15:8]		;
   			if(add_42h & w_en) {derated_timer[2:0], min_zqcal_timer[11:8]} 			<= wdata_c[22:16]		;		
   			if(add_43h & w_en) {vref_current_mode_dis[7:0]} 				<= wdata_c[31:24]		;
   	
   			if(add_44h & w_en) {min_pprdis2any[7:0]}  					<= wdata_c[7:0]			;
   			if(add_45h & w_en) {min_pprdis2any[15:0]} 					<= wdata_c[15:8]		;
   			if(add_46h & w_en) {m_in_sr_timer[5:0],min_pprdis2any[16]} 			<= wdata_c[22:16]		;
   			// add_47h & w_en RSVD !
   			
   			if(add_48h & w_en) {f_out_act_window[2:0],ca_data_out_delay[4:0]}  		<= wdata_c[7:0]			;
   			if(add_49h & w_en) {f_out_act_window[5:3]} 					<= wdata_c[10:8]		;
   			// add_4ah & w_en RSVD !
   			// add_4bh & w_en RSVD !
   			
   			if(add_4ch & w_en) {dfi_tphywrdata[7:0]} 					<= wdata_c[7:0]			;
   			if(add_4dh & w_en) {dfi_tphywrlat[7:0]}  					<= wdata_c[15:7]		;
   			if(add_4eh & w_en) {dfi_tphyrddataen[7:0]}					<= wdata_c[23:16]		;
   			if(add_4fh & w_en) {dfi_tphyrdlat[7:0]} 					<= wdata_c[31:24]		;
   
   			if(add_50h & w_en) {ppr_program_time[7:0]} 					<= wdata_c[7:0]			;
   			if(add_51h & w_en) {ppr_program_time[15:8]} 					<= wdata_c[15:8]		;
   			if(add_52h & w_en) {ppr_program_time[23:16]}					<= wdata_c[23:16]		;
   			if(add_53h & w_en) {ppr_program_time[31:24]}					<= wdata_c[31:24]		;
   
   			if(add_5ch & w_en) {update_all_timers} 						<= wdata_c[0]			;
   
   		//Interrupt Registers 
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
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// -->  reading register logic 

assign reg_data[7 : 0] =(add_00h ) ? mr_addr[rank_index] 					:
			(add_04h ) ? {6'b0,ppr_status[rank_index],1'b0}				:
			(add_10h ) ? {1'b0 , all_training, zq_training, rd_gate_training,rd_lvl_training, wr_lvl_training, wr_dq_training, ca_training} :
			(add_14h ) ? {system_traffic_enable , 2'b0, soft_reset, 3'b0, mc_ready} : 				
			(add_1ch ) ? {3'b0, freq_index} 					:
			(add_20h ) ? {start_initialization, 6'b0 , lpddr3} 			:
			(add_30h ) ? {rd2pre_timer[0], act2pre_timer[6:0]} 			:
			(add_34h ) ? {write2read_timer[1:0],write_recovery_timer[5:0]}		:
			(add_38h ) ? {ref_per_bank_timer[7:0]} 					:
			(add_3ch ) ? {vref_chng2any_timer[1:0],min_zq_latch_timer[5:0]}		:
			(add_40h ) ? {2'b0, mr4rd_interval_timer[5:0]}				:
			(add_44h ) ? {min_pprdis2any[7:0]}					:
			(add_48h ) ? {f_out_act_window[2:0],ca_data_out_delay[4:0]}		:
			(add_4ch ) ? {dfi_tphywrdata[7:0]}					:
			(add_50h ) ? {ppr_program_time[7:0]}					:
			(add_5ch ) ? {7'b0,update_all_timers}					:				
			(add_60h ) ? {rank_intr}						:
			(add_64h ) ? {rank_intr_en} : 8'b0;


assign reg_data[15: 8] =(add_01h ) ? mr_data[rank_index] 						:
			(add_05h ) ? {5'b0, ppr_bank_addr[rank_index]} 					:
			(add_19h ) ? {4'b0, mr_rd_disable, 3'b0} 					:
			(add_31h ) ? {act2rw_timer[3:0], rd2pre_timer[4:1]} 				:
			(add_35h ) ? {act2act_timer[0],wpre_rpst_dqsck[3:0], write2read_timer[4:2]}	:
			(add_39h ) ? {ref_all_bank_timer[5:0], ref_per_bank_timer[9:8] }		:
			(add_3dh ) ? {vref_chng2any_timer[9:2]}						:	
			(add_41h ) ? {min_zqcal_timer[7:0]}						:
			(add_45h ) ? {min_pprdis2any[15:0]}						:
			(add_49h ) ? {f_out_act_window[5:3]} 						:
			(add_4dh ) ? {dfi_tphywrlat[7:0]} 						:
			(add_51h ) ? {ppr_program_time[15:8]}						:
			(add_61h ) ? {1'b0, mc_error, write_dq_resp_error, write_level_resp_error, read_level_resp_error, read_gate_resp_error, ca_resp_error, init_resp_error} 			:
			(add_65h ) ? {1'b0, mc_error_en,write_dq_resp_error_en,  write_level_resp_error_en, read_gate_resp_error_en, read_level_resp_error_en, ca_resp_error_en,init_resp_error_en} 	: 8'b0;

assign reg_data[23:16] =(add_02h ) ? {ppr_done_status[rank_index], mrr_done_status[rank_index], mrw_done_status[rank_index], 1'b0, 1'b0 , rank_busy_c[rank_index], 2'b0} :
			(add_06h ) ? {ppr_row_addr[7:0]}														 :
			(add_32h ) ? {pre_pb2any_timer[5:0], act2rw_timer[5:4]}												 :
			(add_36h ) ? {mrr2any_timer[3:0],act2act_timer[4:1]}												 :
			(add_3ah ) ? {3'b0,ref_all_bank_timer[10:6]}													 :
			(add_3eh ) ? {refresh_interval_timer[7:0]}													 :
			(add_42h ) ? {1'b0,derated_timer[2:0], min_zqcal_timer[11:8]} 											 :
			(add_46h ) ? {1'b0,m_in_sr_timer[5:0],min_pprdis2any[16]} 											 :
			(add_4eh ) ? {dfi_tphyrddataen[7:0]}														 :
			(add_52h ) ? {ppr_program_time[23:16]}														 :			
			(add_62h ) ? {2'b0,refresh_x_trm, watch_dog_timeout, freq_change_ready, freq_change_done, freq_change_error, test_mode_intr} 			 :
			(add_66h ) ? {2'b0, intr_5_en , intr_4_en, intr_3_en, intr_2_en, intr_1_en, intr_0_en} 								 : 8'b0;

assign reg_data[31:24] =(add_03h ) ? {all_rank_mr, 4'b0, rank_index} 			:
			(add_07h ) ? {ppr_row_addr[15:8]}	    			:
			(add_33h ) ? {2'b0,pre_ab2any_timer [5:0]}			:
			(add_37h ) ? {mrw2any_timer[5:0],mrr2any_timer[5:4]}		:
			(add_3fh ) ? {min_pd_timer[4:0],refresh_interval_timer[10:8]}	:
			(add_43h ) ? {vref_current_mode_dis[7:0]} 			:
			(add_4fh ) ? {dfi_tphyrdlat[7:0]}				:
			(add_53h ) ? {ppr_program_time[31:24]}				:	8'b0;

	always@(posedge pclk_i or negedge prst_ni)
	begin
		if(!prst_ni | soft_reset)
			prdata_o <= 0;
		else  
			prdata_o <= prdata_c;
	end		
	

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// --> mr4rd_pulse generator logic

    always@(posedge pclk_i or negedge prst_ni)  // mr_count upto required time and than 
    begin					// ig got reset by mr_rd_cnt_rst flag
     if(!prst_ni | mr_rd_disable)  
            mr4rd_count <=0;
     else if(mr_rd_cnt_rst & !mr_rd_disable)
    	mr4rd_count <=1;
     else if(!mr_rd_disable) 
           mr4rd_count <= mr4rd_count +1;
    end
 

endmodule
