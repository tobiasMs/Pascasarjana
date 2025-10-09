function [Norm_pow] = Normalization(pow)

originalMinValue = min(pow);
originalMaxValue = max(pow);
originalRange = originalMaxValue - originalMinValue;
% Get a double image in the range 0 to +1
desiredMin = 0;
desiredMax = 1;
desiredRange = desiredMax - desiredMin;
Norm_pow = desiredRange * (pow - originalMinValue) / originalRange + desiredMin;