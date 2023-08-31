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




*libname perm0'G:\tryscratch';
*libname fsid'G:\MergentData';
*libname perm'G:\tryscratch';

%let startday='01DEC2008'D;
%let endday='31DEC12'D;




data total;
set perm.totalmerged;
if enddt^=. and TRD_EXCTN_DT gt enddt then delete;
run;




proc sort data=total nodupkey out=perm.ntotalbond;
by cusip_id;
run;



data perm.nbond1;
set perm.ntotalbond end=eof;
number=_N_;
if eof then output;
run;


data total;
set total;
if offering_date=. then delete;
run;


proc sort data=total nodupkey out=perm.nbond2;
by cusip_id;
run;


data perm.nbond2;
set perm.nbond2 end=eof;
number=_N_;
if eof then output;
run;







*******Delete Convertible Bonds**********;

data total;
set total;
if CNVRB_FL='Y' then delete;
if foreign_currency='Y' then delete; 
run;


proc sort data=total out=perm.nbond3;
by cusip_id;
run;

data perm.nbond3;
set perm.nbond3 end=eof;
number=_N_;
if eof then output;
run;

* Find The First Trade Executation Date In the Trading Period;


proc sort data=total;
by TRD_EXCTN_DT;
run;


data firstday;
set total(obs=1);
run;

data perm.firstday;
set firstday;
run;

data _null_;
set firstday;
call symput('firstday',TRD_EXCTN_DT);
run;
%put firstday is &firstday;

***********************************************************************************************************************************************************;
*
* Delete bond does not trade at least once within 60 days after the offering date;
* Ncheckftrading contain the number of bonds after deleting bonds that did not trade at least once within 60 days after the offering date;
*
***********************************************************************************************************************************************************;

proc sort data=total out=checkftrading;
by CUSIP_ID TRD_EXCTN_DT;
run;

data checkftrading;
set checkftrading(keep=CUSIP_ID TRD_EXCTN_DT offering_date);
run;



*********************************************************************************
*Check point;
*********************************************************************************;


data perm.checkftradingcheck;
set checkftrading(obs=10000);
run;


proc sort data=checkftrading nodupkey;
by CUSIP_ID;
run;




data perm.checkproblem;
set checkftrading;
if ((offering_date >= &startday)&(TRD_EXCTN_DT > offering_date +60)) then output;
run;

*******************************************Delete Bonds Does Not Trade Within 60 Days of Offering Date*****************************************************************************;
data checkftrading;
set checkftrading;
if ((offering_date >= &startday)&(TRD_EXCTN_DT > offering_date +60)) then delete;
run;



data checkftrading;
set checkftrading(keep=CUSIP_ID);
run;


proc sort data=checkftrading nodupkey;
by CUSIP_ID;
run;

data perm.nbond4;
set checkftrading end=eof;;
if eof then output;
run;


*** this step delete any bonds does not trade within 60 days';

proc sql;
create table total as select a.* from total as a, checkftrading as b
where a.CUSIP_ID=b.CUSIP_ID;
quit;


*************************************************************************************************************;
*
* Delete Bond does not trade at least 100 bonds In The Period;
* bondcusip2 contain number of bonds after deleting bond does not trade minimum 100 bonds;
*
*************************************************************************************************************;



data Institutional;
	set total(keep=CUSIP_ID ENTRD_VOL_QT);
run;


proc sort data=Institutional;
	by CUSIP_ID descending ENTRD_VOL_QT;
run;

proc sort data=Institutional nodupkey;
	by CUSIP_ID;
run;

data Institutional;
	set Institutional;
	if ENTRD_VOL_QT<=100000 then
		delete;
run;

proc sort data=Institutional nodupkey;
	by CUSIP_ID;
run;

data Institutional;
	set Institutional(keep=CUSIP_ID);
run;


proc sql;
create table total as select a.* from total as a, Institutional as b
where a.CUSIP_ID=b.CUSIP_ID;
quit;

proc sort data=total nodupkey out=perm.nbond5;
by CUSIP_ID;
run;


data perm.nbond5;
set perm.nbond5 end=eof;
if eof then output;
run;



* Delete institutional data set in working directory;

proc delete data=Institutional;
run;



data step2B2008;
set total;
run;



proc delete data=total;
run;



proc sort data=step2B2008; by cusip_id trd_exctn_dt TRD_EXCTN_TM; run;







data step2B2008;
	set step2B2008;
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




data step2B2008;
	set step2B2008;
	if buyer=seller then
		delete;
run;




data Nrating;
	set step2B2008(keep=Nrating);
run;


proc sort data=Nrating nodupkey;
	by Nrating;
run;


data perm.Nrating;
	set Nrating;
run;


* Assign bonds to different group according to the rating level;


data step2B2008;
set step2B2008;
informat Grate $10.;
format Grate $10.;
Grate='';
if (ratingScore le 6 and ratingScore^=.) then Grate='AorAbove';
else if (ratingScore le 9 and ratingScore > 6) then Grate='BBB';
else if (ratingScore le 12 and ratingScore > 9) then Grate='BB';
else if (ratingScore le 15 and ratingScore > 12) then Grate='B';
else if (ratingScore > 15 and ratingScore < 23) then Grate='BewlowB';
else if ratingScore=23 | ratingScore=. then Grate='NA';
else Grate='Other';
run;


proc freq data=step2B2008;
table ratingScore;
run;

proc freq data=step2B2008;
table Grate;
run;





***************************************************************************************************************************;
*
*Exclude Periods within 60 days of issuance, redemption, or maturity;
*
***************************************************************************************************************************;


data step2B2008;
	set step2B2008;
	*if (abs(trd_exctn_dt-offering_date)<60) | ((abs(trd_exctn_dt-enddt)<60) and enddt^=.)
		then
			delete;
run;




*Keep only dealer for the buyers;


data BuyTrades;
	set step2B2008;
	if (buyer='C' | buyer='A') then
		delete;
run;



*Keep only dealer for the sellers;

data SellTrades;
	set step2B2008;
	if (seller='C' | seller='A') then
		delete;
run;



data perm.BuyTrades;
set BuyTrades;
run;



data perm.SellTrades;
set SellTrades;
run;

data BuyTrades;
	set BuyTrades;
	trade_id=_N_;
	BuyOrSell='B';
	rename buyer=player;
run;


data SellTrades;
	set SellTrades;
	Strade_id=_N_;
	BuyOrSell='S';
	rename seller=player;
run;

proc sort data=BuyTrades;
	by CUSIP_ID TRD_EXCTN_DT player ENTRD_VOL_QT TRD_EXCTN_TM;
run;

proc sort data=SellTrades;
	by CUSIP_ID TRD_EXCTN_DT player ENTRD_VOL_QT TRD_EXCTN_TM;
run;


*We Only need to Build a Bridge to identify the first roundtrip trade so keep only necessary variables;

data BuyTrades;
	set BuyTrades(keep=CUSIP_ID TRD_EXCTN_DT player trade_id ENTRD_VOL_QT TRD_EXCTN_TM 
		FirstId BuyOrSell RPTD_PR);
run;


data SellTrades;
	set SellTrades(keep=CUSIP_ID TRD_EXCTN_DT player Strade_id ENTRD_VOL_QT 
		TRD_EXCTN_TM FirstId BuyOrSell RPTD_PR);
run;



*Build a bridge between buy, sell trade with FirstId;

data BuyIdAndFirstId;
	set BuyTrades(keep=trade_id FirstId);
run;

data BuyIdAndFirstId;
	set BuyIdAndFirstId;
	rename trade_id=buy_id;
run;

data SellIdAndFirstId;
	set SellTrades(keep=Strade_id FirstId);
run;

data SellIdAndFirstId;
	set SellIdAndFirstId;
	rename Strade_id=sell_id;
run;



********************************************************************************************************************************************************************************************
*
*Identify roundtrip trade, first type;
*
***********************************************************************************************************************************************************************************************;


proc sql  _METHOD;
	create table match1 as select a.*, b.player as SPlayer, b.Strade_id , b.ENTRD_VOL_QT as SENTRD_VOL_QT,
	b.TRD_EXCTN_DT as STRD_EXCTN_DT, b.CUSIP_ID as SCUSIP_ID,
		b.TRD_EXCTN_TM as STRD_EXCTN_TM, b.FirstId as SFirstId, abs(b.TRD_EXCTN_TM-a.TRD_EXCTN_TM) as 
		tradetime_dist1 from BuyTrades as a, SellTrades as b where 
		a.CUSIP_ID=b.CUSIP_ID and a.TRD_EXCTN_DT=b.TRD_EXCTN_DT and a.player=b.player 
		and a.ENTRD_VOL_QT=b.ENTRD_VOL_QT order by trade_id;
	quit; 


	%let dsid=%sysfunc(open(match1));
	%let nobs=%sysfunc(attrn(&dsid, nlobs));
	%let dsid=%sysfunc(close(&dsid));
	%put nobs= &nobs ;


data match1;
set match1;
if FirstId=SFirstId then delete;
run;


%macro exactmatch;
	%do %while(&nobs>=1);

		data matched1;
			set match1;
		run;

		proc sort data=matched1 out=matched1;
			by trade_id tradetime_dist1;
		run;

		proc sort data=matched1 nodupkey;
			by trade_id;
		run;

		proc sort data=matched1;
			by Strade_id tradetime_dist1;
		run;

		proc sort data=matched1 nodupkey;
			by Strade_id;
		run;

		data buyid;
		set matched1(keep=trade_id);
		run;

		data sellid;
		set matched1(keep=Strade_id);
		run;

		proc sort data=buyid;
		by trade_id;
		run;

		proc sort data=sellid;
		by Strade_id;
		run;

		proc sort data=match1;
		by trade_id;
		run;

		data match1;
		merge buyid(in=q1) match1(in=q2);
		by trade_id;
		if q2;
		if q1 and q2 then delete;
		run;

		proc sort data=match1;
		by Strade_id;
		run;

		data match1;
		merge sellid(in=q1) match1(in=q2);
		by Strade_id;
		if q2;
		if q1 and q2 then delete;
		run;

	
		proc append base=matchlist1 data=matched1;
		run;

		%let dsid=%sysfunc(open(match1));
		%let nobs=%sysfunc(attrn(&dsid, nlobs));
		%let dsid=%sysfunc(close(&dsid));
		%put nobs= &nobs ;
	%end;

%mend exactmatch;

%exactmatch;



proc sort data=matchlist1;
	by trade_id Strade_id;
run;


data perm.matchlist1;
set matchlist1;
run;


data FirstId;
	set matchlist1(keep=FirstId);
run;


data SFirstId;
	set matchlist1(keep=SFirstId);
run;


data SFirstId;
	set SFirstId;
	rename SFirstId=FirstId;
run;

proc sort data=FirstId;
by FirstId;
run;

proc sort data=SFirstId;
by FirstId;
run;

proc sort data=BuyTrades;
by FirstId;
run;



proc sort data=SellTrades;
by FirstId;
run;


data UBuyTrades1;
merge BuyTrades  FirstId(in=qq);
by FirstId;
if qq=0;
run;


data USellTrades1;
merge SellTrades SFirstId(in=qq);
by FirstId;
if qq=0;
run;

***************************************************************************************************************************************************************************************;
*
*Check Wether Match is Correct Or Not!
*
***************************************************************************************************************************************************************************************;


proc sort data=UBuyTrades1;
by CUSIP_ID TRD_EXCTN_DT player ENTRD_VOL_QT;
run;

proc sort data=USellTrades1;
by CUSIP_ID TRD_EXCTN_DT player ENTRD_VOL_QT;
run;


proc sql  _METHOD;
	create table perm.match1check as select a.*, b.player as SPlayer, b.Strade_id , b.ENTRD_VOL_QT as SENTRD_VOL_QT,
	b.TRD_EXCTN_DT as STRD_EXCTN_DT, b.CUSIP_ID as SCUSIP_ID,
		b.TRD_EXCTN_TM as STRD_EXCTN_TM, b.FirstId as SFirstId, abs(b.TRD_EXCTN_TM-a.TRD_EXCTN_TM) as 
		tradetime_dist1 from UBuyTrades1 as a, USellTrades1 as b where 
		a.CUSIP_ID=b.CUSIP_ID and a.TRD_EXCTN_DT=b.TRD_EXCTN_DT and a.player=b.player 
		and a.ENTRD_VOL_QT=b.ENTRD_VOL_QT order by trade_id;
	quit; 




**************************************************************************************************************************************************************************************************;
*Rename The Variables In Unmatched Sell Trade;
**************************************************************************************************************************************************************************************************;




data USellTrades1;
	set USellTrades1;
	rename TRD_EXCTN_DT=STRD_EXCTN_DT player=Splayer ENTRD_VOL_QT=SENTRD_VOL_QT TRD_EXCTN_TM=STRD_EXCTN_TM FirstId=SFirstId BuyOrSell=SBuyOrSell
    RPTD_PR=SRPTD_PR;
run;


*********************************************************************************************************************************************************************************************
*Create the necessary data set to Identify Second Type roundtrip trade;
**********************************************************************************************************************************************************************************************;

proc sort data=UBuyTrades1;
by CUSIP_ID player TRD_EXCTN_DT TRD_EXCTN_TM;
run;


proc sort data=USellTrades1;
by CUSIP_ID Splayer STRD_EXCTN_DT STRD_EXCTN_TM;
run;



proc sql;
create table perm.match2 as select a.*, b.Splayer, b.Strade_id , b.SENTRD_VOL_QT,
	b.STRD_EXCTN_DT, b.STRD_EXCTN_TM, b.SFirstId, abs(b.STRD_EXCTN_TM-a.TRD_EXCTN_TM) as 
		tradetime_dist2 from UBuyTrades1 as a, USellTrades1 as b where 
		a.CUSIP_ID=b.CUSIP_ID and a.TRD_EXCTN_DT=b.STRD_EXCTN_DT and a.player=b.Splayer
    order by trade_id;
quit;


proc sort data=perm.match2;
by FirstId;
run;

data totaltime(keep=FirstId TtimeDistance) ;
set perm.match2;
retain TtimeDistance;
by FirstId;
if First.FirstId then TtimeDistance=0;
TtimeDistance=TtimeDistance+tradetime_dist2;
if last.FirstId then output;
run;


proc sort data=totaltime;
by FirstId;
run;


proc sql;
create table perm.match2 as select a.*, b.TtimeDistance from perm.match2 as a, totaltime as b where 
		a.FirstId=b.FirstId
    order by FirstId;
quit;


data sameday;
set perm.match2(keep=player CUSIP_ID TRD_EXCTN_DT);
run;

proc sort data=sameday out=sameday nodupkey;
by player CUSIP_ID TRD_EXCTN_DT;
run;

data sameday;
set sameday;
sameday=_N_;
run;


proc sort data=perm.match2;
by player CUSIP_ID TRD_EXCTN_DT;
run;


proc sql;
	create table perm.match2 as select * from perm.match2 as a, 
		sameday as b where a.player=b.player and a.CUSIP_ID=b.CUSIP_ID and
        a.TRD_EXCTN_DT=b.TRD_EXCTN_DT;
quit;


proc sort data=perm.match2;
by player CUSIP_ID TRD_EXCTN_DT TtimeDistance FirstID tradetime_dist2;
run;


data selectmatch2(keep=sameday FirstId ENTRD_VOL_QT SFirstId SENTRD_VOL_QT) ;
set perm.match2;
run;

proc export data=selectmatch2
      outfile='E:\csvdatatwoyear\selectmatch22.csv'
      dbms=dlm replace;  
      delimiter=',';
run;




* Create a dataset that store the location of each sameday group on the orginal dataset;

data samedaylocation;
set selectmatch2;
retain start1;
retain end1;
by sameday;
if FIRST.sameday then start1=_n_;
if LAST.sameday then end1=_n_;
run;

data samedaylocation;
set samedaylocation(keep=sameday start1 end1);
run;

proc sort data=samedaylocation out =samedaylocation;
by descending start1 descending end1;
run;
proc sort data=samedaylocation nodupkey out=samedaylocation;
by sameday;
run;


proc export data=samedaylocation
      outfile='E:\csvdatatwoyear\samedaylocation2.csv'
      dbms=dlm replace;  
      delimiter=',';
run;


data perm.UBuyTrades1;
set UBuyTrades1;
run;

data perm.USellTrades1;
set USellTrades1;
run;


/*  This Part Output the Step2B2008  to Perm File */

data perm.step2B2008;
set step2B2008;
run;


data perm.FirstId;
set FirstId;
run;

data perm.SFirstId;
set SFirstId;
run;
