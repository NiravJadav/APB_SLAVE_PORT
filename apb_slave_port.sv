// Design : apb_slave port for LPDDR3-4 MC
// Datawidth supported by design 8/16/32 [APB_DATAWIDTH]
 


module apb_slave_port
#(
   parameter APB_ADDRWIDTH =16 , 
   parameter APB_DATAWIDTH = 32,
   parameter NB_RANK=1;
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
  output 			 pslverr_o      

);

wire 				r_en	;	// read enable 	, prdata_i <-- register_bank
wire 				w_wn	;	// write enable	, register_bank <-- pwdata_i 
wire [31:0] 			wdata_c	;	
wire [APB_DATAWIDTH-1:0]	prdata_c;

localparam ADDR_LSB = (APB_DATAWIDTH/8)>>1;  // paramter to generalize paddr_i LSB in generate loop 

initial 
$display("%d",ADDR_LSB);




// Rank Specific Registers 
wire add_00h	;	//	0x00h -->	Mode Register Address Register 
wire add_01h	;	//	0x01h -->	Mode Register Data Register
wire add_02h	;	//	0x02h --> 	Rank Access Control/Status Register
wire add_03h	;	//	0x03h --> 	Rank Index register	
wire add_04h	;	// 	0x04h --> 	PPR Control/Status Register
wire add_05h 	;	//	0x05h --> 	PPR Bank Address Register
wire add_06h  	;	//	0x06h --> 	PPR Row Address Register
wire add_07h	;	

// Common Registers
wire add_10h	;	// 	0x10h -->	Training Register
wire add_14h	;	//	0x14h -->	MC Control/Status Register
wire add_18h	;	//	0x18h -->	Power Down Control/Status Register-1
wire add_19h	;	//	0x19h --> 	Power Down Control/Status Register-2
wire add_1ch	;	//	0x1ch -->	Frequency Change Register
wire add_20h	;	//	0x20h -->	Strap Configuration Register

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
wire add_61h	;	//	0x61h -->	MC Error Interrupt Status Register
wire add_62h	;	//	0x62h -->	MC Interrupt Status Register 
wire add_64h	;	//	0x64h --> 	Rank Interrupt Enable Register
wire add_65h	;	//	0x65h -->	MC Error Interrupt Enable Register
wire add_66h	;	//	0x66h -->	MC Interrupt Enable Register

// Test Mode Specific Register

wire add_70h	;	//	0x70h -->	Test Mode Control/Status Register
wire add_74h	;	//	0x74h -->	Read/Write Test-Mode Size Register
wire add_75h	;
wire add_76h	;
wire add_77h	;

wire add_78h	;	//	0x78  -->	Read/Write Test-Mode Address Register
wire add_79h	;	
wire add_7ah	;
wire add_7bh	;

wire add_7ch	;	//	0x7c  -->	Read/Write Test-Mode Address Register
wire add_7dh	;
wire add_7eh	;
wire add_7fh	;

wire add_80h	;	//	0x80  -->	Read/Write Test-Mode Data Register
wire add_81h	;
wire add_82h	;
wire add_83h	;

wire [31:0] reg_data	;
// Logic for APB control signal 

	assign pready_o  = psel_i ? 1 :	0 ; 	// if slave select than salve ready 
	assign pslverr_o = 0		  ;	// not implemented 
	
	assign r_en = (psel_i & !pwrite_i		)	;	// read_enable signal
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
			
			assign add_10h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h10>>ADDR_LSB)) ? 1 :  0  	;
			assign add_14h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h14>>ADDR_LSB)) ? 1 :  0  	;
			assign add_18h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h18>>ADDR_LSB)) ? 1 :  0  	;
			assign add_19h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h19>>ADDR_LSB)) ? 1 :  0  	;
			assign add_1ch =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h1c>>ADDR_LSB)) ? 1 :  0  	;
			assign add_20h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h20>>ADDR_LSB)) ? 1 :  0  	;
						
			assign add_30h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h30>>ADDR_LSB)) ? 1 :  0  	;
			assign add_31h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h31>>ADDR_LSB)) ? 1 :  0  	;
			assign add_32h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h32>>ADDR_LSB)) ? 1 :  0  	;
			assign add_33h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h33>>ADDR_LSB)) ? 1 :  0  	;
			assign add_34h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h34>>ADDR_LSB)) ? 1 :  0  	;
			assign add_35h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h35>>ADDR_LSB)) ? 1 :  0  	;
			assign add_36h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h36>>ADDR_LSB)) ? 1 :  0  	;
			assign add_37h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h37>>ADDR_LSB)) ? 1 :  0  	;
			assign add_38h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h38>>ADDR_LSB)) ? 1 :  0  	;
			assign add_39h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h39>>ADDR_LSB)) ? 1 :  0  	;
			assign add_3ah =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h3a>>ADDR_LSB)) ? 1 :  0  	;
			assign add_3bh =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h3b>>ADDR_LSB)) ? 1 :  0  	;
			assign add_3ch =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h3c>>ADDR_LSB)) ? 1 :  0  	;
			assign add_3dh =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h3d>>ADDR_LSB)) ? 1 :  0  	;
			assign add_3eh =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h3e>>ADDR_LSB)) ? 1 :  0  	;
			assign add_3fh =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h3f>>ADDR_LSB)) ? 1 :  0  	;
			assign add_40h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h40>>ADDR_LSB)) ? 1 :  0  	;
			assign add_41h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h41>>ADDR_LSB)) ? 1 :  0  	;
			assign add_42h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h42>>ADDR_LSB)) ? 1 :  0  	;
			assign add_43h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h43>>ADDR_LSB)) ? 1 :  0  	;
			assign add_44h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h44>>ADDR_LSB)) ? 1 :  0  	;
			assign add_45h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h45>>ADDR_LSB)) ? 1 :  0  	;
			assign add_46h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h46>>ADDR_LSB)) ? 1 :  0  	;
			assign add_47h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h47>>ADDR_LSB)) ? 1 :  0  	;
			assign add_48h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h48>>ADDR_LSB)) ? 1 :  0  	;
			assign add_49h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h49>>ADDR_LSB)) ? 1 :  0  	;
			assign add_4ah =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h4a>>ADDR_LSB)) ? 1 :  0  	;
			assign add_4bh =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h4b>>ADDR_LSB)) ? 1 :  0  	;
			assign add_4ch =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h4c>>ADDR_LSB)) ? 1 :  0  	;
			assign add_4dh =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h4d>>ADDR_LSB)) ? 1 :  0  	;
			assign add_4eh =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h4e>>ADDR_LSB)) ? 1 :  0  	;
			assign add_4fh =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h4f>>ADDR_LSB)) ? 1 :  0  	;
			assign add_50h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h50>>ADDR_LSB)) ? 1 :  0  	;
			assign add_51h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h51>>ADDR_LSB)) ? 1 :  0  	;
			assign add_52h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h52>>ADDR_LSB)) ? 1 :  0  	;
			assign add_53h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h53>>ADDR_LSB)) ? 1 :  0  	;
			assign add_5ch =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h5c>>ADDR_LSB)) ? 1 :  0  	;
			
			assign add_60h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h60>>ADDR_LSB)) ? 1 :  0  	;
			assign add_61h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h61>>ADDR_LSB)) ? 1 :  0  	;
			assign add_62h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h62>>ADDR_LSB)) ? 1 :  0  	;
			assign add_64h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h64>>ADDR_LSB)) ? 1 :  0  	;
			assign add_65h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h65>>ADDR_LSB)) ? 1 :  0  	;
			assign add_66h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h66>>ADDR_LSB)) ? 1 :  0  	;
			
			
			assign add_70h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h70>>ADDR_LSB)) ? 1 :  0  	;
			assign add_74h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h74>>ADDR_LSB)) ? 1 :  0  	;
			assign add_75h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h75>>ADDR_LSB)) ? 1 :  0  	;
			assign add_76h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h76>>ADDR_LSB)) ? 1 :  0  	;
			assign add_77h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h77>>ADDR_LSB)) ? 1 :  0  	;
			assign add_78h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h78>>ADDR_LSB)) ? 1 :  0  	;
			assign add_79h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h79>>ADDR_LSB)) ? 1 :  0  	;
			assign add_7ah =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h7a>>ADDR_LSB)) ? 1 :  0  	;
			assign add_7bh =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h7b>>ADDR_LSB)) ? 1 :  0  	;
			assign add_7ch =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h7c>>ADDR_LSB)) ? 1 :  0  	;
			assign add_7dh =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h7d>>ADDR_LSB)) ? 1 :  0  	;
			assign add_7eh =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h7e>>ADDR_LSB)) ? 1 :  0  	;
			assign add_7fh =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h7f>>ADDR_LSB)) ? 1 :  0  	;
			assign add_80h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h80>>ADDR_LSB)) ? 1 :  0  	;
			assign add_81h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h81>>ADDR_LSB)) ? 1 :  0  	;
			assign add_82h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h82>>ADDR_LSB)) ? 1 :  0  	;
			assign add_83h =  (paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == ('h83>>ADDR_LSB)) ? 1 :  0  	;
			
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
			
			assign add_10h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h10>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;

			assign add_14h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h14>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
	
			assign add_18h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h18>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_19h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h19>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_1ch =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h1c>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;

			assign add_20h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h20>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
						
			assign add_30h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h30>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_31h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h31>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_32h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h32>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_33h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h33>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_34h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h34>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_35h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h35>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_36h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h36>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_37h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h37>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_38h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h38>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_39h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h39>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_3ah =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3a>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_3bh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3b>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_3ch =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3c>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_3dh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3d>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_3eh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3e>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_3fh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3f>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_40h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h40>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_41h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h41>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_42h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h42>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_43h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h43>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_44h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h44>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_45h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h45>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_46h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h46>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_47h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h47>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_48h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h48>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_49h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h49>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;
			
			assign add_4ah =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4a>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_4bh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4b>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;
			
			assign add_4ch =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4c>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_4dh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4d>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_4eh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4e>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_4fh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4f>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_50h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h50>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_51h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h51>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_52h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h52>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_53h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h53>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_5ch =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h5c>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			
			assign add_60h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h60>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_61h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h61>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_62h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h62>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;

			assign add_64h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h64>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_65h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h65>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_66h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h66>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			
			
			assign add_70h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h70>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;

			assign add_74h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h74>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_75h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h75>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_76h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h76>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_77h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h77>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_78h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h78>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_79h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h79>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_7ah =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h7a>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_7bh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h7b>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_7ch =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h7c>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_7dh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h7d>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_7eh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h7e>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_7fh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h7f>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_80h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h80>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_81h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h81>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_82h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h82>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_83h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h82>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;
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
			
			assign add_10h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h10>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_14h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h14>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_18h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h18>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_19h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h19>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;

			assign add_1ch =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h1c>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_20h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h20>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
					
			assign add_30h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h30>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_31h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h31>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;
			assign add_32h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h32>>ADDR_LSB) & pstrb_i[2]) ? 1 :  0 ;
			assign add_33h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h33>>ADDR_LSB) & pstrb_i[3]) ? 1 :  0 ;

			assign add_34h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h34>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_35h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h35>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;
			assign add_36h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h36>>ADDR_LSB) & pstrb_i[2]) ? 1 :  0 ;
			assign add_37h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h37>>ADDR_LSB) & pstrb_i[3]) ? 1 :  0 ;

			assign add_38h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h38>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_39h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h39>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;
			assign add_3ah =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3a>>ADDR_LSB) & pstrb_i[2]) ? 1 :  0 ;
			assign add_3bh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3b>>ADDR_LSB) & pstrb_i[3]) ? 1 :  0 ;

			assign add_3ch =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3c>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_3dh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3d>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;
			assign add_3eh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3e>>ADDR_LSB) & pstrb_i[2]) ? 1 :  0 ;
			assign add_3fh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h3f>>ADDR_LSB) & pstrb_i[3]) ? 1 :  0 ;

			assign add_40h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h40>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_41h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h41>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;
			assign add_42h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h42>>ADDR_LSB) & pstrb_i[2]) ? 1 :  0 ;
			assign add_43h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h43>>ADDR_LSB) & pstrb_i[3]) ? 1 :  0 ;

			assign add_44h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h44>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_45h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h45>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;
			assign add_46h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h46>>ADDR_LSB) & pstrb_i[2]) ? 1 :  0 ;
			assign add_47h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h47>>ADDR_LSB) & pstrb_i[3]) ? 1 :  0 ;

			assign add_48h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h48>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_49h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h49>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;
			assign add_4ah =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4a>>ADDR_LSB) & pstrb_i[2]) ? 1 :  0 ;
			assign add_4bh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4b>>ADDR_LSB) & pstrb_i[3]) ? 1 :  0 ;
			
			assign add_4ch =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4c>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_4dh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4d>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;
			assign add_4eh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4e>>ADDR_LSB) & pstrb_i[2]) ? 1 :  0 ;
			assign add_4fh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h4f>>ADDR_LSB) & pstrb_i[3]) ? 1 :  0 ;

			assign add_50h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h50>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_51h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h51>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;
			assign add_52h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h52>>ADDR_LSB) & pstrb_i[2]) ? 1 :  0 ;
			assign add_53h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h53>>ADDR_LSB) & pstrb_i[3]) ? 1 :  0 ;

			assign add_5ch =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h5c>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
		
			assign add_60h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h60>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_61h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h61>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;
			assign add_62h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h62>>ADDR_LSB) & pstrb_i[2]) ? 1 :  0 ;

			assign add_64h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h64>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_65h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h65>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;
			assign add_66h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h66>>ADDR_LSB) & pstrb_i[2]) ? 1 :  0 ;
						
			assign add_70h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h70>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;

			assign add_74h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h74>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_75h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h75>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;
			assign add_76h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h76>>ADDR_LSB) & pstrb_i[2]) ? 1 :  0 ;
			assign add_77h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h77>>ADDR_LSB) & pstrb_i[3]) ? 1 :  0 ;

			assign add_78h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h78>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_79h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h79>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;
			assign add_7ah =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h7a>>ADDR_LSB) & pstrb_i[2]) ? 1 :  0 ;
			assign add_7bh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h7b>>ADDR_LSB) & pstrb_i[3]) ? 1 :  0 ;

			assign add_7ch =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h7c>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_7dh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h7d>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ;
			assign add_7eh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h7e>>ADDR_LSB) & pstrb_i[2]) ? 1 :  0 ;
			assign add_7fh =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h7f>>ADDR_LSB) & pstrb_i[3]) ? 1 :  0 ;

			assign add_80h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h80>>ADDR_LSB) & pstrb_i[0]) ? 1 :  0 ;
			assign add_81h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h81>>ADDR_LSB) & pstrb_i[1]) ? 1 :  0 ; 
			assign add_82h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h82>>ADDR_LSB) & pstrb_i[2]) ? 1 :  0 ;
			assign add_83h =  ((paddr_i[APB_ADDRWIDTH-1:ADDR_LSB] == 'h82>>ADDR_LSB) & pstrb_i[3]) ? 1 :  0 ;
			
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
	
	
/////////////////////////////////////////////////////////////////////
// 
/////////////////////////////////////////////////////////////////////

// - * - * - * - - * - * - * - - * - * - * - - * - * - * - - * - * - * - - * - * - * - - * - * - * - 	



// 1. Rank Specific Registers 
reg [NB_RANK-1:0][7:0] mr_addr 			; // addr = 00h
reg [NB_RANK-1:0][7:0] mr_data 			; // addr = 01h

reg [0:NB_RANK-1] rank_mrw 			; // addr = 02h
reg [0:NB_RANK-1] rank_mrr 			;
reg [0:NB_RANK-1] rank_busy 			;
reg 		  rank_training_done 		;
reg [0:NB_RANK-1] mrw_done_status		;
reg [0:NB_RANK-1] mrr_done_status		;
reg 		  ppr_done_status		;


reg [2:0] rank_index			; // addr = 03h
reg	  all_rank_mr			;	

reg	  ppr_enable 			; // addr = 04h
reg	  ppr_status			;	

reg [2:0] ppr_bank_addr			; // addr = 05h
reg [15:0]ppr_row_addr			; // addr = 06h , addr = 07h

// 3. timer regsiter 
reg [6:0] act2pre_timer			; // addr = 30h - Timer1 register
reg [4:0] rd2pre_timer			;
reg [5:0] act2rw_timer			;
reg [5:0] pre_pb2any_timer		;
reg [5:0] pre_ab2any_timer		;
//  [1:0] RSVD

reg [5:0] write_recovery_timer		; // addr = 34h - Timer2 register
reg [4:0] write2read_timer		;
reg [3:0] wpre_rpst_dqsck		;
reg [4:0] act2act_timer		      	;
reg [5:0] mrr2any_timer			;
reg [5:0] mrw2any_timer			;

reg [9:0] ref_per_bank_timer		; // addr = 38h - Timer3 register
reg [10:0]ref_all_bank_timer		;

reg [5:0] min_zq_latch_timer		; // addr = 3ch - Timer4 register
reg [9:0] vref_chng2any_timer		;
reg [10:0]refresh_interval_timer	;
reg [4:0] min_pd_timer			;

reg [5 :0]mr4rd_interval_timer		; // addr = 40h - Timer5 regsiter
reg [11:0]min_zqcal_timer		;	
reg [2:0] derated_timer			;
reg [7 :0]vref_current_mode_dis		;

reg [16:0]min_pprdis2any		; // addr = 44h - Timer6 regsiter
reg [5:0] m_in_sr_timer			;
	
reg [4:0] ca_data_out_delay		; // addr = 48h - Timer7 register
reg [5:0] f_out_act_window		;

reg [7:0] dfi_tphywrdata		; // addr = 4ch - DFI Timer register
reg [7:0] dfi_tphywrlat			;
reg [7:0] dfi_tphyrddataen		;
reg [7:0] dfi_tphyrdlat		  	;

reg [31:0] ppr_program_time		; // addr = 50h - PPR Timer Regsiter

reg update_all_timers			; // addr = 5ch - Timer Control Register



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
			rank_training_done 	<= 0	;
			mrw_done_status 	<= 0	;
			mrr_done_status 	<= 0	;
			ppr_done_status 	<= 0	;

			rank_index		<= 0	; // addr = 03h
			all_rank_mr 		<= 0	;

			ppr_enable 		<= 0	; // addr = 04h 
			ppr_status 		<= 0	;

			ppr_bank_addr 		<= 0	; // addr = 05h
			ppr_row_addr		<= 0	; // addr = 06h,07h

		// Timer Registers
			act2pre_timer 		<=0	; // addr = 30h 
			rd2pre_timer  		<=0	;
			act2rw_timer		<=0	;
			pre_pb2any_timer	<=0	;
			pre_ab2any_timer	<=0	;

			write_recovery_timer	<=0	; // addr = 34h
			write2read_timer 	<=0	;
			wpre_rpst_dqsck		<=0	;
			act2act_timer		<=0	;
			mrr2any_timer		<=0	;
			mrw2any_timer		<=0	;
			
			ref_per_bank_timer	<=0	; // addr = 38h
			ref_all_bank_timer	<=0	;
			
			min_zq_latch_timer	<=0	; // addr = 3ch
			vref_chng2any_timer	<=0	;
			refresh_interval_timer	<=0	;
			min_pd_timer		<=0	;
			
			mr4rd_interval_timer	<=0	; // addr = 40h
			min_zqcal_timer		<=0	;
			derated_timer		<=0	;
			vref_current_mode_dis	<=0	;	
			
			min_pprdis2any		<=0	; // addr = 44h
			m_in_sr_timer		<=0	;
			
			ca_data_out_delay	<=0	; // addr = 48h
			f_out_act_window	<=0	;
			
			dfi_tphywrdata		<=0	; // addr = 4ch
			dfi_tphywrlat		<=0	;
			dfi_tphyrddataen	<=0	;
			dfi_tphyrdlat		<=0	;
			
			ppr_program_time	<=0	; // addr = 50h
				
			update_all_timers	<=0	; // addr = 5ch
			
				
		end
		else if(w_en)
		begin
// Rank Specific Registers Write Transfer 
		if(add_00h) {mr_addr}    						<=  wdata_c[7 : 0]		;
		if(add_01h) {mr_data}	 						<=  wdata_c[15: 8]		;
		if(add_02h) {rank_mrr , rank_mrw} 					<=  wdata_c[1:0]		;
		if(add_03h) {all_rank_mr, rank_index} 					<=  {wdata_c[31],wdata_c[26:24]};
		
		if(add_04h) {ppr_enable} 						<= {wdata_c[0]}			;
		if(add_05h) {ppr_bank_addr}  						<= {wdata_c[10:8]}		;
		if(add_06h) {ppr_row_addr[7:0]}						<= {wdata_c[23:16]}		;
		if(add_07h) {ppr_row_addr[15:8]}					<= {wdata_c[31:24]}		;

// Timer Registers Write Transfer 

		if(add_30h) {rd2pre_timer[0], act2pre_timer[6:0]} 			<= wdata_c[7:0]			;
		if(add_31h) {act2rw_timer[3:0], rd2pre_timer[4:1]} 			<= wdata_c[15:8]		;
		if(add_32h) {pre_pb2any_timer[5:0], act2rw_timer[5:4]} 			<= wdata_c[23:16]		;
		if(add_33h) {pre_ab2any_timer [5:0]} 					<= wdata_c[29:24]		;

		if(add_34h) {write2read_timer[1:0],write_recovery_timer[5:0]}   		<= wdata_c[7:0]		;
		if(add_35h) {act2act_timer[0],wpre_rpst_dqsck[3:0], write2read_timer[4:2]}	<= wdata_c[15:8]	;
		if(add_36h) {mrr2any_timer[3:0],act2act_timer[4:1]} 				<= wdata_c[23:16]	;
		if(add_37h) {mrw2any_timer[5:0],mrr2any_timer[5:4]} 				<= wdata_c[31:24]	;

		if(add_38h) {ref_per_bank_timer[7:0]} 					<= wdata_c[7:0]			;
		if(add_39h) {ref_all_bank_timer[5:0], ref_per_bank_timer[9:8] } 	<= wdata_c[15:0]		;
		if(add_3ah) {ref_all_bank_timer[10:6]}					<= wdata_c[20:16]		;
		// add_3bh reserved !

		if(add_3ch) {vref_chng2any_timer[1:0],min_zq_latch_timer[5:0]} 		<= wdata_c[7:0]			;		
		if(add_3dh) {vref_chng2any_timer[9:2]} 					<= wdata_c[15:8]		;
		if(add_3eh) {refresh_interval_timer[7:0]} 				<= wdata_c[23:16]		;
		if(add_3fh) {min_pd_timer[4:0],refresh_interval_timer[10:8]} 		<= wdata_c[31:24]		;
	
		if(add_40h) {mr4rd_interval_timer[5:0]} 				<= wdata_c[5:0]			;
		if(add_41h) {min_zqcal_timer[7:0]} 					<= wdata_c[15:8]		;
		if(add_42h) {derated_timer[2:0], min_zqcal_timer[11:8]} 		<= wdata_c[22:16]		;		
		if(add_43h) {vref_current_mode_dis[7:0]} 				<= wdata_c[31:24]		;
	
		if(add_44h) {min_pprdis2any[7:0]}  					<= wdata_c[7:0]			;
		if(add_45h) {min_pprdis2any[15:0]} 					<= wdata_c[15:8]		;
		if(add_46h) {m_in_sr_timer[5:0],min_pprdis2any[16]} 			<= wdata_c[22:16]		;
		// add_47h RSVD !
		
		if(add_48h) {f_out_act_window[2:0],ca_data_out_delay[4:0]}  		<= wdata_c[7:0]			;
		if(add_49h) {f_out_act_window[5:3]} 					<= wdata_c[10:8]		;
		// add_4ah RSVD !
		// add_4bh RSVD !
		
		if(add_4ch) {dfi_tphywrdata[7:0]} 					<= wdata_c[7:0]			;
		if(add_4dh) {dfi_tphywrlat[7:0]}  					<= wdata_c[15:7]		;
		if(add_4eh) {dfi_tphyrddataen[7:0]}					<= wdata_c[23:16]		;
		if(add_4fh) {dfi_tphyrdlat[7:0]} 					<= wdata_c[31:24]		;

		if(add_50h) {ppr_program_time[7:0]} 					<= wdata_c[7:0]			;
		if(add_51h) {ppr_program_time[15:8]} 					<= wdata_c[15:8]		;
		if(add_52h) {ppr_program_time[23:16]}					<= wdata_c[23:16]		;
		if(add_53h) {ppr_program_time[31:24]}					<= wdata_c[31:24]		;

		if(add_5ch) {update_all_timers} 					<= wdata_c[0]			;

		
		end
	end
// - * - * - * - - * - * - * - - * - * - * - - * - * - * - - * - * - * - - * - * - * - - * - * - * - 	
//
// reading register data and collected at "reg_data" 32 bit register as per address selected !
// 
	assign reg_data[7 : 0] =(add_00h) ? mr_addr 						: 
			 	(add_04h) ? {6'b0, ppr_status, ppr_enable} 		 	:
				(add_30h) ? {rd2pre_timer[0], act2pre_timer[6:0]} 		:
				(add_34h) ? {write2read_timer[1:0],write_recovery_timer[5:0]}	:
				(add_38h) ? {ref_per_bank_timer[7:0]} 				:
				(add_3ch) ? {vref_chng2any_timer[1:0],min_zq_latch_timer[5:0]}	:
				(add_40h) ? {2'b0, mr4rd_interval_timer[5:0]}			:
				(add_44h) ? {min_pprdis2any[7:0]}				:
				(add_48h) ? {f_out_act_window[2:0],ca_data_out_delay[4:0]}	:
				(add_4ch) ? {dfi_tphywrdata[7:0]}				:
				(add_50h) ? {ppr_program_time[7:0]}				:
				(add_5ch) ? {7'b0,update_all_timers}				:	0;
	
	assign reg_data[15: 8] =(add_01h) ? mr_data 								:
				(add_05h) ? {6'b0, ppr_bank_addr}						:
				(add_31h) ? {act2rw_timer[3:0], rd2pre_timer[4:1]} 				:
				(add_35h) ? {act2act_timer[0],wpre_rpst_dqsck[3:0], write2read_timer[4:2]}	:
				(add_39h) ? {ref_all_bank_timer[5:0], ref_per_bank_timer[9:8] }			:
				(add_3dh) ? {vref_chng2any_timer[9:2]}						:	
				(add_41h) ? {min_zqcal_timer[7:0]}						:
				(add_45h) ? {min_pprdis2any[15:0]}						:
				(add_49h) ? {f_out_act_window[5:3]} 						:
				(add_4dh) ? {dfi_tphywrlat[7:0]} 						:
				(add_51h) ? {ppr_program_time[15:8]}						:	0;
	
	assign reg_data[23:16] =(add_02h) ? {ppr_done_status, mrr_done_status, mrw_done_status, rank_training_done, 1'b0 , rank_busy, rank_mrr, rank_mrw} 	:
				(add_06h) ? {ppr_row_addr[7:0]}													:
				(add_32h) ? {pre_pb2any_timer[5:0], act2rw_timer[5:4]}										:
				(add_36h) ? {mrr2any_timer[3:0],act2act_timer[4:1]}										:
				(add_3ah) ? {3'b0,ref_all_bank_timer[10:6]}											:
				(add_3eh) ? {refresh_interval_timer[7:0]}											:
				(add_42h) ? {1'b0,derated_timer[2:0], min_zqcal_timer[11:8]} 									:
				(add_46h) ? {1'b0,m_in_sr_timer[5:0],min_pprdis2any[16]} 									:
				(add_4eh) ? {dfi_tphyrddataen[7:0]}												:
				(add_52h) ? {ppr_program_time[23:16]}												:	0;
			

	assign reg_data[31:24] = (add_03h) ? {all_rank_mr, 4'b0, rank_index} 			:	
				 (add_07h) ? {ppr_row_addr[15:8]}				:
				 (add_33h) ? {2'b0,pre_ab2any_timer [5:0]}			:
				 (add_37h) ? {mrw2any_timer[5:0],mrr2any_timer[5:4]}		:
				 (add_3fh) ? {min_pd_timer[4:0],refresh_interval_timer[10:8]}	:
				 (add_43h) ? {vref_current_mode_dis[7:0]} 			:
				 (add_4fh) ? {dfi_tphyrdlat[7:0]}				:
				 (add_53h) ? {ppr_program_time[31:24]}				:	0;

	always@(posedge pclk_i or negedge prst_ni)
	begin
		if(!prst_ni)
			prdata_o <= 0;
		else if (r_en)
			prdata_o <= prdata_c;
	end		
	
// - * - * - * - - * - * - * - - * - * - * - - * - * - * - - * - * - * - - * - * - * - - * - * - * - 	
	

endmodule
