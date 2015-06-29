function [val,num] = counts(x)
%COUNTS Counts of unique integer values
%
%   [Val,Num] = COUNTS(x)
%
%   Example: If x = [0,0.1,0,  1,  3,3,3.1,  3.9]
%             Val = [   0,     1,    3        4] 
%             Num = [   3,     1,    3,       1]
%
%   The code for this function is simply
%   x = round(x);  
%   val = unique(round(x));
%   num = hist(x,[val(1):val(end)]');
%
%   See also HIST, UNIQUE.

x = round(x);  
val = unique(x);
num = hist(x,[val(1):val(end)])


  