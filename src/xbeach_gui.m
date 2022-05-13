function xbeach_gui(varargin)
% version 1.1

%%%%%%  Missing characteristics %%%%%%
% write epsi, left, right parameters
% remove back option from flow boundaries
% Create Warning Table of suspicious parameters value

addpath(genpath('../libs/'));
addpath(genpath('./'));

% clear all;clc
global handles figurehandleX cor pos fh kt MB_phy handles_MB MB_out UISAVE...
    UISAVEAS directory direc_place version power_zoom_scroll corLine
if ~isempty(figurehandleX) & ishghandle(figurehandleX)
    figure(figurehandleX);
    return
end

% persistent tab_sed_transp tab_morphoUP


version='v1.1';
warning off;
% set(0,'DefaultAxesFontName', 'Consolas');
% set(0,'DefaultTextFontname', 'Consolas')

%%%%%%%%%%%%%%%%%%%%%%%%%    Default Properties    %%%%%%%%%%%%%%%%%%%%%%%%
power_zoom_scroll = 0.2;

%opengl('software');
% import java.awt.*;
% import java.awt.event.*;
% import javax.swing.*
% JFrame.setDefaultLookAndFeelDecorated(true); %java
kt=7;
% -                           SPLASH SCREEN
%--------------------------------------------------------------------------
% fh = figure('Visible','off','MenuBar','none','NumberTitle','off');
% modifyLogo(fh); ah = axes('Parent',fh,'Visible','off');
% splashPHOTO=imread('../assets/images/XB_logo01.png');
% ih = image(splashPHOTO,'parent',ah);
% imxpos = get(ih,'XData'); imypos = get(ih,'YData');
% set(ah,'Unit','Normalized','Position',[0,0,1,1]);
% figpos = get(fh,'Position'); figpos(3:4) = [imxpos(2) imypos(2)];
% set(fh,'Position',figpos); movegui(fh,'center'); axis off;
% set(fh,'Visible','on');
% ht = timer('StartDelay',1,'ExecutionMode','SingleShot','TimerFcn',@splashXbeach,...
%     'Name','Splash');
% start(ht);  pause(1);

% coefficients Hsu & Evans (1989)

for k=1:kt
    for g=1:9
        handles{g,k}=[];
    end
end
vertMargin = 0;
oldRootUnits = get(0,'Units');

% Restore the Units safely
c = onCleanup(@()set(0, 'Units', oldRootUnits));
set(0, 'Units', 'points');
screenSize = get(0,'ScreenSize');
delete(c);
% axFontSize=get(0,'FactoryAxesFontSize');
axFontSize=6;
set(0,'ScreenPixelsPerInch',96);
pointsPerPixel = 72/get(0,'ScreenPixelsPerInch');
width = 800 * pointsPerPixel;
height = 600 * pointsPerPixel;
pos = [screenSize(3)/2-width/2 screenSize(4)/2-height/2 width height];
% pos = [screenSize(3)-width/1.5-5 35 width/1.5 height];
axNorm=[.05 .1 .6 .1];
%     axPos=axNorm.*[pos(3:4),pos(3:4)] + [0 vertMargin 0 -2];
axPos=[width/4 59 width*0.4 9];

% Create a figure
cor=[0.9 0.9 0.9];
corLine = [0 0 0];
directory=pwd;
figurehandleX = figure('Units', 'points','BusyAction','queue','WindowStyle','normal', ...
    'Position',pos,'Resize','off','CreateFcn','','NumberTitle','off', ...
    'IntegerHandle','off','MenuBar','none','Tag','XbeachGUI','Interruptible','off', ...
    'DockControls','off','Visible','on','Interruptible','off','name',...
    ['XBeach GUI  --  ',fsize(directory),'*'],'color',cor);
f=uimenu(figurehandleX,'label','File');
uimenu(f,'label','New','callback',@newFile00,'enable','on');
OPEN_PARAMS=uimenu(f,'label','Open','callback',@openfile,'enable','on');
UISAVE=uimenu(f,'label','Save','callback',@savefile,'enable','off');
UISAVEAS=uimenu(f,'label','Save As','callback',@saveasfile,'enable','off','separator','on');
uimenu(f,'label','Exit','callback',@myclosereq);
vM=uimenu(figurehandleX,'label','View');
uimenu(vM,'label','Visualization Area','callback',@viewarea);
aboutM=uimenu(figurehandleX,'label','Help');
uimenu(aboutM,'label','About','callback',@aboutXbeachGUI);

set(figurehandleX, 'CloseRequestFcn', @myclosereq);
setappdata(figurehandleX,'figurehandle',figurehandleX);

% change figure logo
modifyLogo(figurehandleX)

% plot initial data
MB_tf=uicontrol('units','points','parent',figurehandleX,'style','pushbutton',...
    'string','Time Frame','fontsize',10,'fontw','bold',...
    'position',[10 height-30 110 20],'callback',@timeframe_button);
MB_dom=uicontrol('units','points','parent',figurehandleX,'style','pushbutton',...
    'string','Domain','fontsize',10,'fontw','bold',...
    'position',[10 height-55 110 20],'callback',@domain_button);
MB_proc=uicontrol('units','points','parent',figurehandleX,'style','pushbutton',...
    'string','Processes','fontsize',10,'fontw','bold',...
    'position',[10 height-80 110 20],'callback',@processes_button);
MB_lim=uicontrol('units','points','parent',figurehandleX,'style','pushbutton',...
    'string','Limiters','fontsize',10,'fontw','bold',...
    'position',[10 height-105 110 20],'callback',@limiters_button);
MB_phy=uicontrol('units','points','parent',figurehandleX,'style','pushbutton',...
    'string','Physical Parameters','enable','off','fontsize',10,'fontw','bold',...
    'position',[10 height-130 110 20],'callback',@phy_parameters_button);
MB_bound=uicontrol('units','points','parent',figurehandleX,'style','pushbutton',...
    'string','Boundaries','fontsize',10,'fontw','bold',...
    'position',[10 height-155 110 20],'callback',@boundaries_button);
MB_drifters=uicontrol('units','points','parent',figurehandleX,'style','pushbutton',...
    'string','Drifters','fontsize',10,'fontw','bold',...
    'position',[10 height-180 110 20],'callback',@drifters_button,'enable','off');
MB_monit=uicontrol('units','points','parent',figurehandleX,'style','pushbutton',...
    'string','Monitoring','fontsize',10,'fontw','bold',...
    'position',[10 height-205 110 20],'callback',@monitoring_button,'enable','off');
MB_out=uicontrol('units','points','parent',figurehandleX,'style','pushbutton',...
    'string','Output','fontsize',10,'fontw','bold','enable','off',...
    'position',[10 height-230 110 20],'callback',@output_button);
handles_MB=[MB_tf MB_dom MB_proc MB_lim MB_phy MB_bound MB_drifters MB_monit MB_out];

%     Disable access to the handle
set(figurehandleX, 'HandleVisibility', 'callback')

direc_icon=imread('../assets/images/FolderOpen.png');
for i=1:size(direc_icon,1)
    for j=1:size(direc_icon,2)
        if direc_icon(i,j,:)==0 | direc_icon(i,j,:)<100
            direc_icon(i,j,:)=255*0.9;
        end
    end
end
direc_text=uicontrol('parent',figurehandleX,'unit','normalized','style','text',...
    'string','Select Directory','position',[0.01 0.005 0.13 0.027],...
    'fontsize',9,'fontw','bold','backgroundcolor',cor);
direc_place=uicontrol('parent',figurehandleX,'unit','normalized','style','edit',...
    'string',pwd,'position',[0.14 0.003 0.81 0.034],'fontw','normal',...
    'fontsize',8,'backgroundcolor',[1 1 1],'horizontalalignment','center');
direc_dir=uicontrol('parent',figurehandleX,'unit','normalized','style','pushbutton',...
    'cdata',direc_icon,'position',[0.96 0.005 0.028 0.033],...
    'callback',@select_directory);

function select_directory(varargin)
global figurehandleX direc_place
fig=getappdata(figurehandleX,'figurehandle');
path=uigetdir(pwd,'Select Directory');
if path~=0
    set(direc_place,'string',path);
    set(figurehandleX,'name',['XBeach GUI  --  ',fsize(path),'*']);
    cd(path)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            File Menu - Save                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function savefile(varargin)
global handles figurehandleX cor fh figureSAVEfilesX params0 directory version...
    tstop CFL...
    gridform xyfile depfile thetamin  thetamax dtheta  ...
    hmin eps umin hwci...
    gravity_value rho...
    cf C nuh nuhfac nuhv smag zs0file tideloc...
    wavint wci gamma gammax alpha n roller beta...
    rhoa Cd windv windth...
    z0 facsl BRfac rhos	por tsfac facua...
    morfac morstart wetslp dryslp hswitch...
    bcfile...
    thetanaut...
    scheme break_value...
    waveform form thetanum smax...
    morfacopt sourcesink...
    fbound1_Pop fbound1_PopCon...
    fbound2_Pop fbound2_PopCon...
    instat...
    outputformat...
    swave lwave flow sedtrans morphology nonh gwflow q3d...
    lws sws...
    outGlob_CB outTimeAvg_CB outPoint_CB... %variables types
    outGlobAll_CB outGlobZb_CB outGlobZs_CB...
    outGlobH_CB outGlobEu_CB outGlobthMean_CB outGlobsedero_CB outGlobdzav_CB... 
    outGlobsusg_CB outGlobsvsg_CB outGlobsubg_CB outGlobsvbg_CB... global
    outTavgAll_CB outTavgbH_CB outTavgEu_CB... 
    outTavgsusg_CB outTavgsvsg_CB outTavgsubg_CB outTavgsvbg_CB...time-averaged
    outPointAll_CB outPointzs_CB outPointH_CB outPointEu_CB...
    tstart tintg tintm tintp
vin=varargin;
if ~isempty(vin) & ischar(vin{1})
    save_directory=vin{1};
else
    save_directory=pwd; save_directory=[save_directory,'\params.txt'];
end

% try
    fig=getappdata(figurehandleX,'figurehandle');
    set(0, 'Units', 'points'); screenSize = get(0,'ScreenSize');
    width=250; height=150; un=20;
    pos = [screenSize(3)/2-width/0.4 screenSize(4)/2-height/2 width 0];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% edit variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    auxE1={tstop;CFL}; keyE1={'tstop';'CFL'}; defaultE1={1000;0.7};
    %if Delft3DForm  - INCOMPLETE - TO REVISE (XBEACH FORM)
    auxE2={gridform; xyfile; depfile; thetamin; thetamax; dtheta; };
    keyE2={'gridform';'xyfile';'depfile';'thetamin';'thetamax';'dtheta'}; defaultE2={'delft3d';'';'';0;270;20};
    auxE3=[]; keyE3=[]; defaultE3=[];
    auxE4={hmin; eps; umin; hwci}; %limiters tab
    keyE4={'hmin';'eps';'umin';'hwci'}; defaultE4={0.05; 0.005; 0.0; 0.1};
    auxE5={gravity_value; rho; ...%constant tab
        cf; C; nuh; nuhfac; nuhv; smag; zs0file; tideloc;...%flow tab
        wavint; wci; gamma; gammax; alpha; n; roller; beta;...%wave tab
        rhoa; Cd; windv; windth;...%wind tab
        z0; facsl; BRfac; rhos;	por; tsfac; facua;...% sed_trans tab
        morfac; morstart; wetslp; dryslp; hswitch}; %morpho tab
    keyE5={'g';'rho';'cf';'C';'nuh';'nuhfac';'nuhv';'smag'; 'zs0file'; 'tideloc';...
        'wavint';'wci';'gamma';'gammax';'alpha';'n';'roller';'beta';...
        'rhoa';'Cd';'windv';'windth';...
        'z0';'facsl';'BRfac';'rhos';'por';'tsfac';'facua';...
        'morfac';'morstart';'wetslp';'dryslp';'hswitch'};
    defaultE5={9.81; 1025; 0.003; sqrt(9.81/0.003); 0.15; 0; 1; 1; '';'';...
        1; 0; 0.55; 2; 1; 10; 1; 0.15;...
        1.25; 0.002; 5; 0;...
        0.006; 0; 1; 2650; 0.4; 0.1; 0;...
        1; 120; 0.3; 1; 0.1};
    auxE6={bcfile}; keyE6={'bcfile'}; defaultE6={'jonswap'};%wave boundary
    auxE7=[]; keyE7=[]; defaultE7=[];
    auxE8=[]; keyE8=[]; defaultE8=[];
    auxE9={tstart; tintg; tintm; tintp};
    keyE9={'tstart';'tintg';'tintm';'tintp'}; 
    defaultE9={'0';'60';'3600';'2'};
    for j=1:9
        eval(['var1=auxE',num2str(j),';']); eval(['var2=keyE',num2str(j),';']);
        eval(['var3=defaultE',num2str(j),';']);
        for i=1:33
            if ~isempty(var1)
                if i <= size(var1,1)
                    variable_handles_Edit{i,j}=var1{i,1};
                    keywordsE{i,j}=var2{i,1};
                    defaultEdit{i,j}=var3{i,1};
                else
                    variable_handles_Edit{i,j}=[];
                    keywordsE{i,j}=[];
                    defaultEdit{i,j}=[];
                end
            else
                variable_handles_Edit{i,j}=[];
                keywordsE{i,j}=[];
                defaultEdit{i,j}=[];
            end
        end
        clear var1 var2 var3
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% pop-up variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    auxPOP1=[]; keyPOP1=[]; defaultPOP1=[];
    auxPOP2={thetanaut}; keyPOP2={'thetanaut'}; defaultPOP2={0}; % ATTENTION %grid
    auxPOP3=[]; keyPOP3=[]; defaultPOP3=[];
    auxPOP4=[]; keyPOP4=[]; defaultPOP4=[];
    auxPOP5={scheme; break_value;...%wave tab
        waveform; form; thetanum; smax;...%sed_transport tab
        morfacopt; sourcesink}; %morpho tab
    keyPOP5={'scheme';'break';...
        'waveform';'form';'thetanum';'smax';...
        'morfacopt';'sourcesink'};
    defaultPOP5={2; 3;...
        'vanthiel'; 1; 1; 1; ...
        2; 1};
    auxPOP6={instat;'0.5';...
        fbound1_PopCon;...%flow boundary 1
        fbound2_PopCon}; %flow boundary2
    % wave boundary
    axB1=get(fbound1_Pop,'string'); axB2=get(fbound1_PopCon,'string');
    axB3=get(fbound2_Pop,'string'); axB4=get(fbound2_PopCon,'string');
    keyPOP6={'instat';'dtbc'; ...
        axB1(get(fbound1_Pop,'value'),1:end);... %axB2(get(fbound1_PopCon,'value'),1:end);...
        axB3(get(fbound2_Pop,'value'),1:end)}; %axB4(get(fbound2_PopCon,'value'),1:end)};
    % ??????? %%%%%%%%%%%%%%%     ATTENTION     %%%%%%%%%%%%%%%
    defaultPOP6={6; 0.5;...
        'abs_1d';...
        'wall'}; % ATTENTION
    auxPOP7=[]; keyPOP7=[]; defaultPOP7=[];
    auxPOP8=[]; keyPOP8=[]; defaultPOP8=[];
    auxPOP9={outputformat}; keyPOP9={'outputformat'}; defaultPOP9={2};
    for j=1:9
        eval(['var1=auxPOP',num2str(j),';']); eval(['var2=keyPOP',num2str(j),';']);
        eval(['var3=defaultPOP',num2str(j),';']);
        for i=1:8
            if ~isempty(var1)
                if i <= size(var1,1)
                    variable_handles_Pop{i,j}=var1{i,1};
                    keywordsPop{i,j}=var2{i,1};
                    defaultPOPUP{i,j}=var3{i,1};
                else
                    variable_handles_Pop{i,j}=[];
                    keywordsPop{i,j}=[];
                    defaultPOPUP{i,j}=[];
                end
            else
                variable_handles_Pop{i,j}=[];
                keywordsPop{i,j}=[];
                defaultPOPUP{i,j}=[];
            end
        end
        clear var1 var2 var3
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% check box variables %%%%%%%%%%%%%%%%%%%%%%%%%
    auxC1=[]; keyC1=[]; defaultC1=[];
    auxC2={swave; lwave; flow; sedtrans; morphology; nonh; gwflow; q3d}; %processes
    keyC2={'swave'; 'lwave'; 'flow'; 'sedtrans'; 'morphology'; 'nonh'; 'gwflow'; 'q3d'};
    defaultC2={1; 1; 1; 1; 1; 0; 0; 0};
    auxC3=[]; keyC3=[]; defaultC3=[];
    auxC4=[]; keyC4=[]; defaultC4=[];
    auxC5={lws;sws}; keyC5={'lws';'sws'}; defaultC5={1; 1};%sed_trans
    auxC6=[]; keyC6=[]; defaultC6=[];
    auxC7=[]; keyC7=[]; defaultC7=[];
    auxC8=[]; keyC8=[]; defaultC8=[];
    auxC9={outGlob_CB; ... %OUTPUT - variables types - INCOMPLETE
        outGlobAll_CB; outGlobZb_CB; outGlobZs_CB;...
        outGlobH_CB; outGlobEu_CB; outGlobthMean_CB; outGlobsedero_CB; outGlobdzav_CB;...
        outGlobsusg_CB; outGlobsvsg_CB; outGlobsubg_CB; outGlobsvbg_CB;... global
        outTimeAvg_CB; outTavgAll_CB; outTavgbH_CB; outTavgEu_CB;... 
        outTavgsusg_CB; outTavgsvsg_CB; outTavgsubg_CB; outTavgsvbg_CB;... time-averaged
        outPoint_CB; outPointAll_CB; outPointzs_CB; outPointH_CB; outPointEu_CB};%point
    keyC9={'nglobalvar'; ...
        'XbeachGlobal';'zb';'zs';'H';'ue';'thetamean';'sedero';'dzav';'Susg';'Svsg';'Subg';'Svbg';...
        'nmeanvar'; 'XbeachTime'; 'H'; 'ue';'Susg';'Svsg';'Subg';'Svbg';...
        'npoints'; 'XbeachPoint'; 'zs';'H';'ue'}; % ATTENTION
    defaultC9={1; ...
        ''; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1;...
        1;''; 1; 1; 1; 1; 1; 1;...
        1;''; 1; 1; 1}; % ATTENTION
    for j=1:9
        eval(['var1=auxC',num2str(j),';']); eval(['var2=keyC',num2str(j),';']);
        eval(['var3=defaultC',num2str(j),';']);
        for i=1:size(var1,1)
            if ~isempty(var1)
                if i <= size(var1,1)
                    variable_handles_Check{i,j}=var1{i,1};
                    keywordsCheck{i,j}=var2{i,1};
                    defaultCHECK{i,j}=var3{i,1};
                else
                    variable_handles_Check{i,j}=[];
                    keywordsCheck{i,j}=[];
                    defaultCHECK{i,j}=[];
                end
            else
                variable_handles_Check{i,j}=[];
                keywordsCheck{i,j}=[];
                defaultCHECK{i,j}=[];
            end
        end
        clear var1 var2 var3
    end
    
    %organizing params.txt file
    L=1;
    for col=1:9
        for f=1:3
            if f==1; name=keywordsE; elseif f==2; name=keywordsPop; elseif f==3; name=keywordsCheck; end
            for lin=1:size(name,1);
                if ~isempty(name{lin,col})
                    if f==1 % Edit
                        if col==2 & lin==1
                            params0{L,1}=name{lin,col}; params0{L,2}=variable_handles_Edit{lin,col};
                        elseif col==5 & lin==9
                            if strcmpi(get(variable_handles_Edit{lin,col},'string'),'Filename Unknown')==0
                                params0{L,1}=name{lin,col}; params0{L,2}=get(variable_handles_Edit{lin,col},'string');
                            else
                                continue
                            end
                        elseif col==5 & lin==10
                            if strcmpi(get(variable_handles_Edit{lin-1,col},'string'),'Filename Unknown')==1
                                continue
                            else
                                params0{L,1}=name{lin,col}; params0{L,2}=get(variable_handles_Edit{lin,col},'string');
                            end
                        else
                            if ~isempty(get(variable_handles_Edit{lin,col},'string'))
                                params0{L,1}=name{lin,col}; params0{L,2}=get(variable_handles_Edit{lin,col},'string');
                            else
                                params0{L,1}=name{lin,col}; params0{L,2}=defaultEdit{lin,col};
                            end
                        end
                    elseif f==2 % PopUpMenu
                        if col==6 & lin==2
                            params0{L,1}=name{lin,col}; params0{L,2}=variable_handles_Pop{lin,col};
                        else
                            if ~isempty(get(variable_handles_Pop{lin,col},'string'))
                                params0{L,1}=name{lin,col};
                                if col==5 & lin==7 | lin==8 || col==2 & lin==1
                                    params0{L,2}=get(variable_handles_Pop{lin,col},'value') - 1;
                                elseif col==5 & lin==3
                                    aux01=get(variable_handles_Pop{lin,col},'string');
                                    params0{L,2}=aux01(get(variable_handles_Pop{lin,col},'value'),1:end);
                                elseif col==5 & lin==4
                                    aux01=get(variable_handles_Pop{lin,col},'string');
                                    if strcmp(aux01([1:2:32]),'Soulsby\vanRijn ');
                                        params0{L,2}=1;
                                    elseif strcmp(aux01([2:2:32]),'Vanthiel\vanRijn');
                                        params0{L,2}=2;
                                    end
                                elseif col==5 & lin==5
                                    params0{L,2}=get(variable_handles_Pop{lin,col},'value') - 0.5;
                                elseif col==5 & lin==6 %col==6 & lin==1
                                    params0{L,2}=get(variable_handles_Pop{lin,col},'value') - 2;
                                elseif col==6 & lin==1
                                    aux01=get(variable_handles_Pop{lin,col},'value') - 2;
                                    if aux01==4; params0{L,2}='jons'; else params0{L,2}=aux01; end
                                elseif col==6 & lin==3 | lin==4
                                    aux01=get(variable_handles_Pop{lin,col},'string');
                                    params0{L,2}=aux01(get(variable_handles_Pop{lin,col},'value'),1:end);
                                else
                                    params0{L,2}=get(variable_handles_Pop{lin,col},'value');
                                end
                            else
                                params0{L,1}=name{lin,col}; params0{L,2}=defaultPOPUP{lin,col};
                            end
                        end
                    elseif f==3 % CheckBox
                        if ~isempty(get(variable_handles_Check{lin,col},'value'))
                            params0{L,1}=name{lin,col}; params0{L,2}=get(variable_handles_Check{lin,col},'value');
                        else
                            params0{L,1}=name{lin,col}; params0{L,2}=defaultCHECK{lin,col};
                        end
                    end
                    L=L+1;
                end
            end
        end
    end
    
    %write params.txt file
    clear params vector spaces
    l01=idx_finder(params0,'gridform',1); l02=idx_finder(params0,'swave',1); l03=idx_finder(params0,'hmin',1);
    l05=idx_finder(params0,'cf',1); l066=idx_finder(params0,'zs0file',1); l06=idx_finder(params0,'wavint',1);
    l07=idx_finder(params0,'rhoa',1); l08=idx_finder(params0,'z0',1); l09=find(ismember(params0(:,1),'morfac'));
    l10=idx_finder(params0,'bcfile',1); l11=idx_finder(params0,'front',1); l12=idx_finder(params0,'outputformat',1);
    l044=idx_finder(params0,'hwci',1); l04=l044+1;
    if isempty(l066)
        l066=l06;
    end
    
    if strcmp(get(variable_handles_Edit{9,5},'string'),'Filename Unknown')==1 
        handles_name={'Time Frame Parameters';'Domain Parameters';...
            'Processes Parameters'; 'Limiters Parameters';...
            'Constants Parameters'; 'Flow Parameters';...
            'Wave Parameters'; 'Wind Parameters';...
            'Sediment Transport Parameters'; 'Morphological Parameters';...
            'Wave Boundaries Parameters'; 'Flow Boundaries Parameters';...
            'Output Configuration'}; IDX02=13;
            spaces=[1 l01 l02 l03 l04 l05 l06 l07 l08 l09 l10 l11 l12 81]; i=1; % modify this vector if add some
    else
        handles_name={'Time Frame Parameters';'Domain Parameters';...
            'Processes Parameters'; 'Limiters Parameters';...
            'Constants Parameters'; 'Flow Parameters';'Tide/Surge Parameters';...
            'Wave Parameters'; 'Wind Parameters';...
            'Sediment Transport Parameters'; 'Morphological Parameters';...
            'Wave Boundaries Parameters'; 'Flow Boundaries Parameters';...
            'Output Configuration'}; IDX02=14;
            spaces=[1 l01 l02 l03 l04 l05 l066 l06 l07 l08 l09 l10 l11 l12 81]; i=1; % modify this vector if add some
    end
    
    % keywords in params.txt
    for g=1:size(spaces,2)-1;
        if g==1
            params{i,1}=dispSection('');
            params{i+1,1}=dispSection('                                          ');
            params{i+2,1}=dispSection('   XBeach parameter settings input file   ');
            params{i+3,1}=dispSection(['    Generated in XBeach GUI by GHG ',version,'   ']);
            params{i+4,1}=dispSection(['        Date: ',sprintf(datestr(clock)),'        ']);
            params{i+5,1}=dispSection('                                          '); i=i+7;
        end
        if g==size(spaces,2)-1
            i=i+1;
        end
        params{i,1}=dispSection(handles_name{g,1}); i=i+1;
        
        % output variables
        if strfind(params0{spaces(g),1},'outputformat')==1
            %         idxOUT=find_index('outputformat');
            aux=strfind(params0(:,1),'outputformat');
            for p=1:size(aux,1);
                if aux{p,1}==1
                    idxOUT=p;
                end
            end
            Vec=[idxOUT idxOUT+14 idxOUT+14]; D1=[1 0 0]; H1=[1 0 0];
            for Q=1:2 % INCOMPLETE - ATTENTION FOR POINT OUTPUT (Q = 3)
                clear vector
                idxOUT=Vec(Q);
                if params0{idxOUT,2}==2 % netcdf
                    params{i,1}=[params0{idxOUT,1},' = netcdf'];
                    params{i+1,1}=[params0{idxOUT-4,1},' = ',params0{idxOUT-4,2}];
                    params{i+2,1}=[params0{idxOUT-3,1},' = ',params0{idxOUT-3,2}];
                    params{i+3,1}=[params0{idxOUT-2,1},' = ',params0{idxOUT-2,2}];
                    i=i+5;
                end
                if params0{idxOUT+D1(Q),2}==1; cont=0; % save global variables
                    if Q==1
                        ax1=idxOUT+3; ax2=idxOUT+13;
                    elseif Q==2
                        ax1=idxOUT+2; ax2=idxOUT+7;
                    elseif Q==3
                        ax1=idxOUT+2; ax2=idxOUT+4;
                    end
                    for j= ax1 : ax2;
                        if params0{j,2}==1;
                            cont=cont+1;
                            vector(cont,1)=j;
                        end;
                    end
                    if exist('vector','var')
                        params{i,1}=[params0{idxOUT+H1(Q),1},' = ',num2str(cont)]; bACK=i; i=i+1;
                        for o=1:size(vector,1)
                            if strfind(params0{vector(o,1),1},'ue')==1
                                params{bACK,1}=[params0{idxOUT+H1(Q),1},' = ',num2str(cont+1)];
                                params{i,1}='ue'; params{i+1,1}='ve'; i=i+2;
                            else
                                params{i,1}=params0{vector(o,1),1}; i=i+1;
                            end
                            if o==length(vector); i=i+1; end
                        end
                    end
                end
            end
        end
        
        if g<IDX02
            if g==IDX02 - 1
                k1=spaces(g); k2=spaces(g+1) - 5;
            else
                k1=spaces(g); k2=spaces(g+1) - 1;
            end
            for k=k1 : k2
                %         aux99=string_converter(params0{k,2});
                aux98=params0{k,2};
                if ischar(aux98);
                    aux99=aux98;
                elseif iscell(aux98);
                    aux99=aux98{1};
                elseif isnumeric(aux98)
                    aux99=num2str(aux98);
                end
                params{i,1}=[params0{k,1},' = ',aux99];
                if k == spaces(g+1)-1
                    i=i+2;
                else
                    i=i+1;
                end
            end
        end
    end
    
    % write params file
    fid=fopen(save_directory,'w');
    for g=1:size(params,1)
        fprintf(fid,'%s\n',params{g,1});
    end
    fclose(fid);
    fclose all;
    set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd)]);
% catch
%     alertFigure('Error saving params.txt file!');
% end

function [idx]=idx_finder(structF,carac,col)
aux=strfind(structF(:,col),carac); i=1;
for g=1:size(aux,1)
    if aux{g,1}==1
        idx(i)=g; i=i+1;
    end
end
if ~exist('idx','var')
    idx=[];
end

function saveasfile(varargin)
[fileSas,pathSas] = uiputfile('params.txt','Save file name');
if fileSas~=0
    save_directory=[pathSas,fileSas];
    savefile(save_directory);
end


% First check - Main Button's handles
% z=1;
% for g=1:size(handles,1)
%     aux=0;
%     for k=1:size(handles,2)
%         if isempty(handles{g,k});
%             aux=aux+1;
%         end
%     end
%     if aux==7
%         verify(z,1)=g; z=z+1;
%     end
% end
% if ~isempty(verify)
%     if size(verify,1)==1; pos=pos+[0 0 0 0];
%     elseif size(verify,1)==2; pos=pos+[0 0 0 un*1];
%     elseif size(verify,1)==3; pos=pos+[0 0 0 un*2];
%     elseif size(verify,1)==4; pos=pos+[0 0 0 un*3];
%     elseif size(verify,1)==5; pos=pos+[0 0 0 un*4];
%     elseif size(verify,1)==6; pos=pos+[0 0 0 un*5];
%     elseif size(verify,1)==7; pos=pos+[0 0 0 un*6];
%     elseif size(verify,1)==8; pos=pos+[0 0 0 un*7];
%     elseif size(verify,1)==9; pos=pos+[0 0 0 un*8];
%     end
%
%     figureSAVEfilesX = dialog('units','points','Name','XBeach GUI - Save "params.txt"','position',pos,...
%     'color',cor); modifyLogo(figureSAVEfilesX);
%     remember01=uicontrol('units','normalized','parent',figureSAVEfilesX,'style','text',...
%     'string','You need to set more Buttons ','fontsize',10,'fontw','bold',...
%     'position',[.1 .90 .8 .2],'backgroundcolor',cor);
%
% %     for g=1:size(verify,1)
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            File Menu - Open                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function openfile(varargin)
global handles kt figurehandleX  A...
    d3ddepPB_open d3ddepUn_edit d3ddepUn_edit1 u0 u1...
    d3dthetaMINT  d3dthetaMINT2 d3dthetaMAXT ...
    d3dthetaMAXT2 d3d_dthetaT  d3d_dthetaT2 d3d_theNautT1 d3dclock bathyclock...
    tide_handle tide_panelPB tide_panelPB1 tide_panel wfile_open handles_Glob handles_Tavg...
    output_Globpanel output_Tavgpanel handles_MB gridparclock gr_xbstylePB gr_d3dstylePB...
    tstop CFL...
    gridform xyfile depfile thetamin  thetamax dtheta  ...
    hmin eps umin hwci...
    gravity_value rho...
    cf C nuh nuhfac nuhv smag zs0file tideloc...
    wavint wci gamma gammax alpha n roller beta...
    rhoa Cd windv windth...
    z0 facsl BRfac rhos	por tsfac facua ne_layer D50 D90 struct...
    morfac morstart wetslp dryslp hswitch...
    bcfile...
    thetanaut...
    scheme break_value...
    waveform form thetanum smax...
    morfacopt sourcesink...
    fbound1_Pop fbound1_PopCon...
    fbound2_Pop fbound2_PopCon...
    instat...
    outputformat...
    swave lwave flow sedtrans morphology nonh gwflow q3d...
    lws sws...
    outGlob_CB outTimeAvg_CB outPoint_CB... %variables types
    outGlobAll_CB outGlobZb_CB outGlobZs_CB...
    outGlobH_CB outGlobEu_CB outGlobthMean_CB outGlobsedero_CB outGlobdzav_CB... global
    outGlobsusg_CB outGlobsvsg_CB outGlobsubg_CB outGlobsvbg_CB ...
    outTavgAll_CB outTavgbH_CB outTavgEu_CB... 
    outTavgsusg_CB outTavgsvsg_CB outTavgsubg_CB outTavgsvbg_CB...time-averaged
    outPointAll_CB outPointzs_CB outPointH_CB outPointEu_CB...
    tstart tintg tintm tintp...
    handles_G ...
    file path

try
    [file,path]=uigetfile({'*.txt','params (*.txt)'},'Open Params File');
    if file~=0
        fid=fopen([path,file],'r');
        reading=fread(fid,'*char'); 
        reading=strread(reading,'%s','whitespace','\b');
        aux_perc=strfind(reading(:,1),'%'); z=1; clear reading_org;
        idxEND=idx_finder(reading,'nglobalvar',1);
        if isempty(idxEND); idxEND = size(aux_perc,1); end
        % Read params file until declared output variables
        for g=1 : idxEND
            if isempty(aux_perc{g,1})
                clear aux01; aux01=strfind(reading{g,1},'=');
                if ~isempty(aux01)
                    reading_org{z,1}=reading{g,1}(1:aux01-1); reading_org{z,2}=reading{g,1}(aux01+1:end); z=z+1;
                else
                    alertFigure(sprintf(['Bad Params File!\nMissing ''='' signal in line ',num2str(g)]));
                    a=fclose(fid);
                    break
                end
            end
        end
        
        
        l01=idx_finder(reading_org,'gridform',1); l02=idx_finder(reading_org,'swave',1);
        l03=idx_finder(reading_org,'hmin',1); l04=idx_finder(reading_org,'g',1);
        l05=idx_finder(reading_org,'cf',1); l066=idx_finder(reading_org,'zs0file',1);
        l06=idx_finder(reading_org,'wavint',1); l07=idx_finder(reading_org,'rhoa',1);
        l08=idx_finder(reading_org,'z0',1); l09=idx_finder(reading_org,'morfac ',1);
        l10=idx_finder(reading_org,'bcfile',1); l11=idx_finder(reading_org,'front',1);
        l12=idx_finder(reading_org,'outputformat',1); l13=idx_finder(reading_org,'break',1);
        
        
        if isempty(l066)
            spaces=[1 l01 l01 l02 l03 22 l05 l06 l07 l08 l09 l10 l11 l12 81]; % modify this vector if add some
            functions_handles={'timeframe_button';'d3dstyle_grid';'bathymetry';...
                'processes_button';'limiters_button';'constantsTAB';'flowTAB';...
                'waveTAB';'windTAB';'sedtranspTAB';'morphoTAB';'wave_bound';...
                'flow_bound';'output_button'};
            stringB=[1 2 4:8 18:52 65 71:73];
            checkB=[10:17 63 64];
            popB=[9 55:62 66 68:70];
        else
            spaces=[1 l01 l01 l02 l03 22 l05 l066 l06 l07 l08 l09 l10 l11 l12 81];
            functions_handles={'timeframe_button';'d3dstyle_grid';'bathymetry';...
                'processes_button';'limiters_button';'constantsTAB';'flowTAB';'flowTAB';...
                'waveTAB';'windTAB';'sedtranspTAB';'morphoTAB';'wave_bound';...
                'flow_bound';'output_button'};
            stringB=[1 2 4:8 18:54 66:69 75:77];
            checkB=[10:17 63 64];
            popB=[9 55:62 65 70 72:74];
        end
        for j=1:size(spaces,2) - 1
            if j~=3
                if j~=2
                    lim1=spaces(j); lim2=spaces(j+1) - 1;
                else
                    lim1=spaces(j); lim2=spaces(j+2) - 1;
                end
                %         if j==
                eval(functions_handles{j,1});
                for h= lim1 : lim2
                    if any((stringB-h)==0)
                        if h==22
                            set(gravity_value,'string',reading_org{h,2});
                        else
                            set(eval(reading_org{h,1}),'string',reading_org{h,2}(2:end));
                        end
                    elseif any((checkB-h)==0)
                        set(eval(reading_org{h,1}),'value',str2double(reading_org{h,2}));
                    elseif any((popB-h)==0)
                        if strcmp(reading_org{h,1}(1:end-1),'thetanaut') | strcmp(reading_org{h,1}(1:end-1),'morfacopt') | ...
                                strcmp(reading_org{h,1}(1:end-1),'sourcesink')
                            set(eval(reading_org{h,1}),'value',str2double(reading_org{h,2}) + 1);
                        elseif strcmp(reading_org{h,1}(1:end-1),'waveform') %5%3
                            if strcmp(reading_org{h,2}(2:end),'ruessink')
                                set(eval(reading_org{h,1}),'value',1);
                            elseif strcmp(reading_org{h,2}(2:end),'vanthiel')
                                set(eval(reading_org{h,1}),'value',2);
                            end
                        elseif strcmp(reading_org{h,1}(1:end-1),'form')
                            set(eval(reading_org{h,1}),'value',str2double(reading_org{h,2}));
                        elseif strcmp(reading_org{h,1}(1:end-1),'thetanum')
                            if str2double(reading_org{h,2}) == 0.5
                                set(eval(reading_org{h,1}),'value',str2double(reading_org{h,2}) + 1.5);
                            else
                                set(eval(reading_org{h,1}),'value',str2double(reading_org{h,2}));
                            end
                        elseif strcmp(reading_org{h,1}(1:end-1),'smax') %5%6
                            set(eval(reading_org{h,1}),'value',str2double(reading_org{h,2}) + 2);
                        elseif strcmp(reading_org{h,1}(1:end-1),'instat') %6%1 %wave boundaries
                            if strcmp(reading_org{h,2}(2:end),'jons') | str2double(reading_org{h,2})==4
                                set(eval(reading_org{h,1}),'value',6);
                            elseif reading_org{h,2}==41
                                set(eval(reading_org{h,1}),'value',13);
                            end
                            % lines unit elseif 'back' you can simplify easily and
                            % insert missing wave bounds
                        elseif strcmp(reading_org{h,1}(1:end-1),'front')
                            if h==68; hand=fbound1_PopCon; elseif h==69; hand=fbound2_PopCon; end;
                            clear bounds aux01; bounds={'none','abs_1d','abs_2d','wall','wlevel','nonh_1d'};
                            aux01=strcmp(bounds,reading_org{h,2}(2:end));
                            set(hand,'value',find(aux01==1));
                        elseif strcmp(reading_org{h,1}(1:end-1),'back')
                            if h==68; hand=fbound1_PopCon; elseif h==69; hand=fbound2_PopCon; end;
                            clear bounds aux01; bounds={'none','wall','abs_1d','abs_2d','wlevel'};
                            aux01=strcmp(bounds,reading_org{h,2}(2:end));
                            set(hand,'value',find(aux01==1));
                        elseif strcmp(reading_org{h,1}(1:end-1),'outputformat')
                            if strcmp(reading_org{h,2}(2:end),'netcdf')
                                set(eval(reading_org{h,1}),'value',2);
                            else
                                set(eval(reading_org{h,1}),'value',1);
                            end
                        elseif strcmp(reading_org{h,1}(1:end-1),'struct')
                            set(eval(reading_org{h,1}),'value',str2double(reading_org{h,2})+1);
                        elseif h==l13
                            set(break_value,'value',str2double(reading_org{h,2}));
                        end
                    end
                end
            else
                idx000=idx_finder(reading_org,'depfile',1);
                A=1;
                domain_button
                eval(functions_handles{j,1});
                set(d3ddepPB_open,'enable','on')
                set(d3ddepUn_edit,'enable','off');
                set(d3ddepUn_edit1,'enable','off');
                set(depfile,'enable','on');
                set(u0,'value',1); set(u1,'value',0);
                if ~isempty(reading_org{idx000,2})
                    set(eval(reading_org{idx000,1}),'string',reading_org{idx000,2}(2:end));
                else
                    set(eval(reading_org{idx000,1}),'string','Filename Unknown');
                end
            end
            
            % active organizing
            if strcmp(functions_handles{j,1},'d3dstyle_grid')
                handles_grid=[d3dthetaMINT thetamin d3dthetaMINT2 d3dthetaMAXT thetamax...
                    d3dthetaMAXT2 d3d_dthetaT dtheta d3d_dthetaT2 d3d_theNautT1 thetanaut];
                set(handles_grid,'enable','on');
            elseif j==8 & strcmp(functions_handles{j,1},'flowTAB')
                set(tide_handle,'enable','on');
                set(tide_panelPB1,'visible','on','value',0);
                set(tide_panel,'foregroundcolor','k');
                set(tide_panelPB,'visible','off','value',0);
            elseif strcmp(functions_handles{j,1},'sedtranspTAB')
                auxNE=idx_finder(reading_org,'ne_layer',1);
                if strcmp(reading_org{auxNE,2},'Filename Unknown')==0
                    set(ne_layer,'enable','on');
                end
            elseif strcmp(functions_handles{j,1},'wave_bound')
                set([wfile_open bcfile],'enable','on');
            end
        end
        
        % Read params file of declared output variables
        ls00=idx_finder(reading_org,'tstart',1); ls01=idx_finder(reading_org,'tintg',1);
        ls02=idx_finder(reading_org,'tintm',1); ls03=idx_finder(reading_org,'tintp',1);
        ls04=idx_finder(reading,'nglobalvar',1);
        ls05=idx_finder(reading,'zb',1); ls06=idx_finder(reading,'zs',1);
        ls07=idx_finder(reading,'H',1); ls08=idx_finder(reading,'ue',1);
        ls09=idx_finder(reading,'ve',1); ls10=idx_finder(reading,'thetamean',1);
        ls11=idx_finder(reading,'sedero',1); ls12=idx_finder(reading,'dzav',1);
        ls13=idx_finder(reading,'nmeanvar',1); ls14=idx_finder(reading,'Susg',1);
        ls15=idx_finder(reading,'Svsg',1); ls16=idx_finder(reading,'Subg',1);
        ls17=idx_finder(reading,'Svbg',1);
        if numel(ls06)~=2 & ls06<85
            ls06(2)=ls06;
        end
        vectorS=[ls00 ls01 ls02 ls03 ls04 ls05 ls06(2) ls07 ls08 ls09 ls10 ls11 ls12 ls13...
            ls14 ls15 ls16 ls17];
        set([handles_Glob handles_Tavg],'value',0);
        for b=1:size(vectorS,2)
            if ~isempty(ls00) & vectorS(b)==ls00
                set(tstart,'string',reading_org{ls00,2});
            elseif ~isempty(ls01) & vectorS(b)==ls01
                set(tintg,'string',reading_org{ls01,2});
            elseif ~isempty(ls02) & vectorS(b)==ls02
                set(tintm,'string',reading_org{ls02,2});
            elseif ~isempty(ls03) & vectorS(b)==ls03
                set(tintp,'string',reading_org{ls03,2});
            elseif ~isempty(ls04) & vectorS(b)==ls04
                set(outGlob_CB,'value',1);
                set(handles_Glob,'enable','on');
                set(output_Globpanel,'foregroundcolor','k');
            elseif ~isempty(ls05) & vectorS(b)==ls05
                set(outGlobZb_CB,'value',1);
            elseif ~isempty(ls06) & b == find(vectorS==ls06(2))
                if size(ls06,2)==1 & ls06>85
                    set(outGlobZs_CB,'value',1);
                elseif size(ls06,2) > 1 & ls06(2) > 85
                    set(outGlobZs_CB,'value',1);
                end
            elseif ~isempty(ls07) & b == find(vectorS==ls07(1))
                if size(ls07,2)>1 & ~isempty(ls04) & ~isempty(ls13)
                    if ls07(1) > ls04 & ls07(1) < ls13
                        set(outGlobH_CB,'value',1);
                    end
                    if ls07(2) > ls13
                        set(outTavgbH_CB,'value',1);
                    end
                elseif size(ls07,2)==1 & ~isempty(ls04) & ~isempty(ls13)
                    if ls07 > ls04 & ls07 < ls13
                        set(outGlobH_CB,'value',1);
                    elseif ls07 > ls13
                        set(outTavgbH_CB,'value',1);
                    end
                end
            elseif ~isempty(ls08) & ~isempty(ls09) & b == find(vectorS==ls08(1))
                if size(ls08,2) > 1 & size(ls09,2) > 1 & ~isempty(ls04) & ~isempty(ls13)
                    if ls08(1) > ls04 & ls08(1) < ls13
                        set(outGlobEu_CB,'value',1);
                    end
                    if ls08(2) > ls13
                        set(outTavgEu_CB,'value',1);
                    end
                elseif size(ls08,2)==1 & size(ls09,2)==1 & ~isempty(ls04) & ~isempty(ls13)
                    if ls08 > ls04 & ls08 < ls13
                        set(outGlobEu_CB,'value',1);
                    elseif ls08 > ls13
                        set(outTavgEu_CB,'value',1);
                    end
                end
            elseif ~isempty(ls10) & vectorS(b)==ls10
                set(outGlobthMean_CB,'value',1);
            elseif ~isempty(ls11) & vectorS(b)==ls11
                set(outGlobsedero_CB,'value',1);
            elseif ~isempty(ls12) & vectorS(b)==ls12
                set(outGlobdzav_CB,'value',1);
            elseif ~isempty(ls14) & vectorS(b)==ls14 %susg
                if size(ls14,2) == 2
                    set([outGlobsusg_CB,outTavgsusg_CB],'value',1);
                elseif size(ls14,2)==1 & ls14 > ls13
                    set(outTavgsusg_CB,'value',1);
                else
                    set(outGlobsusg_CB,'value',1);
                end
            elseif ~isempty(ls15) & vectorS(b)==ls15 %svsg
                if size(ls15,2) == 2
                    set([outGlobsvsg_CB,outTavgsvsg_CB],'value',1);
                elseif size(ls15,2)==1 & ls15 > ls13
                    set(outTavgsvsg_CB,'value',1);
                else
                    set(outGlobsvsg_CB,'value',1);
                end
            elseif ~isempty(ls16) & vectorS(b)==ls16 %subg
                if size(ls16,2) == 2
                    set([outGlobsubg_CB,outTavgsubg_CB],'value',1);
                elseif size(ls16,2)==1 & ls16 > ls13
                    set(outTavgsubg_CB,'value',1);
                else
                    set(outGlobsubg_CB,'value',1);
                end
            elseif ~isempty(ls17) & vectorS(b)==ls17 %svbg
                if size(ls17,2) == 2
                    set([outGlobsvbg_CB,outTavgsvbg_CB],'value',1);
                elseif size(ls17,2)==1 & ls17 > ls13
                    set(outTavgsvbg_CB,'value',1);
                else
                    set(outGlobsvbg_CB,'value',1);
                end
            elseif ~isempty(ls13) & vectorS(b)==ls13
                set(outTimeAvg_CB,'value',1);
                set(handles_Tavg,'enable','on');
                set(output_Tavgpanel,'foregroundcolor','k');
            elseif isempty([ls05 ls06 ls07 ls08 ls09 ls10 ls11 ls12])
                set([outGlobAll_CB outGlobZb_CB outGlobZs_CB outGlobH_CB outGlobEu_CB ...
                    outGlobthMean_CB  outGlobsedero_CB  outGlobdzav_CB],'value',0);
                set(outGlobAll_CB,'value',1);
                set([outTavgAll_CB outTavgbH_CB outTavgEu_CB],'value',0);
                set(outTavgAll_CB,'value',1);
            end
            
        end
        
        % set all main button to "black series"
        set(handles_MB,'foregroundcolor','k');
        
        % close params file
        fclose(fid);
        fclose all;
        
        % d3dclock
        d3dclock=datenum(clock); gridparclock=datenum(clock);
        gridsParameters;
        set(handles_G,'foregroundcolor','k'); set(handles_G(1),'foregroundcolor','b');
        set(gr_xbstylePB,'foregroundcolor','k'); set(gr_d3dstylePB,'foregroundcolor','b');
        
        for k=1:kt
            for g=1:length(handles(:,1))
                if ~isempty('handles'); aux=handles{g,k}; set(aux,'visible','off'); end
            end
        end
        
    end
catch
    alertFigure(['Error opening params.txt file in keyword ',num2str(h),'!']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             File Menu - New                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newFile00(varargin)
global handles saveFYes saveFNo saveF
for i=1:size(handles,1)
    for j=1:size(handles,2)
        if ~isempty(handles{i,j})
            notisempty=1;
        end
    end
end
if exist('notisempty','var')
        width=250; height=100; set(0, 'Units', 'points'); screenSize=get(0,'screensize');
    pos1 = [screenSize(3)/2-width/2 screenSize(4)/2-height/2 width height];
    saveF=figure('unit','points','BusyAction','queue','WindowStyle','modal', ...
        'Position',pos1,'Resize','off','CreateFcn','','NumberTitle','off', ...
        'IntegerHandle','off','MenuBar','none','Tag','XbeachGUI','Interruptible','off', ...
        'DockControls','off','Visible','on','Interruptible','off','color',[1 1 1],'name','Xbeach GUI');
    saveFIcon=imread('../assets/images/Alert.png','backgroundcolor',[1 1 1]);
    saveFIconF=uicontrol('unit','normalized','cdata',saveFIcon,...
        'position',[0.07 0.25 0.2 0.52]);
    saveFTXT=uicontrol('unit','normalized','style','text',...
        'string',sprintf('Params file have been changed!\nSave params file?'),'position',[0.32 0.5 0.63 0.3],...
        'fontsize',10,'fontw','bold','backgroundcolor',[1 1 1],'horizontalalignment','center');
    saveFYes=uicontrol('unit','normalized','style','pushbutton',...
        'string','Yes','position',[0.435 0.15 0.2 0.2],...
        'fontsize',10,'fontw','bold','callback',@newFile);
    saveFNo=uicontrol('unit','normalized','style','pushbutton',...
        'string','No','position',[0.665 0.15 0.2 0.2],...
        'fontsize',10,'fontw','bold','callback',@newFile);
    modifyLogo(saveF)
end
% uiresume(saveF);

function newFile(hObj,varargin)
global handles handles_MB xbclock d3dclock bathyclock gridparclock ...
constantsclock flowclock waveclock windclock...
    sedtranspclock morphoclock flow_bound_clock wave_bound_clock...
    saveFYes saveFNo kt saveF A
if hObj == saveFYes
    savefile;
end
set(handles_MB,'foregroundcolor','k');
for k=1:kt
    for g=1:length(handles(:,1))
        if ~isempty('handles'); aux=handles{g,k}; set(aux,'visible','off'); end
    end
end
% clear([xbclock d3dclock bathyclock gridparclock ...
% constantsclock flowclock waveclock windclock...
%     sedtranspclock morphoclock flow_bound_clock wave_bound_clock]);
clear -global -regexp \w*clock\w*

clearvars -global A
for k=1:kt
    for g=1:9
        handles{g,k}=[];
    end
end
clear functions
set([handles_MB(5) handles_MB(7) handles_MB(8) handles_MB(9)],'enable','off');
close(saveF);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          Main Button Time Frame                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function timeframe_button(varargin)
global handles figurehandleX cor kt handles_MB MB_out tstop CFL globalhand; %if ~isempty('vars1'); delete(vars1); end
globalhand{1,1}={tstop;CFL};
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
set(handles_MB,'foregroundcolor','k'); set(handles_MB(1),'foregroundcolor','b');
set(MB_out,'enable','on');
for k=1:kt
    for g=1:length(handles(:,1))
        if ~isempty('handles'); aux=handles{g,k}; set(aux,'visible','off'); end
    end
end
set(handles{1,1},'visible','on');
if isempty(handles{1,1})
    fig=getappdata(figurehandleX,'figurehandle');
    tfpanel=uipanel('unit','normalized','parent',fig,'Title','Time Frame','fontsize',8,...
        'position',[0.24 0.78  0.7 0.2],'backgroundcolor',cor);
    tfT_tstop=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.88 0.2222 0.0444],'string','Time Stop','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring','key: tstop');
    tstop=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.50 0.89 0.2222 0.0444],'string','1000','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    tfU_tstop=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.74 0.88 0.18 0.0444],'string','[Seconds]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
    tfT_CFL=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.79 0.2222 0.0444],'string','Courant Number','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Min: 0.1\nMax: 0.9\nkey: CFL'));
    CFL=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.5 0.8 0.2222 0.0444],'string','0.7','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    tfU_CFL=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.74 0.79 0.15 0.0444],'string','[-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
    handles{1,1}=[tfT_tstop tstop tfU_tstop tfT_CFL CFL tfU_CFL tfpanel];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          Main Button Domain                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function domain_button(varargin)
global handles figurehandleX cor xbclock d3dclock bathyclock gridparclock kt handles_MB...
    handles_G
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
set(handles_MB,'foregroundcolor','k'); set(handles_MB(2),'foregroundcolor','b');
for k=1:kt
    for g=1:length(handles(:,1))
        if ~isempty('handles'); aux=handles{g,k}; set(aux,'visible','off'); end
    end
end
set(handles{2,1},'visible','on');
aux=max([bathyclock gridparclock]); aux2=max([d3dclock xbclock]);
if aux==gridparclock & aux2==d3dclock
    set(handles{2,2},'visible','on'); set(handles{2,3},'visible','on');
elseif aux==gridparclock & aux2==xbclock
    set(handles{2,2},'visible','on'); set(handles{2,4},'visible','on');
elseif aux==gridparclock & isempty(aux2);
    set(handles{2,2},'visible','on');
elseif aux==bathyclock
    set(handles{2,5},'visible','on');
end

if isempty(handles{2,1})
    fig=getappdata(figurehandleX,'figurehandle');
    dmpanel1=uipanel('unit','normalized','parent',fig,'Title','Domain','fontsize',8,...
        'position',[0.24 0.88  0.7 0.1],'backgroundcolor',cor);
    dm_gridsPB=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',[0.30 0.9 0.15 0.0444],'string','Grid Parameters','fontsize',10,...
        'fontw','bold','callback',@gridsParameters);
    dm_bathyPB=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',[0.515 0.9 0.15 0.0444],'string','Bathymetry','fontsize',10,...
        'fontw','bold','callback',@bathymetry);
    dm_obstaclesPB=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',[0.73 0.9 0.15 0.0444],'string','Obstacles','fontsize',10,...
        'fontw','bold','enable','off');    
    handles_G=[dm_gridsPB dm_bathyPB dm_obstaclesPB];
    handles{2,1}=[dm_gridsPB dm_bathyPB dm_obstaclesPB dmpanel1];
end

function gridsParameters(varargin)
global handles figurehandleX cor d3dclock xbclock kt gridparclock handles_G...
    gr_xbstylePB gr_d3dstylePB
gridparclock=datenum(clock);
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
set(handles_G,'foregroundcolor','k'); set(handles_G(1),'foregroundcolor','b');
for k=1:kt
    for g=1:length(handles(:,1))
        if ~isempty('handles'); aux=handles{g,k}; set(aux,'visible','off'); end
    end
end
set(handles{2,1},'visible','on');
aux=max([d3dclock xbclock]);
if aux==d3dclock;
    set(handles{2,2},'visible','on'); set(handles{2,3},'visible','on');
elseif aux==xbclock;
    set(handles{2,2},'visible','on'); set(handles{2,4},'visible','on');
end
if isempty(handles{2,2})
    fig=getappdata(figurehandleX,'figurehandle');
    grstyle=uipanel('unit','normalized','parent',fig,'Title','Domain Style','fontsize',8,...
        'position',[0.24 0.72  0.7 0.1],'backgroundcolor',cor);
    gr_d3dstylePB=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',[0.30 0.745  0.25 0.0355],'string','Delft3D Form','fontsize',10,...
        'fontw','bold','callback',@d3dstyle_grid);
    gr_xbstylePB=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',[0.63 0.745  0.25 0.0355],'string','Xbeach Form','fontsize',10,...
        'fontw','bold','callback',@xbstyle_grid,'enable','off');
    handles{2,2}=[handles{2,2} gr_xbstylePB gr_d3dstylePB grstyle];
end

function d3dstyle_grid(varargin)
global handles figurehandleX xyfile d3dValue_coor d3dMsize_Value d3dNsize_Value cor ...
    d3dtxt_coor d3dMsize_txt d3dNsize_txt d3dthetaMINT thetamin d3dthetaMINT2...
    d3dthetaMAXT thetamax d3dthetaMAXT2 d3d_dthetaT dtheta d3d_dthetaT2 ...
    d3d_theNautT1 thetanaut d3dclock d3dcstlineT d3dcstlinePOP...
    d3dcstlinefixPB d3d_analysepanel d3d_grcaracpanel D1 gr_xbstylePB gr_d3dstylePB...
    d3dgrPB_open gridform globalhand d3d_grpanel
set(gr_xbstylePB,'foregroundcolor','k'); set(gr_d3dstylePB,'foregroundcolor','b');
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
set(handles{2,4},'visible','off');
set(handles{2,1},'visible','on'); set(handles{2,2},'visible','on'); set(handles{2,3},'visible','on');
d3dclock=datenum(clock);
gridform='delft3d';
if isempty(handles{2,3})
    fig=getappdata(figurehandleX,'figurehandle');
    d3d_grpanel=uipanel('unit','normalized','parent',fig,'Title','Grid - Delft3D Form','fontsize',8,...
        'position',[0.24 0.05  0.7 0.61],'backgroundcolor',cor);
    d3d_analysepanel=uipanel('unit','normalized','parent',fig,'Title','Analyse XY origin','fontsize',8,...
        'position',[0.62 0.08 0.29 0.245],'backgroundcolor',cor,'foregroundcolor',[.6 .6 .6]);
    d3d_grcaracpanel=uipanel('unit','normalized','parent',fig,'Title','Grid Characteristics','fontsize',8,...
        'position',[0.27 0.08  0.32 0.215],'backgroundcolor',cor,'foregroundcolor',[.6 .6 .6]);
    xyfile=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.57 0.575  0.35 0.0355],'string','Filename Unknown','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
    % d3denT_open=uicontrol('unit','points','parent',fig,'style','text',...
    %     'position',[360 height*1.4-29 100 17],'string','Filename Unknown','fontsize',10,...
    %     'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
    d3dgrPB_open=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',[0.3 0.58  0.25 0.0355],'string','Open Grid','fontsize',10,...
        'fontw','bold','callback',@openGRID,'max',1);
    % d3dencPB_open=uicontrol('unit','points','parent',fig,'style','pushbutton',...
    %     'position',[200 height*1.4-25 150 17],'string','Open Grid Enclosure','fontsize',10,...
    %     'fontw','bold','callback',@openENC);
    d3dthetaMINT=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.335 0.49  0.1 0.0355],'string','Theta Min:','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltip',sprintf('Lower Directional\nLimit\nkey: thetamin'),'enable','off');
    thetamin=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.45 0.495  0.085 0.0355],'string','0','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'horizontalalignment','right','enable','off');
    d3dthetaMINT2=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.55 0.49  0.3 0.0355],'string','Angle w.r.t. computational x-axis','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left','enable','off');
    d3dthetaMAXT=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.335 0.435  0.1 0.0355],'string','Theta Max:','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltip',sprintf('Upper Directional\nLimit\nkey: thetamax'),'enable','off');
    thetamax=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.45 0.44  0.085 0.0355],'string','270','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'horizontalalignment','right','enable','off');
    d3dthetaMAXT2=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.55 0.435  0.3 0.0355],'string','Angle w.r.t. computational x-axis','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left','enable','off');
    d3d_dthetaT=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.335 0.38  0.15 0.0355],'string','Directional Theta:','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltip',sprintf('Directional\nResolution'),'enable','off');
    dtheta=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.495 0.38  0.04 0.0355],'string','20','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'horizontalalignment','right','enable','off');
    d3d_dthetaT2=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.55 0.38  0.08 0.0355],'string','[Deg]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left','enable','off');
    d3d_theNautT1=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.335 0.325  0.20 0.0355],'string','Angle Convention:','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left','enable','off');
    %     d3d_theNautT2=uicontrol('unit','normalized','parent',fig,'style','text',...
    %         'position',[0.55 0.325 0.3 0.0355],'string','[0 - Cartesian / 1 - Nautical]','fontsize',10,...
    %         'fontw','bold','backgroundcolor',cor,'horizontalalignment','left','enable','off');
    thetanaut=uicontrol('unit','normalized','parent',fig,'style','popup',...
        'position',[0.505 0.329 0.1 0.0355],'string','Cartesian|Nautical','fontsize',10,...% string 1
        'fontw','bold','backgroundcolor',[1 1 1],'horizontalalignment','right','value',2,'enable','off');
    
    d3dtxt_coor=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.29 0.22  0.20 0.0355],'string','Coordinate System:','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left','enable','off');
    d3dValue_coor=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.48 0.22  0.08 0.0355],'string','','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
    d3dMsize_txt=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.29 0.16  0.23 0.0355],'string','Grid Points in M direction:','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left','enable','off');
    d3dMsize_Value=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.51 0.16  0.06 0.0355],'string','','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
    d3dNsize_txt=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.29 0.10  0.23 0.0355],'string','Grid Points in N direction:','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left','enable','off');
    d3dNsize_Value=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.51 0.10 0.06 0.0355],'string','','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
    d3dcstlineT=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.64 0.26  0.18 0.0355],'string','Coastline Position:','fontsize',8,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left','enable','off');
    d3dcstlinePOP=uicontrol('unit','normalized','parent',fig,'style','popup',...
        'position',[0.78 0.273  0.11 0.028],'string',...
        'None|NorthWest|West|South|East|North','fontsize',8,...
        'fontw','bold','backgroundcolor',[1 1 1],'horizontalalignment','left','enable','off',...
        'callback',@analyse_xyorgin); D1=1;
    d3dcstlinefixPB=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',[0.792 0.11  0.08 0.0355],'string',...
        'Fix','fontsize',10,'fontw','bold','backgroundcolor',cor,...
        'horizontalalignment','left','enable','off','visible','off');
        
    handles{2,3}=[handles{2,3} xyfile d3dgrPB_open d3dtxt_coor ...
        d3dMsize_txt d3dNsize_txt d3dValue_coor d3dMsize_Value d3dNsize_Value ...
        d3dthetaMINT thetamin d3dthetaMINT2 d3dthetaMAXT thetamax ...
        d3dthetaMAXT2 d3d_dthetaT dtheta d3d_dthetaT2 d3d_theNautT1...
        thetanaut d3dcstlineT d3dcstlinePOP  d3dcstlinefixPB d3d_grpanel d3d_analysepanel...
        d3d_grcaracpanel];
    
    globalhand{1,2}={gridform; xyfile; thetamin; thetamax; dtheta; thetanaut};
end

function bathymetry(height,varargin)
global handles figurehandleX cor d3ddepPB_open d3ddepUn_edit d3ddepUn_edit1 depfile A ...
    d3ddepTMax_open d3ddepValueMax_open d3ddepValueMin_open kt bathyclock...
    handles_G globalhand u0 u1
 
if isempty(A)
    alertFigure('Load Grid Before!');
    %     questGRID=questdlg('You need to open a grid!', ...
    %         'Xbeach GUI','Yes','No','xalala');
    %     switch questGRID
    %         case 'Yes'
    %             gridsParameters(height,varargin)
    %             return
    %         case 'No'
    %             return
    %     end
else
    set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
    set(handles_G,'foregroundcolor','k'); set(handles_G(2),'foregroundcolor','b');
    bathyclock=datenum(clock);
    for k=1:kt
        for g=1:length(handles(:,1))
            if ~isempty('handles'); aux=handles{g,k}; set(aux,'visible','off'); end
        end
    end
    set(handles{2,1},'visible','on'); set(handles{2,5},'visible','on');
    if isempty(handles{2,5})
        fig=getappdata(figurehandleX,'figurehandle');
        d3dbathy_panel=uipanel('unit','normalized','parent',fig,'Title','Bathymetry','fontsize',8,...
            'position',[0.24 0.54  0.7 0.28],'backgroundcolor',cor);
        % Create the button group.
        h = uibuttongroup('unit','normalized','parent',fig,'visible','off',...
            'Position',[0.30 0.55  0.6 0.23],'backgroundcolor',cor,'bordertype','none');
        u0 = uicontrol('unit','normalized','Style','Radio','String','File',...
            'pos',[0 0.6  0.2 0.2],'parent',h,'HandleVisibility','off',...
            'backgroundcolor',cor,'fontsize',10,'fontw','bold');
        u1 = uicontrol('unit','normalized','Style','Radio','String','Uniform',...
            'pos',[0 0.2  0.2 0.2],'parent',h,'HandleVisibility','off',...
            'backgroundcolor',cor,'fontsize',10,'fontw','bold');
        set(h,'SelectionChangeFcn',@seldepFILE); set(h,'SelectedObject',u1); set(h,'Visible','on');
        
        d3ddepPB_open=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
            'position',[0.40 0.695  0.25 0.0355],'string','Open Bathymetry','fontsize',10,...
            'fontw','bold','callback',@openDEPTH,'enable','off');
        depfile=uicontrol('unit','normalized','parent',fig,'style','text',...
            'position',[0.67 0.692  0.21 0.0355],'string','Filename Unknown','fontsize',10,...
            'fontw','bold','backgroundcolor',cor,'horizontalalignment','left','enable','off');
        d3ddepTMax_open=uicontrol('unit','normalized','parent',fig,'style','text',...
            'position',[0.67 0.662  0.21 0.0355],'string','Min:               |   Max:','fontsize',10,...
            'fontw','bold','backgroundcolor',cor,'horizontalalignment','left','enable','off');
        d3ddepValueMax_open=uicontrol('unit','normalized','parent',fig,'style','text',...
            'position',[0.711 0.6635  0.06 0.0355],'string','','fontsize',10,...
            'fontw','bold','backgroundcolor',cor,'horizontalalignment','right','enable','off');
        d3ddepValueMin_open=uicontrol('unit','normalized','parent',fig,'style','text',...
            'position',[0.845 0.6635  0.05 0.0355],'string','','fontsize',10,...
            'fontw','bold','backgroundcolor',cor,'horizontalalignment','right','enable','off');
        
        d3ddepUn_edit=uicontrol('unit','normalized','parent',fig,'style','edit',...
            'position',[0.4 0.60  0.10 0.0355],'string','10','fontsize',10,...
            'fontw','bold','backgroundcolor',[1 1 1],'horizontalalignment','right');
        d3ddepUn_edit1=uicontrol('unit','normalized','parent',fig,'style','text',...
            'position',[0.52 0.602  0.30 0.0355],'string','[m] below reference level','fontsize',10,...
            'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
        handles{2,5}=[handles{2,5} h u0 u1 d3ddepPB_open depfile...
            d3ddepUn_edit d3ddepUn_edit1 d3dbathy_panel d3ddepTMax_open ...
            d3ddepValueMax_open d3ddepValueMin_open];
        
        globalhand{1,3}=depfile;
    end
end

function xbstyle_grid(varargin)
global handles figurehandleX cor xbclock xbtxt_coor xbValue_coor xbMsize_txt ...
    xbMsize_Value xbNsize_txt xbNsize_Value xbgrTY_open xbgrTX_open kt...
    gr_xbstylePB gr_d3dstylePB
xbclock=datenum(clock);
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
set(gr_d3dstylePB,'foregroundcolor','k'); set(gr_xbstylePB,'foregroundcolor','b');
for k=1:kt
    for g=1:length(handles(:,1))
        if ~isempty('handles'); aux=handles{g,k}; set(aux,'visible','off'); end
    end
end
set(handles{2,1},'visible','on'); set(handles{2,2},'visible','on'); set(handles{2,4},'visible','on');
if isempty(handles{2,4})
    fig=getappdata(figurehandleX,'figurehandle');
    dXb_grpanel=uipanel('unit','normalized','parent',fig,'Title','Grid - Xbeach Form','fontsize',8,...
        'position',[0.24 0.1  0.7 0.56],'backgroundcolor',cor);
    xbgrTX_open=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.57 0.575  0.35 0.0355],'string','Filename Unknown','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
    xbgrXPB_open=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',[0.3 0.58  0.25 0.0355],'string','Open X Grid','fontsize',10,...
        'fontw','bold','callback',@openGRID,'max',2);
    xbgrTY_open=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.57 0.535  0.35 0.0355],'string','Filename Unknown','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
    xbgrYPB_open=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',[0.3 0.54  0.25 0.0355],'string','Open Y Grid','fontsize',10,...
        'fontw','bold','callback',@openGRID,'max',3);
    
    xbtxt_coor=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.335 0.24  0.20 0.0355],'string','Coordinate System:','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left','enable','off');
    xbValue_coor=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.555 0.24  0.20 0.0355],'string','','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
    xbMsize_txt=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.335 0.185  0.23 0.0355],'string','Grid Points in M direction:','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left','enable','off');
    xbMsize_Value=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.585 0.185  0.23 0.0355],'string','','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
    xbNsize_txt=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.335 0.13  0.23 0.0355],'string','Grid Points in N direction:','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left','enable','off');
    xbNsize_Value=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.585 0.13 0.23 0.0355],'string','','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');    
    handles{2,4}=[handles{2,4} dXb_grpanel xbtxt_coor xbValue_coor xbMsize_txt ...
        xbMsize_Value xbNsize_txt xbNsize_Value xbgrTX_open xbgrXPB_open xbgrTY_open ...
        xbgrYPB_open];
end

function seldepFILE(source,eventdata)
global d3ddepPB_open d3ddepUn_edit d3ddepUn_edit1 depfile figurehandleX
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
aux=source;
if strcmp(get(eventdata.OldValue,'String'),'Uniform')%file
    set(d3ddepPB_open,'enable','on')
    set(d3ddepUn_edit,'enable','off');
    set(d3ddepUn_edit1,'enable','off');
    set(depfile,'enable','on');    
else%uniform
    set(d3ddepPB_open,'enable','off');
    set(d3ddepUn_edit,'enable','on');
    set(d3ddepUn_edit1,'enable','on');
    set(depfile,'enable','off');
end

function openGRID(hobj,varargin)
global xyfile gridD3D d3dValue_coor d3dMsize_Value d3dNsize_Value A xgrid ygrid ...
    d3dtxt_coor d3dMsize_txt d3dNsize_txt d3dthetaMINT thetamin d3dthetaMINT2...
    d3dthetaMAXT thetamax d3dthetaMAXT2 d3d_dthetaT dtheta d3d_dthetaT2 ...
    d3d_theNautT1 d3d_theNautT2 thetanaut d3dcstlinefixPB...
    d3dcstlineT d3dcstlinePOP d3d_grcaracpanel  d3d_analysepanel cpanel h...
    d3dgrPB_open D1 d3dcstlinefixT figxyO figurehandleX pathG direc_place
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
D1=1;
set(d3dgrPB_open,'foregroundcolor','b');
value=get(hobj,'max');
if value==1 % d3dgrid
    [file,pathG]=uigetfile({'*.grd','Grid (*.grd)'},'Pick a File');
    if file==0
        set(xyfile,'String','Filename Unknown');
    else
        clear gridD3D
        gridD3D=wlgrid_Xbeach('read',[pathG,file]);
        [m,n]=size(gridD3D.X);
        set(xyfile,'String',file);
        set(d3dValue_coor,'string',gridD3D.CoordinateSystem);
        set(d3dMsize_Value,'string',num2str(m));
        set(d3dNsize_Value,'string',num2str(n));
        set(d3dtxt_coor,'enable','on');
        set(d3dMsize_txt,'enable','on');
        set(d3dNsize_txt,'enable','on');%
        set(d3dthetaMINT,'enable','on'); set(thetamin,'enable','on');
        set(d3dthetaMINT2,'enable','on'); set(d3dthetaMAXT,'enable','on');
        set(thetamax,'enable','on'); set(d3dthetaMAXT2,'enable','on');
        set(d3d_dthetaT,'enable','on'); set(dtheta,'enable','on');
        set(d3d_dthetaT2,'enable','on'); set(d3d_theNautT1,'enable','on');
        set(d3d_theNautT2,'enable','on'); set(thetanaut,'enable','on');
        set(d3dcstlineT,'enable','on'); set(d3dcstlinePOP,'enable','on');
        set(d3d_grcaracpanel,'foregroundcolor',[0 0 0]);
        set(d3d_analysepanel,'foregroundcolor',[0 0 0]);
        set(d3dcstlinefixPB,'visible','on');
        set(d3dcstlinePOP,'value',1);
        delete([d3dcstlinefixT figxyO]);
        xgrid=gridD3D.X; ygrid=gridD3D.Y;
        A=1;
        % call attention for xy grid origin
        h=1;
        cpanel= timer('TimerFcn',@colorpanel,'StartDelay',0, ...
            'Period',0.5,'Name','aa','ExecutionMode','fixedrate',...
            'taskstoexecute',5); start(cpanel);
        set(direc_place,'string',pathG);
        set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pathG),'*']);
        %cd(pathG)
    end
    
elseif value==2
    [file,path]=uigetfile({'*.grd','X Grid - XbForm (*.grd)'},'Pick a File');
elseif value==3
    [file,path]=uigetfile({'*.grd','Y Grid - XbForm (*.grd)'},'Pick a File');
end

function colorpanel(varargin)
global d3d_analysepanel cpanel h
colors=[1,0,0 ; 0,0,0 ; 1,0,0 ; 0,0,0 ; 1,0,0];
set(d3d_analysepanel,'foregroundcolor',[colors(h,1) colors(h,2) colors(h,3)],...
    'fontw','bold','fontsize',11);
if h==5
    stop(cpanel);
    set(d3d_analysepanel,'fontw','bold','fontsize',8);
end
h=h+1;

function analyse_xyorgin(varargin)
global handles cor figurehandleX d3dcstlineT d3dcstlinePOP  d3dcstlinefixPB d3d_analysepanel...
    xgrid ygrid figxyO d3dcstlinefixT D1
fig=getappdata(figurehandleX,'figurehandle');
if D1==1
    d3dcstlinefixT=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.77 0.155  0.12 0.0355],'string','Status: Check!','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left','enable','on');
    figxyO=uicontrol('units','normalized','parent',fig,...
        'position',[0.65 0.099 0.112 0.163],'selected','off');
    
    handles{2,3}=[handles{2,3} figxyO d3dcstlinefixT];
    D1=D1+1;
end

[xMax,idxmax]=max(xgrid(:)); [yMax,idymax]=max(ygrid(:));
[xMin,idxmin]=min(xgrid(:)); [yMin,idymin]=min(ygrid(:));
x1=xgrid(1,1); xEnd1=xgrid(end,1); x1End=xgrid(1,end); xEndEnd=xgrid(end,end);
y1=ygrid(1,1); yEnd1=ygrid(end,1); y1End=ygrid(1,end); yEndEnd=ygrid(end,end);

if get(d3dcstlinePOP,'value')==2 %NorthWest
    if x1 == xMax & yEnd1==yMax
        set(d3dcstlinefixT,'string','Status: Ok!','foregroundcolor','b');
        set(d3dcstlinefixPB,'enable','off');
        clear pI; pI=imread('../assets/images/p1.png');
        set(figxyO,'cdata',pI);
    elseif (xMin<x1) && (x1<xMax) & y1==yMin  % INCOMPLETE - REVISE
        clear pI; pI=imread('../assets/images/p2.png');
        set(figxyO,'cdata',pI);
        set(d3dcstlinefixT,'string','Status: Check!','enable','on','foregroundcolor','r');
        set(d3dcstlinefixPB,'enable','on');
    elseif (yMin<y1) && (y1<yMax) & x1==xMin
        clear pI; pI=imread('../assets/images/p3.png');
        set(figxyO,'cdata',pI);
        set(d3dcstlinefixT,'string','Status: Check!','enable','on','foregroundcolor','r');
        set(d3dcstlinefixPB,'enable','on');
    elseif (xMin<x1) && (x1<xMax) & y1==yMax
        clear pI; pI=imread('../assets/images/p4.png');
        set(figxyO,'cdata',pI);
        set(d3dcstlinefixT,'string','Status: Check!','enable','on','foregroundcolor','r');
        set(d3dcstlinefixPB,'enable','on');
    end
elseif get(d3dcstlinePOP,'value')==3 %West
    if x1 == xMax | x1 < xMax-xMax*0.01 & xEnd1 ==xMin | xEnd1 < xMin+xMin*0.01
        set(d3dcstlinefixT,'string','Status: Ok!','foregroundcolor','b');
        set(d3dcstlinefixPB,'enable','off');
        clear pI; pI=imread('../assets/images/p1.png');
        set(figxyO,'cdata',pI);
    elseif y1 == yMin & idymin == 1 % INCOMPLETE - REVISE
        clear pI; pI=imread('../assets/images/p2.png');
        set(figxyO,'cdata',pI);
        set(d3dcstlinefixT,'string','Status: Check!','enable','on','foregroundcolor','r');
        set(d3dcstlinefixPB,'enable','on');
    end
end
set(d3d_analysepanel,'foregroundcolor',[0 0 0]);

function openDEPTH(hObj,event)
global depfile xgrid ygrid d3ddepTMax_open d3ddepValueMax_open ...
    d3ddepValueMin_open B1 d3ddepPB_open figurehandleX zs0file_PB zs0file ...
    ne_layerPB ne_layer fileD pathD direc_place
if hObj == d3ddepPB_open
    set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
    set(d3ddepPB_open,'foregroundcolor','b');
    gridD3D.X=xgrid; gridD3D.Y=ygrid;
    [fileD,pathD]=uigetfile({'*.dep','Depth (*.dep)'},'Pick a File');
    if fileD==0
        set(depfile,'String','Filename Unknown');
    else
        clear bathyD3D
        try
            [bathyD3D]=wldep_Xbeach('read',[pathD,fileD],gridD3D);
    %         if ~isempty(verifyDEPTH)
    %             alertFigure('Wrong Bathymetry file!');
    %             return
    %         end
            bathyD3D=bathyD3D(1:end-1,1:end-1); 
            
            bathyD3D(bathyD3D == -999) = nan;
            
            Bmax=nanmax(bathyD3D(:)); Bmin=nanmin(bathyD3D(:));
            set(depfile,'String',fileD);
            set(d3ddepTMax_open,'enable','on');
            set(d3ddepValueMax_open,'enable','on','string',sprintf('%3.1f',Bmin));
            set(d3ddepValueMin_open,'enable','on','string',sprintf('%3.1f',Bmax));
            B1=bathyD3D;
            set(direc_place,'string',pathD);
            set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pathD),'*']);
%             cd(pathD)
        catch
            alertFigure('Wrong Bathymetry file!');
            return
        end
    end
elseif hObj ==  zs0file_PB
    set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
    [file,path]=uigetfile({'*.txt','Tide/Surge (*.txt)'},'Pick a File');
    if file==0
        set(zs0file,'String','Filename Unknown');
    else
        set(zs0file,'string',file);
    end
elseif hObj == ne_layerPB
    set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
    [file,path]=uigetfile({'*.dep','Bed Thickness (*.dep)'},'Pick a File');
    if file==0
        set(ne_layer,'String','Filename Unknown');
    else
        set(ne_layer,'string',file,'enable','on');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         Main Button Processes                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function processes_button(varargin)
global handles figurehandleX cor sedtrans morphology kt handles_MB...
    swave lwave flow nonh gwflow q3d globalhand
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
set(handles_MB,'foregroundcolor','k'); set(handles_MB(3),'foregroundcolor','b');
for k=1:kt
    for g=1:length(handles(:,1))
        if ~isempty('handles'); aux=handles{g,k}; set(aux,'visible','off'); end
    end
end
set(handles{3,1},'visible','on');
set(handles_MB(5),'enable','on');
if isempty(handles{3,1})
    fig=getappdata(figurehandleX,'figurehandle');
    proc_panel=uipanel('unit','normalized','parent',fig,'Title','Physical Processes','fontsize',8,...
        'position',[0.24 0.48  0.7 0.5],'backgroundcolor',cor);
    swave=uicontrol('unit','normalized','parent',fig,'style','check',...
        'String','Short Waves','fontsize',10,'fontw','bold','position',[0.33 0.85  0.2 0.0444],...
        'backgroundcolor',cor,'value',1);
    lwave=uicontrol('unit','normalized','parent',fig,'style','check',...
        'String','Long Waves','fontsize',10,'fontw','bold','position',[0.33 0.78  0.2 0.0444],...
        'backgroundcolor',cor,'value',1);
    flow=uicontrol('unit','normalized','parent',fig,'style','check',...
        'String','NLSW Equations','fontsize',10,'fontw','bold','position',[0.33 0.71  0.2 0.0444],...
        'backgroundcolor',cor,'value',1,...
        'tooltipstring',sprintf('NonLinear Shallow Water equation'));...
    sedtrans=uicontrol('unit','normalized','parent',fig,'style','check',...
        'String','Sediment Transport','fontsize',10,'fontw','bold','position',[0.33 0.64  0.2 0.0444],...
        'backgroundcolor',cor,'value',1);
    morphology=uicontrol('unit','normalized','parent',fig,'style','check',...
        'String','Bathymetry Update','fontsize',10,'fontw','bold','position',[0.33 0.57  0.2 0.0444],...
        'backgroundcolor',cor,'value',1);
    nonh=uicontrol('unit','normalized','parent',fig,'style','check',...
        'String','NonHydrostatic Flow','fontsize',10,'fontw','bold','position',[0.65 0.85  0.2 0.0444],...
        'backgroundcolor',cor,'value',0,...
        'tooltipstring',sprintf('NLSW equation without wave-action driver'));
    gwflow=uicontrol('unit','normalized','parent',fig,'style','check',...
        'String','Groundwater Flow','fontsize',10,'fontw','bold','position',[0.65 0.78  0.2 0.0444],...
        'backgroundcolor',cor,'value',0);
    q3d=uicontrol('unit','normalized','parent',fig,'style','check',...
        'String','quasi-3D Model (NYI)','fontsize',10,'fontw','bold','position',[0.65 0.71  0.2 0.0444],...
        'backgroundcolor',cor,'value',0,...
        'tooltipstring','Not Yet Implemented');    
    handles{3,1}=[handles{3,1} proc_panel swave lwave flow sedtrans morphology...
        nonh gwflow q3d];
    globalhand{1,4}={swave; lwave; flow; sedtrans; morphology; nonh; gwflow; q3d};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         Main Button Limiters                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function limiters_button(varargin)
global handles figurehandleX cor kt handles_MB...
    hmin eps umin hwci globalhand
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
set(handles_MB,'foregroundcolor','k'); set(handles_MB(4),'foregroundcolor','b');
for k=1:kt
    for g=1:length(handles(:,1))
        if ~isempty('handles'); aux=handles{g,k}; set(aux,'visible','off'); end
    end
end
set(handles{4,1},'visible','on');
if isempty(handles{4,1})
    fig=getappdata(figurehandleX,'figurehandle');
    limiters_panel=uipanel('unit','normalized','parent',fig,'Title','Limiters','fontsize',8,...
        'position',[0.24 0.64  0.7 0.34],'backgroundcolor',cor);
    hmin_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.88  0.6 0.0444],'string',...
        'Min. depth for concentration and return flow                                     [m]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('key: hmin\nMin: 0.05\nMax: 1'));
    hmin=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.67 0.887 0.15 0.0444],'string','0.05','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    eps_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.81  0.6 0.0444],'string',...
        'Min. depth for drying and flooding                                                     [m]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('key: eps\nMin: 0.001\nMax: 0.1'));
    eps=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.67 0.817 0.15 0.0444],'string','0.005','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    umin_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.74  0.6 0.0444],'string',...
        'Min. veloc. for upwind scheme                                                          [m/s]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('key: umin\nMin: 0.0\nMax: 5'));
    umin=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.67 0.747 0.15 0.0444],'string','0.0','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    hwci_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.67  0.6 0.0444],'string',...
        'Depth below which wci is no aplied                                                  [m]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('key: hwci\nMin: 0.0001\nMax: 1'));
    hwci=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.67 0.677 0.15 0.0444],'string','0.1','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    handles{4,1}=[handles{4,1} limiters_panel hmin_text hmin ...
        eps_text eps umin_text umin hwci_text hwci];
    
    globalhand{1,5}={hmin; eps; umin; hwci};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    Main Button Physical Parameters                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function phy_parameters_button(varargin)
global handles figurehandleX cor sedtrans morphology tab_constants tab_flow ...
    tab_wave tab_wind kt constantsclock flowclock waveclock windclock...
    sedtranspclock morphoclock tab_sed_transp tab_morphoUP handles_MB
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
set(handles_MB,'foregroundcolor','k'); set(handles_MB(5),'foregroundcolor','b');
% persistent tab_sed_transp tab_morphoUP
fig=getappdata(figurehandleX,'figurehandle');
for k=1:kt
    for g=1:length(handles(:,1))
        if ~isempty('handles'); aux=handles{g,k}; set(aux,'visible','off'); end
    end
end
set(handles{5,1},'visible','on');
aux=max([constantsclock flowclock waveclock windclock...
    sedtranspclock morphoclock]);
if aux==constantsclock;
    set(handles{5,2},'visible','on');
    set(handles{5,1},'value',0);
    set([tab_constants tab_flow tab_wave tab_wind tab_sed_transp tab_morphoUP],'foregroundcolor','k');
    set(tab_constants,'foregroundcolor','b');
elseif aux==flowclock;
    set(handles{5,3},'visible','on');
    set(handles{5,1},'value',0);
    set([tab_constants tab_flow tab_wave tab_wind tab_sed_transp tab_morphoUP],'foregroundcolor','k');
    set(tab_flow,'foregroundcolor','b');
elseif aux==waveclock;
    set(handles{5,4},'visible','on');
    set(handles{5,1},'value',0);
    set([tab_constants tab_flow tab_wave tab_wind tab_sed_transp tab_morphoUP],'foregroundcolor','k');
    set(tab_wave,'foregroundcolor','b');
elseif aux==windclock;
    set(handles{5,5},'visible','on');
    set(handles{5,1},'value',0);
    set([tab_constants tab_flow tab_wave tab_wind tab_sed_transp tab_morphoUP],'foregroundcolor','k');
    set(tab_wind,'foregroundcolor','b');
elseif aux==sedtranspclock;
    set(handles{5,6},'visible','on');
    set(handles{5,1},'value',0);
    set([tab_constants tab_flow tab_wave tab_wind tab_sed_transp tab_morphoUP],'foregroundcolor','k');
    set(tab_sed_transp,'foregroundcolor','b');
elseif aux==morphoclock;
    set(handles{5,7},'visible','on');
    set(handles{5,1},'value',0);
    set([tab_constants tab_flow tab_wave tab_wind tab_sed_transp tab_morphoUP],'foregroundcolor','k');
    set(tab_morphoUP,'foregroundcolor','b');
end


if ~isempty(tab_sed_transp) & get(sedtrans,'value')==0
    if ishghandle(tab_sed_transp); delete(tab_sed_transp); clear tab_sed_transp;
        set(handles{5,6},'visible','off');
    end
    if get(morphology,'value')==1
        if ishghandle(morphology)==1
            set(tab_morphoUP,'position',[0.72 0.9445  0.12 0.0355]);
        else
            tab_morphoUP=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
                'position',[0.72 0.9445  0.12 0.0355],'string','Morphological','fontsize',8,...
                'fontw','bold','callback',@morphoTAB,'foregroundcolor','k');
        end
        handles{5,1}=[]; handles{5,1}=[handles{5,1} tab_constants tab_flow tab_wave tab_wind tab_morphoUP];
    else
        handles{5,1}=[]; handles{5,1}=[handles{5,1} tab_constants tab_flow tab_wave tab_wind];
    end
elseif isempty(tab_sed_transp) & get(sedtrans,'value')==1
    tab_sed_transp=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',[0.72 0.9445  0.12 0.0355],'string','Sed. Transp.','fontsize',8,...
        'fontw','bold','callback',@sedtranspTAB,'foregroundcolor','k');
    handles{5,1}=[handles{5,1} tab_sed_transp];
end
if ~isempty(tab_morphoUP) & get(morphology,'value')==0
    if ishghandle(tab_morphoUP); delete(tab_morphoUP); clear tab_morphoUP;
        set(handles{5,7},'visible','off');
    end
    if get(sedtrans,'value')==1
        handles{5,1}=[]; handles{5,1}=[handles{5,1} tab_constants tab_flow tab_wave tab_wind tab_sed_transp];
    else
        handles{5,1}=[]; handles{5,1}=[handles{5,1} tab_constants tab_flow tab_wave tab_wind ];
    end
elseif isempty(tab_morphoUP) & get(morphology,'value')==1
    if get(sedtrans,'value')==0
        p1=[0.72 0.9445  0.12 0.0355];
    else
        p1=[0.84 0.9445  0.12 0.0355];
    end
    tab_morphoUP=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',p1,'string','Morphological','fontsize',8,...
        'fontw','bold','callback',@morphoTAB,'foregroundcolor','k');
    handles{5,1}=[handles{5,1} tab_morphoUP];
end
if get(sedtrans,'value')==1 & get(morphology,'value')==1 &...
        ishghandle(tab_sed_transp)==1 & ishghandle(tab_morphoUP)==1
    set(tab_sed_transp,'position',[0.72 0.9445  0.12 0.0355]);
    set(tab_morphoUP,'position',[0.84 0.9445  0.12 0.0355]);
    handles{5,1}=[]; handles{5,1}=[handles{5,1} tab_constants tab_flow tab_wave tab_wind tab_sed_transp tab_morphoUP];
elseif get(sedtrans,'value')==1 & get(morphology,'value')==1 &...
        ishghandle(tab_sed_transp)==1 & ishghandle(tab_morphoUP)==0
    set(tab_sed_transp,'position',[0.72 0.9445  0.12 0.0355]);
    tab_morphoUP=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',[0.84 0.9445  0.12 0.0355],'string','Morphological','fontsize',8,...
        'fontw','bold','callback',@morphoTAB,'foregroundcolor','k');
    handles{5,1}=[]; handles{5,1}=[handles{5,1} tab_constants tab_flow tab_wave tab_wind tab_sed_transp tab_morphoUP];
elseif get(sedtrans,'value')==1 & get(morphology,'value')==1 &...
        ishghandle(tab_sed_transp)==0 & ishghandle(tab_morphoUP)==1
    set(tab_morphoUP,'position',[0.84 0.9445  0.12 0.0355]);
    tab_sed_transp=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',[0.72 0.9445  0.12 0.0355],'string','Sed. Transp.','fontsize',8,...
        'fontw','bold','callback',@sedtranspTAB,'foregroundcolor','k');
    handles{5,1}=[]; handles{5,1}=[handles{5,1} tab_constants tab_flow tab_wave tab_wind tab_sed_transp tab_morphoUP];
elseif get(sedtrans,'value')==1 & get(morphology,'value')==1 &...
        ishghandle(tab_sed_transp)==0 & ishghandle(tab_morphoUP)==0
    tab_sed_transp=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',[0.72 0.9445  0.12 0.0355],'string','Sed. Transp.','fontsize',8,...
        'fontw','bold','callback',@sedtranspTAB,'foregroundcolor','k');
    tab_morphoUP=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',[0.84 0.9445  0.12 0.0355],'string','Morphological','fontsize',8,...
        'fontw','bold','callback',@morphoTAB,'foregroundcolor','k');
    handles{5,1}=[]; handles{5,1}=[handles{5,1} tab_constants tab_flow tab_wave tab_wind tab_sed_transp tab_morphoUP];
end
if length(handles{5,1}) < 4%isempty(handles{4,1})
    tab_constants=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',[0.24 0.9445  0.12 0.0355],'string','Constants','fontsize',8,...
        'fontw','bold','callback',@constantsTAB);
    tab_flow=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',[0.36 0.9445  0.12 0.0355],'string','Flow','fontsize',8,...
        'fontw','bold','callback',@flowTAB);
    tab_wave=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',[0.48 0.9445  0.12 0.0355],'string','Wave','fontsize',8,...
        'fontw','bold','callback',@waveTAB);
    tab_wind=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',[0.60 0.9445  0.12 0.0355],'string','Wind','fontsize',8,...
        'fontw','bold','callback',@windTAB);
    % if isempty(tab_sed_transp)
    % tab_sed_transp=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
    %     'position',[0.72 0.9445  0.12 0.0355],'string','Sed. Transp.','fontsize',8,...
    %     'fontw','bold','callback',@sedtranspTAB);
    % end
    % if isempty(tab_morphoUP)
    % tab_morphoUP=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
    %     'position',[0.84 0.9445  0.12 0.0355],'string','Morphological','fontsize',8,...
    %     'fontw','bold','callback',@morphoTAB);
    % end
    handles{5,1}=[handles{5,1} tab_constants tab_flow tab_wave tab_wind];
end

function constantsTAB(varargin)
global handles figurehandleX cor kt constantsclock tab_constants ...
    tab_flow  tab_wave tab_wind tab_sed_transp tab_morphoUP gravity_value rho...
    globalhand
constantsclock=datenum(clock);
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
for k=1:kt
    for g=1:length(handles(:,1))
        if ~isempty('handles'); aux=handles{g,k}; set(aux,'visible','off'); end
    end
end
set(handles{5,1},'visible','on'); set(handles{5,2},'visible','on');
if ishghandle(tab_sed_transp)==1 & ishghandle(tab_morphoUP)==1
    set([tab_flow,tab_wave,tab_wind,tab_sed_transp,tab_morphoUP],...
        'foregroundcolor','k'); set(tab_constants,'foregroundcolor','b');
elseif ishghandle(tab_sed_transp)==1 & ishghandle(tab_morphoUP)==0
    set([tab_flow,tab_wave,tab_wind,tab_sed_transp],...
        'foregroundcolor','k'); set(tab_constants,'foregroundcolor','b');
elseif ishghandle(tab_sed_transp)==0 & ishghandle(tab_morphoUP)==1
    set([tab_flow,tab_wave,tab_wind,tab_morphoUP],...
        'foregroundcolor','k'); set(tab_constants,'foregroundcolor','b');
elseif ishghandle(tab_sed_transp)==0 & ishghandle(tab_morphoUP)==0
    set([tab_flow,tab_wave,tab_wind],...
        'foregroundcolor','k'); set(tab_constants,'foregroundcolor','b');
end
if isempty(handles{5,2})
    fig=getappdata(figurehandleX,'figurehandle');
    const_panel=uipanel('unit','normalized','parent',fig,'Title','Constants','fontsize',8,...
        'position',[0.24 0.73  0.7 0.2],'backgroundcolor',cor);
    gravity_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.83  0.5 0.0444],'string',...
        'Gravity Acceleration                                           [m/s²]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
    gravity_value=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.50 0.837 0.15 0.0444],'string','9.81','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    rho_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.76  0.5 0.0444],'string',...
        'Water Density                                                   [kg/m²]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
    rho=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.50 0.767 0.15 0.0444],'string','1025','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    handles{5,2}=[handles{5,2} const_panel gravity_text rho_text gravity_value rho];
    globalhand{1,6}={gravity_value; rho};
end

function flowTAB(varargin)
global handles figurehandleX cor kt flowclock tab_flow ...
    tab_constants  tab_wave tab_wind tab_sed_transp tab_morphoUP...
    cf C nuh nuhfac nuhv smag ...
    zs0file_PB zs0file tide_handle tide_panelPB tide_panelPB1 tideloc...
    tide_panel globalhand
flowclock=datenum(clock);
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
for k=1:kt
    for g=1:length(handles(:,1))
        if ~isempty('handles'); aux=handles{g,k}; set(aux,'visible','off'); end
    end
end
set(handles{5,1},'visible','on'); set(handles{5,3},'visible','on');
set([tab_constants,tab_wave,tab_wind,tab_sed_transp,tab_morphoUP],...
    'foregroundcolor','k'); set(tab_flow,'foregroundcolor','b');
if isempty(handles{5,3})
    fig=getappdata(figurehandleX,'figurehandle');
    tide_panelPB1=uicontrol('unit','normalized','parent',fig,'style','togglebutton','fontsize',8,...
        'position',[0.93 0.21  0.02 0.02],'backgroundcolor',cor,'visible','off',...
        'callback',@enable_tide);    
    tide_panel=uipanel('unit','normalized','parent',fig,'Title','Tide/Storm Surge','fontsize',8,...
        'position',[0.24 0.22  0.7 0.18],'backgroundcolor',cor,...
        'foregroundcolor',[.5 .5 .5]);
    tide_panelPB=uicontrol('unit','normalized','parent',fig,'style','togglebutton','fontsize',8,...
        'position',[0.24 0.22  0.7 0.18],'backgroundcolor',cor,'callback',@enable_tide);
    flow_panel=uipanel('unit','normalized','parent',fig,'Title','Flow','fontsize',8,...
        'position',[0.24 0.45  0.7 0.48],'backgroundcolor',cor);
%     roughness_panel=uipanel('unit','normalized','parent',fig,'Title','Roughness','fontsize',8,...
%         'position',[0.27 0.7  0.64 0.2],'backgroundcolor',cor,'titleposition','righttop');
    cf_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.83  0.6 0.0444],'string',...
        'Flow Friction Coefficient                                                     [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring','key: cf');
    cf=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.585 0.837 0.15 0.0444],'string','0.003','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right','callback',@calculate_chezy);
    chezy_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.76  0.6 0.0444],'string',...
        'Chezy Coefficient                                                                [m^1/2/s]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring','Sqrt(g/cf) -> key: C');
    C=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.585 0.767 0.15 0.0444],'string',...
        sprintf('%3.0f',sqrt(9.81/str2double(get(cf,'string')))),'fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    nuh_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.69  0.6 0.0444],'string',...
        'Horizontal Background Viscosity                                         [m²/s]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring','key: nuh');
    nuh=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.585 0.697 0.15 0.0444],'string','0.15','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    visco_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.62  0.6 0.0444],'string',...
        'Viscosity Coeff. for Roller                                                    [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',...
        sprintf('Viscosity coefficient for\nroller induced turbulent\nhorizontal viscosity -> key: nuhfac'));
    nuhfac=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.585 0.627 0.15 0.0444],'string','0','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right','tooltipstring',sprintf('Min - 0\nMax - 1'));
    sh_disp_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.55  0.6 0.0444],'string',...
        'Addit. Shear Dispersion Factor                                           [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring','Svendsen & Putrevu (1994) -> Key: nuhv');
    nuhv=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.585 0.557 0.15 0.0444],'string','1','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right','tooltipstring',sprintf('Min - 1\nMax - 20'));
    smago_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.48  0.6 0.0444],'string',...
        'Smagorinski Viscosity                                                         [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring','key: smag');
    smag=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.585 0.487 0.15 0.0444],'string','1','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right','tooltipstring',sprintf('Min - 0\nMax - 1'));
    
    zs0file_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.31  0.6 0.0444],'string',...
        'Time-varying water level signal','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Max: 4\nkey: zs0file'),'enable','off');
    zs0file=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.75 0.31  0.17 0.0444],'string',...
        'Filename Unknown','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left','enable','off');
    zs0file_PB=uicontrol('unit','normalized','parent',fig','style','pushbutton',...
        'position',[0.585 0.317 0.15 0.0444],'string','Open file','fontsize',10,...
        'fontw','bold','SelectionHighlight','on','enable','off',...
        'horizontalalignment','right','callback',@openDEPTH);
    tideloc_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.24  0.6 0.0444],'string',...
        'Number of input tidal time series','fontsize',10,'enable','off',...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Max: 4\nkey: tideloc'));
    tideloc=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.585 0.247 0.15 0.0444],'string','1','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right','enable','off');
    tide_handle=[zs0file_text zs0file zs0file_PB...
        tideloc_text tideloc];
    
    handles{5,3}=[handles{5,3} flow_panel cf_text cf chezy_text C nuh_text nuh visco_text...
        nuhfac sh_disp_text nuhv nuhv smago_text smag...
        tide_panelPB1 tide_handle tide_panel tide_panelPB];
    globalhand{1,7}={cf; C; nuh; nuhfac; nuhv; smag; zs0file; tideloc};
end

function enable_tide(hObj,event)
global tide_handle tide_panelPB tide_panelPB1 zs0file tide_panel
if hObj == tide_panelPB
    set(gcbo,'visible','off');
    set(tide_handle,'enable','on');
    set(tide_panelPB1,'visible','on','value',0);   
    set(tide_panel,'foregroundcolor','k');
elseif hObj == tide_panelPB1
    set(tide_panelPB,'visible','on','value',0);  
    set(tide_handle,'enable','off');  
    set(gcbo,'visible','off');
    set(tide_panel,'foregroundcolor',[.5 .5 .5]);
    set(zs0file,'string','Filename Unknown');    
end

function waveTAB(varargin)
global handles figurehandleX cor kt waveclock tab_wave...
    tab_constants tab_flow tab_wind tab_sed_transp tab_morphoUP...
    wavint wci gamma gammax alpha...
    n roller beta scheme break_value globalhand
waveclock=datenum(clock);
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
for k=1:kt
    for g=1:length(handles(:,1))
        if ~isempty('handles'); aux=handles{g,k}; set(aux,'visible','off'); end
    end
end
set(handles{5,1},'visible','on'); set(handles{5,4},'visible','on');
set([tab_constants,tab_flow,tab_wind,tab_sed_transp,tab_morphoUP],...
    'foregroundcolor','k'); set(tab_wave,'foregroundcolor','b');
if isempty(handles{5,4})
    fig=getappdata(figurehandleX,'figurehandle');
    act_bal_panel=uipanel('unit','normalized','parent',fig,'Title','Action Balance','fontsize',8,...
        'position',[0.24 0.74  0.7 0.19],'backgroundcolor',cor);
    dissipat_panel=uipanel('unit','normalized','parent',fig,'Title','Dissipation Model','fontsize',8,...
        'position',[0.24 0.4  0.7 0.33],'backgroundcolor',cor);
    roller_model_panel=uipanel('unit','normalized','parent',fig,'Title','Roller Model','fontsize',8,...
        'position',[0.24 0.2  0.7 0.19],'backgroundcolor',cor);
    wavint_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.86  0.6 0.0344],'string',...
        'Interval between stationay wave module                                       [s]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('instat = 0 only\nMin: 1\nMax: 3600\nkey: wavint'));
    wavint=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.68 0.863 0.12 0.0344],'string','1','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    scheme_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.81  0.6 0.0344],'string',...
        'Numerical Scheme                                                                         [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('1 = Upwind\n2 = Lax Wendroff\nkey: scheme'));
    scheme=uicontrol('unit','normalized','parent',fig','style','popup',...
        'position',[0.65 0.828 0.15 0.0244],'value',2,...
        'string','Upwind|Lax Wendroff','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    wci_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.76  0.6 0.0344],'string',...
        'Wave current interaction                                                                [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('0 = Off\n1 = On\nkey: wci'));
    wci=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.68 0.763 0.12 0.0344],'string','1','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    break_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.64  0.6 0.0344],'string',...
        'Breaker model                                                                                [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf(['1 = Roelvink1 (1993a)\n2 = Baldock (Stationary case only)\n',...
        '3 = Roelvink2\n4 = Daly & Roelvink(ICCE 2010)\nkey: break']));
    break_value=uicontrol('unit','normalized','parent',fig','style','popup',...
        'position',[0.65 0.647 0.15 0.0344],'value',3,...
        'string','Roelvink|Baldock|Roelvink2|Roelvink & Daly','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    gamma_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.59  0.6 0.0344],'string',...
        'Breaker parameter                                                                         [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Min: 0.4\nMax: 0.9\nkey: gamma'));
    gamma=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.68 0.593 0.12 0.0344],'string','0.55','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    gammax_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.54  0.6 0.0344],'string',...
        'Maximum waveheight over waterdepth                                         [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Min: 0.4\nMax: 5\nkey: gammax'));
    gammax=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.68 0.543 0.12 0.0344],'string','2','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    alpha_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.49  0.6 0.0344],'string',...
        'Wave dissipation coefficient                                                          [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Min: 0.5\nMax: 2\nkey: alpha'));
    alpha=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.68 0.493 0.12 0.0344],'string','1','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    n_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.44  0.6 0.0344],'string',...
        'Power in Roelvink Model                                                               [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Min: 5\nMax: 20\nkey: n'));
    n=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.68 0.443 0.12 0.0344],'string','10','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    roller_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.3  0.6 0.0344],'string',...
        'Roller Model                                                                                   [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Keyword not yet\nimplemented\nkey: roller'));
    roller=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.68 0.303 0.12 0.0344],'string','1','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    beta_text=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.30 0.25  0.6 0.0344],'string',...
        'Breaker slope coefficient                                                                [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Min: 0.05\nMax: 0.3\nkey: beta'));
    beta=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.68 0.253 0.12 0.0344],'string','0.15','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    handles{5,4}=[handles{5,4} act_bal_panel dissipat_panel roller_model_panel...
        wavint_text wavint scheme_text scheme wci_text...
        wci break_text break_value gamma_text gamma gammax_text...
        gammax alpha_text alpha n_text n roller_text ...
        roller beta_text beta];
    globalhand{1,8}={wavint; wci; gamma; gammax; alpha; n; roller; beta; scheme; break_value};
end

function calculate_chezy(varargin)
global cf C
set(C,'string',num2str(sqrt(9.81/str2double(get(cf,'string')))));

function windTAB(varargin)
global handles figurehandleX cor kt windclock tab_wind...
    tab_constants tab_flow tab_wave tab_sed_transp tab_morphoUP rhoa...
    Cd windv windth globalhand

windclock=datenum(clock);
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
for k=1:kt
    for g=1:length(handles(:,1))
        if ~isempty('handles'); aux=handles{g,k}; set(aux,'visible','off'); end
    end
end
set(handles{5,1},'visible','on'); set(handles{5,5},'visible','on');
set([tab_constants,tab_flow,tab_wave,tab_wind,tab_sed_transp,tab_morphoUP],...
    'foregroundcolor','k'); set(tab_wind,'foregroundcolor','b');
if isempty(handles{5,5})
    fig=getappdata(figurehandleX,'figurehandle');
    wind_panel=uipanel('unit','normalized','parent',fig,'Title','Wind','fontsize',8,...
        'position',[0.24 0.585  0.7 0.345],'backgroundcolor',cor);
    rhoaT_wind=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.83  0.6 0.0444],'string',...
        'Air Density                                                                                     [kg/m²]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring','key: rhoa');
    rhoa=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.65 0.837 0.15 0.0444],'string','1.25','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    CdT_wind=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.76  0.6 0.0444],'string',...
        'Wind Drag Coefficient (Attention: > 50m/s)                                    [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Min: 0.0001\nMax: 0.01\nkey: Cd'));
    Cd=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.65 0.767 0.15 0.0444],'string','0.002','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    windvT_wind=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.69  0.6 0.0444],'string',...
        'Wind Velocity                                                                                [m/s]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring','key: windv');
    windv=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.65 0.697 0.15 0.0444],'string','5','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    windthT_wind=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.62  0.6 0.0444],'string',...
        'Wind Direction (Nautical Convention)                                           [deg]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring','key: windth');
    windth=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.65 0.627 0.15 0.0444],'string','0','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    handles{5,5}=[handles{5,5} wind_panel rhoaT_wind rhoa CdT_wind...
        Cd windvT_wind windv windthT_wind windth];
    globalhand{1,9}={rhoa; Cd; windv; windth};
end

function sedtranspTAB(varargin)
global handles figurehandleX cor kt sedtranspclock tab_sed_transp...
    tab_constants tab_flow tab_wave tab_wind tab_morphoUP z0 ...
    facsl BRfac rhos por tsfac...
    facua waveform form thetanum smax...
    lws sws globalhand D50 D90 struct ne_layerPB ne_layer

sedtranspclock=datenum(clock);
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
for k=1:kt
    for g=1:length(handles(:,1))
        if ~isempty('handles'); aux=handles{g,k}; set(aux,'visible','off'); end
    end
end
set(handles{5,1},'visible','on'); set(handles{5,6},'visible','on');
if ishghandle(tab_morphoUP)
    set([tab_constants tab_flow tab_wave tab_wind tab_morphoUP],...
        'foregroundcolor','k'); set(tab_sed_transp,'foregroundcolor','b');
else
    set([tab_constants tab_flow tab_wave tab_wind],...
        'foregroundcolor','k'); set(tab_sed_transp,'foregroundcolor','b');
end
if isempty(handles{5,6})
    fig=getappdata(figurehandleX,'figurehandle');
    ST_panel=uipanel('unit','normalized','parent',fig,'Title',...
        'Sediment Transport','fontsize',8,...
        'position',[0.24 0.07  0.7 0.86],'backgroundcolor',cor);
    wformT_ST=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.83  0.6 0.0444],'string',...
        'Waveshape Model                                                                           [-]','fontsize',10,...
        'fontw','bold','value',1,'backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Ruessink & vanRijn\nkey: waveform'));
    waveform=uicontrol('unit','normalized','parent',fig,'style','popup',...
        'position',[0.55 0.841 0.25 0.04],'value',2,...
        'string','ruessink |vanthiel','fontsize',10,...
        'fontw','bold','SelectionHighlight','on','backgroundcolor',[1 1 1],...
        'horizontalalignment','right');
    formT_ST=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.78  0.6 0.0444],'string',...
        'Equilibrium Sedim. Concent. Form.                                                [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring','key: form');
    form=uicontrol('unit','normalized','parent',fig,'style','popup',...
        'position',[0.62 0.791 0.18 0.04],'value',1,...
        'string','Soulsby\vanRijn|Vanthiel\vanRijn','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    thetanumT_ST=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.73  0.6 0.0444],'string',...
        'Scheme                                                                                           [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring','key: thetanum');
    thetanum=uicontrol('unit','normalized','parent',fig,'style','popup',...
        'position',[0.7 0.741 0.10 0.04],...
        'string','Upwind|Central','value',1,'fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    z0T_ST=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.68  0.4 0.05444],'string',...
        'Zero Flow velocity level Sed. Conc. (Soulsby & vanRijn(1997)','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Min:0.0001\nMax: 0.05\nkey: z0'));
    z0T_ST2=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.815 0.673  0.1 0.05444],'string',...
        '[m]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
    z0=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.7 0.691 0.10 0.04],'string','0.006','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    facslT_ST=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.63  0.6 0.0444],'string',...
        'Bed Slope Factor                                                                            [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Min:0\nMax: 1.6\nkey: facsl'));
    facsl=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.7 0.641 0.10 0.04],'string','0','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    BRfacT_ST=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.58  0.6 0.0444],'string',...
        'Calibration Factor surface slope                                                     [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Min:0\nMax: 1\nkey: BRfac'));
    BRfac=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.7 0.591 0.10 0.04],'string','1','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    rhosT_ST=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.53  0.6 0.0444],'string',...
        'Density of Sediment (no pores)                                                       [kg/m²]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Min:2400\nMax: 2800\nkey: rhos'));
    rhos=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.7 0.541 0.10 0.04],'string','2650','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    porT_ST=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.48  0.6 0.0444],'string',...
        'Porosity                                                                                           [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Min:0.3\nMax: 0.5\nkey: por'));
    por=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.7 0.491 0.10 0.04],'string','0.4','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    smaxT_ST=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.43  0.6 0.0444],'string',...
        'Max shields value for overwash                                                      [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Min:-1\nMax: 3\nkey: smax'));
    smax=uicontrol('unit','normalized','parent',fig,'style','popup',...
        'position',[0.7 0.441 0.10 0.04],'value',1,...
        'string','-1|0|1|2|3','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    tsfacT_ST=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.38  0.6 0.0444],'string',...
        'Max value for fall velocity                                                               [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Min:0.01\nMax: 1\nkey: tsfac'));
    tsfac=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.7 0.391 0.10 0.04],'string','0.1','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    facuaT_ST=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.33  0.6 0.0444],'string',...
        'Asymmetry transport                                                                       [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Min:0\nMax: 1\nkey: facua'));
    facua=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.7 0.341 0.10 0.04],'string','0','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    d50T=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.24  0.6 0.0444],'string',...
        'D50 sediment diameter                                                                   [m]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('key: D50'));
    D50=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.7 0.251 0.10 0.04],'string','0.0002','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    d90T=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.19  0.6 0.0444],'string',...
        'D90 sediment diameter                                                                   [m]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('key: D90'));
    D90=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.7 0.201 0.10 0.04],'string','0.0003','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    structT=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.14  0.6 0.0444],'string',...
        'Option for hard structures                                                               [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('key: struct'));
    struct=uicontrol('unit','normalized','parent',fig,'style','popup',...
        'position',[0.63 0.151 0.17 0.04],'string','No revetment|Multiple classes','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    nelayerT=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.09  0.6 0.0444],'string',...
        'Bed thickness','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('key: ne_layer'));
    ne_layer=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.645 0.09  0.2 0.0444],'string',...
        'Filename Unknown','fontsize',10,'enable','off',...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
    ne_layerPB=uicontrol('unit','normalized','parent',fig,'style','push',...
        'position',[0.47 0.101 0.15 0.04],'string','Open File','fontsize',10,...
        'fontw','bold','SelectionHighlight','on',...
        'horizontalalignment','right','callback',@openDEPTH);
%     lws=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
%         'position',[0.37 0.16  0.2 0.0444],'string',...
%         'Longwave stirring','fontsize',10,'value',1,...
%         'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
%         'tooltipstring',sprintf('key: lws'));
%     sws=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
%         'position',[0.65 0.16  0.2 0.0444],'string',...
%         'Shortwave stirring','fontsize',10,'value',1,...
%         'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
%         'tooltipstring',sprintf('key: sws'));
    handles{5,6}=[handles{5,6} ST_panel wformT_ST waveform formT_ST...
        form thetanumT_ST thetanum z0T_ST z0T_ST2 ...
        z0 facslT_ST facsl BRfacT_ST BRfac ...
        rhosT_ST rhos porT_ST por smaxT_ST smax...
        tsfacT_ST tsfac facuaT_ST facua d50T D50 d90T D90 lws sws...
        structT struct nelayerT ne_layer ne_layerPB];
    globalhand{1,10}={z0; facsl; BRfac; rhos;	por; tsfac; facua; waveform; form; thetanum; smax};
end

function morphoTAB(varargin) % INCOMPLETE - TO REVISE (MULTIPLE SEDIMENT)
global handles figurehandleX cor kt morphoclock tab_morphoUP...
    tab_constants tab_flow tab_wave tab_wind tab_sed_transp...
    morfac morstart wetslp dryslp...
    hswitch morfacopt sourcesink globalhand

morphoclock=datenum(clock);
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
for k=1:kt
    for g=1:length(handles(:,1))
        if ~isempty('handles'); aux=handles{g,k}; set(aux,'visible','off'); end
    end
end
set(handles{5,1},'visible','on'); set(handles{5,7},'visible','on');
if ishghandle(tab_sed_transp)
    set([tab_constants,tab_flow,tab_wave,tab_wind,tab_sed_transp],...
        'foregroundcolor','k'); set(tab_morphoUP,'foregroundcolor','b');
else
    set([tab_constants,tab_flow,tab_wave,tab_wind],...
        'foregroundcolor','k'); set(tab_morphoUP,'foregroundcolor','b');
end
if isempty(handles{5,7})
    fig=getappdata(figurehandleX,'figurehandle');
    morpho_panel=uipanel('unit','normalized','parent',fig,'Title',...
        'Morphological Update and Avalanching','fontsize',8,...
        'position',[0.24 0.38  0.7 0.55],'backgroundcolor',cor);
    morfacT_mua=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.83  0.6 0.0444],'string',...
        'Morfological Factor                                                                         [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('key: morfac'));
    morfac=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.7 0.841 0.10 0.04],'string','1','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    morstartT_mua=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.76  0.6 0.0444],'string',...
        'Start time of morfological updates                                                  [s]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('key: morstart'));
    morstart=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.7 0.771 0.10 0.04],'string','120','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    morfacoptT_mua=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.69  0.6 0.0444],'string',...
        'Type of morfac update (see manual pag. 38)                                  [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('key: morfacopt'));
    morfacopt=uicontrol('unit','normalized','parent',fig,'style','popup',...
        'position',[0.7 0.701 0.10 0.04],'value',2,...
        'string','Off|On','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    skT_mua=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.62  0.6 0.0444],'string',...
        'Type of morphological update                                                        [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('0 = gradient\n1 = source/sink\nkey: sourcesink'));
    sourcesink=uicontrol('unit','normalized','parent',fig,'style','popup',...
        'position',[0.65 0.631 0.15 0.04],'value',1,...
        'string','Gradient|Source/Sink','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    wetslpT_mua=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.55  0.6 0.0444],'string',...
        'Critical avalanching slope under water                                          [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Min: 0.1\nMax: 1\nkey: wetslp'));
    wetslp=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.7 0.561 0.10 0.04],'string','0.3','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    dryslpT_mua=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.48  0.6 0.0444],'string',...
        'Critical avalanching slope above water                                         [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Min: 0.1\nMax: 2\nkey: dryslp'));
    dryslp=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.7 0.491 0.10 0.04],'string','1','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    hswitchT_mua=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.41  0.6 0.0444],'string',...
        'Water depth at interface above/below slope                                  [-]','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left',...
        'tooltipstring',sprintf('Min: 0.01\nMax: 1\nkey: hswitch'));
    hswitch=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.7 0.421 0.10 0.04],'string','0.1','fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'SelectionHighlight','on',...
        'horizontalalignment','right');
    handles{5,7}=[handles{5,7} morpho_panel morfacT_mua morfac ...
        morstartT_mua morstart morfacoptT_mua morfacopt...
        skT_mua sourcesink wetslpT_mua wetslp dryslpT_mua ...
        dryslp hswitchT_mua hswitch];
    globalhand{1,11}={morfac; morstart; wetslp; dryslp; hswitch; morfacopt; sourcesink};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          Main Button Boundaries                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function boundaries_button(varargin) % INCOMPLETE - TO REVISE (BOUNDARIES)
global handles figurehandleX cor kt handles_MB flowbound_PB wavebound_PB...
    flow_bound_clock wave_bound_clock
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
set(handles_MB,'foregroundcolor','k'); set(handles_MB(6),'foregroundcolor','b');
for k=1:kt
    for g=1:length(handles(:,1))
        if ~isempty('handles'); aux=handles{g,k}; set(aux,'visible','off'); end
    end
end
set(handles{6,1},'visible','on');
if exist('flow_bound_clock','var') & ~exist('wave_bound_clock','var');
    set(handles{6,2},'visible','on');
elseif exist('wave_bound_clock','var') & ~exist('flow_bound_clock','var');
    set(handles{6,3},'visible','on');
elseif exist('flow_bound_clock','var') & exist('wave_bound_clock','var');
    aux=max([flow_bound_clock wave_bound_clock]);
    if aux==flow_bound_clock; set(handles{6,2},'visible','on'); elseif aux==wave_bound_clock; set(handles{6,3},'visible','on'); end
end
if isempty(handles{6,1})
    fig=getappdata(figurehandleX,'figurehandle');
    boundaries_panel=uipanel('unit','normalized','parent',fig,'Title',...
        'Boundaries Conditions','fontsize',8,...
        'position',[0.24 0.855  0.7 0.125],'backgroundcolor',cor);
    flowbound_PB=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',[0.30 0.89  0.25 0.0444],'string',...
        'Flow Boundaries','fontsize',10,...
        'fontw','bold','horizontalalignment','center',...
        'callback',@flow_bound);
    wavebound_PB=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',[0.63 0.89  0.25 0.0444],'string',...
        'Wave Boundaries','fontsize',10,...
        'fontw','bold','horizontalalignment','center',...
        'callback',@wave_bound);
    handles{6,1}=[handles{6,1} boundaries_panel flowbound_PB wavebound_PB];
end

function flow_bound(varargin)
global handles figurehandleX cor kt flow_bound_clock flowbound_PB wavebound_PB...
    fbound1_Pop fbound1_PopCon fbound2_Pop fbound2_PopCon fbound3_Pop fbound3_PopCon...
    fbound4_Pop fbound4_PopCon B01 B2 UISAVE UISAVEAS boundariesF_panel boundariesW_panel ...
    globalhand
set(flowbound_PB,'foregroundcolor','b'); set(wavebound_PB,'foregroundcolor','k');
flow_bound_clock=datenum(clock);
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
for k=1:kt
    for g=1:length(handles(:,1))
        if ~isempty('handles'); aux=handles{g,k}; set(aux,'visible','off'); end
    end
end
set(handles{6,1},'visible','on'); set(handles{6,2},'visible','on');
if isempty(handles{6,2})
    fig=getappdata(figurehandleX,'figurehandle');
    boundariesF_panel=uipanel('unit','normalized','parent',fig,'Title',...
        'Specify Flow Boundaries','fontsize',8,...
        'position',[0.24 0.4  0.7 0.4],'backgroundcolor',cor);
    fboundary=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.475 0.71  0.16 0.0444],'string',...
        'Boundary','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
    fboundaryCond=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.69 0.71  0.16 0.0444],'string',...
        'Boundary Condition','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
    fbound1T=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.65  0.16 0.0444],'string',...
        'Boundary 1','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
    fbound1_PopCon=uicontrol('unit','normalized','parent',fig,'style','popup',...
        'position',[0.7 0.655  0.14 0.0444],'string',...
        'None|abs_1d|abs_2d|wall|wlevel|nonh_1d','Enable','on',...
        'fontsize',10,'backgroundcolor',[1 1 1],'value',2,...
        'fontw','bold','horizontalalignment','center'); B01=1;
    fbound1_Pop=uicontrol('unit','normalized','parent',fig,'style','popup',...
        'position',[0.45 0.655  0.14 0.0444],'value',1,'string',...
        'front|ARC|order|carspan|back|left|right|epsi',...
        'fontsize',10,'backgroundcolor',[1 1 1],...
        'fontw','bold','horizontalalignment','center','callback',@fbound00_Cond); %}
    B2=5;
    fbound2T=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.58  0.16 0.0444],'string',...
        'Boundary 2','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
    fbound2_PopCon=uicontrol('unit','normalized','parent',fig,'style','popup',...
        'position',[0.7 0.585  0.14 0.0444],'string',...
        'None|wall|abs_1d|abs_2d|wlevel','Enable','on',...
        'fontsize',10,'backgroundcolor',[1 1 1],'value',2,...
        'fontw','bold','horizontalalignment','center');
    fbound2_Pop=uicontrol('unit','normalized','parent',fig,'style','popup',...
        'position',[0.45 0.585  0.14 0.0444],'string',...
        'front|ARC|order|carspan|back|left|right|epsi','value',5,...
        'fontsize',10,'backgroundcolor',[1 1 1],...
        'fontw','bold','horizontalalignment','center','callback',@fbound00_Cond);
    fbound3T=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.51  0.16 0.0444],'string',...
        'Boundary 3','fontsize',10,'foregroundcolor',[.5 .5 .5],...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left','enable','off');
    fbound3_Pop=uicontrol('unit','normalized','parent',fig,'style','popup',...
        'position',[0.45 0.515  0.14 0.0444],'string',...
        'None|front|ARC|order|carspan|back|left|right|epsi',...
        'fontsize',10,'foregroundcolor',[.5 .5 .5],...
        'fontw','bold','horizontalalignment','center','callback',@fbound00_Cond,'enable','on');
    fbound3_PopCon=uicontrol('unit','normalized','parent',fig,'style','popup',...
        'position',[0.7 0.515  0.14 0.0444],'string',...
        'None','Enable','off',...
        'fontsize',10,'backgroundcolor',[1 1 1],...
        'fontw','bold','horizontalalignment','center');
    fbound4T=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.30 0.44  0.16 0.0444],'string',...
        'Boundary 4','fontsize',10,'foregroundcolor',[.5 .5 .5],...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left','enable','off');
    fbound4_Pop=uicontrol('unit','normalized','parent',fig,'style','popup',...
        'position',[0.45 0.445  0.14 0.0444],'string',...
        'None|front|ARC|order|carspan|back|left|right|epsi',...
        'fontsize',10,'foregroundcolor',[.5 .5 .5],...
        'fontw','bold','horizontalalignment','center','callback',@fbound00_Cond,'enable','on');
    fbound4_PopCon=uicontrol('unit','normalized','parent',fig,'style','popup',...
        'position',[0.7 0.445  0.14 0.0444],'string',...
        'None','Enable','off',...
        'fontsize',10,'backgroundcolor',[1 1 1],...
        'fontw','bold','horizontalalignment','center');
    handles{6,2}=[handles{6,2} boundariesF_panel fboundary fboundaryCond fbound1T ...
        fbound1_Pop fbound1_PopCon fbound2T fbound2_Pop fbound2_PopCon fbound3T...
        fbound3_Pop fbound3_PopCon fbound4T fbound4_Pop fbound4_PopCon];
    if ishghandle(boundariesW_panel) & ishghandle(boundariesF_panel);
        set([UISAVE,UISAVEAS],'enable','on');
    end
    
    globalhand{1,12}={fbound1_PopCon; fbound2_PopCon};
end

function fbound00_Cond(hObj,varargin)
global figurehandleX fbound1_Pop fbound1_PopCon fbound2_Pop fbound2_PopCon ...
        fbound3_Pop fbound3_PopCon fbound4_PopCon
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
if hObj==fbound1_Pop
    pop=fbound1_PopCon; n0=0;
elseif hObj==fbound2_Pop
    pop=fbound2_PopCon; n0=0;
elseif hObj==fbound3_Pop
    pop=fbound3_PopCon; n0=1;
elseif hObj==fbound4_PopC
    pop=fbound4_PopCon; n0=1;
end

if get(hObj,'value')== 1+n0 %front
    set(pop,'enable','on','backgroundcolor',[1 1 1],'string',...
        'None|abs_1d|abs_2d|wall|wlevel|nonh_1d','value',2);
elseif get(hObj,'value')== 2+n0 %ARC
    set(pop,'enable','on','backgroundcolor',[1 1 1],'string',...
        'On|Off','value',1);
elseif get(hObj,'value')== 3+n0 %order
    set(pop,'enable','on','backgroundcolor',[1 1 1],'string',...
        '2nd order|1st order','value',1);
elseif get(hObj,'value')== 4+n0 %carspan
    set(pop,'enable','on','backgroundcolor',[1 1 1],'string',...
        '0 (manual)|1 (manual)','value',1);
elseif get(hObj,'value')== 5+n0 %back
    set(pop,'enable','on','backgroundcolor',[1 1 1],'string',...
        'None|wall|abs_1d|abs_2d|wlevel','value',2);
elseif get(hObj,'value')== 6+n0 %left
    set(pop,'enable','on','backgroundcolor',[1 1 1],'string',...
        'neumann|wall','value',1);
elseif get(hObj,'value')== 7+n0 %right
    set(pop,'enable','on','backgroundcolor',[1 1 1],'string',...
        'neumann|wall','value',1);
elseif get(hObj,'value')== 8+n0 %epsi
    set(pop,'enable','on','backgroundcolor',[1 1 1],'string',...
        'Obsolete (man.)','value',1);
end

function wave_bound(varargin)
global handles figurehandleX cor kt wave_bound_clock flowbound_PB wavebound_PB ...
    instat bcfile wfile_open boundariesW_panel wboundaryI UISAVE UISAVEAS...
    boundariesF_panel
set(flowbound_PB,'foregroundcolor','k'); set(wavebound_PB,'foregroundcolor','b');
wave_bound_clock=datenum(clock);
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
for k=1:kt
    for g=1:length(handles(:,1))
        if ~isempty('handles'); aux=handles{g,k}; set(aux,'visible','off'); end
    end
end
set(handles{6,1},'visible','on'); set(handles{6,3},'visible','on');
if isempty(handles{6,3})
    fig=getappdata(figurehandleX,'figurehandle');
    boundariesW_panel=uipanel('unit','normalized','parent',fig,'Title',...
        'Specify Wave Boundaries','fontsize',8,...
        'position',[0.24 0.25  0.7 0.55],'backgroundcolor',cor);
    wboundaryI=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.26 0.7  0.1 0.0444],'string','Instat =',...
        'backgroundcolor',cor,'fontsize',10,...
        'fontw','bold' ,'horizontalalignment','left');
    bcfile=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.57 0.635  0.35 0.0355],'string','Filename Unknown','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left','enable','off');
    wfile_open=uicontrol('unit','normalized','parent',fig,'style','pushbutton',...
        'position',[0.3 0.64  0.25 0.0355],'string','Open BCfile','fontsize',10,...
        'fontw','bold','callback',@wave_boundaryFILE,'max',1,'enable','off');
    instat=uicontrol('unit','normalized','parent',fig,'style','popup',...
        'position',[0.34 0.705  0.57 0.0444],'value',1,'string',...
        ['None|0 - Stationary wave boundary condition (sea state)|',...
        '1 - Bichromatic (two wave component) waves|',...
        '2 - First-order timeseries of wave (outside XBeach)|',...
        '3 - Second-order timeseries of wave (outside XBeach)|',...
        '4 - Wave groups generated using a parametric (Jonswap) spectrum)|',...
        '5 - Wave groups generated using a SWAN 2D output file|',...
        '6 - Wave groups generated using a formated file|',...
        '7 - Reuse of wave conditions|',...
        '8 - Boundary conditions for nonhydrostatic option|',...
        '9 - No wave boundary conditions|',...
        '40 - A sequence of stationary conditions (sea states)|',...
        '41 - A sequence of time-varying wave groups'],'fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'horizontalalignment','left',...
        'callback',@wave_tables);
    
    if ishghandle(boundariesW_panel) & ishghandle(boundariesF_panel);
        set([UISAVE,UISAVEAS],'enable','on');
    end
    handles{6,3}=[handles{6,3} boundariesW_panel wboundaryI bcfile wfile_open instat];
end

function wave_tables(varargin)
global handles figurehandleX cor kt instat bcfile wfile_open jon_table...
    boundariesW_panel wboundaryI
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
fig=getappdata(figurehandleX,'figurehandle');
h=get(instat,'value');
if h==6 | h==13
    set([bcfile,wfile_open],'enable','on');
    if h==6
        jonT={'Hm0';'fp';'mainang';'gammajsp';'s';'fnyq'};
        for g=1:6; jonT{g,2}='';end;
        if ishghandle(jon_table)
            delete(jon_table);
        end
        jon_table=uitable('unit','normalized','parent',fig,'data',jonT,...
            'ColumnName',{'Parameter','Value'},'RowName',[],...
            'position',[0.5 0.3 0.19 0.3],'fontsize',10,...
            'columnformat',{'char','numeric'},'columneditable',...
            [false true],'ColumnWidth','auto');
    elseif h==13
        jonT={'Hm0','Tp','Angle','Gamma','Spreading','Duration(s)','Timestep'};
        for g=2:5; for k=1:7; jonT{g,k}='';end;end;
        if ishghandle(jon_table)
            delete(jon_table);
        end
        jon_table=uitable('unit','normalized','parent',fig,'data',jonT(2:5,:),...
            'ColumnName',jonT(1,:),'RowName',[],...
            'position',[0.26 0.3 0.662 0.3],'fontsize',10,...
            'columnformat',{'numeric','numeric','numeric','numeric','numeric','numeric','numeric'},...
            'columneditable',[true true true true true true true],'ColumnWidth','auto');
    end
    handles{6,3}=[boundariesW_panel wboundaryI instat jon_table wfile_open bcfile];
elseif h~=6 | h~=13
    if ishghandle(jon_table)
        delete(jon_table);
    end
    set([bcfile,wfile_open],'enable','off');
    set(bcfile,'string','Filename Unknown');
end

function wave_boundaryFILE(varargin)
global handles figurehandleX cor kt instat bcfile wfile_open boundariesW_panel...
    wboundaryI jon_table
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
fig=getappdata(figurehandleX,'figurehandle');
if get(instat,'value')==6
    [file,path]=uigetfile({'*.*','jonswap (*.*)'},'Pick a BCfile');
    if file==0
        set(bcfile,'String','Filename Unknown');
    else
        fid=fopen([path,file]);
        jon=fread(fid,'*char'); jon=strread(jon,'%s','whitespace','\b');
        if size(jon,1)>=3
            for g=1:size(jon,1)
                aux=strfind(jon{g,1},'=');
                jonT{g,1}=jon{g,1}(1:aux-1); jonT{g,2}=str2num(jon{g,1}(aux+1:end));
            end
            if ishghandle(jon_table)
                delete(jon_table);
            end
            jon_table=uitable('unit','normalized','parent',fig,'data',jonT,...
                'ColumnName',{'Parameter','Value'},'RowName',[],...
                'position',[0.5 0.3 0.19 0.3],'fontsize',10,...
                'columnformat',{'char','numeric'},'columneditable',...
                [false true],'ColumnWidth','auto');
            fclose(fid);
            set(bcfile,'string',file);
            handles{6,3}=[boundariesW_panel wboundaryI instat jon_table wfile_open bcfile];
        else
            alertFigure('File not Supported!')
        end
    end
elseif get(instat,'value')==13
    [file,path]=uigetfile({'*.lst;*.txt','Jonswap Files (*.lst,*.txt)'},'Pick a BCfile');
    if file==0
        set(bcfile,'String','Filename Unknown');
    else       
        fid=fopen([path,file]);
        jon=fread(fid,'*char'); jon=strread(jon,'%s','whitespace','\b');
        jonTc={'Hm0','Tp','Angle','Gamma','Spreading','Duration(s)','Timestep'};
        if size(jon,1)>=3
            for g=1:size(jon,1)
                aux=strfind(jon{g,1},' '); k=1;
                while k<=length(aux)-1
                    if aux(k+1) - aux(k)>3
                        if k==1
                            jonT{g,k}=str2num(jon{g,1}(1:aux(k)-1));
                        else
                            jonT{g,k}=str2num(jon{g,1}(aux(k)+1:aux(k+1)-1));
                        end
                        k=k+1;
                    else
                        if k==1
                            jonT{g,k}=str2num(jon{g,1}(1:aux(k+1)-1));
                        else
                            jonT{g,k}=str2num(jon{g,1}(aux(k)+1:aux(k+2)-1));
                        end
                        k=k+1;
                    end
                end
            end
            if ishghandle(jon_table)
                delete(jon_table);
            end
            
            jon_table=uitable('unit','normalized','parent',fig,'data',jonT(1:end,:),...
                'ColumnName',jonTc(1,:),'RowName',[],...
                'position',[0.26 0.3 0.662 0.3],'fontsize',10,...
                'columnformat',{'numeric','numeric','numeric','numeric','numeric','numeric','numeric'},...
                'columneditable',[true true true true true true true],'ColumnWidth','auto');
            fclose(fid);
            set(bcfile,'string',file);
            handles{6,3}=[boundariesW_panel wboundaryI instat jon_table wfile_open bcfile];
        else
            alertFigure('File not Supported!')
        end
    end
end

%
% function openENC(varargin)
% global d3denT_open
% [file]=uigetfile({'*.enc','Enclosure (*.enc)'},'Pick a File');
% if file==0
%     set(d3denT_open,'String','Filename Unknown');
% else
%     set(d3denT_open,'String',file);
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        Main Button Output  - INCOMPLETE - TO REVISE (POINT VAR.)       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output_button(varargin)
global handles figurehandleX cor kt handles_MB MB_out tstop aux1 stop_time_T...
    handles_Glob handles_Tavg handles_Point outGlob_CB outTimeAvg_CB output_Tavgpanel...
    output_Globpanel output_Pointpanel ...
    outPoint_CB outGlobAll_CB outGlobZb_CB outGlobZs_CB...
    outGlobH_CB outGlobEu_CB outGlobthMean_CB outGlobsedero_CB outGlobdzav_CB...
    outGlobsusg_CB outGlobsvsg_CB outGlobsubg_CB outGlobsvbg_CB...
    outTavgAll_CB outTavgbH_CB outTavgEu_CB...
    outTavgsusg_CB outTavgsvsg_CB outTavgsubg_CB outTavgsvbg_CB...
    outPointAll_CB outPointzs_CB outPointH_CB outPointEu_CB...
    outGlobINTERV_T tintg outTavgINTERV_T tintm...
    outPointINTERV_T tintp start_time_T tstart outputformat
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
set(handles_MB,'foregroundcolor','k'); set(handles_MB(9),'foregroundcolor','b');
for k=1:kt
    for g=1:length(handles(:,1))
        if ~isempty('handles'); aux=handles{g,k}; set(aux,'visible','off'); end
    end
end
if ~isempty(aux1) & strcmp(get(tstop,'string'),aux1)==0
    set(stop_time_T,'string',['Stop Time:  ',get(tstop,'string'),'  [s]']);
end
set(handles{9,1},'visible','on');
if isempty(handles{9,1})
    fig=getappdata(figurehandleX,'figurehandle');
    output_panel=uipanel('unit','normalized','parent',fig,'Title',...
        'Output Configuration','fontsize',8,...
        'position',[0.24 0.31  0.7 0.67],'backgroundcolor',cor);
    output_Globpanel=uipanel('unit','normalized','parent',fig,'Title',...
        'Global Variables','fontsize',8,'foregroundcolor',[.5 .5 .5],...
        'position',[0.28 0.37  0.285 0.435],'backgroundcolor',cor);
    output_Tavgpanel=uipanel('unit','normalized','parent',fig,'Title',...
        'Time-Averaged Variables','fontsize',8,'foregroundcolor',[.5 .5 .5],...
        'position',[0.61 0.53  0.285 0.275],'backgroundcolor',cor);
    output_Pointpanel=uipanel('unit','normalized','parent',fig,'Title',...
        'Point Variables','fontsize',8,'foregroundcolor',[.5 .5 .5],...
        'position',[0.61 0.335  0.285 0.185],'backgroundcolor',cor);
    outForm_T=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.28 0.88  0.2 0.0444],'string',...
        'Output Format','fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
    outputformat=uicontrol('unit','normalized','parent',fig,'style','popup',...
        'position',[0.42 0.888  0.1 0.0444],'value',2,'string',...
        'None|netcdf','fontsize',10,'backgroundcolor',[1 1 1],...
        'fontw','bold','horizontalalignment','center');
    start_time_T=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.54 0.88  0.2 0.0444],'string',...
        ['Start Time:            [s]'],'fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left');
    tstart=uicontrol('unit','normalized','parent',fig','style','edit',...
        'position',[0.633 0.888  0.05 0.0444],'string',...
        ['0'],'fontsize',10,...
        'fontw','bold','backgroundcolor',[1 1 1],'horizontalalignment','right');
    stop_time_T=uicontrol('unit','normalized','parent',fig','style','text',...
        'position',[0.73 0.88  0.2 0.0444],'string',...
        ['Stop Time:  ',get(tstop,'string'),'  [s]'],'fontsize',10,...
        'fontw','bold','backgroundcolor',cor,'horizontalalignment','left'); aux1=get(tstop,'string');
    outGlob_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.30 0.825  0.2 0.0444],'string',...
        'Global variables','fontsize',10,'backgroundcolor',cor,...
        'fontw','bold','horizontalalignment','left','callback',@globalVars);
    outTimeAvg_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.473 0.825  0.3 0.0444],'string',...
        'Time-Averaged Global variables','fontsize',10,'backgroundcolor',cor,...
        'fontw','bold','horizontalalignment','left','callback',@globalVars);
    outPoint_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.77 0.825  0.15 0.0444],'string',...
        'Point variables','fontsize',10, 'fontw','bold','backgroundcolor',cor,...
        'horizontalalignment','left','enable','off','callback',@define_outPoint);
    
    outGlobAll_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.38 0.745  0.13 0.04],'string',...
        'Save all','fontsize',10,'backgroundcolor',cor,'enable','off',...
        'fontw','bold','horizontalalignment','left','callback',@globalVars);
    outGlobZb_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.30 0.715  0.2 0.037],'value',1,'string',...
        'Bed Level','fontsize',8,'backgroundcolor',cor,'enable','off',...
        'fontw','normal','horizontalalignment','left','callback','');
    outGlobZs_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.30 0.685  0.2 0.037],'value',1,'string',...
        'Water Level','fontsize',8,'backgroundcolor',cor,'enable','off',...
        'fontw','normal','horizontalalignment','left','callback','');
    outGlobH_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.30 0.655  0.2 0.037],'value',1,'string',...
        'Wave height','fontsize',8,'backgroundcolor',cor,'enable','off',...
        'fontw','normal','horizontalalignment','left','callback','');
    outGlobEu_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.30 0.625  0.25 0.037],'value',1,'enable','off','string',...
        'Eulerian mean x/y velocity cell center','fontsize',8,'backgroundcolor',cor,...
        'fontw','normal','horizontalalignment','left','callback','');
    outGlobthMean_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.30 0.595  0.2 0.037],'value',1,'string',...
        'Mean wave angle','fontsize',8,'backgroundcolor',cor,'enable','off',...
        'fontw','normal','horizontalalignment','left','callback','');
    outGlobsedero_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.30 0.565  0.2 0.037],'value',1,'string',...
        'Cum. sedimentation/erosion','fontsize',8,'backgroundcolor',cor,'enable','off',...
        'fontw','normal','horizontalalignment','left','callback','');
    outGlobdzav_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.30 0.535  0.23 0.037],'value',1,'enable','off','string',...
        'Bed level change due avalanching','fontsize',8,'backgroundcolor',cor,...
        'fontw','normal','horizontalalignment','left','callback','');
    outGlobsusg_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.30 0.505  0.23 0.037],'value',1,'enable','off','string',...
        'Suspended sediment transport (u)','fontsize',8,'backgroundcolor',cor,...
        'fontw','normal','horizontalalignment','left','callback','');
    outGlobsvsg_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.30 0.475  0.23 0.037],'value',1,'enable','off','string',...
        'Suspended sediment transport (v)','fontsize',8,'backgroundcolor',cor,...
        'fontw','normal','horizontalalignment','left','callback','');
    outGlobsubg_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.30 0.445  0.23 0.037],'value',1,'enable','off','string',...
        'Bed sediment transport (u)','fontsize',8,'backgroundcolor',cor,...
        'fontw','normal','horizontalalignment','left','callback','');
    outGlobsvbg_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.30 0.415  0.23 0.037],'value',1,'enable','off','string',...
        'Bed sediment transport (v)','fontsize',8,'backgroundcolor',cor,...
        'fontw','normal','horizontalalignment','left','callback','');
    outGlobINTERV_T=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.32 0.379  0.2 0.03],'enable','off','string',...
        'Interval output (s)','fontsize',9,'backgroundcolor',cor,...
        'fontw','bold','horizontalalignment','left','tooltipstring','tintg');
    tintg=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.45 0.38  0.08 0.03],'enable','off','string',...
        '60','fontsize',9,'backgroundcolor',[1 1 1],...
        'fontw','bold','horizontalalignment','right','callback','');    
    handles_Glob=[outGlobAll_CB outGlobZb_CB outGlobZs_CB outGlobH_CB outGlobEu_CB ...
        outGlobthMean_CB  outGlobsedero_CB  outGlobdzav_CB...
        outGlobINTERV_T tintg outGlobsusg_CB outGlobsvsg_CB outGlobsubg_CB outGlobsvbg_CB];
    
    outTavgAll_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.69 0.745  0.13 0.04],'string',...
        'Save all','fontsize',10,'backgroundcolor',cor,'enable','off',...
        'fontw','bold','horizontalalignment','left','callback',@globalVars);
    outTavgbH_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.63 0.715  0.2 0.037],'value',1,'string',...
        'Wave height','fontsize',8,'backgroundcolor',cor,'enable','off',...
        'fontw','normal','horizontalalignment','left','callback','');
    outTavgEu_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.63 0.685  0.25 0.037],'value',1,'enable','off','string',...
        'Eulerian mean x/y velocity cell center','fontsize',8,'backgroundcolor',cor,...
        'fontw','normal','horizontalalignment','left','callback','');
    outTavgsusg_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.63 0.655  0.23 0.037],'value',1,'enable','off','string',...
        'Suspended sediment transport (u)','fontsize',8,'backgroundcolor',cor,...
        'fontw','normal','horizontalalignment','left','callback','');
    outTavgsvsg_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.63 0.625  0.23 0.037],'value',1,'enable','off','string',...
        'Suspended sediment transport (v)','fontsize',8,'backgroundcolor',cor,...
        'fontw','normal','horizontalalignment','left','callback','');
    outTavgsubg_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.63 0.595  0.23 0.037],'value',1,'enable','off','string',...
        'Bed sediment transport (u)','fontsize',8,'backgroundcolor',cor,...
        'fontw','normal','horizontalalignment','left','callback','');
    outTavgsvbg_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.63 0.565  0.23 0.037],'value',1,'enable','off','string',...
        'Bed sediment transport (v)','fontsize',8,'backgroundcolor',cor,...
        'fontw','normal','horizontalalignment','left','callback','');
    outTavgINTERV_T=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.65 0.539  0.2 0.03],'enable','off','string',...
        'Interval output (s)','fontsize',9,'backgroundcolor',cor,...
        'fontw','bold','horizontalalignment','left','tooltipstring','tintg');
    tintm=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.78 0.54  0.08 0.03],'enable','off','string',...
        '3600','fontsize',9,'backgroundcolor',[1 1 1],...
        'fontw','bold','horizontalalignment','right','callback','');
    handles_Tavg=[outTavgAll_CB outTavgbH_CB outTavgEu_CB outTavgINTERV_T tintm...
        outTavgsusg_CB outTavgsvsg_CB outTavgsubg_CB outTavgsvbg_CB];
    
    outPointAll_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.69 0.46  0.13 0.04],'string',...
        'Save all','fontsize',10,'backgroundcolor',cor,'enable','off',...
        'fontw','bold','horizontalalignment','left','callback','');
    outPointzs_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.63 0.44  0.2 0.029],'string',...
        'Water level','fontsize',8,'backgroundcolor',cor,'enable','off',...
        'fontw','normal','horizontalalignment','left','callback','');
    outPointH_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.63 0.409  0.2 0.033],'string',...
        'Wave height','fontsize',8,'backgroundcolor',cor,'enable','off',...
        'fontw','normal','horizontalalignment','left','callback','');
    outPointEu_CB=uicontrol('unit','normalized','parent',fig,'style','checkbox',...
        'position',[0.63 0.38  0.25 0.033],'enable','off','string',...
        'Eulerian mean x/y velocity cell center','fontsize',8,'backgroundcolor',cor,...
        'fontw','normal','horizontalalignment','left','callback','');
    outPointINTERV_T=uicontrol('unit','normalized','parent',fig,'style','text',...
        'position',[0.65 0.344  0.2 0.03],'enable','off','string',...
        'Interval output (s)','fontsize',9,'backgroundcolor',cor,...
        'fontw','bold','horizontalalignment','left','tooltipstring','tintg');
    tintp=uicontrol('unit','normalized','parent',fig,'style','edit',...
        'position',[0.78 0.345  0.08 0.03],'enable','off','string',...
        '2','fontsize',9,'backgroundcolor',[1 1 1],...
        'fontw','bold','horizontalalignment','right','callback','');    
    handles_Point=[outPointAll_CB outPointzs_CB outPointH_CB outPointEu_CB outPointINTERV_T...
        tintp];
    
    handles{9,1}=[handles{9,1} output_panel outForm_T outputformat stop_time_T ...
        outGlob_CB outTimeAvg_CB outPoint_CB handles_Glob handles_Tavg handles_Point...
        output_Pointpanel output_Tavgpanel output_Globpanel start_time_T tstart];
end

function globalVars(hObj,event)
global output_Globpanel handles_Glob outGlob_CB outTimeAvg_CB figurehandleX...
    outGlobZb_CB outGlobZs_CB outGlobH_CB outGlobEu_CB ...
    outGlobthMean_CB  outGlobsedero_CB  outGlobdzav_CB outGlobsusg_CB outGlobsvsg_CB...
    outGlobsubg_CB outGlobsvbg_CB...
    output_Tavgpanel handles_Tavg outTavgbH_CB outTavgEu_CB ...
    outTavgsusg_CB outTavgsvsg_CB outTavgsubg_CB outTavgsvbg_CB outTavgAll_CB outGlobAll_CB
glob_hand=[outGlobZb_CB outGlobZs_CB outGlobH_CB outGlobEu_CB ...
    outGlobthMean_CB  outGlobsedero_CB  outGlobdzav_CB ...
    outGlobsusg_CB outGlobsvsg_CB outGlobsubg_CB outGlobsvbg_CB];
time_hand=[outTavgbH_CB outTavgEu_CB outTavgsusg_CB outTavgsvsg_CB outTavgsubg_CB outTavgsvbg_CB];
set(figurehandleX,'name',['XBeach GUI  --  ',fsize(pwd),'*']);
if hObj==outGlob_CB
    if get(outGlob_CB,'value')==1;
        set(handles_Glob,'enable','on');
        set(output_Globpanel,'foregroundcolor',[0 0 0]);
        set(glob_hand,'value',1); set(outGlobAll_CB,'value',0);
    elseif get(outGlob_CB,'value')==0;
        set(handles_Glob,'enable','off');
        set(output_Globpanel,'foregroundcolor',[.5 .5 .5]);
    end
elseif hObj == outTimeAvg_CB
    if get(outTimeAvg_CB,'value')==1;
        set(handles_Tavg,'enable','on');
        set(output_Tavgpanel,'foregroundcolor',[0 0 0]);
        set([outTavgbH_CB outTavgEu_CB],'value',1); set(outTavgAll_CB,'value',0);
    elseif get(outTimeAvg_CB,'value')==0;
        set(handles_Tavg,'enable','off');
        set(output_Tavgpanel,'foregroundcolor',[.5 .5 .5]);
    end
elseif hObj == outGlobAll_CB
    if get(outGlobAll_CB,'value')==1
        set(glob_hand,'value',0);
    elseif get(outGlobAll_CB,'value')==0
        set(glob_hand,'value',1);
    end
elseif hObj == outTavgAll_CB
    if get(outTavgAll_CB,'value')==1
        set(time_hand,'value',0);
    elseif get(outTavgAll_CB,'value')==0
        set(time_hand,'value',1);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          Visualization Area                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function viewarea(varargin)
global cor xgrid ygrid B1 ax1 PLOT_LDB clrmap_choose fViewarea K h2 h1 ...
    caxisMIN caxisMAX gr01 gr02 LDB1 statusbarFvArea fileD pathD xyfile depfile ...
    d3ddepTMax_open d3ddepValueMax_open d3ddepValueMin_open auxG hPc pathG ...
    notifyText measureText countParB
if ~isempty(fViewarea) & ishghandle(fViewarea)
    figure(fViewarea);
else
    countParB = 1;
    buttons={'New Figure','Open File','Edit Plot','Save Figure','Print Figure','Hide Plot Tools',...
        'Show Plot Tools','Insert Legend','Data Cursor','Rotate 3D',...
        'Brush/Select Data','Link Plot','Show Plot Tools and Dock Figure'};
    % buttons={'New Figure','Open File','Save Figure','Print Figure','Hide Plot Tools',...
    %     'Show Plot Tools','Insert Legend','Insert Colorbar','Data Cursor','Rotate 3D',...
    %     'Brush/Select Data','Link Plot','Show Plot Tools and Dock Figure'};
    % buttons={'Pan','Edit Plot','Zoom in','Zoom Out'};
    width=400; height=250; set(0, 'Units', 'points'); pos=get(0,'screensize');
    %figure('visible','off'); set(gcf,'WVisual','00'); close;
    fViewarea = figure('Units', 'points','WindowStyle', 'normal', ...
        'Position', [pos(3)/2-width/2 pos(4)/2-height/2 width height],'NumberTitle','off',...
        'Tag','ViewArea','Interruptible', 'on',...
        'DockControls', 'off','Visible','on','name','Domain View','color',cor,...
        'ResizeFcn','','KeyPressFcn',@move_axis_key,...
        'WindowKeyPressFcn',@ctrl_move_axes,'CloseRequestFcn', @myclosereq);
    set(fViewarea,'renderer','OpenGL','renderermode','manual');
    colordef(fViewarea,'black');
    modifyLogo(fViewarea);
    % uimenu(f,'label','Land Boundary');
    
    % handles uimenu figure
    hUiMenu=get(findall(fViewarea,'type','uimenu'),'tag');
    % handles toolbar tag names
    hToolBar=get(findall(findall(fViewarea,'tag','FigureToolBar')),'tag');
    % set(h2,'visible','on','ClickedCallback',@colorbar_on); K=1;
    % set(h2,'OffCallback',@colorbar_off);
    
    % clear uimenu
    for g=1:length(hUiMenu(:,1));
        aux=findall(fViewarea,'tag',hUiMenu{g,1});
        set(aux,'visible','off');
    end
    
    ax1=axes('DrawMode','fast'); set(ax1, 'LooseInset', [0,0,0,0],'hittest','off');
    Fi=uimenu(fViewarea,'label','File');
    Vi=uimenu(fViewarea,'label','View');
    Ed=uimenu(fViewarea,'label','Settings');
    To=uimenu(fViewarea,'label','Tools');
    clmSET=uimenu(fViewarea,'label','Colormap');
    
    ldbopen=uimenu(Fi,'label','Open Land Boundary','callback',@carregaLDB);
    uimenu(Fi,'label','Refresh Bathymetry','callback',@refreshBathy);
    uimenu(Fi,'label','Exit','callback','closereq');
    
    cSET=uimenu(Ed,'label','Bathymetry Limits','callback',@caxisSET);
    Acolor=uimenu(Ed,'label','Colors');
    uimenu(Acolor,'label','BackGround','callback',@sel_color_bg);
    uimenu(Acolor,'label','Land Boundary','callback',@sel_color_LDB);
    clrmap=uimenu(clmSET,'Label','Colors');
    uimenu(clrmap,'label','Jet','callback','colormap(''jet'')');
    uimenu(clrmap,'label','HSV','callback','colormap(''hsv'')');
    uimenu(clrmap,'label','Hot','callback','colormap(''hot'')');
    uimenu(clrmap,'label','Cool','callback','colormap(''cool'')');
    uimenu(clrmap,'label','Spring','callback','colormap(''spring'')');
    uimenu(clrmap,'label','Summer','callback','colormap(''summer'')');
    uimenu(clrmap,'label','Autumn','callback','colormap(''autumn'')');
    uimenu(clrmap,'label','Winter','callback','colormap(''winter'')');
    uimenu(clrmap,'label','Gray','callback','colormap(''gray'')');
    uimenu(clrmap,'label','Bone','callback','colormap(''bone'')');
    uimenu(clrmap,'label','Copper','callback','colormap(''copper'')');
    uimenu(clrmap,'label','Pink','callback','colormap(''pink'')');
    uimenu(clrmap,'label','Lines','callback','colormap(''lines'')');
    uimenu(clmSET,'label','Invert','callback',...
        'global fViewarea invCLR; colormap(flipud(get(fViewarea,''colormap'')))');
    shadSET=uimenu(Vi,'label','Shading');
    shadSETflat=uimenu(shadSET,'label','Flat','callback','global hPc; shading flat; set(hPc,''edgecolor'',''k'');');
    shadSETinterp=uimenu(shadSET,'label','Interp','callback','global hPc; shading interp; set(hPc,''edgecolor'',''k'');');
    gridIO=uimenu(Vi,'label','Grid');
    uimenu(gridIO,'label','On','callback',...
        'global gr01 gr02;set(gr01,''visible'',''on'');set(gr02,''visible'',''on'')');
    uimenu(gridIO,'label','Off','callback',...
        'global gr01 gr02;set(gr01,''visible'',''off'');set(gr02,''visible'',''off'')');
    B_PROfile=uimenu(Vi,'label','Profile','callback',@PROfile);
    Dpolygon=uimenu(Vi,'label','Polygon','callback',@chamaPolygon);
    
    SESmenu=uimenu(To,'label','Static Equilibrium Shoreline','callback',@SES_analysis);
    % SES_parab=uimenu(SESmenu,'label','Parabolic Shape');
    % SES_hiperb=uimenu(SESmenu,'label','Hiperbolic Shape');
    % SES_bodge=uimenu(SESmenu,'label','Bodge (1998) Shape');
    
    statusbarFvArea=uicontrol('unit','normalized','parent',fViewarea,...
        'style','text','backgroundcolor',cor,'position',[0.4 0 .2 0.04],...
        'string','Xbeach GUI Visualization Area - Waiting');
    set(fViewarea,'toolbar','figure');
    notifyText=uicontrol('unit','normalized','parent',fViewarea,...
        'style','text','backgroundcolor',cor,...
        'string',' ','horizontalalignment','center');
    set(notifyText,'position',[0.5 0.5 0.18 0.04]);
    measureText=uicontrol('unit','normalized','parent',fViewarea,...
        'style','text','backgroundcolor',cor,'position',[0.82 0 0.18 0.037],...
        'string',' ','horizontalalignment','center');
    
    % clear some toolbar buttons
    a=findall(fViewarea);
    for g=1:length(buttons)
        aux=findall(a,'tooltipstring',buttons{g});
        set(aux,'visible','off');
    end
    
    % h1=findall(fViewarea,'tag','FigureToolBar');
    % h2=findall(h1,'tooltipstring','Zoom In');
    set(h2,'RightClickAction','InverseZoom'); fontDefault=get(0,'FactoryAxesFontSize');
    if ~isempty(xgrid) & ~isempty(ygrid)
        if ~isempty(B1);
            hPc=pcolor(xgrid,ygrid,B1); shading interp; axis equal; hold on; colormap(flipud(colormap)); %
            set(hPc,'edgecolor','k'); set(ax1,'color','none'); %colorbar;
            plot(xgrid(1,1),ygrid(1,1),'o','markersize',fontDefault,'markerfacecolor','k',...
                'markeredgecolor','y');
        else
            axis off;
            alertFigure('Load Bathymetry Before!');
        end
    elseif ~isempty(fileD) & ~isempty(pathD)
        if ~isempty(xyfile) & ~isempty(depfile)
            auxG=wlgrid_Xbeach('read',[pathD,get(xyfile,'string')]); xgrid=auxG.X; ygrid=auxG.Y;
            [bathyD3D]=wldep_Xbeach('read',[pathD,get(depfile,'string')],auxG);
            bathyD3D=bathyD3D(1:end-1,1:end-1);
            Bmax=nanmax(bathyD3D(:)); Bmin=nanmin(bathyD3D(:));
            set(depfile,'String',get(depfile,'string'));
            set(d3ddepTMax_open,'enable','on');
            set(d3ddepValueMax_open,'enable','on','string',sprintf('%3.1f',Bmin));
            set(d3ddepValueMin_open,'enable','on','string',sprintf('%3.1f',Bmax));
            B1=bathyD3D; clear bathyD3D auxG;
            
            if ~isempty(B1);
                hPc=pcolor(xgrid,ygrid,B1); shading interp; axis equal; hold on; colormap(flipud(colormap));
                set(hPc,'edgecolor','k');set(ax1,'color','none'); %colorbar;
                plot(xgrid(1,1),ygrid(1,1),'o','markersize',fontDefault,'markerfacecolor','k',...
                    'markeredgecolor','y');
            else
                axis off;
                alertFigure('Load Bathymetry Before!');
            end
        else
            axis off;
            alertFigure('Select Grid and Bathymetry file''s Before!');
        end
        
    else
        axis off;
    end
    set(fViewarea,'ResizeFcn',@maximized_window);
    set(fViewarea,'windowButtonMotionFcn',@mouse_pointer);
    set(fViewarea,'windowButtonUpFcn',@maximized_window);
    set(fViewarea,'WindowScrollWheelFcn',@scroll_zoom_window);
end

function chamaPolygon(src,evnt)
global fViewarea
set(fViewarea,'pointer','cross')
set(fViewarea,'WindowButtonDownFcn',@createPolygon);

function createPolygon(src,evnt)
global ax1 cp hl xinit yinit
if strcmp(get(src,'SelectionType'),'normal')
    cp = get(ax1,'CurrentPoint');
    xinit = cp(1,1);yinit = cp(1,2);
    hl = line('XData',xinit,'YData',yinit,...
        'Marker','.','color','y','linewidth',2);
    set(src,'WindowButtonMotionFcn',@wbmcb1)
    set(src,'WindowButtonUpFcn',@wbucb)
end
        
function wbmcb1(src,evnt)
global ax1 cp hl xinit yinit statusbarFvArea Xwa Ywa notifyText TT...
    PlineXY hl1 hl2
cp = get(ax1,'CurrentPoint');
if TT == 1
    set(hl1,'Xdata',[PlineXY(2,1),cp(1,1)],...
        'YData',[PlineXY(2,2),cp(1,2)]);
    set(hl2,'Xdata',[PlineXY(1,1),PlineXY(1,1) - (cp(1,1) - (PlineXY(2,1)))],...
    'YData',[PlineXY(1,2),PlineXY(1,2) - (cp(1,2) - (PlineXY(2,2)))]);
    Xwa = xinit; Ywa = yinit;
    calculateWaveAngle(xinit,yinit,cp,0);
    xdat = [xinit,cp(1,1)];
    ydat = [yinit,cp(1,2)];
    set(hl,'XData',xdat,'YData',ydat);
    set(statusbarFvArea,'string',...
        ['X: ',sprintf('%2.3f',cp(1,1)),' | Y: ',sprintf('%2.3f',cp(1,2)),' [m]']);
    drawnow    
else
    Xwa = xinit; Ywa = yinit;
    calculateWaveAngle(xinit,yinit,cp,0);
    xdat = [xinit,cp(1,1)];
    ydat = [yinit,cp(1,2)];
    set(hl,'XData',xdat,'YData',ydat);
    set(statusbarFvArea,'string',...
        ['X: ',sprintf('%2.3f',cp(1,1)),' | Y: ',sprintf('%2.3f',cp(1,2)),' [m]']);
    drawnow
end
           
function wbucb(src,evnt)
if strcmp(get(src,'SelectionType'),'alt')
    set(src,'Pointer','arrow')
    set(src,'WindowButtonMotionFcn',@mouse_pointer)
    set(src,'WindowButtonUpFcn',@maximized_window)
else
    return
end
                


function mouse_pointer(varargin)
global ax1 statusbarFvArea
C=get(ax1,'CurrentPoint');
set(statusbarFvArea,'string',...
    ['X: ',sprintf('%2.3f',C(1,1)),' | Y: ',sprintf('%2.3f',C(1,2)),' [m]']);

function maximized_window(varargin)
global fViewarea statusbarFvArea notifyText measureText
h=get(fViewarea,'javaframe');
if get(h,'Maximized')==1
    set(statusbarFvArea,'position',[0.47 0 .11 0.016]);
    set(notifyText,'position',[0 0 0.47 0.016]);
    set(measureText,'position',[0.58 0 0.42 0.016]);
else
    set(statusbarFvArea,'position',[0.3 0 .4 0.037]);
    set(notifyText,'position',[0 0 0.3 0.037]);
    set(measureText,'position',[0.7 0 0.3 0.037]);
end

function move_axis_key(fViewarea,event)
global ax1 A99

switch event.Key
    case 'rightarrow'
        aux=get(ax1,'xlim'); set(ax1,'xlim',aux+[aux(1)*0.002 aux(2)*0.002]);
    case 'leftarrow'
        aux=get(ax1,'xlim'); set(ax1,'xlim',aux+[-aux(1)*0.002 -aux(2)*0.002]);
    case 'uparrow'
        aux=get(ax1,'ylim'); set(ax1,'ylim',aux+[aux(1)*0.0002 aux(2)*0.0002]);
    case 'downarrow'
        aux=get(ax1,'ylim'); set(ax1,'ylim',aux+[-aux(1)*0.0002 -aux(2)*0.0002]);    
    otherwise
end

function scroll_zoom_window(fViewarea,event)
global ax1 power_zoom_scroll
drawnow
C=get(ax1,'CurrentPoint'); cP=0.1;
xl=get(ax1,'xlim'); auxx=(xl(2)-xl(1)); Xm=xl(1)+auxx/2;
yl=get(ax1,'ylim'); auxy=(yl(2)-yl(1)); Ym=yl(1)+auxy/2;
% xl(1)=C(1,1) - ((auxx/2)*cP); 
% xl(2)=C(1,1) + ((auxx/2)*cP); 
Xp=(auxx/4) * power_zoom_scroll;
% yl(1)=C(1,2) - ((auxy/2)*cP); 
% yl(2)=C(1,2) + ((auxy/2)*cP); 
Yp=(auxy/4) * power_zoom_scroll;

if event.VerticalScrollCount > 0
%     Xp=-Xp;
    if C(1,1) > Xm & C(1,2) > Ym % Q4
        xl= xl - (abs((Xm - C(1,1)))*cP); yl= yl - (abs((Ym - C(1,2)))*cP);
    elseif C(1,1) < Xm & C(1,2) > Ym % Q1
        xl= xl + (abs((Xm - C(1,1)))*cP); yl= yl - (abs((Ym - C(1,2)))*cP);
    elseif C(1,1) < Xm & C(1,2) < Ym % Q2
        xl= xl + (abs((Xm - C(1,1)))*cP); yl= yl + (abs((Ym - C(1,2)))*cP);
    elseif C(1,1) > Xm & C(1,2) < Ym % Q3
        xl= xl - (abs((Xm - C(1,1)))*cP); yl= yl + (abs((Ym - C(1,2)))*cP);
    end
    set(ax1,'xlim',[xl(1)-Xp xl(2)+Xp],'ylim',[yl(1)-Yp yl(2)+Yp]); drawnow;
elseif event.VerticalScrollCount < 0
    if C(1,1) > Xm & C(1,2) > Ym % Q4
        xl= xl + (abs((Xm - C(1,1)))*cP); yl= yl + (abs((Ym - C(1,2)))*cP);
    elseif C(1,1) < Xm & C(1,2) > Ym % Q1
        xl= xl - (abs((Xm - C(1,1)))*cP); yl= yl + (abs((Ym - C(1,2)))*cP);
    elseif C(1,1) < Xm & C(1,2) < Ym % Q2
        xl= xl - (abs((Xm - C(1,1)))*cP); yl= yl - (abs((Ym - C(1,2)))*cP);
    elseif C(1,1) > Xm & C(1,2) < Ym % Q3
        xl= xl + (abs((Xm - C(1,1)))*cP); yl= yl - (abs((Ym - C(1,2)))*cP);
    end    
    set(ax1,'xlim',[xl(1)+Xp xl(2)-Xp],'ylim',[yl(1)+Yp yl(2)-Yp]); drawnow;
end

function refreshBathy(src,event)
global pathD pathG depfile auxG xyfile hPc xgrid ygrid gr01 gr02
try
    if ~isempty(xgrid) & ~isempty(ygrid)
        auxG1.X=xgrid; auxG1.Y=ygrid;
%         path=
        [bathyD3D]=wldep_Xbeach('read',[pathD,get(depfile,'string')],auxG1);
        bathyD3D=bathyD3D(1:end-1,1:end-1); B1=bathyD3D;
        set(hPc,'CData',B1,'ZData',B1); drawnow;
    else
        auxG=wlgrid_Xbeach('read',[pathG,get(xyfile,'string')]); xgrid=auxG.X; ygrid=auxG.Y;
        [bathyD3D]=wldep_Xbeach('read',[pathD,get(depfile,'string')],auxG);
        bathyD3D=bathyD3D(1:end-1,1:end-1); B1=bathyD3D;
        set(hPc,'CData',B1,'ZData',B1); drawnow;
    end        
catch exception3
    throw(exception3);
%     alertFigure('Problem updating Bathymetry file''s!');
end




function ctrl_move_axes(src,event)
global ax1 cPress xl yl
switch event.Key
    case 'control'
        zoom(src,'off'); pan(src,'off');
        cPress=get(ax1,'CurrentPoint');
        xl=get(ax1,'xlim');
        yl=get(ax1,'ylim');
        set(src,'WindowButtonMotionFcn',@wbmcb); 
        set(src,'WindowKeyReleaseFcn',@ctrl_release);
    otherwise
        return;
end

function wbmcb(src,event)
global ax1 cPress xl yl
C=get(ax1,'CurrentPoint');
dife=[(C(1,1) - cPress(1,1)) (C(1,2) - cPress(1,2))];
set(ax1,'xlim',xl-(dife(1)),'ylim',yl-(dife(2))); 
drawnow;
        
function ctrl_release(src,event)
switch event.Key
    case 'control'
        set(src,'WindowButtonMotionFcn',@mouse_pointer)
        set(src,'WindowKeyReleaseFcn','');
        drawnow;
    otherwise
        return;
end

function PROfile(src,event)
global ax1 xgrid ygrid XouY ProfilePlot statusbarFvArea p1 ...
    fViewarea Profile1 B1 f1 distance1 notifyText x1P y1P x2P y2P TitProf fixScaleCB...
    cor
set(notifyText,'string','Select Profile','backgroundcolor','k','foregroundcolor',[1 1 1]);
click1=waitforbuttonpress;
if click1==0
    C=get(ax1,'CurrentPoint');
    [x1P,y1P]=xy2mn(xgrid,ygrid,C(1,1),C(1,2));
    x1=x1P; y1=y1P;
    Pp1=plot(xgrid(x1,y1),ygrid(x1,y1),'or','markersize',6,'markerfacecolor','r'); 
    Pl1=plot(xgrid(x1,1:end),ygrid(x1,1:end),'-b','linew',2);
    Pl2=plot(xgrid(1:end,y1),ygrid(1:end,y1),'-b','linew',2);
end

click2=waitforbuttonpress;
if click2==0
    C=get(ax1,'CurrentPoint');
    [x2P,y2P]=xy2mn(xgrid,ygrid,C(1,1),C(1,2));
    x2=x2P; y2=y2P;
    delete([Pp1,Pl1,Pl2]);
    if x1==x2        
        if y1>y2; aux01=y1; y1=y2; y2=aux01; clear aux01; end
        Profile1=plot(xgrid(x1,y1:y2),ygrid(x1,y1:y2),'-w','linew',3); drawnow;
        f1=figure('numbertitle','off','name','Profile Analysis',...
            'CloseRequestFcn',['global f1 notifyText Profile1 distance1; delete(Profile1);',...
            'clear distance1;closereq; set(notifyText,''string'','''',''',...
            'backgroundcolor'',[.9 .9 .9],''foregroundcolor'',''k'');',...
            'clearvars -global XLIM YLIM']); modifyLogo(f1);        
        z=1; distance1 = [];
        for g=y1:y2
            if g == y1
                distance1(z,1) = 0; z=z+1;
            else
                distance1(z,1) = distance1(z-1,1) + sqrt((xgrid(x1,g)-xgrid(x1,g-1))^2 + ...
                    (ygrid(x1,g)-ygrid(x1,g-1))^2 ); z=z+1;
            end
        end
        ProfilePlot=plot(distance1,-B1(x1,y1:y2),'k','linew',1); grid(gca,'minor');
        xlabel('Distance [meters]'); ylabel('Height [meters]'); 
        TitProf=title(['Profile M = ',num2str(x1),' - N = ',num2str(y1),':',num2str(y2)],'fontsize',12);
        profileSlider=uicontrol('parent',f1,'unit','normalized',...
            'style','slider','position',[0.02 0.02 0.1 0.03],...
            'sliderstep',[1/(size(xgrid,1)-1) 0.1],'min',1,'max',size(xgrid,1),...
            'value',x1,'callback',@profileSliderPlot);
        fixScaleCB=uicontrol('parent',f1,'unit','normalized',...
            'style','check','string','Fix Scale','fontsize',8,...
            'position',[0.14 0.02 0.12 0.03],'value',0,'backgroundcolor','g');
        XouY=0;   
        set(f1,'toolbar','figure');
    elseif y1==y2
        if x1>x2; aux01=x1; x1=x2; x2=aux01; clear aux01; end
        Profile1=plot(xgrid(x1:x2,y1),ygrid(x1:x2,y1),'-w','linew',3); drawnow;
        f1=figure('numbertitle','off','name','Profile Analysis',...
            'CloseRequestFcn',['global f1 notifyText Profile1 distance1; delete(Profile1);',...
            'clear distance1;closereq; set(notifyText,''string'','''',''',...
            'backgroundcolor'',[.9 .9 .9],''foregroundcolor'',''k'');',...
            'clearvars -global XLIM YLIM']); modifyLogo(f1);
        z=1; distance1 = [];
        for g=x1:x2
            if g == x1
                distance1(z,1) = 0; z=z+1;
            else
                distance1(z,1) = distance1(z-1,1) + ...
                    sqrt((xgrid(g,y1)-xgrid(g-1,y1))^2 + (ygrid(g,y1)-ygrid(g-1,y1))^2 ); z=z+1;
            end
        end
        ProfilePlot=plot(distance1,-B1(x1:x2,y1),'k','linew',1); grid(gca,'minor');
        xlabel('Distance [meters]'); ylabel('Height [meters]'); 
        TitProf=title(['Profile M = ',num2str(y1),' - N = ',num2str(x1),':',num2str(x2)],'fontsize',12);        
        profileSlider=uicontrol('parent',f1,'unit','normalized',...
            'style','slider','position',[0.02 0.02 0.1 0.03],...
            'sliderstep',[1/(size(xgrid,2)-1) 0.1],'min',1,'max',size(xgrid,2),...
            'value',y1,'callback',@profileSliderPlot);
        fixScaleCB=uicontrol('parent',f1,'unit','normalized',...
            'style','check','string','Fix Scale','fontsize',8,...
            'position',[0.14 0.02 0.12 0.03],'value',0,'backgroundcolor','g');
        XouY=1;
        set(f1,'toolbar','figure');
    end
end

function profileSliderPlot(hObj,evnt)
global XouY ProfilePlot ax1 xgrid ygrid statusbarFvArea p1 fViewarea ...
    Profile1 B1 f1 distance1 notifyText x1P y1P x2P y2P TitProf fixScaleCB XLIM YLIM
line0 = round(get(hObj,'value'));
x1=x1P; y1=y1P; x2=x2P; y2=y2P;
if get(fixScaleCB,'value')==1
    if isempty(XLIM)
       XLIM=get(gca,'xlim'); YLIM=get(gca,'ylim');
       set(gca,'xlim',XLIM,'ylim',YLIM);
    else
        set(gca,'xlim',XLIM,'ylim',YLIM);
    end
else
    set(gca,'XlimMode','auto','YlimMode','auto');
end

if y2 > y1; aux=y1; y1 = y2; y2 = aux; end;
if x2 > x1; aux=x1; x1 = x2; x2 = aux; end;

if XouY==0
    Dist = distanceInGrid(y2,y1,line0,0);
    set(ProfilePlot,'xdata',Dist,'ydata',-B1(line0,y2:y1));
    set(Profile1,'xdata',xgrid(line0,y2:y1),'ydata',ygrid(line0,y2:y1)); %set(gca,'xdir','reverse');
    title(gca,['Profile M = ',num2str(line0),' - N = ',num2str(y2),':',num2str(y1)],'fontsize',12);
else
    Dist = distanceInGrid(x2,x1,line0,1);
    set(ProfilePlot,'xdata',Dist,'ydata',-B1(x2:x1,line0));
    set(Profile1,'xdata',xgrid(x2:x1,line0),'ydata',ygrid(x2:x1,line0)); %set(gca,'xdir','reverse');
    title(gca,['Profile M = ',num2str(line0),' - N = ',num2str(x2),':',num2str(x1)],'fontsize',12);
end

function [Dist]=distanceInGrid(start,finish,line,direction)
global xgrid ygrid
if start > finish
    aux = start; start = finish; finish = start;
end

i=2; Dist = zeros(length(start:finish),1);
if direction == 0 % n-direction
    for k = start + 1 : finish
        dx = xgrid(line,k) - xgrid(line,k-1);
        dy = ygrid(line,k) - ygrid(line,k-1);        
        Dist(i,1) = nansum([Dist(i - 1,1) sqrt(dx^2 + dy^2)]); i = i+1;
    end
elseif direction == 1 % m-direction
    for k = start + 1 : finish
        dx = xgrid(k,line) - xgrid(k-1,line);
        dy = ygrid(k,line) - ygrid(k-1,line);
        Dist(i,1) = nansum([Dist(i - 1,1) sqrt(dx^2 + dy^2)]); i = i+1;
    end
end
Dist(Dist == 0)=nan;



function caxisSET(varargin)
global ax1 caxisMIN caxisMAX B1 cor
width=90; height=120; set(0, 'Units', 'points'); pos=get(0,'screensize');
fcaxis = figure('Units', 'points','WindowStyle', 'normal', ...
    'Position', [pos(3)/2-width/2 pos(4)/2-height/2 width height],'NumberTitle','off',...
    'Tag','ViewArea','Interruptible', 'off','menubar','none',...
    'DockControls', 'off','Visible','on','name','Bathymetry Limits','color',cor);
min_panel=uipanel('unit','normalized','parent',fcaxis','title','Minimum Value',...
    'position',[0.05 0.65 0.9 0.34],'titleposition','centertop');
caxisMIN=uicontrol('unit','normalized','parent',fcaxis,'style','edit','position',[0.18 0.72 0.64 0.14],...
    'string',sprintf('%3.1f',nanmin(B1(:))),'fontsize',9,'fontw','bold','horizontalalignment','right',...
    'backgroundcolor',[1 1 1]);
max_panel=uipanel('unit','normalized','parent',fcaxis','title','Maximum Value',...
    'position',[0.05 0.3 0.9 0.34],'titleposition','centertop');
caxisMAX=uicontrol('unit','normalized','parent',fcaxis,'style','edit','position',[0.18 0.37 0.64 0.14],...
    'string',sprintf('%3.1f',nanmax(B1(:))),'fontsize',9,'fontw','bold','horizontalalignment','right',...
    'backgroundcolor',[1 1 1]);
okbutton=uicontrol('unit','normalized','parent',fcaxis,'style','pushbutton',...
    'position',[0.05 0.05 0.9 0.2],'string','OK','fontsize',8,'horizontalalignment','center','callback',...
    'global ax1 caxisMIN caxisMAX; caxis(ax1,[str2num(get(caxisMIN,''string'')) str2num(get(caxisMAX,''string''))]);closereq');
modifyLogo(fcaxis);

function carregaLDB(varargin)
global ax1 PLOT_LDB LDB1
clear ldb; 
[file,path]=uigetfile({'*.ldb','Land Boundary (*.ldb)'},'Pick a File');
if file~=0
    try
        ldb = readldb2([path,file]); aux=isnan(ldb);
        idx = find(aux(:,1) == 1);
        if length(idx) == length(ldb(:,1))
            error('');
        end
    catch
        ldb = readldb([path,file]);
    end
%     if ~isempty(aux00)
%         ldb(aux00)=nan;
%     end
    if ishghandle(PLOT_LDB)
        delete(PLOT_LDB);
    end
    PLOT_LDB=plot(ax1,ldb(:,1),ldb(:,2),'color',[1 1 1],'linew',2); axis equal;
    LDB1=ldb;
end

function sel_color_LDB(varargin)
global PLOT_LDB LDB1
if ~isempty(LDB1)
    colors=uisetcolor;
    if colors~=0
        set(PLOT_LDB,'color',[colors(1) colors(2) colors(3)]);
    end
else
    MSG_ldb=msgbox('Set the Land Boundary Before','Xbeach GUI','warn');
    modifyLogo(MSG_ldb);
end

function sel_color_bg(varargin)
global fViewarea
colors=uisetcolor;
if colors~=0
    set(fViewarea,'color',[colors(1) colors(2) colors(3)]);
end



function SES_analysis(hObj,evnt)
global fViewarea ax1 cor vecSESequat vecSESequatPB SESf hsu_evansB...
    mWaveAtext mWaveAEdit diffrac_controlPB showTableHSUPB H_E_handles ...
    exportHSUPB PlinePlot hl hl1 hl2 countParabolic
if ~isempty(SESf) & ishghandle(SESf)
    figure(SESf);
else
    countParabolic = 1;
    if ~isempty(PlinePlot)
        set(PlinePlot,'XData',[],'YData',[]);
    end
    if ~isempty(hl) & ishghandle(hl)
        set(hl,'XData',[],'YData',[]);
    end
    if ~isempty(hl1) & ishghandle(hl1)
        set(hl1,'XData',[],'YData',[]);
    end
    if ~isempty(hl2) & ishghandle(hl2)
        set(hl2,'XData',[],'YData',[]);
    end
    pos=get(0,'screensize');
    pointsPerPixel = 72/get(0,'ScreenPixelsPerInch');
    width=320* pointsPerPixel; height=310* pointsPerPixel; 
    SESf=figure('unit','points',...
        'position',[pos(3)/2-width/2 pos(4)/2-height/2 width height],...
        'NumberTitle','off','Name','Static Equilibrium Shoreline Analysis',...
        'color',cor,...
        'CloseRequestFcn',@myclosereq);
    set(findall(SESf,'type','uimenu'),'visible','off');
    set(findall(SESf,'type','uitoolbar'),'visible','off');
    modifyLogo(SESf);
    SESequatG= uibuttongroup('unit','normalized','parent',SESf,'visible','on',...
        'Position',[0.03 0.52  .94 0.47],'backgroundcolor',cor,...
        'title','Equations');
    hsu_evansB = uicontrol('unit','normalized','Style','Radio','String',...
        'Hsu & Evans (1989) - Parabolic Shape','pos',[0.02 0.84  0.9 0.15],...
        'parent',SESequatG,'HandleVisibility','off',...
        'backgroundcolor',cor,'fontsize',8);
    hsu_evansPB = uicontrol('unit','normalized','Style','pushbutton','String',...
        'Ok','pos',[0.82 0.84  0.15 0.15],...
        'parent',SESequatG,'HandleVisibility','off',...
        'fontsize',8,'callback',@H_E_diff_control_Analysis);
    gonzalez_MedinaB = uicontrol('unit','normalized','Style','Radio',...
        'String','González & Medina (1999) - Control Point','pos',[0.02 0.645  0.9 0.15],...
        'parent',SESequatG,'HandleVisibility','off',...
        'backgroundcolor',cor,'fontsize',8);
    gonzalez_MedinaPB = uicontrol('unit','normalized','Style','pushbutton','String',...
        'Ok','pos',[0.82 0.645  0.15 0.15],...
        'parent',SESequatG,'HandleVisibility','off',...
        'fontsize',8);
    moreno_krausB = uicontrol('unit','normalized','Style','Radio',...
        'String','Moreno & Kraus (1999) - Hiperbolic Shape','pos',[0.02 0.43  0.9 0.15],...
        'parent',SESequatG,'HandleVisibility','off',...
        'backgroundcolor',cor,'fontsize',8);
    moreno_krausPB = uicontrol('unit','normalized','Style','pushbutton','String',...
        'Ok','pos',[0.82 0.43  0.15 0.15],...
        'parent',SESequatG,'HandleVisibility','off',...
        'fontsize',8);
    bodge_mlwB = uicontrol('unit','normalized','Style','Radio',...
        'String','Bodge(1998) - Design MLW','pos',[0.02 0.23  0.9 0.15],...
        'parent',SESequatG,'HandleVisibility','off',...
        'backgroundcolor',cor,'fontsize',8);
    bodge_mlwPB = uicontrol('unit','normalized','Style','pushbutton','String',...
        'Ok','pos',[0.82 0.23  0.15 0.15],...
        'parent',SESequatG,'HandleVisibility','off',...
        'fontsize',8);
    bodge_G_3B = uicontrol('unit','normalized','Style','Radio',...
        'String','Bodge(1998) - G/3 Rule','pos',[0.02 0.03  0.9 0.15],...
        'parent',SESequatG,'HandleVisibility','off',...
        'backgroundcolor',cor,'fontsize',8);
    bodge_G_3PB = uicontrol('unit','normalized','Style','pushbutton','String',...
        'Ok','pos',[0.82 0.03  0.15 0.15],...
        'parent',SESequatG,'HandleVisibility','off',...
        'fontsize',8);
    vecSESequat=[hsu_evansB gonzalez_MedinaB moreno_krausB bodge_mlwB bodge_G_3B];
    vecSESequatPB = [hsu_evansPB gonzalez_MedinaPB moreno_krausPB bodge_mlwPB bodge_G_3PB];
    set(vecSESequatPB,'enable','off'); set(vecSESequatPB(1),'enable','on');
    set(SESequatG,'SelectionChangeFcn',@selSESequat);
    set(SESequatG,'SelectedObject',hsu_evansB); set(SESequatG,'Visible','on');
    uipanel('unit','normalized','parent',SESf,'position',...
        [0.03 0.03  .94 0.47],'backgroundcolor',cor,...
        'title','Analysis');
    mWaveAtext = uicontrol('unit','normalized','parent',SESf,...
        'style','text','string','Mean Wave Angle                                   deg.',...
        'position',[0.1 0.3 0.85 0.1],'enable','off',...
        'fontsize',10,'backgroundcolor',cor,'visible','on',...
        'horizontalalignment','left');
    mWaveAEdit = uicontrol('unit','normalized','parent',SESf,...
        'style','edit','string','',...
        'position',[0.51 0.338 0.24 0.07],'enable','off',...
        'fontsize',10,'backgroundcolor',[1 1 1],'visible','on');
    diffrac_controlPB = uicontrol('unit','normalized','parent',SESf,...
        'style','push','string','Define Diffraction and Control Points',...
        'position',[0.1 0.2 0.8 0.07],'enable','off',...
        'fontsize',10,'visible','on','callback',@H_E_diff_control_Analysis);
    showTableHSUPB = uicontrol('unit','normalized','parent',SESf,...
        'style','push','string','Show Table',...
        'position',[0.1 0.07 0.35 0.07],'enable','off',...
        'fontsize',10,'visible','on','callback',@showTable_analysis);
    exportHSUPB = uicontrol('unit','normalized','parent',SESf,...
        'style','push','string','Export *.ldb',...
        'position',[0.55 0.07 0.35 0.07],'enable','off',...
        'fontsize',10,'visible','on','callback',@exportHsuParabolic);
    H_E_handles = [mWaveAtext mWaveAEdit diffrac_controlPB showTableHSUPB exportHSUPB];
end

function selSESequat(hObj,evnt)
global vecSESequat vecSESequatPB SESf hsu_evansB mWaveAtext cor...
    mWaveAEdit H_E_handles
if ~isempty(evnt)
    idx = find( vecSESequat == evnt.NewValue);
else
    idx = 1;
end
if vecSESequat(idx) == hsu_evansB
    set(H_E_handles,'visible','on');  
else
    if ~isempty(mWaveAtext)
        set(H_E_handles,'visible','off'); 
    end
end


%             Hsu & Evans (1989) - Parabolic Shape Analysis              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hsu_evans_analysis(hObj,evnt)
global notifyText fViewarea SESf countAux PlinePlot H_E_MWA H_E_DC
if ~isempty(PlinePlot) & ishghandle(PlinePlot)
    set(PlinePlot,'XData',[],'YData',[]);
end
H_E_MWA = 1; H_E_DC =[];
countAux = 1;
set(fViewarea,'pointer','cross','WindowButtonDownFcn',@defineLine);
set(notifyText,'backgroundcolor','r','foregroundcolor','k',...
    'string','Define Mean Wave Angle');
set(SESf,'visible','off');
figure(fViewarea);

function defineLine(hObj,evnt)
global ax1 hl xinit yinit notifyText hsu_evansPB H_E_DC countAux...
    PlineXY auxPline corLine TT
cp = get(ax1,'CurrentPoint');
xinit = cp(1,1);yinit = cp(1,2);
hl = line('XData',xinit,'YData',yinit,...
    'color',corLine,'linewidth',1.5);
PlineXY(countAux,:) = [xinit,yinit]; 
auxPline(countAux) = hl; countAux = countAux + 1;
if H_E_DC == 1
    set(notifyText,'backgroundcolor','y','foregroundcolor','k',...
    'string','Define Control Point');
end
set(hObj,'WindowButtonMotionFcn',@wbmcb1)
set(hObj,'WindowButtonDownFcn',@meanWaveAngleLine);

function endLine(hObj,evnt)
global hl notifyText cor ax1 SESf measureText Xwa Ywa mWaveAtext...
    mWaveAEdit diffrac_controlPB mwaLine H_E_DC countAux PlineXY ...
    PlinePlot H_E_MWA auxPline WaveAngle corLine TT
if strcmp(get(hObj,'SelectionType'),'alt') | ...
     strcmp(get(hObj,'SelectionType'),'normal')   
    cp = get(ax1,'CurrentPoint');
    xinit = cp(1,1); yinit = cp(1,2);
%     hl = line('XData',xinit,'YData',yinit,...
%         'Marker','.','markersize',20,'color',corLine,'linewidth',0.3);
%     auxPline(countAux) = hl;
%     for g=1:length(auxPline)
%         set(auxPline(g),'XData',[],'YData',[]);
%     end
    PlineXY(countAux,:) = [xinit,yinit]; countAux = 1;
% %     if H_E_DC ==1
% %         TT = 1;
% %         set(hObj,'WindowButtonMotionFcn',@wbmcb1)
% %     end
%     PlinePlot = plot(PlineXY(:,1),...
%         PlineXY(:,2),'color',corLine,'linew',1.5,...
%         'marker','.','markersize',20,'linestyle','--');
    set(hObj,'Pointer','arrow')
    set(hObj,'WindowButtonMotionFcn',@mouse_pointer)
    set(hObj,'WindowButtonUpFcn','');
    set(notifyText,'backgroundcolor',cor,'foregroundcolor','k',...
        'string','');
    set(SESf,'visible','on');
    set(measureText,'string','');
    if H_E_MWA == 1
        calculateWaveAngle(Xwa,Ywa,cp,1);
    else
        calculateWaveAngle(Xwa,Ywa,cp,0);
    end
    set(mWaveAtext,'enable','on'); set(mWaveAEdit,'enable','on');
    set(diffrac_controlPB,'enable','on'); mwaLine = hl;
    if H_E_DC ==1
        set(measureText,'string','');
        H_E_calculate_parabolic(WaveAngle,PlineXY,5);
        H_E_DC=[];
    end
    H_E_MWA = []; TT = [];
end

function meanWaveAngleLine(hObj,evnt)
global TT PlineXY countAux xinit yinit ax1 hl1 hl2...
    notifyText PlinePlot corLine
cp = get(ax1,'CurrentPoint');
xinit = cp(1,1);yinit = cp(1,2);
PlineXY(countAux,:) = [xinit,yinit]; countAux = countAux + 1;
PlinePlot = plot(PlineXY(:,1),...
    PlineXY(:,2),'color',corLine,'linew',1.5,...
    'linestyle','--');
hl1 = line('Xdata',[PlineXY(2,1),cp(1,1)],...
    'YData',[PlineXY(2,2),cp(1,2)],...
    'color',corLine,'linewidth',1,'linestyle','--');
hl2 = line('Xdata',[PlineXY(1,1),PlineXY(1,1) - (cp(1,1) - (PlineXY(2,1)))],...
    'YData',[PlineXY(1,2),PlineXY(1,2) - (cp(1,2) - (PlineXY(2,2)))],...
    'color',corLine,'linewidth',1,'linestyle','--');
set(notifyText,'backgroundcolor','g','foregroundcolor','k',...
    'string','Define Mean Wave Angle Attack');
TT = 1;
set(hObj,'WindowButtonMotionFcn',@wbmcb1)
set(hObj,'WindowButtonDownFcn',@endLine);


function H_E_diff_control_Analysis(hObj,evnt)
global notifyText fViewarea SESf H_E_DC countAux PlinePlot H_E_MWA...
    hl hl1 hl2
H_E_MWA = 1; H_E_DC =[];
if ~isempty(PlinePlot)
    set(PlinePlot,'XData',[],'YData',[]);
end
if ~isempty(hl) & ishghandle(hl)
    set(hl,'XData',[],'YData',[]);
end
if ~isempty(hl1) & ishghandle(hl1)
    set(hl1,'XData',[],'YData',[]);
end
if ~isempty(hl2) & ishghandle(hl2)
    set(hl2,'XData',[],'YData',[]);
end
countAux = 1;
set(fViewarea,'pointer','cross','WindowButtonDownFcn',@defineLine);
set(notifyText,'backgroundcolor','r','foregroundcolor','k',...
    'string','Define Diffraction Point');
set(SESf,'visible','off'); H_E_DC = 1;
figure(fViewarea); % focus to visualization area

function calculateWaveAngle(xinit,yinit,cp,aux)
global measureText WaveAngle notifyText mWaveAEdit
dx = xinit - cp(1,1); dy = yinit - cp(1,2); 
% if dx>0 & dy>0; gears= 90 + rad2deg(atan(dx/dy)); % 0
% elseif dx>0 & dy<0; gears= 180 + (180 - (90 - rad2deg(atan(dx/dy)))); %180
% elseif dx<0 & dy<0; gears= 270 + rad2deg(atan(dx/dy)); %180
% elseif dx<0 & dy>0; gears= 90 - abs(rad2deg(atan(dx/dy))); %360
if dx>0 & dy>0; gears= rad2deg(atan(dx/dy)); % 0
elseif dx>0 & dy<0; gears= 180 - abs(rad2deg(atan(dx/dy)));
elseif dx<0 & dy<0; gears= 180 + rad2deg(atan(dx/dy)); %180
elseif dx<0 & dy>0; gears= 270 + abs(rad2deg(atan(dy/dx))); %360
elseif dx > 0 & dy == 0; gears = 90; % 180
elseif dx < 0 & dy == 0; gears = 270; % 0
elseif dx == 0 & dy > 0; gears = 0; % 90
elseif dx == 0 & dy < 0; gears = 180; % 270
elseif dx == 0 & dy == 0; gears = 0; % Maybe NAN
end
gears = gears + 90 + 180;
gears(gears > 360) = gears(gears > 360) - 360;
if aux == 0
    set(measureText,'string',['Wave Angle: ',sprintf('%3.3f',gears),' degrees']);
elseif aux == 1
    WaveAngle = gears;
    set(mWaveAEdit,'string',sprintf('%3.2f',WaveAngle));
end

function H_E_calculate_parabolic(WaveAngle,PlineXY,Kan)
global fViewarea ax1 Parabolic_H_E_shape showTableHSUPB exportHSUPB ...
    mWaveAEdit beta R0 H_E_Data Parabolic_Beach hl1 hl2 countParB
% if ~isempty(Parabolic_H_E_shape) & ishghandle(Parabolic_H_E_shape)
%     set(Parabolic_H_E_shape,'XData',[],'YData',[]);
% end
x1 = get(hl1,'XData'); y1 = get(hl1,'XData');
x2 = get(hl2,'XData'); y2 = get(hl2,'YData');
set(mWaveAEdit,'string',sprintf('%3.2f',WaveAngle));
dx = PlineXY(end-1,1) - PlineXY(1,1); dy = PlineXY(end-1,2) - PlineXY(1,2);
dx1 = PlineXY(end,1) - PlineXY(end-1,1); dy1 = PlineXY(end,2) - PlineXY(end-1,2);
dx2 = x2(2) - PlineXY(1,1); dy2 = y2(2) - PlineXY(1,2);
dx3 = PlineXY(end,1) - PlineXY(1,1); dy3 = PlineXY(end,2) - PlineXY(1,2);
dx4 = x1(2) - PlineXY(1,1); dy4 = y1(2) - PlineXY(1,2);

betaAux = arg(dx3,dy3); betaAux1 = arg(dx2,dy2);

angleControl = arg(dx,dy);

direction = beachDirection(betaAux,angleControl); % parabolic beach direction

%beta = Angle_diff(betaAux,angleControl);
beta = Angle_diff(betaAux1,angleControl);

R0 = sqrt(dx^2 + dy^2);

[c0,c1,c2] = H_E_table_coefficients(beta);

thetas = beta : Kan : beta + 110; 

auxA = arg(dx3,dy3);

for g=1:length(thetas)
    R(g,1) = (c0 + c1*(beta/thetas(g)) + c2*((beta/thetas(g))^2)) * R0;

    eval(['angleAux = angleControl ',direction,'(thetas(g) - beta)']);
    angleAux(angleAux > 360) = angleAux(angleAux > 360) -360;
    
    xp(g,1) = PlineXY(1,1) + (sin(deg2rad(angleAux)) * R(g,1));
    yp(g,1) = PlineXY(1,2) + (cos(deg2rad(angleAux)) * R(g,1));
%     dx2(g,1) = xp(g,1) - PlineXY(1,1); dy2(g,1) = yp(g,1) - PlineXY(1,2);
%     ii(g,1)=angleAux;
end

H_E_Data = [thetas',R]; %dista = sqrt(dx2.^2 + dy2.^2);

if countParB == 1
    Parabolic_H_E_shape = plot(ax1,xp,yp,'k','linew',1.5,'marker','.','markersize',15);
else
    Parabolic_H_E_shape = plot(ax1,xp,yp,'color',rand(1,3),'linew',1.5,'marker','.','markersize',15);
end

part_name = ['p',num2str(countParB)];
if ~isfield(Parabolic_Beach,part_name)
    Parabolic_Beach.(part_name) = [];
end
Parabolic_Beach.(part_name) = [xp,yp];
countParB = countParB + 1;

set(showTableHSUPB,'enable','on'); set(exportHSUPB,'enable','on');
set(fViewarea,'WindowButtonMotionFcn',@mouse_pointer)
set(fViewarea,'WindowButtonDownFcn','');

function inv=invertAngle(ang)
inv = ang - 180;
if inv < 0
    inv = inv + 360;
end

function [angDif]=Angle_diff(ang1,ang2)
amax = max([ang1 ang2]); amin = min([ang1 ang2]);
% amaxInv = invertAngle(amax);% 
% if amax == amin
%     angDif = 0;
% elseif amin < amaxInv
%     angDif = (amin + 360) - amax;
% else
%     angDif = amax - amin;
% end
if amax >= 270 & amin <= 90
    aux= 360 - amax; angDif = aux + amin;
else
    angDif = amax - amin;
end

function direction = beachDirection(betaA,angleControlA)
if betaA <= 90 & angleControlA >= 270 %beta esta no 1o quadrante & control no 2o
    direction = '+';
elseif betaA >= 270 & angleControlA <= 90
    direction = '-';
else
    if betaA > angleControlA
        direction = '+';
    else
        direction = '-';
    end
end


function gears=arg(dx,dy)
if dx>0 & dy>0; gears= rad2deg(atan(dx/dy)); 
    quadrant = 1;% 0 
elseif dx>0 & dy<0; gears= 180 - abs(rad2deg(atan(dx/dy)));
    quadrant = 4;
elseif dx<0 & dy<0; gears= 180 + rad2deg(atan(dx/dy)); %180
    quadrant = 3;
elseif dx<0 & dy>0; gears= 270 + abs(rad2deg(atan(dy/dx))); %360
    quadrant = 2;
elseif dx > 0 & dy == 0; gears = 90; % 180
elseif dx < 0 & dy == 0; gears = 270; % 0
elseif dx == 0 & dy > 0; gears = 0; % 90
elseif dx == 0 & dy < 0; gears = 180; % 270
elseif dx == 0 & dy == 0; gears = 0; % Maybe NAN
end

function [c0,c1,c2]=H_E_table_coefficients(beta)
global coeff_H_E
coeff_H_E = [...
    10 0.036 1.011 -0.047;...
    15  0.050 0.998 -0.049;...
    20  0.055 1.029 -0.088;...
    25  0.054 1.083 -0.142;...
    30  0.045 1.146 -0.194;...
    35  0.029 1.220 -0.253;...
    40  0.000 1.326 -0.332;...
    45 -0.039 1.446 -0.412;...
    50 -0.088 1.588 -0.507;...
    55 -0.151 1.756 -0.611;...
    60 -0.227 1.930 -0.706;...
    65 -0.315 2.113 -0.800;...
    70 -0.409 2.284 -0.873;...
    75 -0.505 2.422 -0.909;...
    80 -0.600 2.520 -0.906];

if beta < 10; beta = 10; elseif beta > 80; beta = 80; end
[~,idx] = findnearest(beta,coeff_H_E(:,1));
c0 = coeff_H_E(idx,2); c1 = coeff_H_E(idx,3); c2 = coeff_H_E(idx,4);

function showTable_analysis(hObj,evnt)
global SESf cor H_E_Data beta R0 PlineXY WaveAngle Table_Hsu_Evans
aux=get(SESf,'position');
pos=get(0,'screensize');
pointsPerPixel = 72/get(0,'ScreenPixelsPerInch');
width = 250 * pointsPerPixel;
height = 350 * pointsPerPixel;

Table_Hsu_Evans = figure('unit','points',...
    'position',[aux(1)+aux(3)+10 aux(2) width height],...
    'NumberTitle','off','Name','Data View',...
    'color',cor,...
    'CloseRequestFcn','closereq');
set(findall(Table_Hsu_Evans,'type','uimenu'),'visible','off');
set(findall(Table_Hsu_Evans,'type','uitoolbar'),'visible','off');
modifyLogo(Table_Hsu_Evans);
table = uitable('unit','normalized','position',[0.1 0.05 0.8 0.8],...
    'ColumnName',{'Theta [deg]','R [m]'},'Data',H_E_Data,'ColumnWidth',{70});
betaT = uicontrol('unit','normalized','parent',Table_Hsu_Evans,...
    'style','text','string',['Beta = ',sprintf('%3.2f',beta),' [deg]'],...
    'position',[0.08 0.88 0.44 0.1],'enable','on',...
    'fontsize',9,'backgroundcolor',cor,'visible','on',...
    'horizontalalignment','left');
R0T = uicontrol('unit','normalized','parent',Table_Hsu_Evans,...
    'style','text','string',['R0 = ',sprintf('%3.2f',R0),' [m]'],...
    'position',[0.55 0.88 0.4 0.1],'enable','on',...
    'fontsize',9,'backgroundcolor',cor,'visible','on',...
    'horizontalalignment','left');
RT = uicontrol('unit','normalized','parent',Table_Hsu_Evans,...
    'style','text','string',['Radius Line Interval [deg]'],...
    'position',[0.08 0.86 0.6 0.05],'enable','on',...
    'fontsize',9,'backgroundcolor',cor,'visible','on',...
    'horizontalalignment','left');
KanT = uicontrol('unit','normalized','parent',Table_Hsu_Evans,...
    'style','edit','string','5',...
    'position',[0.65 0.86 0.25 0.05],'enable','on',...
    'fontsize',9,'backgroundcolor',[1 1 1],'visible','on',...
    'horizontalalignment','left','callback',...
    'global WaveAngle PlineXY KantT; H_E_calculate_parabolic(WaveAngle,PlineXY,str2double(get(KanT,''string'''')))');

function exportHsuParabolic(hObj,evnt)
global Parabolic_Beach countParabolic
try
    fnames = fieldnames(Parabolic_Beach);
    for i = 1 : numel(fnames)
        nameFparabolic = ['Parabolic_Beach_',fnames{i},'.ldb'];
        fid            = fopen(nameFparabolic,'w'); 
        z=1;
        vetor{z,1}     = nameFparabolic(1:end-4);     
        vetor{z+1,1}   = size(Parabolic_Beach.(fnames{i}),1); 
        vetor{z+1,2}   = size(Parabolic_Beach.(fnames{i}),2); 
        fprintf(fid,'%s\n',vetor{z,1});
        fprintf(fid,'%1.0f %1.0f\n',vetor{z+1,:}); 
        z=z+2;

        for k = 1 : size(Parabolic_Beach.(fnames{i}),1)
            vetor{z,1}=Parabolic_Beach.(fnames{i})(k,1); 
            vetor{z,2}=Parabolic_Beach.(fnames{i})(k,2); 
            fprintf(fid,'%4.3f %4.3f\n',vetor{z,:});
            z=z+1;
        end
        fclose(fid);
    end
    alertFigure(sprintf(['Export Complete!\n',nameFparabolic]));
    countParabolic = i + 1;
catch
    if ~isempty(fid)
        fclose(fid);
    end
    alertFigure('Problem exporting Parabolic Beach');
end



%            Moreno & Kraus (1999) - Hiperbolic Shape Analysis           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function morenoKrausEquation(hObj,evnt)
% y = across-shore distance
% x = alongshore distante
% a = units of length
% b = units of 1 / length
% m = dimensionless

x=1:1500;

a = 767.5;
m = [0 0.25 0.5 0.6 1 2];
% b = [0.0005 0.001 0.003 0.006];
b = 0.0012;

for g=1:length(b)
    y(g,:) = a * tanh(b(g) * x).^m;
end

for g=1:length(m)
    y(g,:) = a*tanh(b * x).^m(g);
end
    
figure; plot(x,y)

m0 = plot(x,y(1,:),'k'); hold on
m025 = plot(x,y(2,:),'b');
m05 = plot(x,y(3,:),'c');
m06 = plot(x,y(4,:),'y');
m1 = plot(x,y(5,:),'g');
m2 = plot(x,y(6,:),'m');

b = 0.6060 / a^0.9124;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              Modify Logo                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function modifyLogo(handlE,varargin)
import javax.swing.*
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(handlE,'javaframe');
jIcon=javax.swing.ImageIcon('../assets/images/X-FOFO-01.png');
jframe.setFigureIcon(jIcon);
% jframe.setImageIcon(jIcon);
% jframe.setUndecorated(true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            About Information                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function aboutXbeachGUI(varargin)
global version
width=250; height=150; set(0, 'Units', 'points'); screenSize = get(0,'ScreenSize');
pos1 = [screenSize(3)/2-width/2 screenSize(4)/2-height/2 width height];
aboutdiag=dialog('units','points','Name','About XBeach GUI','position',pos1,...
    'color',[1 1 1]);
modifyLogo(aboutdiag);
try
    myIcon = imread('../assets/images/XB_logo01.png');
catch
end
if exist('myIcon','var')
    jj=uicontrol('units','points','parent',aboutdiag,...
        'position',[width/2-105 80 205 70],'cdata',myIcon,'selected','off');
else
    jj=uicontrol('units','points','parent',aboutdiag,'style','text',...
        'position',[width/2-80/2 90 80 20],'string','CB&I','selected','off',...
        'fontsize',10,'fontw','bold','backgroundcolor',[1 1 1]);
end
uicontrol('units','points','parent',aboutdiag,'style','text','string','XBeach GUI',...
    'position',[width/2-100/2 50 100 20],'fontsize',10,'fontw','bold',...
    'horizontalalignment','center','backgroundcolor',[1 1 1]);
uicontrol('units','points','parent',aboutdiag,'style','text','string',['Version: ',version,' by GHG'],...
    'position',[width/2-100/2 20 100 20],'fontsize',10,'fontw','bold',...
    'horizontalalignment','center','backgroundcolor',[1 1 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              Close Figure                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function myclosereq(hObj,varargin)
global fViewarea saveF f1 XLIM YLIM SESf mWaveAtext mwaLine hl PlinePlot ...
    Parabolic_H_E_shape Table_Hsu_Evans hl1 hl2
if hObj == fViewarea
    if ~isempty(fViewarea) & ishghandle(fViewarea)
        if ishghandle(f1)
            close(f1)            
        end
        if ~isempty(SESf) & ishghandle(SESf)
            close(SESf)
        end
        if ~isempty(Table_Hsu_Evans) & ishghandle(Table_Hsu_Evans)
            close(Table_Hsu_Evans)
        end
        close(fViewarea);
%         clearvars -global
    end
elseif hObj == f1
    close(f1);
    clearvars -global XLIM YLIM
    if ishghandle(SESf)
        close(SESf);
    end
    if ~isempty(Table_Hsu_Evans) & ishghandle(Table_Hsu_Evans)
        close(Table_Hsu_Evans)
    end
elseif hObj == SESf
    mWaveAtext=[];
    if ~isempty(PlinePlot)
        set(PlinePlot,'XData',[],'YData',[]);
        set(Parabolic_H_E_shape,'XData',[],'YData',[]);
        drawnow();
    end
    if ~isempty(Table_Hsu_Evans) & ishghandle(Table_Hsu_Evans)
        close(Table_Hsu_Evans)
    end
    if ~isempty(hl) & ishghandle(hl)
        set(hl,'XData',[],'YData',[]);
    end
    if ~isempty(hl1) & ishghandle(hl1)
        set(hl1,'XData',[],'YData',[]);
    end
    if ~isempty(hl2) & ishghandle(hl2)
        set(hl2,'XData',[],'YData',[]);
    end
    closereq
else
    
    newFile00;
    waitfor(saveF,'name');
    
    % Call normal close request
    clearvars -global
    closereq;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             Splash Screen                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function splashXbeach(varargin)
global fh
mytimer = timerfind('Name','Splash') ;
if ~isempty(mytimer)
    stop  (mytimer);
    delete(mytimer)
    delete(fh);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              Alert Figure                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function alertFigure(message)
width=250; height=100; set(0, 'Units', 'points'); screenSize=get(0,'screensize');
pos1 = [screenSize(3)/2-width/2 screenSize(4)/2-height/2 width height];
alert=figure('unit','points','BusyAction','queue','WindowStyle','modal', ...
    'Position',pos1,'Resize','off','CreateFcn','','NumberTitle','off', ...
    'IntegerHandle','off','MenuBar','none','Tag','XbeachGUI','Interruptible','off', ...
    'DockControls','off','Visible','on','Interruptible','off','color',[1 1 1],'name','Xbeach GUI');
alertIcon=imread('../assets/images/Alert.png','backgroundcolor',[1 1 1]);
alertIconF=uicontrol('unit','normalized','cdata',alertIcon,...
    'position',[0.07 0.25 0.2 0.52]);
alertTXT=uicontrol('unit','normalized','style','text',...
    'string',message,'position',[0.32 0.5 0.63 0.3],...
    'fontsize',10,'fontw','bold','backgroundcolor',[1 1 1],'horizontalalignment','center');
alertOK=uicontrol('unit','normalized','style','pushbutton',...
    'string','Ok','position',[0.535 0.15 0.2 0.2],...
    'fontsize',10,'fontw','bold','callback','closereq');
modifyLogo(alert)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              Figure title Size                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function titlesizeM=fsize(titlesize)
if ischar(titlesize) & length(titlesize) > 50
    titlesizeM=['... ',titlesize(end-50:end)];
else
    titlesizeM=titlesize;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Display Information Params file                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function formText=dispSection(textSec,varargin)
baseT='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
if length(textSec)~=0
    len01=length(textSec) + 4;
    t0=length(baseT) - len01;
    formText(1:round(t0/2))='%'; formText=[formText,'  ',textSec,'  ']; formText(end+1:length(baseT))='%';
else
    formText=baseT;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                WLDEP Xbeach                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=wldep_Xbeach(cmd,varargin)
%WLDEP Read/write Delft3D field files (e.g. depth files).
%   WLDEP can be used to read and write Delft3D field files for spatial
%   varying quantities. This includes files for depth (most common
%   application), roughness (2 fields in one file!), eddy viscosity,
%   critical bed shear stress (for mud fractions), bed composition files
%   (per layer per fraction), initial conditions (water level, velocities,
%   concentrations), etc.
%
%   DEPTH = WLDEP('read',FILENAME,SIZE) reads the file assuming that the
%   file contains a single data matrix of the indicate size.
%
%   DEPTH = WLDEP('read',FILENAME,GRID) reads the file assuming that the
%   file contains a single data matrix of the size that matches the grid
%   data structure GRID as generated by WLGRID.
%
%   STRUCT = WLDEP(...,'multiple') reads multiple fields from the file. The
%   function returns a structure vector with one field: Data. In case of a
%   roughness file which contains 2 fields, the U data is accessible via
%   STRUCT(1).Data and the V data is accessible via STRUCT(2).Data.
%
%   [FLD1,FLD2,...] = WLDEP(...,'multiple') reads multiple fields from the
%   file. The function returns one field to one output argument. In case of
%   a roughness file you would use this as [URGH,VRGH] = WLDEP(...).
%
%   WLDEP('write',FILENAME,MATRIX) writes a depth file for the specified
%   matrix. It will interactively ask whether the data should be multiplied
%   by -1 (e.g. for depth versus elevation) and whether one data line
%   should be added at the high end of both grid directions (the Delft3D
%   depth files are one grid line larger than the associated grid files).
%   To suppress these interactive questions use the command:
%   WLDEP('write',FILENAME,'',MATRIX)
%
%   WLDEP('write',FILENAME,MATRIX1,MATRIX2,MATRIX3,...) writes multiple
%   fields to the specified file. Optionally you may add keywords between
%   data blocks by inserting Keyword strings between the matrices:
%   WLDEP('write',FILENAME,KEYWORD1,MATRIX1,KEYWORD2,MATRIX2,...)
%   The keywords will be enclosed in single quotes in the file:
%
%   'KEYWORD1'
%   DATA of MATRIX1
%   'KEYWORD2'
%   DATA of MATRIX2
%
%   If the keyword is empty, nothing will be written. The file format with
%   keywords is not supported by Delft3D.
%
%   WLDEP('write',FILENAME,STRUCT) writes the STRUCT(i).Data fields to the
%   specified file. Optionally the STRUCT may contain Keyword fields which
%   will be used in the same manner as the keyword arguments mentioned
%   above.
%
%   The default number format used by WLDEP is a fixed point %15.7f. For
%   small parameters like variable grain size diameters this setting may
%   not be appropriate. You can change the format setting by inserting the
%   pair 'format',FORMAT after the FILENAME and before MATRIX argument that
%   should be influenced. Here FORMAT should contain a single valid format
%   specification like '%15.7f', '%16.7e' or '%g'.
%
%   See also: WLGRID

%----- LGPL --------------------------------------------------------------------
%
%   Copyright (C) 2011-2012 Stichting Deltares.
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation version 2.1.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, see <http://www.gnu.org/licenses/>.
%
%   contact: delft3d.support@deltares.nl
%   Stichting Deltares
%   P.O. Box 177
%   2600 MH Delft, The Netherlands
%
%   All indications and logos of, and references to, "Delft3D" and "Deltares"
%   are registered trademarks of Stichting Deltares, and remain the property of
%   Stichting Deltares. All rights reserved.
%
%-------------------------------------------------------------------------------
%   http://www.deltaressystems.com
%   $HeadURL: https://svn.oss.deltares.nl/repos/delft3d/trunk/src/tools_lgpl/matlab/quickplot/progsrc/wldep.m $
%   $Id: wldep.m 1201 2012-01-21 16:47:51Z jagers $

if nargin==0
    if nargout>0
        varargout=cell(1,nargout);
    end
    return
end

switch cmd
    case 'read'
        if nargout>1 % automatically add 'multiple'
            if nargin==3 % cmd, filename, size
                varargin{3}='multiple';
            end
        end
        Dep=Local_depread_Xbeach(varargin{:});
        if isstruct(Dep)
            if length(Dep)<nargout
                error('Too many output arguments.')
            end
            if nargout==1
                varargout{1}=Dep;
            else
                varargout = cell(1,max(1,nargout));
                for i=1:length(varargout)
                    varargout{i}=Dep(i).Data;
                end
            end
        elseif nargout>1
            error('Too many output arguments.')
        else % nargout<=1
            varargout={Dep};
        end
    case 'write'
        Out=Local_depwrite_Xbeach(varargin{:});
        if nargout>0
            varargout{1}=Out;
        end
    otherwise
        error('Unknown command: %s',var2str(cmd))
end


function DP=Local_depread_Xbeach(filename,dimvar,option)
% DEPREAD reads depth information from a given filename
%    DEPTH=DEPREAD('FILENAME.DEP',SIZE)
%    or
%    DEPTH=DEPREAD('FILENAME.DEP',GRID)
%    where GRID was generated by GRDREAD.
%
%    ...,'multiple') to read multiple fields from the file.

DP=[];

if nargin<2
    error('No size or grid specified.')
end

if nargin<3
    multiple=0;
else
    multiple=strcmp(option,'multiple');
    if ~multiple
        error('Unknown 3rd argument: %s.',var2str(option))
    end
end

if strcmp(filename,'?')
    [fname,fpath]=uigetfile('*.*','Select depth file');
    if ~ischar(fname)
        return
    end
    filename=[fpath,fname];
end

fid=fopen(filename);
if fid<0
    error('Cannot open %s.',filename)
end
try
    if isstruct(dimvar) % new grid format G.X, G.Y, G.Enclosure
        dim=size(dimvar.X)+1;
    elseif iscell(dimvar) % old grid format {X Y Enclosure}
        dim=size(dimvar{1})+1;
    else
        dim=dimvar;
    end
    i=1;
    while 1
        %
        % Skip lines starting with *
        %
        line='*';
        cl=0;
        while ~isempty(line) && line(1)=='*'
            if cl>0
                DP(i).Comment{cl,1}=line;
            end
            cl=cl+1;
            currentpoint=ftell(fid);
            line=fgetl(fid);
        end
        fseek(fid,currentpoint,-1);
        %
        [DP(i).Data,NRead]=fscanf(fid,'%f',dim);
        if NRead==0 % accept dredging input files containing 'keyword' on the first line ...
            str=fscanf(fid,['''%[^' char(10) char(13) ''']%['']']);
            if ~isempty(str) && isequal(str(end),'''')
                [DP(i).Data,NRead]=fscanf(fid,'%f',dim);
                DP(i).Keyword=str(1:end-1);
            end
        end
        DP(i).Data=DP(i).Data;
        %
        % Read remainder of last line
        %
        Rem=fgetl(fid);
        if ~ischar(Rem)
            Rem='';
        else
            Rem=deblank(Rem);
        end
        if NRead<prod(dim)
            if isempty(Rem)
                Str=sprintf('Not enough data in the file for complete field %i (only %i out of %i values).',i,NRead,prod(dim));
                if i==1 % most probably wrong file format
                    error(Str)
                else
                    warning(Str)
                end
            else
                error('Invalid string while reading data: %s',Rem)
            end
        end
        pos=ftell(fid);
        if isempty(fscanf(fid,'%f',1))
            break % no more data (at least not readable)
        elseif ~multiple
            fprintf('More data in the file. Use ''multiple'' option to read all fields.\n');
            break % don't read data although there seems to be more ...
        end
        fseek(fid,pos,-1);
        i=i+1;
    end
    fclose(fid);
catch
    fclose(fid);
    rethrow(lasterror)
end
if ~multiple
    DP=DP.Data;
end


function OK=Local_depwrite_Xbeach(filename,varargin)
% DEPWRITE writes depth information to a given filename
%
% Usage: depwrite('filename',Matrix)
%
%    or: depwrite('filename',Struct)
%        where Struct is a structure vector with one field: Data

fid=fopen(filename,'w');
Keyword='';
interactive = length(varargin)==1;
format = '%15.8f';
idp = 0;
while idp<length(varargin)
    idp = idp+1;
    DP = varargin{idp};
    %
    if ischar(DP)
        if idp==length(varargin)
            % ignore this last argument
        else
            DP2 = varargin{idp+1};
            if strcmpi(DP,'format') && ischar(DP2)
                format = DP2;
                idp = idp+1;
            else
                Keyword = DP;
            end
        end
    elseif isstruct(DP)
        % DP(1:N).Data=Matrix;
        
        for i=1:length(DP)
            if isfield(DP,'Keyword')
                Keyword = DP(i).Keyword;
            else
                Keyword = '';
            end
            writeblock_Xbeach(fid,DP(i).Data,Keyword,format);
        end
        Keyword = '';
    else
        % DP=Matrix;
        if DP(end,end)~=-999 && interactive
            switch input('Negate data points? (Y/N) ','s')
                case {'Y','y'}
                    DP=-DP;
                otherwise
            end
            switch input('Grid extension: 9 (-999 values)/B (boundary values) /N (Don''t extend) ','s')
                case {'9'}
                    DP=[DP -999*ones(size(DP,1),1); ...
                        -999*ones(1,size(DP,2)+1)];
                case {'B','b'}
                    DP=[DP DP(:,end); ...
                        DP(end,:) DP(end,end)];
                otherwise
            end
        end
        writeblock_Xbeach(fid,DP,Keyword,format);
        Keyword = '';
    end
end
fclose(fid);
OK=1;


function writeblock_Xbeach(fid,DP,Keyword,format)
if ~isempty(Keyword)
    fprintf(fid,'''%s''\n',Keyword);
end

DP(isnan(DP))=-999;

lformat = length(format)+2;
Frmt=repmat([format '  '],[1 size(DP,1)]);
k=lformat*12;
Frmt((k-1):k:length(Frmt))='\';
Frmt(k:k:length(Frmt))='n';
Frmt(end-1:end)='\n';
Frmt=strrep(Frmt,'  ',' ');

szDP=size(DP);
if length(szDP)<3
    kmax=1;
else
    kmax=prod(szDP(3:end));
end
for k=1:kmax
    fprintf(fid,Frmt,DP(:,:,k));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               WLGRID Xbeach                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=wlgrid_Xbeach(cmd,varargin)
%WLGRID Read/write a Delft3D grid file.
%   GRID = WLGRID('read',FILENAME) reads a Delft3D or SWAN grid file and
%   returns a structure containing all grid information.
%
%   [X,Y,ENC,CS,nodatavalue] = WLGRID('read',FILENAME) reads a Delft3D
%   or SWAN grid file and returns X coordinates, Y coordinates, grid
%   enclosure and coordinate system string and nodatavalue separately.
%
%   OK = WLGRID('write','PropName1',PropVal1,'PropName2',PropVal2, ...)
%   writes a grid file. The following property names are accepted when
%   following the write command
%     'FileName'        : Name of file to write
%     'X'               : X-coordinates (can be a 1D vector 'stick' of an
%                         orthogonal grid)
%     'Y'               : Y-coordinates (can be a 1D vector 'stick' of an
%                         orthogonal grid)
%     'Enclosure'       : Enclosure array
%     'CoordinateSystem': Coordinate system 'Cartesian' (default) or
%                         'Spherical'
%     'Format'          : 'NewRGF'   - keyword based, double precision file
%                                      (default)
%                         'OldRGF'   - single precision file
%                         'SWANgrid' - SWAN formatted single precision file
%     'MissingValue'    : Missing value to be used for NaN coordinates
%
%   Accepted without property name: x-coordinates, y-coordinates and
%   enclosure array (in this order), file name, file format, coordinate
%   system strings 'Cartesian' and 'Spherical' (non-abbreviated).
%
%   See also ENCLOSURE, WLDEP.

%----- LGPL --------------------------------------------------------------------
%
%   Copyright (C) 2011-2012 Stichting Deltares.
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation version 2.1.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, see <http://www.gnu.org/licenses/>.
%
%   contact: delft3d.support@deltares.nl
%   Stichting Deltares
%   P.O. Box 177
%   2600 MH Delft, The Netherlands
%
%   All indications and logos of, and references to, "Delft3D" and "Deltares"
%   are registered trademarks of Stichting Deltares, and remain the property of
%   Stichting Deltares. All rights reserved.
%
%-------------------------------------------------------------------------------
%   http://www.deltaressystems.com
%   $HeadURL: https://svn.oss.deltares.nl/repos/delft3d/trunk/src/tools_lgpl/matlab/quickplot/progsrc/wlgrid.m $
%   $Id: wlgrid.m 1482 2012-05-14 05:21:37Z jagers $

if nargin==0
   if nargout>0
      varargout=cell(1,nargout);
   end
   return
end

switch lower(cmd)
   case {'read','open'}
      Grid=Local_read_grid_Xbeach(varargin{:});
      if nargout<=1
         varargout{1}=Grid;
      else
         varargout={Grid.X Grid.Y Grid.Enclosure Grid.CoordinateSystem Grid.MissingValue};
      end
   case {'write'}
      Out=Local_write_grid_Xbeach('newrgf',varargin{:});
      if nargout>0
         varargout{1}=Out;
      end
   case {'writeold'}
      Out=Local_write_grid_Xbeach('oldrgf',varargin{:});
      if nargout>0
         varargout{1}=Out;
      end
   case {'writeswan'}
      Out=Local_write_grid_Xbeach('swangrid',varargin{:});
      if nargout>0
         varargout{1}=Out;
      end
   otherwise
      error('Unknown command')
end


function GRID=Local_read_grid_Xbeach(filename)
GRID.X                = [];
GRID.Y                = [];
GRID.Enclosure        = [];
GRID.FileName         = '';
GRID.CoordinateSystem = 'Unknown';
GRID.MissingValue     = 0;

if (nargin==0) || strcmp(filename,'?')
   [fname,fpath]=uigetfile('*.*','Select grid file');
   if ~ischar(fname)
      return
   end
   filename=fullfile(fpath,fname);
end

% detect extension
[path,name,ext]=fileparts(filename);
if isempty(ext)
   if ~exist(filename)
      % add default .grd extension
      ext='.grd';
   end
end
filename=fullfile(path,[name ext]);
basename=fullfile(path,name);
GRID.FileName=filename;

% Grid file
gridtype='RGF';
fid=fopen(filename);
if fid<0
   error('Couldn''t open file: %s.',filename)
end
%
try
   prevlineoffset = 0;
   line=fgetl(fid);
   if ~isempty(strfind(lower(line),'spherical'))
   GRID.CoordinateSystem = 'Spherical';
   end
   while 1
   values = sscanf(line,'%f');
   if ~ischar(line)
      fclose(fid);
         error('The file is empty: %s.',filename)
      elseif ~isempty(line) && line(1)=='*'
      prevlineoffset = ftell(fid);
      line=fgetl(fid);
      elseif strcmp('x coordinates',deblank(line)) || strcmp('x-coordinates',deblank(line))
      gridtype='SWAN';
      GRID.CoordinateSystem='Cartesian';
      break
      elseif prevlineoffset == 0 && length(values)>3
      gridtype='ECOMSED-corners';
      break
   else
      EqualSign = strfind(line,'=');
      if ~isempty(EqualSign)
         keyword = deblank2(line(1:EqualSign(1)-1));
         switch keyword
            case 'Coordinate System'
               GRID.CoordinateSystem=deblank2(line(EqualSign(1)+1:end));
            case 'Missing Value'
                  GRID.MissingValue=str2double(line(EqualSign(1)+1:end));
         end
         prevlineoffset = ftell(fid);
         line=fgetl(fid);
      else
         % Not a line containing a keyword. This can happen if it is an old
         % grid file with the first line starting with a *, in which case
         % this line should not yet have been read. Or it can be an old
         % file,where the first line does not start with a *, in which case
         % this line should be skipped anyway. To distinguish between these
         % two cases, check prevlineoffset: if it is zero, then this is the
         % first line and it should be skipped, otherwise unskip this line.
         if prevlineoffset>0
            fseek(fid,prevlineoffset,-1);
         end
         break
      end
   end
   end
   %
   grdsize=[];
   switch gridtype
   case 'RGF'
      while 1
         line=fgetl(fid);
            if ~ischar(line)
            break
         end
            if isempty(deblank(line)) && isempty(grdsize)
         elseif line(1)=='*'
            % skip comment
         else
            grdsize_f=transpose(sscanf(line,'%f'));
            grdsize=transpose(sscanf(line,'%i'));
            %
            % don't continue if there are floating point numbers on the
            % grid size line.
            %
            if length(grdsize_f) > length(grdsize)
               error('Floating point number in line that should contain grid dimensions\n%s',line)
            end
            %
               fgetl(fid); % read xori,yori,alfori
            if length(grdsize)>2 % the possible third element contains the number of subgrids
               if grdsize(3)>1
                  for i=1:(2*grdsize(3)) % read subgrid definitions
                        fgetl(fid);
                  end
               end
            end
            if isempty(grdsize)
                  error('Cannot determine grid size.')
            end
            grdsize=grdsize(1:2);
            floc=ftell(fid);
            str=fscanf(fid,'%11c',1);
            fseek(fid,floc,-1);
            cc = sscanf(str,' %*[Ee]%*[Tt]%*[Aa] = %i',1);
            readETA=0;
            if ~isempty(cc)
               readETA=1;
            end
            GRID.X=-999*ones(grdsize);
            for c=1:grdsize(2)
               if readETA
                     fscanf(fid,' %*[Ee]%*[Tt]%*[Aa] = %i',1); % skip line header ETA= and read c
               else
                     fscanf(fid,'%11c',1); % this does not include the preceding EOL
               end
               GRID.X(:,c)=fscanf(fid,'%f',[grdsize(1) 1]);
               if ~readETA
                   fgetl(fid); % read optional spaces and EOL
               end
            end
            GRID.Y=-999*ones(grdsize);
            for c=1:grdsize(2)
               if readETA
                     fscanf(fid,' %*[Ee]%*[Tt]%*[Aa] = %i',1); % skip line header ETA= and read c
               else
                     fscanf(fid,'%11c',1); % this does not include the preceding EOL
               end
               GRID.Y(:,c)=fscanf(fid,'%f',[grdsize(1) 1]);
               if ~readETA
                   fgetl(fid); % read optional spaces and EOL
               end
            end
            break
         end
      end
   case 'SWAN'
      %SWANgrid
      xCoords={};
      firstline=1;
      NCoordPerLine=0;
      while 1
         line=fgetl(fid);
         if firstline
             [Crd,cnt]=sscanf(line,'%f',[1 inf]);
             NCoordPerLine=cnt;
             firstline=0;
         else
             [Crd,cnt]=sscanf(line,'%f',[1 NCoordPerLine]);
         end
         if cnt>0
            xCoords{end+1}=Crd;
         end
         if cnt<NCoordPerLine
            break
         end
      end
      NCnt=-1;
      if cnt>0
         NCnt=(length(xCoords)-1)*NCoordPerLine+length(xCoords{end});
         while 1
            line=fgetl(fid);
            [Crd,cnt]=sscanf(line,'%f',[1 NCoordPerLine]);
            if cnt>0
               xCoords{end+1}=Crd;
            else
               break
            end
         end
      end
         if ~strcmp('y coordinates',deblank(line)) && ~strcmp('y-coordinates',deblank(line))
         error('y coordinates string expected.')
      end
      xCoords=cat(2,xCoords{:});
      yCoords=zeros(size(xCoords));
      offset=0;
      while 1
         line=fgetl(fid);
         if ~ischar(line)
            break;
         else
            [Crd,cnt]=sscanf(line,'%f',[1 NCoordPerLine]);
            if cnt>0
               yCoords(offset+(1:cnt))=Crd;
               offset=offset+cnt;
            else
               break
            end
         end
      end
      if NCnt<0
         %
         % Determine grid dimensions by finding the first large change in the
         % location of successive points. Does not work if the grid contains
         % "missing points" such as the FLOW grid.
         %
         dist=sqrt(diff(xCoords).^2+diff(yCoords).^2);
         NCnt=min(find(dist>max(dist)*0.9));
      end
      xCoords=reshape(xCoords,[NCnt length(xCoords)/NCnt]);
      yCoords=reshape(yCoords,[NCnt length(yCoords)/NCnt]);
      GRID.X=xCoords;
      GRID.Y=yCoords;
   case 'ECOMSED-corners'
      fseek(fid,0,-1);
      GRID = read_ecom_corners(fid);
      GRID.CoordinateSystem='Unknown';
      GRID.MissingValue=0;
   otherwise
         error('Unknown grid type: %s',gridtype)
   end
      fclose(fid);
catch
   fclose(fid);
   rethrow(lasterror)
end
if isempty(GRID.X)
   error('File does not match Delft3D grid file format.')
end
%
% XX=complex(GRID.X,GRID.Y);
% [YY,i1,i2]=unique(XX(:));
% ZZ=sparse(i2,1,1);
% [YYm,n]=max(ZZ);
% if YYm>1
%    Missing = XX==YY(n);
%    GRID.X(Missing)=NaN;
%    GRID.Y(Missing)=NaN;
% end
%
notdef=(GRID.X==GRID.MissingValue) & (GRID.Y==GRID.MissingValue);
GRID.X(notdef)=NaN;
GRID.Y(notdef)=NaN;
GRID.Type = gridtype;

% Grid enclosure file
fid=fopen([basename '.enc']);
if fid>0
   Enc = [];
   while 1
      line=fgetl(fid);
      if ~ischar(line)
         break
      end
      Enc=[Enc; sscanf(line,'%i',[1 2])];
   end
   GRID.Enclosure=Enc;
   fclose(fid);
else
   %warning('Grid enclosure not found.');
   [M,N]=size(GRID.X);
   GRID.Enclosure=[1 1; M+1 1; M+1 N+1; 1 N+1; 1 1];
end


function OK = Local_write_grid_Xbeach(varargin)
% GRDWRITE writes a grid file
%       GRDWRITE(FILENAME,GRID) writes the GRID to files that
%       can be used by Delft3D and TRISULA.

fileformat = 'newrgf';
%
i          = 1;
filename   = '';
nparset    = 0;
Grd.CoordinateSystem='Cartesian';
while i<=nargin
    if ischar(varargin{i})
        switch lower(varargin{i})
         case 'oldrgf'
            fileformat      ='oldrgf';
         case 'newrgf'
            fileformat      ='newrgf';
         case 'swangrid'
            fileformat      ='swangrid';
         case 'cartesian'
            Grd.CoordinateSystem='Cartesian';
         case 'spherical'
            Grd.CoordinateSystem='Spherical';
            otherwise
                Cmds = {'CoordinateSystem','MissingValue','Format', ...
                    'X','Y','Enclosure','FileName'};
                j = ustrcmpi(varargin{i},Cmds);
                if j>0
                    i=i+1;
                    switch Cmds{j}
                        case 'CoordinateSystem'
                            Cmds = {'Cartesian','Spherical'};
                            j = ustrcmpi(varargin{i},Cmds);
                            if j<0
                        error('Unknown coordinate system: %s',varargin{i})
                            else
                                Grd.CoordinateSystem=Cmds{j};
                            end
                  case 'MissingValue'
                     Grd.MissingValue = varargin{i};
                  case 'Format'
                     fileformat    = lower(varargin{i});
                  case 'X'
                     Grd.X         = varargin{i};
                  case 'Y'
                     Grd.Y         = varargin{i};
                  case 'Enclosure'
                     Grd.Enclosure = varargin{i};
                  case 'FileName'
                     filename      = varargin{i};
                    end
            elseif isempty(filename) && ~isempty(varargin{i})
                    filename=varargin{i};
                else
               error('Cannot interpret: %s',varargin{i})
                end
        end
    elseif isnumeric(varargin{i})
        switch nparset
         case 0
            Grd.X         = varargin{i};
         case 1
            Grd.Y         = varargin{i};
         case 2
            Grd.Enclosure = varargin{i};
         case 3
            error('Unexpected numerical argument.')
        end
        nparset = nparset+1;
    else
        Grd = varargin{i};
        if ~isfield(Grd,'CoordinateSystem')
            Grd.CoordinateSystem='Cartesian';
            if isfield(Grd,'CoordSys')
                Grd.CoordinateSystem = Grd.CoordSys;
                Grd = rmfield(Grd,'CoordSys');
            end
        end
    end
    i=i+1;
end

% allow to supply orthogonal grid defined with two 1D sticks
%  while making sure the resulting grid is RIGHT-HANDED
%  (when m is locally defined as x, n should locally point in positive y direction)
sz.x = size(Grd.X);
sz.y = size(Grd.Y);
if ~isequal(sz.x,sz.y)
   if min(sz.x(1:2))==1 && min(sz.y(1:2))==1
      [Grd.X,Grd.Y] = ndgrid(Grd.X(:),Grd.Y(:)); % NOT meshgrid, which leads not to righthanded coordinate system.
   else
      error(['X and Y should have same size:',num2str(sz.x),' vs. ',num2str(sz.y)])
   end
end

% enclosure
if ~isfield(Grd,'Enclosure')
   Grd.Enclosure=[];
end
if ~isfield(Grd,'MissingValue')
   Grd.MissingValue=0;
end

%
j = ustrcmpi(fileformat,{'oldrgf','newrgf','swangrid'});
switch j
   case 1
      Format='%11.3f';
   case 2
      Format='%25.17e';
   case 3
      Format='%15.8f';
   otherwise
      Format=fileformat;
           fileformat='newrgf';
end
if isfield(Grd,'Format')
   Format=Grd.Format;
end

%
if Format(end)=='f'
   ndec       = sscanf(Format,'%%%*i.%i');
   coord_eps  = 10^(-ndec);
else
   coord_eps  = eps*max(1,abs(Grd.MissingValue));
end

% move any points that have x-coordinate/y-coordinate equal to missing
% value coordinate
Grd.X(Grd.X==Grd.MissingValue)=Grd.MissingValue+coord_eps;
Grd.Y(Grd.Y==Grd.MissingValue)=Grd.MissingValue+coord_eps;
Idx=isnan(Grd.X.*Grd.Y);                % change indicator of grid point exclusion
Grd.X(Idx)=Grd.MissingValue;            % from NaN in Matlab to (0,0) in grid file.
Grd.Y(Idx)=Grd.MissingValue;

% detect extension
[path,name,ext]=fileparts(filename);
if isempty(ext)
    ext='.grd';
end % default .grd file
filename=fullfile(path,[name ext]);
basename=fullfile(path,name);

if ~isempty(Grd.Enclosure),
   fid=fopen([basename '.enc'],'w');
   if fid<0
      error('* Could not open output file.')
   end
   fprintf(fid,'%5i%5i\n',Grd.Enclosure');
   fclose(fid);
end

% write
fid=fopen(filename,'w');
if strcmp(fileformat,'oldrgf') || strcmp(fileformat,'newrgf')
   if strcmp(fileformat,'oldrgf')
      fprintf(fid,'* MATLAB Version %s file created at %s.\n',version,datestr(now));
   elseif strcmp(fileformat,'newrgf')
      fprintf(fid,'Coordinate System = %s\n',Grd.CoordinateSystem);
      if isfield(Grd,'MissingValue') && Grd.MissingValue~=0
         fprintf(fid,['Missing Value = ' Format '\n'],Grd.MissingValue);
      end
   end
   fprintf(fid,'%8i%8i\n',size(Grd.X));
   fprintf(fid,'%8i%8i%8i\n',0,0,0);
   Format=cat(2,' ',Format);
   M=size(Grd.X,1);
   for fld={'X','Y'}
      fldx=fld{1};
      coords = Grd.(fldx);
      for j=1:size(coords,2)
         fprintf(fid,' ETA=%5i',j);
         fprintf(fid,Format,coords(1:min(5,M),j));
         if M>5
            fprintf(fid,cat(2,'\n          ',repmat(Format,1,5)),coords(6:M,j));
         end
         fprintf(fid,'\n');
      end
   end
elseif strcmp(fileformat,'swangrid')
   for fld={'X','Y'}
      fldx  =fld{1};
      fprintf(fid,'%s%s\n',lower(fldx),'-coordinates');
      coords = Grd.(fldx);
      Frmt  =repmat('%15.8f  ',[1 size(coords,1)]);
      k=8*3;
      Frmt((k-1):k:length(Frmt))='\';
      Frmt( k   :k:length(Frmt))='n';
      Frmt(end-1:end)='\n';
      fprintf(fid,Frmt,coords);
   end
end
%---------
fclose(fid);
OK=1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Positions                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [height,width]=positionsSafely(varargin)
oldRootUnits = get(0,'Units');
% Restore the Units safely
c = onCleanup(@()set(0, 'Units', oldRootUnits));
set(0, 'Units', 'normalized');
screenSize = get(0,'ScreenSize'); delete(c);
axFontSize=6; set(0,'ScreenPixelsPerInch',96);
pointsPerPixel = 72/get(0,'ScreenPixelsPerInch');
width = 800 * pointsPerPixel;
height = 600 * pointsPerPixel;

% invCLR=uimenu(fViewarea,'label','Invert Colormap','callback',@(fViewarea)colormap(flipud(get(fViewarea,'colormap')))');

% JEditorPane
% Add a "Next phase" button to the right of the text
% jb = javax.swing.JButton('Next phase >');
% jbh = handle(jb,'CallbackProperties');
% set(jbh, 'ActionPerformedCallback', @nextPhaseFunction);
% statusbarObj.add(jb,'East');
% %note: we might need jRootPane.setStatusBarVisible(0)
% % followed by jRootPane.setStatusBarVisible(1) to repaint
%
% % Add a simple Matlab uicontrol, obscured by the status-bar
% hb = uicontrol('string','click me!', 'position',[10,15,70,30]);

% STATUS BAR
% hFig=figure;
% jFrame = get(hFig,'JavaFrame');
% jRootPane = jFrame.fFigureClient.getWindow;
% statusbarObj = com.mathworks.mwswing.MJStatusBar;
% jRootPane.setStatusBar(statusbarObj);
% statusbarObj.setText(statusText);
