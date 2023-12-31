// ================================================================
// NVDLA Open Source Project
// 
// Copyright(c) 2016 - 2017 NVIDIA Corporation.  Licensed under the
// NVDLA Open Hardware License; Check "LICENSE" which comes with 
// this distribution for more information.
// ================================================================

// File Name: MUX2HDD2.v
`timescale 10ps/1ps
module  MUX2HDD2 (
	 I0
	,I1
	,S
	,Z
	);

input	 I0 ;
input	 I1 ;
input	 S ;
output	 Z ;

assign Z = S ? I1 : I0;

endmodule

