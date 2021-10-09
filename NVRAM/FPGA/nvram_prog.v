/* this is the interface for FT2232 SPI,  here is the data flow
 *   for write: 
 *     bit15 for the addr is set to 1,  (we only support to 32k ram )
 *     | ADDR (15-8) | Addr(7-0) | Data(7-0)| Dummy (7-0)| 
 *    after last bit of data is latched, CE# and WE# will be low, OE# will be high 
 *    and it last a cycle to finish 
 * 
 * * for read: 
 *     bit 15 for addr is set 0, 
 *     | ADDR(15-8) | ADDR(7-0)| Dummy (7-0)| 
 *   after two bytes, OE# and CE# will be set to 0, the next cycle will latch the 
 *   data input. the data will be transfered for the next SPI transfer, until new
 *   read data is available. 
 * 
 * * the dummy data is mainly used to provide clock for RAM access, in fact only 
 *   1 bit is used, but we provide a whole byte. 
 * 
 */

module nvram_prog(rst_n, 
                  spi_clk_i, 
                  spi_ncs_i, 
                  spi_mosi, 
                  spi_miso,
                  addr,
                  data,
                  nce,
                  noe,
                  nwe,
                  led,
                  );
   input                        rst_n;
   input                        spi_clk_i;
   input                        spi_ncs_i;
   input                        spi_mosi;
   output reg                   spi_miso;
   output reg [12:0]            addr;
   inout [7:0]                  data;
   output reg                   nce;
   output reg                   noe;
   output reg                   nwe;
   output [2:0]                 led;
   
         
   reg [4:0]                     spi_counter;
   reg [2:0]                     rd_counter;
   reg                           spi_rdn_wr;
   reg [15:0]                    sub_addr;
   reg [7:0]                     data_o;
   reg [7:0]                     data_i;

   assign data = noe ? data_o : 8'hzz;
   assign led[0] = spi_mosi;
   assign led[1] = spi_ncs_i;
   assign led[2] = spi_clk_i;

   //master spi input and output stage
   always @ (posedge spi_clk_i, posedge spi_ncs_i) begin
      if(spi_ncs_i) 
        spi_counter <= 0;
      else
        spi_counter <= spi_counter + 1'b1;
   end

   always @ (posedge spi_clk_i, negedge rst_n)
     if(~rst_n)
       spi_rdn_wr <= 1'b0;
     else if (spi_counter == 0)
       spi_rdn_wr <= spi_mosi;


   always @ (posedge spi_clk_i, posedge spi_ncs_i)
     if (spi_ncs_i)
       sub_addr <= 16'h00;
     else if (spi_counter < 16)
       begin
          sub_addr[15:1] <= sub_addr[14:0];
          sub_addr[0] <= spi_mosi;
       end

   always @ (posedge spi_clk_i)
     if (spi_counter >= 16 && spi_counter < 24)
       begin
          data_o[7:1] <= data_o[6:0];
          data_o[0] <= spi_mosi;
       end

   always @ (negedge spi_clk_i, posedge spi_ncs_i) begin
      if(spi_ncs_i) 
        rd_counter <= 0;
      else
        rd_counter <= rd_counter + 1'b1;
   end
   
   always @ (*)
     spi_miso =  data_i[7 - rd_counter[2:0]];

   /* latch the address either on posedge of cs or the start 
    * of data bits 
    */
   always @ (posedge spi_clk_i, negedge rst_n)
     if (~rst_n)
       addr <= 13'h1FFF;
     else if (spi_counter == 16)
       addr <= sub_addr[12:0];
  
   reg[1:0] state;
   reg [1:0] next_state;
   parameter S_IDLE = 0, S_WR=1, S_RD=2;

   always @ (posedge spi_clk_i, negedge rst_n)
     if (~rst_n)
       state <= S_IDLE;
     else 
       state <=  next_state;

   always @ (*)
     case (state)
       S_IDLE: 
          if (~spi_rdn_wr & spi_counter == 17)
            next_state = S_RD;
          else if (spi_rdn_wr & spi_counter == 25)
            next_state = S_WR;
          else
            next_state = S_IDLE;
       S_RD:
         next_state = S_IDLE;
       S_WR:
         next_state = S_IDLE;
       default:
         next_state = S_IDLE;
     endcase // case (state)
   

   always @ (*)
     if (state == S_IDLE) begin
        noe = 1'b1;
        nce = 1'b1;
        nwe = 1'b1;
     end
     else if (state == S_RD) begin
        noe = 1'b0;
        nce = 1'b0;
        nwe = 1'b1;
     end
     else if (state == S_WR) begin
        noe = 1'b1;
        nce = 1'b0;
        nwe = 1'b0;
     end
     else begin
        noe = 1'b1;
        nce = 1'b1;
        nwe = 1'b1;
     end
       
        
   always @ (posedge spi_clk_i)
     if (state == S_RD)
       data_i <= data;
   
endmodule
          

          
       
   
        

   

        
        
   
        
   

