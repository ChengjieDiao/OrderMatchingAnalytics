*libname perm'/scratch/queensu/cjdiao/total';
*ODS HTML FILE='/scratch/queensu/cjdiao/total/TEMP.XLS';

proc datasets library=work kill;
run;
quit;

*libname perm'/scratch/queensu/cjdiao/total';
*ODS HTML FILE='/scratch/queensu/cjdiao/total/TEMP.XLS';




libname fsid'E:\MergentData';
libname perm0'E:\MainData\data';
libname perm'E:\datatwoyear';


libname check'E:\check';




*libname perm0'D:\tryscratch';
*libname fsid'D:\MergentData';
*libname perm'D:\tryscratch';

%let startday='01DEC2008'D;
%let endday='31DEC12'D;


%let startdayE='01Jan2010'D;
%let enddayE='31OCT2012'D;



********************************************************************************************************************************************************************************************************************************;
*
*Read The Data From Bridge2;
*
*********************************************************************************************************************************************************************************************************************************;

data step2B2008;
set perm.step2B2008;
run;


data matchlist1;
set perm.matchlist1;
run;

data matlab1;
set perm.matlab1;
run;

proc import datafile = 'E:\csvdatatwoyear\bridge21.csv'
out  =  matlab21
dbms  = csv
replace;
run;

proc import datafile = 'E:\csvdatatwoyear\bridge22.csv'
out  =  matlab22
dbms  = csv
replace;
run;

proc import datafile = 'E:\csvdatatwoyear\bridge23.csv'
out  =  matlab23
dbms  = csv
replace;
run;

proc import datafile = 'E:\csvdatatwoyear\bridge24.csv'
out  =  matlab24
dbms  = csv
replace;
run;

proc import datafile = 'E:\csvdatatwoyear\bridge25.csv'
out  =  matlab25
dbms  = csv
replace;
run;

proc append base=matlab2 data=matlab21;
run;

proc append base=matlab2 data=matlab22;
run;

proc append base=matlab2 data=matlab23;
run;

proc append base=matlab2 data=matlab24;
run;

proc append base=matlab2 data=matlab25;
run;




data perm.matlab2;
set matlab2;
rename buysellmatchedid1=FirstId buysellmatchedid2=SFirstId buysellmatchedid3=matchedquantity;
run;

data matlab2;
set perm.matlab2;
run;


data FirstId;
set perm.FirstId;
run;

data SFirstId;
set perm.SFirstId;
run;


data MatFirstId1;
set perm.MatFirstId1;
run;

data MatSFirstId1;
set perm.MatFirstId1;
run;



*****************************************************************************************************************************************************************************************************
*
*Calcualte the Weighted Price Spread For the Third Type RoundTrip Trade;
*
****************************************************************************************************************************************************************************************************;



 data MatFirstId2;
 set perm.matlab2(keep=FirstId);
 run;




 data MatSFirstId2;
 set perm.matlab2(keep=SFirstId);
 run;




proc sort data=MatFirstId2 nodupkey;
by FirstId;
run;

proc sort data=MatSFirstId2 nodupkey;
by SFirstId;
run;



/* OutPut MatFirstId2 and MatSFirstId2 to perm file */

data perm.MatFirstId2;
set MatFirstId2;
run;


data perm.MatSFirstId2;
set MatSFirstId2;
run;




proc sort data=step2B2008;
by FirstId;
run;


proc sort data=matlab2;
by FirstId;
run;


proc sql;
create table mspread2 as select * from matlab2 as a,step2B2008 as b
where a.FirstId=b.FirstId;
run;


proc sort data=mspread2;
by SFirstId;
run;




proc sql;
create table mspread2 as select a.* , b.agencyid as Sagencyid, b.RPTD_PR as SRPTD_PR, b.ENTRD_VOL_QT as SENTRD_VOL_QT2, b.TRD_EXCTN_DT as STRD_EXCTN_DT, b.buyer as Sbuyer, b.seller as Sseller, b.TRD_EXCTN_TM as STRD_EXCTN_TM from mspread2 as a left join step2B2008 as b
on a.SFirstId=b.FirstId;
quit;


proc sort data=mspread2;
by FirstId;
run;

data mspread2(drop=matchedquantity);
set mspread2;
SENTRD_VOL_QT=matchedquantity;
run;


data mspread2;
set mspread2;
quarter=INTNX('Quarter',STRD_EXCTN_DT,0,'End');
format quarter YYMMDD10.;
informat quarter YYMMDD10.;
run;

proc import file="E:\MainData\data\core1-1.csv"
    out=core1
    dbms=csv 
    replace;
	guessingrows=100000;
run;

data core1;
set core1;
SCoreDealer=1;
run;

data core1;
set core1;
if cored='' then delete;
run;




proc sql;
create table mspread2 as select * from mspread2 as a left join core1 as b
on a.quarter=b.quarter and a.Sbuyer=b.cored;
quit;

data mspread2;set mspread2; if SCoreDealer=. then SCoreDealer=0;run;





data mspread2;
set mspread2;
sweight2=SENTRD_VOL_QT/ENTRD_VOL_QT;
roundtriptype=3;
run;






data mspread2;
set mspread2;
swpdiff2=(SRPTD_PR-RPTD_PR)*sweight2;
wsprice2=SRPTD_PR*sweight2;
aswpdiff2=abs((SRPTD_PR-RPTD_PR))*sweight2;
wholding=(STRD_EXCTN_DT-TRD_EXCTN_DT)*sweight2;
wselltocore2=SCoreDealer*sweight2;
run;



**Check The Problem*;
data check.mspread2;
set mspread2;
run;


proc sort data=mspread2;
by FirstId STRD_EXCTN_DT STRD_EXCTN_TM;
run;

 
************************************************************************************************************************************************************************************************
*
*Calculate The weight spread by the Third type RoundTrip Trade and whether ever sell to dealer or customer or buy from dealer or customer;
*
************************************************************************************************************************************************************************************************;





data mspread2;
set mspread2;
by FirstId;
retain everBuyFromC everBuyFromD everSelltoC everSelltoD pdiff apdiff holding haveagency havecomission nsell nsellsmall wsprice WsellToCore;
if first.FirstId then 
do;
nsell=0;
nsellsmall=0;
haveagency=0;
*havecommission=0;
everBuyFromC=0;
everBuyFromD=0;
everSelltoC=0;
everSelltoD=0;
pdiff=0;
apdiff=0;
holding=0;
wsprice=0;
WsellToCore=0;
end;;
nsell=nsell+1;
if SENTRD_VOL_QT<100000 then nsellsmall=nsellsmall+1;
if (agencyid=1 | Sagencyid=1) then haveagency=1;
if (seller='C' | seller='A') then everBuyFromC=1;
if (seller^='C' & seller^='A') then everBuyFromD=1;
if (Sbuyer='C' | Sbuyer='A') then everSelltoC=1;
if (Sbuyer^='C' & Sbuyer^='A') then everSelltoD=1;
*if (hcommission=1 | Shcommission=1) then havecomission=1;
pdiff=pdiff+swpdiff2;
wsprice=wsprice+wsprice2;
apdiff=apdiff+aswpdiff2;
holding=holding+wholding;
WsellToCore=WsellToCore+wselltocore2;
run;




data perm.mspread2;
set mspread2;
run;


data mspread22;
set mspread2(drop = sweight2 swpdiff2 aswpdiff2 wholding wselltocore2 SCoreDealer);
by FirstId;
if last.FirstId then output;
run;



*****************Construct Buysource and Sellrouce for the Third Type Roundtrip Trades and Ratio Small/Total # Sells **************************************************************;

data mspread22;
set mspread22;
buykind='BuyFromDealer';
sellkind='SellToDealer';
if (everBuyFromC=1 & everBuyFromD=1) then buykind='BuyFromBoth';
if (everBuyFromC=1 & everBuyFromD=0) then buykind='BuyFromCustom';
if (everSelltoC=1 & everSelltoD=1) then sellkind='SellToBoth';
if (everSelltoC=1 & everSelltoD=0) then sellkind='SellToCustom';
RatioSmallSell=nsellsmall/nsell;
run;

data mspread22;
set mspread22;
if holding=0 then roundtriptype=2;
run;


data check.checkmspread22;
set mspread22;
run;

data mspread22;
set mspread22;
if haveagency=1 then delete;
run;








*****************************************************************************************************************************
*
*Calculate Spread For the Second Type RoundTrip Trade;
*
*****************************************************************************************************************************;



proc sort data=step2B2008;
by FirstId;
run;


proc sort data=matlab1;
by FirstId;
run;


proc sql;
create table mspread1 as select * from matlab1 as a, step2B2008 as b
where a.FirstId=b.FirstId;
run;


proc sort data=mspread1;
by SFirstId;
run;









*****************************************This is to deal with whether there is hcommission and or wehther to delete hcommission**************************************************************;




*proc sql;
*create table mspread1 as select a.*, b.hcommission as Shcommission, b.agencyid as Sagencyid, b.RPTD_PR as SRPTD_PR, b.ENTRD_VOL_QT as SENTRD_VOL_QT,b.TRD_EXCTN_DT as STRD_EXCTN_DT, b.buyer as Sbuyer, b.seller as Sseller, b.TRD_EXCTN_TM as STRD_EXCTN_TM from mspread1 as a left join step2B2008 as b
*on a.SFirstId=b.FirstId;
*quit;

proc sql;
create table mspread1 as select a.*, b.agencyid as Sagencyid, b.RPTD_PR as SRPTD_PR, b.ENTRD_VOL_QT as SENTRD_VOL_QT,b.TRD_EXCTN_DT as STRD_EXCTN_DT, b.buyer as Sbuyer, b.seller as Sseller, b.TRD_EXCTN_TM as STRD_EXCTN_TM from mspread1 as a left join step2B2008 as b
on a.SFirstId=b.FirstId;
quit;




proc sort data=mspread1;
by FirstId;
run;



data mspread1;
set mspread1;
sweight1=SENTRD_VOL_QT/ENTRD_VOL_QT;
roundtriptype=2;
run;

data mspread1;
set mspread1;
quarter=INTNX('Quarter',STRD_EXCTN_DT,0,'End');
format quarter YYMMDD10.;
informat quarter YYMMDD10.;
run;




proc sql;
create table mspread1 as select * from mspread1 as a left join core1 as b
on a.quarter=b.quarter and a.Sbuyer=b.cored;
quit;

data mspread1;set mspread1; if SCoreDealer=. then SCoreDealer=0;run;


data mspread1;
set mspread1;
swpdiff1=(SRPTD_PR-RPTD_PR)*sweight1;
wsprice1=SRPTD_PR*sweight1;
aswpdiff1=abs((SRPTD_PR-RPTD_PR))*sweight1;
WsellToCore1=SCoreDealer*sweight1;
run;


*Check The Problem;
data check.mspread1;
set mspread1;
run;


proc sort data=mspread1;
by FirstId STRD_EXCTN_TM;
run;



data mspread1;
set mspread1;
by FirstId;
retain everBuyFromC everBuyFromD everSelltoC everSelltoD pdiff apdiff haveagency havecomission nsell nsellsmall wsprice WsellToCore;
if first.FirstId then 
do;
nsell=0;
nsellsmall=0;
haveagency=0;
*havecomission=0;
everBuyFromC=0;
everBuyFromD=0; 
everSelltoC=0; 
everSelltoD=0;
wsprice=0;
pdiff=0;
apdiff=0;
WsellToCore=0;
end;;
nsell=nsell+1;
if SENTRD_VOL_QT<100000 then nsellsmall=nsellsmall+1;
if (agencyid=1 | Sagencyid=1) then haveagency=1;
if (seller='C' | seller='A') then everBuyFromC=1;
if (seller^='C' & seller^='A') then everBuyFromD=1;
if (Sbuyer='C' | Sbuyer='A') then everSelltoC=1;
if (Sbuyer^='C' & Sbuyer^='A')  then everSelltoD=1;
*if (hcommission=1 | Shcommission=1) then havecomission=1;
pdiff=pdiff+swpdiff1;
apdiff=apdiff+aswpdiff1;
wsprice=wsprice+wsprice1;
WsellToCore=WsellToCore+WsellToCore1;
run;





data perm.mspread1;
set mspread1;
run;




data mspread12;
set mspread1(drop = sweight1 swpdiff1 aswpdiff1 WsellToCore1 SCoreDealer);
by FirstId;
if last.FirstId then output;
run;






data mspread12;
set mspread12;
buykind='BuyFromDealer';
sellkind='SellToDealer';
if (everBuyFromC=1 & everBuyFromD=1) then buykind='BuyFromBoth';
if (everBuyFromC=1 & everBuyFromD=0) then buykind='BuyFromCustom';
if (everSelltoC=1 & everSelltoD=1) then sellkind='SellToBoth';
if (everSelltoC=1 & everSelltoD=0) then sellkind='SellToCustom';
RatioSmallSell=nsellsmall/nsell;
run;



data mspread12;
set mspread12;
if haveagency=1 then delete;
run;




data mspread12;
set mspread12;
holding=0;
run;



**********************************************************************************************************************************************************************************************
*
*Some observations in mspread22 are actually second type roundtrip trade, seperate and put them into mspread12;
*
**********************************************************************************************************************************************************************************************;


DATA mspread22 secondtype;
  set mspread22;
  if roundtriptype=3 then output mspread22;
  else if roundtriptype=2 then output secondtype;
run;

proc append base=mspread12 data=secondtype force;
run;




proc sort data=mspread22;
by firstid;
run;

proc sort data=mspread12;
by firstid;
run;






******************************************************************************************************************
*
* Match buy and sell and calcualte spread for The First Type RoundTrip Trade;
*
******************************************************************************************************************;



data spreadbridge1;
set matchlist1(keep=FirstId SFirstId);
run;


proc sort data=spreadbridge1;
by FirstId;
run;

proc sort data=step2B2008;
by FirstId;
run;

proc sql;
create table spread as select * from spreadbridge1 as a, step2B2008 as b
where a.FirstId=b.FirstId;
quit;

proc sort data=spread;
by SFirstId;
run;

proc sort data=step2B2008;
by FirstId;
run;


*proc sql;
*create table spread as select a.*, b.hcommission as Shcommission, b.agencyid as Sagencyid, b.RPTD_PR as SRPTD_PR, b.ENTRD_VOL_QT as SENTRD_VOL_QT,b.TRD_EXCTN_DT as STRD_EXCTN_DT, b.buyer as Sbuyer, b.seller as Sseller, b.TRD_EXCTN_TM as STRD_EXCTN_TM from spread as a left join step2B2008 as b
*on a.SFirstId=b.FirstId;
*quit;

proc sql;
create table spread as select a.*, b.agencyid as Sagencyid, b.RPTD_PR as SRPTD_PR, b.ENTRD_VOL_QT as SENTRD_VOL_QT,b.TRD_EXCTN_DT as STRD_EXCTN_DT, b.buyer as Sbuyer, b.seller as Sseller, b.TRD_EXCTN_TM as STRD_EXCTN_TM from spread as a left join step2B2008 as b
on a.SFirstId=b.FirstId;
quit;




****************************************************************************************************************;
* Calculate the Spread For The First Type Roundtrip Trade;
****************************************************************************************************************;

data spread;
set spread;
quarter=INTNX('Quarter',STRD_EXCTN_DT,0,'End');
format quarter YYMMDD10.;
informat quarter YYMMDD10.;
run;



proc sql;
create table spread as select * from spread as a left join core1 as b
on a.quarter=b.quarter and a.Sbuyer=b.cored;
quit;

data spread;set spread; if SCoreDealer=. then SCoreDealer=0;run;

data spread;set spread; WsellToCore=SCoreDealer;drop SCoreDealer; run;



data spread;
set spread;
haveagency=0;
*havecommission=0;
pdiff=SRPTD_PR-RPTD_PR; * spread is the sell price minus the buy price, ask minus bid;
wsprice=SRPTD_PR;
roundtriptype=1;
apdiff=abs(SRPTD_PR-RPTD_PR);
RatioSmallSell=0;
if (agencyid=1|Sagencyid=1) then haveagency=1;
*if (hcommission=1 | Shcommission=1) then havecomission=1;
if  ENTRD_VOL_QT<100000 then RatioSmallSell=1;
run;


data spread;
set spread;
if haveagency=1 then delete;
run;








data spread;
set spread;
buykind='BuyFromDealer';
if (seller='C'|seller='A') then buykind='BuyFromCustom';
sellkind='SellToDealer';
if (Sbuyer='C'|Sbuyer='A') then sellkind='SellToCustom';
run;





data spread;
set spread;
holding=0;
run;



******************************************************************************************************************************************;
*
*Add the Second Type RoundTrip Trade Spread and The FIrst Type RoundTrip Trade Spread to the First Type RoundTrip Trade Spread, Make All Roundtrip Spread
*
******************************************************************************************************************************************;

proc append base= spread data=mspread12 force; run;


proc append base= spread data=mspread22 force; run;


************delete roundtrip trade involve any agency trade**************;


data spread;
set spread;
if haveagency=1 then delete;
run;


/********Remove Roundtrip Trades That Start within 60 days of Offering_date and enddt */


data spread;
set spread;
if TRD_EXCTN_DT>enddt then delete;
if TRD_EXCTN_DT<offering_date then delete;
run;



data spread;
	set spread;
	if ((abs(TRD_EXCTN_DT-offering_date)<=60)|(abs(TRD_EXCTN_DT-enddt)<=60)) 
		then
			delete;
run;


data spread;
set spread;
PairType='    ';
if buykind='BuyFromCustom' and sellkind='SellToCustom' then PairType='C2C';
if buykind='BuyFromCustom' and sellkind='SellToDealer' then PairType='C2D';
if buykind='BuyFromCustom' and sellkind='SellToBoth' then PairType='C2B';
if buykind='BuyFromDealer' and sellkind='SellToCustom' then PairType='D2C';
if buykind='BuyFromDealer' and sellkind='SellToDealer' then PairType='D2D';
if buykind='BuyFromDealer' and sellkind='SellToBoth' then PairType='D2B';
run;



data perm.problemPairtype;
set spread;
if PairType='    ' then output;
run;

************************************************************************************************************************
*
*Delete Round Trip Trade with Trading volume less than 100 bonds;
*
************************************************************************************************************************;

data spread;
set spread;
if ENTRD_VOL_QT<=100000 then delete;
run;





*******************Check Wether There are Some Problems*********************;

proc sort data=spread out=typecheck;
by firstid roundtriptype;
run;




data typecheck2;
set typecheck;
problem=0;
by firstid;
if first.firstid then problem=0;
if (~first.firstid & roundtriptype^=lag1(roundtriptype)) then problem=1;
if last.firstid then output;
run;

data typecheck2;
set typecheck2(keep=firstid problem);
run;

proc sort data=typecheck2;
by firstid;
run;

proc sort data=typecheck;
by firstid;
run;

proc sql;
create table typecheck3 as select * from typecheck2 as a inner join typecheck as b
on a.firstid=b.firstid;
run;




data check.typeproblem;
set typecheck3;
if problem=1 then output;
run;



******************************************************************************************************************************************************************************
*
*Rank Dealers According to Their Trading Volume And Trade Count;
*
******************************************************************************************************************************************************************************;


data total;
set perm0.rawtotal;
if TRD_EXCTN_DT le &endday and TRD_EXCTN_DT ge &startday then output;
run;

data total;
	set total;
	if RPT_SIDE_CD='B' then
		do;
			buyer=RPTG_PARTY_ID;
			seller=CNTRA_PARTY_ID;
		end;
	else
		do;
			buyer=CNTRA_PARTY_ID;
			seller=RPTG_PARTY_ID;
		end;
run;


data total;
set total(keep=RPTG_PARTY_ID CNTRA_PARTY_ID ENTRD_VOL_QT);
run;

data side1;
set total(keep=RPTG_PARTY_ID ENTRD_VOL_QT);
rename RPTG_PARTY_ID=dealer;
run;

data side2;
set total(keep=CNTRA_PARTY_ID ENTRD_VOL_QT);
rename CNTRA_PARTY_ID=dealer;
run;


proc delete data=total; run;

proc append base=side1 data=side2 force;
run;



proc summary data=side1;
   class dealer;
   var ENTRD_VOL_QT;
   output out=dealervolume(drop= _type_) sum=TVolume;
run;

data dealervolume;
set dealervolume;
if dealer='A' | dealer='C' then delete;
run;


data dealervolume;
set dealervolume;
rename _freq_ =tradecount;
if dealer='' then delete;
run;


data perm.checkdealervolume;
set dealervolume;
run;

proc rank data=dealervolume out=Rdealervolume groups=10 ties=low; 
var TVolume;
ranks RDVolume;
run; 


data Rdealervolume;
set Rdealervolume;
RDVolume=RDVolume+1;
run;


proc summary data=Rdealervolume;
   var  TVolume tradecount;
   output out= TopDealer(drop= _:) idgroup (max(TVolume) out[10] (TVolume) =) idgroup (max(tradecount) out[10] (tradecount) =) p99= /autoname;
run;

data _null_;                                                         
   set TopDealer;                                                         
   call symputx('TradeCount10', tradecount_10);                                     
   call symputx('TradeCountP99',tradecount_p99);
   call symputx('Volume10', TVolume_10);                                     
   call symputx('VolumeP99',TVolume_p99);  
run;    

data Rdealervolume;                                                             
   set Rdealervolume;                                                           
Top99Dcount=0;
Top99Dvolume=0;
Top10Dcount=0;
Top10Dvolume=0; 
if tradecount>= &TradeCountP99 then Top99Dcount=1;
if tradecount>= &TradeCount10 then Top10Dcount=1;
if TVolume>= &VolumeP99 then Top99Dvolume=1;
if TVolume>= &Volume10 then Top10Dvolume=1;
run;  


proc sort data=spread;
by buyer firstid;
run;

proc sort data=Rdealervolume;
by dealer;
run;


data perm.Rdealervolume;
set Rdealervolume;
run;

********************************Rdealervolume include multiple ranks based on volume and tradecounts********************************************************;
proc sql;
create table spread as select * from spread as a left join Rdealervolume as b
on a.buyer=b.dealer;
run;




data spread;
set spread;
rename dealer=Bdealer;
run;




*******************************************************************************************************************************************************************************;
*
**********************************************Calculate Number Of Dealers Traded This Bonds**************************************;
*
******************************************************************************************************************************************************************************;



data total;
set perm0.rawtotal;
if TRD_EXCTN_DT le &endday and TRD_EXCTN_DT ge &startday then output;
run;

data total;
set total(keep=CUSIP_ID RPTG_PARTY_ID CNTRA_PARTY_ID);

data ndealer1;
set total(keep=CUSIP_ID RPTG_PARTY_ID);
rename RPTG_PARTY_ID=dealer;
run;

data ndealer2;
set total(keep=CUSIP_ID CNTRA_PARTY_ID);
rename CNTRA_PARTY_ID=dealer;
run;

proc append base=ndealer1 data=ndealer2;
run;


data ndealer1;
set ndealer1;
if dealer in ('A','C') then delete;
run;

proc sort data=ndealer1 nodupkey;
by CUSIP_ID dealer;
run;


proc summary data=ndealer1;
   class CUSIP_ID;
   output out=ndealer3(drop= _type_);
run;

data ndealer3;
set ndealer3;
rename _freq_=ndealer;
run;

data ndealer3;
set ndealer3(keep=cusip_id ndealer);
run;




proc sql;
create table spread as select * from spread as a left join ndealer3 as b
on a.cusip_id=b.cusip_id;
run;





*******************************************************************************************************************************;
* 
*Start to count the number of trade counts in previous 30 days for each bond;
*
*******************************************************************************************************************************;

data total;
set perm0.rawtotal;
if TRD_EXCTN_DT le &endday and TRD_EXCTN_DT ge &startday then output;
run;

proc sort data=total;
	by CUSIP_ID TRD_EXCTN_DT TRD_EXCTN_TM;
run;


data DayTradeCum1;
set total(keep=CUSIP_ID TRD_EXCTN_DT);
by CUSIP_ID TRD_EXCTN_DT;
retain DayTradeCum;
if first.CUSIP_ID then DayTradeCum=0;
DayTradeCum=DayTradeCum+1;
if first.TRD_EXCTN_DT then output; * important, it is the first observation of the date to be count;
run;


data DayTradeCum1;
set DayTradeCum1;
DayTradeCum=DayTradeCum-1;
run;






proc timeseries data=DayTradeCum1 out=DayTradeCum2;
      by CUSIP_ID;
      id TRD_EXCTN_DT interval=day 
                   start=&startday
                   end  =&endday;
	  var DayTradeCum;
run;



proc sort data=DayTradeCum2;
by CUSIP_ID TRD_EXCTN_DT;
run;





data DayTradeCum2;
set DayTradeCum2;
by CUSIP_ID;
if first.CUSIP_ID then
do;
if DayTradeCum=. then DayTradeCum=0;
end;
run;





proc expand data=DayTradeCum2 to=day out=DayTradeCum2 extrapolate;
by CUSIP_ID;
id TRD_EXCTN_DT;
convert DayTradeCum /method=step;
run;
  

data DayTradeCum3;
set DayTradeCum2;
rename TRD_EXCTN_DT=TRD_EXCTN_DT30 DayTradeCum=DayTradeCum30;
run;


data _null_;
informat startd YYMMDD8.;
format startd YYMMDDN8.;
startd=intnx('day',&startday,+30);
call symput('startd',put(startd, date9.));
run;

%put startd is &startd;


data DayTradeCum2;
set DayTradeCum2;
if TRD_EXCTN_DT>="&startd"d then output;
run;

proc sort data=DayTradeCum3;
by CUSIP_ID TRD_EXCTN_DT30;
run;




proc sql;
create table DayTradeCum as select * from DayTradeCum2 as a, DayTradeCum3 as b
where a.CUSIP_ID=b.CUSIP_ID and a.TRD_EXCTN_DT=intnx('day',b.TRD_EXCTN_DT30,30);
quit;


proc sort data=DayTradeCum;
by CUSIP_ID TRD_EXCTN_DT;
run;


data DayTradeCum;
set DayTradecum;
Tcount30day=DayTradeCum-DayTradeCum30;
run;

data DayTradeCum;
set DayTradeCum(keep=CUSIP_ID TRD_EXCTN_DT TRD_EXCTN_DT30 Tcount30day DayTradeCum DayTradeCum30);
run;

proc sort data=DayTradeCum;
by CUSIP_ID TRD_EXCTN_DT;
run;



data perm.DayTradeCum;
set DayTradeCum;
run;



proc sort data=spread;
by CUSIP_ID TRD_EXCTN_DT;
run;



proc sql;
create table spread1 as select * from spread as a,DayTradeCum as b
where a.CUSIP_ID=b.CUSIP_ID and a.TRD_EXCTN_DT=b.TRD_EXCTN_DT;
quit;





***************************************************************************************************************************************
*
* calculate bond spread based on the rank of bond trading count;
*
**************************************************************************************************************************************;




proc rank data=spread1 out=TRankSpread groups=10 ties=low;
var Tcount30day;
ranks RTcount30day;
run;


data TRankSpread;
set TRankSpread;
RTcount30day=RTcount30day+1;
run;

data ftypeTRankSpread;
set TRankSpread ;
if roundtriptype=1 then output;
run;



data SecondtypeTRankSpread;
set TRankSpread ;
if roundtriptype=2 then output;
run;


data ThirdTypeTRankSpread;
set TRankSpread;
if roundtriptype=3 then output;
run;






data perm.trankspread;
set TRankSpread;
run;




******************************************************************************************************************************************
*
* Start to count the number of trade days in previous 30 days for each bond;
*
******************************************************************************************************************************************;


proc sort data=total nodupkey out=ctradedays;
	by CUSIP_ID TRD_EXCTN_DT;
run;



data countdays1;
set ctradedays(keep=CUSIP_ID TRD_EXCTN_DT);
by CUSIP_ID TRD_EXCTN_DT;
retain NCTdays;
if first.CUSIP_ID then NCTdays=0;
NCTdays=NCTdays+1;
run;


data countdays1;
set countdays1;
NCTdays=NCTdays-1;
run;






proc timeseries data=countdays1 out=countdays2;
      by CUSIP_ID;
      id TRD_EXCTN_DT interval=day 
                   start= &startday
                   end  = &endday;
	  var NCTdays;
run;


proc sort data=countdays2;
by CUSIP_ID TRD_EXCTN_DT;
run;





data countdays2;
set countdays2;
by CUSIP_ID;
if first.CUSIP_ID then
do;
if NCTdays=. then NCTdays=0;
end;
;
run;


proc expand data=countdays2 to=day out=countdays2 extrapolate;
by CUSIP_ID;
id TRD_EXCTN_DT;
convert NCTdays /method=step;
run;
  



data countdays3;
set countdays2;
rename TRD_EXCTN_DT=TRD_EXCTN_DT30 NCTdays=NCTdays30;
run;


data countdays2;
set countdays2;
if TRD_EXCTN_DT>="&startd"d;
run;


proc sort data=countdays3;
by CUSIP_ID TRD_EXCTN_DT30;
run;

proc sql;
create table countdays as select * from countdays2 as a, countdays3 as b
where a.CUSIP_ID=b.CUSIP_ID and a.TRD_EXCTN_DT=intnx('day',b.TRD_EXCTN_DT30,30);
quit;


proc sort data=countdays;
by CUSIP_ID TRD_EXCTN_DT;
run;


data countdays;
set countdays;
Ntdays30=NCTdays-NCTdays30;
run;

data countdays;
set countdays(keep=CUSIP_ID TRD_EXCTN_DT Ntdays30);
run;

proc sort data=countdays;
by CUSIP_ID TRD_EXCTN_DT;
run;

proc sort data=TRankSpread;
by CUSIP_ID TRD_EXCTN_DT;
run;


proc sql;
create table TDRankSpread0 as select * from TRankSpread as a,countdays as b
where a.CUSIP_ID=b.CUSIP_ID and a.TRD_EXCTN_DT=b.TRD_EXCTN_DT;
run;



*****************************************************************************************************************;
*
* calculate bond median spread based on bond trading days;
*
*****************************************************************************************************************;

proc rank data=TDRankSpread0 out=TDRankSpread groups=10 ties=low;
var Ntdays30;
ranks RNtdays30;
run;


data TDRankSpread;
set TDRankSpread;
RNtdays30=RNtdays30+1;
run;


/*
data ftypeTDRankSpread;
set TDRankSpread;
if roundtriptype=1 then output;
run;



data SecondtypeTDRankSpread;
set TDRankSpread ;
if roundtriptype=2 then output;
run;


data ThirdTypeTDRankSpread;
set TDRankSpread;
if roundtriptype=3 then output;
run;
*/



data perm.TDRankSpread;
set TDRankSpread;
run;




