function [sa, sigma] = fn_BJF_1997_horiz(M, R, T, Fault_Type, Vs, arb)

% by Jack Baker, 2/1/05
% Stanford University
% bakerjw@stanford.edu
%
% Boore Joyner and Fumal attenuation model (1997 Seismological Research
% Letters, Vol 68, No 1, p154). 
%
% This script includes standard deviations for either
% arbitrary or average components of ground motion See Baker, JW, and 
% Cornell, CA (2006). "Which spectral acceleration are you using?" 
% Earthquake Spectra, 22(2), 293-312.
%
% This script has also been modified to correct an error in the original
% publication. See Boore, DM (2005). "Erratum: Equations for Estimating
% Horizontal Response Spectra and Peak Acceleration from Western North 
% American Earthquakes: A Summary of Recent Work." Seismological Research 
% Letters, 76(3), 368-369.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT
%
% M             = Moment Magnitude
% R             = joyner boore distance
% T             = period (0.001 to 2s)
% Fault_Type    = 1 for strike-slip fault 
%               = 2 for reverse-slip fault
%               = 0 for non-specified mechanism
% Vs            = shear wave velocity averaged over top 30 m (use 310 for soil, 620 for rock)
% arb           = 1 for arbitrary component sigma
%               = 0 for average component sigma
%
% OUTPUT   
%
%   sa              = median spectral acceleration prediction
%   sigma           = logarithmic standard deviation of spectral acceleration
%                     prediction FOR AN ARBITRARY OR AVERAGE COMPONENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% import package for self reference
import hazus.fn_BJF_1997_horiz

% coefficients
period = [ 0.001 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2 0.22 0.24 0.26 0.28 0.3 0.32 0.34 0.36 0.38 0.4 0.42 0.44 0.46 0.48 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 ];
B1ss = [ -0.313 1.006 1.072 1.109 1.128 1.135 1.128 1.112 1.09 1.063 1.032 0.999 0.925 0.847 0.764 0.681 0.598 0.518 0.439 0.361 0.286 0.212 0.14 0.073 0.005 -0.058 -0.122 -0.268 -0.401 -0.523 -0.634 -0.737 -0.829 -0.915 -0.993 -1.066 -1.133 -1.249 -1.345 -1.428 -1.495 -1.552 -1.598 -1.634 -1.663 -1.685 -1.699 ];
B1rv = [ -0.117 1.087 1.164 1.215 1.246 1.261 1.264 1.257 1.242 1.222 1.198 1.17 1.104 1.033 0.958 0.881 0.803 0.725 0.648 0.57 0.495 0.423 0.352 0.282 0.217 0.151 0.087 -0.063 -0.203 -0.331 -0.452 -0.562 -0.666 -0.761 -0.848 -0.932 -1.009 -1.145 -1.265 -1.37 -1.46 -1.538 -1.608 -1.668 -1.718 -1.763 -1.801 ];
B1all = [ -0.242 1.059 1.13 1.174 1.2 1.208 1.204 1.192 1.173 1.151 1.122 1.089 1.019 0.941 0.861 0.78 0.7 0.619 0.54 0.462 0.385 0.311 0.239 0.169 0.102 0.036 -0.025 -0.176 -0.314 -0.44 -0.555 -0.661 -0.76 -0.851 -0.933 -1.01 -1.08 -1.208 -1.315 -1.407 -1.483 -1.55 -1.605 -1.652 -1.689 -1.72 -1.743 ];
B2 = [ 0.527 0.753 0.732 0.721 0.711 0.707 0.702 0.702 0.702 0.705 0.709 0.711 0.721 0.732 0.744 0.758 0.769 0.783 0.794 0.806 0.82 0.831 0.84 0.852 0.863 0.873 0.884 0.907 0.928 0.946 0.962 0.979 0.992 1.006 1.018 1.027 1.036 1.052 1.064 1.073 1.08 1.085 1.087 1.089 1.087 1.087 1.085 ];
B3 = [ 0 -0.226 -0.23 -0.233 -0.233 -0.23 -0.228 -0.226 -0.221 -0.216 -0.212 -0.207 -0.198 -0.189 -0.18 -0.168 -0.161 -0.152 -0.143 -0.136 -0.127 -0.12 -0.113 -0.108 -0.101 -0.097 -0.09 -0.078 -0.069 -0.06 -0.053 -0.046 -0.041 -0.037 -0.035 -0.032 -0.032 -0.03 -0.032 -0.035 -0.039 -0.044 -0.051 -0.058 -0.067 -0.074 -0.085 ];
B5 = [ -0.778 -0.934 -0.937 -0.939 -0.939 -0.938 -0.937 -0.935 -0.933 -0.93 -0.927 -0.924 -0.918 -0.912 -0.906 -0.899 -0.893 -0.888 -0.882 -0.877 -0.872 -0.867 -0.862 -0.858 -0.854 -0.85 -0.846 -0.837 -0.83 -0.823 -0.818 -0.813 -0.809 -0.805 -0.802 -0.8 -0.798 -0.795 -0.794 -0.793 -0.794 -0.796 -0.798 -0.801 -0.804 -0.808 -0.812 ];
Bv = [ -0.371 -0.212 -0.211 -0.215 -0.221 -0.228 -0.238 -0.248 -0.258 -0.27 -0.281 -0.292 -0.315 -0.338 -0.36 -0.381 -0.401 -0.42 -0.438 -0.456 -0.472 -0.487 -0.502 -0.516 -0.529 -0.541 -0.553 -0.579 -0.602 -0.622 -0.639 -0.653 -0.666 -0.676 -0.685 -0.692 -0.698 -0.706 -0.71 -0.711 -0.709 -0.704 -0.697 -0.689 -0.679 -0.667 -0.655 ];
Va = [ 1396 1112 1291 1452 1596 1718 1820 1910 1977 2037 2080 2118 2158 2178 2173 2158 2133 2104 2070 2032 1995 1954 1919 1884 1849 1816 1782 1710 1644 1592 1545 1507 1476 1452 1432 1416 1406 1396 1400 1416 1442 1479 1524 1581 1644 1714 1795 ];
h = [ 5.57 6.27 6.65 6.91 7.08 7.18 7.23 7.24 7.21 7.16 7.1 7.02 6.83 6.62 6.39 6.17 5.94 5.72 5.5 5.3 5.1 4.91 4.74 4.57 4.41 4.26 4.13 3.82 3.57 3.36 3.2 3.07 2.98 2.92 2.89 2.88 2.9 2.99 3.14 3.36 3.62 3.92 4.26 4.62 5.01 5.42 5.85 ];
sigma1 = [ 0.431 0.44 0.437 0.437 0.435 0.435 0.435 0.435 0.435 0.435 0.435 0.435 0.437 0.437 0.437 0.44 0.44 0.442 0.444 0.444 0.447 0.447 0.449 0.449 0.451 0.451 0.454 0.456 0.458 0.461 0.463 0.465 0.467 0.467 0.47 0.472 0.474 0.477 0.479 0.481 0.484 0.486 0.488 0.49 0.493 0.493 0.495 ];
sigmac = [0.160 0.134 0.141 0.148 0.153 0.158 0.163 0.166 0.169 0.173 0.176 0.177 0.182 0.185 0.189 0.192 0.195 0.197 0.199 0.200 0.202 0.204 0.205 0.206 0.209 0.210 0.211 0.214 0.216 0.218 0.220 0.221 0.223 0.226 0.228 0.230 0.230 0.233 0.236 0.239 0.241 0.244 0.246 0.249 0.251 0.254 0.256];
sigmar = [ 0.460 0.460 0.459 0.461 0.461 0.463 0.465 0.466 0.467 0.468 0.469 0.470 0.473 0.475 0.476 0.480 0.481 0.484 0.487 0.487 0.491 0.491 0.494 0.494 0.497 0.497 0.501 0.504 0.506 0.510 0.513 0.515 0.518 0.519 0.522 0.525 0.527 0.531 0.534 0.537 0.541 0.544 0.546 0.550 0.553 0.555 0.557];
sigmae = [ 0.184 0 0 0 0 0 0 0 0 0.002 0.005 0.009 0.016 0.025 0.032 0.039 0.048 0.055 0.064 0.071 0.078 0.085 0.092 0.099 0.104 0.111 0.115 0.129 0.143 0.154 0.166 0.175 0.184 0.191 0.2 0.207 0.214 0.226 0.235 0.244 0.251 0.256 0.262 0.267 0.269 0.274 0.276 ];
sigmalny = [ 0.495 0.460 0.459 0.461 0.461 0.463 0.465 0.466 0.467 0.468 0.469 0.470 0.474 0.475 0.477 0.482 0.484 0.487 0.491 0.492 0.497 0.499 0.502 0.504 0.508 0.510 0.514 0.520 0.526 0.533 0.539 0.544 0.549 0.553 0.559 0.564 0.569 0.577 0.583 0.590 0.596 0.601 0.606 0.611 0.615 0.619 0.622];

% interpolate between periods if neccesary    
if (length(find(period == T)) == 0)
    index_low = sum(period<T);
    T_low = period(index_low);
    T_hi = period(index_low+1);
    
    [sa_low, sigma_low] = fn_BJF_1997_horiz(M, R, T_low, Fault_Type, Vs, arb);
    [sa_hi, sigma_hi] = fn_BJF_1997_horiz(M, R, T_hi, Fault_Type, Vs, arb);
    
    x = [log(T_low) log(T_hi)];
    Y_sa = [log(sa_low) log(sa_hi)];
    Y_sigma = [sigma_low sigma_hi];
    sa = exp(interp1(x,Y_sa,log(T)));
    sigma = interp1(x,Y_sigma,log(T));
    
else
    i = find(period == T);

    % compute median and sigma
    r = sqrt(R^2 + h(i)^2);

    if(Fault_Type == 1)
        b1 = B1ss(i);
    elseif(Fault_Type == 2)
        b1 = B1rv(i);
    else
        b1 = B1all(i);
    end
    
    lny= b1 + B2(i)*(M-6) + B3(i)*(M-6)^2 + B5(i)*log(r) + Bv(i)*log(Vs / Va(i));   
    sa = exp(lny);

    if (arb) % arbitrary component sigma
        sigma = sigmalny(i);
    else     % average component sigma
        sigma = sqrt(sigma1(i)^2 + sigmae(i)^2);
    end
end