function [ luminance ] = calculateLuminance(backgroundSpectrum, S, luminanceType)

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