libname perm2'D:\MergentData';


*libname perm'E:\MergentData';



data issue;
set perm2.issue;
run;

data issuer;
set perm2.issuer;
run;

data coupon;
set perm2.coupon;
run;

data ISSUE_EXCHANGE;
set perm2.ISSUE_EXCHANGE;
run;

data rating;
set perm2.rating(keep=issue_id rating_type rating_date rating rating_status reason);
run;

data ratinghist;
set perm2.ratinghist;
run;


proc sort data=issue;
by issuer_id;
run;


proc sort data=issuer;
by issuer_id;
run;

proc sort data=coupon;
by issue_id;
run;

proc sort data=ISSUE_EXCHANGE;
by issue_id;
run;


proc append base=rating data=ratinghist;
run;

proc sort data=rating nodupkey;
by _all_;
run;


proc sort data=rating;
by issue_id rating_date rating rating_type;
run;









PROC SQL;
      CREATE TABLE fsid AS 
      SELECT *
	  FROM issuer as a left join issue as b
	  ON a.issuer_id=b.issuer_id;
QUIT;


proc sort data=fsid;
by issue_id;
run;




PROC SQL;
      CREATE TABLE fsid AS 
      SELECT *
	  FROM fsid as a left join ISSUE_EXCHANGE as b
	  ON a.issue_id=b.issue_id;
QUIT;


PROC SQL;
      CREATE TABLE fsid AS 
      SELECT *
	  FROM fsid as a left join coupon as b
	  ON a.issue_id=b.issue_id;
QUIT;


PROC SQL;
      CREATE TABLE fsid AS 
      SELECT *
	  FROM fsid as a left join rating as b
	  ON a.issue_id=b.issue_id;
QUIT;


proc sort data=fsid;
by issue_id rating_date;
run;

data perm2.fsid;
set fsid;
run;
