% iotest plot library

% TODO
global hide_legend = 0
global hide_title = 0
global no_errorbar = 1
global plot_linewidth = 2
global plot_markersize = 12
global base_fontsize = 12
global base_linewidth = 0.25 % grids
global legend_fontsize = 12
% default six in one page
global papersize = [6 5]
global paperposition = [0,0,[6 5]]
global position = [0.11 0.1 0.867 0.84]
global position_no_title = [0.11 0.1 0.867 0.887]

% TODO
function print_to_file(name,h=gcf)
 %legend_text = findobj(h, 'type', 'axes', 'tag', 'legend');
 %set(legend_text, 'fontsize', 9);
% print(h,'-dpdf','-color', [name '.pdf']);
% print(h,'-dpng','-color', [name '.png']);
 print(h,'-depsc2', '-color', [name '.eps']);
% print(h,'-depslatex', '-color', name);
% print(h,'-dtikz', '-color', name);
endfunction

% iotest shared legends for f,bs,op
%global typical_target_legends = {[1 1],[1 2],[2 1],[2 2],[3 1],[3 2],[5 0]};
global typical_target_legends = {[1 1],[1 2],[2 1],[2 2],[5 0]};

% Aalto colours
global black = [0 0 0];
global gray = [146/255 139/255 129/255];
global red = [237/255 41/255 57/255];
global blue = [0 101/255 189/255];
global yellow = [254/255 203/255 0];
global purple = [102/255 57/255 183/255];
global green = [0 155/255 58/255];
global orange = [1 121/255 0];
global turquoise = [0 168/255 180/255];
global fuchsia = [177/255 5/255 157/255];

function set_paper()
 h = figure();
 set (h,'papertype', '<custom>')
 set (h,'paperunits','inches')
 global papersize
 set (h,'papersize', papersize)
 global paperposition
 set (h,'paperposition', paperposition)
 global base_fontsize
 set (0,'defaultaxesfontsize', base_fontsize)
 set (0,'defaulttextfontsize', base_fontsize)
endfunction

function H = common_preparation(scenario=0)
 set_paper()
 newplot()
 H = gca();
 global hide_title
 if (0 == hide_title)
  global position
  set(H,'position', position)
 else
  global position_no_title
  set(H,'position', position_no_title)
 endif
 set(H,'gridlinestyle', ":")
 global base_linewidth
 set(H,'linewidth', base_linewidth)
 cla(H,'reset')
 hold on
endfunction

function set_axis(HAX, target, flag)
 global black
 global gray
 global red
 global blue
 global yellow
 global purple
 global green
 global orange
 global turquoise
 global fuchsia
 % defaults
 color = black;
 marker = '^';
 global plot_markersize
 markersize = plot_markersize;
 linestyle = "-";
 global plot_linewidth
 linewidth = plot_linewidth;

 flag_def = 0;
 flag_d = 1;
 flag_s = 2;
 flag_ds = 3;
 if (1 == strcmp(flag, 'def'))
  i_flag = flag_def;
 elseif (1 == strcmp(flag, 'd'))
  i_flag = flag_d;
 elseif (1 == strcmp(flag, 's'))
  i_flag = flag_s;
 elseif (1 == strcmp(flag, 'ds'))
  i_flag = flag_ds;
 else
  error(['ERROR invalid flag: ' flag])
 endif

 switch (target)
  case 0 % Baseline - local disk
   switch (i_flag)
    case flag_d
     linestyle = ":";
     marker = '+';
     color = blue;
    case flag_s
     linestyle = "--";
     marker = 'o';
     color = red;
   endswitch
  case 1 % NFS
   linestyle = ":";
   linewidth = plot_linewidth + 1;
   switch (i_flag)
    case flag_def
     color = turquoise;
     marker = 'x';
    case flag_d
     color = blue;
     marker = '+';
    case flag_s
     color = purple;
     marker = 'o';
   endswitch
  case 2 % iSCSI CFQ
   linestyle = "--";
   switch (i_flag)
    case flag_def
     color = green;
     marker = 's';
    case flag_d
     color = red;
     marker = '*';
    case flag_s
     color = orange;
     marker = '.';
   endswitch
  case 3 % iSCSI deadline
   linestyle = "-.";
   switch (i_flag)
    case flag_d
     color = turquoise;
     marker = 'x';
     linestyle = '--';
    case flag_s
     color = green;
     marker = 's';
   endswitch
  case 4 % iSCSI noop
   switch (i_flag)
    case flag_d
     ;
    case flag_s
     ;
   endswitch
  case 5 % Swift+CloudFuse
   linestyle = "-";
   linewidth = plot_linewidth - 1;
   switch (i_flag)
    case flag_def
     color = black;
     marker = 'p';
   endswitch
 endswitch

 set(HAX, 'color', color)
 set(HAX, 'marker', marker)
 set(HAX, 'markersize', markersize)
 set(HAX, 'linewidth', linewidth)
 set(HAX, 'linestyle', linestyle)
endfunction
 
function N = get_scenario_remark(scenario)
 global scenario_remark_list
 try
  % Octave array index starts from 1
  N = scenario_remark_list(scenario+1);
 catch
  N = ['Unknown scenario:' num2str(scenario)];
 end_try_catch
endfunction

function make_legend(HAX, targets, location = 'northwest', side = 'right')
 legends = {};
 for t = targets
  s = t{1,1};
  target = s(1);
  i_flag = s(2);
  switch (target)
   case 0
    name = 'Local CFQ';
   case 1
    name = 'NFS';
   case 2
    name = 'iSCSI CFQ';
   case 3
    name = 'iSCSI deadline';
   case 4
    name = 'iSCSI NOOP';
   case 5
    name = 'Swift/FUSE';
   otherwise
    name = 'undefined';
  endswitch
  switch (i_flag)
   case -1
    flag = '';
   case 0
    flag = 'default';
   case 1
    flag = 'direct';
   case 2
    flag = 'sync';
   case 3
    flag = 'direct+sync';
   otherwise
    flag = 'undefined';
  endswitch
  legends = [legends [name ' ' flag]];
   endfor
 try
  legend(HAX, side);
  legend(HAX, 'boxoff');
  hl = legend(HAX, legends, 'location', location);
  global legend_fontsize
  set(hl, 'fontsize', legend_fontsize);
  global hide_legend
  if (1 == hide_legend)
   %display('hiding legend')
   legend(HAX, 'hide');
  endif
 catch
  display(['legend error: ' lasterror.message])
 end_try_catch
endfunction

function th = make_title(h = gca, text = 'empty string')
 th = 0;
 global hide_title
 if (1 == hide_title)
  return;
 endif
 th = title(h, text);
endfunction

% Include other libraries

% Metadata functions
run meta.lib.m
% Block-Size functions
run bs.lib.m
% One-File functions
run op.lib.m
% File test functions
run f.lib.m
% Macrobenchmark functions
run macro.lib.m
% 3D plotting functions
run 3d.lib.m
% boxplot functions
run box.lib.m

