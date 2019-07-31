function Soos = transferfnAverageOutofSample(S,opts)

% Create base structure for average models. The results (in-sample) metrics
% will be replaced.
fprintf('transferfnAverageOutofSample.m: Computing metrics using average model based on all intervals.\n');
Soos = transferfnAverage(S,opts);

Sis = Soos; % In sample results.

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
  fprintf('transferfnAverageOutofSample.m: Computing metrics using average model excluding interval %d\n',u);
  Stmp = transferfnAverage(S,opts,Io);

  keys = fieldnames(Stmp);
  for f = 1:length(keys)
      in = mean(Soos.(keys{f}).PE,3);  % Original
      out = mean(Stmp.(keys{f}).PE,3); % New
      
      Soos.(keys{f}).PE(1,:,u) = Stmp.(keys{f}).PE(:,:,u);
      Soos.(keys{f}).CC(1,:,u) = Stmp.(keys{f}).CC(:,:,u);
      Soos.(keys{f}).MSE(1,:,u) = Stmp.(keys{f}).MSE(:,:,u);
      Soos.(keys{f}).Error_PSD(:,:,u) = Stmp.(keys{f}).Error_PSD(:,:,u);
      Soos.(keys{f}).Coherence(:,:,u) = Stmp.(keys{f}).Coherence(:,:,u);
      Soos.(keys{f}).SN(:,:,u) = Stmp.(keys{f}).SN(:,:,u);

      comp = 'x';
      for c = 1:2
          if c == 2, comp = 'y'; end
          fprintf(['transferfnAverageOutofSample.m: Comp %s Method %s, Interval %d: '...
                   'Mean model In-sample PE/CC/MSE: %.4f/%.4f/%.6f; '...
                   'Out-of-Sample PE/CC/MSE: %.4f/%.4f/%.6f\n'],...
                    comp,...
                    keys{f},...
                    u,...
                    Stmp.(keys{f}).PE(1,c,u),...
                    Stmp.(keys{f}).CC(1,c,u),...
                    Stmp.(keys{f}).MSE(1,c,u),...
                    Sis.(keys{f}).PE(1,c,u),...
                    Sis.(keys{f}).CC(1,c,u),...
                    Sis.(keys{f}).MSE(1,c,u));
      end
  end
end
