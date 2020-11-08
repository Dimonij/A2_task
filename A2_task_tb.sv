module A2_task_tb;

localparam WIDTH    = 8;
localparam VAL_BITS = 3;
localparam MAX_DATA = 2** WIDTH;
localparam MAX_BITS = 2** VAL_BITS;

// DUT wire
bit                clk, reset; 
bit                d_val_i, d_val_o, d_busy_o;
bit                d_ser_data_o;

bit [WIDTH-1:0]    d_in;
bit [VAL_BITS-1:0] d_data_mod_i;

// test internal signal & var
bit                end_flag1, end_flag2, end_flag3;
bit                rand_flag, capt_flag;

bit [WIDTH-1:0]    d_dut;
  bit [WIDTH-1:0]  tempy;

bit [WIDTH-1:0]    data_i_flow [$]; // data word for DUT
bit [WIDTH-1:0]    d_dut_flow [$]; // data word from DUT

int                flow_cnt;
int                test_counter;
int                bit_counter;
int                dut_count;

function [WIDTH-1:0] cutting ( input [WIDTH-1:0] data, [VAL_BITS-1:0] cutter );

bit [WIDTH-1:0]    kgf;

kgf = 0;
for (int j = 0; j <= ( cutter - 1 ); j++ )
  kgf[ ( WIDTH-1 ) - j ] = 1;
  
cutting = data & kgf;

endfunction

// takt generator
initial 
  forever #5 clk = !clk;

// port mapping
A2_task #( WIDTH, VAL_BITS) DUT  (
  .clk_i          ( clk ),
  .srst_i         ( reset ),
  .data_val_i     ( d_val_i ),
  .data_i         (d_in),
  .data_mod_i     ( d_data_mod_i ),
  .ser_data_val_o ( d_val_o ),
  .ser_data_o     ( d_ser_data_o ),
  .busy_o         ( d_busy_o )
);

// start initialization
initial 
  begin
    capt_flag    = 0;
    end_flag1    = 0;
    end_flag2    = 0;
    end_flag3    = 0;
    #10;
    bit_counter  = 0;
    test_counter = 0;
    flow_cnt     = 0;
    @( posedge clk ) reset = 1'b1;
    @( posedge clk ) reset = 1'b0;	
    #10;
  end

// test stimulus generator for random load
initial
  begin
  #50;
  d_val_i = 0;
  do
    begin
      wait ( !d_busy_o );
      @( posedge clk )
        if ( !d_busy_o )
          begin
            rand_flag    = ( $urandom_range ( 1,0 ) );
            d_in         = ( $urandom_range ( MAX_DATA,0 ) );
            d_data_mod_i = ( $urandom_range ( MAX_BITS,0 ) );
          end
        begin
          if ( ( rand_flag ) && ( !d_busy_o ) ) d_val_i = 1;
          if ( ( rand_flag ) && ( !d_busy_o ) && ( d_data_mod_i >= 3 ) )
            begin
              tempy        = cutting ( d_in, d_data_mod_i );
              data_i_flow.push_front ( tempy );
              test_counter = test_counter + 1;
              $display( "data input = %b, ITERATION = %d", tempy, test_counter );  
            end
          @(posedge clk) d_val_i = 0;
        end
        flow_cnt++;
    end
    
  while ( flow_cnt <= ( MAX_DATA / 4 ) );

  d_val_i   = 0;
  end_flag1 = 1;
    
  end

// test stimulus generator for max load
initial
  begin
    wait ( end_flag1 );
    do
      begin
        wait ( !d_busy_o );
        @( posedge clk )
          if ( !d_busy_o )
            begin
              d_in         = ( $urandom_range ( MAX_DATA,0 ) );
              d_data_mod_i = ( $urandom_range ( MAX_BITS,0 ) );
            end
        begin
          if ( !d_busy_o ) d_val_i = 1;
          if ( ( !d_busy_o ) && ( d_data_mod_i >=3 ) )
            begin
              tempy        = cutting ( d_in, d_data_mod_i );
              data_i_flow.push_front( tempy );
              test_counter = test_counter + 1;
              $display( "data input = %b, ITERATION = %d",tempy, test_counter );  
            end
           @( posedge clk ) d_val_i = 0;
        end
        flow_cnt++;
      end
    
    while ( flow_cnt <= ( MAX_DATA / 2 ) );
    
  d_val_i   = 0;
  end_flag2 = 1;
     
  end 
  
//DUT data capture
initial
  begin
    #50;
    dut_count   = 0;
    bit_counter = 0;

    do 
      begin
      @( posedge clk ) 
        if ( d_val_o )
          begin
            capt_flag                        = 1;
            d_dut[( WIDTH-1 ) - bit_counter] = d_ser_data_o;
            bit_counter++;
          end  
        else 
          if ( capt_flag )
            begin
              capt_flag   = 0;
              d_dut_flow.push_front( d_dut );
              dut_count++;
              $display( "data output = %b, out_queue size = %d",d_dut,dut_count );
              d_dut       = 0;
              bit_counter = 0;
            end
      end  

    while  ( !( ( end_flag1 ) && ( end_flag2 ) && ( !d_busy_o ) ) );

    end_flag3 = 1;
  end

// data compare
initial
  begin
    wait ( end_flag1 && end_flag2 && end_flag3 );
      for ( int i = 0; i <= ( MAX_DATA / 2 ); i++ )
        if ( d_dut_flow [i] != data_i_flow[i] )
          begin
            $display( "error at data input = %b, iteration = %d", data_i_flow[i],i );
            $stop;
          end

   $display( "test sucsessful!" );
   $stop;
   
  end
	
endmodule
