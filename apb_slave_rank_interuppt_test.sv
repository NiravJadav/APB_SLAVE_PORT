module apb_slave_port_test();

parameter A_WIDTH = 16;
parameter D_WIDTH = 8 ;
parameter NB_RANK = 8 ;
//APB BUS INTERCONNECTS
wire pclk,preset,pselect,penable,pready,pslverr,pwrite;
wire [D_WIDTH-1:0] pwdata,prdata;
wire [A_WIDTH-1:0] paddr;
wire [3:0]     pstrobe;


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
wire[NB_RANK-1:0] r_mrr,r_mrw;

//APB SLAVE INTRUPPT OUTPUT 
wire intr;

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
									.rank_intr_o	(intr))		;

initial 
begin	
	mclk = 1;
	forever mclk = #5 !mclk;
end


initial 
begin 
mrst = 0; strb =0;  mrw_i  =0; mrr_i  =0;
#5 mrst = 1;
t =1 ;

rd_wr = 1; 	maddr = 3;	mwdata = 7;	#20	// rank_index <-- 0
rd_wr = 1; 	maddr = 0;	mwdata = 10;	#20	// mraddr[0]  <-- 10
rd_wr = 1; 	maddr = 1;	mwdata = 20;	#20	// mrdata[0]  <-- 20
rd_wr = 1;	maddr = 2;	mwdata = 2;	#20 	// rank_mrw[0] request asseted 

// rank_mrw req done ! 
//now some random transaction 

t= 0;




end

always@(posedge intr) // ISR of intr pin
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


always@(r_mrw)
begin
if(r_mrw[0]) begin #30 mrw_i[0] =1; #10 mrw_i[0] = 0; end
if(r_mrw[1]) begin #30 mrw_i[1] =1; #10 mrw_i[1] = 0; end
if(r_mrw[2]) begin #30 mrw_i[2] =1; #10 mrw_i[2] = 0; end
if(r_mrw[3]) begin #30 mrw_i[3] =1; #10 mrw_i[3] = 0; end
if(r_mrw[4]) begin #30 mrw_i[4] =1; #10 mrw_i[4] = 0; end
if(r_mrw[5]) begin #30 mrw_i[5] =1; #10 mrw_i[5] = 0; end
if(r_mrw[6]) begin #30 mrw_i[6] =1; #10 mrw_i[6] = 0; end
if(r_mrw[7]) begin #30 mrw_i[7] =1; #10 mrw_i[7] = 0; end
end


always@(r_mrr)
begin
if(r_mrr[0]) begin #30 mrr_i[0] =1; #10 mrr_i[0] = 0; end
if(r_mrr[1]) begin #30 mrr_i[1] =1; #10 mrr_i[1] = 0; end
if(r_mrr[2]) begin #30 mrr_i[2] =1; #10 mrr_i[2] = 0; end
if(r_mrr[3]) begin #30 mrr_i[3] =1; #10 mrr_i[3] = 0; end
if(r_mrr[4]) begin #30 mrr_i[4] =1; #10 mrr_i[4] = 0; end
if(r_mrr[5]) begin #30 mrr_i[5] =1; #10 mrr_i[5] = 0; end
if(r_mrr[6]) begin #30 mrr_i[6] =1; #10 mrr_i[6] = 0; end
if(r_mrr[7]) begin #30 mrr_i[7] =1; #10 mrr_i[7] = 0; end
end

endmodule
