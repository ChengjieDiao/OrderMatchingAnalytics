libname fsid'E:\MergentData';
libname perm0'E:\datatwoyear';
libname perm'E:\datatwoyear';
libname check'E:\try';

proc tabulate data=perm.spread missing;
class rountriptype /order=formatted;
var holding;
table holding  * (all rountriptype) * (N mean median);
run;


proc tabulate data=perm.spread missing;
class rountriptype /order=formatted;
var ENTRD_VOL_QT;
table ENTRD_VOL_QT  * (all rountriptype) * (N mean median);
run;
