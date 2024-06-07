
module one_bit_branch_predictor (
  input logic clk, rst_n,
  input logic branch_i,
  // 0: Not Taken, 1: Taken
  input logic branch_decision,
  // 0: Not Taken, 1: Taken
  output logic  branch_prediction,
  output logic [31:0] trans_addr_o, 
  input logic [31:0] fetch_rdata_o,
  input logic [31:0] pc_if_o
);


  typedef enum logic {TAKEN=1'b1, NT=1'b0
                           } state;
  state p_state, n_state;
  // output logic for branch_out
  assign branch_prediction = (p_state == TAKEN );
  // state registers
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // initialized as Taken output
      p_state <= TAKEN;
    end
    else begin
      p_state <= n_state;
    end
  end

  // next state and output logic 
  always_comb begin
    n_state = TAKEN;
    if (branch_i) begin
      case(p_state)
        TAKEN: begin
          if (branch_decision) begin
            n_state = TAKEN;
          end
          else n_state = NT;
        end
        NT: begin
          if (branch_decision) 
            n_state = TAKEN;
          else n_state = NT;
        end
        default: n_state = TAKEN;
      endcase
    end
   
  end
  
  logic [4:0] ins_imm;
    assign ins_imm = fetch_rdata_o[11:7]; 
  logic sign_bit;
  assign sign_bit = ins_imm[0];
    // Two's complement of bits [2:0]
  logic [31:0] twos_complement;
  assign twos_complement = (sign_bit) ? (~ins_imm[4:1] + 4'b1) : ins_imm[4:1];
  logic [31:0] result;
    // One-bit left shift
    assign result = {twos_complement[3:0], 1'b0};
    assign trans_addr_o = (sign_bit) ? (pc_if_o - result) : (pc_if_o + result);
endmodule
