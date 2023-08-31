# Generated with SMOP  0.41
from libsmop import *
# nonsameday.m

    delete(gcp('nocreate'))
    data='D:\csvdatatwoyear\match3anlaysis22.csv'
# nonsameday.m:2
    location=readtable('D:\csvdatatwoyear\nosamedaylocation2.csv')
# nonsameday.m:3
    tnsamegroup=size(location,1)
# nonsameday.m:6
    ds=tabularTextDatastore(data)
# nonsameday.m:7
    buysellmatchedid=[]
# nonsameday.m:8
    t_array=readall(ds)
# nonsameday.m:9
    nrow=size(t_array,1)
# nonsameday.m:10
    parpool
    for i in arange(1,tnsamegroup).reshape(-1):
        disp(i)
        start1=location.start1(i)
# nonsameday.m:17
        Cind1=1
# nonsameday.m:18
        end1=location.end1(i)
# nonsameday.m:19
        datamatrix=t_array(arange(start1,end1),arange())
# nonsameday.m:20
        nmatrix=size(datamatrix,1)
# nonsameday.m:21
        CFirstId=datamatrix.FirstId(1)
# nonsameday.m:22
        MdSFirstId=[]
# nonsameday.m:23
        partleft=[]
# nonsameday.m:24
        for cf in arange(1,nmatrix).reshape(-1):
            if CFirstId == datamatrix.FirstId(cf):
                if (Cind1):
                    trade=datamatrix(cf,arange())
# nonsameday.m:28
                    Cind1=0
# nonsameday.m:29
                else:
                    trade=concat([[trade],[datamatrix(cf,arange())]])
# nonsameday.m:31
            else:
                disp('problem2')
                break
            if cf != nmatrix:
                if CFirstId != datamatrix.FirstId(cf + 1):
                    Cind1=1
# nonsameday.m:41
                    commonrows=intersect(trade.SFirstId,MdSFirstId)
# nonsameday.m:42
                    if (isempty(commonrows) != 1):
                        mindice=ismember(trade.SFirstId,commonrows)
# nonsameday.m:44
                        trade=trade(logical_not(mindice),arange())
# nonsameday.m:45
                    if (isempty(trade) != 1):
                        if (isempty(partleft) != 1):
                            commonrows2=intersect(trade.SFirstId,partleft(arange(),1))
# nonsameday.m:49
                            if (isempty(commonrows2) != 1):
                                mindice2=ismember(trade.SFirstId,commonrows)
# nonsameday.m:51
                                for icommon1 in arange(1,size(mindice2,1)).reshape(-1):
                                    trade(mindice2(icommon1),arange()).SENTRD_VOL_QT = copy(partleft(mindice2(icommon1),2))
# nonsameday.m:53
                        ntrade=size(trade,1)
# nonsameday.m:57
                        buyamount=trade.ENTRD_VOL_QT(1)
# nonsameday.m:58
                        remain=copy(buyamount)
# nonsameday.m:59
                        for ti1 in arange(1,ntrade).reshape(-1):
                            remain=remain - trade.SENTRD_VOL_QT(ti1)
# nonsameday.m:62
                            if remain <= 0:
                                #display(remain); # check
                                if remain == 0:
                                    for ti2 in arange(1,ti1).reshape(-1):
                                        FirstIds=concat([CFirstId,trade.SFirstId(ti2),trade.SENTRD_VOL_QT(ti2)])
# nonsameday.m:67
                                        buysellmatchedid=concat([[buysellmatchedid],[FirstIds]])
# nonsameday.m:68
                                        dSFirstId=trade.SFirstId(ti2)
# nonsameday.m:69
                                        MdSFirstId=concat([[MdSFirstId],[dSFirstId]])
# nonsameday.m:70
                                    break
                                else:
                                    #display('true'); # check
                                    if ti1 > 1:
                                        for ti2 in arange(1,ti1 - 1).reshape(-1):
                                            FirstIds=concat([CFirstId,trade.SFirstId(ti2),trade.SENTRD_VOL_QT(ti2)])
# nonsameday.m:78
                                            buysellmatchedid=concat([[buysellmatchedid],[FirstIds]])
# nonsameday.m:79
                                            dSFirstId=trade.SFirstId(ti2)
# nonsameday.m:80
                                            MdSFirstId=concat([[MdSFirstId],[dSFirstId]])
# nonsameday.m:81
                                        FirstIds=concat([CFirstId,trade.SFirstId(ti1),trade.SENTRD_VOL_QT(ti1) + remain])
# nonsameday.m:83
                                        buysellmatchedid=concat([[buysellmatchedid],[FirstIds]])
# nonsameday.m:84
                                        if (isempty(partleft) != 1):
                                            commonrows3=intersect(partleft(arange(),1),trade.SFirstId(ti1))
# nonsameday.m:86
                                        else:
                                            commonrows3=[]
# nonsameday.m:88
                                        if isempty(commonrows3) != 1:
                                            mindice3=ismember(partleft(arange(),1),commonrows3)
# nonsameday.m:91
                                            partleft[mindice3,2]=- remain
# nonsameday.m:92
                                            break
                                        else:
                                            partleft=concat([[partleft],[trade.SFirstId(ti1),- remain]])
# nonsameday.m:95
                                            break
                                    else:
                                        FirstIds=concat([CFirstId,trade.SFirstId(ti1),trade.SENTRD_VOL_QT(ti1) + remain])
# nonsameday.m:99
                                        buysellmatchedid=concat([[buysellmatchedid],[FirstIds]])
# nonsameday.m:100
                                        if (isempty(partleft) != 1):
                                            commonrows3=intersect(partleft(arange(),1),trade.SFirstId(ti1))
# nonsameday.m:102
                                        else:
                                            commonrows3=[]
# nonsameday.m:104
                                        if isempty(commonrows3) != 1:
                                            mindice3=ismember(partleft(arange(),1),commonrows3)
# nonsameday.m:107
                                            partleft[mindice3,2]=- remain
# nonsameday.m:108
                                            break
                                        else:
                                            partleft=concat([[partleft],[trade.SFirstId(ti1),- remain]])
# nonsameday.m:111
                                            break
                CFirstId=datamatrix.FirstId(cf + 1)
# nonsameday.m:121
            else:
                commonrows=intersect(trade.SFirstId,MdSFirstId)
# nonsameday.m:127
                if (isempty(commonrows) != 1):
                    mindice=ismember(trade.SFirstId,commonrows)
# nonsameday.m:129
                    trade=trade(logical_not(mindice),arange())
# nonsameday.m:130
                if (isempty(trade) != 1):
                    if (isempty(partleft) != 1):
                        commonrows2=intersect(trade.SFirstId,partleft(arange(),1))
# nonsameday.m:134
                        if (isempty(commonrows2) != 1):
                            mindice2=ismember(trade.SFirstId,commonrows)
# nonsameday.m:136
                            for icommon1 in arange(1,size(mindice2,1)).reshape(-1):
                                trade(mindice2(icommon1),arange()).SENTRD_VOL_QT = copy(partleft(mindice2(icommon1),2))
# nonsameday.m:138
                    ntrade=size(trade,1)
# nonsameday.m:142
                    buyamount=trade.ENTRD_VOL_QT(1)
# nonsameday.m:143
                    remain=copy(buyamount)
# nonsameday.m:144
                    for ti1 in arange(1,ntrade).reshape(-1):
                        remain=remain - trade.SENTRD_VOL_QT(ti1)
# nonsameday.m:147
                        if remain <= 0:
                            #display(remain); # check
                            if remain == 0:
                                for ti2 in arange(1,ti1).reshape(-1):
                                    FirstIds=concat([CFirstId,trade.SFirstId(ti2),trade.SENTRD_VOL_QT(ti2)])
# nonsameday.m:152
                                    buysellmatchedid=concat([[buysellmatchedid],[FirstIds]])
# nonsameday.m:153
                                    dSFirstId=trade.SFirstId(ti2)
# nonsameday.m:154
                                    MdSFirstId=concat([[MdSFirstId],[dSFirstId]])
# nonsameday.m:155
                                break
                            else:
                                #   display('true'); # check
                                if ti1 > 1:
                                    for ti2 in arange(1,ti1 - 1).reshape(-1):
                                        FirstIds=concat([CFirstId,trade.SFirstId(ti2),trade.SENTRD_VOL_QT(ti2)])
# nonsameday.m:163
                                        buysellmatchedid=concat([[buysellmatchedid],[FirstIds]])
# nonsameday.m:164
                                        dSFirstId=trade.SFirstId(ti2)
# nonsameday.m:165
                                        MdSFirstId=concat([[MdSFirstId],[dSFirstId]])
# nonsameday.m:166
                                    FirstIds=concat([CFirstId,trade.SFirstId(ti1),trade.SENTRD_VOL_QT(ti1) + remain])
# nonsameday.m:168
                                    buysellmatchedid=concat([[buysellmatchedid],[FirstIds]])
# nonsameday.m:169
                                    if (isempty(partleft) != 1):
                                        commonrows3=intersect(partleft(arange(),1),trade.SFirstId(ti1))
# nonsameday.m:171
                                    else:
                                        commonrows3=[]
# nonsameday.m:173
                                    if isempty(commonrows3) != 1:
                                        mindice3=ismember(partleft(arange(),1),commonrows3)
# nonsameday.m:176
                                        partleft[mindice3,2]=- remain
# nonsameday.m:177
                                        break
                                    else:
                                        partleft=concat([[partleft],[trade.SFirstId(ti1),- remain]])
# nonsameday.m:180
                                        break
                                else:
                                    FirstIds=concat([CFirstId,trade.SFirstId(ti1),trade.SENTRD_VOL_QT(ti1) + remain])
# nonsameday.m:184
                                    buysellmatchedid=concat([[buysellmatchedid],[FirstIds]])
# nonsameday.m:185
                                    if (isempty(partleft) != 1):
                                        commonrows3=intersect(partleft(arange(),1),trade.SFirstId(ti1))
# nonsameday.m:187
                                    else:
                                        commonrows3=[]
# nonsameday.m:189
                                    if isempty(commonrows3) != 1:
                                        mindice3=ismember(partleft(arange(),1),commonrows3)
# nonsameday.m:192
                                        partleft[mindice3,2]=- remain
# nonsameday.m:193
                                        break
                                    else:
                                        partleft=concat([[partleft],[trade.SFirstId(ti1),- remain]])
# nonsameday.m:196
                                        break
    
    buysellmatchedid=array2table(buysellmatchedid)
# nonsameday.m:211
    writetable(buysellmatchedid,'D:\csvdatatwoyear\bridge2.csv')
    #writematrix(buysellmatchedid,"E:\csvdata\BSmatrixSameDay.csv")