
libname fsid'E:\MergentData';
libname perm0'E:\datatwoyear';
libname perm'E:\datatwoyear';
libname check'E:\try';

data perm.checkmspread22holding;
set perm.msreapd22;
if holding=0 then output;
run;

proc sort data=perm.checkmspread22holding nodupkey out=checkholding;
by firstid;
run;

data checkholding;
set checkholding(keep=firstid);
run;

proc sort data=perm.mspread2;
by firstid;
run;

proc sql;
create table perm.checkholding as select * from perm.mspread2 as a inner join checkholding as b
on a.firstid=b.firstid;
quit;

data perm.checkholding2;
set perm.checkholding(keep=ENTRD_VOL_QT RPTD_PR TRD_EXCTN_DT SRPTD_PR SENTRD_VOL_QT STRD_EXCTN_DT pdiff buyer Sseller cusip_id);
run;
