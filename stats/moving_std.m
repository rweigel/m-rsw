function x = moving_std(x,N)
    
if (N > size(x,1))
  error(['moving_std: N (= %d) must be less than or equal '...
          'size(x,1) (= %d)\n'],N,size(x,1));
end


