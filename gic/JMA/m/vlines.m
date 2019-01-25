function vlines(m)
    yl = get(gca,'YLim');
    loglog([60,60],yl,'--','Color',[0.5,0.5,0.5]);
    text(60,yl(1),'1m','VerticalAlignment','bottom');

    if m < 3600*2
        yl = get(gca,'YLim');
        loglog([60*60,60*60],yl,'--','Color',[0.5,0.5,0.5]);
        text(60*60,yl(1),'1h','VerticalAlignment','bottom');
    end
    if m < 86400
        yl = get(gca,'YLim');
        loglog([12*60*60,12*60*60],yl,'--','Color',[0.5,0.5,0.5]);
        text(12*60*60,yl(1),'12h','VerticalAlignment','bottom');
    end
    if m < 86400/2
        yl = get(gca,'YLim');
        loglog([6*60*60,6*60*60],yl,'--','Color',[0.5,0.5,0.5]);
        text(6*60*60,yl(1),'6h','VerticalAlignment','bottom');
    end        
    if m < 86400*2
        yl = get(gca,'YLim');
        loglog([24*60*60,24*60*60],yl,'--','Color',[0.5,0.5,0.5]);
        text(24*60*60,yl(1),'1d','VerticalAlignment','bottom');
    end    
end