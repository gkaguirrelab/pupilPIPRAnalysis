function [ responseIntegrationTime ] = calculateResponseIntegrationTime(timebase, response)

responseIntegrationTime = abs(trapz(timebase, response))/max(abs(response));