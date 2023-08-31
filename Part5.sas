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

libname im'E:\RoundtripData\coreperiph';
libname check'E:\check';




*libname perm0'D:\tryscratch';
*libname fsid'D:\MergentData';
*libname perm'D:\tryscratch';
*libname im'D:\RoundtripData\coreperiph';

%let startday='01DEC2008'D;
%let endday='31DEC12'D;


%let startdayE='01JAN2010'D;
%let enddayE='31OCT2012'D;

*** You Did Not Delete The Agency Trade In Calculating Previous Trading History and Total Trading Volume For Each Deaer, maybe you should not but be alert***************;


data chistory;
set perm0.rawtotal(keep=CUSIP_ID RPTG_PARTY_ID TRD_EXCTN_DT CNTRA_PARTY_ID);
if TRD_EXCTN_DT> &startday and TRD_EXCTN_DT< &endday then output;
run;


data TDRankSpread;
set perm.TDRankSpread;
run;




data chistory1;
set chistory(keep=CUSIP_ID TRD_EXCTN_DT RPTG_PARTY_ID);
rename RPTG_PARTY_ID=bdealer;
run;


data chistory2;
set chistory(keep=CUSIP_ID TRD_EXCTN_DT CNTRA_PARTY_ID);
rename CNTRA_PARTY_ID=bdealer;
run;


proc append base=chistory1 data=chistory2;
run;

data chistory1;
set chistory1;
if bdealer in ('A','C') then delete;
run;

proc sort data=chistory1 nodupkey;
by bdealer cusip_id TRD_EXCTN_DT;
run;

data chistory1;
set chistory1;
by bdealer cusip_id;
retain ndaystraded;
if first.bdealer or first.cusip_id then ndaystraded=0;
ndaystraded=ndaystraded+1;
run;


data chistory1;
set chistory1;
rename TRD_EXCTN_DT=TradedDate;
run;


proc sort data=TDRankSpread;
by bdealer cusip_id TRD_EXCTN_DT;
run;



proc sql;
create table chistory3 as select a.firstid, a.TRD_EXCTN_DT, a.cusip_id, a.bdealer,b.TradedDate,b.ndaystraded from TDRankSpread as a left join chistory1 as b
on a.bdealer=b.bdealer and a.cusip_id=b.cusip_id and b.TradedDate le a.TRD_EXCTN_DT-6 and b.TradedDate ge a.TRD_EXCTN_DT-371;
quit;


proc sort data=chistory3;
by firstid tradeddate;
run;


proc sort data=chistory3 nodupkey out=chistory31;
by firstid;
run;

data chistory31;
set chistory31;
rename tradeddate=tradeddate0;
run;

data chistory31;
set chistory31;
rename ndaystraded=ndaystraded0;
run;

proc sort data=chistory3;
by firstid desending tradeddate;
run;


proc sort data=chistory3 nodupkey out=chistory32;
by firstid;
run;


data chistory32;
set chistory32;
rename tradeddate=tradeddate1;
run;


data chistory32;
set chistory32;
rename ndaystraded=ndaystraded1;
run;

proc sort data=chistory31;
by firstid;
run;

proc sort data=chistory32;
by firstid;
run;

proc sql;
create table TDRankSpread as select * from TDRankSpread as a left join chistory31 as b
on a.firstid=b.firstid;
quit;


proc sql;
create table TDRankSpread as select * from TDRankSpread as a left join chistory32 as b
on a.firstid=b.firstid;
quit;






data TDRankSpread;
set TDRankSpread;
TradedDaysPreviousY=ndaystraded1-ndaystraded0+1;
run;

data TDRankSpread;
set TDRankSpread;
if TradedDaysPreviousY=. then TradedDaysPreviousY=0;
run;


data TDHRankSpread;
set TDRankSpread;
drop tradeddate0 ndaystraded0 tradeddate1 ndaystraded1;
run;

proc delete data=TDRankSpread;
run;



********************************************Calculate Number Of Days Dealers Take Bond Into Inventory***********************************************;




data cinvenhistory1;
set TDHRankSpread(keep=CUSIP_ID TRD_EXCTN_DT bdealer holding);
if holding>0 then output;
run;

data cinvenhistory1;
set cinvenhistory1(drop=holding);
run;



proc sort data=cinvenhistory1 nodupkey;
by bdealer cusip_id TRD_EXCTN_DT;
run;

data cinvenhistory1;
set cinvenhistory1;
by bdealer cusip_id;
retain ndayInventory;
if first.bdealer or first.cusip_id then ndayInventory=0;
ndayInventory=ndayInventory+1;
run;


data cinvenhistory1;
set cinvenhistory1;
rename TRD_EXCTN_DT=TakeInvDate;
run;



proc sort data=TDHRankSpread;
by bdealer cusip_id TRD_EXCTN_DT;
run;




proc sql;
create table cinvenhistory2 as select a.firstid, a.TRD_EXCTN_DT, a.cusip_id, a.bdealer,b.TakeInvDate,b.ndayInventory from TDHRankSpread as a left join cinvenhistory1 as b
on a.bdealer=b.bdealer and a.cusip_id=b.cusip_id and b.TakeInvDate le a.TRD_EXCTN_DT-6 and b.TakeInvDate ge a.TRD_EXCTN_DT-371;
quit;


proc sort data=cinvenhistory2;
by firstid ndayInventory;
run;


proc sort data=cinvenhistory2 nodupkey out=cinvenhistory21;
by firstid;
run;

data cinvenhistory21;
set cinvenhistory21;
rename TakeInvDate=TakeInvDate0;
run;

data cinvenhistory21;
set cinvenhistory21;
rename ndayInventory=ndayInventory0;
run;

proc sort data=cinvenhistory2;
by firstid desending TakeInvDate;
run;


proc sort data=cinvenhistory2 nodupkey out=cinvenhistory22;
by firstid;
run;


data cinvenhistory22;
set cinvenhistory22;
rename TakeInvDate=TakeInvDate1;
run;


data cinvenhistory22;
set cinvenhistory22;
rename ndayInventory=ndayInventory1;
run;

proc sort data=cinvenhistory21;
by firstid;
run;

proc sort data=cinvenhistory22;
by firstid;
run;

proc sql;
create table TDHRankSpread as select * from TDHRankSpread as a left join cinvenhistory21 as b
on a.firstid=b.firstid;
quit;


proc sql;
create table TDHRankSpread as select * from TDHRankSpread as a left join cinvenhistory22 as b
on a.firstid=b.firstid;
quit;






data TDHRankSpread;
set TDHRankSpread;
InventoryDaysPreviousY=ndayInventory1-ndayInventory0+1;
run;

data TDHRankSpread;
set TDHRankSpread;
if InventoryDaysPreviousY=. then InventoryDaysPreviousY=0;
run;






data TDHRankSpread;
set TDHRankSpread;
quarter=INTNX('Quarter',TRD_EXCTN_DT,0,'End');
run;


proc sort data=TDHRankSpread;
by quarter bdealer;
run;


proc import file="E:\MainData\data\dealercentralityWeightByNumberOfTrades.csv"
    out=eigenvector
    dbms=csv
	replace;
	guessingrows=100000;
run;

data eigenvector(drop=quarter);
set eigenvector;
quarter2=input(put(quarter,8.),yymmdd8.);
format quarter2 YYMMDD10.;
informat quarter2 YYMMDD10.;
run;


data eigenvector;
set eigenvector;
rename quarter2=quarter;
run;

data eigenvector;
set eigenvector;
quarter=INTNX('Quarter',quarter,0,'End');
run;

proc sort data=eigenvector;
by quarter dealer;
run;


proc sql;
create table TDHRankSpread as select * from TDHRankSpread as a left join eigenvector as b
on a.quarter=b.quarter and a.bdealer = b.dealer;
quit;



proc import file="E:\MainData\data\core1-1.csv"
    out=core1
    dbms=csv 
    replace;
	guessingrows=100000;
run;

data core1;
set core1;
CoreDealer=1;
run;

data core1;
set core1;
if cored='' then delete;
run;



proc sort data=core1;
by quarter cored;
run;

proc sort data=TDHRankSpread;
by quarter Bdealer;
run;

proc sql;
create table TDHRankSpread as select * from TDHRankSpread as a left join core1 as b
on a.quarter=b.quarter and a.bdealer=b.cored;
run;

data TDHRankSpread;
set TDHRankSpread;
if CoreDealer=. then CoreDealer=0;
run;



data TDHRankSpread;
set TDHRankSpread(drop=TakeInvDate0 ndayInventory0 TakeInvDate1 ndayInventory1);
run;


/* Match Order Imbalance */


data coreperiph;
set im.coreperiph;
run;

proc append base=coreperiph data=im.coreperiph20072008;run;
proc append base=coreperiph data=im.coreperiph20092010;run;
proc append base=coreperiph data=im.coreperiph2012;run;


data coreperiph;
set coreperiph;
nextweek=intnx('week', TRD_STLMT_DT,1,'b');
run;


data tdhrankspread;
set tdhrankspread;
run;

data tdhrankspread;
set tdhrankspread;
week=intnx('week', TRD_EXCTN_DT,0,'b');
run;


proc sql;
create table tdhrankspread as select * from tdhrankspread as a left join coreperiph as b
on a.week=b.nextweek and a.CoreDealer=b.Core and a.cusip_id=b.NCUSIP;
quit;


data tdhrankspread;
set tdhrankspread;
drop NCUSIP nextweek;
run;




data tdhrankspread;
set tdhrankspread;
drop _TYPE_ _FREQ_ TRD_STLMT_DT core;
run;




data tdhrankspread;
set tdhrankspread;
NormOrderIM=InventoryCumulative/finOS/1000;
run;

data tdhrankspread;
set tdhrankspread;
if NormOrderIM>=1 then NormOrderIM=1;
if NormOrderIM<=-1 then NormOrderIM=-1;
run;



data problemim;
set tdhrankspread;
if InventoryCumulative=.;
run;

proc sort data=problemim;
by TRD_EXCTN_DT CoreDealer CUSIP_ID;
run;

data perm.problemim;
set problemim;
run;




data checkWsellToCore;
set tdhrankspread;
if WsellToCore=. then output;
run;

proc sort data=checkWsellToCore;
by TRD_EXCTN_DT WsellToCore;
run;


data perm.checkWsellToCore;
set checkWsellToCore;
run;


proc sort data=tdhrankspread;
by cusip_id;
run;


data fsid3;
set fsid.fsidnorating;
drop issue_id issuer_id offering_date offering_amt rule_144a foreign_currency convertible maturity perpetual;
run;



proc sql;
create table tdhrankspread as select * from tdhrankspread as a left join fsid3 as b
on a.cusip_id=b.cusip_id;
run;




data tdhrankspread;
set tdhrankspread;
defaulty=.;
if ratingScore le 6 and ratingScore^=. then defaulty=0;
if ratingScore >6 and ratingScore<9 then defaulty=0;
if ratingScore =9 then defaulty=0.0017;
if ratingScore >9 and ratingScore<12 then defaulty=0.0017;
if ratingScore =12 then defaulty=0.0065;
if ratingScore >12 and ratingScore<15 then defaulty=0.0065;
if ratingScore =15 then defaulty=0.0344;
if ratingScore >15 and ratingScore<18 then defaulty=0.0344;
if ratingScore ge 18 then defaulty=0.2663;
if ratingScore=. | ratingScore=23 then defaulty=.;
run;




data tdhrankspread;
set tdhrankspread;
BuyFromCustomer=0;
if buykind='BuyFromCustom' then BuyFromCustomer=1;
run;




data tdhrankspread;
set tdhrankspread;
theta_f=(1+coupon/100)**(1/365)-1;
spread=pdiff;
buyprice=RPTD_PR;
sd=0;
sellprice= wsprice;
if sellkind='SellToDealer' then sd=1;
alpha_f=(1-defaulty)**(1/365);
q=ENTRD_VOL_QT;
run;





data tdhrankspread;
set tdhrankspread;
run;



data tdhrankspread;
set tdhrankspread;
dailydefaultrate=1-alpha_f;
dailyriskfree=1/0.9999-1;
run;


data tdhrankspread;
set tdhrankspread;
discountvalue=theta_f/dailyriskfree-(theta_f/dailyriskfree)*(dailydefaultrate/(dailyriskfree+dailydefaultrate));
run;



data tdhrankspread;
set tdhrankspread;
offering_amt=offering_amt*1000;
run;




/* Only Include Jan 1 2010 to Oct 31 2012 */

data tdhrankspread;
set tdhrankspread;
if TRD_EXCTN_DT>=&startdayE and TRD_EXCTN_DT<=&enddayE then output;
run;




***********************************************************************************************
*
*****Seprate Different Type of Roundtrip Spread;
*
*********************************************************************************************;


data ftypespread;
set tdhrankspread;
if roundtriptype=1 then output;
run;

data mspread12;
set tdhrankspread;
if roundtriptype=2 then output;
run;


data mspread22;
set tdhrankspread;
if roundtriptype=3 then output;
run;




data perm.ftypespread;
set ftypespread;
run;

data perm.mspread12;
set mspread12;
run;

data perm.mspread22;
set mspread22;
run;



data ftypeTDHRankSpread;
set tdhrankspread;
if roundtriptype=1 then output;
run;



data SecondtypeTDHRankSpread;
set tdhrankspread;
if roundtriptype=2 then output;
run;


data ThirdTypeTDHRankSpread;
set tdhrankspread;
if roundtriptype=3 then output;
run;





****************************************************************************************************************************;
* 
*
*Calculate part B of table 4;
*
*
****************************************************************************************************************************;


ODS EXCEL FILE="E:\csvdatatwoyear\result1.xlsx";

title 'First Type Spread';
proc tabulate data=ftypespread;
class buykind sellkind;
var pdiff;
table buykind  all ,pdiff * (all sellkind) * (N median PCTN)  /nocellmerge  box='roundtrip trade in sameday, exactly trading quantity match';
label buykind='Buy Source' sellkind='Sell Source' pdiff='Spread (Ask price minus Buy Price), In Basis Points';
keylabel PCTN='Percentage of Total Observation';
run;


title 'Second Type Spread';
proc tabulate data=mspread12;
class buykind sellkind;
var pdiff;
table buykind  all ,pdiff * (all sellkind) * (N median PCTN) /nocellmerge   box='roundtrip trade in sameday, but not exactly trading quantity match';
label buykind='Buy Source' sellkind='Sell Source' pdiff='Spread (Ask price minus Buy Price), In Basis Points';
keylabel PCTN='Percentage of Total Observation';
run;


title 'Third Type Spread';
proc tabulate data=mspread22;
class buykind sellkind;
var pdiff;
table buykind  all ,pdiff * (all sellkind) * (N median PCTN)  /nocellmerge box='Roundtrip Matched with sells up to 60 days following the buy trade';
label buykind='Buy Source' sellkind='Sell Source' pdiff='Spread (Ask price minus Buy Price), In Basis Points';
keylabel PCTN='Percentage of Total Observation';
run;


title 'All Types Spread';
proc tabulate data=tdhrankspread;
class buykind sellkind;
var pdiff;
table buykind  all ,pdiff * (all sellkind) * (N median PCTN) /nocellmerge box='All types of RoundTrip Trade Included';
label buykind='Buy Source' sellkind='Sell Source' pdiff='Spread (Ask price minus Buy Price), In Basis Points';
keylabel PCTN='Percentage of Total Observation';
run;



proc format;
value rfmt 1='1' 2='2' 3='3' 4='4' 5='5' 6-10='6-10';
run;


****************************************************************************************************************************;
*
*Create Table 4 for different deciles of trade counts in previous 30 days;
*
****************************************************************************************************************************;


proc format;
value $fgrade 'AorAbove' ='         AorAbove ' 'BBB'='      BBB' 'BB'='    BB' 'B'='  B' 'BelowB'=' BelowB' 'NA'='NA';
run;




title 'All Types Spread';

proc tabulate data=tdhrankspread missing;
class RTcount30day Grate /order=formatted;
var pdiff ;
*format RTcount30day rfmt.;
format Grate $fgrade. ;
table RTcount30day  all , pdiff  * (all Grate) * (N median min max PCTN) /nocellmerge box='All types of RoundTrip Trade Included';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days ';
keylabel PCTN='%';
run;

proc freq data=tdhrankspread;
table Grate;
run;



title 'All Types Spread';
proc tabulate data=tdhrankspread missing;
class RTcount30day Grate /order=formatted;
var Tcount30day ;
*format RTcount30day rfmt.;
format Grate $fgrade. ;
table RTcount30day  all , Tcount30day  * (all Grate) * (N median min max PCTN) /nocellmerge  box='All types';;
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days ';
keylabel PCTN='%';
run;


title 'First Type Spread';
proc tabulate data=ftypeTDHRankSpread missing;
class RTcount30day Grate /order=formatted;
var pdiff;
*format RTcount30day rfmt.;
format Grate $fgrade. ;
table RTcount30day  all , pdiff  * (all Grate) * (N median min max PCTN) /nocellmerge  box='First Type';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days ';
keylabel PCTN='%';
run;

title 'First Type Spread';
proc tabulate data=ftypeTDHRankSpread missing;
class RTcount30day Grate /order=formatted;
var Tcount30day ;
*format RTcount30day rfmt.;
format Grate $fgrade. ;
table RTcount30day  all , Tcount30day  * (all Grate) * (N median min max PCTN) /nocellmerge box='First Type';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days ';
keylabel PCTN='%';
run;



title 'Second Type Spread';
proc tabulate data=SecondTypeTDHRankSpread missing;
class RTcount30day Grate /order=formatted;
var pdiff;
*format RTcount30day rfmt.;
format Grate $fgrade. ;
table RTcount30day  all , pdiff  * (all Grate) * (N median min max PCTN) /nocellmerge   box='Second Type';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days ';
keylabel PCTN='%';
run;

title 'Second Type Spread';
proc tabulate data=SecondTypeTDHRankSpread missing;
class RTcount30day Grate /order=formatted;
var Tcount30day ;
*format RTcount30day rfmt.;
format Grate $fgrade. ;
table RTcount30day  all , Tcount30day  * (all Grate) * (N median min max PCTN) /nocellmerge box='Second Type';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days ';
keylabel PCTN='%';
run;


title 'Third Type Spread';
proc tabulate data=ThirdTypeTDHRankSpread missing;
class RTcount30day Grate /order=formatted;
var pdiff;
*format RTcount30day rfmt.;
format Grate $fgrade. ;
table RTcount30day  all , pdiff  * (all Grate) * (N median min max PCTN) /nocellmerge box='Third Type';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days ';
keylabel PCTN='%';
run;

title 'Third Type Spread';
proc tabulate data=ThirdTypeTDHRankSpread missing;
class RTcount30day Grate /order=formatted;
var Tcount30day ;
*format RTcount30day rfmt.;
format Grate $fgrade. ;
table RTcount30day  all , Tcount30day  * (all Grate) * (N median min max PCTN) /nocellmerge box='Third Type';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days ';
keylabel PCTN='%';
run;




*************************************************************************************************************************************************
*
*Summarize The Roundtrip Spread By Different Pair Type;
*
**************************************************************************************************************************************************;


title 'All Types Spread';

proc tabulate data=tdhrankspread missing;
class RTcount30day Grate PairType /order=formatted;
var pdiff ;
*format RTcount30day rfmt.;
format Grate $fgrade. ;
table RTcount30day  all , pdiff  * (all Grate) *(all Pairtype) * (N median min max PCTN) /nocellmerge box='All types';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days ';
keylabel PCTN='%';
run;

proc freq data=tdhrankspread;
table Grate;
run;


title 'All Types Spread';
proc tabulate data=tdhrankspread missing;
class RTcount30day Grate PairType/order=formatted;
var Tcount30day ;
*format RTcount30day rfmt.;
format Grate $fgrade. ;
table RTcount30day  all , Tcount30day  * (all Grate) *(all Pairtype) * (N median min max PCTN) /nocellmerge  box='All types';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days ';
keylabel PCTN='%';
run;


title 'First Type Spread';
proc tabulate data=ftypeTDHRankSpread missing;
class RTcount30day Grate PairType/order=formatted;
var pdiff;
*format RTcount30day rfmt.;
format Grate $fgrade. ;
table RTcount30day  all , pdiff  * (all Grate) *(all Pairtype) * (N median min max PCTN) /nocellmerge  box='First Type';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days ';
keylabel PCTN='%';
run;

title 'First Type Spread';
proc tabulate data=ftypeTDHRankSpread missing;
class RTcount30day Grate PairType/order=formatted;
var Tcount30day ;
*format RTcount30day rfmt.;
format Grate $fgrade. ;
table RTcount30day  all , Tcount30day  * (all Grate)*(all Pairtype) * (N median min max PCTN) /nocellmerge box='First Type';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days ';
keylabel PCTN='%';
run;



title 'Second Type Spread';
proc tabulate data=SecondTypeTDHRankSpread missing;
class RTcount30day Grate PairType/order=formatted;
var pdiff;
*format RTcount30day rfmt.;
format Grate $fgrade. ;
table RTcount30day  all , pdiff  * (all Grate) *(all Pairtype)* (N median min max PCTN) /nocellmerge   box='Second Type';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days ';
keylabel PCTN='%';
run;

title 'Second Type Spread';
proc tabulate data=SecondTypeTDHRankSpread missing;
class RTcount30day Grate PairType/order=formatted;
var Tcount30day ;
*format RTcount30day rfmt.;
format Grate $fgrade. ;
table RTcount30day  all , Tcount30day  * (all Grate) *(all Pairtype)* (N median min max PCTN) /nocellmerge box='Second Type';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days ';
keylabel PCTN='%';
run;


title 'Third Type Spread';
proc tabulate data=ThirdTypeTDHRankSpread missing;
class RTcount30day Grate PairType /order=formatted;
var pdiff;
*format RTcount30day rfmt.;
format Grate $fgrade. ;
table RTcount30day  all , pdiff  * (all Grate) *(all Pairtype)* (N median min max PCTN) /nocellmerge box='Third Type';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days ';
keylabel PCTN='%';
run;

title 'Third Type Spread';
proc tabulate data=ThirdTypeTDHRankSpread missing;
class RTcount30day Grate PairType/order=formatted;
var Tcount30day ;
*format RTcount30day rfmt.;
format Grate $fgrade. ;
table RTcount30day  all , Tcount30day  * (all Grate)*(all Pairtype) * (N median min max PCTN) /nocellmerge box='Third Type';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days ';
keylabel PCTN='%';
run;






proc format;
value rfmt 1='1' 2='2' 3='3' 4='4' 5='5' 6-10='6-10';
run;





title 'All Types Spread';
proc tabulate data=tdhrankspread missing;
class RNtdays30 Grate /order=formatted;
var pdiff;
format RNtdays30 rfmt.;
format Grate $fgrade. ;
table RNtdays30  all , pdiff  * (all Grate) * (N median min max PCTN) /nocellmerge box='All types ';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days'  RNtdays30='Deciles for Number Of Trading Days among Previous 30 Days' Ntdays30='Number Of Trading Days among Previous 30 Days';
keylabel PCTN='%';
run;


title 'All Types Spread';
proc tabulate data=tdhrankspread missing;
class RNtdays30 Grate /order=formatted;
var Ntdays30;
format RNtdays30 rfmt.;
format Grate $fgrade. ;
table RNtdays30  all ,Ntdays30  * (all Grate) * (N median min max PCTN) /nocellmerge box='All types';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days'  RNtdays30='Deciles for Number Of Trading Days among Previous 30 Days' Ntdays30='Number Of Trading Days among Previous 30 Days';
keylabel PCTN='%';
run;


title 'First Type Spread';
proc tabulate data=ftypeTDHRankSpread missing;
class RNtdays30 Grate /order=formatted;
var pdiff;
format RNtdays30 rfmt.;
format Grate $fgrade. ;
table RNtdays30  all , pdiff  * (all Grate) * (N median min max PCTN) /nocellmerge box='First Type';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days'  RNtdays30='Deciles for Number Of Trading Days among Previous 30 Days' Ntdays30='Number Of Trading Days among Previous 30 Days';
keylabel PCTN='%';
run;

title 'First Type Spread';
proc tabulate data=ftypeTDHRankSpread missing;
class RNtdays30 Grate /order=formatted;
var Ntdays30;
format RNtdays30 rfmt.;
format Grate $fgrade. ;
table RNtdays30  all ,Ntdays30  * (all Grate) * (N median min max PCTN) /nocellmerge box='First Type';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days'  RNtdays30='Deciles for Number Of Trading Days among Previous 30 Days' Ntdays30='Number Of Trading Days among Previous 30 Days';
keylabel PCTN='%';
run;

title 'Second Type Spread';
proc tabulate data=SecondTypeTDHRankSpread missing;
class RNtdays30 Grate /order=formatted;
var pdiff;
format RNtdays30 rfmt.;
format Grate $fgrade. ;
table RNtdays30  all , pdiff  * (all Grate) * (N median min max PCTN) /nocellmerge box='Second Type';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days'  RNtdays30='Deciles for Number Of Trading Days among Previous 30 Days' Ntdays30='Number Of Trading Days among Previous 30 Days';
keylabel PCTN='%';
run;

title 'Second Type Spread';
proc tabulate data=SecondTypeTDHRankSpread missing;
class RNtdays30 Grate /order=formatted;
var Ntdays30;
format RNtdays30 rfmt.;
format Grate $fgrade. ;
table RNtdays30  all ,Ntdays30  * (all Grate) * (N median min max PCTN) /nocellmerge box='Second Type';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days'  RNtdays30='Deciles for Number Of Trading Days among Previous 30 Days' Ntdays30='Number Of Trading Days among Previous 30 Days';
keylabel PCTN='%';
run;

title 'Third Type Spread';
proc tabulate data=ThirdTypeTDHRankSpread missing;
class RNtdays30 Grate /order=formatted;
var pdiff;
format RNtdays30 rfmt.;
format Grate $fgrade. ;
table RNtdays30  all , pdiff  * (all Grate) * (N median min max PCTN) /nocellmerge box='Third Type';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days'  RNtdays30='Deciles for Number Of Trading Days among Previous 30 Days' Ntdays30='Number Of Trading Days among Previous 30 Days';
keylabel PCTN='%';
run;

title 'Third Type Spread';
proc tabulate data=ThirdTypeTDHRankSpread missing;
class RNtdays30 Grate /order=formatted;
var Ntdays30;
format RNtdays30 rfmt.;
format Grate $fgrade. ;
table RNtdays30  all ,Ntdays30  * (all Grate) * (N median min max PCTN) /nocellmerge box='Third Type';
label RTcount30day='Deciles for Trade Counts in Previous 30 Days' pdiff='spread' Grate='Rating Grade' 
Tcount30day='Trade Counts in Previous 30 Days'  RNtdays30='Deciles for Number Of Trading Days among Previous 30 Days' Ntdays30='Number Of Trading Days among Previous 30 Days';
keylabel PCTN='%';
run;


proc tabulate data=tdhrankspread missing;
class PairType quarter CoreDealer /order=formatted;
var pdiff;
table quarter , pdiff  * (all CoreDealer) *(all PairType)* (median);
label pdiff='spread';
run;

proc tabulate data=tdhrankspread missing;
class PairType quarter CoreDealer /order=formatted;
var holding;
table quarter , holding  * (all CoreDealer) *(all PairType)* (mean);
label holding='Holding Period';
run;


data C2D;
set tdhrankspread;
if PairType='C2D' then output;
run;

data C2D;
set C2D;
if WsellToCore=0 | WsellToCore=1;
run;

data C2D;
set C2D;
if WsellToCore=0 then SellToCore=0;
if WsellToCore=1 then SellToCore=1;
run;



data perm.C2D;
set C2D;
run;

proc tabulate data=C2D missing;
class PairType quarter CoreDealer SellToCore /order=formatted;
var pdiff;
table quarter , pdiff  * (all CoreDealer) *(all SellToCore)* (median);
label pdiff='Spread Sell To Different Dealers, C2D trades';
run;

proc tabulate data=C2D missing;
class PairType quarter CoreDealer SellToCore /order=formatted;
var holding;
table quarter , holding  * (all CoreDealer) *(all SellToCore)* (mean);
label holding='Holding Period Sell to Different Dealers, C2D trades';
run;


ODS EXCEL close;




data tdhrankspread;
set tdhrankspread;
rename RDVolume=DecileBrokerDealerTradingVolume Bdealer=BrokerDealer sd=SellToDealer alpha_f=alpha theta_f=theta TRD_EXCTN_DT=BuyTransactionDate coupon=coupon_rate buykind=BuySource sellkind=SellSource RTcount30day=TradeCountDecile Tcount30day=TradeCountPre30Days defaulty=yearlydefaultrate;
run;


data tdhrankspread;
set tdhrankspread;
rename TradedDaysPreviousY=DealerTradedDaysPreviousY InventoryDaysPreviousY=DealerInventoryDaysPreviousY;
run;

data tdhrankspread;
set tdhrankspread;
BuyVolumeGt5M=0;
BuyVolumeBet1Mand5M=0;
BuyVolumeBetHalfMand1M=0;
if ENTRD_VOL_QT>5000000 then BuyVolumeGt5M=1;
if ENTRD_VOL_QT le 5000000 and ENTRD_VOL_QT gt 1000000  then BuyVolumeBet1Mand5M=1;
if ENTRD_VOL_QT le 1000000 and ENTRD_VOL_QT gt 500000  then BuyVolumeBetHalfMand1M=1;
run;

data tdhrankspread;
set tdhrankspread;
TradeCountDeciel1=0;
TradeCountDeciel2=0;
TradeCountDeciel3=0;
TradeCountDeciel4=0;
TradeCountDeciel5=0;
if TradeCountPre30Days=1 then TradeCountDeciel1=1;
if TradeCountPre30Days=2 then TradeCountDeciel2=1;
if TradeCountPre30Days=3 then TradeCountDeciel3=1;
if TradeCountPre30Days=4 then TradeCountDeciel4=1;
if TradeCountPre30Days=5 then TradeCountDeciel5=1;
run;

data tdhrankspread;
set tdhrankspread;
Decile1CoreDealer=TradeCountDeciel1*CoreDealer;
Decile2CoreDealer=TradeCountDeciel2*CoreDealer;
Decile3CoreDealer=TradeCountDeciel3*CoreDealer;
Decile4CoreDealer=TradeCountDeciel4*CoreDealer;
Decile5CoreDealer=TradeCountDeciel5*CoreDealer;
BuyVolumeGt5MCoreDealer=BuyVolumeGt5M*CoreDealer;
BuyVolumeBet1Mand5MCoreDealer=BuyVolumeBet1Mand5M*CoreDealer;
BuyVolumeBetHalfMand1MCoreDealer=BuyVolumeBetHalfMand1M*CoreDealer;
run;





data perm.tdhrankspread;
set tdhrankspread;
run;


proc export data=tdhrankspread
    outfile="E:\RoundtripData\tdhrankspread.csv"
    dbms=csv
	replace;
run;







