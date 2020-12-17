%_________________________________________________________________________
%                          Oceanic data analysis                         %
%   Southern Ocean State Estimate (SOSE) - http://sose.ucsd.edu/ 	     %
% 	This script calculates potential temperature, salinity and velocities
%   differences between 2012 and 2008, in the Southern Ocean

% Natalia Silva; natalia3.silva@usp.br
% (2020)
%_________________________________________________________________________

close all;clear all

%% Read data from 2008 to 2012 
dado = ('/db4/reanalise/ocn/B-SOSE/bsose_i105_2008to2012_monthly_Salt.nc');
tempo = ncread(dado,'time'); tempo = double(tempo); 
tempo = datenum(datetime(2008,1,1)+seconds(tempo)); 
lon = ncread(dado,'XC'); lat = ncread(dado,'YC'); 
sal = ncread(dado,'SALT');

%% Define Southern Ocean regions (East and West)
leste = find(lon>30 & lon<150); lonleste = lon(leste);
amun = find(lon>150 & lon<300); lonamun = lon(amun);
pen = find(lon>300 & lon<360); lonpen = lon(pen);

% Southern Ocean: lat > -60
austral = find(lat<-60); lataus = lat(austral);

%% Mean salinity map
sal = squeeze(sal(:,austral,1,:)); % st surface
salanual = downsample_ts(sal,tempo,'year'); % annual mean

for i = 1:5
	substitui = salanual(:,:,i);    
	mascara = find(salanual(:,:,i)==0); substitui(mascara) = NaN;
	salanual(:,:,i) = substitui;

	figure('color',[1 1 1],'position',[108 305 500 450]);
	v=(33:0.1:35);
	m_proj('stereographic','lat',-90,'long',0,'radius',60);
	m_contourf(lon,lataus,salanual(:,:,i)',v); hold on
	m_contour(lon,lataus,salanual(:,:,i)',v)
	m_grid('ytick',[-70 -80 -90],'xtick',12,'radius',60,'tickdir','out',
	 'xaxisLocation', 'top','yaxisLocation',...
	    'middle','box','on', 'fontsize',7,'linewidth',1.5);
	m_coast('color','k','linewidth',1.5);
	title(2007+i);
	t = colorbar; tt = get(t,'title'); %set(tt,'string','hPa')
	cmocean('balance')
end

%% Last yr (2012) @minus first yr (2008)
Dif = salanual(:,:,5)-salanual(:,:,1);

figure('color',[1 1 1],'position',[108 305 500 450]);
v=(-0.5:0.1:0.5);
m_proj('stereographic','lat',-90,'long',0,'radius',60);
m_contourf(lon,lataus,Dif',v); hold on
m_contour(lon,lataus,Dif',v)
m_grid('ytick',[-70 -80 -90],'xtick',12,'radius',60,'tickdir','out',
 'xaxisLocation', 'top','yaxisLocation',...
    'middle','box','on', 'fontsize',7,'linewidth',1.5);
m_coast('color','k','linewidth',1.5);
title('Diferenca (2012 - 2008)');
t = colorbar; tt = get(t,'title'); %set(tt,'string','hPa')
cmocean('balance')

%% Annual cycle at surface (z = 1) for each region

mesleste = squeeze(mean(mean(sal(leste,austral,:))));
mesamun = squeeze(mean(mean(sal(amun,austral,:))));
mespen = squeeze(mean(mean(sal(pen,austral,:))));

% Remove outliers
outleste = find(mesleste > mean(mesleste)+2.5*std(mesleste) |...
    mesleste < mean(mesleste)-2.5*std(mesleste)); mesleste(outleste) = NaN;
xleste = 1:(length(mesleste)); intl = isnan(mesleste);
mesleste(intl) = interp1(xleste(~intl),mesleste(~intl),xleste(intl)); 
clear outleste; clear xl;

outamun = find(mesamun > mean(mesamun)+2.5*std(mesamun) |...
    mesamun < mean(mesamun)-2.5*std(mesamun)); mesamun(outamun) = NaN;
xamun = 1:(length(mesamun)); intamun = isnan(mesamun);
mesamun(intamun) = interp1(xamun(~intamun),mesamun(~intamun),xamun(intamun)); 
clear outamun; clear xamun;

% outpen = find(mespen > mean(mespen)+2.5*std(mespen) |...
%     mespen < mean(mespen)-2.5*std(mespen)); mespen(outpen) = NaN;
% xpen = 1:(length(mespen)); intpen = isnan(mespen);
% mespen(intpen) = interp1(xpen(~intpen),mespen(~intpen),xpen(intpen)); clear outpen; clear xpen;

%% Surface anomalies
% monthly means (Jan, Fev, Mar...)
month = []; c = [1:12]; 
for j = 1:5
	month = horzcat(month,c);
end
clear c

medmensalleste = []; medmensalamun = []; medmensalpen = [];
anomleste = []; anomamun = []; anompen = [];

for i = 1:12
    mes = find(month == i); 
   
    medmensalleste = horzcat(medmensalleste,mean(mesleste(mes)));
    medmensalamun = horzcat(medmensalamun,mean(mesamun(mes)));
    medmensalpen = horzcat(medmensalpen,mean(mespen(mes)));
end

% anomalies (J2008 - Jan, Fev2008-Fev ... Jan2009-Jan...)
k = 1; anomleste = []; anomamun = []; anompen = [];
for i = 1:length(tempo)
    anomleste = horzcat(anomleste, mesleste(i) - medmensalleste(k)); 
    anomamun = horzcat(anomamun, mesamun(i) - medmensalamun(k));
    anompen = horzcat(anompen, mespen(i) - medmensalpen(k)); 
   
    k = k+1;
    if k > 12
         k = 1;
    end
end
clear k; clear i

% PLOT
figure('color','W','position',[108 305 800 700])
subplot(2,1,1)
plot(tempo,mesleste,'color',[1 0.5 0.6],'linewidth',1.2);
xlim([min(tempo) max(tempo)]); ylim([8 28])
set(gca,'Color',[0.92 0.92 0.92]); title('Ciclo Anual - S (z = 0)')
ylabel('S'); xlabel('Anos'); datetick('x',12,'keepticks') % 12 = Mar00 ou 28 = Mar2000
hold on; plot(tempo,mesamun,'color', [0 0.7 0.9],'linewidth',1.2);
hold on; plot(tempo,mespen,'color',[0 0.9 0.2], 'linewidth', 1.2)
legend('Leste', 'Amundsen', 'Peninsula')

subplot(2,1,2)
plot(tempo,anomleste,'color',[1 0.5 0.6],'linewidth',1.2);
xlim([min(tempo) max(tempo)]); ylim([-0.1 0.1])
set(gca,'Color',[0.92 0.92 0.92]); title('Anomalia - S (z = 0)')
xlabel('Anos');ylabel('S');datetick('x',12,'keepticks') % 12 = Mar00 ou 28 = Mar2000
hold on; plot(tempo,anomamun,'color', [0 0.7 0.9],'linewidth',1.2);
hold on; plot(tempo,anompen,'color',[0 0.9 0.2], 'linewidth', 1.2)
legend('Leste', 'Amundsen', 'Peninsula')
