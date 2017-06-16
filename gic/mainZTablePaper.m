% Note that x->y and y->x here because mainZ assumes x = east and y = north.
fid = fopen(sprintf('paper/tables/%s.txt',Info.short),'w');
fprintf(fid,'& \\multicolumn{3}{c}{Training set}\\\\\n');
fprintf(fid,'& cc$_x$ & PE$_x$ & cc$_y$ & PE$_y$\\\\\n');
fprintf(fid,'\\hline\n');
fprintf(fid,'Method 1 & %0.2f & %.2f & %0.2f & %.2f\\\\\n',cctr_U(2),petr_U(2),cctr_U(1),petr_U(1));
fprintf(fid,'Method 2 & %0.2f & %.2f & %0.2f & %.2f\\\\\n',cctr_FDP(2),petr_FDP(2),cctr_FDP(1),petr_FDP(1));
fprintf(fid,'Method 3 & %0.2f & %.2f & %0.2f & %.2f\\\\\n',cctr_O(2),petr_O(2),cctr_O(1),petr_O(1));

%fclose(fid);

%fid = fopen(sprintf('paper/tables/%s_test.txt',Info.short),'w');
fprintf(fid,'\\\\\n');
fprintf(fid,'& \\multicolumn{3}{c}{Testing set}\\\\\n');
%fprintf(fid,'Method & cc$_x$ & PE$_x$ & cc$_y$ & PE$_y$\\\\\n');
fprintf(fid,'& cc$_x$ & PE$_x$ & cc$_y$ & PE$_y$\\\\\n');
fprintf(fid,'\\hline\n');
fprintf(fid,'Method 1 & %0.2f & %.2f & %0.2f & %.2f\\\\\n',ccte_U(2),pete_U(2),ccte_U(1),pete_U(1));
fprintf(fid,'Method 2 & %0.2f & %.2f & %0.2f & %.2f\\\\\n',ccte_FDP(2),pete_FDP(2),ccte_FDP(1),pete_FDP(1));
fprintf(fid,'Method 3 & %0.2f & %.2f & %0.2f & %.2f\\\\\n',ccte_O(2),pete_O(2),ccte_O(1),pete_O(1));
fclose(fid);
