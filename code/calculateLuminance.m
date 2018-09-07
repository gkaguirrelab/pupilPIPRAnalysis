function [ luminance ] = calculateLuminance(backgroundSpectrum, S, luminanceType)
% calculateLuminance
%
% Usage:
%     [ luminance ] = calculateLuminance(backgroundSpectrum, S, 'photopic')
%
% Description:
%    Calculate the luminance of the inputted spectrum.
%
%    This function takes in an SPD and calculates the luminance of that spectrum. This function can calculate either
%    photopic or scoptopic luminance depending on the user input. Note that the photopic luminance is currently
%    calculated according to the 10 degree CIE fundamentals
%
% Input:
%    backgroundSpectrum     - Background spd in column vector of length nWls.
%    S (1x3)                - Wavelength spacing.
%    luminanceType          - A string that specifies which luminance should be calculated. Options are limited to
%                            'photopic' or 'scotopic'
%
%
% Output:
%    luminance              - The calculated luminance in cd/m2




if strcmp(luminanceType, 'scotopic')
    load T_rods;
    T_vLambda = SplineCmf(S_rods,T_rods,S);
    magicFactor = 1700;
    luminance = T_vLambda * [backgroundSpectrum] * magicFactor;
    
end

if strcmp(luminanceType, 'photopic')
    
    load T_xyzCIEPhys10
    T_xyz = SplineCmf(S_xyzCIEPhys10,683*T_xyzCIEPhys10,S);
    
    luminance = T_xyz(2,:) * [backgroundSpectrum];
    
end

end