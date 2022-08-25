///////////////////////////////////////////
// dtim.sv
//
// Written: Ross Thompson ross1728@gmail.com January 30, 2022
// Modified: 
//
// Purpose: simple memory with bus or cache.
// A component of the Wally configurable RISC-V project.
// 
// Copyright (C) 2021 Harvey Mudd College & Oklahoma State University
//
// MIT LICENSE
// Permission is hereby granted, free of charge, to any person obtaining a copy of this 
// software and associated documentation files (the "Software"), to deal in the Software 
// without restriction, including without limitation the rights to use, copy, modify, merge, 
// publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons 
// to whom the Software is furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all copies or 
//   substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
//   INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
//   PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS 
//   BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
//   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE 
//   OR OTHER DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////////////////////

`include "wally-config.vh"

module dtim(
  input logic               clk, reset,
  input logic               CPUBusy,
  input logic [1:0]         LSURWM,
  input logic [`XLEN-1:0]   IEUAdrM,
  input logic [`XLEN-1:0]   IEUAdrE,
  input logic               TrapM, 
  input logic [`LLEN-1:0]   WriteDataM,
  input logic [`LLEN/8-1:0] ByteMaskM,
  input logic               Cacheable,
  output logic [`LLEN-1:0]  ReadDataWordM,
  output logic              BusStall,
  output logic              LSUBusWrite,
  output logic              LSUBusRead,
  output logic              BusCommittedM,
  output logic              DCacheStallM,
  output logic              DCacheCommittedM,
  output logic              DCacheMiss,
  output logic              DCacheAccess
);

  logic we;
 
//  localparam ADDR_WDITH = $clog2(`TIM_RAM_RANGE/8);  // *** replace with tihs when  defined
  localparam ADDR_WDITH = $clog2(`UNCORE_RAM_RANGE/8); // *** this is the wrong size
  localparam OFFSET = $clog2(`LLEN/8);

  assign we = LSURWM[0] & Cacheable & ~TrapM;  // have to ignore write if Trap.

  bram1p1rw #(`LLEN/8, 8, ADDR_WDITH) 
    ram(.clk, .we, .bwe(ByteMaskM), .addr(IEUAdrE[ADDR_WDITH+OFFSET-1:OFFSET]), .dout(ReadDataWordM), .din(WriteDataM));

  // since we have a local memory the bus connections are all disabled.
  // There are no peripherals supported.
  assign {BusStall, LSUBusWrite, LSUBusRead, BusCommittedM} = '0;   
  assign {DCacheStallM, DCacheCommittedM} = '0;
  assign {DCacheMiss, DCacheAccess} = '0;

endmodule  
  
