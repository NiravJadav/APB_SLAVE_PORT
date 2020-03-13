module apb_slave_port_test_top();

parameter A_WIDTH 	= 16	;
parameter D_WIDTH 	= 8  	;
parameter N_RANK 	= 8 	;
parameter PULSE_INT	= 6 	;	// UNIT PULSE INTERVAL  in micro-sec
parameter CLK_PULSE  	= 3	;	// CLK PULSE WIDTH 	in micro-sec
//APB BUS INTERCONNECTS
wire pclk,preset,pselect,penable,pready,pslverr,pwrite;
wire [D_WIDTH-1:0] pwdata,prdata;
wire [A_WIDTH-1:0] paddr;
wire [3:0]     pstrobe;

wire [7 :0] wdata;

//APB MASTER BACKEND SIGNAL
reg t , rd_wr, mclk,mrst;
reg [3:0] strb =0;
reg [D_WIDTH-1:0] mwdata;
reg [A_WIDTH-1:0] maddr ;
wire [D_WIDTH-1:0] mrdata;
wire mrvalid;


//APB SALVE BACKEND SIGNAL
wire 				mc_intr_t		;
wire [N_RANK-1:0][7:0]		mr_addr_t		;
wire [N_RANK-1:0][7:0]		mr_data_t		;	   	
wire [N_RANK-1:0] 		rank_mrw_t		;	   	
wire [N_RANK-1:0] 		rank_mrr_t		;	   	
reg  [N_RANK-1:0]		mrw_done_status_t =0  	;	   	
reg  [N_RANK-1:0]    		mrr_done_status_t =0	;	   	
reg  [N_RANK-1:0]		ppr_status_t	  =0  	;
wire [N_RANK-1:0] 		ppr_en_t		;   	
reg  [N_RANK-1:0]		ppr_done_status_t =0	;   	
wire [N_RANK-1:0][2:0]		ppr_bank_addr_t	   	;
wire [N_RANK-1:0][15:0] 	ppr_row_addr_t	   	;
wire [6:0]  	act2pre_timer_t	   	 ;
wire [4:0]  	rd2pre_timer_t	   	 ;
wire [5:0]  	act2rw_timer_t	   	 ;
wire [5:0]  	pre_pb2any_timer_t	 ;  	
wire [5:0]  	pre_ab2any_timer_t	 ;   	
wire [5:0]  	write_recovery_timer_t   ;	
wire [4:0]  	write2read_timer_t	 ;   	
wire [3:0]  	wpre_rpst_dqsck_t	 ;  	
wire [4:0]  	act2act_timer_t		 ;   	
wire [5:0]  	mrr2any_timer_t		 ;  	
wire [5:0]  	mrw2any_timer_t		 ; 	
wire [9:0]  	ref_per_bank_timer_t	 ;
wire [10:0] 	ref_all_bank_timer_t	 ;
wire [5:0] 	 min_zq_latch_timer_t	 ;
wire [9:0] 	 vref_chng2any_timer_t	 ;
wire [10:0]	 refresh_interval_timer_t; 	
wire [4:0]  	min_pd_timer_t	   	 ;
wire [5 :0] 	mr4rd_interval_timer_t  ; 	
wire [11:0] 	min_zqcal_timer_t	 ; 	
wire [2:0]  	derated_timer_t	 ;	
wire [7 :0] 	vref_current_mode_dis_t ;	
wire [16:0] 	min_pprdis2any_t	 ;	
wire [5:0]  	m_in_sr_timer_t	 ;	
wire [4:0]  	ca_data_out_delay_t	 ;
wire [5:0]  	f_out_act_window_t	 ;  	
wire [7:0]  	dfi_tphywrdata_t	 ;	
wire [7:0]  	dfi_tphywrlat_t	 ;	
wire [7:0] 	 dfi_tphyrddataen_t	 ;	
wire [7:0]  	dfi_tphyrdlat_t	 ;	
wire [31:0] 	ppr_program_time_t	 ;	
wire 	 	update_all_timers_t	 ;
wire 	 	ca_training_start_t	 ;
wire 	 	wr_dq_training_start_t  ; 	
wire 	 	wr_lvl_training_start_t ;	
wire 	 	rd_lvl_training_start_t ;	
wire 	 	rd_gate_training_start_t;	
wire 	 	zq_training_start_t	 ;
wire 	 	all_training_start_t	 ;
reg 		ca_training_done_t	 =0	;  	
reg 		wr_dq_training_done_t	 =0	;
reg 		wr_lvl_training_done_t   =0	;	
reg 		rd_lvl_training_done_t   =0	;	
reg 		rd_gate_training_done_t  =0	;	
reg 		zq_training_done_t	 =0	; 	
reg 		all_training_done_t	 =0	;
reg 		mc_ready_t		 =0	;  	
wire 		system_traffic_enable_t  ;	
wire 		start_initialization_t   ;	
wire [4:0]	freq_index_t		 ;
wire 		start_freq_change_t	 ;
wire 		pll_freq_chng_done_t	 ;
reg 		init_resp_error_t 	 =0	;  	
reg 		ca_resp_error_t	   	 =0	;
reg 		read_gate_resp_error_t   =0	;	
reg 		read_level_resp_error_t  =0	;	
reg 		write_level_resp_error_t =0	;	
reg 		write_dq_resp_error_t    =0	;	
reg 		mc_error_t		 =0	; 	
reg 		test_mode_intr_t	 =0	;	
reg 		freq_change_error_t   	 =0	;
reg 		freq_change_done_t	 =0	;  	
reg 		freq_change_ready_t   	 =0	;
reg 		watch_dog_timeout_t   	 =0	;
reg 		refresh_x_trm_t	   	 =0	;
wire 		mr_rd_pulse_t	   		;

//APB SLAVE INTRUPPT OUTPUT 


// APB PULSE
wire mr_pulse;

apb_master_port #(.APB_ADDRWIDTH(A_WIDTH), .APB_DATAWIDTH(D_WIDTH)) apb_master
									(.pready_i	(pready)	,
									.prdata_i	(prdata)	,
									.pslverr_i	(pslverr)	,
									.pclk_o		(pclk)		,
									.prst_no	(preset)	,
									.psel_o		(pselect)	,
									.penable_o	(penable)	,
									.pwrite_o	(pwrite)	,
									.pwdata_o	(pwdata)	,
									.paddr_o	(paddr)		,
									.pstrb_o	(pstrobe)	,
									
									.t		(t)		,
									.rd_wr		(rd_wr)		,
									.mclk_i		(mclk)		,
									.mrst_ni	(mrst)		,
									.strb_i		(strb)		,
									.m_rdata_o	(mrdata)	,
									.m_rvalid_o	(mrvalid)	,
									.m_wdata_i	(mwdata)	,
									.m_addr_i	(maddr)		,
									.m_intr_i	(intr)		);
									






apb_slave_port #(.APB_ADDRWIDTH(A_WIDTH),
		 .APB_DATAWIDTH(D_WIDTH),
		 .NB_RANK(N_RANK)	,
		 .APB_PULSEWIDTH(CLK_PULSE),
		 .PULSE_INTERVAL(PULSE_INT)) apb_slave		(	 .pclk_i		    (pclk		   	),  // apb_signals
									 .prst_ni		    (preset		   	),
									 .paddr_i		    (paddr		   	),
									 .psel_i		    (pselect		   	),
									 .penable_i		    (penable		   	),
									 .pwrite_i		    (pwrite		   	),
									 .pwdata_i		    (pwdata		   	),
									 .pstrb_i		    (pstrobe		   	),
									 .pready_o		    (pready		   	),
									 .prdata_o		    (prdata		  	),
									 .pslverr_o     	    (pslverr     	   	), 
									 .mc_intr_o		    (mc_intr_t		   	),  // mc_intr_out_pin
									 .mr_addr_o		    (mr_addr_t			), // slave backend interface
									 .mr_data_o		    (mr_data_t			),
									 .rank_mrw_o		    (rank_mrw_t		   	), 
									 .rank_mrr_o		    (rank_mrr_t		   	),
									 .mrw_done_status_i	    (mrw_done_status_t	   	),
									 .mrr_done_status_i	    (mrr_done_status_t	   	),
									 .ppr_status_i		    (ppr_status_t	   	),
									 .ppr_en_o		    (ppr_en_t		   	),
									 .ppr_done_status_i	    (ppr_done_status_t	   	),				
									 .ppr_bank_addr_o	    (ppr_bank_addr_t	   	),
									 .ppr_row_addr_o	    (ppr_row_addr_t	   	),
									 .act2pre_timer_o	    (act2pre_timer_t	   	),       
									 .rd2pre_timer_o	    (rd2pre_timer_t	   	),
									 .act2rw_timer_o	    (act2rw_timer_t	   	),
									 .pre_pb2any_timer_o	    (pre_pb2any_timer_t	   	),
									 .pre_ab2any_timer_o	    (pre_ab2any_timer_t	   	),     	 		                         
									 .write_recovery_timer_o    (write_recovery_timer_t   	),       
									 .write2read_timer_o	    (write2read_timer_t	   	),
									 .wpre_rpst_dqsck_o	    (wpre_rpst_dqsck_t	   	),       
									 .act2act_timer_o	    (act2act_timer_t	   	),       
									 .mrr2any_timer_o	    (mrr2any_timer_t	   	),       
									 .mrw2any_timer_o	    (mrw2any_timer_t	   	),           	 		                         
									 .ref_per_bank_timer_o	    (ref_per_bank_timer_t	),
									 .ref_all_bank_timer_o	    (ref_all_bank_timer_t	),     	 		                         
									 .min_zq_latch_timer_o	    (min_zq_latch_timer_t	),
									 .vref_chng2any_timer_o	    (vref_chng2any_timer_t	),
									 .refresh_interval_timer_o  (refresh_interval_timer_t 	),	
									 .min_pd_timer_o	    (min_pd_timer_t	   	),     	 		                         
									 .mr4rd_interval_timer_o    (mr4rd_interval_timer_t   	),       
									 .min_zqcal_timer_o	    (min_zqcal_timer_t	   	),       
									 .derated_timer_o	    (derated_timer_t	   	),       
									 .vref_current_mode_dis_o   (vref_current_mode_dis_t  	),	     	 		                         
									 .min_pprdis2any_o	    (min_pprdis2any_t	   	),       
									 .m_in_sr_timer_o	    (m_in_sr_timer_t	   	),             	 		                         
									 .ca_data_out_delay_o	    (ca_data_out_delay_t	),
									 .f_out_act_window_o	    (f_out_act_window_t	   	),     	 		                         
									 .dfi_tphywrdata_o	    (dfi_tphywrdata_t	  	),       
									 .dfi_tphywrlat_o	    (dfi_tphywrlat_t	   	),       
									 .dfi_tphyrddataen_o	    (dfi_tphyrddataen_t	   	),
									 .dfi_tphyrdlat_o	    (dfi_tphyrdlat_t	   	),       
									 .ppr_program_time_o	    (ppr_program_time_t	   	),            			                         
									 .update_all_timers_o	    (update_all_timers_t	),
									 .ca_training_start_o	    (ca_training_start_t	),
									 .wr_dq_training_start_o    (wr_dq_training_start_t   	),
									 .wr_lvl_training_start_o   (wr_lvl_training_start_t  	),
									 .rd_lvl_training_start_o   (rd_lvl_training_start_t  	),
									 .rd_gate_training_start_o  (rd_gate_training_start_t 	),
									 .zq_training_start_o	    (zq_training_start_t	),
									 .all_training_start_o	    (all_training_start_t	),  
									 .ca_training_done_i	    (ca_training_done_t	   	),
									 .wr_dq_training_done_i	    (wr_dq_training_done_t	),
									 .wr_lvl_training_done_i    (wr_lvl_training_done_t   	),
									 .rd_lvl_training_done_i    (rd_lvl_training_done_t   	),
									 .rd_gate_training_done_i   (rd_gate_training_done_t  	),      
									 .zq_training_done_i	    (zq_training_done_t	   	),
									 .all_training_done_i	    (all_training_done_t	),      	
									 .mc_ready_i		    (mc_ready_t		   	),
									 .system_traffic_enable_o   (system_traffic_enable_t  	),  
									 .start_initialization_o    (start_initialization_t   	),	   
									 .freq_index_o		    (freq_index_t		),
									 .start_freq_change_o	    (start_freq_change_t	),
									 .pll_freq_chng_done_o	    (pll_freq_chng_done_t	), 
									 .init_resp_error_i 	    (init_resp_error_t 	   	),  
									 .ca_resp_error_i	    (ca_resp_error_t	   	),
									 .read_gate_resp_error_i    (read_gate_resp_error_t   	),
									 .read_level_resp_error_i   (read_level_resp_error_t  	),
									 .write_level_resp_error_i  (write_level_resp_error_t 	),
									 .write_dq_resp_error_i     (write_dq_resp_error_t    	),
									 .mc_error_i		    (mc_error_t		   	),
									 .test_mode_intr_i	    (test_mode_intr_t	   	),  
									 .freq_change_error_i	    (freq_change_error_t   	),
									 .freq_change_done_i	    (freq_change_done_t	   	),
									 .freq_change_ready_i	    (freq_change_ready_t   	),
									 .watch_dog_timeout_i	    (watch_dog_timeout_t   	),
									 .refresh_x_trm_i	    (refresh_x_trm_t	   	),    
									 .mr_rd_pulse_o	            (mr_rd_pulse_t	   	)	
								);


initial 
begin
     mclk =1;
     forever #5 mclk = !mclk;
end

///////////////////////////////////////////////////////////////////////////////////////////////////////
// --> MRW/MRR TEST
/*
initial 
begin
mrst = 0; strb =0;  mrw_done_status_t =0; mrr_done_status_t  =0;
#5 mrst = 1;

// RANK MRW / MRR TEST WITH INTERRUPT
t =1 ;
rd_wr = 1; 	maddr = 3;	mwdata = 7;	#20	// rank_index <-- 0
rd_wr = 1; 	maddr = 0;	mwdata = 10;	#20	// mraddr[0]  <-- 10
rd_wr = 1; 	maddr = 1;	mwdata = 20;	#20	// mrdata[0]  <-- 20
rd_wr = 1;	maddr = 2;	mwdata = 2;	#20 	// rank_mrw[0] request asseted 
t= 0;
// rank_mrw req done ! 
//now some random transaction 
end


always@(posedge mc_intr_t) // ISR of intr pin
begin
t=1;
rd_wr = 0;	maddr = 'h60;			#20 $display("time-->%t", $time); #10

	if(prdata[0]) begin mwdata = 0; $display("matched i --> %d",0); end
	if(prdata[1]) begin mwdata = 1; $display("matched i --> %d",1); end
	if(prdata[2]) begin mwdata = 2; $display("matched i --> %d",2); end
	if(prdata[3]) begin mwdata = 3; $display("matched i --> %d",3); end
	if(prdata[4]) begin mwdata = 4; $display("matched i --> %d",4); end
	if(prdata[5]) begin mwdata = 5; $display("matched i --> %d",5); end
	if(prdata[6]) begin mwdata = 6; $display("matched i --> %d",6); end
	if(prdata[7]) begin mwdata = 7; $display("matched i --> %d",7); end

rd_wr = 1;	maddr = 3;			#20
rd_wr = 0;	maddr = 2;			#30
			
$finish;    
end


always@(rank_mrw_t)
begin
if(rank_mrw_t[0]) begin #30 mrw_done_status_t[0] ='b1; #10 mrw_done_status_t[0] = 'b0; end
if(rank_mrw_t[1]) begin #30 mrw_done_status_t[1] ='b1; #10 mrw_done_status_t[1] = 'b0; end
if(rank_mrw_t[2]) begin #30 mrw_done_status_t[2] ='b1; #10 mrw_done_status_t[2] = 'b0; end
if(rank_mrw_t[3]) begin #30 mrw_done_status_t[3] ='b1; #10 mrw_done_status_t[3] = 'b0; end
if(rank_mrw_t[4]) begin #30 mrw_done_status_t[4] ='b1; #10 mrw_done_status_t[4] = 'b0; end
if(rank_mrw_t[5]) begin #30 mrw_done_status_t[5] ='b1; #10 mrw_done_status_t[5] = 'b0; end
if(rank_mrw_t[6]) begin #30 mrw_done_status_t[6] ='b1; #10 mrw_done_status_t[6] = 'b0; end
if(rank_mrw_t[7]) begin #30 mrw_done_status_t[7] ='b1; #10 mrw_done_status_t[7] = 'b0; end
end


always@(rank_mrr_t)
begin
if(rank_mrr_t[0]) begin #30 mrr_done_status_t[0] =1'b1; #10 mrr_done_status_t[0] = 1'b0; end
if(rank_mrr_t[1]) begin #30 mrr_done_status_t[1] =1'b1; #10 mrr_done_status_t[1] = 1'b0; end
if(rank_mrr_t[2]) begin #30 mrr_done_status_t[2] =1'b1; #10 mrr_done_status_t[2] = 1'b0; end
if(rank_mrr_t[3]) begin #30 mrr_done_status_t[3] =1'b1; #10 mrr_done_status_t[3] = 1'b0; end
if(rank_mrr_t[4]) begin #30 mrr_done_status_t[4] =1'b1; #10 mrr_done_status_t[4] = 1'b0; end
if(rank_mrr_t[5]) begin #30 mrr_done_status_t[5] =1'b1; #10 mrr_done_status_t[5] = 1'b0; end
if(rank_mrr_t[6]) begin #30 mrr_done_status_t[6] =1'b1; #10 mrr_done_status_t[6] = 1'b0; end
if(rank_mrr_t[7]) begin #30 mrr_done_status_t[7] =1'b1; #10 mrr_done_status_t[7] = 1'b0; end
end
*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// --> PPR TEST
/*
initial 
begin 
mrst = 0; 
#05 mrst = 1;
t =1 ;
//rd_wr = 1; 	maddr = 'h64;	mwdata = 'hfe;	#20	// rank_index_0 <-- disable interrupt
rd_wr = 1; 	maddr = 3;	mwdata = 1;	#20	// rank_index <-- 0
rd_wr = 1; 	maddr = 5;	mwdata = 3;	#20	// ppr_bank_address <-- 3
rd_wr = 1; 	maddr = 6;	mwdata = 20;	#20	// ppr_bank_address lower byte write
rd_wr = 1; 	maddr = 7;	mwdata = 50;	#20	// ppr_bank_address lower byte writeppr_bank_address upper byte write 
rd_wr = 1;	maddr = 4;	mwdata = 1;	#20 	// ppr_enable <-- 1
t =0;
end

always@(posedge mc_intr_t) // ISR of intr pin
begin
t=1;
rd_wr = 0;	maddr = 'h60; #20 $display("time-->%t, prdata--> %b", $time, prdata);#10
if(prdata[0]) begin mwdata = 0; $display("matched i --> %d",0); end
	if(prdata[1]) begin mwdata = 1; $display("matched i --> %d",1); end
	if(prdata[2]) begin mwdata = 2; $display("matched i --> %d",2); end
	if(prdata[3]) begin mwdata = 3; $display("matched i --> %d",3); end
	if(prdata[4]) begin mwdata = 4; $display("matched i --> %d",4); end
	if(prdata[5]) begin mwdata = 5; $display("matched i --> %d",5); end
	if(prdata[6]) begin mwdata = 6; $display("matched i --> %d",6); end
	if(prdata[7]) begin mwdata = 7; $display("matched i --> %d",7); end
	
rd_wr = 1;	maddr = 3; 			#20 // writed matched rank address for which interrupt generated !
rd_wr = 0;	maddr = 2;			#20
rd_wr = 0; 	maddr = 4;			#50
			
$finish;    
end

always@(ppr_en_t)
begin
if(ppr_en_t[0]) begin #30 ppr_done_status_t[0] =1'b1; ppr_status_t[0] = 1'b1; #10 ppr_done_status_t[0] = 1'b0; ppr_status_t[0] = 1'b0;end
if(ppr_en_t[1]) begin #30 ppr_done_status_t[1] =1'b1; ppr_status_t[1] = 1'b1; #10 ppr_done_status_t[1] = 1'b0; ppr_status_t[1] = 1'b0;end
if(ppr_en_t[2]) begin #30 ppr_done_status_t[2] =1'b1; ppr_status_t[2] = 1'b1; #10 ppr_done_status_t[2] = 1'b0; ppr_status_t[2] = 1'b0;end
if(ppr_en_t[3]) begin #30 ppr_done_status_t[3] =1'b1; ppr_status_t[3] = 1'b1; #10 ppr_done_status_t[3] = 1'b0; ppr_status_t[3] = 1'b0;end
if(ppr_en_t[4]) begin #30 ppr_done_status_t[4] =1'b1; ppr_status_t[4] = 1'b1; #10 ppr_done_status_t[4] = 1'b0; ppr_status_t[4] = 1'b0;end
if(ppr_en_t[5]) begin #30 ppr_done_status_t[5] =1'b1; ppr_status_t[5] = 1'b1; #10 ppr_done_status_t[5] = 1'b0; ppr_status_t[5] = 1'b0;end
if(ppr_en_t[6]) begin #30 ppr_done_status_t[6] =1'b1; ppr_status_t[6] = 1'b1; #10 ppr_done_status_t[6] = 1'b0; ppr_status_t[6] = 1'b0;end
if(ppr_en_t[7]) begin #30 ppr_done_status_t[7] =1'b1; ppr_status_t[7] = 1'b1; #10 ppr_done_status_t[7] = 1'b0; ppr_status_t[7] = 1'b0;end
end
*/

///////////////////////////////////////////////////////////////////////////////////////////////
//--> soft reset test
/*
initial 
begin
mrst = 0; strb = 0; 
#5 mrst = 1 ;

t =1;
// one write transation 
rd_wr = 1; 	maddr = 0; 	mwdata = 'h80; 	#20
// one read transation 
rd_wr = 0;	maddr = 0;			#20

// now soft-reset asserted ! 
rd_wr = 1 ; 	maddr = 'h14;	mwdata = (1<<4);#20
rd_wr = 1 ; 	maddr = 0;			#20 t =0;
#30
$finish;
end
*/

//////////////////////////////////////////////////////////////////////////////////////////////
//--> frequency change test
/*
initial 
begin
mrst = 0; strb = 0; 
#5 mrst = 1 ;

t =1; rd_wr = 1; maddr = 'h19; mwdata = 1<<3;		#20 // --> disabled mrr_read 
t =1; rd_wr = 1; maddr = 'h1c; mwdata = 5 | (1<< 5);	#20 // --> write freq_index | start_freq_change
t=0; // wait for interrupt	
end

always@(posedge mc_intr_t)
begin
$display("start prdata --> %b , time --> %t", prdata, $time);
t = 1; rd_wr = 0; maddr = 'h62;				#30 // --> mc interrupt status register read 
$display("after readprdata --> %b , time --> %t", prdata, $time);
if(prdata[3]) begin t = 1; rd_wr = 1; maddr = 'h1c; mwdata = 1<<6;  end // --> pll
t=0;
end

always@(posedge start_freq_change_t )
begin
 #30 freq_change_ready_t = 1; #5  freq_change_ready_t =0; // frequency change ready intrepput
end

always@( posedge pll_freq_chng_done_t)
begin
#40 freq_change_done_t  = 1; #5 freq_change_done_t =0; // frequency change done interrupt
end 
*/
/////////////////////////////////////////////////////////////////////////////////////////////////////
//--> mr4rd_pulse test
/*
initial 
begin
mrst = 0; strb = 0; 
#5 mrst = 1 ;

t=1; 	rd_wr=1; 	maddr= 'h19; 	mwdata=1<<3;	#20 // timer disabled 
t =1; 	rd_wr=1; 	maddr='h40; 	mwdata=1;	#20 // interval*1
#40
t=1; 	rd_wr=1; 	maddr= 'h19; 	mwdata=0<<3;	#20 // timer enabled !
t=0;
end
*/
////////////////////////////////////////////////////////////////////////////////////////////////////
// --> all datawidth all strobe 
initial
begin
  mrst = 0; #5 mrst = 1;
t=1 ; rd_wr = 1; maddr = 0; strb = 1; 	#20 
t=1 ; rd_wr = 1; maddr = 1; strb = 3; 	#20 
t=1 ; rd_wr = 1; maddr = 2; strb = 3; 	#20 
t=1 ; rd_wr = 1; maddr = 3; strb = 1; 	#20 
t=0;
#10
$finish;
end 
endmodule
