
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

%let startday='01JAN03'D;
%let RatingStartDay='1JAN02'D;
%let endday='01JAN04'D;


ODS EXCEL FILE="E:\csvdatatwoyear\result2.xlsx";
*libname fsid'E:\CorporateBondData\OneDrive_1_2-10-2020\FISD2012';




data firstid;
set perm.firstid;
run;

data sfirstid;
set perm.sfirstid;
run;

data step2b2008;
set perm.step2b2008;
run;


 data MatFirstId2;
 set perm.MatFirstId2;
 run;

 data MatSFirstId2;
 set perm.MatSFirstId2;
 run;


proc sort data=MatFirstId2 nodupkey;
by FirstId;
run;

proc sort data=MatSFirstId2 nodupkey;
by SFirstId;
run;



***********************************************************************************************************************************************************************************************
*
*
*Find Out Bond Have At Least ONE Roundtrip Trade;
*
*
************************************************************************************************************************************************************************************************;



 data MatSFirstId1;
 set MatSFirstId1;
 rename SFirstId=FirstId;
 run;



 data MatSFirstId2;
 set MatSFirstId2;
 rename SFirstId=FirstId;
 run;


proc append base=MatFirstId1 data=MatSFirstId1;
run;


proc append base=MatFirstId2 data=MatSFirstId2;
run;


proc append base=MatFirstId1 data=MatFirstId2;
run;

proc append base=FirstId data=MatFirstId1;
run;






proc append base=FirstId data=SFirstId;
run;

* FirstId Contains ALL Trade Involved In Roundtrip Trade;

proc sort data=FirstId nodupkey;
	by FirstId;
run;



*Recover all RoundTrip Trade;

proc sort data=step2B2008;
	by FirstId;
run;




data TradeInRound;
	merge FirstId(in=qq) step2B2008;
	by FirstId;
	if qq;
run;



*Find Bond CUSIP Id Which Has Least One RoundTrip Trade;


data RoundCusip;
	set TradeInRound(keep=CUSIP_ID);
run;


proc sort data=RoundCusip nodupkey;
	by CUSIP_ID;
run;



*Delete Bonds that do not have at least one First Type Roundtrip Trade;

proc sort data=step2B2008;
	by CUSIP_ID;
run;



********************************************************************************************************************
*
*From now step2B2008 contains only bonds that involved at least one roundtrip trade in the period;
*
*******************************************************************************************************************;



proc sql;
create table step2B2008 as select a.* from step2B2008 as a, RoundCusip as b
where a.CUSIP_ID=b.CUSIP_ID;
quit;


data bondcusipafter;
set step2B2008(keep=CUSIP_ID);
run;

proc sort data=bondcusipafter nodupkey;
by CUSIP_ID;
run;



data perm.nbond6;
set bondcusipafter end=eof;
number=_N_;
if eof then output;
run;



*****************************************************************************************************************************************************************************************************
*
*Output unmatched observations in roundtrip trade;
*
***************************************************************************************************************************************************************************************************;


proc sort data=step2B2008;
by FirstId;
run;


data perm.unmatched1;
	merge FirstId(in=qq) step2B2008;
	by FirstId;
	if qq=0;
run;






******************************************************************************************************************
*
*Calculate Table 1 A part;
*
******************************************************************************************************************;



proc sort data=step2B2008;
by CUSIP_ID;
run;


proc summary data=step2B2008;
	var  TimeToMaturity age RULE144 ratingScore offering_amt;
	by CUSIP_ID;
	output out=tableA1 mean= MeanTimeToMaturity MeanAge MeanRULE144 MeanRating IssueSize;
run;

proc summary data=tableA1;
	var  MeanTimeToMaturity MeanAge MeanRULE144 MeanRating IssueSize;
	output out=tableA mean= MeanTimeToMaturity MeanAge MeanRULE144 MeanRating MeanIssueSize median= MedianTimeToMaturity MedianAge MedianRULE144 MedianRating MedianIssueSize;
run;



ODS EXCEL FILE="E:\csvdatatwoyear\table1.xlsx";


proc print data=tableA;
run;





* Find observations has missing Offering Date, Maturity Date and Trade Executation Date;

data perm.MissingOdateMdateTradeDate;
	set step2B2008;
	if ((offering_date=.)|(MTRTY_DT=.)|(TRD_EXCTN_DT=.)) 
		then
			output;
run;




***************************************************************************************************************************
*
* Delete Trasaction Which happend 60 days within offering date and maturity date;
*
***************************************************************************************************************************;


data step2B2008;
set step2B2008;
if TRD_EXCTN_DT>enddt then delete;
if TRD_EXCTN_DT<offering_date then delete;
run;

data step2B2008;
	set step2B2008;
	if ((abs(TRD_EXCTN_DT-offering_date)<=60)|(abs(TRD_EXCTN_DT-enddt)<=60)) 
		then
			delete;
run;


* Check the number of bonds;


data bondafter2;
set step2B2008(keep=CUSIP_ID);
run;


proc sort data=bondafter2 nodupkey;
by CUSIP_ID;
run;

data perm.nbond7;
set bondafter2 end=eof;
number=_N_;
if eof then output;
run;





*****************************************************************************************************************
*Calcualte total number of trading months for data period;
*****************************************************************************************************************;


data step2B2008;
	set step2B2008;
	month=input(put(TRD_EXCTN_DT, YYMMDDN8.), yymmn6.);
	format month yymmn6.;
run;


proc sort data=step2B2008;
by CUSIP_ID TRD_EXCTN_DT;
run;


data firstmonth;
set step2B2008;
by CUSIP_ID TRD_EXCTN_DT;
if first.CUSIP_ID then output;
run;

data lastmonth;
set step2B2008;
by CUSIP_ID TRD_EXCTN_DT;
if last.CUSIP_ID then output;
run;

data firstmonth;
set firstmonth;
format fdate YYMMDD8.;
fdate=TRD_EXCTN_DT;
run;

data firstmonth;
set firstmonth(keep=CUSIP_ID fdate);
run;


data lastmonth;
set lastmonth;
format ldate YYMMDD8.;
ldate=TRD_EXCTN_DT;
run;

data lastmonth;
set lastmonth(keep=CUSIP_ID ldate);
run;

proc sql;
create table activemonth as select * from firstmonth as a left join lastmonth as b
ON a.CUSIP_ID=b.CUSIP_ID;
quit;


data activemonth;
set activemonth;
activemonth= intck("month",fdate,ldate)+1;
run;

data perm.activemonth;
set activemonth;
run;

proc sql;
create table step2B2008 as select * from step2B2008 as a left join activemonth as b
ON a.CUSIP_ID =b.CUSIP_ID;
quit;





*****************************************************************************************************************************
*
*Calculate Statistics about Monthly Trade Count;
*
*****************************************************************************************************************************;


data TableB1;
	set step2B2008;
	retain MonthTradeCount;
	retain MonthTradeGreater100;
	retain mtradevolume;
	retain MonthlyNonZeroTradingDays;
	by CUSIP_ID month TRD_EXCTN_DT;
	if first.CUSIP_ID or first.month then MonthTradeCount=0;
	MonthTradeCount=MonthTradeCount+1;
	if first.CUSIP_ID or first.month then MonthTradeGreater100=0;
	if ENTRD_VOL_QT>=100000 then MonthTradeGreater100=MonthTradeGreater100+1;
	if first.CUSIP_ID or first.month then mtradevolume=0;
	mtradevolume=mtradevolume+ENTRD_VOL_QT;
	if first.CUSIP_ID or first.month then MonthlyNonZeroTradingDays=0;
	if first.CUSIP_ID or first.month or first.TRD_EXCTN_DT then MonthlyNonZeroTradingDays=MonthlyNonZeroTradingDays+1;
	if last.CUSIP_ID or last.month then output;
run;


proc means data=TableB1 noprint nway;
	class CUSIP_ID;
	var MonthTradeCount MonthTradeGreater100 mtradevolume 
		MonthlyNonZeroTradingDays;
	output out=TableB12 mean= MeanMonthlyTradeCount MeanMonthTradeCountsGThan100B MeanMonthlyTradeQuantity MeanMonthlyNumberOfTradingDays;
run;

proc means data=TableB12 noprint nway;
	var MeanMonthlyTradeCount MeanMonthTradeCountsGThan100B MeanMonthlyTradeQuantity MeanMonthlyNumberOfTradingDays;
	output out=TableB mean= MeanMonthlyTradeCount MeanMonthTradeCountsGThan100B MeanMonthlyTradeQuantity MeanMonthlyNumberOfTradingDays
median= MedianMonthlyTradeCount MedianMonthTradeCountsGThan100B MedianMontylyTradeQuantity MedianMonthlyNumberOfTradingDays;
run;

proc print data=TableB;
run;


data TableB2;
	set step2B2008;
	retain NumberTradingMonth;
	by CUSIP_ID month TRD_EXCTN_DT;
	if first.CUSIP_ID then
		NumberTradingMonth=0;
	if first.CUSIP_ID or first.month then
		NumberTradingMonth=NumberTradingMonth+1;
	if last.CUSIP_ID then
		output;
run;

data perm.TableB1;
	set TableB1;
run;



data TableB2;
set TableB2;
PercentTradingMonth=NumberTradingMonth/activemonth*100;
run;

data perm.TableB2;
	set TableB2;
run;



proc means data=TableB2 noprint nway;
	var NumberTradingMonth PercentTradingMonth;
	output out=TablePmonthTrade mean= MeanNumberOfTradingMonth MeanPercentOfTradingMonth median= MedianNumberOfTradingMonth MedianPercentOfTradingMonth ;
run;


proc print data=TablePmonthTrade;
run;



******************************************************************************************************************
*Put RoundTrade and spread data set into working direcoty;
******************************************************************************************************************;




data spread;
set perm.spread;
run;



*********************************************************************************************************************
*
*Calculate Trading Volume For Each Dealer;
*
*********************************************************************************************************************;


proc sort data=step2B2008;
	by buyer;
run;

data BuyCount;
	set step2B2008;
	retain buycount;
	by buyer;
	if first.buyer then
		buycount=0;
	buycount=buycount+1;
	if last.buyer then
		output;
run;

data BuyCount;
	set BuyCount(keep=buyer buycount);
run;

proc sort data=step2B2008;
	by seller;
run;

data SellCount;
	set step2B2008;
	retain sellcount;
	by seller;
	if first.seller then
		sellcount=0;
	sellcount=sellcount+1;
	if last.seller then
		output;
run;

data SellCount;
	set SellCount(keep=seller sellcount);
run;



data BuyCount;
	set BuyCount;
	rename buyer=player;
run;




data SellCount;
	set SellCount;
	rename seller=player;
run;



proc sort data=SellCount nodupkey;
	by player;
run;


proc sort data=BuyCount nodupkey;
	by player;
run;


data BuySellCount;
	merge BuyCount SellCount;
	by player;
run;



data BuySellCount;
	set BuySellCount;
	array change _numeric_;
	do over change;
		if change=. then
			change=0;
	end;
run;



data BuySellCount;
	set BuySellCount;
	tradeCount=BuyCount+SellCount;
	if player='C' then
		delete;
run;



proc sort data=BuySellCount;
	by descending tradeCount;
run;



proc sort data=step2B2008;
	by buyer;
run;



data BuyerVolume;
	set step2B2008;
	retain bvolume;
	by buyer;
	if first.buyer then
		bvolume=0;
	bvolume=bvolume+ENTRD_VOL_QT;
	if last.buyer then
		output;
run;

proc sort data=step2B2008;
	by seller;
run;

data SellerVolume;
	set step2B2008;
	retain svolume;
	by seller;
	if first.seller then
		svolume=0;
	svolume=svolume+ENTRD_VOL_QT;
	if last.seller then
		output;
run;

data BuyerVolume;
	set BuyerVolume(keep=buyer bvolume);
	rename buyer=player;
run;

data SellerVolume;
	set SellerVolume(keep=seller svolume);
	rename seller=player;
run;


proc sort data=BuyerVolume nodupkey;
	by player;
run;


proc sort data=SellerVolume nodupkey;
	by player;
run;


data BuyerSellerVolume;
	merge BuyerVolume SellerVolume;
	by player;
	where player^='C';
run;



data BuyerSellerVolume;
	set BuyerSellerVolume;
	array change _numeric_;
	do over change;
		if change=. then
			change=0;
	end;
run;

data BuyerSellerVolume;
	set BuyerSellerVolume;
	totalvolume=bvolume+svolume;
run;


proc sort data=BuyerSellerVolume;
	by descending totalvolume;
run;

************************************************************************************************************************
*
*Calculate Percentile for each dealer;
*
************************************************************************************************************************;



%macro generate_percentiles(countptile99, volumeptile99);
	/* Output desired percentile values */
	proc summary data=BuySellCount;
		var tradeCount;
		output out=percentTradeCount p99= / autoname;
	run;

	proc summary data=BuySellCount;
		var tradeCount;
		output out=perm.percentTradeCount p99= / autoname;
	run;

	proc summary data=BuyerSellerVolume;
		var totalvolume;
		output out=percentTradeVolume p99= / autoname;
	run;

	/* Create macro variables for the percentile values */
	data _null_;
		set percentTradeCount;
		call symputx("count99", tradeCount_&countptile99);
	run;

	data _null_;
		set percentTradeVolume;
		call symputx("volume99", totalvolume_&volumeptile99);
	run;

	%put it is &count99;
	%put &volume99;

	data BuyerSellerVolume99;
		set BuyerSellerVolume;
		where totalvolume ge &volume99;
	run;

	

	data BuySellCount99;
		set BuySellCount;
		where tradeCount ge &count99;
	run;



	data count99dealers;
		set BuySellCount99(keep=player);
	run;






	data volume99dealers;
		set BuyerSellerVolume99(keep=player);
	run;





	proc sort data=BuySellCount;
		by descending tradeCount;
	run;

	data top10dealerbytradecount;
		set BuySellCount(obs=10);
	run;



	proc sort data=BuyerSellerVolume;
		by descending totalvolume;
	run;

	data top10dealerbytradevolume;
		set BuyerSellerVolume(obs=10);
	run;



%mend;

%generate_percentiles(p99, p99);



** Right now*/

*********************************************************************************************************************
*
*Calculate number of dealers trading the bond and average percentage interdealer trades;
*calculate number of dealers trading the bond;
*
*********************************************************************************************************************;

data NDealersTrading;
	set step2B2008(keep=CUSIP_ID buyer seller);
run;

proc sort data=NDealersTrading;
	by CUSIP_ID buyer;
run;

proc sort data=NDealersTrading nodupkey out=Nbuyers;
	by CUSIP_ID buyer;
run;

data Nbuyers;
	set Nbuyers(keep=CUSIP_ID buyer);
	rename buyer=player;
run;

proc sort data=NDealersTrading;
	by CUSIP_ID seller;
run;

proc sort data=NDealersTrading nodupkey out=Nsellers;
	by CUSIP_ID seller;
run;

data Nsellers;
	set Nsellers(keep=CUSIP_ID seller);
	rename seller=player;
run;

proc append base=Nbuyers data=Nsellers;
run;

proc sort data=Nbuyers nodupkey out=Ndealers;
	by CUSIP_ID player;
run;




data Ndealers;
	set Ndealers;
	by CUSIP_ID;
	retain nplayer;

	if first.CUSIP_ID then
		nplayer=0;

	if player^='C' then
		nplayer=nplayer+1;

	if last.CUSIP_ID then
		output;
run;


*******************************************************************************************************************
*output the result Number of Dealers Trading The Bond;
******************************************************************************************************************;

proc summary data=Ndealers;
	var nplayer;
	output out=NumberOfdealersTradingTheBond mean=MeanNOfdealersTradingTheBond median= MedianNOfdealersTradingTheBond;
run;

proc print data=NumberOfdealersTradingTheBond;
run;




*****************************************************************************************************************
*Calculate Average Percentage Roundtrip Trade, This part is out of analysis and does not go over through */
*****************************************************************************************************************;




proc sort data=TradeInRound;
	by CUSIP_ID;
run;

data NumberOfRoundTrade;
	set TradeInRound;
	by CUSIP_ID;
	retain nRoundTrade;

	if first.CUSIP_ID then
		nRoundTrade=0;
	nRoundTrade=nRoundTrade+1;

	if last.CUSIP_ID then
		output;
run;

data NumberOfRoundTrade;
	set NumberOfRoundTrade(keep=CUSIP_ID nRoundTrade);
run;

proc sort data=step2B2008;
	by CUSIP_ID;
run;




data NumberOfTrade;
	set step2B2008;
	by CUSIP_ID;
	retain nTrade;

	if first.CUSIP_ID then
		nTrade=0;
	nTrade=nTrade+1;

	if last.CUSIP_ID then
		output;
run;



*Important;




data NumberOfTrade;
	set NumberOfTrade(keep=CUSIP_ID nTrade);
run;



proc sort data=NumberOfTrade;
by CUSIP_ID;
run;



proc sort data=NumberOfRoundTrade;
by CUSIP_ID;
run;


data RoundTradeAndTotalTrade;
	merge NumberOfTrade NumberOfRoundTrade;
	by CUSIP_ID;
run;



data RoundTradeAndTotalTrade;
	set RoundTradeAndTotalTrade;
	array change _numeric_;

	do over change;

		if change=. then
			change=0;
	end;
run;





data RoundTradeAndTotalTrade;
	set RoundTradeAndTotalTrade;
	PercentRoundTrade=nRoundTrade/nTrade*100;
run;







proc summary data=RoundTradeAndTotalTrade;
	var PercentRoundTrade;
	output out=PercentRoundTrades mean=MeanPercentRoundTrade median=MedianPercentRoundTrade;
run;

proc print data=PercentRoundTrades;
run;

* above part is out of analysis *;





*********************************************************************************************************************
*Calculate Average Percentage interdealer Trades;
*********************************************************************************************************************;



data step2B2008;
set step2B2008;
if (CNTRA_PARTY_ID^='C') then interdealer=1;
else interdealer=0;
run;


data interdealer;
set step2B2008;
if interdealer=1 then output;
run;

proc sort data=interdealer;
by CUSIP_ID;
run;

data ninterdealer;
set interdealer;
by CUSIP_ID;
retain ninterdealer;
if first.CUSIP_ID then ninterdealer=0;
ninterdealer= ninterdealer+1;
if last.CUSIP_ID then output;
run;


data ninterdealer;
set ninterdealer(keep=CUSIP_ID ninterdealer);
run;


proc sort data=ninterdealer;
by CUSIP_ID;
run;


proc sort data=NumberOfTrade;
by CUSIP_ID;
run;



data InterDealerTotal;
	merge NumberOfTrade ninterdealer;
	by CUSIP_ID;
run;



data InterDealerTotal;
	set InterDealerTotal;
	array change _numeric_;

	do over change;

		if change=. then
			change=0;
	end;
run;





data InterDealerTotal;
	set InterDealerTotal;
	pinterdealer=ninterdealer/nTrade*100;
run;



*calculate percentage interdealer trades and output result;

proc summary data=InterDealerTotal;
	var pinterdealer;
	output out=PInterDealerTotal mean=MeanPercentOfInterDealerTrades median=MedianPercentOfInterDealerTrades;
run;

proc print data=PInterDealerTotal;
run;




*Calculate %of trade count by top ten dealers by trade count;
*first select top dealers by trade count;

data top10dealerbytradecount;
	set top10dealerbytradecount(keep=player);
run;

proc sql;
create table top10dealertrade as select a.* from step2B2008 as a, top10dealerbytradecount as b
where a.buyer=b.player or a.seller=b.player;
quit;

proc sort data=top10dealertrade nodupkey;
by FirstId;
run;

data top10dealertrade;
set top10dealertrade(keep=CUSIP_ID FirstId);
run;



proc sort data=top10dealertrade;
	by CUSIP_ID;
run;


data top10dealertrade;
	set top10dealertrade;
	by CUSIP_ID;
	retain Top10DealerTradeCount;

	if first.CUSIP_ID then

		Top10DealerTradeCount=0;

	Top10DealerTradeCount=Top10DealerTradeCount+1;

	if last.CUSIP_ID then
		output;
run;


proc sort data=step2B2008;
	by CUSIP_ID;
run;


data TotalTradeCount;
	set step2B2008;
	by CUSIP_ID;
	retain TotalTradeCount;

	if first.CUSIP_ID then
		TotalTradeCount=0;
	TotalTradeCount=TotalTradeCount+1;

	if last.CUSIP_ID then
		output;
run;



data CalculateTradeCountByTop10Dealer;
	merge top10dealertrade(keep=CUSIP_ID Top10DealerTradeCount) 
		TotalTradeCount(keep=CUSIP_ID TotalTradeCount);
	by CUSIP_ID;
run;



data CalculateTradeCountByTop10Dealer;
	set CalculateTradeCountByTop10Dealer;
	array change _numeric_;

	do over change;

		if change=. then
			change=0;
	end;
run;

data CalculateTradeCountByTop10Dealer;
	set CalculateTradeCountByTop10Dealer;
	PercentTradeCountByTop10Dealers=Top10DealerTradeCount/TotalTradeCount*100;
run;

*out put Trade Count By top ten dealers by trade count result;

proc summary data=CalculateTradeCountByTop10Dealer;
	var PercentTradeCountByTop10Dealers;
	output out=Top10TCountResult mean= median= /autoname;
run;

proc print data=Top10TCountResult;
run;



*Calculate percent trade count by top 1percent dealers by trade count;

proc sql;
	create table top99dealertrade as select a.* from step2B2008 as a, 
		count99dealers as b where a.buyer=b.player or a.seller=b.player;
quit;

proc sort data=top99dealertrade nodupkey;
	by FirstId;
run;

data top99dealertrade;
	set top99dealertrade(keep=CUSIP_ID FirstId);
run;

proc sort data=top99dealertrade;
	by CUSIP_ID;
run;

data top99dealertrade;
	set top99dealertrade;
	by CUSIP_ID;
	retain top99tradecount;

	if first.CUSIP_ID then
		top99tradecount=0;
	top99tradecount=top99tradecount+1;
	if last.CUSIP_ID then
		output;
run;

data PercentTCountTop99;
	merge top99dealertrade(keep=CUSIP_ID top99tradecount) 
		TotalTradeCount(keep=CUSIP_ID TotalTradeCount);
	by CUSIP_ID;
run;

data PercentTCountTop99;
	set PercentTCountTop99;
	array change _numeric_;

	do over change;

		if change=. then
			change=0;
	end;
run;

data PercentTCountTop99;
	set PercentTCountTop99;
	PercentTradeCountByTop99Dealers=top99tradecount/TotalTradeCount*100;
run;

* output percent trade count by top 99 dealers by trade count to result;

proc summary data=PercentTCountTop99;
	var PercentTradeCountByTop99Dealers;
	output out=Top99TCountResult mean= median= /autoname;
run;

proc print data=Top99TCountResult;
run;


*Calculate percent of volume by top ten dealers;

proc sql;
	create table top10volumedealertrade as select a.* from step2B2008 as a, 
		top10dealerbytradevolume as b where a.buyer=b.player or a.seller=b.player;
quit;

proc sort data=top10volumedealertrade nodupkey;
	by FirstId;
run;

data top10volumedealertrade;
	set top10volumedealertrade(keep=CUSIP_ID FirstId ENTRD_VOL_QT);
run;

proc sort data=top10volumedealertrade;
	by CUSIP_ID;
run;

data top10volumedealertrade;
	set top10volumedealertrade;
	by CUSIP_ID;
	retain TradeVolumeTop10;

	if first.CUSIP_ID then
		TradeVolumeTop10=0;
	TradeVolumeTop10=TradeVolumeTop10+ENTRD_VOL_QT;

	if last.CUSIP_ID then
		output;
run;

data top10volumedealertrade;
	set top10volumedealertrade(keep=CUSIP_ID TradeVolumeTop10);
run;

* calculate total trade Volume for each bond;

proc sort data=step2B2008;
	by CUSIP_ID;
run;

data TotalTradeVolume;
	set step2B2008;
	retain totalvolume;
	by CUSIP_ID;

	if first.CUSIP_ID then
		totalvolume=0;
	totalvolume=totalvolume+ENTRD_VOL_QT;

	if last.CUSIP_ID then
		output;
run;

data TotalTradeVolume;
	set TotalTradeVolume(keep=CUSIP_ID totalvolume);
run;

data PercentTradeVolumeTop10;
	merge top10volumedealertrade(keep=CUSIP_ID TradeVolumeTop10) 
		TotalTradeVolume(keep=CUSIP_ID totalvolume);
	by CUSIP_ID;
run;

data PercentTradeVolumeTop10;
	set PercentTradeVolumeTop10;
	array change _numeric_;

	do over change;

		if change=. then
			change=0;
	end;
run;

data PercentTradeVolumeTop10;
	set PercentTradeVolumeTop10;
	PercentTradeVolumeByTop10Dealers=TradeVolumeTop10/totalvolume*100;
run;

*out put Trade volume By top ten dealers by trade volume result;

proc summary data=PercentTradeVolumeTop10;
	var PercentTradeVolumeByTop10Dealers;
	output out=PercentTVolumeTop10 mean= median= /autoname;
run;

proc print data=PercentTVolumeTop10;
run;


*Calculate percent of volume by top ten dealers;

proc sql;
	create table top99volumedealertrade as select a.* from step2B2008 as a, 
		volume99dealers as b where a.buyer=b.player or a.seller=b.player;
quit;

proc sort data=top99volumedealertrade nodupkey;
	by FirstId;
run;

data top99volumedealertrade;
	set top99volumedealertrade(keep=CUSIP_ID FirstId ENTRD_VOL_QT);
run;

proc sort data=top99volumedealertrade;
	by CUSIP_ID;
run;

data top99volumedealertrade;
	set top99volumedealertrade;
	by CUSIP_ID;
	retain TradeVolumeTop99;

	if first.CUSIP_ID then
		TradeVolumeTop99=0;

	TradeVolumeTop99=TradeVolumeTop99+ENTRD_VOL_QT;

	if last.CUSIP_ID then
		output;
run;

data top99volumedealertrade;
	set top99volumedealertrade(keep=CUSIP_ID TradeVolumeTop99);
run;

data PercentTVolumeTop99;
	merge top99volumedealertrade(keep=CUSIP_ID TradeVolumeTop99) 
		TotalTradeVolume(keep=CUSIP_ID totalvolume);
	by CUSIP_ID;
run;

data PercentTVolumeTop99;
	set PercentTVolumeTop99;
	array change _numeric_;

	do over change;

		if change=. then
			change=0;
	end;
run;

data PercentTVolumeTop99;
	set PercentTVolumeTop99;
	PercentTradeVolumeByTop99Dealers=TradeVolumeTop99/totalvolume*100;
run;

*out put Trade volume By top 99 dealers by trade volume result;

proc summary data=PercentTVolumeTop99;
	var PercentTradeVolumeByTop99Dealers;
	output out=PercentTVolumeTop99 mean= median= /autoname;
run;

proc print data=PercentTVolumeTop99;
run;



ODS EXCEL close;








