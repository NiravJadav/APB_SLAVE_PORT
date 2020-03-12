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
//APB SLAVE INTRUPPT OUTPUT 
wire intr;

// Training Nets
reg 	ca_done,
  	wr_dq_done,
	wr_lvl_done,
	rd_lvl_done,
	rd_gate_done,
	zq_done,
	all_done;

wire 	ca_start,
	wr_dq_start,
	wr_lvl_start,
	rd_lvl_start,
	rd_gate_start,
	zq_start,
	all_start;
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
									.m_addr_i	(maddr)		);
									






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
								
									.ca_training_start_o	 (ca_start  	 )     ,	
                                                                	.wr_dq_training_start_o	 (wr_dq_start	 )     ,
                                                                	.wr_lvl_training_start_o (wr_lvl_start	 )     ,
                                                                	.rd_lvl_training_start_o (rd_lvl_start	 )     ,
                                                                	.rd_gate_training_start_o(rd_gate_start	 )     ,
                                                                	.zq_training_start_o	 (zq_start   	 )     ,
                                                                	.all_training_start_o	 (all_start 	 )     ,
                                                                	                             
                                                                	.ca_training_done_i	(ca_done    	)   	,
                                                                	.wr_dq_training_done_i	(wr_dq_done	)    	,
                                                                	.wr_lvl_training_done_i (wr_lvl_done	)	,
                                                                	.rd_lvl_training_done_i (rd_lvl_done	)	,
                                                                	.rd_gate_training_done_i(rd_gate_done	)     	,
                                                                	.zq_training_done_i	(zq_done  	)    	,
                                                                	.all_training_done_i	(all_done 	)    	



	
);


initial 
begin
	mclk = 1;
	forever mclk = #5 !mclk;
end


initial 
begin
mrst = 0; strb = 0; zq_done =0;
#5 mrst = 1 ;

t =1;
rd_wr = 1; 	maddr = 'h10; 	mwdata = 1<<5; 	#20
t=0;


end

always @ (posedge zq_start)
begin
#30
zq_done <= 1;
#20
$finish;
end
endmodule
