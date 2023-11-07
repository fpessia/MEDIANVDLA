// ================================================================
// NVDLA Open Source Project
//
// Copyright(c) 2016 - 2017 NVIDIA Corporation. Licensed under the
// NVDLA Open Hardware License; Check "LICENSE" which comes with
// this distribution for more information.
// ================================================================
// File Name: HLS_fp16_to_fp17.v
`timescale 10ps/1ps
module FP16_TO_FP17_mgc_in_wire_wait_v1 (ld, vd, d, lz, vz, z);
  parameter integer rscid = 1;
  parameter integer width = 8;
  input ld;
  output vd;
  output [width-1:0] d;
  output lz;
  input vz;
  input [width-1:0] z;
  wire vd;
  wire [width-1:0] d;
  wire lz;
  assign d = z;
  assign lz = ld;
  assign vd = vz;
endmodule
//------> /home/tools/calypto/catapult-10.0-264918/Mgc_home/pkgs/siflibs/FP16_TO_FP17_mgc_out_stdreg_wait_v1.v
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2015 Mentor Graphics Corp.
// All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------
module FP16_TO_FP17_mgc_out_stdreg_wait_v1 (ld, vd, d, lz, vz, z);
  parameter integer rscid = 1;
  parameter integer width = 8;
  input ld;
  output vd;
  input [width-1:0] d;
  output lz;
  input vz;
  output [width-1:0] z;
  wire vd;
  wire lz;
  wire [width-1:0] z;
  assign z = d;
  assign lz = ld;
  assign vd = vz;
endmodule
//------> /home/tools/calypto/catapult-10.0-264918/Mgc_home/pkgs/siflibs/mgc_shift_l_beh_v4.v
module FP16_TO_FP17_mgc_shift_l_v4(a,s,z);
   parameter width_a = 4;
   parameter signd_a = 1;
   parameter width_s = 2;
   parameter width_z = 8;
   input [width_a-1:0] a;
   input [width_s-1:0] s;
   output [width_z -1:0] z;
   generate
   if (signd_a)
   begin: SIGNED
      assign z = fshl_u(a,s,a[width_a-1]);
   end
   else
   begin: UNSIGNED
      assign z = fshl_u(a,s,1'b0);
   end
   endgenerate
//Shift-left - unsigned shift argument one bit more
   function [width_z-1:0] fshl_u_1;
      input [width_a :0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      int olen = width_z;
      int ilen = width_a+1;
      int len = (ilen >= olen) ? ilen : olen;
      reg [len-1:0] result;
      reg [len-1:0] result_t;
      begin
        result_t = {(len){sbit}};
        result_t[ilen-1:0] = arg1;
        result = result_t <<< arg2;
        fshl_u_1 = result[olen-1:0];
      end
   endfunction // fshl_u
//Shift-left - unsigned shift argument
   function [width_z-1:0] fshl_u;
      input [width_a-1:0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      fshl_u = fshl_u_1({sbit,arg1} ,arg2, sbit);
   endfunction // fshl_u
endmodule
//------> ../td_ccore_solutions/leading_sign_10_0_9ac8f64992538a762a5a05a903e0d3de3d5a_0/rtl.v
// ----------------------------------------------------------------------
// HLS HDL: Verilog Netlister
// HLS Version: 10.0/264918 Production Release
// HLS Date: Mon Aug 8 13:35:54 PDT 2016
//
// Generated by: ezhang@hk-sim-11-197
// Generated date: Tue Nov 15 18:05:52 2016
// ----------------------------------------------------------------------
//
// ------------------------------------------------------------------
// Design Unit: FP16_TO_FP17_leading_sign_10_0
// ------------------------------------------------------------------
module FP16_TO_FP17_leading_sign_10_0 (
  mantissa, rtn
);
  input [9:0] mantissa;
  output [3:0] rtn;
// Interconnect Declarations
  wire IntLeadZero_10U_leading_sign_10_0_rtn_wrs_c_6_2_sdt_2;
  wire IntLeadZero_10U_leading_sign_10_0_rtn_wrs_c_18_3_sdt_3;
  wire IntLeadZero_10U_leading_sign_10_0_rtn_wrs_c_6_2_sdt_1;
  wire IntLeadZero_10U_leading_sign_10_0_rtn_wrs_c_14_2_sdt_1;
  wire c_h_1_2;
  wire c_h_1_3;
  wire IntLeadZero_10U_leading_sign_10_0_rtn_and_35_ssc;
  wire[0:0] IntLeadZero_10U_leading_sign_10_0_rtn_and_31_nl;
  wire[0:0] IntLeadZero_10U_leading_sign_10_0_rtn_IntLeadZero_10U_leading_sign_10_0_rtn_or_nl;
  wire[0:0] IntLeadZero_10U_leading_sign_10_0_rtn_IntLeadZero_10U_leading_sign_10_0_rtn_nor_6_nl;
// Interconnect Declarations for Component Instantiations
  assign IntLeadZero_10U_leading_sign_10_0_rtn_wrs_c_6_2_sdt_2 = ~((mantissa[7:6]!=2'b00));
  assign IntLeadZero_10U_leading_sign_10_0_rtn_wrs_c_6_2_sdt_1 = ~((mantissa[9:8]!=2'b00));
  assign IntLeadZero_10U_leading_sign_10_0_rtn_wrs_c_14_2_sdt_1 = ~((mantissa[5:4]!=2'b00));
  assign c_h_1_2 = IntLeadZero_10U_leading_sign_10_0_rtn_wrs_c_6_2_sdt_1 & IntLeadZero_10U_leading_sign_10_0_rtn_wrs_c_6_2_sdt_2;
  assign IntLeadZero_10U_leading_sign_10_0_rtn_wrs_c_18_3_sdt_3 = (mantissa[3:2]==2'b00)
      & IntLeadZero_10U_leading_sign_10_0_rtn_wrs_c_14_2_sdt_1;
  assign c_h_1_3 = c_h_1_2 & IntLeadZero_10U_leading_sign_10_0_rtn_wrs_c_18_3_sdt_3;
  assign IntLeadZero_10U_leading_sign_10_0_rtn_and_35_ssc = (mantissa[1:0]==2'b00)
      & c_h_1_3;
  assign IntLeadZero_10U_leading_sign_10_0_rtn_and_31_nl = c_h_1_2 & (~ IntLeadZero_10U_leading_sign_10_0_rtn_wrs_c_18_3_sdt_3);
  assign IntLeadZero_10U_leading_sign_10_0_rtn_IntLeadZero_10U_leading_sign_10_0_rtn_or_nl
      = (IntLeadZero_10U_leading_sign_10_0_rtn_wrs_c_6_2_sdt_1 & (IntLeadZero_10U_leading_sign_10_0_rtn_wrs_c_14_2_sdt_1
      | (~ IntLeadZero_10U_leading_sign_10_0_rtn_wrs_c_6_2_sdt_2)) & (~ c_h_1_3))
      | IntLeadZero_10U_leading_sign_10_0_rtn_and_35_ssc;
  assign IntLeadZero_10U_leading_sign_10_0_rtn_IntLeadZero_10U_leading_sign_10_0_rtn_nor_6_nl
      = ~((mantissa[9]) | (~((mantissa[8:7]!=2'b01))) | (((mantissa[5]) | (~((mantissa[4:3]!=2'b01))))
      & c_h_1_2) | ((mantissa[1]) & c_h_1_3) | IntLeadZero_10U_leading_sign_10_0_rtn_and_35_ssc);
  assign rtn = {c_h_1_3 , (IntLeadZero_10U_leading_sign_10_0_rtn_and_31_nl) , (IntLeadZero_10U_leading_sign_10_0_rtn_IntLeadZero_10U_leading_sign_10_0_rtn_or_nl)
      , (IntLeadZero_10U_leading_sign_10_0_rtn_IntLeadZero_10U_leading_sign_10_0_rtn_nor_6_nl)};
endmodule
//------> ./rtl.v
// ----------------------------------------------------------------------
// HLS HDL: Verilog Netlister
// HLS Version: 10.0/264918 Production Release
// HLS Date: Mon Aug 8 13:35:54 PDT 2016
//
// Generated by: ezhang@hk-sim-10-084
// Generated date: Mon Mar 20 14:08:26 2017
// ----------------------------------------------------------------------
//
// ------------------------------------------------------------------
// Design Unit: FP16_TO_FP17_chn_o_rsci_unreg
// ------------------------------------------------------------------
module FP16_TO_FP17_chn_o_rsci_unreg (
  in_0, outsig
);
  input in_0;
  output outsig;
// Interconnect Declarations for Component Instantiations
  assign outsig = in_0;
endmodule
// ------------------------------------------------------------------
// Design Unit: FP16_TO_FP17_chn_a_rsci_unreg
// ------------------------------------------------------------------
module FP16_TO_FP17_chn_a_rsci_unreg (
  in_0, outsig
);
  input in_0;
  output outsig;
// Interconnect Declarations for Component Instantiations
  assign outsig = in_0;
endmodule
// ------------------------------------------------------------------
// Design Unit: HLS_fp16_to_fp17_core_core_fsm
// FSM Module
// ------------------------------------------------------------------
module HLS_fp16_to_fp17_core_core_fsm (
  nvdla_core_clk, nvdla_core_rstn, core_wen, fsm_output
);
  input nvdla_core_clk;
  input nvdla_core_rstn;
  input core_wen;
  output [1:0] fsm_output;
  reg [1:0] fsm_output;
// FSM State Type Declaration for HLS_fp16_to_fp17_core_core_fsm_1
  parameter
    core_rlp_C_0 = 1'd0,
    main_C_0 = 1'd1;
  reg [0:0] state_var;
  reg [0:0] state_var_NS;
// Interconnect Declarations for Component Instantiations
  always @(*)
  begin : HLS_fp16_to_fp17_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 2'b10;
        state_var_NS = main_C_0;
      end
// core_rlp_C_0
      default : begin
        fsm_output = 2'b1;
        state_var_NS = main_C_0;
      end
    endcase
  end
  always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
    if ( ~ nvdla_core_rstn ) begin
      state_var <= core_rlp_C_0;
    end
    else if ( core_wen ) begin
      state_var <= state_var_NS;
    end
  end
endmodule
// ------------------------------------------------------------------
// Design Unit: HLS_fp16_to_fp17_core_staller
// ------------------------------------------------------------------
module HLS_fp16_to_fp17_core_staller (
  nvdla_core_clk, nvdla_core_rstn, core_wen, chn_a_rsci_wen_comp, core_wten, chn_o_rsci_wen_comp
);
  input nvdla_core_clk;
  input nvdla_core_rstn;
  output core_wen;
  input chn_a_rsci_wen_comp;
  output core_wten;
  reg core_wten;
  input chn_o_rsci_wen_comp;
// Interconnect Declarations for Component Instantiations
  assign core_wen = chn_a_rsci_wen_comp & chn_o_rsci_wen_comp;
  always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
    if ( ~ nvdla_core_rstn ) begin
      core_wten <= 1'b0;
    end
    else begin
      core_wten <= ~ core_wen;
    end
  end
endmodule
// ------------------------------------------------------------------
// Design Unit: HLS_fp16_to_fp17_core_chn_o_rsci_chn_o_wait_dp
// ------------------------------------------------------------------
module HLS_fp16_to_fp17_core_chn_o_rsci_chn_o_wait_dp (
  nvdla_core_clk, nvdla_core_rstn, chn_o_rsci_oswt, chn_o_rsci_bawt, chn_o_rsci_wen_comp,
      chn_o_rsci_biwt, chn_o_rsci_bdwt
);
  input nvdla_core_clk;
  input nvdla_core_rstn;
  input chn_o_rsci_oswt;
  output chn_o_rsci_bawt;
  output chn_o_rsci_wen_comp;
  input chn_o_rsci_biwt;
  input chn_o_rsci_bdwt;
// Interconnect Declarations
  reg chn_o_rsci_bcwt;
// Interconnect Declarations for Component Instantiations
  assign chn_o_rsci_bawt = chn_o_rsci_biwt | chn_o_rsci_bcwt;
  assign chn_o_rsci_wen_comp = (~ chn_o_rsci_oswt) | chn_o_rsci_bawt;
  always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
    if ( ~ nvdla_core_rstn ) begin
      chn_o_rsci_bcwt <= 1'b0;
    end
    else begin
      chn_o_rsci_bcwt <= ~((~(chn_o_rsci_bcwt | chn_o_rsci_biwt)) | chn_o_rsci_bdwt);
    end
  end
endmodule
// ------------------------------------------------------------------
// Design Unit: HLS_fp16_to_fp17_core_chn_o_rsci_chn_o_wait_ctrl
// ------------------------------------------------------------------
module HLS_fp16_to_fp17_core_chn_o_rsci_chn_o_wait_ctrl (
  nvdla_core_clk, nvdla_core_rstn, chn_o_rsci_oswt, core_wen, core_wten, chn_o_rsci_iswt0,
      chn_o_rsci_ld_core_psct, chn_o_rsci_biwt, chn_o_rsci_bdwt, chn_o_rsci_ld_core_sct,
      chn_o_rsci_vd
);
  input nvdla_core_clk;
  input nvdla_core_rstn;
  input chn_o_rsci_oswt;
  input core_wen;
  input core_wten;
  input chn_o_rsci_iswt0;
  input chn_o_rsci_ld_core_psct;
  output chn_o_rsci_biwt;
  output chn_o_rsci_bdwt;
  output chn_o_rsci_ld_core_sct;
  input chn_o_rsci_vd;
// Interconnect Declarations
  wire chn_o_rsci_ogwt;
  wire chn_o_rsci_pdswt0;
  reg chn_o_rsci_icwt;
// Interconnect Declarations for Component Instantiations
  assign chn_o_rsci_pdswt0 = (~ core_wten) & chn_o_rsci_iswt0;
  assign chn_o_rsci_biwt = chn_o_rsci_ogwt & chn_o_rsci_vd;
  assign chn_o_rsci_ogwt = chn_o_rsci_pdswt0 | chn_o_rsci_icwt;
  assign chn_o_rsci_bdwt = chn_o_rsci_oswt & core_wen;
  assign chn_o_rsci_ld_core_sct = chn_o_rsci_ld_core_psct & chn_o_rsci_ogwt;
  always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
    if ( ~ nvdla_core_rstn ) begin
      chn_o_rsci_icwt <= 1'b0;
    end
    else begin
      chn_o_rsci_icwt <= ~((~(chn_o_rsci_icwt | chn_o_rsci_pdswt0)) | chn_o_rsci_biwt);
    end
  end
endmodule
// ------------------------------------------------------------------
// Design Unit: HLS_fp16_to_fp17_core_chn_a_rsci_chn_a_wait_dp
// ------------------------------------------------------------------
module HLS_fp16_to_fp17_core_chn_a_rsci_chn_a_wait_dp (
  nvdla_core_clk, nvdla_core_rstn, chn_a_rsci_oswt, chn_a_rsci_bawt, chn_a_rsci_wen_comp,
      chn_a_rsci_d_mxwt, chn_a_rsci_biwt, chn_a_rsci_bdwt, chn_a_rsci_d
);
  input nvdla_core_clk;
  input nvdla_core_rstn;
  input chn_a_rsci_oswt;
  output chn_a_rsci_bawt;
  output chn_a_rsci_wen_comp;
  output [15:0] chn_a_rsci_d_mxwt;
  input chn_a_rsci_biwt;
  input chn_a_rsci_bdwt;
  input [15:0] chn_a_rsci_d;
// Interconnect Declarations
  reg chn_a_rsci_bcwt;
  reg [15:0] chn_a_rsci_d_bfwt;
// Interconnect Declarations for Component Instantiations
  assign chn_a_rsci_bawt = chn_a_rsci_biwt | chn_a_rsci_bcwt;
  assign chn_a_rsci_wen_comp = (~ chn_a_rsci_oswt) | chn_a_rsci_bawt;
  assign chn_a_rsci_d_mxwt = MUX_v_16_2_2(chn_a_rsci_d, chn_a_rsci_d_bfwt, chn_a_rsci_bcwt);
  always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
    if ( ~ nvdla_core_rstn ) begin
      chn_a_rsci_bcwt <= 1'b0;
      chn_a_rsci_d_bfwt <= 16'b0;
    end
    else begin
      chn_a_rsci_bcwt <= ~((~(chn_a_rsci_bcwt | chn_a_rsci_biwt)) | chn_a_rsci_bdwt);
      chn_a_rsci_d_bfwt <= chn_a_rsci_d_mxwt;
    end
  end
  function [15:0] MUX_v_16_2_2;
    input [15:0] input_0;
    input [15:0] input_1;
    input [0:0] sel;
    reg [15:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_16_2_2 = result;
  end
  endfunction
endmodule
// ------------------------------------------------------------------
// Design Unit: HLS_fp16_to_fp17_core_chn_a_rsci_chn_a_wait_ctrl
// ------------------------------------------------------------------
module HLS_fp16_to_fp17_core_chn_a_rsci_chn_a_wait_ctrl (
  nvdla_core_clk, nvdla_core_rstn, chn_a_rsci_oswt, core_wen, chn_a_rsci_iswt0, chn_a_rsci_ld_core_psct,
      core_wten, chn_a_rsci_biwt, chn_a_rsci_bdwt, chn_a_rsci_ld_core_sct, chn_a_rsci_vd
);
  input nvdla_core_clk;
  input nvdla_core_rstn;
  input chn_a_rsci_oswt;
  input core_wen;
  input chn_a_rsci_iswt0;
  input chn_a_rsci_ld_core_psct;
  input core_wten;
  output chn_a_rsci_biwt;
  output chn_a_rsci_bdwt;
  output chn_a_rsci_ld_core_sct;
  input chn_a_rsci_vd;
// Interconnect Declarations
  wire chn_a_rsci_ogwt;
  wire chn_a_rsci_pdswt0;
  reg chn_a_rsci_icwt;
// Interconnect Declarations for Component Instantiations
  assign chn_a_rsci_pdswt0 = (~ core_wten) & chn_a_rsci_iswt0;
  assign chn_a_rsci_biwt = chn_a_rsci_ogwt & chn_a_rsci_vd;
  assign chn_a_rsci_ogwt = chn_a_rsci_pdswt0 | chn_a_rsci_icwt;
  assign chn_a_rsci_bdwt = chn_a_rsci_oswt & core_wen;
  assign chn_a_rsci_ld_core_sct = chn_a_rsci_ld_core_psct & chn_a_rsci_ogwt;
  always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
    if ( ~ nvdla_core_rstn ) begin
      chn_a_rsci_icwt <= 1'b0;
    end
    else begin
      chn_a_rsci_icwt <= ~((~(chn_a_rsci_icwt | chn_a_rsci_pdswt0)) | chn_a_rsci_biwt);
    end
  end
endmodule
// ------------------------------------------------------------------
// Design Unit: HLS_fp16_to_fp17_core_chn_o_rsci
// ------------------------------------------------------------------
module HLS_fp16_to_fp17_core_chn_o_rsci (
  nvdla_core_clk, nvdla_core_rstn, chn_o_rsc_z, chn_o_rsc_vz, chn_o_rsc_lz, chn_o_rsci_oswt,
      core_wen, core_wten, chn_o_rsci_iswt0, chn_o_rsci_bawt, chn_o_rsci_wen_comp,
      chn_o_rsci_ld_core_psct, chn_o_rsci_d
);
  input nvdla_core_clk;
  input nvdla_core_rstn;
  output [16:0] chn_o_rsc_z;
  input chn_o_rsc_vz;
  output chn_o_rsc_lz;
  input chn_o_rsci_oswt;
  input core_wen;
  input core_wten;
  input chn_o_rsci_iswt0;
  output chn_o_rsci_bawt;
  output chn_o_rsci_wen_comp;
  input chn_o_rsci_ld_core_psct;
  input [16:0] chn_o_rsci_d;
// Interconnect Declarations
  wire chn_o_rsci_biwt;
  wire chn_o_rsci_bdwt;
  wire chn_o_rsci_ld_core_sct;
  wire chn_o_rsci_vd;
// Interconnect Declarations for Component Instantiations
  FP16_TO_FP17_mgc_out_stdreg_wait_v1 #(.rscid(32'sd2),
  .width(32'sd17)) chn_o_rsci (
      .ld(chn_o_rsci_ld_core_sct),
      .vd(chn_o_rsci_vd),
      .d(chn_o_rsci_d),
      .lz(chn_o_rsc_lz),
      .vz(chn_o_rsc_vz),
      .z(chn_o_rsc_z)
    );
  HLS_fp16_to_fp17_core_chn_o_rsci_chn_o_wait_ctrl HLS_fp16_to_fp17_core_chn_o_rsci_chn_o_wait_ctrl_inst
      (
      .nvdla_core_clk(nvdla_core_clk),
      .nvdla_core_rstn(nvdla_core_rstn),
      .chn_o_rsci_oswt(chn_o_rsci_oswt),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .chn_o_rsci_iswt0(chn_o_rsci_iswt0),
      .chn_o_rsci_ld_core_psct(chn_o_rsci_ld_core_psct),
      .chn_o_rsci_biwt(chn_o_rsci_biwt),
      .chn_o_rsci_bdwt(chn_o_rsci_bdwt),
      .chn_o_rsci_ld_core_sct(chn_o_rsci_ld_core_sct),
      .chn_o_rsci_vd(chn_o_rsci_vd)
    );
  HLS_fp16_to_fp17_core_chn_o_rsci_chn_o_wait_dp HLS_fp16_to_fp17_core_chn_o_rsci_chn_o_wait_dp_inst
      (
      .nvdla_core_clk(nvdla_core_clk),
      .nvdla_core_rstn(nvdla_core_rstn),
      .chn_o_rsci_oswt(chn_o_rsci_oswt),
      .chn_o_rsci_bawt(chn_o_rsci_bawt),
      .chn_o_rsci_wen_comp(chn_o_rsci_wen_comp),
      .chn_o_rsci_biwt(chn_o_rsci_biwt),
      .chn_o_rsci_bdwt(chn_o_rsci_bdwt)
    );
endmodule
// ------------------------------------------------------------------
// Design Unit: HLS_fp16_to_fp17_core_chn_a_rsci
// ------------------------------------------------------------------
module HLS_fp16_to_fp17_core_chn_a_rsci (
  nvdla_core_clk, nvdla_core_rstn, chn_a_rsc_z, chn_a_rsc_vz, chn_a_rsc_lz, chn_a_rsci_oswt,
      core_wen, chn_a_rsci_iswt0, chn_a_rsci_bawt, chn_a_rsci_wen_comp, chn_a_rsci_ld_core_psct,
      chn_a_rsci_d_mxwt, core_wten
);
  input nvdla_core_clk;
  input nvdla_core_rstn;
  input [15:0] chn_a_rsc_z;
  input chn_a_rsc_vz;
  output chn_a_rsc_lz;
  input chn_a_rsci_oswt;
  input core_wen;
  input chn_a_rsci_iswt0;
  output chn_a_rsci_bawt;
  output chn_a_rsci_wen_comp;
  input chn_a_rsci_ld_core_psct;
  output [15:0] chn_a_rsci_d_mxwt;
  input core_wten;
// Interconnect Declarations
  wire chn_a_rsci_biwt;
  wire chn_a_rsci_bdwt;
  wire chn_a_rsci_ld_core_sct;
  wire chn_a_rsci_vd;
  wire [15:0] chn_a_rsci_d;
// Interconnect Declarations for Component Instantiations
  FP16_TO_FP17_mgc_in_wire_wait_v1 #(.rscid(32'sd1),
  .width(32'sd16)) chn_a_rsci (
      .ld(chn_a_rsci_ld_core_sct),
      .vd(chn_a_rsci_vd),
      .d(chn_a_rsci_d),
      .lz(chn_a_rsc_lz),
      .vz(chn_a_rsc_vz),
      .z(chn_a_rsc_z)
    );
  HLS_fp16_to_fp17_core_chn_a_rsci_chn_a_wait_ctrl HLS_fp16_to_fp17_core_chn_a_rsci_chn_a_wait_ctrl_inst
      (
      .nvdla_core_clk(nvdla_core_clk),
      .nvdla_core_rstn(nvdla_core_rstn),
      .chn_a_rsci_oswt(chn_a_rsci_oswt),
      .core_wen(core_wen),
      .chn_a_rsci_iswt0(chn_a_rsci_iswt0),
      .chn_a_rsci_ld_core_psct(chn_a_rsci_ld_core_psct),
      .core_wten(core_wten),
      .chn_a_rsci_biwt(chn_a_rsci_biwt),
      .chn_a_rsci_bdwt(chn_a_rsci_bdwt),
      .chn_a_rsci_ld_core_sct(chn_a_rsci_ld_core_sct),
      .chn_a_rsci_vd(chn_a_rsci_vd)
    );
  HLS_fp16_to_fp17_core_chn_a_rsci_chn_a_wait_dp HLS_fp16_to_fp17_core_chn_a_rsci_chn_a_wait_dp_inst
      (
      .nvdla_core_clk(nvdla_core_clk),
      .nvdla_core_rstn(nvdla_core_rstn),
      .chn_a_rsci_oswt(chn_a_rsci_oswt),
      .chn_a_rsci_bawt(chn_a_rsci_bawt),
      .chn_a_rsci_wen_comp(chn_a_rsci_wen_comp),
      .chn_a_rsci_d_mxwt(chn_a_rsci_d_mxwt),
      .chn_a_rsci_biwt(chn_a_rsci_biwt),
      .chn_a_rsci_bdwt(chn_a_rsci_bdwt),
      .chn_a_rsci_d(chn_a_rsci_d)
    );
endmodule
// ------------------------------------------------------------------
// Design Unit: HLS_fp16_to_fp17_core
// ------------------------------------------------------------------
module HLS_fp16_to_fp17_core (
  nvdla_core_clk, nvdla_core_rstn, chn_a_rsc_z, chn_a_rsc_vz, chn_a_rsc_lz, chn_o_rsc_z,
      chn_o_rsc_vz, chn_o_rsc_lz, chn_a_rsci_oswt, chn_a_rsci_oswt_unreg, chn_o_rsci_oswt,
      chn_o_rsci_oswt_unreg
);
  input nvdla_core_clk;
  input nvdla_core_rstn;
  input [15:0] chn_a_rsc_z;
  input chn_a_rsc_vz;
  output chn_a_rsc_lz;
  output [16:0] chn_o_rsc_z;
  input chn_o_rsc_vz;
  output chn_o_rsc_lz;
  input chn_a_rsci_oswt;
  output chn_a_rsci_oswt_unreg;
  input chn_o_rsci_oswt;
  output chn_o_rsci_oswt_unreg;
// Interconnect Declarations
  wire core_wen;
  reg chn_a_rsci_iswt0;
  wire chn_a_rsci_bawt;
  wire chn_a_rsci_wen_comp;
  reg chn_a_rsci_ld_core_psct;
  wire [15:0] chn_a_rsci_d_mxwt;
  wire core_wten;
  wire chn_o_rsci_bawt;
  wire chn_o_rsci_wen_comp;
  reg chn_o_rsci_d_16;
  reg [3:0] chn_o_rsci_d_13_10;
  reg [9:0] chn_o_rsci_d_9_0;
  reg chn_o_rsci_d_15;
  reg chn_o_rsci_d_14;
  wire [1:0] fsm_output;
  wire IsDenorm_5U_10U_or_tmp;
  wire and_dcpl_2;
  wire and_dcpl_8;
  wire and_dcpl_9;
  wire and_dcpl_13;
  wire or_dcpl_8;
  wire and_dcpl_19;
  wire and_38_cse;
  wire and_4_mdf;
  wire IsDenorm_5U_10U_land_lpi_1_dfm;
  wire IsInf_5U_10U_land_lpi_1_dfm;
  wire IsInf_5U_10U_IsInf_5U_10U_and_cse_sva;
  wire IsZero_5U_10U_IsZero_5U_10U_nor_cse_sva;
  wire chn_o_and_1_cse;
  reg reg_chn_o_rsci_iswt0_cse;
  reg reg_chn_o_rsci_ld_core_psct_cse;
  wire or_cse;
  wire and_6_cse;
  wire chn_o_rsci_d_9_0_mx0c1;
  wire FpExpoWidthInc_5U_6U_10U_1U_1U_FpExpoWidthInc_5U_6U_10U_1U_1U_nor_1_cse;
  wire [9:0] FpExpoWidthInc_5U_6U_10U_1U_1U_if_1_if_lshift_itm;
  wire chn_a_rsci_ld_core_psct_mx0c0;
  wire [4:0] FpExpoWidthInc_5U_6U_10U_1U_1U_if_1_if_acc_psp_sva;
  wire [5:0] nl_FpExpoWidthInc_5U_6U_10U_1U_1U_if_1_if_acc_psp_sva;
  wire IsNaN_5U_10U_land_lpi_1_dfm;
  wire [3:0] libraries_leading_sign_10_0_9ac8f64992538a762a5a05a903e0d3de3d5a_1;
  wire[0:0] iExpoWidth_oExpoWidth_prb;
  wire[0:0] FpExpoWidthInc_5U_6U_10U_1U_1U_if_1_mux_2_nl;
  wire[0:0] FpExpoWidthInc_5U_6U_10U_1U_1U_FpExpoWidthInc_5U_6U_10U_1U_1U_FpExpoWidthInc_5U_6U_10U_1U_1U_nor_nl;
  wire[9:0] FpExpoWidthInc_5U_6U_10U_1U_1U_FpExpoWidthInc_5U_6U_10U_1U_1U_or_1_nl;
  wire[0:0] nand_8_nl;
  wire[3:0] FpExpoWidthInc_5U_6U_10U_1U_1U_FpExpoWidthInc_5U_6U_10U_1U_1U_mux1h_nl;
// Interconnect Declarations for Component Instantiations
  wire [8:0] nl_FpExpoWidthInc_5U_6U_10U_1U_1U_if_1_if_lshift_rg_a;
  assign nl_FpExpoWidthInc_5U_6U_10U_1U_1U_if_1_if_lshift_rg_a = chn_a_rsci_d_mxwt[8:0];
  wire [5:0] nl_FpExpoWidthInc_5U_6U_10U_1U_1U_if_1_if_lshift_rg_s;
  assign nl_FpExpoWidthInc_5U_6U_10U_1U_1U_if_1_if_lshift_rg_s = conv_u2u_4_5(libraries_leading_sign_10_0_9ac8f64992538a762a5a05a903e0d3de3d5a_1)
      + 5'b1;
  wire [9:0] nl_leading_sign_10_0_rg_mantissa;
  assign nl_leading_sign_10_0_rg_mantissa = chn_a_rsci_d_mxwt[9:0];
  wire [16:0] nl_HLS_fp16_to_fp17_core_chn_o_rsci_inst_chn_o_rsci_d;
  assign nl_HLS_fp16_to_fp17_core_chn_o_rsci_inst_chn_o_rsci_d = {chn_o_rsci_d_16
      , chn_o_rsci_d_15 , chn_o_rsci_d_14 , chn_o_rsci_d_13_10 , chn_o_rsci_d_9_0};
  FP16_TO_FP17_mgc_shift_l_v4 #(.width_a(32'sd9),
  .signd_a(32'sd1),
  .width_s(32'sd5),
  .width_z(32'sd10)) FpExpoWidthInc_5U_6U_10U_1U_1U_if_1_if_lshift_rg (
      .a(nl_FpExpoWidthInc_5U_6U_10U_1U_1U_if_1_if_lshift_rg_a[8:0]),
      .s(nl_FpExpoWidthInc_5U_6U_10U_1U_1U_if_1_if_lshift_rg_s[4:0]),
      .z(FpExpoWidthInc_5U_6U_10U_1U_1U_if_1_if_lshift_itm)
    );
  FP16_TO_FP17_leading_sign_10_0 leading_sign_10_0_rg (
      .mantissa(nl_leading_sign_10_0_rg_mantissa[9:0]),
      .rtn(libraries_leading_sign_10_0_9ac8f64992538a762a5a05a903e0d3de3d5a_1)
    );
  HLS_fp16_to_fp17_core_chn_a_rsci HLS_fp16_to_fp17_core_chn_a_rsci_inst (
      .nvdla_core_clk(nvdla_core_clk),
      .nvdla_core_rstn(nvdla_core_rstn),
      .chn_a_rsc_z(chn_a_rsc_z),
      .chn_a_rsc_vz(chn_a_rsc_vz),
      .chn_a_rsc_lz(chn_a_rsc_lz),
      .chn_a_rsci_oswt(chn_a_rsci_oswt),
      .core_wen(core_wen),
      .chn_a_rsci_iswt0(chn_a_rsci_iswt0),
      .chn_a_rsci_bawt(chn_a_rsci_bawt),
      .chn_a_rsci_wen_comp(chn_a_rsci_wen_comp),
      .chn_a_rsci_ld_core_psct(chn_a_rsci_ld_core_psct),
      .chn_a_rsci_d_mxwt(chn_a_rsci_d_mxwt),
      .core_wten(core_wten)
    );
  HLS_fp16_to_fp17_core_chn_o_rsci HLS_fp16_to_fp17_core_chn_o_rsci_inst (
      .nvdla_core_clk(nvdla_core_clk),
      .nvdla_core_rstn(nvdla_core_rstn),
      .chn_o_rsc_z(chn_o_rsc_z),
      .chn_o_rsc_vz(chn_o_rsc_vz),
      .chn_o_rsc_lz(chn_o_rsc_lz),
      .chn_o_rsci_oswt(chn_o_rsci_oswt),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .chn_o_rsci_iswt0(reg_chn_o_rsci_iswt0_cse),
      .chn_o_rsci_bawt(chn_o_rsci_bawt),
      .chn_o_rsci_wen_comp(chn_o_rsci_wen_comp),
      .chn_o_rsci_ld_core_psct(reg_chn_o_rsci_ld_core_psct_cse),
      .chn_o_rsci_d(nl_HLS_fp16_to_fp17_core_chn_o_rsci_inst_chn_o_rsci_d[16:0])
    );
  HLS_fp16_to_fp17_core_staller HLS_fp16_to_fp17_core_staller_inst (
      .nvdla_core_clk(nvdla_core_clk),
      .nvdla_core_rstn(nvdla_core_rstn),
      .core_wen(core_wen),
      .chn_a_rsci_wen_comp(chn_a_rsci_wen_comp),
      .core_wten(core_wten),
      .chn_o_rsci_wen_comp(chn_o_rsci_wen_comp)
    );
  HLS_fp16_to_fp17_core_core_fsm HLS_fp16_to_fp17_core_core_fsm_inst (
      .nvdla_core_clk(nvdla_core_clk),
      .nvdla_core_rstn(nvdla_core_rstn),
      .core_wen(core_wen),
      .fsm_output(fsm_output)
    );
  assign and_6_cse = and_4_mdf & (fsm_output[1]);
  assign iExpoWidth_oExpoWidth_prb = MUX_s_1_2_2((MUX1HOT_s_1_1_2(1'b1, fsm_output[0])),
      (MUX1HOT_s_1_1_2(1'b1, and_6_cse)), fsm_output[1]);
// assert(iExpoWidth <= oExpoWidth) - ../include/nvdla_float.h: line 477
// PSL HLS_fp16_to_fp17_core_nvdla_float_h_ln477_assert_iExpoWidth_le_oExpoWidth : assert { iExpoWidth_oExpoWidth_prb } @rose(nvdla_core_clk);
  assign chn_o_and_1_cse = core_wen & (~(and_38_cse | (fsm_output[0])));
  assign nl_FpExpoWidthInc_5U_6U_10U_1U_1U_if_1_if_acc_psp_sva = ({1'b1 , (~ libraries_leading_sign_10_0_9ac8f64992538a762a5a05a903e0d3de3d5a_1)})
      + 5'b10001;
  assign FpExpoWidthInc_5U_6U_10U_1U_1U_if_1_if_acc_psp_sva = nl_FpExpoWidthInc_5U_6U_10U_1U_1U_if_1_if_acc_psp_sva[4:0];
  assign FpExpoWidthInc_5U_6U_10U_1U_1U_FpExpoWidthInc_5U_6U_10U_1U_1U_nor_1_cse
      = ~(IsDenorm_5U_10U_land_lpi_1_dfm | IsInf_5U_10U_land_lpi_1_dfm);
  assign IsInf_5U_10U_land_lpi_1_dfm = ~((chn_a_rsci_d_mxwt[9:0]!=10'b0000000000)
      | (~ IsInf_5U_10U_IsInf_5U_10U_and_cse_sva));
  assign IsNaN_5U_10U_land_lpi_1_dfm = IsDenorm_5U_10U_or_tmp & IsInf_5U_10U_IsInf_5U_10U_and_cse_sva;
  assign IsZero_5U_10U_IsZero_5U_10U_nor_cse_sva = ~((chn_a_rsci_d_mxwt[14:10]!=5'b00000));
  assign IsDenorm_5U_10U_land_lpi_1_dfm = IsDenorm_5U_10U_or_tmp & IsZero_5U_10U_IsZero_5U_10U_nor_cse_sva;
  assign IsDenorm_5U_10U_or_tmp = (chn_a_rsci_d_mxwt[9:0]!=10'b0000000000);
  assign IsInf_5U_10U_IsInf_5U_10U_and_cse_sva = (chn_a_rsci_d_mxwt[14:10]==5'b11111);
  assign or_cse = chn_o_rsci_bawt | (~ reg_chn_o_rsci_ld_core_psct_cse);
  assign and_4_mdf = chn_a_rsci_bawt & or_cse;
  assign and_dcpl_2 = chn_o_rsci_bawt & reg_chn_o_rsci_ld_core_psct_cse;
  assign and_dcpl_8 = (chn_a_rsci_d_mxwt[14:12]==3'b111) & IsDenorm_5U_10U_or_tmp;
  assign and_dcpl_9 = (chn_a_rsci_d_mxwt[11:10]==2'b11);
  assign and_dcpl_13 = and_dcpl_2 & chn_a_rsci_bawt;
  assign or_dcpl_8 = (chn_a_rsci_d_mxwt[12:10]!=3'b111) | (~((chn_a_rsci_d_mxwt[14:13]==2'b11)
      & IsDenorm_5U_10U_or_tmp));
  assign and_dcpl_19 = and_dcpl_2 & (~ chn_a_rsci_bawt);
  assign and_38_cse = ~((~((~ chn_o_rsci_bawt) & reg_chn_o_rsci_ld_core_psct_cse))
      & chn_a_rsci_bawt);
  assign chn_a_rsci_ld_core_psct_mx0c0 = and_4_mdf | (fsm_output[0]);
  assign chn_o_rsci_d_9_0_mx0c1 = (or_dcpl_8 & or_cse & chn_a_rsci_bawt & (fsm_output[1]))
      | (or_dcpl_8 & and_dcpl_13);
  assign chn_a_rsci_oswt_unreg = and_6_cse;
  assign chn_o_rsci_oswt_unreg = and_dcpl_2;
  always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
    if ( ~ nvdla_core_rstn ) begin
      chn_a_rsci_iswt0 <= 1'b0;
      reg_chn_o_rsci_iswt0_cse <= 1'b0;
    end
    else if ( core_wen ) begin
      chn_a_rsci_iswt0 <= ~((~ and_4_mdf) & (fsm_output[1]));
      reg_chn_o_rsci_iswt0_cse <= and_6_cse;
    end
  end
  always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
    if ( ~ nvdla_core_rstn ) begin
      chn_a_rsci_ld_core_psct <= 1'b0;
    end
    else if ( core_wen & chn_a_rsci_ld_core_psct_mx0c0 ) begin
      chn_a_rsci_ld_core_psct <= chn_a_rsci_ld_core_psct_mx0c0;
    end
  end
  always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
    if ( ~ nvdla_core_rstn ) begin
      chn_o_rsci_d_14 <= 1'b0;
    end
    else if ( core_wen & (~(and_38_cse | ((~(chn_o_rsci_bawt & reg_chn_o_rsci_ld_core_psct_cse
        & chn_a_rsci_bawt)) & (fsm_output[0])))) ) begin
      chn_o_rsci_d_14 <= (FpExpoWidthInc_5U_6U_10U_1U_1U_if_1_mux_2_nl) | IsInf_5U_10U_land_lpi_1_dfm
          | IsNaN_5U_10U_land_lpi_1_dfm;
    end
  end
  always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
    if ( ~ nvdla_core_rstn ) begin
      chn_o_rsci_d_15 <= 1'b0;
      chn_o_rsci_d_13_10 <= 4'b0;
      chn_o_rsci_d_16 <= 1'b0;
    end
    else if ( chn_o_and_1_cse ) begin
      chn_o_rsci_d_15 <= chn_a_rsci_d_mxwt[14];
      chn_o_rsci_d_13_10 <= MUX_v_4_2_2((FpExpoWidthInc_5U_6U_10U_1U_1U_FpExpoWidthInc_5U_6U_10U_1U_1U_mux1h_nl),
          4'b1111, IsNaN_5U_10U_land_lpi_1_dfm);
      chn_o_rsci_d_16 <= chn_a_rsci_d_mxwt[15];
    end
  end
  always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
    if ( ~ nvdla_core_rstn ) begin
      chn_o_rsci_d_9_0 <= 10'b0;
    end
    else if ( core_wen & ((and_4_mdf & and_dcpl_9 & and_dcpl_8 & (fsm_output[1]))
        | (and_dcpl_13 & and_dcpl_9 & and_dcpl_8) | chn_o_rsci_d_9_0_mx0c1) ) begin
      chn_o_rsci_d_9_0 <= MUX_v_10_2_2((FpExpoWidthInc_5U_6U_10U_1U_1U_FpExpoWidthInc_5U_6U_10U_1U_1U_or_1_nl),
          (chn_a_rsci_d_mxwt[9:0]), nand_8_nl);
    end
  end
  always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
    if ( ~ nvdla_core_rstn ) begin
      reg_chn_o_rsci_ld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & (and_6_cse | and_dcpl_19) ) begin
      reg_chn_o_rsci_ld_core_psct_cse <= ~ and_dcpl_19;
    end
  end
  assign FpExpoWidthInc_5U_6U_10U_1U_1U_FpExpoWidthInc_5U_6U_10U_1U_1U_FpExpoWidthInc_5U_6U_10U_1U_1U_nor_nl
      = ~((chn_a_rsci_d_mxwt[14]) | (~((chn_a_rsci_d_mxwt[9:0]!=10'b0000000000) |
      (~ IsZero_5U_10U_IsZero_5U_10U_nor_cse_sva))));
  assign FpExpoWidthInc_5U_6U_10U_1U_1U_if_1_mux_2_nl = MUX_s_1_2_2((FpExpoWidthInc_5U_6U_10U_1U_1U_FpExpoWidthInc_5U_6U_10U_1U_1U_FpExpoWidthInc_5U_6U_10U_1U_1U_nor_nl),
      (FpExpoWidthInc_5U_6U_10U_1U_1U_if_1_if_acc_psp_sva[4]), IsDenorm_5U_10U_land_lpi_1_dfm);
  assign FpExpoWidthInc_5U_6U_10U_1U_1U_FpExpoWidthInc_5U_6U_10U_1U_1U_mux1h_nl =
      MUX1HOT_v_4_3_2((chn_a_rsci_d_mxwt[13:10]), (FpExpoWidthInc_5U_6U_10U_1U_1U_if_1_if_acc_psp_sva[3:0]),
      4'b1110, {FpExpoWidthInc_5U_6U_10U_1U_1U_FpExpoWidthInc_5U_6U_10U_1U_1U_nor_1_cse
      , IsDenorm_5U_10U_land_lpi_1_dfm , IsInf_5U_10U_land_lpi_1_dfm});
  assign FpExpoWidthInc_5U_6U_10U_1U_1U_FpExpoWidthInc_5U_6U_10U_1U_1U_or_1_nl =
      MUX_v_10_2_2(FpExpoWidthInc_5U_6U_10U_1U_1U_if_1_if_lshift_itm, 10'b1111111111,
      IsInf_5U_10U_land_lpi_1_dfm);
  assign nand_8_nl = ~((~ FpExpoWidthInc_5U_6U_10U_1U_1U_FpExpoWidthInc_5U_6U_10U_1U_1U_nor_1_cse)
      & chn_o_rsci_d_9_0_mx0c1);
  function [0:0] MUX1HOT_s_1_1_2;
    input [0:0] input_0;
    input [0:0] sel;
    reg [0:0] result;
  begin
    result = input_0 & {1{sel[0]}};
    MUX1HOT_s_1_1_2 = result;
  end
  endfunction
  function [3:0] MUX1HOT_v_4_3_2;
    input [3:0] input_2;
    input [3:0] input_1;
    input [3:0] input_0;
    input [2:0] sel;
    reg [3:0] result;
  begin
    result = input_0 & {4{sel[0]}};
    result = result | ( input_1 & {4{sel[1]}});
    result = result | ( input_2 & {4{sel[2]}});
    MUX1HOT_v_4_3_2 = result;
  end
  endfunction
  function [0:0] MUX_s_1_2_2;
    input [0:0] input_0;
    input [0:0] input_1;
    input [0:0] sel;
    reg [0:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction
  function [9:0] MUX_v_10_2_2;
    input [9:0] input_0;
    input [9:0] input_1;
    input [0:0] sel;
    reg [9:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_10_2_2 = result;
  end
  endfunction
  function [3:0] MUX_v_4_2_2;
    input [3:0] input_0;
    input [3:0] input_1;
    input [0:0] sel;
    reg [3:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_4_2_2 = result;
  end
  endfunction
  function [4:0] conv_u2u_4_5 ;
    input [3:0] vector ;
  begin
    conv_u2u_4_5 = {1'b0, vector};
  end
  endfunction
endmodule
// ------------------------------------------------------------------
// Design Unit: HLS_fp16_to_fp17
// ------------------------------------------------------------------
module HLS_fp16_to_fp17 (
  nvdla_core_clk, nvdla_core_rstn, chn_a_rsc_z, chn_a_rsc_vz, chn_a_rsc_lz, chn_o_rsc_z,
      chn_o_rsc_vz, chn_o_rsc_lz
);
  input nvdla_core_clk;
  input nvdla_core_rstn;
  input [15:0] chn_a_rsc_z;
  input chn_a_rsc_vz;
  output chn_a_rsc_lz;
  output [16:0] chn_o_rsc_z;
  input chn_o_rsc_vz;
  output chn_o_rsc_lz;
// Interconnect Declarations
  wire chn_a_rsci_oswt;
  wire chn_a_rsci_oswt_unreg;
  wire chn_o_rsci_oswt;
  wire chn_o_rsci_oswt_unreg;
// Interconnect Declarations for Component Instantiations
  FP16_TO_FP17_chn_a_rsci_unreg chn_a_rsci_unreg_inst (
      .in_0(chn_a_rsci_oswt_unreg),
      .outsig(chn_a_rsci_oswt)
    );
  FP16_TO_FP17_chn_o_rsci_unreg chn_o_rsci_unreg_inst (
      .in_0(chn_o_rsci_oswt_unreg),
      .outsig(chn_o_rsci_oswt)
    );
  HLS_fp16_to_fp17_core HLS_fp16_to_fp17_core_inst (
      .nvdla_core_clk(nvdla_core_clk),
      .nvdla_core_rstn(nvdla_core_rstn),
      .chn_a_rsc_z(chn_a_rsc_z),
      .chn_a_rsc_vz(chn_a_rsc_vz),
      .chn_a_rsc_lz(chn_a_rsc_lz),
      .chn_o_rsc_z(chn_o_rsc_z),
      .chn_o_rsc_vz(chn_o_rsc_vz),
      .chn_o_rsc_lz(chn_o_rsc_lz),
      .chn_a_rsci_oswt(chn_a_rsci_oswt),
      .chn_a_rsci_oswt_unreg(chn_a_rsci_oswt_unreg),
      .chn_o_rsci_oswt(chn_o_rsci_oswt),
      .chn_o_rsci_oswt_unreg(chn_o_rsci_oswt_unreg)
    );
endmodule
