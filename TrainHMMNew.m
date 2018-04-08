function [trans,emis]= TrainHMMNew (AllObs, Emissions)
%this is a working code May 25,2013

obsNum=length(Emissions);
States=obsNum*4;
A = ones(States)/States;
B = ones(States,obsNum)/obsNum;
[trans,emis]=hmmtrain(AllObs,A,B,'Symbols',Emissions);

end