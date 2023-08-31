libname perm'D:\MainData\data';

data perm.ab1try;
set perm.ab1;
if SUB_PRDCT_TYPE_CD='CORP' then delete;
run;
