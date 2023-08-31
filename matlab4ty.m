data='F:\csvdatatwoyear\match2.csv';

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
    disp('problem');
    break;
    end
    if(i~=nrow);
    if nsameday~=t_array.sameday(i+1);
       ind1=1;
       nsameday=nsameday+1;
       nmatrix=size(datamatrix,1);
       BuyFirstId=datamatrix(:,1);
       BuyFirstId=unique(BuyFirstId,'rows','stable');
       j1=1;
       nbuy=size(BuyFirstId,1);
       while(isempty(datamatrix)~=1)
            CFirstId=BuyFirstId{j1,1};
            Trade=datamatrix(datamatrix.FirstId==CFirstId,:);
            buyamount=Trade.ENTRD_VOL_QT(1);
            remain=buyamount;
            for j2=1:size(Trade,1)
                    remain=remain-Trade.SENTRD_VOL_QT(j2);
                        if remain==0
                             for j3=1:j2
                                FirstIds=[CFirstId,Trade.SFirstId(j3)];
                                buysellmatchedid=[buysellmatchedid;FirstIds];
                                n=n+1;
                                dSFirstId=Trade.SFirstId(j3);
                                datamatrix=datamatrix(datamatrix.SFirstId~=dSFirstId,:);
                             end
                        break;
                        end
            end
           datamatrix=datamatrix(datamatrix.FirstId~=CFirstId,:);
           j1=j1+1;
        end
    end
    else
       nmatrix=size(datamatrix,1);
       BuyFirstId=datamatrix(:,1);
       BuyFirstId=unique(BuyFirstId,'rows','stable')
       j1=1;
       nbuy=size(BuyFirstId,1);
       while(isempty(datamatrix)~=1)
            CFirstId=BuyFirstId{j1,1};
            Trade=datamatrix(datamatrix.FirstId==CFirstId,:);
            buyamount=Trade.ENTRD_VOL_QT(1);
            remain=buyamount;
            for j2=1:size(Trade,1)
                    remain=remain-Trade.SENTRD_VOL_QT(j2);
                        if remain==0
                             for j3=1:j2
                                FirstIds=[CFirstId,Trade.SFirstId(j3)];
                                buysellmatchedid=[buysellmatchedid;FirstIds];
                                n=n+1;
                                dSFirstId=Trade.SFirstId(j3);
                                datamatrix=datamatrix(datamatrix.SFirstId~=dSFirstId,:);
                             end
                        break;
                        end
            end
           datamatrix=datamatrix(datamatrix.FirstId~=CFirstId,:);
           j1=j1+1;
        end
    end   
end

disp(n);


buysellmatchedid=array2table(buysellmatchedid);
writetable(buysellmatchedid,'F:\csvdatatwoyear\bridge1.csv');

%writematrix(buysellmatchedid,"E:\csvdata\BSmatrixSameDay.csv")
