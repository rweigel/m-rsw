%NONFLAG_DEMO 
% Demo and test of NONFLAG functions.
%
%   NONFLAG_DEMO executes several tests on the NONFLAG functions.
% 

for j = 1:4
for i = 1:2

  if (i == 1) & (j == 1)
  	FLAG = NaN;
  end
  if (j > 1)
  	FLAG = 999.0;
  end;

  COND = j-2;
  
  D    = [1 2 FLAG 3 4 FLAG FLAG 5 6 FLAG 7 8 9 10]';  
  Do   = [1:10]';
  Z    = zeros(size(D));
  Zo   = zeros(size(Do));

  % Note max_nonflag, min_nonflag, mean_nonflag, and std_nonflag, etc. do not
  % have the same syntax as Octave or Matlab max, min, and std functions.
  % The demos below are compatable with these Octave and Matlab functions,
  % however.

  T(1)  = max_nonflag(D,1,FLAG,COND)  - max(Do);
  T(2)  = min_nonflag(D,1,FLAG,COND)  - min(Do);
  T(3)  = mse_nonflag(D,Z,FLAG,COND)  - mse(Do,Zo);
  T(4)  = arv_nonflag(D,Z,FLAG,COND)  - arv(Do,Zo);
  T(5)  = pe_nonflag(D,Z,FLAG,COND)   - pe(Do,Zo);
  T(6)  = mean_nonflag(D,1,FLAG,COND) - mean(Do);
  T(7)  = std_nonflag(D,1,FLAG,COND)  - std(Do);
  T(8)  = sum_nonflag(D,1,FLAG,COND)  - sum(Do);

  T(9)  = sum_nonflag(prod_nonflag(D,D,FLAG,COND),1,FLAG,COND) - sum(Do.*Do);
  T(10) = sum_nonflag(rectify_nonflag(D,FLAG,COND),1,FLAG,COND)- sum(rectify(Do));

  dx    = Do;
  dx(1) = -1;
  tmp1  = corrcoef(Do,dx);
  d     = D;
  d(1)  = -1;
  tmp2  = corrcoef_nonflag(D,d,FLAG,COND);
  T(11) = tmp1(2)-tmp2(2);


  %tmp1  = corrcoef([Do,Do]);
  %tmp2  = corrcoef_nonflag([D,D],FLAG,COND);% Syntax not allowed
  %T(12) = tmp1(2)-tmp2(2);

  I = find(T~=0);
  if ~isempty(I)
    error(['Error in nonflag function test(s) ',sprintf('i = %d, j = %d, I = ',i,j),sprintf('%d ',I(:))]);
  else
    fprintf('Test 1.%d.%d OK.\n',j,i);
  end

end
end

FLAG = 999;
Drf = reflag(D,FLAG,-FLAG);
Drf = reflag(Drf,-FLAG,FLAG);
if (Drf ~= D)
   fprintf('Test 2 failed\n');
else	
   fprintf('Test 2 OK.\n');
end	

D(1) = -D(1);
Dr = rectify_nonflag(D,FLAG);
if (Dr(1) ~= 0)
   fprintf('Test 3 failed\n');
else	
   fprintf('Test 3 OK.\n');
end	

Do_dt = block_corrcoef(Do,Do,3); 
if (Do_dt ~= [1 1 1]') % Choice of Do just happens to lead to exact integer 
                       % so comparison as in Test 11 is not needed.
   fprintf('Test 4 failed\n');
else	
   fprintf('Test 4 OK.\n');
end	

D_dt = block_corrcoef_nonflag(D,D,3,FLAG);
if (abs(max(D_dt - 1)) > eps)
   fprintf('Test 5 failed.\n');
else	
   fprintf('Test 5 OK.\n');
end	

Do_dt = block_detrend(Do,3);
if (Do_dt ~= [-1 0 1 -1 0 1 -1 0 1 NaN]')
   fprintf('Test 6 failed\n');
else	
   fprintf('Test 6 OK.\n');
end	

Do_dt = block_detrend_nonflag(D,3,FLAG);
if (Do_dt ~= [-1.5 1.5 FLAG -0.5 0.5 FLAG FLAG -0.5 0.5 FLAG -0.5 0.5 FLAG FLAG]')
   fprintf('Test 7 failed\n');
else	
   fprintf('Test 7 OK.\n');
end	

Do_dt = block_mean(Do,3);
if (Do_dt ~= [2 5 8]')
   fprintf('Test 8 failed\n');
else	
   fprintf('Test 8 OK.\n');
end	

D_dt = block_mean_nonflag(D,3,FLAG);
if (D_dt ~= [0.5 3.5 5.5 7.5]')
   fprintf('Test 9 failed\n');
else	
   fprintf('Test 9 OK.\n');
end	

Do_dt = block_std(Do,3);
if (Do_dt ~= [1 1 1]')
   fprintf('Test 10 failed\n');
else	
   fprintf('Test 10 OK.\n');
end	

D(1) = 1;
D_dt = block_std_nonflag(D,3,FLAG);
if (max(D_dt - 1/sqrt(2)) > eps)
   fprintf('Test 11 failed\n');
else	
   fprintf('Test 11 OK.\n');
end	

Do_m = moving_sum(Do,3);
if (Do_m ~= [NaN NaN 6 9 12 15 18 21 24 27]')
   fprintf('Test 12 failed\n');
else	
   fprintf('Test 12 OK.\n');
end	

[D_m,ng] = moving_sum_nonflag(D,3,FLAG);
if (D_m ~= [NaN NaN 3 5 7 7 4 5 11 11 13 15 24 27]') & ...
   (ng ~= [NaN NaN 2 2 2 2 1 1 2 2 2 2 3 3]')
   fprintf('Test 13 failed\n');
else	
   fprintf('Test 13 OK.\n');
end	
