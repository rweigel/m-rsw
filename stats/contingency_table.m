function [CT,CTt] = contingency_table(X,Y,thresh_X,thresh_Y,T)
%CONTINGENCY_TABLE 
%
%    [CT,t_H,t_Hbar,t_e,t_f] = contingency_table(X,Y,thresh_X,thresh_Y)
%
%    [CT,t_H,t_Hbar,t_e,t_f] = contingency_table(X,Y,thresh_X,thresh_Y,T)
%
%    If X(t-1) < thresh_X and X(t) >= thresh_X, Y is predicted to go from
%    below thresh_Y to above or equal to thresh_Y on any one of t+1, t+2,
%    ..., t+T.  Default is T = 1.
% 
%    CT is the contingency matrix with elements 
%            | N_H        N_Hbar       (N_H+N_Hbar) | 
%            | N_M          x          (N_M+x)      |
%            | (N_H+N_M)  (N_Hbar+x)      N         |
% 
%    N_H    number of hits (event and forecast)  
%    N_Hbar number of false alarms (forecast but no event)  
%    N_M    number of misses (event but no forecast)  
%    x      number of nulls (no event and no forecast)
%    N      Total number of intervals
%
%    CTt is a cell array with elements 
%            | t_H        t_Hbar    t_f   | 
%            | t_M         NaN      NaN   |
%            | t_e         NaN      NaN   |
%
%    t_H    indices of the hits
%    t_Hbar indices of the false alarms
%    t_M    indices of the misses
%    t_e    indices of the events
%    t_f    indices of the forecasts
%
%    If T = 1, then N = length(X)-1.
%  
%    Note that if T > 1, the number of non-events and non-predictions is
%    given by 
%
%    CT(2,2) = (length(X)-1)-length(t_e)-T*length(t_f)+CT(1,1);
%
%    The length(X)-1 term is first point in Y is not counted as an event or
%    nonevent because no information is available for a prediction.
%
%    See also CONTINGENCY_TABLE_DEMO.

if (nargin < 5)
  T = 1;
end
  
if (length(X) ~= length(Y))
  error('length(X) must be same as length(Y)');
  return;
end

if (prod(size(X)) > max(size(X)))
  error('X must be a row or column array');
end
if (prod(size(Y)) > max(size(Y)))
  error('X must be a row or column array');
end

% Find times of threshold crossing in X and Y
t_X   = find((X(2:end)>=thresh_X) & (X(1:end-1)<thresh_X) & (Y(2:end)<thresh_Y));
t_Y   = find((Y(2:end)>=thresh_Y) & (Y(1:end-1)<thresh_Y));

if (~isempty(t_X) & ~isempty(t_Y)) % If at least one prediction and one forecast.
  
  t_e = t_Y + 1;     % Index of crossing (e = event) + 1
                     % corresponds to calling it event when
                     % first measured.

  t_f = t_X + 1 + 1; % Make prediction one index after thresh_X	  

  for i = 1:T			  
    a(:,i)   = ismember(t_e,t_f+i-1);  % For each event, see if any
				       % t_f matches.
    am(:,i)  = ismember(t_f+i-1,t_e);  % For each forecast, see if any
				       % t_e matches.
  end

  at  = sum(a,2);      
  atm = sum(am,2);
  
  if (~isempty(at))           
    t_Hbar     = find(atm == 0);
    t_H        = find(at > 0);

    t_H        = t_e(t_H);
    t_Hbar     = t_f(t_Hbar);
  else                        
    t_H        = [];     
    t_Hbar     = [];     
  end

  N_e      = length(t_e);    % Number of events      
  N_H      = length(t_H);    % Number of hits
  N_Hbar   = length(t_Hbar); % Number of false alarms
%  N_f      = length(t_f);   % Number of forecasts with double counting.  
                             % (which gives contingency table problems
                             % since must have N_Hbar+N_Hbar = Nf in table)
  N_f      = N_H+N_Hbar;       % Number of forecasts with no double counting.  
  
else % If not at least one prediction and one forecast.
  
  if (~isempty(t_X) & isempty(t_Y)) % If at least one forecast and no events.
    N_Hbar = length(t_X);
    N_H = 0;
    t_f = t_X + 1 + 1;
    t_e = [];
    t_H = [];     
    t_Hbar = t_X + 1 + 1;     
  end
  if (isempty(t_X) & ~isempty(t_Y)) % If at least one event and no forecasts.
    N_H = 0;
    N_Hbar = 0;
    t_f = [];
    t_e = t_Y+1;
    t_H = [];     
    t_Hbar = [];     
  end
  if (isempty(t_X) & isempty(t_Y)) % If no events and no forecasts.
    N_Hbar = 0;
    N_H = 0;
    t_f = [];
    t_e = [];
    t_H = [];     
    t_Hbar = [];     
  end
  
end


CT(1,1) = N_H;      
CT(1,2) = N_Hbar;         
CT(1,3) = N_H+N_Hbar;  

CT(2,1) = length(t_e)-CT(1,1); 
CT(3,1) = length(t_e);         


t_M     = setdiff(t_e,t_H);

CT(2,2) = (length(X)-1)-length(t_e)-T*length(t_f)+CT(1,1);  

% length(X)-1 because we should not count first point.
% T*length(t_f) is the number of days there was a prediction

CT(3,2) = CT(1,2) + CT(2,2);      
CT(2,3) = CT(2,1) + CT(2,2);      
CT(3,3) = CT(3,1) + CT(3,2);      
check   = CT(1,3) + CT(2,3);      

if (check - CT(3,3) ~= 0)
  error('Problem with contingency table');
end
  
if (nargout > 1)
  CTt{1,1} = t_H;
  CTt{1,2} = t_Hbar;
  CTt{1,3} = t_f;

  CTt{2,1} = t_M;
  CTt{2,2} = NaN;
  CTt{2,3} = NaN;

  CTt{3,1} = t_e;
  CTt{3,2} = NaN;
  CTt{3,3} = NaN;
end