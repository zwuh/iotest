clear
clc
close all

run lib.m
run boxdat.m

% TODO: local configurations
hide_legend = 0
hide_title = 0

function print_to_file(name,h=gcf)
 print(h,'-dpng','-color', [name '.png'])
endfunction
% -----------------

scenario_list = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27];
fs_list = [1 2 3 4 5];
rw_list = {'r', 'w'};
job_size_list = [4096 1048576 16777216];
flag_list = {'d','s'};
meta_op_list = {'ls','mkdir'};
sth_scenario_list = [1 2 3 4 5 6 7 8 16 17 24 26 27];
bs_def_scenario_list = [1 3 5 7];

% baseline
for op = meta_op_list
 plot_box('meta', 0, 0, op{1,1})
endfor
parfor _rw = rw_list
 rw = _rw{1,1};
 for _flag = flag_list
  flag = _flag{1,1};
  for job_size = job_size_list
   plot_box('nthread', 0, 0, flag, rw, job_size)
  endfor
  plot_box('bs', 0, 0, flag, rw)
  plot_box('1thread', 0, 0, flag, rw)
  plot_box('op', 0, 0, flag, rw)
 endfor
endparfor

plot_box_macro(0, 1, 1)
plot_box_macro(0, 2, 2)
plot_box_macro(0, 3, 3)
plot_box_macro(0, 3, 4)


% network
parfor scenario = scenario_list
 for fs = fs_list
  for _op = meta_op_list
   op = _op{1,1};
   plot_box('meta', scenario, fs, op)
  endfor

  for _rw = rw_list
   rw = _rw{1,1};
   if (fs == 5)
    for job_size = job_size_list
     plot_box('nthread', scenario, fs, 'def', rw, job_size)
    endfor
    plot_box('bs', scenario, fs, 'def', rw)
    plot_box('op', scenario, fs, 'def', rw)
   else
    for _flag = flag_list
     flag = _flag{1,1};
     for job_size = job_size_list
      plot_box('nthread', scenario, fs, flag, rw, job_size)
     endfor
     plot_box('bs', scenario, fs, flag, rw)
     plot_box('op', scenario, fs, flag, rw)
    endfor
   endif
  endfor
 endfor
endparfor

parfor scenario = sth_scenario_list
 for _rw = rw_list
  rw = _rw{1,1};
  for fs = fs_list
   if (fs == 5)
    plot_box('1thread', scenario, fs, 'def')
   else
    plot_box('1thread', scenario, fs, 'd')
    plot_box('1thread', scenario, fs, 's')
   endif
  endfor
 endfor
endparfor

parfor scenario = bs_def_scenario_list
 for _rw = rw_list
  rw = _rw{1,1};
  plot_box('bs', scenario, 1, 'def', rw)
  plot_box('bs', scenario, 2, 'def', rw)
  plot_box('bs', scenario, 3, 'def', rw)
 endfor
endparfor

parfor fs = fs_list
 plot_box_macro(fs, 1, 1)
 plot_box_macro(fs, 2, 2)
 plot_box_macro(fs, 3, 3)
 plot_box_macro(fs, 3, 4)
endparfor

