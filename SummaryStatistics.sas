libname data2'D:\tryscratch';
*libname data2'D:\DealerNetworkProject\Data\CoreAndPeriphery';
*libname main'D:\MainData\data';


data total;
set data2.totalmerged;
run;


proc summary data=total;
   var ENTRD_VOL_QT;
   output out=data2.volume1(drop= _type_) sum=TVolume;
run;



proc sort data=total nodupkey out=Nbond1;
by cusip_id;
run;



proc summary data=Nbond1;
   output out=data2.Nbond1(keep= _freq_);
run;

data total1;
set total1;
if SCRTY_TYPE_CD='CORP' then output;
run;


proc summary data=total;
   var ENTRD_VOL_QT;
   output out=data2.volume2(drop= _type_) sum=TVolume;
run;


proc sort data=total nodupkey out=Nbond2;
by cusip_id;
run;


proc summary data=Nbond2;
   output out=data2.Nbond2(keep= _freq_);
run;

data TotalMergedS;
set total;
if offering_date=. then delete;
run;

proc sort data=TotalMergedS nodupkey out=Nbond3;
by cusip_id;
run;


proc summary data=TotalMergedS;
   var ENTRD_VOL_QT;
   output out=data2.volume3(drop= _type_) sum=TVolume;
run;


proc summary data=Nbond3;
   output out=data2.Nbond3;
run;



data TotalMergedS;
set TotalMergedS;
Tenor=MTRTY_DT-TRD_EXCTN_DT;
age=TRD_EXCTN_DT-offering_date;
run;





data TotalMergedS;
	set TotalMergedS;

	if RULE_144A_FL='N' then
		RULE144=0;
	else
		RULE144=1;

	if rating='Aaa' then
		Nrating='AAA';
	else if rating='Aa1' then
		Nrating='AA+';
	else if rating='Aa2' then
		Nrating='AA';
	else if rating='Aa3' then
		Nrating='AA-';
	else if rating='A1' then
		Nrating='A+';
	else if rating='A2' then
		Nrating='A';
	else if rating='A3' then
		Nrating='A-';
	else if rating='Baa1' then
		Nrating='BBB+';
	else if rating='Baa2' then
		Nrating='BBB';
	else if rating='Baa3' then
		Nrating='BBB-';
	else if rating='Ba1' then
		Nrating='BB+';
	else if rating='Ba2' then
		Nrating='BB';
	else if rating='Ba3' then
		Nrating='BB-';
	else if rating='B1' then
		Nrating='B+';
	else if rating='B2' then
		Nrating='B';
	else if rating='B3' then
		Nrating='B-';
	else if rating='Caa1' then
		Nrating='CCC+';
	else if rating='Caa2' then
		Nrating='CCC';
	else if rating='Caa3' then
		Nrating='CCC-';
	else if rating='Ca' then
		Nrating='CC';
	else if (rating=''|rating='NR') then
		Nrating='NR';
	else
		Nrating=rating;
run;

data TotalMergedS;
	set TotalMergedS(drop=rating);
run;



data TotalMergedS;
	set TotalMergedS;

	if Nrating='AAA' then
		ratingScore=1;
	else if Nrating='AA+' then
		ratingScore=2;
	else if Nrating='AA' then
		ratingScore=3;
	else if Nrating='AA-' then
		ratingScore=4;
	else if Nrating='A+' then
	    ratingScore=5;
	else if Nrating='A' then 
		ratingScore=6;
	else if Nrating='A-' then
		ratingScore=7;
	else if Nrating='BBB+' then
		ratingScore=8;
	else if Nrating='BBB' then
		ratingScore=9;
	else if Nrating='BBB-' then
		ratingScore=10;
	else if Nrating='BB+' then
		ratingScore=11;
	else if Nrating='BB' then
		ratingScore=12;
	else if Nrating='BB-' then
		ratingScore=13;
	else if Nrating='B+' then
		ratingScore=14;
	else if Nrating='B' then
		ratingScore=15;
	else if Nrating='B-' then
		ratingScore=16;
	else if Nrating='CCC+' then
		ratingScore=17;
	else if Nrating='CCC' then
		ratingScore=18;
	else if Nrating='CCC-' then
		ratingScore=19;
	else if Nrating='CC' then
		ratingScore=20;
	else if Nrating='C' then
		ratingScore=21;
	else if Nrating='D' then
		ratingScore=22;
	else if Nrating='NR' then
		ratingScore=.;
	else ratingScore=.;
run;


proc means data=TotalMergedS;
class cusip_id;
   var offering_amt tenor age ratingScore;
   output out=BondCharacteristicsMean1(drop= _type_) mean= offering_amt tenor age ratingScore;
run;


data BondCharacteristicsMean1;
set BondCharacteristicsMean1;
if cusip_id='' then delete;
run;


proc means data=BondCharacteristicsMean1;
   var offering_amt tenor age ratingScore ;
   output out=data2.BondCharacteristicsMean2(drop= _type_) mean= /autoname;
run;



proc means data=TotalMergedS;
class cusip_id;
   var offering_amt tenor age ratingScore;
   output out=BondCharacteristicsMedian1(drop= _type_) median= offering_amt tenor age ratingScore;
run;



data BondCharacteristicsMedian1;
set BondCharacteristicsMedian1;
if cusip_id='' then delete;
run;




proc means data=BondCharacteristicsMedian1;
   var offering_amt tenor age ratingScore ;
   output out=data2.BondCharacteristicsMedian2(drop= _type_) median= /autoname;
run;


*********Mean And Median Of Trading Activites**********************************************************;



proc sql;
create table TradingFrequency1 as
select cusip_id, count(CUSIP_ID) as TradeCount, sum(ENTRD_VOL_QT) as BondVolume from TotalMergedS group by CUSIP_ID;
quit;




data TradingFrequency1;
set TradingFrequency1;
if cusip_id='' then delete;
run;



data data2.TradingFrequency1;
set TradingFrequency1;
run;


proc sgplot data=TradingFrequency1;
    histogram TradeCount;
run;

proc means data=TradingFrequency1;
   output out=data2.TradingFrequency2 mean= median=/autoname;
run;


******************Calcualte Statistics About Core Periphery and Dealer Trading activities**********************************************;


data DealerVolume;
set TotalMergedS(keep=RPTG_PARTY_ID CNTRA_PARTY_ID ENTRD_VOL_QT);
run;


data DealerVolume1;
set DealerVolume(keep=RPTG_PARTY_ID ENTRD_VOL_QT);
rename RPTG_PARTY_ID=dealer;
run;

data DealerVolume2;
set DealerVolume(keep=CNTRA_PARTY_ID ENTRD_VOL_QT);
rename CNTRA_PARTY_ID=dealer;
run;


data DealerVolume2;
set DealerVolume2;
if dealer in ('A','C') then delete;
run;



proc append base=DealerVolume1 data=DealerVolume2;
run;



proc sql;
create table DealerVolume3 as
select dealer,  sum(ENTRD_VOL_QT) as DVolume from DealerVolume1 group by dealer;
quit;


proc sql;
create table VolumeSum as
select  sum(DVolume) as TVolume from DealerVolume3;
quit;





data _NULL_;
set VolumeSum;
call symput('TVolume',TVolume);
run;


data DealerVolume3;
set DealerVolume3;
PDVolume=DVolume/&TVolume;
run;


proc sort data=DealerVolume3;
by desending PDVolume;
run;

data DealerVolume3;
set DealerVolume3;
DVRank=_N_;
run;


data DealerVolume4;
set DealerVolume3;
retain CPDVolume;
if _N_=1 then CPDVolume=0;
CPDVolume=CPDVolume+PDVolume;
run;


data data2.DealerVolume4;
set DealerVolume4;
run;

proc sgplot data=DealerVolume4;
  series x=DVRank y=CPDVolume / markers;
  label DVRank="Number of Dealers, From Top Dealers to Peripheral Dealers" CPDVolume="Share Of Total Trading Volume";
  refline 30 / axis=x lineattrs=(thickness=3 color=darkred pattern=dash);
run;









