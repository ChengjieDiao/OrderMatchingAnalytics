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
