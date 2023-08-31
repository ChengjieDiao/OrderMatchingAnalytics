

*********************************************************************************************************************************************************************************************
*
** This Code Match The Roundtrip Spread With The Same Ideology In The Paper: Providing Liquidity in an Illiquid Market: Dealer Behavior in U.S. Corporate Bonds, Goldstein And Hockiss 2020
*
**********************************************************************************************************************************************************************************************;
*
***************************Chengjie Diao*************************************************************************************************************************************************
***********************Queen's Unviersity, Economics Department*******************************
**********************************************************************************************************************************************************************************************;


proc datasets library=work kill;
run;
quit;

*libname perm'/scratch/queensu/cjdiao/total';
*ODS HTML FILE='/scratch/queensu/cjdiao/total/TEMP.XLS';


*libname fsid'E:\MergentData';
*libname perm0'E:\MainData\data';
*libname perm'E:\datatwoyear';


libname check'G:\check';




libname perm0'G:\tryscratch';
libname fsid'G:\MergentData';
libname perm'G:\tryscratch';

%let startday='01DEC2008'D;
%let endday='31DEC12'D;




******************************************************************************************************************************************************************************************
*
** Clean The Trace Academic Data, This Part Of The Code Is Obtained From Jens Dick-Nielsen Website: How to Clean ACADEMIC TRACE data;
*
****************************************************************************************************************************************************************************************;



*********************************************************************************************************************************************************************************************
*
** This Code Match The Roundtrip Spread With The Same Ideology In The Paper: Providing Liquidity in an Illiquid Market: Dealer Behavior in U.S. Corporate Bonds, Goldstein And Hockiss 2020
*
**********************************************************************************************************************************************************************************************;
*
***************************Chengjie Diao*************************************************************************************************************************************************
***********************Queen's Unviersity, Economics Department*******************************
**********************************************************************************************************************************************************************************************;







**************************************************************************************************************************************************************************************************
*
*Perform Goldstein and Hotchiss
*
**************************************************************************************************************************************************************************************************;


*************************************************************************************************************
** First Step : delete bond do not trade at least once within 60 days after offering date and delete bond 
** can not match with FSID, delete convertable bond;
*************************************************************************************************************;



*  Merge With FSID dataset;



data perm.RAWtotalSmall;
set perm0.RAWtotal(obs=10000);
if (trd_exctn_dt>&startday & trd_exctn_dt<&endday) then output;
run;




data total(drop=TRD_MDFR_LATE_CD TRD_MDFR_SRO_CD LCKD_IN_FL ATS_FL SYSTM_CNTRL_DT PREV_TRD_CNTRL_DT PREV_TRD_CNTRL_DT SYSTM_CNTRL_DT DISSEM_FL SPCL_PR_FL AGU_TRD_ID CNTRA_PARTY_GVP_ID SELL_CPCTY_CD SELL_CMSN_RT BUY_CPCTY_CD BUY_CMSN_RT SALE_CNDTN2_CD WIS_DSTRD_CD CMSN_TRD RPTG_PARTY_GVP_ID BOND_SYM_ID TRD_STLMT_DT SALE_CNDTN_CD);
set perm.RAWtotalSmall;
run;

data total;
set total;
if cusip_id='' then delete;
run;



data fsidmerged2;
set fsid.FsidNoRating;
keep issue_id issuer_id offering_date offering_amt rule_144a foreign_currency cusip_id convertible maturity perpetual;
run;

proc sql;
create table total as select * from total as a left join fsidmerged2 as b
on a.cusip_id=b.cusip_id;
run;


proc delete data=fsidmerged2;run;


data rating;
set fsid.rating;
run;

data rating_hist;
set fsid.rating_hist;
run;

proc append base=rating data=rating_hist force;run;


data rating;set rating; keep issue_id rating_type rating_date rating reason;run;

data rating;
set rating;
if rating='' then delete;
run;



data rating;
	set rating;
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
	else if rating='NR' then
		Nrating='NR';
	else
		Nrating=rating;
run;

data rating;
	set rating;
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
		ratingScore=23;
	else ratingScore=23;
run;



data total2;
set total(keep=FirstId cusip_id TRD_EXCTN_DT issue_id);
run;


data rating;set rating;format rating_date mmddyy10.;rename rating_date=trd_exctn_dt;run;
proc sort data=rating;by issue_id trd_exctn_dt;run;


proc sort data=total2;by issue_id trd_exctn_dt;run;

data total2;merge total2 (in=a) rating (in=b);by issue_id trd_exctn_dt;if a;run;
/*If missing daily rating retain previous day rating*/
data total2;set total2;by issue_id;retain ratingScore2 Nrating2 Rating2;
if ratingScore ne . then ratingScore2=ratingScore;else ratingScore2=ratingScore2;
if Nrating ne '' then Nrating2=Nrating; else Nrating2=Nrating2;
if rating ne '' then rating2=rating; else rating2=rating2;
drop rating Nrating ratingScore;
run;

data total2;
set total2;
rename rating2=rating Nrating2=Nrating ratingScore2=ratingScore;
run;




proc sort data=total2 NODUPKEY;
	  by FirstId;
run;


data total2;
set total2(drop=cusip_id TRD_EXCTN_DT);
run;




proc sql;
create table total as select * from total as a left join total2 as b
on a.FirstId=b.FirstId;
quit;



proc delete data=total2;run;

proc sort data=total;
by cusip_id;
run;




data AMOUNT_OUTSTANDING;
set fsid.AMOUNT_OUTSTANDING;
run;

data AMT_OUT_HIST;
set fsid.AMT_OUT_HIST;
run;

data issue;
set fsid.issue;
run;


proc append base=AMOUNT_OUTSTANDING data=AMT_OUT_HIST force; run;

proc sql;create table amtOS as select * from issue as a left join AMOUNT_OUTSTANDING as b on a.issue_id=b.issue_id;quit;

data perm.amtOS;set amtOS;if (offering_amt ne amount_outstanding) and action_type not in ('IM');keep issue_id effective_date amount_outstanding;run;


/*13B) Delete primary market trades*/
data total;set total;if TRDG_MKT_CD eq 'P1' then delete;run;

/*14B) Determine changes to amount outstanding*/
proc sort data=total;by issue_id;run;

data total2;set total;keep FirstId issue_id TRD_EXCTN_DT;run;

/*Merge trade data with 'amtOSJF' file by issue_id. Keep only issues with 
change to amount outstanding*/
proc sort data=perm.amtOS;by issue_id;run;
data total3;merge total2 (in=a) perm.amtOS (in=b);by issue_id;if a and b;run;
/*effective_date is 'The date on which the change to the issue's amount 
outstanding became effective' in FISD.*/
data total3;set total3;if TRD_EXCTN_DT lt effective_date then delete;run;
proc sort data=total3;by FirstId issue_id TRD_EXCTN_DT descending
effective_date;run;
proc sort data=total3 nodupkey;by FirstId issue_id TRD_EXCTN_DT;run;
proc sort data=total;by FirstId;run;
data total;merge total (in=a) total3 (in=b);by FirstId;if a;run;
/*If change to 'amount_outstanding' then the final amount outstanding finOS 
is set to amount_outstanding*/
/*If no change to 'amount_outstanding' then the final amount outstanding 
finOS is set to the offering amount*/
/*Create 'enddt' variable. If change to 'amount_outstanding' that results in 
0 outstanding, enddt is the effective_date, otherwise enddt is the maturity 
date.*/

data total;set total;if amount_outstanding ne . then
finOS=amount_outstanding;else finOS=offering_amt;
if finOS=0 then enddt=effective_date;else enddt=maturity;format enddt 
YYMMDDN8.;run;


/*15B) Delete trades after end date*/
data total;set total;if enddt^=. and TRD_EXCTN_DT gt enddt then delete;run;




data total;
set total;
if MTRTY_DT =. then MTRTY_DT=maturity;
run;




data perm.totalmerged;
set total;
run;


proc datasets library=work kill;
run;
quit;
