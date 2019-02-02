function savefig(fname)

[ST, I] = dbstack('-completenames', 1);
%export_fig(fname,'-transparent');
export_fig(fname);
fprintf('%s.m: Wrote %s\n',ST.name,fname);
