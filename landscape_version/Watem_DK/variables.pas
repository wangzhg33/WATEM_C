unit variables;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, RData, GData, surface;
Type
  TIntegerFileFormat=(INT2S,INT4S);

  Rraster_3D = array of Rraster;
const
  PDB : double = 0.0112372; //  Pee Dee Belemnite (PDB) standard of 13C : 12C
var
  //Raster filenames
  c14filename,c13filename,Cs137filename: String;
  dtmfilename,outfilename,prcfilename, RKCPfilename, ktcfilename, ktilfilename: String;
  outfilename_temp : String;
  Working_Dir : string;

  WATEREROS     : RRaster;                      //water erosion per year (unit: m)
  TILEROS       : RRaster;                      //tillage erosion per year (unit: m)
  RKCP          : RRaster;                      // RUSLE R*K*C*P parameters
  ktc           : GRaster;                      // transport capacity constant kg/m
  W_Export      : RRaster;                      // export per cell (unit : m)

  A12_EROS      : RRaster;                     //water active C erosion per year (unit: m * %)
  S12_EROS      : RRaster;
  P12_EROS      : RRaster;

  A13_EROS      : RRaster;                     //water active C erosion per year (unit: m * %)
  S13_EROS      : RRaster;
  P13_EROS      : RRaster;

  A14_EROS      : RRaster;                     //water active C erosion per year (unit: m * %)
  S14_EROS      : RRaster;
  P14_EROS      : RRaster;

  Clay_EROS      : RRaster;                     //water active C erosion per year (unit: m * %)
  Silt_EROS      : RRaster;
  Sand_EROS      : RRaster;
  Rock_EROS      : RRaster;
  Cs137_EROS     : RRaster;
                                                // Unit kg/m2
  C_STOCK        : RRaster;
  C_STOCK_equili : RRaster;
  CS137_ACTIVITY : RRaster;
  PRC : GRaster;
  DTM,Slope,Aspect,Uparea,LS: Rraster;         // note uparea is used for temporary maps after uparea calculation!

  BD, TFCA, KTIL, PDEPTH : integer;            // BD kg/m3 TFCA (0-100) KTIL kg/m Pdepth in cm (!)

  MC_RKCP, MC_ktc : integer;                    // # of Monte carlo runs for rkcp and ktc maps

  Cal_Frac : boolean;                           // set to "1 or 0", do recursive calculation for fractional contribution of each gridcell to export, CPU/time intensive!

  McCool_factor : real;                         // default = 1, you can set this to 0.5 for low contribution of rill erosion,, or 2 for high contribution of rill

  Write_map : boolean;                          // set to "1 or 0", default = TRUE, write spatial output if true, set to false for no map output
  Write_txt : boolean;

  Write_detail_Exp : boolean;                   // set to "1 or 0", default = TRUE, write spatial output if true, set to false for no map output

  Parcel_File_Format : TIntegerFileFormat;      // set to "INT2S" or "INT4S", default = INT2S, standard Idrisi smallint format INT2S, set to "INT4S" for INT4S format, ie integer

  ra : Troutingalgorithm;                       //type of routing  sdra= steepest descent mfra=multiple flow

erosion_start_year : integer;
erosion_end_year   : integer;

time_equilibrium : integer;

time_step      : integer;
depth_interval : integer; // unit cm
depth          : integer; // unit cm
tillage_depth  : integer;  // unit cm
layer_num      : integer;
deltaC13_ini_top  : single;  // unit per mille
deltaC13_ini_bot  : single;  // unit per mille
DeltaC14_ini_top  : single;  // unit per mille
DeltaC14_ini_bot  : single;  // unit per mille
k1             : single;
k2             : single;
k3             : single;
hAS            : single;
hAP            : single;
hSP            : single;
C13_discri     : single;
C14_discri     : single;
deltaC13_input_default : single;
deltaC14_input_default : single;
Cs137_input_default    : single;

r0             : single;
C_input        : single;  // Mg C ha-1 yr-1
C_input2       : single;  // Mg C ha-1 yr-1
r_exp          : single;   // unit m-1
i_exp          : single;   // unit m-1

Sand_ini_top   : single;   // unit %
Silt_ini_top   : single;   // unit %
Clay_ini_top   : single;   // unit %
Sand_ini_bot   : single;   // unit %
Silt_ini_bot   : single;   // unit %
Clay_ini_bot   : single;   // unit %


A12, S12, P12: Rraster_3D;
A13, S13, P13 : Rraster_3D;
A14, S14, P14 : Rraster_3D;
SAND, SILT, CLAY, ROCK : Rraster_3D;
CS137: Rraster_3D;

unstable: Boolean;
K0,v0,kfzp,vfzp:single;

//ER_ero,ER_depo: single;

a_erero,b_erero,b_erdepo: single;


Procedure Allocate_Memory;
Procedure Release_Memory;


implementation

Procedure Allocate_Memory;
var
  i: integer;
begin
// Create procedure to read in maps & allocate memory to global maps

// Assign internal & global 2D maps
SetDynamicRData(LS);

//SetDynamicRData(SLOPE);
//SetDynamicRData(ASPECT);

SetDynamicRData(RKCP);
SetDynamicGData(ktc);
SetDynamicRData(W_Export);  SetZeroR(W_Export);

SetDynamicRData(WATEREROS);
SetDynamicRData(TILEROS);

SetDynamicRData(A12_EROS);
SetDynamicRData(S12_EROS);
SetDynamicRData(P12_EROS);
SetDynamicRData(A13_EROS);
SetDynamicRData(S13_EROS);
SetDynamicRData(P13_EROS);
SetDynamicRData(A14_EROS);
SetDynamicRData(S14_EROS);
SetDynamicRData(P14_EROS);
SetDynamicRData(Clay_EROS);
SetDynamicRData(Silt_EROS);
SetDynamicRData(Sand_EROS);
SetDynamicRData(Rock_EROS);
SetDynamicRData(Cs137_EROS);
SetDynamicRData(C_STOCK);
SetDynamicRData(C_STOCK_equili);
SetDynamicRData(CS137_ACTIVITY);

Setlength(A12,layer_num+2);
Setlength(S12,layer_num+2);
Setlength(P12,layer_num+2);
Setlength(A13,layer_num+2);
Setlength(S13,layer_num+2);
Setlength(P13,layer_num+2);
Setlength(A14,layer_num+2);
Setlength(S14,layer_num+2);
Setlength(P14,layer_num+2);

Setlength(CLAY,layer_num+2);
Setlength(SILT,layer_num+2);
Setlength(SAND,layer_num+2);
Setlength(ROCK,layer_num+2);
Setlength(CS137,layer_num+2);

for i:=0 to layer_num+1 do
begin
    SetDynamicRdata(A12[i]);
    SetDynamicRdata(S12[i]);
    SetDynamicRdata(P12[i]);
    SetDynamicRdata(A13[i]);
    SetDynamicRdata(S13[i]);
    SetDynamicRdata(P13[i]);
    SetDynamicRdata(A14[i]);
    SetDynamicRdata(S14[i]);
    SetDynamicRdata(P14[i]);
    SetDynamicRdata(CLAY[i]);
    SetDynamicRdata(SILT[i]);
    SetDynamicRdata(SAND[i]);
    SetDynamicRdata(ROCK[i]);
    SetDynamicRdata(CS137[i]);
end;

end;

Procedure Release_Memory;

var
  i: integer;
begin
// Release memory for input rasters
DisposeDynamicRdata(DTM);
DisposeDynamicGdata(PRC);

// Release internal 2D rasters maps

DisposeDynamicRdata(LS);
//DisposeDynamicRdata(SLOPE);
//DisposeDynamicRdata(ASPECT);
DisposeDynamicRdata(RKCP);
DisposeDynamicGdata(ktc);
DisposeDynamicRdata(W_Export);

DisposeDynamicRdata(WATEREROS);
DisposeDynamicRdata(TILEROS);

DisposeDynamicRdata(A12_EROS);
DisposeDynamicRdata(S12_EROS);
DisposeDynamicRdata(P12_EROS);
DisposeDynamicRdata(A13_EROS);
DisposeDynamicRdata(S13_EROS);
DisposeDynamicRdata(P13_EROS);
DisposeDynamicRdata(A13_EROS);
DisposeDynamicRdata(S13_EROS);
DisposeDynamicRdata(P13_EROS);
DisposeDynamicRdata(Clay_EROS);
DisposeDynamicRdata(Silt_EROS);
DisposeDynamicRdata(Sand_EROS);
DisposeDynamicRdata(Rock_EROS);
DisposeDynamicRdata(Cs137_EROS);
DisposeDynamicRdata(C_STOCK);
DisposeDynamicRdata(C_STOCK_equili);
DisposeDynamicRdata(CS137_ACTIVITY);

for i:=0 to layer_num+1 do
begin
    DisposeDynamicRdata(A12[i]);
    DisposeDynamicRdata(S12[i]);
    DisposeDynamicRdata(P12[i]);
    DisposeDynamicRdata(A13[i]);
    DisposeDynamicRdata(S13[i]);
    DisposeDynamicRdata(P13[i]);
    DisposeDynamicRdata(A14[i]);
    DisposeDynamicRdata(S14[i]);
    DisposeDynamicRdata(P14[i]);
    DisposeDynamicRdata(CLAY[i]);
    DisposeDynamicRdata(SILT[i]);
    DisposeDynamicRdata(SAND[i]);
    DisposeDynamicRdata(ROCK[i]);
    DisposeDynamicRdata(CS137[i]);
end;


ROW:=NIL;
COLUMN:=NIL;

end;

end.

