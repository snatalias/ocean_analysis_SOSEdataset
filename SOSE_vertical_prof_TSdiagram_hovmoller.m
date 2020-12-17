%_________________________________________________________________________
%                          SR4 vertical profiles                         %
%   Southern Ocean State Estimate (SOSE) - http://sose.ucsd.edu/         %
%   
% W/ CDO: 
% 1. Cut SR4 region -- lat[-68 -60], lon[-71 -10]
% 2. Annual mean
%
% This scritpt calculates and plots vertical profiles of theta/salinity,
% also the T-S and Hovmoller diagrams

% Natalia Silva; natalia3.silva@usp.br
% (2020)
%_________________________________________________________________________

clear all; close all;

% Read data
sal = squeeze(ncread('/db4/reanalise/ocn/B-SOSE/sr4anual_S.nc','SALT'));
theta = squeeze(ncread('/db4/reanalise/ocn/B-SOSE/sr4anual_T.nc','THETA'));
v = squeeze(ncread('/db4/reanalise/ocn/B-SOSE/sr4anual_V.nc','VVEL'));
u = squeeze(ncread('/db4/reanalise/ocn/B-SOSE/sr4anual_U.nc','UVEL'));

% topography mask
sal(sal<=34) = NaN; theta(isnan(sal)) = NaN; v(isnan(sal)) = NaN;
u(isnan(sal)) = NaN;

lon = ncread('/db4/reanalise/ocn/B-SOSE/sr4anual_T.nc','lon');lon=lon-360;
lonu = squeeze(ncread('/db4/reanalise/ocn/B-SOSE/sr4anual_U.nc','lon'));
z = ncread('/db4/reanalise/ocn/B-SOSE/sr4anual_T.nc','Z'); 

%% Plot vertical profiles
figure('color',[1 1 1],'position',[108 305 600 900]);
v=(32:.05:35);
for i = 1:5
    subplot(5,1,6-i); contourf(lon,z(1:36),sal(:,1:36,i)',v);hold on
    contour(lon,z(1:36),sal(:,1:36,i)',v);hold on
    colormap(flipud(cmocean('thermal')))
    title(i+2007); ylabel('z (m)','Fontsize',9)
    caxis([34.5 34.72])
    subplot(5,1,5);xlabel('Longitude')
end       
colorbar('southoutside');title(colorbar,'^oC')
    
figure('color',[1 1 1],'position',[108 305 600 900]); 
vv=(-2:.1:1.2);
for i = 1:5
    subplot(5,1,6-i); contourf(lon,z(1:36),theta(:,1:36,i)',vv);hold on
    contour(lon,z(1:36),theta(:,1:36,i)',vv);cmocean('balance')
    title(i+2007,'Fontsize',11); ylabel('z (m)','Fontsize',9)
    caxis([-1.1 0.9])
    subplot(5,1,5);xlabel('Longitude');
end
colorbar('southoutside');title(colorbar,'^oC')

figure('color',[1 1 1],'position',[108 305 600 800]); 
p=(-0.05:.008:0.05);
for i = 1:5
    subplot(5,1,6-i); contourf(lon,z(1:36),v(:,1:36,i)',p);hold on
    contour(lon,z(1:36),v(:,1:36,i)',p);cmocean('balance')
    title(i+2007,'Fontsize',11); ylabel('z (m)','Fontsize',9)
    caxis([-0.03 0.04]);cmocean('matter')
    subplot(5,1,5);xlabel('Longitude');
end
colorbar('southoutside');title(colorbar,'^oC')

 
%% T-S Diagrams @ SR4

figure('color',[1 1 1],'position',[108 305 600 900])
%thetaS_diagram(theta,sal);title('Diagrama \thetaS (0-400m)')
%hold on
thetaS_diagram(theta(:,1:28,:),sal(:,1:28,:));xlim([33.9 34.8])

thetam = zeros(1,28,5); salm = zeros(1,28,5);
for i = 1:5
    thetam(:,:,i) = squeeze(mean(theta(:,1:28,i))); 
    salm(:,:,i) = squeeze(mean(sal(:,1:28,i)));
end

figure('color',[1 1 1],'position',[108 305 600 700]); 
thetaS_diagram(theta(:,1:28,1)),sal(:,1:28,1));xlim([33.9 34.8])
hold on
thetaS_diagram((theta(:,1:28,2)),sal(:,1:28,2));xlim([33.9 34.8])
hold on
thetaS_diagram((theta(:,1:28,3)),sal(:,1:28,3));xlim([33.9 34.8])
hold on
thetaS_diagram((theta(:,1:28,4)),sal(:,1:28,4));xlim([33.9 34.8])
hold on
thetaS_diagram((theta(:,1:28,5)),sal(:,1:28,5));xlim([33.9 34.8])

%% mapa leste oeste
addpath('/home/natalia/rotinas_MATLAB/m_map')
lat = [-90:-60];lon1 = [0:150];
figure('color',[1 1 1],'position',[108 305 600 900])
m_proj('stereographic','lat',-90,'long',0,'radius',60);
m_grid('ytick',[-60 -70 -80 -90],'xtick',12,'tickdir','out', 'xaxisLocation', 'top'...
    ,'box','on', 'fontsize',7,'linewidth',1.5);
m_coast('color','k','linewidth',1.5);

%% HOVMOLLER      

salh = squeeze(ncread('/db4/reanalise/ocn/B-SOSE/sr4mon_S.nc','SALT')); 
thetah = squeeze(ncread('/db4/reanalise/ocn/B-SOSE/sr4mon_T.nc','THETA'));
vh = squeeze(ncread('/db4/reanalise/ocn/B-SOSE/sr4mon_V.nc','VVEL'));
tempo = ncread('/db4/reanalise/ocn/B-SOSE/sr4mon_S.nc','time'); 
tempo = datenum(datetime(2008,1,1)+seconds(tempo));

salh = salh(:,27:33,:); salh = squeeze(mean(salh,2));
thetah = thetah(:,27:33,:); thetah = squeeze(mean(thetah,2));
vh = vh(:,27:33,:); vh = squeeze(mean(vh,2));

salh(salh<=34) = NaN; thetah(isnan(salh)) = NaN; vh(isnan(salh)) = NaN;

figure('color',[1 1 1],'position',[108 305 600 600]);
pp = (34.5:0.5:34.7); colormap(flipud(cmocean('thermal')))
contourf(lon,tempo,salh',pp); hold on; contour(lon,tempo,salh',pp) 
xlim([-54 -12]);caxis([34.63 34.73])
xlabel('Longitude'); ylabel('Tempo'); datetick('y',12,'keepticks')
title('Diagrama Hovmoller na WOCE-SR4 - S')
t = colorbar; tt = get(t,'title');set(tt, 'string', 'S')

figure('color',[1 1 1],'position',[108 305 600 600]);
pp = (-0.5:0.1:1); colormap(cmocean('balance'))
contourf(lon,tempo,thetah',pp); hold on; contour(lon,tempo,thetah',pp) 
xlim([-54 -12]);
xlabel('Longitude'); ylabel('Tempo'); datetick('y',12,'keepticks')
title('Diagrama Hovmoller na WOCE-SR4 - \Theta')
t = colorbar; tt = get(t,'title');set(tt, 'string', '^oC')

% propagation T1
loni = -12.38; ti = tempo(7); lonf = -38.5; tf = tempo(23);
ds = (-(lonf-loni))*111.12*cosd(70); %km
dt = (23-7)*30*24 %horas;
propagacaoT1 = ds/dt; % km/hr

% propagation T2
loni2 = -17.17; ti2 = tempo(13); lonf2 = -39.17; tf2 = tempo(57);
ds2 = (-(lonf2-loni2))*111.12*cosd(70); %km
dt2 = (57-13)*30*24 %horas;
propagacaoT2 = ds2/dt2; % km/hr

