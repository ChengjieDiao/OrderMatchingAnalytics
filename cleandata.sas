

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


libname check'E:\check';




*libname perm0'D:\tryscratch';
*libname fsid'D:\MergentData';
*libname perm'D:\tryscratch';

%let startday='01JAN2007'D;
%let RatingStartDay='01JAN06'D;
%let endday='31MAR09'D;







*****************************************************************************
******************************** ERROR FILTER *******************************
*****************************************************************************
*
**************************
*
* POST 2012 change
*
**************************
*
* Cleans data reported after Feb 6th, 2012.
* The coding and reporting structure changed with the transition
* to the TRAQS reporting system.
* Specifically, the link between a reversal and the original
* transaction is now unique and transperant;
*
* Report the party executing the trade in the RPTG_PARTY_ID field;
data post_2012;
set perm0.ab2;
if RPTG_PARTY_GVP_ID^='' then RPTG_PARTY_ID=RPTG_PARTY_GVP_ID;
if CNTRA_PARTY_GVP_ID^='' then CNTRA_PARTY_ID=CNTRA_PARTY_GVP_ID;
if PRDCT_SBTP_CD='CORP' then PRDCT_SBTP_CD='C';
run;
*;
data temp_raw
temp_deleteI_NEW (keep = cusip_id entrd_vol_qt rptd_pr
trd_exctn_dt trd_exctn_tm rpt_side_cd cntra_party_id
cntra_party_gvp_id systm_cntrl_nb)
temp_deleteII_NEW (keep = cusip_id entrd_vol_qt rptd_pr
trd_exctn_dt trd_exctn_tm rpt_side_cd cntra_party_id
cntra_party_gvp_id prev_trd_cntrl_nb trd_rpt_dt trd_rpt_tm);
set post_2012;
* Deletes observations without a cusip_id;
if cusip_id = '' then delete;
* Takes out all cancellations and corrections;
* These transactions should be deleted together with the
* original report;
if trd_st_cd in ('X','C') then output temp_deleteI_NEW;
* Reversals. These have to be deteled as well together with
* the original report;
else if trd_st_cd in ('Y') then output temp_deleteII_NEW;
* The rest of the data;
else output temp_raw;
run;
*
* Deletes the cancellations and corrections as identified by
* the reports in temp_deleteI_NEW;
* These transactions can be matched by message sequence number
* and date. We furthermore match on cusip, volume, price, date,
* time, buy-sell side, contra party;
* This is as suggested by the variable description;
proc sql;
CREATE TABLE temp_raw2 AS
select * from temp_raw as a,
( (select cusip_id, entrd_vol_qt, rptd_pr, trd_exctn_dt,
trd_exctn_tm, rpt_side_cd, cntra_party_id, cntra_party_gvp_id,
systm_cntrl_nb from temp_raw)
except
(select cusip_id, entrd_vol_qt, rptd_pr, trd_exctn_dt,
trd_exctn_tm, rpt_side_cd, cntra_party_id, cntra_party_gvp_id,
systm_cntrl_nb
from temp_deleteI_NEW) ) as b
where a.cusip_id=b.cusip_id
and a.entrd_vol_qt=b.entrd_vol_qt
and a.rptd_pr=b.rptd_pr
and a.trd_exctn_dt=b.trd_exctn_dt
and a.trd_exctn_tm= b.trd_exctn_tm
and a.rpt_side_cd=b.rpt_side_cd
and a.cntra_party_id=b.cntra_party_id
and a.systm_cntrl_nb=b.systm_cntrl_nb;
quit;
*
* Deletes the reports that are matched by the reversals;
proc sql;
CREATE TABLE temp_raw3_NEW AS
select * from temp_raw2 as a,
( (select cusip_id, entrd_vol_qt, rptd_pr, trd_exctn_dt,
trd_exctn_tm, rpt_side_cd, cntra_party_id, cntra_party_gvp_id,
systm_cntrl_nb from temp_raw2)
except
(select cusip_id, entrd_vol_qt, rptd_pr, trd_exctn_dt,
trd_exctn_tm, rpt_side_cd, cntra_party_id, cntra_party_gvp_id,
prev_trd_cntrl_nb
from temp_deleteII_NEW) ) as b
where a.cusip_id=b.cusip_id
and a.entrd_vol_qt=b.entrd_vol_qt
and a.rptd_pr=b.rptd_pr
and a.trd_exctn_dt=b.trd_exctn_dt
and a.trd_exctn_tm= b.trd_exctn_tm
and a.rpt_side_cd=b.rpt_side_cd
and a.cntra_party_id=b.cntra_party_id
and a.systm_cntrl_nb=b.systm_cntrl_nb;
quit;
*
* Save reversals referring to trades before Feb 6th, 2012;
data unmatched;
set temp_deleteII_NEW;
if trd_exctn_dt<'06FEB2012'd;
run;
*
* Delete temporary datasets;
proc delete data=post_2012 temp_deleteii_new temp_deletei_new temp_raw
temp_raw2; run;
*
* Ends the filtering of the post-change data;
*
*
**************************
*
* PRE 2012 change
*
**************************;
*
* Report the party executing the trade in the RPTG_PARTY_ID field;
data pre_2012;
set perm0.ab1;
if RPTG_SIDE_GVP_MP_ID^='' then RPTG_MKT_MP_ID=RPTG_SIDE_GVP_MP_ID;
if CNTRA_GVP_ID^='' then CNTRA_MP_ID=CNTRA_GVP_ID;
run;
*
* Takes same-day corrections and splits them into two data sets;
* 1 for all the correct trades, and 1 for the corrections;
data temp_raw temp_delete (keep = TRD_RPT_DT PREV_REC_CT_NB);
set pre_2012;
* Deletes observations without a cusip_id;
if cusip_id = '' then delete;
* Takes out all cancellations into the temp_delete dataset;
if trc_st = 'C' then output temp_delete;
* All corrections are put into both datasets;
else if trc_st = 'W' then output temp_delete temp_raw;
else output temp_raw;
run;
*
* Deletes the error trades as identified by the message
* sequence numbers. Same day corrections and cancelations;
proc sql;
CREATE TABLE temp_raw2 AS
select * from temp_raw as a,
( (select REC_CT_NB, TRD_RPT_DT from temp_raw)
except
(select PREV_REC_CT_NB, TRD_RPT_DT from temp_delete) ) as b
where a.REC_CT_NB=b.REC_CT_NB and a.TRD_RPT_DT =b.TRD_RPT_DT ;
quit;
*
* Take out reversals into a dataset;
data reversal temp_raw3;
set temp_raw2;
N=_N_;
if asof_cd='R' then output reversal;
else output temp_raw3;
run;
*
* Include reversals referring to transactions before February 6th, 2012 that
* are reported after this date;
data unmatched;
set unmatched;
keep trd_exctn_dt cusip_id trd_exctn_tm rptd_pr entrd_vol_qt rpt_side_cd
cntra_party_id trd_rpt_dt trd_rpt_tm;
rename TRD_EXCTN_TM=EXCTN_TM CNTRA_PARTY_ID=CNTRA_MP_ID;
run;
data reversal;
set reversal unmatched;
run;
*
* Check for duplicates;
proc sort data=reversal (drop = N) nodupkey; by trd_exctn_dt
cusip_id exctn_tm rptd_pr entrd_vol_qt rpt_side_cd cntra_mp_id
trd_rpt_dt trd_rpt_tm REC_CT_NB; run;
*
* Determine the reporting date and time;
data temp_raw3;
set temp_raw3;
datetime=dhms(trd_rpt_dt,0,0,trd_rpt_tm);
format datetime datetime.;
run;
*
* Asign a unique id to each reversal and determine the reporting date
* and time;
data reversal;
set reversal;
rev_id=_N_;
datetime=dhms(trd_rpt_dt,0,0,trd_rpt_tm);
format datetime datetime.;
run;
*
* Identify all transactions that matches the reversals;
proc sql;
create table reversal2
as select a.*, b.rev_id, (b.datetime-a.datetime) as datetime_dist
from temp_raw3 as a, reversal as b
where a.trd_exctn_dt=b.trd_exctn_dt
and a.cusip_id=b.cusip_id
and a.exctn_tm=b.exctn_tm
and a.rptd_pr=b.rptd_pr
and a.entrd_vol_qt=b.entrd_vol_qt
and a.rpt_side_cd=b.rpt_side_cd
and a.cntra_mp_id=b.cntra_mp_id
/* Reversals must be reported after the matching transaction */
and a.datetime<b.datetime
order by N;
quit;
*
* Keep the earliest transaction (in a chronological sense) that matches each
* reversal;
proc sort data=reversal2; by rev_id datetime_dist; run;
proc sort data=reversal2 nodupkey; by rev_id; run;
*
* Sort the data;
proc sort data=reversal2; by N; run;
proc sort data=temp_raw3; by N; run;
*
* Deletes the matching reversals;
data temp_raw4;
merge reversal2 (in=qq) temp_raw3;
by N;
if qq=0;
drop rev_id datetime datetime_dist;
run;
*
* Delete temporary datasets;
proc delete data=pre_2012 reversal reversal2 temp_delete temp_raw3 unmatched;
run;
*
* Ends the filter for PRE-change data;
*
*
**************************
*
* Combines the PRE and POST data into one;
*
**************************
*Rename variables before merging;
data temp_raw4;
set temp_raw4;
rename RPTG_MKT_MP_ID=RPTG_PARTY_ID RPTG_SIDE_GVP_MP_ID=RPTG_PARTY_GVP_ID
CNTRA_MP_ID=CNTRA_PARTY_ID CNTRA_GVP_ID=CNTRA_PARTY_GVP_ID
EXCTN_TM=TRD_EXCTN_TM WIS_CD=WIS_DSTRD_CD CMSN_TRD_FL=CMSN_TRD;
run;
data temp_raw3_new;
set temp_raw3_new;
rename ISSUE_SYM_ID=BOND_SYM_ID CALCD_YLD_PT=YLD_PT
BUYER_CMSN_AMT=BUY_CMSN_RT SLLR_CMSN_AMT=SELL_CMSN_RT
NO_RMNRN_CD=CMSN_TRD YLD_DRCTN_CD=YLD_SIGN_CD
SLLR_CPCTY_CD=SELL_CPCTY_CD BUYER_CPCTY_CD=BUY_CPCTY_CD
PBLSH_FL=DISSEM_FL PRDCT_SBTP_CD=SCRTY_TYPE_CD TRD_ST_CD=TRC_ST;
run;
*
* Merge the two datasets;
data temp_raw_comb (drop = N asof_cd trd_rpt_dt trd_rpt_tm
systm_cntrl_nb prev_trd_cntrl_nb trc_st REC_CT_NB PREV_REC_CT_NB);
set temp_raw4 temp_raw3_NEW;
run;
*
* Delete temporary datasets;
proc delete data=temp_raw3_new temp_raw4; run;
*
*
**************************
*
* Agency transaction filtering
*
**************************
*
* This step deletes agency transactions but is not part
* of the error detection filter. This step can be deleted if
* you want to keep all agency transactions;
*
* Deletes agency customer transactions without commission;
* These transactions will have the same price as the
* interdealer transaction (if reported correctly);
data temp_raw6 (drop = agency);
set temp_raw_comb;
* Identifies agency transactions;
if rpt_side_cd='B' then agency=buy_cpcty_cd;
else if rpt_side_cd='S' then agency=sell_cpcty_cd;
* Deletes agency transactions which are dealer-customer
* transactions without commission;
*if agency='A' and cntra_party_id = 'C' and CMSN_TRD = 'N' then delete;
run;
*
**************************
*
* Deletes interdealer transactions (one of the sides)
*
**************************
*
*Sort the data and assign a unique id to each observation;
proc sort data=temp_raw6; by cusip_id trd_exctn_dt trd_exctn_tm; run;
data temp_raw6;
set temp_raw6;
id=_N_;
run;
*
*Identify all inter-dealer trades;
data inter_dealer;
set temp_raw6;
if cntra_party_id='C' then delete;
run;
*
*Keep all inter-dealer buys;
data dealer_buys;
set inter_dealer;
if rpt_side_cd='B';
run;
*
*Identify matching inter-dealer transactions;
proc sql;
create table matches
as select a.*, b.id as match_id
from inter_dealer as a, dealer_buys as b
where a.cusip_id=b.cusip_id
and a.trd_exctn_dt=b.trd_exctn_dt
and a.entrd_vol_qt=b.entrd_vol_qt
and a.rptd_pr=b.rptd_pr
and a.rptg_party_id=b.cntra_party_id
and a.cntra_party_id=b.rptg_party_id
and a.rpt_side_cd='S'
order by id;
quit;
*
*Delete one side of each inter-dealer transaction (double counting);
proc sort data=temp_raw6; by id; run;
data temp_raw7;
merge temp_raw6(in=q) matches(in=qq);
by id;
if qq=0;
drop id match_id;
run;

*
*Export the final dataset;
data total;
set temp_raw7;
*Deletes WI trades;
if WIS_DSTRD_CD = 'Y' then delete;
* Deletes trades which are not secondary market;
if TRDG_MKT_CD in ('S2','P1','P2') then delete;
* Deletes if it trades under special circumstances;
if SPCL_PR_FL = 'Y' then delete;
* Deletes if it is an equity linked note;
if SCRTY_TYPE_CD = 'C';
* If days to settlement is very non-standard then
* delete it (6 is arbitrary). From a certain date the
* settlement date is given instead of the days to settle;
*if DAYS_TO_STTL_CT<6;
* Deletes if it is not a cash sale;
*if sale_cndtn_cd = 'C';
* Deletes commissioned trades;
* if CMSN_TRD in ('C','Y') then delete;
* Deletes a trade if it is an automatic give up;
*if AGU_QSR_ID in ('A','Q') then delete;
if rptd_pr le 1 then delete;
if entrd_vol_qt le 1 then delete;
run;







data total;
set total;
if RPTG_PARTY_ID=CNTRA_PARTY_ID  then delete;
if ENTRD_VOL_QT=. then delete;
run;

proc sort data=total;
by cusip_id trd_exctn_dt;
run;

data total;
set total;
FirstId=_N_;
agencyid=0;
hcommission=0;
if (buy_cpcty_cd='A'|sell_cpcty_cd='A') then agencyid=1;
if (CMSN_TRD='Y' or CMSN_TRD='C') then hcommission=1;
run;


data perm0.RAWtotal;
set total;
run;


*data perm.RAWtotalSmall;
*set total;
*if (trd_exctn_dt>&startday & trd_exctn_dt<&endday) then output;
*run;
