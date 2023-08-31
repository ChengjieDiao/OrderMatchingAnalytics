

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


libname fsid'E:\MergentData';
libname perm0'E:\MainData\data';
libname perm'E:\datatwoyear';


*libname check'G:\check';




*libname perm0'G:\tryscratch';
*libname fsid'G:\MergentData';
*libname perm'G:\tryscratch';

%let startday='01DEC2008'D;
%let endday='31DEC12'D;


data total;
set perm.total;

data total2;
set perm.total2;
run;



proc sql;
create table perm.total as select * from total as a left join total2 as b
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
data total;set total;if TRD_EXCTN_DT gt enddt then delete;run;




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
