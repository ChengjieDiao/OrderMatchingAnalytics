libname perm'D:\MergentData';


data fsid;
set perm.fsid;
cusip_id=cats(issuer_cusip,issue_cusip);
run;

proc sort data=fsid nodupkey;
by cusip_id desending rating_date desending rating rating_type desending reason desending rating_status;
run;

data perm.fsid2;
set fsid;
run;



