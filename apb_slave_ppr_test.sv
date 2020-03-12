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
									.ppr_status_i   (ppr_status)
);

initial 
begin	
	mclk = 1;
	forever mclk = #5 !mclk;
end


initial 
begin 
mrst = 0; strb =0;  mrw_i  =0; mrr_i  =0;
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

always@(posedge intr) // ISR of intr pin
begin
t=1;
rd_wr = 0;	maddr = 'h60; #20 $display("time-->%t, prdata--> %b", $time, prdata);


rd_wr = 1;	maddr = 3; mwdata <= 1;	#20 // writed matched rank address for which interrupt generated !
rd_wr = 0;	maddr = 2;			#20
rd_wr = 0; 	maddr = 4;			#50
			
$finish;    
end


always@(ppr_en)
begin
if(ppr_en[0]) begin #30 ppr_done[0] =1'b1; ppr_status[0] = 1'b1; #10 ppr_done[0] = 1'b0; ppr_status[0] = 1'b0;end
if(ppr_en[1]) begin #30 ppr_done[1] =1'b1; ppr_status[1] = 1'b1; #10 ppr_done[1] = 1'b0; ppr_status[1] = 1'b0;end
if(ppr_en[2]) begin #30 ppr_done[2] =1'b1; ppr_status[2] = 1'b1; #10 ppr_done[2] = 1'b0; ppr_status[2] = 1'b0;end
if(ppr_en[3]) begin #30 ppr_done[3] =1'b1; ppr_status[3] = 1'b1; #10 ppr_done[3] = 1'b0; ppr_status[3] = 1'b0;end
if(ppr_en[4]) begin #30 ppr_done[4] =1'b1; ppr_status[4] = 1'b1; #10 ppr_done[4] = 1'b0; ppr_status[4] = 1'b0;end
if(ppr_en[5]) begin #30 ppr_done[5] =1'b1; ppr_status[5] = 1'b1; #10 ppr_done[5] = 1'b0; ppr_status[5] = 1'b0;end
if(ppr_en[6]) begin #30 ppr_done[6] =1'b1; ppr_status[6] = 1'b1; #10 ppr_done[6] = 1'b0; ppr_status[6] = 1'b0;end
if(ppr_en[7]) begin #30 ppr_done[7] =1'b1; ppr_status[7] = 1'b1; #10 ppr_done[7] = 1'b0; ppr_status[7] = 1'b0;end
end





assign wdata = (prdata[0]) ? 8'd0 :
	       (prdata[1]) ? 8'd1 :
	       (prdata[2]) ? 8'd2 :
	       (prdata[3]) ? 8'd3 :
	       (prdata[4]) ? 8'd4 :
	       (prdata[5]) ? 8'd5 :
	       (prdata[6]) ? 8'd6 :
	       (prdata[7]) ? 8'd7 : 8'd1;
	  
endmodule	  
	  
	  




