libname perm2'D:\MergentData';


*libname perm'E:\MergentData';




PROC IMPORT OUT=perm2.issue
           DATATABLE='ISSUE'
           DBMS=ACCESS REPLACE;
    DATABASE="D:\MergentData\fisd2kdb.mdb";
    USEDATE=YES;
    SCANTIME=NO;
    DBSASLABEL=NONE;
RUN;


PROC IMPORT OUT=perm2.issuer
           DATATABLE='ISSUER'
           DBMS=ACCESS REPLACE;
    DATABASE="D:\MergentData\fisd2kdb.mdb";
    USEDATE=YES;
    SCANTIME=NO;
    DBSASLABEL=NONE;
RUN;






PROC IMPORT OUT=perm2.coupon
           DATATABLE='COUPON_INFO'
           DBMS=ACCESS REPLACE;
    DATABASE="D:\MergentData\fisd2kdb.mdb";
    USEDATE=YES;
    SCANTIME=NO;
    DBSASLABEL=NONE;
RUN;


PROC IMPORT OUT=perm2.rating
           DATATABLE='RATING'
           DBMS=ACCESS REPLACE;
    DATABASE="D:\MergentData\fisd2kdb.mdb";
    USEDATE=YES;
    SCANTIME=NO;
    DBSASLABEL=NONE;
RUN;



PROC IMPORT OUT=perm2.ratinghist
           DATATABLE='RATING_HIST'
           DBMS=ACCESS REPLACE;
    DATABASE="D:\MergentData\fisd2kdb.mdb";
    USEDATE=YES;
    SCANTIME=NO;
    DBSASLABEL=NONE;
RUN;


PROC IMPORT OUT=perm2.ISSUE_EXCHANGE
           DATATABLE='ISSUE_EXCHANGE'
           DBMS=ACCESS REPLACE;
    DATABASE="D:\MergentData\fisd2kdb.mdb";
    USEDATE=YES;
    SCANTIME=NO;
    DBSASLABEL=NONE;
RUN;




proc sort data=perm2.issue;
by issuer_id;
run;


proc sort data=perm2.issuer;
by issuer_id;
run;

proc sort data=perm2.coupon;
by issue_id;
run;

proc sort data=perm2.ISSUE_EXCHANGE;
by issuer_id;
run;

proc append base=perm2.rating data=perm2.ratinghist;
run;



proc sort data=perm2.rating;
by issue_id rating_date rating rating_type;
run;



PROC SQL;
      CREATE TABLE fsid AS 
      SELECT *
	  FROM perm2.issuer as a left join perm2.ISSUE_EXCHANGE as b
	  ON a.issuer_id=b.issuer_id;
QUIT;




PROC SQL;
      CREATE TABLE fsid AS 
      SELECT *
	  FROM fsid as a left join perm2.issue as b
	  ON a.issuer_id=b.issuer_id;
QUIT;


proc sort data=fsid;
by issue_id;
run;


PROC SQL;
      CREATE TABLE fsid AS 
      SELECT *
	  FROM fsid  as a left join perm2.coupon as b
	  ON a.issue_id=b.issue_id;
QUIT;


PROC SQL;
      CREATE TABLE fsid AS 
      SELECT *
	  FROM fsid as a left join perm2.rating as b
	  ON a.issue_id=b.issue_id;
QUIT;


proc sort data=fsid;
by issue_id rating_date;
run;

data perm2.fsid;
set fsid;
run;
