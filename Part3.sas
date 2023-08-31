*libname perm'/scratch/queensu/cjdiao/total';
*ODS HTML FILE='/scratch/queensu/cjdiao/total/TEMP.XLS';

proc datasets library=work kill;
run;
quit;

*libname perm'/scratch/queensu/cjdiao/total';
*ODS HTML FILE='/scratch/queensu/cjdiao/total/TEMP.XLS';




libname fsid'E:\MergentData';
libname perm0'E:\MainData\data';
libname perm'E:\datatwoyear';


libname check'E:\check';




libname perm0'D:\tryscratch';
libname fsid'D:\MergentData';
libname perm'D:\tryscratch';

%let startday='01DEC2008'D;
%let endday='31DEC12'D;






data UBuyTrades1;
set perm.UBuyTrades1;
run;

data USellTrades1;
set perm.USellTrades1;
run;



proc import datafile = 'E:\csvdatatwoyear\bridge12.csv'
out  =  matlab1
dbms  = csv
replace;
run;


data perm.matlab1;
set matlab1;
run;





*****************************************************************************************************************************************************************************************************
*
*Remove matched roundtrip trade from unmatched1 by the second type RoundTrip Trade;
*
****************************************************************************************************************************************************************************************************;



 data MatFirstId1;
 set perm.matlab1(keep=buysellmatchedid1);
 run;


 data MatFirstId1;
 set MatFirstId1;
 rename buysellmatchedid1=FirstId;
 run;

 data MatSFirstId1;
 set perm.matlab1(keep=buysellmatchedid2);
 run;


 data MatSFirstId1;
 set MatSFirstId1;
 rename buysellmatchedid2=SFirstId;
 run;


proc sort data=MatFirstId1 nodupkey;
by FirstId;
run;

proc sort data=MatSFirstId1 nodupkey;
by SFirstId;
run;


data perm.matlab1;
set perm.matlab1;
rename buysellmatchedid1=FirstId buysellmatchedid2=SFirstId;
run;


data matlab1;
set matlab1;
rename buysellmatchedid1=FirstId buysellmatchedid2=SFirstId;
run;


proc sort data=UBuyTrades1;
by FirstId;
run;

data UBuyTrades2;
merge UBuyTrades1 MatFirstId1(in=qq);
by FirstId;
if qq=0;
run;







proc sort data=USellTrades1;
by SFirstId;
run;


data USellTrades2;
merge USellTrades1 MatSFirstId1(in=qq);
by SFirstId;
if qq=0;
run;



data UBuyTrades2;
set UBuyTrades2;
year=year(TRD_EXCTN_DT);
run;


data USellTrades2;
set USellTrades2;
Syear=year(STRD_EXCTN_DT);
run;



proc sort data=UBuyTrades2;
by CUSIP_ID year TRD_EXCTN_DT player;
run;

proc sort data=USellTrades2;
by CUSIP_ID Syear STRD_EXCTN_DT Splayer;
run;


proc sql;
create table perm.match3 as select a.*, b.Splayer, b.Strade_id , b.SENTRD_VOL_QT,b.STRD_EXCTN_DT, b.STRD_EXCTN_TM, b.SFirstId, abs(b.STRD_EXCTN_TM-a.TRD_EXCTN_TM) as 
		tradetime_dist3 from UBuyTrades2 as a, USellTrades2 as b where 
		a.CUSIP_ID=b.CUSIP_ID and a.TRD_EXCTN_DT<=b.STRD_EXCTN_DT<=a.TRD_EXCTN_DT+60 and a.player=b.Splayer
    order by trade_id;
quit;



proc sort data=perm.match3 nodupkey out=samegroup;
by CUSIP_ID player;
run;


data samegroup;
set samegroup(keep=CUSIP_ID player);
run;

data samegroup;
set samegroup;
samegroup=_N_;
run;


%let groups=5;


data samegroup;
set samegroup;
flag=mod(_N_-1, &groups.);
flag=flag+1;
run;



data samegroup1;
set samegroup;
if flag=1;
run;

data samegroup2;
set samegroup;
if flag=2;
run;


data samegroup3;
set samegroup;
if flag=3;
run;

data samegroup4;
set samegroup;
if flag=4;
run;

data samegroup5;
set samegroup;
if flag=5;
run;


proc sort data=samegroup1;
by cusip_id player;
run;

proc sort data=samegroup2;
by cusip_id player;
run;

proc sort data=samegroup3;
by cusip_id player;
run;

proc sort data=samegroup4;
by cusip_id player;
run;


proc sort data=samegroup5;
by cusip_id player;
run;

data perm.checksamegroup;
set samegroup;
run;




proc sort data=perm.match3;
by CUSIP_ID player TRD_EXCTN_DT TRD_EXCTN_TM trade_id STRD_EXCTN_DT STRD_EXCTN_TM;
run;



*******************************************************************************************************************************************************************************************************
*
* Create a dataset that store the location of each nosameday group on the orginal dataset Part 1;
*
*******************************************************************************************************************************************************************************************************;



proc sql;
create table perm.match31 as select * from perm.match3 as a, samegroup1 as b
where a.CUSIP_ID=b.CUSIP_ID AND a.player=b.player;
run;

proc sort data=perm.match31;
by CUSIP_ID player TRD_EXCTN_DT TRD_EXCTN_TM FirstId STRD_EXCTN_DT STRD_EXCTN_TM;
run;


data perm.match3analysis1;
set perm.match31(keep=CUSIP_ID player FirstId TRD_EXCTN_DT ENTRD_VOL_QT TRD_EXCTN_TM STRD_EXCTN_DT STRD_EXCTN_TM SENTRD_VOL_QT SFirstId Splayer year samegroup);
run;




data nosamedaylocation1;
set perm.match3analysis1;
retain start1;
retain end1;
by samegroup;
if FIRST.samegroup then start1=_n_;
if LAST.samegroup then end1=_n_;
run;

data nosamedaylocation1;
set nosamedaylocation1(keep=samegroup start1 end1);
run;

proc sort data=nosamedaylocation1 out =nosamedaylocation1;
by descending start1 descending end1;
run;

proc sort data=nosamedaylocation1 nodupkey out=nosamedaylocation1;
by samegroup;
run;


proc export data=nosamedaylocation1
      outfile='E:\csvdatatwoyear\nosamedaylocation21.csv'
      dbms=dlm replace;  
      delimiter=',';
run;



*************************************************************************************************************************************************************************************************
*
*Export Mathc3Analysis to Excel File (Which is The File Necessary to Match The Third Type RoundTrip Trade);
*
************************************************************************************************************************************************************;


proc export 
  data=perm.match3analysis1
  dbms=csv 
  outfile="E:\csvdatatwoyear\match3anlaysis221.csv" 
  replace;
run;






*******************************************************************************************************************************************************************************************************
*
* Create a dataset that store the location of each nosameday group on the orginal dataset Part 2;
*
*******************************************************************************************************************************************************************************************************;



proc sql;
create table perm.match32 as select * from perm.match3 as a, samegroup2 as b
where a.CUSIP_ID=b.CUSIP_ID AND a.player=b.player;
run;

proc sort data=perm.match32;
by CUSIP_ID player TRD_EXCTN_DT TRD_EXCTN_TM FirstId STRD_EXCTN_DT STRD_EXCTN_TM;
run;


data perm.match3analysis2;
set perm.match32(keep=CUSIP_ID player FirstId TRD_EXCTN_DT ENTRD_VOL_QT TRD_EXCTN_TM STRD_EXCTN_DT STRD_EXCTN_TM SENTRD_VOL_QT SFirstId Splayer year samegroup);
run;




data nosamedaylocation2;
set perm.match3analysis2;
retain start1;
retain end1;
by samegroup;
if FIRST.samegroup then start1=_n_;
if LAST.samegroup then end1=_n_;
run;

data nosamedaylocation2;
set nosamedaylocation2(keep=samegroup start1 end1);
run;

proc sort data=nosamedaylocation2 out =nosamedaylocation2;
by descending start1 descending end1;
run;

proc sort data=nosamedaylocation2 nodupkey out=nosamedaylocation2;
by samegroup;
run;


proc export data=nosamedaylocation2
      outfile='E:\csvdatatwoyear\nosamedaylocation22.csv'
      dbms=dlm replace;  
      delimiter=',';
run;



*************************************************************************************************************************************************************************************************
*
*Export Mathc3Analysis to Excel File (Which is The File Necessary to Match The Third Type RoundTrip Trade);
*
************************************************************************************************************************************************************;


proc export 
  data=perm.match3analysis2
  dbms=csv 
  outfile="E:\csvdatatwoyear\match3anlaysis222.csv" 
  replace;
run;





*******************************************************************************************************************************************************************************************************
*
* Create a dataset that store the location of each nosameday group on the orginal dataset Part 3;
*
*******************************************************************************************************************************************************************************************************;



proc sql;
create table perm.match33 as select * from perm.match3 as a, samegroup3 as b
where a.CUSIP_ID=b.CUSIP_ID AND a.player=b.player;
run;

proc sort data=perm.match33;
by CUSIP_ID player TRD_EXCTN_DT TRD_EXCTN_TM FirstId STRD_EXCTN_DT STRD_EXCTN_TM;
run;


data perm.match3analysis3;
set perm.match33(keep=CUSIP_ID player FirstId TRD_EXCTN_DT ENTRD_VOL_QT TRD_EXCTN_TM STRD_EXCTN_DT STRD_EXCTN_TM SENTRD_VOL_QT SFirstId Splayer year samegroup);
run;




data nosamedaylocation3;
set perm.match3analysis3;
retain start1;
retain end1;
by samegroup;
if FIRST.samegroup then start1=_n_;
if LAST.samegroup then end1=_n_;
run;

data nosamedaylocation3;
set nosamedaylocation3(keep=samegroup start1 end1);
run;

proc sort data=nosamedaylocation3 out =nosamedaylocation3;
by descending start1 descending end1;
run;

proc sort data=nosamedaylocation3 nodupkey out=nosamedaylocation3;
by samegroup;
run;


proc export data=nosamedaylocation3
      outfile='E:\csvdatatwoyear\nosamedaylocation23.csv'
      dbms=dlm replace;  
      delimiter=',';
run;



*************************************************************************************************************************************************************************************************
*
*Export Mathc3Analysis to Excel File (Which is The File Necessary to Match The Third Type RoundTrip Trade);
*
************************************************************************************************************************************************************;


proc export 
  data=perm.match3analysis3
  dbms=csv 
  outfile="E:\csvdatatwoyear\match3anlaysis223.csv" 
  replace;
run;





*******************************************************************************************************************************************************************************************************
*
* Create a dataset that store the location of each nosameday group on the orginal dataset Part 4;
*
*******************************************************************************************************************************************************************************************************;



proc sql;
create table perm.match34 as select * from perm.match3 as a, samegroup4 as b
where a.CUSIP_ID=b.CUSIP_ID AND a.player=b.player;
run;

proc sort data=perm.match34;
by CUSIP_ID player TRD_EXCTN_DT TRD_EXCTN_TM FirstId STRD_EXCTN_DT STRD_EXCTN_TM;
run;


data perm.match3analysis4;
set perm.match34(keep=CUSIP_ID player FirstId TRD_EXCTN_DT ENTRD_VOL_QT TRD_EXCTN_TM STRD_EXCTN_DT STRD_EXCTN_TM SENTRD_VOL_QT SFirstId Splayer year samegroup);
run;




data nosamedaylocation4;
set perm.match3analysis4;
retain start1;
retain end1;
by samegroup;
if FIRST.samegroup then start1=_n_;
if LAST.samegroup then end1=_n_;
run;

data nosamedaylocation4;
set nosamedaylocation4(keep=samegroup start1 end1);
run;

proc sort data=nosamedaylocation4 out =nosamedaylocation4;
by descending start1 descending end1;
run;

proc sort data=nosamedaylocation4 nodupkey out=nosamedaylocation4;
by samegroup;
run;


proc export data=nosamedaylocation4
      outfile='E:\csvdatatwoyear\nosamedaylocation24.csv'
      dbms=dlm replace;  
      delimiter=',';
run;



*************************************************************************************************************************************************************************************************
*
*Export Mathc3Analysis to Excel File (Which is The File Necessary to Match The Third Type RoundTrip Trade);
*
************************************************************************************************************************************************************;


proc export 
  data=perm.match3analysis4
  dbms=csv 
  outfile="E:\csvdatatwoyear\match3anlaysis224.csv" 
  replace;
run;



*******************************************************************************************************************************************************************************************************
*
* Create a dataset that store the location of each nosameday group on the orginal dataset Part 5;
*
*******************************************************************************************************************************************************************************************************;



proc sql;
create table perm.match35 as select * from perm.match3 as a, samegroup5 as b
where a.CUSIP_ID=b.CUSIP_ID AND a.player=b.player;
run;

proc sort data=perm.match35;
by CUSIP_ID player TRD_EXCTN_DT TRD_EXCTN_TM FirstId STRD_EXCTN_DT STRD_EXCTN_TM;
run;


data perm.match3analysis5;
set perm.match35(keep=CUSIP_ID player FirstId TRD_EXCTN_DT ENTRD_VOL_QT TRD_EXCTN_TM STRD_EXCTN_DT STRD_EXCTN_TM SENTRD_VOL_QT SFirstId Splayer year samegroup);
run;




data nosamedaylocation5;
set perm.match3analysis5;
retain start1;
retain end1;
by samegroup;
if FIRST.samegroup then start1=_n_;
if LAST.samegroup then end1=_n_;
run;

data nosamedaylocation5;
set nosamedaylocation5(keep=samegroup start1 end1);
run;

proc sort data=nosamedaylocation5 out =nosamedaylocation5;
by descending start1 descending end1;
run;

proc sort data=nosamedaylocation5 nodupkey out=nosamedaylocation5;
by samegroup;
run;


proc export data=nosamedaylocation5
      outfile='E:\csvdatatwoyear\nosamedaylocation25.csv'
      dbms=dlm replace;  
      delimiter=',';
run;



*************************************************************************************************************************************************************************************************
*
*Export Mathc3Analysis to Excel File (Which is The File Necessary to Match The Third Type RoundTrip Trade);
*
************************************************************************************************************************************************************;


proc export 
  data=perm.match3analysis5
  dbms=csv 
  outfile="E:\csvdatatwoyear\match3anlaysis225.csv" 
  replace;
run;






data perm.MatFirstId1;
set MatFirstId1;
run;

data perm.MatSFirstId1;
set MatSFirstId1;
run;
