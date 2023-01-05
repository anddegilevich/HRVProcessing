clc
close all
clear all

global hMenu1 hAxes1 hAxes2 hAxes3 RR3

figure(1)
hMenu1=uicontrol('Style','popupmenu','Units','normalized',...
'Position',[0.75,0.87,0.24,0.1],'FontSize', 20,...
'Backgroundcolor',[1 1 1],'Callback','rythmSelect',...
'String',{'No Signal','Normal Rhytm',...
'Extrasystoles','Atrial Fibrillation'});
hAxes1=axes('Position',[0.05,0.61,0.94,0.3]);
hAxes2=axes('Position',[0.05,0.05,0.45,0.50]);
hAxes3=axes('Position',[0.54,0.05,0.45,0.50]);

xlabel(hAxes1,'RR number')
ylabel(hAxes1,'RR duration, s')
title(hAxes1,'Rhythmogram')

xlabel(hAxes2,'RR duration, s')
ylabel(hAxes2,'Rate')
title(hAxes2,'RR histogram')

xlabel(hAxes3,'RR duration, s')
ylabel(hAxes3,'RR duration, s')
title(hAxes3,'Scattergram')
%--------------------------------------------------------------------------
RR3=load('samples/rhythmogram.txt');