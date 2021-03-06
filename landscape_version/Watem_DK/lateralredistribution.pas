unit LateralRedistribution;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, RData, GData, surface, variables, Idrisi_Proc, CarbonCycling;

procedure Water(var WATEREROS, A12_eros, S12_eros, P12_eros,A13_eros, S13_eros, P13_eros,
  A14_eros, S14_eros, P14_eros,Clay_eros, Silt_eros, Sand_eros,Rock_eros,Cs137_eros: RRaster;
  LS, RKCP: RRaster; ktc : GRaster; TFCA:integer; ra :TRoutingalgorithm; BD: double);
implementation

var

SEDI_OUT: RRaster;
SEDI_IN: RRaster;

CLAY_OUT:RRaster;
CLAY_IN:Rraster;
SILT_OUT:RRaster;
SILT_IN:Rraster;
SAND_OUT:RRaster;
SAND_IN:Rraster;
ROCK_OUT:RRaster;
ROCK_IN:Rraster;

CS137_OUT:RRaster;
CS137_IN:RRaster;

A12_OUT: RRaster;
A12_IN: RRaster;
S12_OUT: RRaster;
S12_IN: RRaster;
P12_OUT: RRaster;
P12_IN: RRaster;

A13_OUT: RRaster;
A13_IN: RRaster;
S13_OUT: RRaster;
S13_IN: RRaster;
P13_OUT: RRaster;
P13_IN: RRaster;

A14_OUT: RRaster;
A14_IN: RRaster;
S14_OUT: RRaster;
S14_IN: RRaster;
P14_OUT: RRaster;
P14_IN: RRaster;


Waterero: double;
Clay_ero: double;
Silt_ero: double;
Sand_ero: double;
Rock_ero: double;
A12_ero: double;
P12_ero: double;
S12_ero: double;
A13_ero: double;
P13_ero: double;
S13_ero: double;
A14_ero: double;
P14_ero: double;
S14_ero: double;
Cs137_ero: double;

Procedure Checkerosionheight(i,j : integer; A12_top, S12_top,P12_top,A13_top, S13_top,P13_top,
           A14_top, S14_top,P14_top,Clay_top,Silt_top,Sand_top,Rock_top,Cs137_top: single;
            var watereros, SEDI_OUT, A12_out, S12_out, P12_out,A13_out, S13_out, P13_out,
            A14_out, S14_out, P14_out,Clay_out,Silt_out,Sand_out,Rock_out,Cs137_out:single; DTM : RRaster);
var
extremum, area:double;
k,l : integer;
ER_ero,ER_depo: single;
begin

area:=sqr(RES) ;

If watereros<0.0 then             //erosion
begin
extremum:=1E45;
for k:=-1 to 1 do                              //search for lowest neighbour
 for l:=-1 to 1 do
  begin
   IF (k=0)and(l=0) then continue;
   IF DTM[i+k,j+l]<extremum then extremum:=DTM[i+k,j+l];
  end;
If extremum > (DTM[i,j]+watereros) then
 begin
  watereros:=extremum-DTM[i,j];
  ER_ero:=ER_erosion(watereros);
  ER_depo:=ER_deposition(watereros);

  SEDI_OUT:=SEDI_IN[i,j]-(watereros*area);
  CLAY_OUT:=CLAY_IN[i,j]-(watereros*area*Clay_top);
  SILT_OUT:=SILT_IN[i,j]-(watereros*area*Silt_top);
  SAND_OUT:=SAND_IN[i,j]-(watereros*area*Sand_top);
  ROCK_OUT:=ROCK_IN[i,j]-(watereros*area*Rock_top);

  CS137_OUT:=CS137_IN[i,j]-(watereros*area*Cs137_top*ER_ero);

  A12_out:=A12_in[i,j]-(watereros*area*A12_top*ER_ero);
  S12_out:=S12_in[i,j]-(watereros*area*S12_top*ER_ero);
  P12_out:=P12_in[i,j]-(watereros*area*P12_top*ER_ero);
  A13_out:=A13_in[i,j]-(watereros*area*A13_top*ER_ero);
  S13_out:=S13_in[i,j]-(watereros*area*S13_top*ER_ero);
  P13_out:=P13_in[i,j]-(watereros*area*P13_top*ER_ero);
  A14_out:=A14_in[i,j]-(watereros*area*A14_top*ER_ero);
  S14_out:=S14_in[i,j]-(watereros*area*S14_top*ER_ero);
  P14_out:=P14_in[i,j]-(watereros*area*P14_top*ER_ero);

 end;
end
else                           //sedimentation
begin
 If watereros>0.0 then
 begin
  extremum:=1E45;
  for k:=-1 to 1 do
   for l:=-1 to 1 do
    begin
      IF ((k=0)and(l=0))or (abs(k)+abs(l)<2) then continue;
      IF DTM[i+k,j+l]>extremum then extremum:=DTM[i+k,j+l];
    end;
  If extremum < (DTM[i,j]+watereros) then
   begin
    watereros:=extremum-DTM[i,j];
    SEDI_OUT:=SEDI_IN[i,j]-(watereros*area);
    CLAY_OUT:=CLAY_IN[i,j]/SEDI_IN[i,j]*(SEDI_IN[i,j]-(watereros*area));
    SILT_OUT:=SILT_IN[i,j]/SEDI_IN[i,j]*(SEDI_IN[i,j]-(watereros*area));
    SAND_OUT:=SAND_IN[i,j]/SEDI_IN[i,j]*(SEDI_IN[i,j]-(watereros*area));
    ROCK_OUT:=ROCK_IN[i,j]/SEDI_IN[i,j]*(SEDI_IN[i,j]-(watereros*area));

    CS137_OUT:=CS137_IN[i,j]/SEDI_IN[i,j]*(SEDI_IN[i,j]-(watereros*area*ER_depo));

    A12_out:=A12_in[i,j]/SEDI_IN[i,j]*(SEDI_IN[i,j]-(watereros*area*ER_depo));
    S12_out:=S12_in[i,j]/SEDI_IN[i,j]*(SEDI_IN[i,j]-(watereros*area*ER_depo));
    P12_out:=P12_in[i,j]/SEDI_IN[i,j]*(SEDI_IN[i,j]-(watereros*area*ER_depo));
    A13_out:=A13_in[i,j]/SEDI_IN[i,j]*(SEDI_IN[i,j]-(watereros*area*ER_depo));
    S13_out:=S13_in[i,j]/SEDI_IN[i,j]*(SEDI_IN[i,j]-(watereros*area*ER_depo));
    P13_out:=P13_in[i,j]/SEDI_IN[i,j]*(SEDI_IN[i,j]-(watereros*area*ER_depo));
    A14_out:=A14_in[i,j]/SEDI_IN[i,j]*(SEDI_IN[i,j]-(watereros*area*ER_depo));
    S14_out:=S14_in[i,j]/SEDI_IN[i,j]*(SEDI_IN[i,j]-(watereros*area*ER_depo));
    P14_out:=P14_in[i,j]/SEDI_IN[i,j]*(SEDI_IN[i,j]-(watereros*area*ER_depo));
   end;
 end;
end;
end;//-----------------------------------------Einde procedure Checkerosionheight


Function Calculatewaterero(RKCP, LS, ktc, aspect, BD : double; A12_top, S12_top,P12_top,
  A13_top, S13_top,P13_top,A14_top, S14_top,P14_top,Clay_top,Silt_top,Sand_top,Rock_top,Cs137_top: single;
  var sedi_in, sedi_out, A12_in, A12_out, S12_in, S12_out, P12_in, P12_out,
       A13_in, A13_out, S13_in, S13_out, P13_in, P13_out,
       A14_in, A14_out, S14_in, S14_out, P14_in, P14_out,
       Clay_in,Clay_out,Silt_in,Silt_out,Sand_in,Sand_out,Rock_in,Rock_out,Cs137_in,Cs137_out: single):vector_double;   //waterero in meter
var                                         //rill,interrill en cap in m≥
capacity,area,Distcorr,rusle,Ero_Potential:double ;
Rf, Kf, Cf, Pf, dum  : double;
ER_ero,ER_depo: single;
begin
 setlength(Calculatewaterero,15);

 Waterero:=0.0;
 A12_ero:=0.0; S12_ero:=0.0; P12_ero:=0.0;

 area:=sqr(RES);
 Distcorr:=(RES*(ABS(sin(aspect))+ABS(cos(aspect))));

 // Erosion equations
 rusle:=RKCP*LS;  //kg/m²
 Capacity:=kTc*rusle*distcorr;
 //*******************************

 Ero_Potential:=rusle*area/BD;
 capacity:=capacity/BD;

 If (SEDI_IN+Ero_Potential)>capacity then
  begin
   SEDI_OUT:=capacity;
   Waterero:=(SEDI_IN-capacity)/area;

   ER_ero:=ER_erosion(Waterero);
   ER_depo:=ER_deposition(Waterero);

   if waterero>0 then   // case of deposition
     begin
        A12_out:=A12_in-A12_in/Sedi_in*waterero*area*ER_depo;  // part of the C influx goes out
        A12_ero:=(A12_in-A12_out)/area;
        S12_out:=S12_in-S12_in/Sedi_in*waterero*area*ER_depo;  // part of the C influx goes out
        S12_ero:=(S12_in-S12_out)/area;
        P12_out:=P12_in-P12_in/Sedi_in*waterero*area*ER_depo;  // part of the C influx goes out
        P12_ero:=(P12_in-P12_out)/area;

        A13_out:=A13_in-A13_in/Sedi_in*waterero*area*ER_depo;  // part of the C influx goes out
        A13_ero:=(A13_in-A13_out)/area;
        S13_out:=S13_in-S13_in/Sedi_in*waterero*area*ER_depo;  // part of the C influx goes out
        S13_ero:=(S13_in-S13_out)/area;
        P13_out:=P13_in-P13_in/Sedi_in*waterero*area*ER_depo;  // part of the C influx goes out
        P13_ero:=(P13_in-P13_out)/area;

        A14_out:=A14_in-A14_in/Sedi_in*waterero*area*ER_depo;  // part of the C influx goes out
        A14_ero:=(A14_in-A14_out)/area;
        S14_out:=S14_in-S14_in/Sedi_in*waterero*area*ER_depo;  // part of the C influx goes out
        S14_ero:=(S14_in-S14_out)/area;
        P14_out:=P14_in-P14_in/Sedi_in*waterero*area*ER_depo;  // part of the C influx goes out
        P14_ero:=(P14_in-P14_out)/area;

        Clay_out:=Clay_in/Sedi_in*capacity; // part of the C influx goes out
        Clay_ero:=(Clay_in-Clay_out)/area;
        Silt_out:=Silt_in/Sedi_in*capacity; // part of the C influx goes out
        Silt_ero:=(Silt_in-Silt_out)/area;
        Sand_out:=Sand_in/Sedi_in*capacity; // part of the C influx goes out
        Sand_ero:=(Sand_in-Sand_out)/area;
        Rock_out:=Rock_in/Sedi_in*capacity; // part of the C influx goes out
        Rock_ero:=(Rock_in-Rock_out)/area;

        Cs137_out:=Cs137_in-Cs137_in/Sedi_in*waterero*area*ER_depo;  // part of the C influx goes out
        Cs137_ero:=(Cs137_in-Cs137_out)/area;

     end
   else //case of erosion
     begin
        A12_out:=A12_in+(capacity-SEDI_IN)*A12_top*ER_ero;  // mixture of C influx and locally entrained C
        A12_ero:=Waterero*A12_top*ER_ero;
        S12_out:=S12_in+(capacity-SEDI_IN)*S12_top*ER_ero;  // mixture of C influx and locally entrained C
        S12_ero:=Waterero*S12_top*ER_ero;
        P12_out:=P12_in+(capacity-SEDI_IN)*P12_top*ER_ero;  // mixture of C influx and locally entrained C
        P12_ero:=Waterero*P12_top*ER_ero;

        A13_out:=A13_in+(capacity-SEDI_IN)*A13_top*ER_ero;  // mixture of C influx and locally entrained C
        A13_ero:=Waterero*A13_top*ER_ero;
        S13_out:=S13_in+(capacity-SEDI_IN)*S13_top*ER_ero;  // mixture of C influx and locally entrained C
        S13_ero:=Waterero*S13_top*ER_ero;
        P13_out:=P13_in+(capacity-SEDI_IN)*P13_top*ER_ero;  // mixture of C influx and locally entrained C
        P13_ero:=Waterero*P13_top*ER_ero;

        A14_out:=A14_in+(capacity-SEDI_IN)*A14_top*ER_ero;  // mixture of C influx and locally entrained C
        A14_ero:=Waterero*A14_top*ER_ero;
        S14_out:=S14_in+(capacity-SEDI_IN)*S14_top*ER_ero;  // mixture of C influx and locally entrained C
        S14_ero:=Waterero*S14_top*ER_ero;
        P14_out:=P14_in+(capacity-SEDI_IN)*P14_top*ER_ero;  // mixture of C influx and locally entrained C
        P14_ero:=Waterero*P14_top*ER_ero;

        Clay_out:=Clay_in+(capacity-SEDI_IN)*Clay_top;  // mixture of C influx and locally entrained C
        Clay_ero:=Waterero*Clay_top;
        Silt_out:=Silt_in+(capacity-SEDI_IN)*Silt_top;  // mixture of C influx and locally entrained C
        Silt_ero:=Waterero*Silt_top;
        Sand_out:=Sand_in+(capacity-SEDI_IN)*Sand_top;  // mixture of C influx and locally entrained C
        Sand_ero:=Waterero*Sand_top;
        Rock_out:=Rock_in+(capacity-SEDI_IN)*Rock_top;  // mixture of C influx and locally entrained C
        Rock_ero:=Waterero*Rock_top;

        Cs137_out:=Cs137_in+(capacity-SEDI_IN)*Cs137_top*ER_ero;  // mixture of C influx and locally entrained C
        Cs137_ero:=Waterero*Cs137_top;

     end;

  end
 else
  begin
   SEDI_OUT:=SEDI_IN+Ero_Potential;
   Waterero:=-(Ero_Potential)/area;

   ER_ero:=ER_erosion(waterero);
   ER_depo:=ER_deposition(waterero);

   A12_out:=A12_in+Ero_potential*A12_top*ER_ero;
   A12_ero:=-(Ero_potential*A12_top*ER_ero)/area;
   S12_out:=S12_in+Ero_potential*S12_top*ER_ero;
   S12_ero:=-(Ero_potential*S12_top*ER_ero)/area;
   P12_out:=P12_in+Ero_potential*P12_top*ER_ero;
   P12_ero:=-(Ero_potential*P12_top*ER_ero)/area;

   A13_out:=A13_in+Ero_potential*A13_top*ER_ero;
   A13_ero:=-(Ero_potential*A13_top*ER_ero)/area;
   S13_out:=S13_in+Ero_potential*S13_top*ER_ero;
   S13_ero:=-(Ero_potential*S13_top*ER_ero)/area;
   P13_out:=P13_in+Ero_potential*P13_top*ER_ero;
   P13_ero:=-(Ero_potential*P13_top*ER_ero)/area;

   A14_out:=A14_in+Ero_potential*A14_top*ER_ero;
   A14_ero:=-(Ero_potential*A14_top*ER_ero)/area;
   S14_out:=S14_in+Ero_potential*S14_top*ER_ero;
   S14_ero:=-(Ero_potential*S14_top*ER_ero)/area;
   P14_out:=P14_in+Ero_potential*P14_top*ER_ero;
   P14_ero:=-(Ero_potential*P14_top*ER_ero)/area;

   Clay_out:=Clay_in+Ero_potential*Clay_top;
   Clay_ero:=-(Ero_potential*Clay_top)/area;
   Silt_out:=Silt_in+Ero_potential*Silt_top;
   Silt_ero:=-(Ero_potential*Silt_top)/area;
   Sand_out:=Sand_in+Ero_potential*Sand_top;
   Sand_ero:=-(Ero_potential*Sand_top)/area;
   Rock_out:=Rock_in+Ero_potential*Rock_top;
   Rock_ero:=-(Ero_potential*Rock_top)/area;

   Cs137_out:=Cs137_in+Ero_potential*Cs137_top*ER_ero;
   Cs137_ero:=-(Ero_potential*Cs137_top*ER_ero)/area;
  end;
 Calculatewaterero[0]:=Waterero;
 Calculatewaterero[1]:=A12_ero;
 Calculatewaterero[2]:=S12_ero;
 Calculatewaterero[3]:=P12_ero;
 Calculatewaterero[4]:=A13_ero;
 Calculatewaterero[5]:=S13_ero;
 Calculatewaterero[6]:=P13_ero;
 Calculatewaterero[7]:=A14_ero;
 Calculatewaterero[8]:=S14_ero;
 Calculatewaterero[9]:=P14_ero;
 Calculatewaterero[10]:=Clay_ero;
 Calculatewaterero[11]:=Silt_ero;
 Calculatewaterero[12]:=Sand_ero;
 Calculatewaterero[13]:=Rock_ero;
 Calculatewaterero[14]:=Cs137_ero;
end;

Procedure DistributeFlux_all(i,j:integer; var Flux_IN,Flux_OUT,
  A12_FLUX_IN, A12_FLUX_OUT,S12_FLUX_IN,S12_FLUX_OUT,P12_FLUX_IN,P12_FLUX_OUT,
  A13_FLUX_IN, A13_FLUX_OUT,S13_FLUX_IN,S13_FLUX_OUT,P13_FLUX_IN,P13_FLUX_OUT,
  A14_FLUX_IN, A14_FLUX_OUT,S14_FLUX_IN,S14_FLUX_OUT,P14_FLUX_IN,P14_FLUX_OUT,
  Clay_FLUX_IN, Clay_FLUX_OUT, Silt_FLUX_IN, Silt_FLUX_OUT, Sand_FLUX_IN, Sand_FLUX_OUT,
  Rock_FLUX_IN, Rock_FLUX_OUT,Cs137_FLUX_IN,Cs137_FLUX_OUT, watereros,A12_eros,S12_eros,P12_eros,A13_eros,S13_eros,P13_eros,
  A14_eros,S14_eros,P14_eros,Clay_eros,Silt_eros,Sand_eros,Rock_eros,Cs137_eros: RRaster;ra:TRoutingalgorithm; TFCA : integer);
var
MINIMUM : double;
ROWMIN,COLMIN,K,L : integer;
PART : array[1..8] of extended;
WEIGTH : array[1..8] of double=(0.353553,0.5,0.353553,0.5,0.5,0.353553,0.5,0.353553);
sum,D,flux,local_slope,partsum:double;
A12_flux, S12_flux, P12_flux: double;
A13_flux, S13_flux, P13_flux: double;
A14_flux, S14_flux, P14_flux: double;
Clay_flux, Silt_flux, Sand_flux, Rock_flux,Cs137_flux: double;
A12_partsum, S12_partsum, P12_partsum: double;
A13_partsum, S13_partsum, P13_partsum: double;
A14_partsum, S14_partsum, P14_partsum: double;
Clay_partsum, Silt_partsum, Sand_partsum, Rock_partsum,Cs137_partsum: double;
number:integer;
begin
If ra=sdra then           //---------------------- STEEPEST DESCENT--------------
BEGIN
            ROWMIN:= 0;
            COLMIN:= 0;
            MINIMUM := 1E45;
	    for K := -1 to 1 do
	    for L := -1 to 1 do
            begin
	         IF ((K=0)AND(L=0)) then CONTINUE;
                 IF (abs(K)+abs(L))=1 THEN D:=1 ELSE D:=1.414;
                 local_slope:= (DTM[I+K,J+L]-DTM[I,J])/D;
	         IF ((local_slope<MINIMUM)AND(DTM[I+K,J+L]<=DTM[I,J]))THEN
                 begin
	              MINIMUM := local_slope;
	              ROWMIN := K;
	              COLMIN := L;
	         end;
            end;

        IF ((ROWMIN <>0)OR(COLMIN<>0))then
        BEGIN
          IF (PRC[i+ROWMIN,j+COLMIN]=PRC[i,j]) THEN
            begin
              Flux_IN[i+ROWMIN,j+COLMIN]:=Flux_IN[i+ROWMIN,j+COLMIN]+Flux_OUT[i,j];
              A12_Flux_IN[i+ROWMIN,j+COLMIN]:=A12_Flux_IN[i+ROWMIN,j+COLMIN]+A12_Flux_OUT[i,j];
              S12_Flux_IN[i+ROWMIN,j+COLMIN]:=S12_Flux_IN[i+ROWMIN,j+COLMIN]+S12_Flux_OUT[i,j];
              P12_Flux_IN[i+ROWMIN,j+COLMIN]:=P12_Flux_IN[i+ROWMIN,j+COLMIN]+P12_Flux_OUT[i,j];
              A13_Flux_IN[i+ROWMIN,j+COLMIN]:=A13_Flux_IN[i+ROWMIN,j+COLMIN]+A13_Flux_OUT[i,j];
              S13_Flux_IN[i+ROWMIN,j+COLMIN]:=S13_Flux_IN[i+ROWMIN,j+COLMIN]+S13_Flux_OUT[i,j];
              P13_Flux_IN[i+ROWMIN,j+COLMIN]:=P13_Flux_IN[i+ROWMIN,j+COLMIN]+P13_Flux_OUT[i,j];
              A14_Flux_IN[i+ROWMIN,j+COLMIN]:=A14_Flux_IN[i+ROWMIN,j+COLMIN]+A14_Flux_OUT[i,j];
              S14_Flux_IN[i+ROWMIN,j+COLMIN]:=S14_Flux_IN[i+ROWMIN,j+COLMIN]+S14_Flux_OUT[i,j];
              P14_Flux_IN[i+ROWMIN,j+COLMIN]:=P14_Flux_IN[i+ROWMIN,j+COLMIN]+P14_Flux_OUT[i,j];
              Clay_Flux_IN[i+ROWMIN,j+COLMIN]:=Clay_Flux_IN[i+ROWMIN,j+COLMIN]+Clay_Flux_OUT[i,j];
              Silt_Flux_IN[i+ROWMIN,j+COLMIN]:=Silt_Flux_IN[i+ROWMIN,j+COLMIN]+Silt_Flux_OUT[i,j];
              Sand_Flux_IN[i+ROWMIN,j+COLMIN]:=Sand_Flux_IN[i+ROWMIN,j+COLMIN]+Sand_Flux_OUT[i,j];
              Rock_Flux_IN[i+ROWMIN,j+COLMIN]:=Rock_Flux_IN[i+ROWMIN,j+COLMIN]+Rock_Flux_OUT[i,j];
              Cs137_Flux_IN[i+ROWMIN,j+COLMIN]:=Cs137_Flux_IN[i+ROWMIN,j+COLMIN]+Cs137_Flux_OUT[i,j];
            end
             else
              begin
                Flux_IN[i+ROWMIN,j+COLMIN]:=Flux_IN[i+ROWMIN,j+COLMIN]+Flux_OUT[i,j]*TFCA/100.0;
                A12_Flux_IN[i+ROWMIN,j+COLMIN]:=A12_Flux_IN[i+ROWMIN,j+COLMIN]+A12_Flux_OUT[i,j]*TFCA/100.0;
                S12_Flux_IN[i+ROWMIN,j+COLMIN]:=S12_Flux_IN[i+ROWMIN,j+COLMIN]+S12_Flux_OUT[i,j]*TFCA/100.0;
                P12_Flux_IN[i+ROWMIN,j+COLMIN]:=P12_Flux_IN[i+ROWMIN,j+COLMIN]+P12_Flux_OUT[i,j]*TFCA/100.0;
                A13_Flux_IN[i+ROWMIN,j+COLMIN]:=A13_Flux_IN[i+ROWMIN,j+COLMIN]+A13_Flux_OUT[i,j]*TFCA/100.0;
                S13_Flux_IN[i+ROWMIN,j+COLMIN]:=S13_Flux_IN[i+ROWMIN,j+COLMIN]+S13_Flux_OUT[i,j]*TFCA/100.0;
                P13_Flux_IN[i+ROWMIN,j+COLMIN]:=P13_Flux_IN[i+ROWMIN,j+COLMIN]+P13_Flux_OUT[i,j]*TFCA/100.0;
                A14_Flux_IN[i+ROWMIN,j+COLMIN]:=A14_Flux_IN[i+ROWMIN,j+COLMIN]+A14_Flux_OUT[i,j]*TFCA/100.0;
                S14_Flux_IN[i+ROWMIN,j+COLMIN]:=S14_Flux_IN[i+ROWMIN,j+COLMIN]+S14_Flux_OUT[i,j]*TFCA/100.0;
                P14_Flux_IN[i+ROWMIN,j+COLMIN]:=P14_Flux_IN[i+ROWMIN,j+COLMIN]+P14_Flux_OUT[i,j]*TFCA/100.0;
                Clay_Flux_IN[i+ROWMIN,j+COLMIN]:=Clay_Flux_IN[i+ROWMIN,j+COLMIN]+Clay_Flux_OUT[i,j]*TFCA/100.0;
                Silt_Flux_IN[i+ROWMIN,j+COLMIN]:=Silt_Flux_IN[i+ROWMIN,j+COLMIN]+Silt_Flux_OUT[i,j]*TFCA/100.0;
                Sand_Flux_IN[i+ROWMIN,j+COLMIN]:=Sand_Flux_IN[i+ROWMIN,j+COLMIN]+Sand_Flux_OUT[i,j]*TFCA/100.0;
                Rock_Flux_IN[i+ROWMIN,j+COLMIN]:=Rock_Flux_IN[i+ROWMIN,j+COLMIN]+Rock_Flux_OUT[i,j]*TFCA/100.0;
                Cs137_Flux_IN[i+ROWMIN,j+COLMIN]:=Cs137_Flux_IN[i+ROWMIN,j+COLMIN]+Cs137_Flux_OUT[i,j]*TFCA/100.0;

                watereros[i,j]:=watereros[i,j]+((FLUX_OUT[i,j]-FLUX_OUT[i,j]*TFCA/100.0)/(RES*RES));
                A12_eros[i,j]:=A12_eros[i,j]+((A12_FLUX_OUT[i,j]-A12_FLUX_OUT[i,j]*TFCA/100.0)/(RES*RES));
                S12_eros[i,j]:=S12_eros[i,j]+((S12_FLUX_OUT[i,j]-S12_FLUX_OUT[i,j]*TFCA/100.0)/(RES*RES));
                P12_eros[i,j]:=P12_eros[i,j]+((P12_FLUX_OUT[i,j]-P12_FLUX_OUT[i,j]*TFCA/100.0)/(RES*RES));
                A13_eros[i,j]:=A13_eros[i,j]+((A13_FLUX_OUT[i,j]-A13_FLUX_OUT[i,j]*TFCA/100.0)/(RES*RES));
                S13_eros[i,j]:=S13_eros[i,j]+((S13_FLUX_OUT[i,j]-S13_FLUX_OUT[i,j]*TFCA/100.0)/(RES*RES));
                P13_eros[i,j]:=P13_eros[i,j]+((P13_FLUX_OUT[i,j]-P13_FLUX_OUT[i,j]*TFCA/100.0)/(RES*RES));
                A14_eros[i,j]:=A14_eros[i,j]+((A14_FLUX_OUT[i,j]-A14_FLUX_OUT[i,j]*TFCA/100.0)/(RES*RES));
                S14_eros[i,j]:=S14_eros[i,j]+((S14_FLUX_OUT[i,j]-S14_FLUX_OUT[i,j]*TFCA/100.0)/(RES*RES));
                P14_eros[i,j]:=P14_eros[i,j]+((P14_FLUX_OUT[i,j]-P14_FLUX_OUT[i,j]*TFCA/100.0)/(RES*RES));
                Clay_eros[i,j]:=Clay_eros[i,j]+((Clay_FLUX_OUT[i,j]-Clay_FLUX_OUT[i,j]*TFCA/100.0)/(RES*RES));
                Silt_eros[i,j]:=Silt_eros[i,j]+((Silt_FLUX_OUT[i,j]-Silt_FLUX_OUT[i,j]*TFCA/100.0)/(RES*RES));
                Sand_eros[i,j]:=Sand_eros[i,j]+((Sand_FLUX_OUT[i,j]-Sand_FLUX_OUT[i,j]*TFCA/100.0)/(RES*RES));
                Rock_eros[i,j]:=Rock_eros[i,j]+((Rock_FLUX_OUT[i,j]-Rock_FLUX_OUT[i,j]*TFCA/100.0)/(RES*RES));
                Cs137_eros[i,j]:=Cs137_eros[i,j]+((Cs137_FLUX_OUT[i,j]-Cs137_FLUX_OUT[i,j]*TFCA/100.0)/(RES*RES));

                FLUX_OUT[i,j]:=FLUX_OUT[i,j]*TFCA/100.0;
                A12_FLUX_OUT[i,j]:=A12_FLUX_OUT[i,j]*TFCA/100.0;
                S12_FLUX_OUT[i,j]:=S12_FLUX_OUT[i,j]*TFCA/100.0;
                P12_FLUX_OUT[i,j]:=P12_FLUX_OUT[i,j]*TFCA/100.0;
                A13_FLUX_OUT[i,j]:=A13_FLUX_OUT[i,j]*TFCA/100.0;
                S13_FLUX_OUT[i,j]:=S13_FLUX_OUT[i,j]*TFCA/100.0;
                P13_FLUX_OUT[i,j]:=P13_FLUX_OUT[i,j]*TFCA/100.0;
                A14_FLUX_OUT[i,j]:=A14_FLUX_OUT[i,j]*TFCA/100.0;
                S14_FLUX_OUT[i,j]:=S14_FLUX_OUT[i,j]*TFCA/100.0;
                P14_FLUX_OUT[i,j]:=P14_FLUX_OUT[i,j]*TFCA/100.0;
                Clay_FLUX_OUT[i,j]:=Clay_FLUX_OUT[i,j]*TFCA/100.0;
                Silt_FLUX_OUT[i,j]:=Silt_FLUX_OUT[i,j]*TFCA/100.0;
                Sand_FLUX_OUT[i,j]:=Sand_FLUX_OUT[i,j]*TFCA/100.0;
                Rock_FLUX_OUT[i,j]:=Rock_FLUX_OUT[i,j]*TFCA/100.0;
                Cs137_FLUX_OUT[i,j]:=Cs137_FLUX_OUT[i,j]*TFCA/100.0;

                If Write_detail_Exp then W_Export[i,j]:=FLUX_OUT[i,j]/(X_Resolution(i,j)*Y_Resolution(i,j)); // assign export sediment (in m) value for cells inside study area
              end;
        END
        else  // no solution found, i.e. pit
         begin
          watereros[i,j]:=watereros[i,j]+(FLUX_OUT[i,j]/(RES*RES));
          FLUX_OUT[i,j]:=0;
          A12_FLUX_OUT[i,j]:=0;
          S12_FLUX_OUT[i,j]:=0;
          P12_FLUX_OUT[i,j]:=0;
          A13_FLUX_OUT[i,j]:=0;
          S13_FLUX_OUT[i,j]:=0;
          P13_FLUX_OUT[i,j]:=0;
          A14_FLUX_OUT[i,j]:=0;
          S14_FLUX_OUT[i,j]:=0;
          P14_FLUX_OUT[i,j]:=0;
          Clay_FLUX_OUT[i,j]:=0;
          Silt_FLUX_OUT[i,j]:=0;
          Sand_FLUX_OUT[i,j]:=0;
          Rock_FLUX_OUT[i,j]:=0;
          Cs137_FLUX_OUT[i,j]:=0;
         end;

END; // end STEEPEST DESCENT
if ra=mfra then  //------------------------------ MULTIPLE FLOW-------------------
BEGIN

  number:=0; sum:=0.0;
  FOR k:=-1 to 1 do
  FOR l := -1 to 1 do
  BEGIN
    IF (k=0) and (l=0) then continue;
    number:=number+1;
    IF DTM[i+k,j+l]<=DTM[i,j] then
    BEGIN
      IF (ABS(k)=1)and(ABS(l)=1) then D:=RES*SQRT(2.0) else D:=RES;   //check if this should be adapted for MF in case of LATLONG
      IF (PRC[i,j]=0) then PART[number]:=0.0 else
      begin
         PART[number]:=(DTM[i,j]-DTM[i+k,j+l])/D;
         SUM:=SUM+PART[number]*WEIGTH[number];
      end;
    END
    ELSE
    PART[number]:=0.0;
  END;

  number:=0;
  partsum:=0.0;
  A12_partsum:=0.0;
  S12_partsum:=0.0;
  P12_partsum:=0.0;
  A13_partsum:=0.0;
  S13_partsum:=0.0;
  P13_partsum:=0.0;
  A14_partsum:=0.0;
  S14_partsum:=0.0;
  P14_partsum:=0.0;
  Clay_partsum:=0.0;
  Silt_partsum:=0.0;
  Sand_partsum:=0.0;
  Rock_partsum:=0.0;
  Cs137_partsum:=0.0;

  FOR k:=-1 to 1 do
  FOR l := -1 to 1 do
  BEGIN
    IF (k=0) and (l=0) then continue;
    number:=number+1;
    IF (k=0) and (l=0) then continue;
    IF  (part[number]>0.0) then
    begin
      flux:=((FLUX_OUT[i,j])*PART[number]*WEIGTH[number])/SUM;
      A12_flux:=((A12_FLUX_OUT[i,j])*PART[number]*WEIGTH[number])/SUM;
      S12_flux:=((S12_FLUX_OUT[i,j])*PART[number]*WEIGTH[number])/SUM;
      P12_flux:=((P12_FLUX_OUT[i,j])*PART[number]*WEIGTH[number])/SUM;
      A13_flux:=((A13_FLUX_OUT[i,j])*PART[number]*WEIGTH[number])/SUM;
      S13_flux:=((S13_FLUX_OUT[i,j])*PART[number]*WEIGTH[number])/SUM;
      P13_flux:=((P13_FLUX_OUT[i,j])*PART[number]*WEIGTH[number])/SUM;
      A14_flux:=((A14_FLUX_OUT[i,j])*PART[number]*WEIGTH[number])/SUM;
      S14_flux:=((S14_FLUX_OUT[i,j])*PART[number]*WEIGTH[number])/SUM;
      P14_flux:=((P14_FLUX_OUT[i,j])*PART[number]*WEIGTH[number])/SUM;
      Clay_flux:=((Clay_FLUX_OUT[i,j])*PART[number]*WEIGTH[number])/SUM;
      Silt_flux:=((Silt_FLUX_OUT[i,j])*PART[number]*WEIGTH[number])/SUM;
      Sand_flux:=((Sand_FLUX_OUT[i,j])*PART[number]*WEIGTH[number])/SUM;
      Rock_flux:=((Rock_FLUX_OUT[i,j])*PART[number]*WEIGTH[number])/SUM;
      Cs137_flux:=((Cs137_FLUX_OUT[i,j])*PART[number]*WEIGTH[number])/SUM;

      IF (PRC[i+k,j+l]<>PRC[i,j]) then         //  AND(PRC[i+k,j+l]>=1)
         begin
          flux:=TFCA*flux/100;
          A12_flux:=TFCA*A12_flux/100;
          S12_flux:=TFCA*S12_flux/100;
          P12_flux:=TFCA*P12_flux/100;
          A13_flux:=TFCA*A13_flux/100;
          S13_flux:=TFCA*S13_flux/100;
          P13_flux:=TFCA*P13_flux/100;
          A14_flux:=TFCA*A14_flux/100;
          S14_flux:=TFCA*S14_flux/100;
          P14_flux:=TFCA*P14_flux/100;
          Clay_flux:=TFCA*Clay_flux/100;
          Silt_flux:=TFCA*Silt_flux/100;
          Sand_flux:=TFCA*Sand_flux/100;
          Rock_flux:=TFCA*Rock_flux/100;
          Cs137_flux:=TFCA*Cs137_flux/100;

          If Write_detail_Exp Then W_Export[i,j]:=W_Export[i,j]+flux/(X_Resolution(i,j)*Y_Resolution(i,j)); // assign export sediment (in m) value for cells inside study area
         end;
      partsum:=partsum+flux;
      A12_partsum:=A12_partsum+A12_flux;
      S12_partsum:=S12_partsum+S12_flux;
      P12_partsum:=P12_partsum+P12_flux;
      A13_partsum:=A13_partsum+A13_flux;
      S13_partsum:=S13_partsum+S13_flux;
      P13_partsum:=P13_partsum+P13_flux;
      A14_partsum:=A14_partsum+A14_flux;
      S14_partsum:=S14_partsum+S14_flux;
      P14_partsum:=P14_partsum+P14_flux;
      Clay_partsum:=Clay_partsum+Clay_flux;
      Silt_partsum:=Silt_partsum+Silt_flux;
      Sand_partsum:=Sand_partsum+Sand_flux;
      Rock_partsum:=Rock_partsum+Rock_flux;
      Cs137_partsum:=Cs137_partsum+Cs137_flux;

      Flux_IN[i+k,j+l]:=Flux_IN[i+k,j+l]+flux;
      A12_Flux_IN[i+k,j+l]:=A12_Flux_IN[i+k,j+l]+A12_flux;
      S12_Flux_IN[i+k,j+l]:=S12_Flux_IN[i+k,j+l]+S12_flux;
      P12_Flux_IN[i+k,j+l]:=P12_Flux_IN[i+k,j+l]+P12_flux;
      A13_Flux_IN[i+k,j+l]:=A13_Flux_IN[i+k,j+l]+A13_flux;
      S13_Flux_IN[i+k,j+l]:=S13_Flux_IN[i+k,j+l]+S13_flux;
      P13_Flux_IN[i+k,j+l]:=P13_Flux_IN[i+k,j+l]+P13_flux;
      A14_Flux_IN[i+k,j+l]:=A14_Flux_IN[i+k,j+l]+A14_flux;
      S14_Flux_IN[i+k,j+l]:=S14_Flux_IN[i+k,j+l]+S14_flux;
      P14_Flux_IN[i+k,j+l]:=P14_Flux_IN[i+k,j+l]+P14_flux;
      Clay_Flux_IN[i+k,j+l]:=Clay_Flux_IN[i+k,j+l]+Clay_flux;
      Silt_Flux_IN[i+k,j+l]:=Silt_Flux_IN[i+k,j+l]+Silt_flux;
      Sand_Flux_IN[i+k,j+l]:=Sand_Flux_IN[i+k,j+l]+Sand_flux;
      Rock_Flux_IN[i+k,j+l]:=Rock_Flux_IN[i+k,j+l]+Rock_flux;
      Cs137_Flux_IN[i+k,j+l]:=Cs137_Flux_IN[i+k,j+l]+Cs137_flux;
    end;

  END;

  // adjust watererosion and SEDI_out when outflow is blocked
  IF (partsum<FLUX_OUT[i,j]) then
   begin
    watereros[i,j]:=watereros[i,j]+((FLUX_OUT[i,j]-partsum)/(RES*RES));
    FLUX_OUT[i,j]:=FLUX_OUT[i,j]-partsum;
    A12_FLUX_OUT[i,j]:=A12_FLUX_OUT[i,j]-A12_partsum;
    S12_FLUX_OUT[i,j]:=S12_FLUX_OUT[i,j]-S12_partsum;
    P12_FLUX_OUT[i,j]:=P12_FLUX_OUT[i,j]-P12_partsum;
    A13_FLUX_OUT[i,j]:=A13_FLUX_OUT[i,j]-A13_partsum;
    S13_FLUX_OUT[i,j]:=S13_FLUX_OUT[i,j]-S13_partsum;
    P13_FLUX_OUT[i,j]:=P13_FLUX_OUT[i,j]-P13_partsum;
    A14_FLUX_OUT[i,j]:=A14_FLUX_OUT[i,j]-A14_partsum;
    S14_FLUX_OUT[i,j]:=S14_FLUX_OUT[i,j]-S14_partsum;
    P14_FLUX_OUT[i,j]:=P14_FLUX_OUT[i,j]-P14_partsum;
    Clay_FLUX_OUT[i,j]:=Clay_FLUX_OUT[i,j]-Clay_partsum;
    Silt_FLUX_OUT[i,j]:=Silt_FLUX_OUT[i,j]-Silt_partsum;
    Sand_FLUX_OUT[i,j]:=Sand_FLUX_OUT[i,j]-Sand_partsum;
    Rock_FLUX_OUT[i,j]:=Rock_FLUX_OUT[i,j]-Rock_partsum;
    Cs137_FLUX_OUT[i,j]:=Cs137_FLUX_OUT[i,j]-Cs137_partsum;
   end;

END;                                           // END MULTIPLE FLOW-------------

end;

procedure Fraction_Export;
var
teller,i,j,o,p,Rec_nr : integer;
Next_OK : boolean;
F,MINIMUM,local_slope,D,M : double;
ROWMIN,COLMIN,K, L : integer;
Frac_Sed      : RRaster;
begin
SetDynamicRData(Frac_Sed);
SetZeroR(Frac_SEd);

 for teller:= ncol*nrow downto 1 do begin // begin lus
  i:=row[teller];  j:=column[teller];
     If (PRC[i,j]<10) or ((PRC[i,j]>=10)AND(WATEREROS[i,j]>=0)) then continue; // if not arable land, continue
     o:=i;p:=j;
     Next_OK:=true;  F:=1;
     Rec_nr:=0;

     Repeat
     begin
           // find next cell
            ROWMIN:= 0;
            COLMIN:= 0;
            MINIMUM := 1E45;
	    for K := -1 to 1 do
	    for L := -1 to 1 do
            begin
	         IF ((K=0)AND(L=0)) then CONTINUE;
                 IF (abs(K)+abs(L))=1 THEN D:=1 ELSE D:=1.414;
                 local_slope:= (DTM[o+K,p+L]-DTM[o,p])/D;
	         IF ((local_slope<MINIMUM)AND(DTM[o+K,p+L]<=DTM[o,p]))THEN
                 begin
	              MINIMUM := local_slope;
	              ROWMIN := K;
	              COLMIN := L;
	         end;
            end;
           //
           Inc(Rec_nr);
           o:=o+ROWMIN;p:=p+COLMIN;

        if (PRC[o,p]<10)OR((ROWMIN=0)AND(COLMIN=0)) then
         begin
          if Rec_nr=1 then
            begin
                 if SEDI_OUT[o-ROWmin,p-COLMIN]= 0 then Frac_Sed[i,j]:=0
                 else Frac_SED[i,j]:=TFCA/100;

            end
           else Frac_Sed[i,j]:=F;
          Next_OK:=false;
         end
         else
          begin
             if (SEDI_OUT[o,p]< SEDI_IN[o,p]) then
             F:=F*SEDI_OUT[o,p]/SEDI_IN[o,p];
          end;
     end;
     Until (Next_OK=false) OR (Rec_nr>5000);

 end;
  writeIdrisi32file(ncol,nrow, ChangeFileExt(outfilename,'')+'_Frac_Sed', Frac_Sed);
  writeIdrisi32file(ncol,nrow, ChangeFileExt(outfilename,'')+'_Frac_SedIN', SEDI_IN);
  writeIdrisi32file(ncol,nrow, ChangeFileExt(outfilename,'')+'_Frac_SedOUT', SEDI_OUT);
 DisposeDynamicRdata(Frac_Sed);
end;

procedure Water(var WATEREROS, A12_eros, S12_eros, P12_eros,A13_eros, S13_eros, P13_eros,
  A14_eros, S14_eros, P14_eros,Clay_eros, Silt_eros, Sand_eros,Rock_eros,Cs137_eros: RRaster;
  LS, RKCP: RRaster; ktc : GRaster; TFCA:integer; ra :TRoutingalgorithm; BD: double);
var
teller,i,j : integer;
model_result: array of double;
begin
// Create temp 2D maps
SetDynamicRData(SEDI_IN);
SetDynamicRData(SEDI_OUT);
SetDynamicRData(A12_IN);
SetDynamicRData(A12_OUT);
SetDynamicRData(S12_IN);
SetDynamicRData(S12_OUT);
SetDynamicRData(P12_IN);
SetDynamicRData(P12_OUT);
SetDynamicRData(A13_IN);
SetDynamicRData(A13_OUT);
SetDynamicRData(S13_IN);
SetDynamicRData(S13_OUT);
SetDynamicRData(P13_IN);
SetDynamicRData(P13_OUT);
SetDynamicRData(A14_IN);
SetDynamicRData(A14_OUT);
SetDynamicRData(S14_IN);
SetDynamicRData(S14_OUT);
SetDynamicRData(P14_IN);
SetDynamicRData(P14_OUT);
SetDynamicRData(Clay_IN);
SetDynamicRData(Clay_OUT);
SetDynamicRData(Silt_IN);
SetDynamicRData(Silt_OUT);
SetDynamicRData(Sand_IN);
SetDynamicRData(Sand_OUT);
SetDynamicRData(Rock_IN);
SetDynamicRData(Rock_OUT);
SetDynamicRData(Cs137_IN);
SetDynamicRData(Cs137_OUT);

SetzeroR(SEDI_IN);SetzeroR(SEDI_OUT);
SetzeroR(A12_in); SetzeroR(A12_out);
SetzeroR(S12_in); SetzeroR(S12_out);
SetzeroR(P12_in); SetzeroR(P12_out);
SetzeroR(A13_in); SetzeroR(A13_out);
SetzeroR(S13_in); SetzeroR(S13_out);
SetzeroR(P13_in); SetzeroR(P13_out);
SetzeroR(A14_in); SetzeroR(A14_out);
SetzeroR(S14_in); SetzeroR(S14_out);
SetzeroR(P14_in); SetzeroR(P14_out);
SetzeroR(Clay_in); SetzeroR(Clay_out);
SetzeroR(Silt_in); SetzeroR(Silt_out);
SetzeroR(Sand_in); SetzeroR(Sand_out);
SetzeroR(Rock_in); SetzeroR(Rock_out);
SetzeroR(Cs137_in); SetzeroR(Cs137_out);
//************************

setlength(model_result,10);
//writeln('start calculating water erosion');
//** Calculate watererosion & Lateral sediment
  for teller:= ncol*nrow downto 1 do begin // begin lus
   i:=row[teller];  j:=column[teller];
     IF Is_Export_Cell(i,j) then // if cell is outside area or river cell
     begin
     W_Export[i,j]:=SEDI_IN[i,j]/(X_Resolution(i,j)*Y_Resolution(i,j)); // assign export sediment (in m) value for cells outside study area
     continue;
     end;

     model_result:=Calculatewaterero(RKCP[i,j], LS[i,j], ktc[i,j], CalculateASPECT(i,j), BD,
                      A12[1,i,j], S12[1,i,j], P12[1,i,j],A13[1,i,j], S13[1,i,j], P13[1,i,j],A14[1,i,j], S14[1,i,j], P14[1,i,j],
                      CLAY[1,i,j],SILT[1,i,j],SAND[1,i,j],ROCK[1,i,j],CS137[1,i,j],SEDI_IN[i,j], SEDI_OUT[i,j],A12_in[i,j],A12_out[i,j],
                      S12_in[i,j],S12_out[i,j],P12_in[i,j],P12_out[i,j],A13_in[i,j],A13_out[i,j],S13_in[i,j],S13_out[i,j],
                      P13_in[i,j],P13_out[i,j],A14_in[i,j],A14_out[i,j],S14_in[i,j],S14_out[i,j],P14_in[i,j],P14_out[i,j],
                      Clay_in[i,j],Clay_out[i,j],Silt_in[i,j],Silt_out[i,j],Sand_in[i,j],Sand_out[i,j],Rock_in[i,j],Rock_out[i,j],Cs137_in[i,j],Cs137_out[i,j]);


     WATEREROS[i,j]:=model_result[0];   //waterero in meter
     A12_eros[i,j]:=model_result[1];   //A12_ero in cm * %  ?
     S12_eros[i,j]:=model_result[2];   //A12_ero in cm * %  ?
     P12_eros[i,j]:=model_result[3];   //A12_ero in cm * %  ?
     A13_eros[i,j]:=model_result[4];   //A12_ero in cm * %  ?
     S13_eros[i,j]:=model_result[5];   //A12_ero in cm * %  ?
     P13_eros[i,j]:=model_result[6];   //A12_ero in cm * %  ?
     A14_eros[i,j]:=model_result[7];   //A12_ero in cm * %  ?
     S14_eros[i,j]:=model_result[8];   //A12_ero in cm * %  ?
     P14_eros[i,j]:=model_result[9];   //A12_ero in cm * %  ?
     Clay_eros[i,j]:=model_result[10];   //A12_ero in cm * %  ?
     Silt_eros[i,j]:=model_result[11];   //A12_ero in cm * %  ?
     Sand_eros[i,j]:=model_result[12];   //A12_ero in cm * %  ?
     Rock_eros[i,j]:=model_result[13];   //A12_ero in cm * %  ?
     Cs137_eros[i,j]:=model_result[14];

     Checkerosionheight(i,j,A12[1,i,j], S12[1,i,j], P12[1,i,j],A13[1,i,j], S13[1,i,j], P13[1,i,j],A14[1,i,j], S14[1,i,j], P14[1,i,j],
                        CLAY[1,i,j],SILT[1,i,j],SAND[1,i,j],ROCK[1,i,j], CS137[1,i,j],WATEREROS[i,j], SEDI_OUT[i,j], A12_out[i,j], S12_out[i,j], P12_out[i,j],
                        A13_out[i,j], S13_out[i,j], P13_out[i,j],A14_out[i,j], S14_out[i,j], P14_out[i,j],
                        Clay_out[i,j],Silt_out[i,j],Sand_out[i,j],Rock_out[i,j],Cs137_out[i,j],DTM);

     DistributeFlux_all(i,j,SEDI_IN,SEDI_OUT,A12_IN, A12_OUT, S12_IN,S12_OUT,P12_IN, P12_OUT,
     A13_IN, A13_OUT, S13_IN,S13_OUT,P13_IN, P13_OUT,A14_IN, A14_OUT, S14_IN,S14_OUT,P14_IN, P14_OUT,
     Clay_IN,Clay_OUT,Silt_IN,Silt_OUT,Sand_IN,Sand_OUT,Rock_IN,Rock_OUT,Cs137_IN,Cs137_OUT,
     WATEREROS,A12_eros,S12_eros,P12_eros,A13_eros,S13_eros,P13_eros,
     A14_eros,S14_eros,P14_eros,Clay_eros,Silt_eros,Sand_eros,Rock_eros,Cs137_eros, ra, TFCA);

  end;
//***********

if Cal_Frac then Fraction_Export; // for Goswin Project

//writeIdrisi32file(ncol,nrow, ChangeFileExt(outfilename,'')+'_SedIN', SEDI_IN);
//writeIdrisi32file(ncol,nrow, ChangeFileExt(outfilename_temp,'')+'_SedOUT', SEDI_OUT);

// Dispose Temp 2D maps
 DisposeDynamicRdata(SEDI_IN);
 DisposeDynamicRdata(SEDI_OUT);
 DisposeDynamicRdata(A12_IN);
 DisposeDynamicRdata(A12_out);
 DisposeDynamicRdata(S12_IN);
 DisposeDynamicRdata(S12_out);
 DisposeDynamicRdata(P12_IN);
 DisposeDynamicRdata(P12_out);
 DisposeDynamicRdata(A13_IN);
 DisposeDynamicRdata(A13_out);
 DisposeDynamicRdata(S13_IN);
 DisposeDynamicRdata(S13_out);
 DisposeDynamicRdata(P13_IN);
 DisposeDynamicRdata(P13_out);
 DisposeDynamicRdata(A14_IN);
 DisposeDynamicRdata(A14_out);
 DisposeDynamicRdata(S14_IN);
 DisposeDynamicRdata(S14_out);
 DisposeDynamicRdata(P14_IN);
 DisposeDynamicRdata(P14_out);
 DisposeDynamicRdata(Clay_IN);
 DisposeDynamicRdata(Clay_out);
 DisposeDynamicRdata(Silt_IN);
 DisposeDynamicRdata(Silt_out);
 DisposeDynamicRdata(Sand_IN);
 DisposeDynamicRdata(Sand_out);
 DisposeDynamicRdata(Rock_IN);
 DisposeDynamicRdata(Rock_out);
 DisposeDynamicRdata(Cs137_IN);
 DisposeDynamicRdata(Cs137_out);

//*********************
end;


end.

