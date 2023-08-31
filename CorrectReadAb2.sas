*proc printto log="E:\MainData\data\CleanData3.txt";
*run;

libname perm'E:\MainData\data';
ods listing close;

%let number1=0;

%macro academic(foopath,member);
filename foo1 ZIP "&foopath" member="&member" ;
data temp1;
%let _EFIERR_ = 0;
infile foo1 delimiter = '|' MISSOVER DSD lrecl=32767 firstobs=2;
informat REC_CT_NB best32.;
informat TRC_ST $1.;
informat BOND_SYM_ID $14.;
informat CUSIP_ID $10.;
informat RPTG_MKT_MP_ID $40.;
informat RPTG_SIDE_GVP_MP_ID $40.;
informat SCRTY_TYPE_CD $5.;
informat WIS_CD $1.;
informat CMSN_TRD_FL $1.;
informat ENTRD_VOL_QT best32.;
informat RPTD_PR best32.;
informat YLD_SIGN_CD $1.;
informat YLD_PT best32.;
informat ASOF_CD $1.;
informat TRD_EXCTN_DT YYMMDD8.;
informat EXCTN_TM HHMMSS6.;
informat TRD_RPT_DT YYMMDD8.;
informat TRD_RPT_TM HHMMSS6.;
informat TRD_STLMT_DT YYMMDD8.;
informat SALE_CNDTN_CD $3.;
informat SALE_CNDTN2_CD $3.;
informat RPT_SIDE_CD $1.;
informat BUY_CMSN_RT best32.;
informat BUY_CPCTY_CD $1.;
informat SELL_CMSN_RT best32.;
informat SELL_CPCTY_CD $1.;
informat CNTRA_MP_ID $40.;
informat CNTRA_GVP_ID $40.;
informat AGU_TRD_ID $1.;
informat SPCL_PR_FL $1.;
informat TRDG_MKT_CD $2.;
informat DISSEM_FL $1.;
informat PREV_REC_CT_NB best32.;

format REC_CT_NB best32.;
format TRC_ST $1.;
format BOND_SYM_ID $14.;
format CUSIP_ID $10.;
format RPTG_MKT_MP_ID $40.;
format RPTG_SIDE_GVP_MP_ID $40.;
format SCRTY_TYPE_CD $5.;
format WIS_CD $1.;
format CMSN_TRD_FL $1.;
format ENTRD_VOL_QT best32.;
format RPTD_PR best32.;
format YLD_SIGN_CD $1.;
format YLD_PT best32.;
format ASOF_CD $1.;
format TRD_EXCTN_DT YYMMDDN8.;
format EXCTN_TM TIME8.;
format TRD_RPT_DT YYMMDDN8.;
format TRD_RPT_TM TIME8.;
format TRD_STLMT_DT YYMMDDN8.;
format SALE_CNDTN_CD $3.;
format SALE_CNDTN2_CD $3.;
format RPT_SIDE_CD $1.;
format BUY_CMSN_RT best32.;
format BUY_CPCTY_CD $1.;
format SELL_CMSN_RT best32.;
format SELL_CPCTY_CD $1.;
format CNTRA_MP_ID $40.;
format CNTRA_GVP_ID $40.;
format AGU_TRD_ID $1.;
format SPCL_PR_FL $1.;
format TRDG_MKT_CD $2.;
format DISSEM_FL $1.;
format PREV_REC_CT_NB best32.;

input

REC_CT_NB
TRC_ST$
BOND_SYM_ID$
CUSIP_ID$
RPTG_MKT_MP_ID$
RPTG_SIDE_GVP_MP_ID$
SCRTY_TYPE_CD$
WIS_CD$
CMSN_TRD_FL$
ENTRD_VOL_QT

RPTD_PR
YLD_SIGN_CD$
YLD_PT
ASOF_CD$
TRD_EXCTN_DT
EXCTN_TM
TRD_RPT_DT
TRD_RPT_TM
TRD_STLMT_DT
SALE_CNDTN_CD$
SALE_CNDTN2_CD$
RPT_SIDE_CD$
BUY_CMSN_RT
BUY_CPCTY_CD$
SELL_CMSN_RT
SELL_CPCTY_CD$
CNTRA_MP_ID$
CNTRA_GVP_ID$
AGU_TRD_ID$
SPCL_PR_FL$
TRDG_MKT_CD$
DISSEM_FL$
PREV_REC_CT_NB
;

if _ERROR_ then call symputx('_EFIERR_',1);
run;



data problem1;
set temp1;
if missing(CUSIP_ID) then output;
run;





data _NULL_;
	if 0 then set problem1 nobs=n;
	call symputx('nproblems',n);
	stop;
run;




data temp1;
set temp1;
if missing(cusip_id) then delete;
run;



data _NULL_;
	if 0 then set temp1 nobs=n;
	call symputx('ncorrect',n);
	stop;
run;

%let cumulate=&number1;
%let number1=%sysevalf(&cumulate+&nproblems+&ncorrect);



%mend academic;



%macro bond(foopath2,member2);
filename foo2 ZIP "&foopath2" member="&member2" ;
data temp2;
%let _EFIERR_ = 0;
infile foo2 delimiter = '|' MISSOVER DSD lrecl=32767 firstobs=2;

informat FINRA_SCRTY_ID $14.;
informat CUSIP_ID $14.;
informat SYM_CD $14.;
informat CMPNY_NM $50.;
informat SUB_PRDCT_TYPE_CD $14.;
informat SCRTY_TYPE_CD $14.;
informat SCRTY_SBTP_CD $14.;
informat CPN_RT best32.;
informat CPN_TYPE_CD $14.;
informat TRD_RPT_EFCTV_DT YYMMDD10.;
informat MTRTY_DT YYMMDD10.;
informat TRACE_GRADE_CD $1.;
informat RULE_144A_FL $1.;
informat DSMTN_FL $1.;
informat ACCRD_INTRS_AM $1.;
informat CNVRB_FL $1.;

format FINRA_SCRTY_ID $14.;
format CUSIP_ID $14.;
format SYM_CD $14.;
format CMPNY_NM $50.;
format SUB_PRDCT_TYPE_CD $14.;
format SCRTY_TYPE_CD $14.;
format SCRTY_SBTP_CD $14.;
format CPN_RT best32.;
format CPN_TYPE_CD $14.;
format TRD_RPT_EFCTV_DT YYMMDD10.;
format MTRTY_DT YYMMDD10.;
format TRACE_GRADE_CD $1.;
format RULE_144A_FL $1.;
format DSMTN_FL $1.;
format ACCRD_INTRS_AM $1.;
format CNVRB_FL $1.;





input

FINRA_SCRTY_ID$
CUSIP_ID$
SYM_CD$
CMPNY_NM$
SUB_PRDCT_TYPE_CD$
SCRTY_TYPE_CD$
SCRTY_SBTP_CD$
CPN_RT
CPN_TYPE_CD$
TRD_RPT_EFCTV_DT
MTRTY_DT
TRACE_GRADE_CD$
RULE_144A_FL$
DSMTN_FL$
ACCRD_INTRS_AM$
CNVRB_FL$
;

if _ERROR_ then call symputx('_EFIERR_',1);
run;

data temp2;
set temp2;
*if missing(cusip_id) then delete;
run;

%mend bond;






%macro supplemental(foopath3,member3);
filename foo3 ZIP "&foopath3" member="&member3" ;
data temp3;
%let _EFIERR_ = 0;
infile foo3 delimiter = '|' MISSOVER DSD lrecl=32767 firstobs=2;

informat FINRA_SCRTY_ID $14.;
informat CUSIP_ID $14.;
informat SYM_CD $14.;
informat CMPNY_NM $50.;
informat SUB_PRDCT_TYPE_CD $14.;
informat SCRTY_TYPE_CD $14.;
informat SCRTY_SBTP_CD $14.;
informat CPN_RT best32.;
informat CPN_TYPE_CD $14.;
informat TRD_RPT_EFCTV_DT YYMMDD10.;
informat MTRTY_DT YYMMDD10.;
informat TRACE_GRADE_CD $1.;
informat RULE_144A_FL $1.;
informat DSMTN_FL $1.;
informat ACCRD_INTRS_AM $1.;
informat CNVRB_FL $1.;
informat EFCTV_DT YYMMDD10.;

format FINRA_SCRTY_ID $14.;
format CUSIP_ID $14.;
format SYM_CD $14.;
format CMPNY_NM $50.;
format SUB_PRDCT_TYPE_CD $14.;
format SCRTY_TYPE_CD $14.;
format SCRTY_SBTP_CD $14.;
format CPN_RT best32.;
format CPN_TYPE_CD $14.;
format TRD_RPT_EFCTV_DT YYMMDD10.;
format MTRTY_DT YYMMDD10.;
format TRACE_GRADE_CD $1.;
format RULE_144A_FL $1.;
format DSMTN_FL $1.;
format ACCRD_INTRS_AM $1.;
format CNVRB_FL $1.;
format EFCTV_DT YYMMDD10.;





input

FINRA_SCRTY_ID$
CUSIP_ID$
SYM_CD$
CMPNY_NM$
SUB_PRDCT_TYPE_CD$
SCRTY_TYPE_CD$
SCRTY_SBTP_CD$
CPN_RT
CPN_TYPE_CD$
TRD_RPT_EFCTV_DT
MTRTY_DT
TRACE_GRADE_CD$
RULE_144A_FL$
DSMTN_FL$
ACCRD_INTRS_AM$
CNVRB_FL$
;

if _ERROR_ then call symputx('_EFIERR_',1);
run;

data temp3;
set temp3(drop=EFCTV_DT);
*if missing(cusip_id) then delete;
run;

%mend supplemental;



%macro academic2(foopath4,member4);
filename foo4 ZIP "&foopath4" member="&member4" ;
data temp4;
%let _EFIERR_ = 0;
infile foo4 delimiter = '|' MISSOVER DSD lrecl=32767 firstobs=2;


informat REC_CT_NB best32.;
informat TRD_ST_CD $1.;
informat ISSUE_SYM_ID $14.;
informat CUSIP_ID $10.;
informat RPTG_PARTY_ID $40.;
informat RPTG_PARTY_GVP_ID $40.;
informat PRDCT_SBTP_CD $5.;
informat WIS_DSTRD_CD $1.;
informat NO_RMNRN_CD $1.;
informat ENTRD_VOL_QT best32.;
informat RPTD_PR best32.;
informat YLD_DRCTN_CD $1.;
informat CALCD_YLD_PT best32.;
informat ASOF_CD $1.;
informat TRD_EXCTN_DT YYMMDD8.;
informat TRD_EXCTN_TM HHMMSS6.;
informat TRD_RPT_DT YYMMDD8.;
informat TRD_RPT_TM HHMMSS6.;
informat TRD_STLMT_DT YYMMDD8.;
informat TRD_MDFR_LATE_CD $1.;
informat TRD_MDFR_SRO_CD $1.;
informat RPT_SIDE_CD $1.;
informat BUYER_CMSN_AMT best32.;
informat BUYER_CPCTY_CD $1.;
informat SLLR_CMSN_AMT best32.;
informat SLLR_CPCTY_CD $1.;
informat CNTRA_PARTY_ID $40.;
informat CNTRA_PARTY_GVP_ID $40.;
informat LCKD_IN_FL $1.;
informat ATS_FL $1.;
informat SPCL_PR_FL $1.;
informat TRDG_MKT_CD$ $2.;
informat PBLSH_FL $1.;
informat SYSTM_CNTRL_DT YYMMDD8.;
informat SYSTM_CNTRL_NB best32.;
informat PREV_TRD_CNTRL_DT YYMMDD8.;
informat PREV_TRD_CNTRL_NB best32.;



format REC_CT_NB best32.;
format TRD_ST_CD $1.;
format ISSUE_SYM_ID $14.;
format CUSIP_ID $10.;
format RPTG_PARTY_ID $40.;
format RPTG_PARTY_GVP_ID $40.;
format PRDCT_SBTP_CD $5.;
format WIS_DSTRD_CD $1.;
format NO_RMNRN_CD $1.;
format ENTRD_VOL_QT best32.;
format RPTD_PR best32.;
format YLD_DRCTN_CD $1.;
format CALCD_YLD_PT best32.;
format ASOF_CD $1.;
format TRD_EXCTN_DT YYMMDDN8.;
format TRD_EXCTN_TM TIME8.;
format TRD_RPT_DT YYMMDDN8.;
format TRD_RPT_TM TIME8.;
format TRD_STLMT_DT YYMMDDN8.;
format TRD_MDFR_LATE_CD $1.;
format TRD_MDFR_SRO_CD $1.;
format RPT_SIDE_CD $1.;
format BUYER_CMSN_AMT best32.;
format BUYER_CPCTY_CD $1.;
format SLLR_CMSN_AMT best32.;
format SLLR_CPCTY_CD $1.;
format CNTRA_PARTY_ID $40.;
format CNTRA_PARTY_GVP_ID $40.;
format LCKD_IN_FL $1.;
format ATS_FL $1.;
format SPCL_PR_FL $1.;
format TRDG_MKT_CD$ $2.;
format PBLSH_FL $1.;
format SYSTM_CNTRL_DT YYMMDDN8.;
format SYSTM_CNTRL_NB best32.;
format PREV_TRD_CNTRL_DT YYMMDDN8.;
format PREV_TRD_CNTRL_NB best32.;




input

REC_CT_NB
TRD_ST_CD$
ISSUE_SYM_ID$
CUSIP_ID$
RPTG_PARTY_ID$
RPTG_PARTY_GVP_ID$
PRDCT_SBTP_CD$
WIS_DSTRD_CD$
NO_RMNRN_CD$
ENTRD_VOL_QT
RPTD_PR
YLD_DRCTN_CD$
CALCD_YLD_PT
ASOF_CD$
TRD_EXCTN_DT
TRD_EXCTN_TM
TRD_RPT_DT
TRD_RPT_TM
TRD_STLMT_DT
TRD_MDFR_LATE_CD$
TRD_MDFR_SRO_CD$
RPT_SIDE_CD$
BUYER_CMSN_AMT
BUYER_CPCTY_CD$
SLLR_CMSN_AMT
SLLR_CPCTY_CD$
CNTRA_PARTY_ID$
CNTRA_PARTY_GVP_ID$
LCKD_IN_FL$
ATS_FL$
SPCL_PR_FL$
TRDG_MKT_CD$
PBLSH_FL$
SYSTM_CNTRL_DT
SYSTM_CNTRL_NB
PREV_TRD_CNTRL_DT
PREV_TRD_CNTRL_NB
;

if _ERROR_ then call symputx('_EFIERR_',1);
run;

data temp4;
set temp4;
*if missing(cusip_id) then delete;
run;

proc print data=temp4;
run;
%mend academic2;




%let path1= E:\traceacademics\academics.zip;
%let path2= E:\traceacademics\bond.zip;

filename data1 zip %sysfunc(quote(&path1));


data file_list1;
length fname1 $100;
fid1=dopen("data1");
memcount1=dnum(fid1);
call symput('num_filels1',memcount1);
do i=1 to memcount1;
fname1=dread(fid1,i);
date=substr(fname1,length(fname1)-13,10);
output;
end;
rc=dclose(fid1);
run;

proc print data=file_list1;
run;

filename data2 zip %sysfunc(quote(&path2));

data file_list2;
length fname2 $100;
fid2=dopen("data2");
memcount2=dnum(fid2);
do i=1 to memcount2;
fname2=dread(fid2,i);
date=substr(fname2,length(fname2)-13,10);
output;
end;
rc=dclose(fid2);
run;

proc print data=file_list2;
run;


data mfile_list1;
merge file_list1 file_list2;
by date;
run;

proc print data=mfile_list1;
run;

%macro fileread1();

%do i=1 %to &num_filels1;
data _null_;
set mfile_list1;
if _n_=&i;
call symput('file_in1',fname1);
call symput('file_in2',fname2);
run;

%academic(&path1,&file_in1);
%bond(&path2,&file_in2);

proc sort data=temp1;
by CUSIP_ID;
run;

proc sort data=temp2;
by CUSIP_ID;
run;

proc sql;
create table merge1 as select * from
temp1 as a left join temp2 as b
on a.CUSIP_ID=b.CUSIP_ID;
quit;

proc append base=ab1 data=merge1;
run;

%end;

%mend fileread1;



%put it is &number1;


%let path3= E:\traceacademics\academicspost.zip;
%let path4= E:\traceacademics\bondpost.zip;
%let path5= E:\traceacademics\supplemental.zip;


filename data3 zip %sysfunc(quote(&path3));
filename data4 zip %sysfunc(quote(&path4));
filename data5 zip %sysfunc(quote(&path5));


data file_list3;
length fname3 $100;
fid3=dopen("data3");
memcount3=dnum(fid3);
call symput('num_filels3',memcount3);
do i=1 to memcount3;
fname3=dread(fid3,i);
date=substr(fname3,length(fname3)-13,10);
output;
end;
rc=dclose(fid3);
run;


data file_list4;
length fname4 $100;
fid4=dopen("data4");
memcount4=dnum(fid4);
call symput('num_filels4',memcount4);
do i=1 to memcount4;
fname4=dread(fid4,i);
date=substr(fname4,length(fname4)-13,10);
output;
end;
rc=dclose(fid4);
run;


data file_list5;
length fname5 $100;
fid5=dopen("data5");
memcount5=dnum(fid5);
call symput('num_filels5',memcount5);
do i=1 to memcount5;
fname5=dread(fid5,i);
date=substr(fname5,length(fname5)-13,10);
output;
end;
rc=dclose(fid5);
run;





data mfile_list2;
merge file_list3 file_list4 file_list5;
by date;
run;


%put &num_filels5;

%macro fileread2();

%do i=1 %to &num_filels5;
data _null_;
set mfile_list2;
if _n_=&i;
call symput('file_in3',fname3);
call symput('file_in4',fname4);
call symput('file_in5',fname5);
run;

%academic2(&path3,&file_in3);
%bond(&path4,&file_in4);
%supplemental(&path5,&file_in5)


proc append base=temp2 data=temp3 force;
run;

proc sort data=temp2;
by CUSIP_ID desending MTRTY_DT;
run;

*proc sort data=temp2 nodupkey;
*by CUSIP_ID;
*run;


proc sort data=temp4;
by CUSIP_ID;
run;

proc sort data=temp2;
by CUSIP_ID;
run;



proc sql;
create table merge3 as select * from
temp4 as a left join temp2 as b
on a.CUSIP_ID=b.CUSIP_ID;
quit;



proc sort data=merge3 nodupkey;
by REC_CT_NB;
run;

proc append base=ab2 data=merge3;
run;

%end;

%mend fileread2;

%fileread2();

data perm.ab2;
set ab2;
run;


data perm.Nab2;
set ab2 end=eof;
number=_N_;
if eof then output;
run;
