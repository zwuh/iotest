% One-File plotting functions
% TODO include this from lib.m

global op_file_size = [4096 16384 65536 262144 1048576 4194304 16777216 67108864];
global op_file_size_labels = {'','4K', '16K', '64K', '256K', '1M', '4M', '16M', '64M'};

function [A D] = get_oneTHP_array(scenario, target, flag, rw)
 name = ['oneTHP_c' num2str(scenario) '_t' num2str(target) '_F' flag '_' rw];
 eval(['global ' name]);
 A = eval(name);
 name = ['oneTHPdev_c' num2str(scenario) '_t' num2str(target) '_F' flag '_' rw];
 eval(['global ' name]);
 D = eval(name);
endfunction

function [A D] = get_oneXFER_array(scenario, target, flag, rw)
 name = ['oneXFER_c' num2str(scenario) '_t' num2str(target) '_F' flag '_' rw];
 eval(['global ' name]);
 A = eval(name);
 name = ['oneXFERdev_c' num2str(scenario) '_t' num2str(target) '_F' flag '_' rw];
 eval(['global ' name]);
 D = eval(name);
endfunction

function AX = plot_op_one_line(h, scenario, fs, flag, rw)
 [A D] = get_oneTHP_array(scenario, fs, flag, rw);
 global no_errorbar
 if (no_errorbar == 1)
  AX = plot(h, A);
 else
  AX = errorbar(h, A, D, "~");
 endif
 set_axis(AX, fs, flag, rw);
endfunction

function plot_op_core(h, scenario, rw)
 ax_nfs_d = plot_op_one_line(h, scenario, 1, 'd', rw);
 ax_nfs_s = plot_op_one_line(h, scenario, 1, 's', rw);
 ax_iscsi_cfq_d = plot_op_one_line(h, scenario, 2, 'd', rw);
 ax_iscsi_cfq_s = plot_op_one_line(h, scenario, 2, 's', rw);
% ax_iscsi_dead_d = plot_op_one_line(h, scenario, 3, 'd', rw);
% ax_iscsi_dead_s = plot_op_one_line(h, scenario, 3, 's', rw);
 ax_fuse_def = plot_op_one_line(h, scenario, 5, 'def', rw);
 axis('tight')
 set(h, 'xtick', [0 1 2 3 4 5 6 7 8])
 xlabel(h, 'File Size')
 global op_file_size_labels
 set(h, 'xticklabel', op_file_size_labels)
 ylabel(h, 'Throughput (MiBps)')
endfunction

function plot_op_scenario(scenario, rw, legendpos = 'northwest', legendside = 'right')
 h = common_preparation();
 plot_op_core(h, scenario, rw)
 global typical_target_legends
 make_legend(h, typical_target_legends, legendpos, legendside);
 make_title(h, ['One-File - c' num2str(scenario) ' - ' rw]);
 print_to_file(['op_c' num2str(scenario) '_' rw])
 close(gcf)
endfunction

function AX = plot_op_ov_one_line(h, scenario, fs, flag, rw)
 global op_file_size
 [A D] = get_oneXFER_array(scenario, fs, flag, rw);
 global no_errorbar
 if (no_errorbar == 1)
  AX = semilogy(h, A ./ op_file_size);
 else
  AX = semilogyerr(h, A ./ op_file_size, D ./ op_file_size, "~");
 endif
 set_axis(AX, fs, flag, rw)
endfunction

function plot_op_overhead_core(h, scenario, rw)
 ax_nfs_d = plot_op_ov_one_line(h, scenario, 1, 'd', rw);
 ax_nfs_s = plot_op_ov_one_line(h, scenario, 1, 's', rw);
 ax_iscsi_cfq_d = plot_op_ov_one_line(h, scenario, 2, 'd', rw);
 ax_iscsi_cfq_s = plot_op_ov_one_line(h, scenario, 2, 's', rw);
% ax_iscsi_dead_d = plot_op_ov_one_line(h, scenario, 3, 'd', rw);
% ax_iscsi_dead_s = plot_op_ov_one_line(h, scenario, 3, 's', rw);
 ax_fuse_def = plot_op_ov_one_line(h, scenario, 5, 'def', rw);
 axis('tight')
 set(h, 'xtick', [0 1 2 3 4 5 6 7 8])
 xlabel(h, 'File Size')
 global op_file_size_labels
 set(h, 'xticklabel', op_file_size_labels)
 set(h, 'ytick', [1 2 5 10 20 50 100 200])
 set(h, 'yticklabel', {'1', '2', '5', '10', '20', '50', '100', '200'})
 ylabel(h, 'Amplification Ratio (times)')
endfunction

function plot_op_overhead_scenario(scenario, rw, legendpos = 'northeast', legendside = 'left')
 h = common_preparation();
 plot_op_overhead_core(h, scenario, rw)
 global typical_target_legends
 make_legend(h, typical_target_legends, legendpos, legendside);
 make_title(h, ['One-File overhead - c' num2str(scenario) ' - ' rw]);
 print_to_file(['op_ov_c' num2str(scenario) '_' rw])
 close(gcf)
endfunction


function plot_baseline_op(rw, legendpos = 'northwest', legendside = 'right')
 h = common_preparation();
 ax_d = plot_op_one_line(h, 0, 0, 'd', rw);
 ax_s = plot_op_one_line(h, 0, 0, 's', rw);
 axis('tight')
 set(h, 'xtick', [0 1 2 3 4 5 6 7 8])
 xlabel(h, 'File Size')
 global op_file_size_labels
 set(h, 'xticklabel', op_file_size_labels)
 ylabel(h, 'Throughput (MiBps)')
 tx = make_title(h, ['One-File - baseline - ', rw]);
 make_legend(h, {[0 1], [0 2]}, legendpos, legendside);
 print_to_file(['baseline_oneTHP-' rw])
 close(gcf)
endfunction

