libname check'E:\try';

data check.checkholding;
set check.mspread2(keep=FirstId SFirstId ENTRD_VOL_QT SENTRD_VOL_QT buyer Sseller TRD_EXCTN_DT STRD_EXCTN_DT sweight2 wholding);
run;
