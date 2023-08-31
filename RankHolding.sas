libname perm'E:\datatwoyear20112012CurrentMethod';
libname check'E:\try';

ODS EXCEL FILE="E:\csvdatatwoyear20112012CurrentMethod\holding.xlsx";
proc format;
value $fgrade 'AorAbove' ='         AorAbove ' 'BBB'='      BBB' 'BB'='    BB' 'B'='  B' 'BorLower'=' BorLower' 'NA'='NA';
run;

data tdhrankspread;
set perm.tdhrankspread;
run;


data tdhrankspread;
set tdhrankspread;
HoldingRange='            0';
if holding>0 and holding le 1 then HoldingRange='      0 to 1';
if holding>1 and holding le 10 then HoldingRange='  0 to 10';
if holding>10 and holding le 20 then HoldingRange='10 to 20';
if holding>20 and holding le 30 then HoldingRange='20 to 30';
if holding>30 and holding le 40 then HoldingRange='30 to 40';
if holding>40 and holding le 50 then HoldingRange='40 to 50';
if holding>50 and holding le 60 then HoldingRange='50 to 60';
run;
data tdhrankspread;
set tdhrankspread;
Rholding=Rholding+1;
run;

proc tabulate data=tdhrankspread missing;
class HoldingRange Grate /order=formatted;
var pdiff ;
*format RTcount30day rfmt.;
format Grate $fgrade. ;
table HoldingRange  all , pdiff  * (all Grate) * (median) /nocellmerge box='All types of RoundTrip Trade Included';
label HoldingRange='Holding Range' pdiff='Spread' Grate='Rating Grade';
keylabel PCTN='Percent of Total Observations';
run;


proc tabulate data=tdhrankspread missing;
class HoldingRange Grate /order=formatted;
var Tcount30day ;
*format RTcount30day rfmt.;
format Grate $fgrade. ;
table HoldingRange  all , Tcount30day  * (all Grate) * (median) /nocellmerge box='All types of RoundTrip Trade Included';
label HoldingRange='Holding Range' Tcount30day='Trade Count in Previous 30 days (liquidity)'  Grate='Rating Grade';
keylabel PCTN='Percent of Total Observations';
run;


data check.checkholding;
set tdhrankspread;
run;

ODS EXCEL close;
