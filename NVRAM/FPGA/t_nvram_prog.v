`timescale 1ns/1ns

module t_nvram_prog;
   
   parameter tp=16;   
   reg           clk_i;
   reg 		 master_spi_ncs;
   wire 	 master_spi_miso;
   reg 		 master_spi_mosi;
   wire          nce, noe, nwe;

   wire [12:0]   addr;
   reg [7:0]     ram_data;
   reg [7:0]    in_data;
   reg           rst_n;
   reg           spi_en;
   
   initial begin
      rst_n = 0;
      spi_en = 0;
      master_spi_ncs = 1;      
      #20 rst_n = 1;
   end
   
   always
     if (spi_en)
       clk_i = #(tp/2) ~clk_i;
     else
       clk_i = #(tp/2) 0;

   task write_spi;
      input [31:0] spi_data;
      input [2:0]  spi_bytes;
      
      integer     spi_cnt;
      integer     bits;

      begin
         bits = spi_bytes * 8;         
	 master_spi_ncs = 0;
         spi_en = 1;
	 for(spi_cnt = 0; spi_cnt <bits-1; spi_cnt= spi_cnt+1) begin
            master_spi_mosi = spi_data[bits - 1 -spi_cnt];
	    @ (negedge clk_i) ;
	 end
         #2 spi_en = 0;
	 #20 master_spi_ncs = 1;
      end
   endtask // write_spi

   always @ (posedge clk_i)
     if (~master_spi_ncs) begin
	in_data[7:1] <= in_data[6:0];
	in_data[0] <= master_spi_miso;
     end

   always @ (negedge nce)
     if (~noe & nwe)
       ram_data <= #2 addr[7:0];
   
   wire [7:0] data_prog;
   assign data_prog = ~noe ? ram_data : 8'hzz;

   always @ (posedge master_spi_ncs)
     $display("spi read data: 0x%02x\n", in_data[7:0]);
   

   nvram_prog prog0 (.rst_n(rst_n), 
                     .spi_clk_i(clk_i), 
                     .spi_ncs_i(master_spi_ncs), 
                     .spi_mosi(master_spi_mosi), 
                     .spi_miso(master_spi_miso),
                     .addr(addr),
                     .data(data_prog),
                     .nce(nce),
                     .noe(noe),
                     .nwe(nwe),
                     .led()
                     );
   initial begin
      $display("start simulation");
      $dumpfile("nvram_prog.vcd");
      $dumpvars;
      #200 write_spi(32'h9B8012AA, 4);
      #200;write_spi(32'h0B20AA, 3);
      #200;write_spi(8'hAA, 1);
      #100 $finish;      
   end
   
   initial begin

   end
endmodule 
