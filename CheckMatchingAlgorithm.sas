


libname fsid'E:\MergentData';
libname perm0'E:\MainData\data';
libname perm'E:\datatwoyear2009040120100331';


libname check'E:\check2009040120100331';



*libname perm0'D:\tryscratch';
*libname fsid'D:\MergentData';
*libname perm'D:\tryscratch';

data step2B2008;
set perm.step2B2008;
run;


data matchlist1;
set perm.matchlist1;
run;

data matlab1;
set perm.matlab1;
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
create table mspread2 as select a.* , b.hcommission as Shcommission, b.agencyid as Sagencyid, b.RPTD_PR as SRPTD_PR, b.ENTRD_VOL_QT as SENTRD_VOL_QT2, b.TRD_EXCTN_DT as STRD_EXCTN_DT, b.buyer as Sbuyer, b.seller as Sseller, b.TRD_EXCTN_TM as STRD_EXCTN_TM from mspread2 as a left join step2B2008 as b
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
sweight2=SENTRD_VOL_QT/ENTRD_VOL_QT;
roundtriptype=3;
run;

data mspread2;
set mspread2;
swpdiff2=(SRPTD_PR-RPTD_PR)*sweight2;
wsprice2=SRPTD_PR*sweight2;
aswpdiff2=abs((SRPTD_PR-RPTD_PR))*sweight2;
wholding=(STRD_EXCTN_DT-TRD_EXCTN_DT)*sweight2;
run;

**Check The Problem*;
data check.mspread2;
set mspread2;
run;




