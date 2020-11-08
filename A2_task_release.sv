// serialyzer with data & modifier locking
module A2_task

#( parameter WIDTH = 8, VAL_BITS = 3 )

(
  input logic                 clk_i, srst_i, 
  input logic                 data_val_i,
  
  input logic  [WIDTH-1:0]    data_i,
  input logic  [VAL_BITS-1:0] data_mod_i,
  
  output logic                ser_data_o,
  output logic                ser_data_val_o,
  output logic                busy_o
);  

logic          [WIDTH-1:0]    data_temp;
logic          [VAL_BITS-1:0] val_width;
logic                         sh_flag, start_flag;

logic [$clog2( VAL_BITS ) + 1:0]  sh_count;

always_comb
  begin
    start_flag = 0;
      if ( ( data_val_i ) & ( !busy_o ) & ( data_mod_i >= 3 ) ) 
        begin
          start_flag = 1;
        end
  end

//data lock
always_ff @( posedge clk_i )
begin
  if ( srst_i ) 
    begin
      data_temp      <= 0;
      val_width      <= 0;
      ser_data_o     <= 0;
      ser_data_val_o <= 0;
      busy_o         <= 0;
      sh_count       <= 0;
      sh_flag        <= 0;
    end
  else 
    if ( start_flag )
      begin
        data_temp <= data_i;
        val_width <= data_mod_i - 1;
        busy_o    <= 1;
        sh_count  <= 0;
      end

// data shift  
  if ( ( busy_o ) & ( sh_count <= val_width ) ) 
    begin
      ser_data_val_o <= 1;
      sh_flag        <= 1;
      ser_data_o     <= data_temp[ ( ( WIDTH-1 ) - sh_count ) ];
      sh_count       <= sh_count + 1;
    end
  else 
    if ( sh_flag ) 
      begin
        ser_data_val_o <= 0;
        busy_o         <= 0;
        sh_flag        <= 0;
        ser_data_o     <= 0;
      end
end

endmodule
