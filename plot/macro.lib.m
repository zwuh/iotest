% Macrobenchmark plotting functions
% TODO include this from lib.m

global macro_target_legends = {[1 -1],[2 -1],[3 -1],[5 -1]};

function A = get_macroTIMEdelay_array(prefix, target, bench, conf)
 A = get_macro_array(prefix, target, bench, conf, 'TIME', 'delay');
endfunction

function A = get_macroTIMEloss_array(prefix, target, bench, conf)
 A = get_macro_array(prefix, target, bench, conf, 'TIME', 'loss');
endfunction

function A = get_macroIOPSdelay_array(prefix, target, bench, conf)
 A = get_macro_array(prefix, target, bench, conf, 'IOPS', 'delay');
endfunction

function A = get_macroIOPSloss_array(prefix, target, bench, conf)
 A = get_macro_array(prefix, target, bench, conf, 'IOPS', 'loss');
endfunction

function A = get_macro_array(prefix, target, bench, conf, func, loss_delay)
 name = [prefix 'macro' func loss_delay '_t' num2str(target) '_b' num2str(bench) '_g' num2str(conf)];
 eval(['global ' name]);
 A = eval(name);
endfunction

function macro_set_ytick(h)
 ytick = get(h, 'ytick');
 yticklabel = {};
 for i = 1:length(ytick)
  if (ytick(i) >= 1000)
   yticklabel(i) = [num2str(ytick(i)/1000) 'K'];
  else
   yticklabel(i) = num2str(ytick(i));
  endif
 endfor
 set(h, 'yticklabel', yticklabel)
endfunction

function plot_macro_iops_vs_delay(prefix, bench, conf, legendpos = 'northeast', legendside = 'left')
 h = common_preparation();
 plot_macro_iops_vs_delay_core(h, prefix, bench, conf)
 global macro_target_legends
 make_legend(h, macro_target_legends, legendpos, legendside);
 make_title(h, ['Macro delay ' prefix ' b' num2str(bench) ' g' num2str(conf)]);
 print_to_file(['macroIOPSdelay_' prefix '_b' num2str(bench) '_g' num2str(conf)])
 close(gcf)
endfunction

function plot_macro_iops_vs_delay_core(h, prefix, bench, conf)
 x_axis = [ 0 20 50 160 250 ];
 ax_nfs = plot(h, x_axis, get_macroIOPSdelay_array(prefix, 1, bench, conf));
 ax_iscsi_cfq = plot(h, x_axis, get_macroIOPSdelay_array(prefix, 2, bench, conf));
 ax_iscsi_dead = plot(h, x_axis, get_macroIOPSdelay_array(prefix, 3, bench, conf));
 ax_fuse = plot(h, x_axis, get_macroIOPSdelay_array(prefix, 5, bench, conf));
 set_axis(ax_nfs, 1, 's')
 set_axis(ax_iscsi_cfq, 2, 's')
 set_axis(ax_iscsi_dead, 3, 's')
 set_axis(ax_fuse, 5, 'def')

 set(h,'xtick',x_axis)
 macro_set_ytick(h)
 xlabel(h, 'RTT (ms)')
 ylabel(h, 'IOPS')
endfunction

function plot_macro_iops_vs_loss(prefix, bench, conf, legendpos = 'northeast', legendside = 'left')
 h = common_preparation();
 plot_macro_iops_vs_loss_core(h, prefix, bench, conf)
 global macro_target_legends
 make_legend(h, macro_target_legends, legendpos, legendside);
 make_title(h, ['Macro loss ' prefix ' b' num2str(bench) ' g' num2str(conf)]);
 print_to_file(['macroIOPSloss_' prefix '_b' num2str(bench) '_g' num2str(conf)])
 close(gcf)
endfunction

function plot_macro_iops_vs_loss_core(h, prefix, bench, conf)
 x_axis = [ 0 0.1 1 2.5 ];
 ax_nfs = plot(h, x_axis, get_macroIOPSloss_array(prefix, 1, bench, conf));
 ax_iscsi_cfq = plot(h, x_axis, get_macroIOPSloss_array(prefix, 2, bench, conf));
 ax_iscsi_dead = plot(h, x_axis, get_macroIOPSloss_array(prefix, 3, bench, conf));
 ax_fuse = plot(h, x_axis, get_macroIOPSloss_array(prefix, 5, bench, conf));
 set_axis(ax_nfs, 1, 's')
 set_axis(ax_iscsi_cfq, 2, 's')
 set_axis(ax_iscsi_dead, 3, 's')
 set_axis(ax_fuse, 5, 'def')

 set(h,'xtick',x_axis)
 macro_set_ytick(h)
 xlabel(h, 'Loss (percent)')
 ylabel(h, 'IOPS')
endfunction

function plot_macro_time_vs_delay(prefix, bench, conf, legendpos = 'northeast', legendside = 'left')
 h = common_preparation();
 plot_macro_time_vs_delay_core(h, prefix, bench, conf)
 global macro_target_legends
 make_legend(h, macro_target_legends, legendpos, legendside);
 make_title(h, ['Macro delay ' prefix ' b' num2str(bench) ' g' num2str(conf)]);
 print_to_file(['macroTIMEdelay_' prefix '_b' num2str(bench) '_g' num2str(conf)])
 close(gcf)
endfunction

function plot_macro_time_vs_delay_core(h, prefix, bench, conf)
 x_axis = [ 0 20 50 160 250 ];
 ax_nfs = plot(h, x_axis, get_macroTIMEdelay_array(prefix, 1, bench, conf));
 ax_iscsi_cfq = plot(h, x_axis, get_macroTIMEdelay_array(prefix, 2, bench, conf));
 ax_iscsi_dead = plot(h, x_axis, get_macroTIMEdelay_array(prefix, 3, bench, conf));
 ax_fuse = plot(h, x_axis, get_macroTIMEdelay_array(prefix, 5, bench, conf));
 set_axis(ax_nfs, 1, 's')
 set_axis(ax_iscsi_cfq, 2, 's')
 set_axis(ax_iscsi_dead, 3, 's')
 set_axis(ax_fuse, 5, 'def')

 set(h,'xtick',x_axis)
 macro_set_ytick(h)
 xlabel(h, 'RTT (ms)')
 ylabel(h, 'TIME (second)')
endfunction

function plot_macro_time_vs_loss(prefix, bench, conf, legendpos = 'northeast', legendside = 'left')
 h = common_preparation();
 plot_macro_time_vs_loss_core(h, prefix, bench, conf)
 global macro_target_legends
 make_legend(h, macro_target_legends, legendpos, legendside);
 make_title(h, ['Macro loss ' prefix ' b' num2str(bench) ' g' num2str(conf)]);
 print_to_file(['macroTIMEloss_' prefix '_b' num2str(bench) '_g' num2str(conf)])
 close(gcf)
endfunction

function plot_macro_time_vs_loss_core(h, prefix, bench, conf)
 x_axis = [ 0 0.1 1 2.5 ];
 ax_nfs = plot(h, x_axis, get_macroTIMEloss_array(prefix, 1, bench, conf));
 ax_iscsi_cfq = plot(h, x_axis, get_macroTIMEloss_array(prefix, 2, bench, conf));
 ax_iscsi_dead = plot(h, x_axis, get_macroTIMEloss_array(prefix, 3, bench, conf));
 ax_fuse = plot(h, x_axis, get_macroTIMEloss_array(prefix, 5, bench, conf));
 set_axis(ax_nfs, 1, 's')
 set_axis(ax_iscsi_cfq, 2, 's')
 set_axis(ax_iscsi_dead, 3, 's')
 set_axis(ax_fuse, 5, 'def')

 set(h,'xtick',x_axis)
 macro_set_ytick(h)
 xlabel(h, 'Loss (percent)')
 ylabel(h, 'TIME (second)')
endfunction

