[C_between,fc] = mscohere(GICp_GB_Ave(:,2),GICp_GE_Ave(:,2),window,noverlap,w);

N = size(GICp_GB,1);
window = ones(N/8,1);
noverlap = N/16;
%w = 2*pi*fe_EB;


err = GIC(:,2)-GICp_GE(:,2);
[Perr,ferr] = pwelch(err,window,noverlap);
[C_between,fc] = mscohere(GICp_GB_Ave(:,2),GICp_GE_Ave(:,2),window,noverlap,w);

[Perr_GE,ferr] = pwelch(errorE,window,noverlap,w);
[C_GE,fc] = mscohere(All.GIC(:,3),GICp_GE_Ave(:,2),window,noverlap,w);

[Perr_GB,ferr] = pwelch(errorB,window,noverlap,w);
[C_GB,fc] = mscohere(All.GIC(:,3),GICp_GB_Ave(:,2),window,noverlap,w);
    
fn=fn+1;fh=figure(fn);set(fh,'Name',[dateo,' coherence']);clf;
    semilogx(2*pi./fc(2:end),C_GE(2:end),'r','LineWidth',2)
    hold on;box on;grid on;
    semilogx(2*pi./fc(2:end),C_GB(2:end),'g','LineWidth',2)
    semilogx(2*pi./fc(2:end),C_between(2:end),'b','LineWidth',1)
    [lh,lo] = legend('G/E','G/B','G/B-G/E','Location','South');
    ylabel('Coherence')
    figconfig;
    if png,print('-dpng',sprintf('%s/GE_GB_coherence_%s.png',dirfig,dateo));end
