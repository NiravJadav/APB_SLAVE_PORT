module apb_slave_port_test();

parameter A_WIDTH = 16;
parameter D_WIDTH = 8 ;
parameter NB_RANK = 2 ;
//APB BUS INTERCONNECTS
wire pclk,preset,pselect,penable,pready,pslverr,pwrite;
wire [D_WIDTH-1:0] pwdata,prdata;
wire [A_WIDTH-1:0] paddr;
wire [3:0]     pstrobe;

wire [7 :0] wdata;

//APB MASTER BACKEND SIGNAL
reg t , rd_wr, mclk,mrst;
reg [3:0] strb;
reg [D_WIDTH-1:0] mwdata;
reg [A_WIDTH-1:0] maddr ;
wire [D_WIDTH-1:0] mrdata;
wire mrvalid;

//APB SLAVE BACKEND 
reg [NB_RANK-1:0] mrw_i = 0;
reg [NB_RANK-1:0] mrr_i = 0;
reg [NB_RANK-1:0] ppr_done = 0;
reg [NB_RANK-1:0] ppr_status=0;
wire[NB_RANK-1:0] r_mrr,r_mrw;
wire[NB_RANK-1:0] ppr_en;

reg  test_int=0;
reg  f_done  =0;
reg  f_ready =0;
reg  f_error =0;
reg  wd_tout =0;
reg  ref_xtrm=0;

wire sta_fre_chng;
wire pll_fre_chng_done;
//APB SLAVE INTRUPPT OUTPUT 
wire intr;

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
									






apb_slave_port #(.APB_ADDRWIDTH(A_WIDTH), .APB_DATAWIDTH(D_WIDTH),.NB_RANK(NB_RANK)) apb_slave
								       (.pclk_i		(pclk)		,
									.prst_ni	(preset)	,
									.paddr_i	(paddr)		,
									.psel_i		(pselect)	,
									.penable_i	(penable)	,
						  			.pwrite_i	(pwrite)	,
									.pwdata_i	(pwdata)	,
									.pstrb_i	(pstrobe)	,
									.pready_o	(pready)	,
									.prdata_o	(prdata)	,
						  			.pslverr_o	(pslverr)	,
									.mrw_done_status_i(mrw_i)	,
									.mrr_done_status_i(mrr_i)	,
									.rank_mrw_o	(r_mrw)		,
									.rank_mrr_o	(r_mrr)		,
									.mc_intr_o	(intr)		,
									.ppr_done_status_i(ppr_done)	,
									.ppr_en_o	(ppr_en)	,
									.ppr_status_i   (ppr_status)    ,
									.start_freq_change_o(sta_fre_chng),
									.pll_freq_chng_done_o(pll_fre_chng_done),
									.test_mode_intr_i(test_int)	,
									.freq_change_error_i(f_error)	,
									.freq_change_done_i(f_done)	,
									.freq_change_ready_i(f_ready)	,
									.watch_dog_timeout_i(wd_tout)	,
									.refresh_x_trm_i(ref_xtrm)	,	
									.mr_rd_pulse_o(mr_pulse)	
);


initial 
begin
	mclk = 1;
	repeat(200) mclk = #5 !mclk;
end


initial 
begin
mrst = 0; strb = 0; 
#5 mrst = 1 ;

t=1; 	rd_wr=1; 	maddr= 'h19; 	mwdata=1<<3;	#20 // timer disabled 
t =1; 	rd_wr=1; 	maddr='h40; 	mwdata=1;	#20 // interval*1
#40
t=1; 	rd_wr=1; 	maddr= 'h19; 	mwdata=0<<3;	#20 // timer enabled !
t =0;

 
end

endmodule

