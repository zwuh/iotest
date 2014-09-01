% Block-Size plotting functions
% TODO include this from lib.m

function [A D] = get_bsTHP_array(scenario, target, flag, rw)
 name = ['bsTHP_c' num2str(scenario) '_t' num2str(target) '_F' flag '_' rw];
 eval(['global ' name]);
 A = eval(name);
 name = ['bsTHPdev_c' num2str(scenario) '_t' num2str(target) '_F' flag '_' rw];
 eval(['global ' name]);
 D = eval(name);
endfunction

function AX = plot_thp_vs_bs_one_line(h, scenario, fs, flag, rw)
 [A D] = get_bsTHP_array(scenario,fs,flag,rw);
 global no_errorbar
 if (no_errorbar == 1)
  AX = plot(h, A);
 else
  AX = errorbar(h, A, D, "~");
 endif
 set_axis(AX, fs, flag);
endfunction

function bs_set_xaxis(h)
 xlabel(h, 'Access Unit Size (bytes)');
 set(h, 'xtick', [0 1 2 3 4 5 6 7])
 set(h, 'xticklabel', {'', '4K', '16K', '64K', '256K', '1M', '4M', '16M'})
endfunction

function plot_thp_vs_bs_core(h, scenario, rw)
 ax_nfs_d = plot_thp_vs_bs_one_line(h, scenario,1,'d',rw);
 ax_nfs_s = plot_thp_vs_bs_one_line(h, scenario,1,'s',rw);
 ax_iscsi_cfq_d = plot_thp_vs_bs_one_line(h, scenario,2,'d',rw);
 ax_iscsi_cfq_s = plot_thp_vs_bs_one_line(h, scenario,2,'s',rw);
% ax_iscsi_dead_d = plot_thp_vs_bs_one_line(h, scenario,3,'d',rw);
% ax_iscsi_dead_s = plot_thp_vs_bs_one_line(h, scenario,3,'s',rw);
 ax_fuse_def = plot_thp_vs_bs_one_line(h, scenario,5,'def',rw);

 %ylim(h, [ 0 120 ])
 axis('tight');
 bs_set_xaxis(h);
 ylabel(h, 'Throughput (MiBps)');
endfunction

function plot_thp_vs_bs(scenario, rw, legendpos = 'northwest', legendside = 'right')
 h = common_preparation();
 plot_thp_vs_bs_core(h, scenario, rw);
 global typical_target_legends
 make_legend(h, typical_target_legends, legendpos, legendside);
 tx = make_title(h, strcat('Block-Size - ', get_scenario_remark(scenario), ' - ', rw));

 print_to_file(['bsTHP_c' num2str(scenario) '-' rw])
 close(gcf)
endfunction

function plot_baseline_bs(rw, legendpos = 'northwest', legendside = 'right')
 h = common_preparation();
 plot_thp_vs_bs_one_line(h, 0, 0, 'd', rw);
 plot_thp_vs_bs_one_line(h, 0, 0, 's', rw);
 make_legend(h, {[0 1], [0 2]}, legendpos, legendside)
 tx = make_title(h, strcat('Block-Size - baseline - ', rw));
 axis('tight')
 bs_set_xaxis(h)
 ylabel(h, 'Throughput (MiBps)')
 print_to_file(['baseline_bsTHP-' rw])
 close(gcf)
endfunction

function plot_access_pattern_bs(rw, legendpos = 'southeast', legendside = 'right', scenario = 3)
 h = common_preparation();
 plot_thp_vs_bs_one_line(h, scenario, 1, 'def', rw);
 plot_thp_vs_bs_one_line(h, scenario, 1, 'd', rw);
 plot_thp_vs_bs_one_line(h, scenario, 1, 's', rw);
 plot_thp_vs_bs_one_line(h, scenario, 2, 'd', rw);
 plot_thp_vs_bs_one_line(h, scenario, 2, 's', rw);
 plot_thp_vs_bs_one_line(h, scenario, 5, 'def', rw);
 legends = {[1 0],[1 1],[1 2],[2 1],[2 2],[5 0]};
 if (1 == strcmp(rw, 'r'))
  plot_thp_vs_bs_one_line(h, scenario, 2, 'def', rw);
  legends(7) = [2 0];
 endif

 make_legend(h, legends, legendpos, legendside);
 make_title(h, ['Access Pattern comparison - ' rw]);
 axis('tight');
 bs_set_xaxis(h);
 ylabel(h, 'Throughput (MiBps)');
 print_to_file(['bs_access_pattern_c' num2str(scenario) '-' rw]);
 close(gcf);
endfunction

