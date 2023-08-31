libname fsid'D:\CorporateBondData\OneDrive_1_2-10-2020\FISD2012';
libname perm0'D:\datatwoyear';
libname perm'D:\datatwoyear';
libname check'D:\try';


data check.problem1;
set perm.step2B2008;
if Firstid=1431|Firstid=1433|Firstid=1435 then output;
run;
