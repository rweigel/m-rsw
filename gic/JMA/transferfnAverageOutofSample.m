function Soos = transferfnAverageOutofSample(S,opts)

% Create base structure for average models. The results are in-sample results.
Soos = transferfnAverage(S,opts);

% Over-write the metrics parts of Soos by recalculating them with
% using out-of-sample models.
for u = 1:size(S.PE,3) % Loop over intervals

  % Create list of intervals excluding u.      
  if isfield(S,'ao')
    Io = setdiff([1:size(S.ao,3)],u);
  else
    Io = setdiff([1:size(S.Z,3)],u); 
  end
  
  % Compute average models excluding interval u from calculation.
  Stmp = transferfnAverage(S,opts,Io);

  in = mean(Soos.Mean.PE,3); % Original
  out = mean(Stmp.Mean.PE,3); % New

  fprintf('transferfnAverageOutofSample: Interval %d: Mean model In-sample PE: %6.6f; Out-of-Sample PE: %6.6f\n',u,in(2),out(2));
  
  Soos.Mean.PE(1,:,u) = mean(Stmp.Mean.PE,3);
  Soss.Median.PE(1,:,u) = mean(Stmp.Median.PE,3);
  Soss.Huber.PE(1,:,u) = mean(Stmp.Median.PE,3);    

  Soos.Mean.CC(1,:,u) = mean(Stmp.Mean.CC,3);
  Soos.Median.CC(1,:,u) = mean(Stmp.Median.CC,3);
  Soos.Huber.CC(1,:,u) = mean(Stmp.Median.CC,3);    
  
  Soos.Mean.MSE(1,:,u) = mean(Stmp.Mean.MSE,3);
  Soos.Median.MSE(1,:,u) = mean(Stmp.Median.MSE,3);
  Soos.Huber.MSE(1,:,u) = mean(Stmp.Median.MSE,3);    

  Soos.Mean.Error_PSD(:,:,u) = mean(Stmp.Mean.Error_PSD,3);
  Soos.Median.Error_PSD(:,:,u) = mean(Stmp.Median.Error_PSD,3);
  Soos.Huber.Error_PSD(:,:,u) = mean(Stmp.Median.Error_PSD,3);    

  Soos.Mean.Coherence(:,:,u) = mean(Stmp.Mean.Coherence,3);
  Soos.Median.Coherence(:,:,u) = mean(Stmp.Median.Coherence,3);
  Soos.Huber.Coherence(:,:,u) = mean(Stmp.Median.Coherence,3);    

  Soos.Mean.SN(:,:,u) = mean(Stmp.Mean.SN,3);
  Soos.Median.SN(:,:,u) = mean(Stmp.Median.SN,3);
  Soos.Huber.SN(:,:,u) = mean(Stmp.Median.SN,3);    
  
end
