data='E:\csvdatatwoyeartry\match3anlaysis2.csv';
location=readtable('E:\csvdatatwoyeartry\nosamedaylocation.csv');


tnsamegroup=size(location,1)
ds = tabularTextDatastore(data);
buysellmatchedid=[];
t_array=readall(ds);
nrow=size(t_array,1);

parpool(4);

parfor i=1:tnsamegroup;
    disp(i);
    start1=location.start1(i);
    Cind1=1;
    end1=location.end1(i);
    datamatrix=t_array(start1:end1,:);
    nmatrix=size(datamatrix,1);
    CFirstId=datamatrix.FirstId(1);
    MdSFirstId=[];
            for cf=1:nmatrix
                if CFirstId==datamatrix.FirstId(cf);
                    if(Cind1)
                        trade=datamatrix(cf,:);
                        Cind1=0;
                    else
                        trade=[trade;datamatrix(cf,:)];
                    end
                else
                    disp('problem2');
                    break;
                end
                
                if cf~=nmatrix
                    
                    if CFirstId~=datamatrix.FirstId(cf+1);
                        Cind1=1;
                        commonrows=intersect(trade.SFirstId,MdSFirstId);
                        if(isempty(commonrows)~=1)
                            mindice=ismember(trade.SFirstId,commonrows);
                            trade=trade(~mindice,:);
                        end
                        if(isempty(trade)~=1)
                            ntrade=size(trade,1);
                            buyamount=trade.ENTRD_VOL_QT(1);
                            remain=buyamount;
                            for ti1=1:ntrade
                                remain=remain-trade.SENTRD_VOL_QT(ti1);
                                if remain==0
                                    for ti2=1:ti1
                                        FirstIds=[CFirstId,trade.SFirstId(ti2)];
                                        buysellmatchedid=[buysellmatchedid;FirstIds];
                                        dSFirstId=trade.SFirstId(ti2);
                                        MdSFirstId=[MdSFirstId;dSFirstId];
                                    end
                                    break;
                                end
                            end
                        end
                        CFirstId=datamatrix.FirstId(cf+1);
                    end
                    
                    
                else
                    
                    commonrows=intersect(trade.SFirstId,MdSFirstId);
                    if(isempty(commonrows)~=1)
                        mindice=ismember(trade.SFirstId,commonrows);
                        trade=trade(~mindice,:);
                    end
                    if(isempty(trade)~=1)
                        ntrade=size(trade,1);
                        buyamount=trade.ENTRD_VOL_QT(1);
                        remain=buyamount;
                        for ti1=1:ntrade
                            remain=remain-trade.SENTRD_VOL_QT(ti1);
                            if remain==0
                                for ti2=1:ti1
                                    FirstIds=[CFirstId,trade.SFirstId(ti2)];
                                    buysellmatchedid=[buysellmatchedid;FirstIds];
                                    dSFirstId=trade.SFirstId(ti2);
                                    MdSFirstId=[MdSFirstId;dSFirstId];
                                end
                                break;
                            end
                        end
                    end
                end
            end
        end



buysellmatchedid=array2table(buysellmatchedid);
writetable(buysellmatchedid,'E:\csvdatatwoyeartry\bridge2.csv');

%writematrix(buysellmatchedid,"E:\csvdata\BSmatrixSameDay.csv")