data='E:\csvdatatwoyear\selectmatch2.csv';

ds = tabularTextDatastore(data);

buysellmatchedid=[];

t_array=readall(ds);
nrow=size(t_array,1);
nsameday=t_array.sameday(1);
ind1=1;
n=0;


for i=1:nrow
    disp(i);
    if nsameday==t_array.sameday(i)
        if (ind1)
            datamatrix=t_array(i,:);
            ind1=0;
        else
            datamatrix=[datamatrix;t_array(i,:)];
        end
    else
        disp('problem1');
        break;
    end
    if(i~=nrow)
        if nsameday~=t_array.sameday(i+1)
            ind1=1;
            nsameday=nsameday+1;
            nmatrix=size(datamatrix,1);
            Cind1=1;
            CFirstId=datamatrix.FirstId(1);
            MdSFirstId=[];
            for cf=1:nmatrix
                if CFirstId==datamatrix.FirstId(cf)
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
                    
                    if CFirstId~=datamatrix.FirstId(cf+1)
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
                                        n=n+1;
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
                                    n=n+1;
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
        
    else
        nmatrix=size(datamatrix,1);
        Cind1=1;
        CFirstId=datamatrix.FirstId(1);
        MdSFirstId=[];
        for cf=1:nmatrix
            if CFirstId==datamatrix.FirstId(cf)
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
                if CFirstId~=datamatrix.FirstId(cf+1)
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
                                    n=n+1;
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
                                n=n+1;
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
end

disp(n);


buysellmatchedid=array2table(buysellmatchedid);
writetable(buysellmatchedid,'E:\csvdatatwoyear\bridge1.csv');

%writematrix(buysellmatchedid,"E:\csvdata\BSmatrixSameDay.csv")