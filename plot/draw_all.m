clear
clc
close all

run lib.m;

function plot_single_thread(scenarios)
 display("single thread")
 parfor s = scenarios
  plot_fs_and_flag_1thread(s, 'r')
  plot_fs_and_flag_1thread(s, 'w')
 endparfor
endfunction

function plot_delay(prefix)
 display("meta vs delay")
 plot_meta_time_vs_delay(prefix, 'mkdir')
 plot_meta_npkt_vs_delay(prefix, 'mkdir')
 plot_meta_pktsz_vs_delay(prefix, 'mkdir')
 plot_meta_time_vs_delay(prefix, 'ls')
 plot_meta_npkt_vs_delay(prefix, 'ls')
 plot_meta_pktsz_vs_delay(prefix, 'ls')
 display("file vs delay")
 parfor j = [4096 1048576 16777216]
  for n = [1 8 32]
   plot_thp_vs_delay(prefix, n, j, 'r')
   plot_thp_vs_delay(prefix, n, j, 'w')
  endfor
 endparfor
endfunction

function plot_loss(prefix)
 display("meta vs loss")
 plot_meta_time_vs_loss(prefix, 'mkdir')
 plot_meta_npkt_vs_loss(prefix, 'mkdir')
 plot_meta_pktsz_vs_loss(prefix, 'mkdir')
 plot_meta_time_vs_loss(prefix, 'ls')
 plot_meta_npkt_vs_loss(prefix, 'ls')
 plot_meta_pktsz_vs_loss(prefix, 'ls')
 display("file vs loss")
 parfor j = [4096 1048576 16777216]
  for n = [1 8 32]
   plot_thp_vs_loss(prefix, n, j, 'r')
   plot_thp_vs_loss(prefix, n, j, 'w')
  endfor
 endparfor
endfunction

function plot_nthreads(scenarios, legendpos = 'northwest')
 display("nthreads")
 parfor s = scenarios
  for j = [4096 1048576 16777216]
  plot_fs_and_flag_vs_nthreads(s, j, 'r')
  plot_fs_and_flag_vs_nthreads(s, j, 'w')
  endfor
 endparfor
endfunction

function plot_bs(scenarios)
 display("access unit size (bs)")
 parfor s = scenarios
  plot_thp_vs_bs(s, 'r')
  plot_thp_vs_bs(s, 'w')
 endparfor
endfunction

function plot_op(scenarios)
 display("one file (op)")
 parfor s = scenarios
  plot_op_scenario(s, 'r')
  plot_op_scenario(s, 'w')
  plot_op_overhead_scenario(s, 'r')
  plot_op_overhead_scenario(s, 'w')
 endparfor
endfunction

function plot_meta(scenarios)
 display("metadata")
 parfor s = scenarios
  plot_meta_time(s, 'mkdir')
  plot_meta_npkt(s, 'mkdir')
  plot_meta_pktsz(s, 'mkdir')
  plot_meta_time(s, 'ls')
  plot_meta_npkt(s, 'ls')
  plot_meta_pktsz(s, 'ls')
 endparfor
endfunction

function plot_baseline()
 display("baseline")
 for j = [4096 1048576 16777216]
  plot_baseline_nthreads(j, 'r')
  plot_baseline_nthreads(j, 'w')
 endfor
 plot_baseline_bs('r')
 plot_baseline_bs('w')
 plot_baseline_op('r')
 plot_baseline_op('w')
 plot_baseline_meta_time('mkdir')
 plot_baseline_meta_time('ls')
 plot_baseline_1thread('r')
 plot_baseline_1thread('w')
endfunction

function plot_3d()
 display("3d plots")

 t = [1 1 2 2 3 3 5];
 f = {'d' 's' 'd' 's' 'd' 's' 'def'};
 rw_set = {'r' 'w'};
 prefix = {'GbE' 'FastE'};
 job_size = [ 4096 1048576 16777216 ];

 parfor i = [1 2 3 4 5 6 7]
  for j = rw_set
   for k = prefix
    rw = j{1,1};
    pf = k{1,1};
    plot3d_4args_print('bs_vs_delay', pf, t(i), f(i){1,1}, rw)
    plot3d_4args_print('bs_vs_loss', pf, t(i), f(i){1,1}, rw)
    plot3d_4args_print('op_vs_delay', pf, t(i), f(i){1,1}, rw)
    plot3d_4args_print('op_vs_loss', pf, t(i), f(i){1,1}, rw)
    for jsz = job_size
     plot3d_5args_print('nthreads_vs_delay', pf, t(i), f(i){1,1}, jsz, rw)
     plot3d_5args_print('nthreads_vs_loss', pf, t(i), f(i){1,1}, jsz, rw)
    endfor
   endfor
  endfor
 endparfor
endfunction

function plot_macro()
 display("macrobenchmark")
 b = [1 2 3 3];
 c = [1 2 3 4];
 prefix = {'GbE' 'FastE'};

 parfor j = c
  for i = prefix
   p = i{1,1};
   plot_macro_iops_vs_delay(p, b(j), j)
   plot_macro_iops_vs_loss(p, b(j), j)
   plot_macro_time_vs_delay(p, b(j), j)
   plot_macro_time_vs_loss(p, b(j), j)
  endfor
 endparfor
endfunction

% ++++++++++++++++++++++++++++++++++++

run data.m;

% TODO: local configurations
hide_legend = 0
hide_title = 0
no_errorbar = 0

function print_to_file(name,h=gcf)
 print(h,'-dpng','-color', [name '.png'])
endfunction
% -----------------

scenarios = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27];

plot_bs(scenarios)
plot_meta(scenarios)
plot_nthreads(scenarios)
plot_op(scenarios)

plot_single_thread([1 2 3 4 5 6 7 8 16 17 24 26 27])

plot_delay('GbE')
plot_loss('GbE')

plot_delay('FastE')
plot_loss('FastE')

plot_baseline()

plot_3d()

plot_macro()

