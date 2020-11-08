module A2_task_top

#( parameter WIDTH = 12, VAL_BITS = 4 )

(
  input logic                 clk_i, srst_i,
  input logic                 data_val_i,

  input logic  [WIDTH-1:0]    data_i,
  input logic  [VAL_BITS-1:0] data_mod_i,

  output logic                ser_data_o,
  output logic                ser_data_val_o,
  output logic                busy_o
);

logic                         srst_i_buf;
logic                         data_val_i_buf;

logic          [WIDTH-1:0]    data_i_buf;       //input   data   buffer
logic          [VAL_BITS-1:0] data_mod_i_buf;   // number of bits to be serialized 

logic                         ser_data_o_buf;  
logic                         ser_data_val_o_buf;
logic                         busy_o_buf;

// port mapping
A2_task #( WIDTH, VAL_BITS ) A2_task_core_unit
(
  .clk_i           ( clk_i ),
  .srst_i          ( srst_i_buf ),
  .data_val_i      ( data_val_i_buf ),
  .data_i          ( data_i_buf ),
  .data_mod_i      ( data_mod_i_buf ),
  
  .ser_data_o      ( ser_data_o_buf ),
  .ser_data_val_o  ( ser_data_val_o_buf ),
  .busy_o          ( busy_o_buf )
);

//data locking
always_ff @( posedge clk_i )
  begin
    srst_i_buf     <= srst_i;
    data_val_i_buf <= data_val_i;
    data_i_buf     <= data_i;
    data_mod_i_buf <= data_mod_i;
  
    ser_data_o     <= ser_data_o_buf;
    ser_data_val_o <= ser_data_val_o_buf;
    busy_o         <= busy_o_buf;
  end

endmodule
