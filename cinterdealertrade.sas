

*********************************************************************************************************************************************************************************************
*
** This Code Match The Roundtrip Spread With The Same Ideology In The Paper: Providing Liquidity in an Illiquid Market: Dealer Behavior in U.S. Corporate Bonds, Goldstein And Hockiss 2020
*
**********************************************************************************************************************************************************************************************;
*
***************************Chengjie Diao*************************************************************************************************************************************************
***********************Queen's Unviersity, Economics Department*******************************
**********************************************************************************************************************************************************************************************;


proc datasets library=work kill;
run;
quit;

ODS EXCEL FILE="E:\interdealer.xlsx";

*libname perm'/scratch/queensu/cjdiao/total';
*ODS HTML FILE='/scratch/queensu/cjdiao/total/TEMP.XLS';




libname fsid'E:\MergentData';
libname perm0'E:\MainData\data';
libname perm'E:\datatwoyear';

*;
data total;
set perm0.RAWtotal;
dyear=year(TRD_EXCTN_DT);
run;

data total;
set total;
interdealer=1;
if (CNTRA_PARTY_ID='C'|CNTRA_PARTY_ID='A'|RPTG_PARTY_ID='C'|RPTG_PARTY_ID='A') then interdealer=0;
run;


proc tabulate data=total missing;
class interdealer dyear /order=formatted;
table dyear  all ,  (all interdealer) * (N PCTN);
run;

ODS EXCEL close;
