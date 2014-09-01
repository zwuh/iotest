% metadata plotting functions
% TODO include this from lib.m

%global metadata_target_legends = {[1 -1],[2 -1],[3 -1],[5 -1]}
global metadata_target_legends = {[1 -1],[2 -1],[5 -1]}

function [A D] = get_metaTIME_array(scenario, target, op)
 name = ['metaTIME_c' num2str(scenario) '_t' num2str(target) '_' op];
 eval(['global ' name]);
 A = eval(name);
 name = ['metaTIMEdev_c' num2str(scenario) '_t' num2str(target) '_' op];
 eval(['global ' name]);
 D = eval(name);
endfunction

function [A D] = get_metaNPKT_array(scenario, target, op)
 name = ['metaNPKT_c' num2str(scenario) '_t' num2str(target) '_' op];
 eval(['global ' name]);
 A = eval(name);
 name = ['metaNPKTdev_c' num2str(scenario) '_t' num2str(target) '_' op];
 eval(['global ' name]);
 D = eval(name);
endfunction

function [A D] = get_metaPKTSZ_array(scenario, target, op)
 name = ['metaPKTSZ_c' num2str(scenario) '_t' num2str(target) '_' op];
 eval(['global ' name]);
 A = eval(name);
 name = ['metaPKTSZdev_c' num2str(scenario) '_t' num2str(target) '_' op];
 eval(['global ' name]);
 D = eval(name);
endfunction

function meta_set_x_tick(h, op)
 if (1 == strcmp(op, 'ls'))
  xlabel(h, 'Directory Size (objects)')
  set(h, 'xticklabel', {'2', '20', '200', '2K'})
 else
  xlabel(h, 'Number of Operations')
  set(h, 'xticklabel', {'1', '10', '100', '1K'})
 endif
endfunction

function AX = plot_meta_time_one_line(h, scenario, fs, op, x_axis)
 [A D] = get_metaTIME_array(scenario, fs, op);
 global no_errorbar
 if (no_errorbar == 1)
  AX = plot(h, x_axis, A);
 else
  AX = errorbar(h, x_axis, A, D, "~");
 endif
 if (5 == fs)
  set_axis(AX, fs, 'def');
 else
  set_axis(AX, fs, 's');
 endif
endfunction

function plot_meta_time_core(h, scenario, op)
 x_axis = [0 1 2 3];
 ax_nfs = plot_meta_time_one_line(h, scenario, 1, op, x_axis);
 ax_iscsi_cfq = plot_meta_time_one_line(h, scenario, 2, op, x_axis);
 ax_iscsi_dead = plot_meta_time_one_line(h, scenario, 3, op, x_axis);
 ax_fuse = plot_meta_time_one_line(h, scenario, 5, op, x_axis);

 set(h, 'xlim', [-0.1 3.1])
 set(h, 'xtick', x_axis)
 meta_set_x_tick(h, op)
 ylabel(h, 'Completion Time (seconds)')
 %set(h, 'ygrid', 'on')
endfunction

function plot_meta_time(scenario, op, legendpos = 'northwest')
 h = common_preparation();

 plot_meta_time_core(h, scenario, op)
 global metadata_target_legends
 make_legend(h, metadata_target_legends, legendpos)
 tx = make_title(h, strcat('Metadata - ', get_scenario_remark(scenario), ' - ', op));

 print_to_file(['metaTIME_c' num2str(scenario) '-' op])
 close(gcf)
endfunction

function plot_baseline_meta_time(op, legendpos = 'northwest')
 h = common_preparation();
 x_axis = [0 1 2 3];
 plot_meta_time_one_line(h, 0, 0, op, x_axis);
 set(h, 'xlim', [-0.1 3.1])
 set(h, 'xtick', x_axis)
 meta_set_x_tick(h, op)
 ylabel(h, 'Completion Time (seconds)')
 %set(h, 'ygrid', 'on')
 print_to_file(['baseline_metaTIME_' op])
 close(gcf)
endfunction

function AX = plot_meta_npkt_one_line(h, scenario, fs, op, x_axis)
 [A D] = get_metaNPKT_array(scenario, fs, op);
 global no_errorbar
 if (no_errorbar == 1)
  AX = semilogy(h, x_axis, A);
 else
  AX = semilogyerr(h, x_axis, A, D, "~");
 endif
 if (5 == fs)
  set_axis(AX, fs, 'def');
 else
  set_axis(AX, fs, 's');
 endif
endfunction

function plot_meta_npkt_core(h, scenario, op)
 x_axis = [0 1 2 3];
 plot_meta_npkt_one_line(h, scenario, 1, op, x_axis);
 plot_meta_npkt_one_line(h, scenario, 2, op, x_axis);
 plot_meta_npkt_one_line(h, scenario, 5, op, x_axis);
 set(h, 'xlim', [-0.1 3.1])
 set(h, 'xtick', x_axis)
 meta_set_x_tick(h, op)
 axis('tight')
 if (max(get(h,'ytick')) >= 10000)
  set(h, 'ytick', [1 10 50 100 400 700 1000 4000 8000 14000])
  set(h, 'yticklabel', {'1','10','50','100','400','700','1K','4K','8K','14K'})
 endif
 ylabel(h, 'Number of Packets')
endfunction

function plot_meta_npkt(scenario, op, legendpos = 'northwest')
 h = common_preparation();

 plot_meta_npkt_core(h, scenario, op)
 global metadata_target_legends
 make_legend(h, metadata_target_legends, legendpos)
 tx = make_title(h, strcat('Metadata - ', get_scenario_remark(scenario), ' - ', op));

 print_to_file(['metaNPKT_c' num2str(scenario) '-' op])
 close(gcf)
endfunction

function AX = plot_meta_pktsz_one_line(h, scenario, fs, op, x_axis)
 [A D] = get_metaPKTSZ_array(scenario, fs, op);
 global no_errorbar
 if (no_errorbar == 1)
  AX = plot(h, x_axis, A);
 else
  AX = errorbar(h, x_axis, A, D, "~");
 endif
 if (5 == fs)
  set_axis(AX, fs, 'def');
 else
  set_axis(AX, fs, 's');
 endif
endfunction

function plot_meta_pktsz_core(h, scenario, op)
 x_axis = [0 1 2 3];
 plot_meta_pktsz_one_line(h, scenario, 1, op, x_axis);
 plot_meta_pktsz_one_line(h, scenario, 2, op, x_axis);
 plot_meta_pktsz_one_line(h, scenario, 5, op, x_axis);
 set(h, 'xlim', [-0.1 3.1])
 set(h, 'xtick', x_axis)
 meta_set_x_tick(h, op)
 ylabel(h, 'Mean Packet Size (bytes)')
 ylim(h, [100 1500])
 set(h, 'ytick', [100 200 300 400 700 1000 1100 1300])
 %set(h, 'ygrid', 'on')
endfunction

function plot_meta_pktsz(scenario, op, legendpos = 'northwest')
 h = common_preparation();

 plot_meta_pktsz_core(h, scenario, op)
 global metadata_target_legends
 make_legend(h, metadata_target_legends, legendpos)
 tx = make_title(h, strcat('Metadata - ', get_scenario_remark(scenario), ' - ', op));

 print_to_file(['metaPKTSZ_c' num2str(scenario) '-' op])
 close(gcf)
endfunction

function [A D] = get_meta_sweep_array(prefix, fs, var, func, op)
 name = [prefix 'meta' var func '_t' num2str(fs) '_' op];
 eval(['global ' name]);
 A = eval(name);
 name = [prefix 'meta' var func 'dev_t' num2str(fs) '_' op];
 eval(['global ' name]);
 D = eval(name);
endfunction

function [A D] = get_meta_delayTIME_array(prefix, fs, op)
 [A D] = get_meta_sweep_array(prefix, fs, 'delay', 'TIME', op);
endfunction

function [A D] = get_meta_delayNPKT_array(prefix, fs, op)
 [A D] = get_meta_sweep_array(prefix, fs, 'delay', 'NPKT', op);
endfunction

function [A D] = get_meta_delayPKTSZ_array(prefix, fs, op)
 [A D] = get_meta_sweep_array(prefix, fs, 'delay', 'PKTSZ', op);
endfunction

function [A D] = get_meta_lossTIME_array(prefix, fs, op)
 [A D] = get_meta_sweep_array(prefix, fs, 'loss', 'TIME', op);
endfunction

function [A D] = get_meta_lossNPKT_array(prefix, fs, op)
 [A D] = get_meta_sweep_array(prefix, fs, 'loss', 'NPKT', op);
endfunction

function [A D] = get_meta_lossPKTSZ_array(prefix, fs, op)
 [A D] = get_meta_sweep_array(prefix, fs, 'loss', 'PKTSZ', op);
endfunction

function plot_meta_time_vs_delay(prefix, op, legendpos = 'northwest')
 h = common_preparation();
 plot_meta_time_vs_delay_core(h, prefix, op)
 global metadata_target_legends
 make_legend(h, metadata_target_legends, legendpos)
 tx = make_title(h, ['Delay test - TIME - ' prefix ' - ' op]);
 print_to_file(['metaTIMEdelay' prefix '_' op])
 close(gcf)
endfunction

function plot_meta_time_vs_delay_one_line(h, prefix, fs, op, x_axis)
 [A D] = get_meta_delayTIME_array(prefix, fs, op);
 global no_errorbar
 if (no_errorbar == 1)
  ax = plot(h, x_axis, A);
 else
  ax = errorbar(h, x_axis, A, D, "~");
 endif
 if (fs == 5)
  set_axis(ax, fs, 'def')
 else
  set_axis(ax, fs, 's')
 endif
endfunction

function plot_meta_time_vs_delay_core(h, prefix, op)
 x_axis = [ 0 20 50 160 250 ];
 plot_meta_time_vs_delay_one_line(h, prefix, 1, op, x_axis)
 plot_meta_time_vs_delay_one_line(h, prefix, 2, op, x_axis)
 plot_meta_time_vs_delay_one_line(h, prefix, 5, op, x_axis)
 xlabel(h, 'RTT (ms)')
 ylabel(h, 'Completion Time (seconds)')
 set(h, 'xlim', [-5 255])
 set(h, 'xtick', x_axis)
 axis('tight')
endfunction

function plot_meta_npkt_vs_delay(prefix, op, legendpos = 'northwest')
 h = common_preparation();
 plot_meta_npkt_vs_delay_core(h, prefix, op)
 global metadata_target_legends
 make_legend(h, metadata_target_legends, legendpos)
 axis('tight')
 if (max(get(h,'ytick')) >= 10000)
  set(h, 'ytick', [0 1000 2000 3000 4000 5000 6000 7000 8000 9000 10000 11000 12000])
  set(h, 'yticklabel', {'0','1K','2K','3K','4K','5K','6K','7K','8K','9K','10K','11K','12K'})
 endif
 tx = make_title(h, ['Delay test - NPKT - ' prefix ' - ' op]);
 print_to_file(['metaNPKTdelay' prefix '_' op])
 close(gcf)
endfunction

function plot_meta_npkt_vs_delay_one_line(h, prefix, fs, op, x_axis)
 [A D] = get_meta_delayNPKT_array(prefix, fs, op);
 global no_errorbar
 if (no_errorbar == 1)
  ax = plot(h, x_axis, A);
 else
  ax = errorbar(h, x_axis, A, D, "~");
 endif
 if (fs == 5)
  set_axis(ax, fs, 'def')
 else
  set_axis(ax, fs, 's')
 endif
endfunction

function plot_meta_npkt_vs_delay_core(h, prefix, op)
 x_axis = [ 0 20 50 160 250 ];
 plot_meta_npkt_vs_delay_one_line(h, prefix, 1, op, x_axis)
 plot_meta_npkt_vs_delay_one_line(h, prefix, 2, op, x_axis)
 plot_meta_npkt_vs_delay_one_line(h, prefix, 5, op, x_axis)
 xlabel(h, 'RTT (ms)')
 ylabel(h, 'Number of Packets')
 set(h, 'xlim', [-5 255])
 set(h, 'xtick', x_axis)
 axis('tight')
endfunction

function plot_meta_pktsz_vs_delay(prefix, op, legendpos = 'northwest')
 h = common_preparation();
 plot_meta_pktsz_vs_delay_core(h, prefix, op)
 global metadata_target_legends
 make_legend(h, metadata_target_legends, legendpos)
 tx = make_title(h, ['Delay test - PKTSZ - ' prefix ' - ' op]);
 print_to_file(['metaPKTSZdelay' prefix '_' op])
 close(gcf)
endfunction

function plot_meta_pktsz_vs_delay_one_line(h, prefix, fs, op, x_axis)
 [A D] = get_meta_delayPKTSZ_array(prefix, fs, op);
 global no_errorbar
 if (no_errorbar == 1)
  ax = plot(h, x_axis, A);
 else
  ax = errorbar(h, x_axis, A, D, "~");
 endif
 if (fs == 5)
  set_axis(ax, fs, 'def')
 else
  set_axis(ax, fs, 's')
 endif
endfunction

function plot_meta_pktsz_vs_delay_core(h, prefix, op)
 x_axis = [ 0 20 50 160 250 ];
 plot_meta_pktsz_vs_delay_one_line(h, prefix, 1, op, x_axis)
 plot_meta_pktsz_vs_delay_one_line(h, prefix, 2, op, x_axis)
 plot_meta_pktsz_vs_delay_one_line(h, prefix, 5, op, x_axis)
 xlabel(h, 'RTT (ms)')
 ylabel(h, 'Mean Packet Size (bytes)')
 set(h, 'xlim', [-5 255])
 set(h, 'xtick', x_axis)
 axis('tight')
endfunction


function plot_meta_time_vs_loss(prefix, op, legendpos = 'northwest')
 h = common_preparation();
 plot_meta_time_vs_loss_core(h, prefix, op)
 global metadata_target_legends
 make_legend(h, metadata_target_legends, legendpos)
 tx = make_title(h, ['loss test - TIME - ' prefix ' - ' op]);
 print_to_file(['metaTIMEloss' prefix '_' op])
 close(gcf)
endfunction

function plot_meta_time_vs_loss_one_line(h, prefix, fs, op, x_axis)
 [A D] = get_meta_lossTIME_array(prefix, fs, op);
 global no_errorbar
 if (no_errorbar == 1)
  ax = plot(h, x_axis, A);
 else
  ax = errorbar(h, x_axis, A, D, "~");
 endif
 if (fs == 5)
  set_axis(ax, fs, 'def')
 else
  set_axis(ax, fs, 's')
 endif
endfunction

function plot_meta_time_vs_loss_core(h, prefix, op)
 x_axis = [ 0 0.1 1 2.5 ];
 plot_meta_time_vs_loss_one_line(h, prefix, 1, op, x_axis)
 plot_meta_time_vs_loss_one_line(h, prefix, 2, op, x_axis)
 plot_meta_time_vs_loss_one_line(h, prefix, 5, op, x_axis)
 xlabel(h, 'Loss rate (percent)')
 ylabel(h, 'Completion Time (seconds)')
 set(h, 'xlim', [-0.1 2.6])
 set(h, 'xtick', x_axis)
 axis('tight')
endfunction

function plot_meta_npkt_vs_loss(prefix, op, legendpos = 'northwest')
 h = common_preparation();
 plot_meta_npkt_vs_loss_core(h, prefix, op)
 global metadata_target_legends
 make_legend(h, metadata_target_legends, legendpos)
 axis('tight')
 if (max(get(h,'ytick')) >= 10000)
  set(h, 'ytick', [0 1000 2000 3000 4000 5000 6000 7000 8000 9000 10000 11000 12000])
  set(h, 'yticklabel', {'0','1K','2K','3K','4K','5K','6K','7K','8K','9K','10K','11K','12K'})
 endif
 tx = make_title(h, ['loss test - NPKT - ' prefix ' - ' op]);
 print_to_file(['metaNPKTloss' prefix '_' op])
 close(gcf)
endfunction

function plot_meta_npkt_vs_loss_one_line(h, prefix, fs, op, x_axis)
 [A D] = get_meta_lossNPKT_array(prefix, fs, op);
 global no_errorbar
 if (no_errorbar == 1)
  ax = plot(h, x_axis, A);
 else
  ax = errorbar(h, x_axis, A, D, "~");
 endif
 if (fs == 5)
  set_axis(ax, fs, 'def')
 else
  set_axis(ax, fs, 's')
 endif
endfunction

function plot_meta_npkt_vs_loss_core(h, prefix, op)
 x_axis = [ 0 0.1 1 2.5 ];
 plot_meta_npkt_vs_loss_one_line(h, prefix, 1, op, x_axis)
 plot_meta_npkt_vs_loss_one_line(h, prefix, 2, op, x_axis)
 plot_meta_npkt_vs_loss_one_line(h, prefix, 5, op, x_axis)
 xlabel(h, 'Loss rate (percent)')
 ylabel(h, 'Number of Packets')
 set(h, 'xlim', [-0.1 2.6])
 set(h, 'xtick', x_axis)
 axis('tight')
endfunction

function plot_meta_pktsz_vs_loss(prefix, op, legendpos = 'northwest')
 h = common_preparation();
 plot_meta_pktsz_vs_loss_core(h, prefix, op)
 global metadata_target_legends
 make_legend(h, metadata_target_legends, legendpos)
 tx = make_title(h, ['loss test - PKTSZ - ' prefix ' - ' op]);
 print_to_file(['metaPKTSZloss' prefix '_' op])
 close(gcf)
endfunction

function plot_meta_pktsz_vs_loss_one_line(h, prefix, fs, op, x_axis)
 [A D] = get_meta_lossPKTSZ_array(prefix, fs, op);
 global no_errorbar
 if (no_errorbar == 1)
  ax = plot(h, x_axis, A);
 else
  ax = errorbar(h, x_axis, A, D, "~");
 endif
 if (fs == 5)
  set_axis(ax, fs, 'def')
 else
  set_axis(ax, fs, 's')
 endif
endfunction

function plot_meta_pktsz_vs_loss_core(h, prefix, op)
 x_axis = [ 0 0.1 1 2.5 ];
 plot_meta_pktsz_vs_loss_one_line(h, prefix, 1, op, x_axis)
 plot_meta_pktsz_vs_loss_one_line(h, prefix, 2, op, x_axis)
 plot_meta_pktsz_vs_loss_one_line(h, prefix, 5, op, x_axis)
 xlabel(h, 'Loss rate (percent)')
 ylabel(h, 'Mean Packet Size (bytes)')
 set(h, 'xlim', [-0.1 2.6])
 set(h, 'xtick', x_axis)
 axis('tight')
endfunction

