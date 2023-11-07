// ================================================================
// NVDLA Open Source Project
//
// Copyright(c) 2016 - 2017 NVIDIA Corporation. Licensed under the
// NVDLA Open Hardware License; Check "LICENSE" which comes with
// this distribution for more information.
// ================================================================
// File Name: NV_NVDLA_sync3d_s.v
`timescale 10ps/1ps
module NV_NVDLA_sync3d_s (
   clk
  ,prst
  ,sync_i
  ,sync_o
  );
input clk;
input prst;
input sync_i;
output sync_o;
//// generated by ::sync -input sync_i -output sync_o -clock clk -preset prst -width 1 -type 3D -dft_xclamp
wire [0:0] sync_ibus;
wire [0:0] sync_rbus;
wire [0:0] sync_bbus;
wire [0:0] sync_sbus;
`undef SYNC_PL_NOSYNTHESIS_NOSYNTH_GCS
`ifndef SYNC_PL_NO_RANDOMIZATION
`ifndef SYNTH_LEVEL1_COMPILE
`ifndef SYNTHESIS
    `define SYNC_PL_NOSYNTHESIS_NOSYNTH_GCS
`endif
`endif
`endif
// VCS coverage off
`ifdef SYNC_PL_NOSYNTHESIS_NOSYNTH_GCS
reg [0:0] RandSyncBusPipe [0:1];
reg [0:0] RandSyncBusCurr;
reg [0:0] RandSyncBusNext;
reg [0:0] RandSyncBusRand;
reg [0:0] RandSyncBusPick;
reg [1:1] RandSyncBusKnown;
reg [1:1] RandSyncBusDelta;
reg RandSyncEnable;
reg RandSyncBusEnable;
reg RandSyncBitEnable;
reg RandSyncDiff;
reg RandSyncDone;
reg RandSyncSnap;
reg RandSyncEval;
`endif
// VCS coverage on
// input bus
wire sync_ibus_preDFTxclamp;
wire dft_xclamp_hold_mux_s_sync_i;
wire dft_xclamp_hold_mux_i1_sync_i;
assign sync_ibus_preDFTxclamp = sync_i ;
NV_BLKBOX_SRC0 UJ_dft_xclamp_ctrl_hold_sync_i (.Y(dft_xclamp_hold_mux_s_sync_i) );
NV_BLKBOX_SRC0 UJ_dft_xclamp_scan_hold_sync_i (.Y(dft_xclamp_hold_mux_i1_sync_i) );
MUX2HDD2 UJ_FP_MUX_sync_i_dft_xclamp_before_sync (
  .S (dft_xclamp_hold_mux_s_sync_i),
  .I0 (sync_ibus_preDFTxclamp),
  .I1 (dft_xclamp_hold_mux_i1_sync_i),
  .Z (sync_ibus)
);
// random bus
`ifdef SYNC_PL_NOSYNTHESIS_NOSYNTH_GCS
  assign sync_rbus = RandSyncBusRand;
`else
  assign sync_rbus = sync_ibus;
`endif
// buffer bus
assign sync_bbus = sync_rbus;
// sync bus
sync3d_s_ppp sync_0 (
  .clk(clk),
  .set_(prst),
  .d(sync_bbus[0]),
  .q(sync_sbus[0])
  );
// defeating sync randomizer
`ifndef NO_PLI_OR_EMU
`ifndef GATES
`ifdef SYNC_PL_NOSYNTHESIS_NOSYNTH_GCS
  `ifdef NVTOOLS_SYNC2D_GENERIC_CELL
  defparam sync_0.NV_GENERIC_CELL.first_stage_of_sync.mode = 0;
  `else
  defparam sync_0.first_stage_of_sync.mode = 0;
  `endif
`endif
`endif
`endif
// output bus
assign sync_o = sync_sbus;
// VCS coverage off
`ifndef NO_PLI_OR_EMU
`ifdef SYNC_PL_NOSYNTHESIS_NOSYNTH_GCS
initial begin
  if ($test$plusargs("RandSyncInfo")) $display ("INFO: RandSync:  @ %m");
end
initial begin
  RandSyncEnable = 1'b1;
  if ($test$plusargs("RandSyncGlobalDisable")) RandSyncEnable = 1'b0;
  if ($test$plusargs("RandSyncLocalDisable")) RandSyncEnable = 1'b0;
end
// SRC before DSTCLK: new SRC is sampled to CUR, CUR is sampled to PRE, CUR/PRE are randomized.
// SRC equals DSTCLK: new SRC is sampled to CUR, CUR is sampled to PRE, CUR/PRE are randomized.
// SRC after DSTCLK: old SRC is sampled again to CUR (NOP), CUR is sampled to PRE, CUR == PRE.
// curr
always @(sync_ibus) begin
  RandSyncBusCurr <= sync_ibus;
end
// snap (glitch filter)
initial RandSyncSnap = 1'b0;
always @(posedge clk) begin
  RandSyncSnap <= (RandSyncSnap === 1'bx)? 1'b0 : !RandSyncSnap;
end
// eval (glitch filter)
initial RandSyncEval = 1'b0;
always @(RandSyncBusCurr or negedge prst) begin
  RandSyncEval <= (RandSyncEval === 1'bx)? 1'b0 : !RandSyncEval;
end
// eval
always @(RandSyncEval or RandSyncSnap) begin: rand_sync_block
  integer i, j;
// bump
  for (i=1; i>=1; i=i-1) begin
    RandSyncBusPipe[i] = RandSyncBusPipe[i-1];
  end
  RandSyncBusPipe[0] = RandSyncBusCurr;
// next
  RandSyncBusNext = RandSyncBusPipe[0];
// rand
  if (RandSyncEnable && prst) begin
// known
    for (i=1; i>=1; i=i-1) begin
      RandSyncBusKnown[i] = |RandSyncBusPipe[i] !== 1'bx;
    end
// delta
    for (i=1; i>=1; i=i-1) begin
      RandSyncBusDelta[i] = |(RandSyncBusPipe[i] ^ RandSyncBusPipe[i-1]);
    end
    if (&RandSyncBusKnown && |RandSyncBusDelta) begin
      RandSyncBusNext = RandSyncBusPipe[1];
      RandSyncBusEnable = prand_inst0(1, 100) > (100 - 50);
      if (RandSyncBusEnable) begin
        RandSyncDone = 1'b0;
        for (i=1; i>=1; i=i-1) begin
          RandSyncDiff = RandSyncBusPipe[i] !== RandSyncBusPipe[i-1];
          if (RandSyncDiff && !RandSyncDone) begin
            RandSyncBusPickTask (RandSyncBusPipe[i], RandSyncBusPipe[i-1]);
            if (RandSyncBusNext !== RandSyncBusPick) begin
              RandSyncBusNext = RandSyncBusPick;
              RandSyncDone = 1'b1;
            end
          end
        end
      end
    end
  end
  RandSyncBusRand = RandSyncBusNext;
end
// task
task RandSyncBusPickTask; // rand value = mixture
  input [0:0] RandSyncTaskBusPrev;
  input [0:0] RandSyncTaskBusCurr;
  integer i;
  for (i=0; i<=0; i=i+1) begin
    if (RandSyncTaskBusCurr[i] === RandSyncTaskBusPrev[i]) begin
      RandSyncBusPick[i] = RandSyncTaskBusCurr[i];
    end else begin
      RandSyncBitEnable = prand_inst1(1, 100) > (100 - 50);
      RandSyncBusPick[i] = (RandSyncBitEnable)? RandSyncTaskBusCurr[i] : RandSyncTaskBusPrev[i];
    end
  end
endtask
`ifdef SYNTH_LEVEL1_COMPILE
`else
`ifdef SYNTHESIS
`else
`ifdef PRAND_VERILOG
// Only verilog needs any local variables
reg [47:0] prand_local_seed0;
reg prand_initialized0;
reg prand_no_rollpli0;
`endif
`endif
`endif
function [31:0] prand_inst0;
//VCS coverage off
    input [31:0] min;
    input [31:0] max;
    reg [32:0] diff;
    begin
`ifdef SYNTH_LEVEL1_COMPILE
        prand_inst0 = min;
`else
`ifdef SYNTHESIS
        prand_inst0 = min;
`else
`ifdef PRAND_VERILOG
        if (prand_initialized0 !== 1'b1) begin
            prand_no_rollpli0 = $test$plusargs("NO_ROLLPLI");
            if (!prand_no_rollpli0)
                prand_local_seed0 = {$prand_get_seed(0), 16'b0};
            prand_initialized0 = 1'b1;
        end
        if (prand_no_rollpli0) begin
            prand_inst0 = min;
        end else begin
            diff = max - min + 1;
            prand_inst0 = min + prand_local_seed0[47:16] % diff;
// magic numbers taken from Java's random class (same as lrand48)
            prand_local_seed0 = prand_local_seed0 * 48'h5deece66d + 48'd11;
        end
`else
`ifdef PRAND_OFF
        prand_inst0 = min;
`else
        prand_inst0 = $RollPLI(min, max, "auto");
`endif
`endif
`endif
`endif
    end
//VCS coverage on
endfunction
`ifdef SYNTH_LEVEL1_COMPILE
`else
`ifdef SYNTHESIS
`else
`ifdef PRAND_VERILOG
// Only verilog needs any local variables
reg [47:0] prand_local_seed1;
reg prand_initialized1;
reg prand_no_rollpli1;
`endif
`endif
`endif
function [31:0] prand_inst1;
//VCS coverage off
    input [31:0] min;
    input [31:0] max;
    reg [32:0] diff;
    begin
`ifdef SYNTH_LEVEL1_COMPILE
        prand_inst1 = min;
`else
`ifdef SYNTHESIS
        prand_inst1 = min;
`else
`ifdef PRAND_VERILOG
        if (prand_initialized1 !== 1'b1) begin
            prand_no_rollpli1 = $test$plusargs("NO_ROLLPLI");
            if (!prand_no_rollpli1)
                prand_local_seed1 = {$prand_get_seed(1), 16'b0};
            prand_initialized1 = 1'b1;
        end
        if (prand_no_rollpli1) begin
            prand_inst1 = min;
        end else begin
            diff = max - min + 1;
            prand_inst1 = min + prand_local_seed1[47:16] % diff;
// magic numbers taken from Java's random class (same as lrand48)
            prand_local_seed1 = prand_local_seed1 * 48'h5deece66d + 48'd11;
        end
`else
`ifdef PRAND_OFF
        prand_inst1 = min;
`else
        prand_inst1 = $RollPLI(min, max, "auto");
`endif
`endif
`endif
`endif
    end
//VCS coverage on
endfunction
`endif
`endif
// VCS coverage on
endmodule // NV_NVDLA_sync3d_s
