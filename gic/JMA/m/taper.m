function [GIC,E,B] = taper(GIC,E,B,wname)

w = window(wname,size(GIC,1));
GIC = GIC.*repmat(w,1,size(GIC,2));

w = window(wname,size(E,1));
E = E.*repmat(w,1,size(E,2));

w = window(wname,size(B,1));
B = B.*repmat(w,1,size(B,2));
