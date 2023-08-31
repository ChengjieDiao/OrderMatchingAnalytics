delete(gcp('nocreate'));
data='D:\csvdatatwoyear\match3anlaysis222.csv';
location=readtable('D:\csvdatatwoyear\nosamedaylocation22.csv');


tnsamegroup=size(location,1)
ds = tabularTextDatastore(data);
buysellmatchedid=[];
t_array=readall(ds);
nrow=size(t_array,1);
parpool(4);


parfor i=1:tnsamegroup;
    % Every group is one cusip and one dealer
    disp(i);
    start1=location.start1(i);
    Cind1=1;
    end1=location.end1(i);
    datamatrix=t_array(start1:end1,:);
    nmatrix=size(datamatrix,1);     % Size of the whole group
    CFirstId=datamatrix.FirstId(1);
    MdSFirstId=[]; %MdSFirstId is associated for all observations in one group
    partleft=[];
    for cf=1:nmatrix
        if CFirstId==datamatrix.FirstId(cf);
            if(Cind1)
                trade=datamatrix(cf,:);
                Cind1=0;
            else
                trade=[trade;datamatrix(cf,:)]; % trade is all data associated with one buy trade
            end
        else
            disp('problem2');
            break;
        end
        
        if cf~=nmatrix;  % If not the last row of the group
            
            if CFirstId~=datamatrix.FirstId(cf+1);   % If it is the last observation of the buy trade
                Cind1=1;
                commonrows=intersect(trade.SFirstId,MdSFirstId);
                if(isempty(commonrows)~=1)
                    mindice=ismember(trade.SFirstId,commonrows);
                    trade=trade(~mindice,:);  % delete all matched sell trade from the buy trade
                end
                if(isempty(trade)~=1) % If number of observations is not zero after deleting all matched sell trade
                    if (isempty(partleft)~=1)
                        commonrows2=intersect(trade.SFirstId,partleft(:,1));
                        if(isempty(commonrows2)~=1)
                            mindice2=ismember(trade.SFirstId,commonrows);
                            for icommon1=1:size(mindice2,1);
                                trade(mindice2(icommon1),:).SENTRD_VOL_QT=partleft(mindice2(icommon1),2);
                            end
                        end
                    end
                    ntrade=size(trade,1);
                    buyamount=trade.ENTRD_VOL_QT(1);
                    remain=buyamount;
                    %display(remain);  % check
                    for ti1=1:ntrade  % ti1 is the iterator to loop through each sell trade associated with one buy trade.
                        remain=remain-trade.SENTRD_VOL_QT(ti1);
                        if remain<=0
                            %display(remain); % check
                            if remain ==0
                                for ti2=1:ti1
                                    FirstIds=[CFirstId,trade.SFirstId(ti2),trade.SENTRD_VOL_QT(ti2)];
                                    buysellmatchedid=[buysellmatchedid;FirstIds];
                                    dSFirstId=trade.SFirstId(ti2);
                                    MdSFirstId=[MdSFirstId;dSFirstId];
                                end
                                break;
                                
                            else
                                %display('true'); % check
                                if ti1>1
                                    for ti2=1:ti1-1
                                        FirstIds=[CFirstId,trade.SFirstId(ti2),trade.SENTRD_VOL_QT(ti2)];
                                        buysellmatchedid=[buysellmatchedid;FirstIds];
                                        dSFirstId=trade.SFirstId(ti2);
                                        MdSFirstId=[MdSFirstId;dSFirstId];
                                    end
                                    FirstIds=[CFirstId,trade.SFirstId(ti1),trade.SENTRD_VOL_QT(ti1)+remain];
                                    buysellmatchedid=[buysellmatchedid;FirstIds];
                                    if (isempty(partleft)~=1)
                                        commonrows3=intersect(partleft(:,1),trade.SFirstId(ti1));
                                    else
                                        commonrows3=[];
                                    end
                                    if isempty(commonrows3)~=1
                                        mindice3=ismember(partleft(:,1),commonrows3);
                                        partleft(mindice3,2)=-remain;
                                        break;
                                    else
                                        partleft=[partleft;trade.SFirstId(ti1),-remain];
                                        break
                                    end
                                else
                                    FirstIds=[CFirstId,trade.SFirstId(ti1),trade.SENTRD_VOL_QT(ti1)+remain];
                                    buysellmatchedid=[buysellmatchedid;FirstIds];
                                    if (isempty(partleft)~=1)
                                        commonrows3=intersect(partleft(:,1),trade.SFirstId(ti1));
                                    else
                                        commonrows3=[];
                                    end
                                    if isempty(commonrows3)~=1
                                        mindice3=ismember(partleft(:,1),commonrows3);
                                        partleft(mindice3,2)=-remain;
                                        break;
                                    else
                                        partleft=[partleft;trade.SFirstId(ti1),-remain];
                                        %disp('partleft')
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
            CFirstId=datamatrix.FirstId(cf+1);
            
            
        else   % Following code deal with the situation if it is the last observation of the group
            
            
            commonrows=intersect(trade.SFirstId,MdSFirstId);
            if(isempty(commonrows)~=1)
                mindice=ismember(trade.SFirstId,commonrows);
                trade=trade(~mindice,:);  % delete all matched sell trade from the buy trade
            end
            if(isempty(trade)~=1) % If number of observations is not zero after deleting all matched sell trade
                if (isempty(partleft)~=1)
                    commonrows2=intersect(trade.SFirstId,partleft(:,1));
                    if(isempty(commonrows2)~=1)
                        mindice2=ismember(trade.SFirstId,commonrows);
                        for icommon1=1:size(mindice2,1);
                            trade(mindice2(icommon1),:).SENTRD_VOL_QT=partleft(mindice2(icommon1),2);
                        end
                    end
                end
                ntrade=size(trade,1);
                buyamount=trade.ENTRD_VOL_QT(1);
                remain=buyamount;
                % display(remain);  % check
                for ti1=1:ntrade  % ti1 is the iterator to loop through each sell trade associated with one buy trade.
                    remain=remain-trade.SENTRD_VOL_QT(ti1);
                    if remain<=0
                        %display(remain); % check
                        if remain ==0
                            for ti2=1:ti1
                                FirstIds=[CFirstId,trade.SFirstId(ti2),trade.SENTRD_VOL_QT(ti2)];
                                buysellmatchedid=[buysellmatchedid;FirstIds];
                                dSFirstId=trade.SFirstId(ti2);
                                MdSFirstId=[MdSFirstId;dSFirstId];
                            end
                            break;
                            
                        else
                            %   display('true'); % check
                            if ti1>1
                                for ti2=1:ti1-1
                                    FirstIds=[CFirstId,trade.SFirstId(ti2),trade.SENTRD_VOL_QT(ti2)];
                                    buysellmatchedid=[buysellmatchedid;FirstIds];
                                    dSFirstId=trade.SFirstId(ti2);
                                    MdSFirstId=[MdSFirstId;dSFirstId];
                                end
                                FirstIds=[CFirstId,trade.SFirstId(ti1),trade.SENTRD_VOL_QT(ti1)+remain];
                                buysellmatchedid=[buysellmatchedid;FirstIds];
                                if (isempty(partleft)~=1)
                                    commonrows3=intersect(partleft(:,1),trade.SFirstId(ti1));
                                else
                                    commonrows3=[];
                                end
                                if isempty(commonrows3)~=1
                                    mindice3=ismember(partleft(:,1),commonrows3);
                                    partleft(mindice3,2)=-remain;
                                    break;
                                else
                                    partleft=[partleft;trade.SFirstId(ti1),-remain];
                                    break
                                end
                            else
                                FirstIds=[CFirstId,trade.SFirstId(ti1),trade.SENTRD_VOL_QT(ti1)+remain];
                                buysellmatchedid=[buysellmatchedid;FirstIds];
                                if (isempty(partleft)~=1)
                                    commonrows3=intersect(partleft(:,1),trade.SFirstId(ti1));
                                else
                                    commonrows3=[];
                                end
                                if isempty(commonrows3)~=1
                                    mindice3=ismember(partleft(:,1),commonrows3);
                                    partleft(mindice3,2)=-remain;
                                    break;
                                else
                                    partleft=[partleft;trade.SFirstId(ti1),-remain];
                                    % disp('partleft')
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end



buysellmatchedid=array2table(buysellmatchedid);
writetable(buysellmatchedid,'D:\csvdatatwoyear\bridge22.csv');

%writematrix(buysellmatchedid,"E:\csvdata\BSmatrixSameDay.csv")