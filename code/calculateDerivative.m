function [derivative] = calculateDerivative(pupilPacket)

numberTimepoints = 7;

for timepoint = 1:length(pupilPacket.response.values)
    if timepoint < round(numberTimepoints/2)
        x = 1:(timepoint-1)+timepoint;
        y = pupilPacket.response.values(1:length(x));
        
    elseif timepoint > length(pupilPacket.response.values) - (round(numberTimepoints/2)-1);
        x = (timepoint - (length(pupilPacket.response.values) - timepoint)):length(pupilPacket.response.values);
        y = pupilPacket.response.values(x);
    else  
        x = (timepoint-(round(numberTimepoints/2-1)):timepoint+(round(numberTimepoints/2-1)));
        y = pupilPacket.response.values(x);
    end
        coefficients = polyfit(x,y,1);
        slope = coefficients(1);
        derivative(timepoint) = slope;
end

%plot(pupilPacket.response.timebase, abs(derivative))


        