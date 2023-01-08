%% HRV analysis
function processHRV()

% Creating the interface 
figure(1)
hAxes1=axes('Position',[0.05,0.75,0.94,0.2]);
hAxes2=axes('Position',[0.05,0.46,0.94,0.2]);
hAxes3=axes('Position',[0.05,0.05,0.35,0.35]);
hAxes4=axes('Position',[0.55,0.05,0.35,0.35]);
hGroup=uibuttongroup('Position',[0.42,0.25,0.10,0.15]);
rb1=uicontrol('Style','Radio','String','Periodogram','FontSize', 15,...
    'Units','normalized','Position',[0.05 0.5 0.9 0.30],'parent',hGroup);
rb2=uicontrol('Style','Radio','String','Welch method','FontSize', 15,...
    'Units','normalized','Position',[0.05 0.15 0.9 0.30],'parent',hGroup);
hFunc1=@getSpectrum;
set(hGroup,'SelectionChangeFcn',hFunc1,'SelectedObject',[]);
hSlider=uicontrol('Style','Slider','Units','normalized',...
    'Position',[0.91,0.3,0.08,0.08]);
hFunc2=@getARSpectrum;
set(hSlider,'Callback',hFunc2,'Min',0,'Max',20);
hTxta=uicontrol('Style','text','String','P=', 'FontSize',15,...
    'Units','normalized','Position',[0.92,0.13,0.08,0.08]);

% Load and plot rhythmogram
RR=load('samples/hrv.txt');
axes(hAxes1)
hold on
NRR=length(RR);
for i=1:NRR
    x(1)=i;
    x(2)=i;
    R(1)=0;
    R(2)=RR(i);
    plot(x,R);
end
RRmax=max(RR)*1.2;
set(hAxes1,'Xlim',[0 NRR],'Ylim',[0 RRmax])
title(hAxes1, 'Rhythmogram')
ylabel(hAxes1, 'RR duration')
xlabel(hAxes1, 'RR number')

% Get and plot uniformly sampled HRV signal
t=0;
for i=1:NRR
    t=t+RR(i);
    tRR(i)=t;
end
sRR=csaps(tRR,RR,1); % Rhythmogram spline interpolation
Fs=4; % Sampling rate
T=1/Fs;
tsRR=0:T:tRR(NRR);
RR4Hz=ppval(sRR,tsRR); % Uniformly sampled signal 
axes(hAxes2)
plot(tsRR,RR4Hz)
set(hAxes2,'Xlim',[0 tRR(NRR)],'Ylim',[0 RRmax])
title(hAxes2, 'HRV')
ylabel(hAxes2, 'RR duration')
xlabel(hAxes2, 'time, s')

% Spectrum method selection function
function getSpectrum(~,Sel)
nfft=2048;
RR0=detrend(RR4Hz)*1000;
df=Fs/nfft;
Fmax=0.5;
Nf=fix(Fmax/df);

axes(hAxes3)
if Sel.NewValue==rb1
    % Periodogramm method
    window=hamming(length(RR4Hz));
    [Pxx,f]=periodogram(RR0,window,nfft,Fs);
    plot(f(1:Nf),Pxx(1:Nf))
else
    % Welch method
    Nw=500;
    noverlap=100;
    window=hamming(Nw);
    [Pxx,f]=pwelch(RR0,window,noverlap,nfft,Fs);
    plot(f(1:Nf),Pxx(1:Nf))
end
Ymax=max(Pxx(1:Nf))*1.3;
set(hAxes3,'Ylim',[0 Ymax]);
title(hAxes3, 'HRV spectrum')
xlabel(hAxes3, 'Frequency, Hz')
ylabel(hAxes3, 'Power')

% C alculation of spectral characteristics of HRV
flim=[0.003 0.04 0.15 0.4];
VLF=0;
LF=0;
HF=0;
i=0;
f=0;
while f<=flim(4)
    f=df*i;
    i=i+1;
    if f>=flim(1) && f<flim(2)
        VLF=VLF+Pxx(i)*df;
    elseif f>=flim(2) && f<flim(3)
        LF=LF+Pxx(i)*df;
    elseif f>=flim(3)
        HF=HF+Pxx(i)*df;
    end
end

% Display values
VLF=round(VLF);
dy=Ymax/10;
text(0.3,Ymax-dy,['VLF=' num2str(VLF) ' ms^2']);
LF=round(LF);
text(0.3,Ymax-2*dy,['LF=' num2str(LF) ' ms^2']);
HF=round(HF);
text(0.3,Ymax-3*dy,['HF=' num2str(HF) ' ms^2']);
end

% Autoregression spectrum method params selection function
function getARSpectrum(h,Sel)
P=round(get(hSlider,'Value')); % Model order
if P==0
    P=1;
end
set(hTxta,'String',("P="+num2str(P)));
nfft=2048;
RR0=detrend(RR4Hz)*1000;
df=Fs/nfft;
Fmax=0.5;
Nf=fix(Fmax/df);

axes(hAxes4)
[Pxx,f]=pburg(RR0,P,nfft,Fs);
plot(f(1:Nf),Pxx(1:Nf))
Ymax=max(Pxx(1:Nf))*1.3;
set(hAxes4,'Ylim',[0 Ymax]);
title(hAxes4, 'HRV spectrum')
xlabel(hAxes4, 'Frequency, Hz')
ylabel(hAxes4, 'Power')

flim=[0.003 0.04 0.15 0.4];
VLF=0;
LF=0;
HF=0;
i=0;
f=0;
while f<=flim(4)
    f=df*i;
    i=i+1;
    if f>=flim(1) && f<flim(2)
        VLF=VLF+Pxx(i)*df;
    elseif f>=flim(2) && f<flim(3)
        LF=LF+Pxx(i)*df;
    elseif f>=flim(3)
        HF=HF+Pxx(i)*df;
    end
end

VLF=round(VLF);
dy=Ymax/10;
text(0.3,Ymax-dy,['VLF=' num2str(VLF) ' ms^2']);
LF=round(LF);
text(0.3,Ymax-2*dy,['LF=' num2str(LF) ' ms^2']);
HF=round(HF);
text(0.3,Ymax-3*dy,['HF=' num2str(HF) ' ms^2']);
end

end