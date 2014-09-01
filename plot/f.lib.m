% File test plotting functions
% TODO include this from lib.m

function [A D] = get_fileTHPvNTH_array(scenario, target, flag, job_size, rw)
 name = ['fileTHPvNTH_c' num2str(scenario) '_t' num2str(target) '_F' flag '_j' num2str(job_size) '_' rw];
 eval(['global ' name]);
 A = eval(name);
 name = ['fileTHPvNTHdev_c' num2str(scenario) '_t' num2str(target) '_F' flag '_j' num2str(job_size) '_' rw];
 eval(['global ' name]);
 D = eval(name);
endfunction

function [A D] = get_fileXFERvNTH_array(scenario, target, flag, job_size, rw)
 name = ['fileXFERvNTH_c' num2str(scenario) '_t' num2str(target) '_F' flag '_j' num2str(job_size) '_' rw];
 eval(['global ' name]);
 A = eval(name);
 name = ['fileXFERvNTHdev_c' num2str(scenario) '_t' num2str(target) '_F' flag '_j' num2str(job_size) '_' rw];
 eval(['global ' name]);
 D = eval(name);
endfunction

function [A D] = get_lossTHP_array(prefix, fs, flag, n_threads, job_size, rw)
 name = [prefix 'lossTHP_t' num2str(fs) '_n' num2str(n_threads) '_F' flag '_' rw '_j' num2str(job_size) ];
 eval(['global ' name]);
 A = eval(name);
 name = [prefix 'lossTHPdev_t' num2str(fs) '_n' num2str(n_threads) '_F' flag '_' rw '_j' num2str(job_size) ];
 eval(['global ' name]);
 D = eval(name);
endfunction

function [A D] = get_1thTHP_array(scenario, target, flag, rw)
 name = ['sthTHP_c' num2str(scenario) '_t' num2str(target) '_F' flag '_' rw];
 eval(['global ' name]);
 A = eval(name);
 name = ['sthTHPdev_c' num2str(scenario) '_t' num2str(target) '_F' flag '_' rw];
 eval(['global ' name]);
 D = eval(name);
endfunction

function [A D] = get_1thXFER_array(scenario, target, flag, rw)
 name = ['sthXFER_c' num2str(scenario) '_t' num2str(target) '_F' flag '_' rw];
 eval(['global ' name]);
 A = eval(name);
 name = ['sthXFERdev_c' num2str(scenario) '_t' num2str(target) '_F' flag '_' rw];
 eval(['global ' name]);
 D = eval(name);
endfunction

function [A D] = get_delayTHP_array(prefix, fs, flag, n_threads, job_size, rw)
 name = [prefix 'delayTHP_t' num2str(fs) '_n' num2str(n_threads) '_F' flag '_' rw '_j' num2str(job_size) ];
 eval(['global ' name]);
 A = eval(name);
 name = [prefix 'delayTHPdev_t' num2str(fs) '_n' num2str(n_threads) '_F' flag '_' rw '_j' num2str(job_size) ];
 eval(['global ' name]);
 D = eval(name);
endfunction


function plot_fs_and_flag_vs_nthreads(scenario, job_size, rw, legendpos = 'northwest', legendside = 'right')
 h = common_preparation();

 plot_fs_and_flag_vs_nthreads_core(h, scenario, job_size, rw)
 global typical_target_legends
 make_legend(h, typical_target_legends, legendpos, legendside)
 title_text = strcat('Worker Threads - ',get_scenario_remark(scenario),' - ',rw,' - job\_size:',num2str(job_size));
 tx = make_title(h, title_text);

 print_to_file(['fileTHPvNTH_c' num2str(scenario) '-' rw '-j' num2str(job_size)])
 close(gcf)
endfunction

function plot_fs_and_flag_vs_nthreads_core(h, scenario, job_size, rw)
 ax_nfs_d = plot_file_nthreads_one_line(h, scenario, 1, 'd', job_size, rw);
 ax_nfs_s = plot_file_nthreads_one_line(h, scenario, 1, 's', job_size, rw);
 ax_iscsi_cfq_d = plot_file_nthreads_one_line(h, scenario, 2, 'd', job_size, rw);
 ax_iscsi_cfq_s = plot_file_nthreads_one_line(h, scenario, 2, 's', job_size, rw);
 ax_fuse_def = plot_file_nthreads_one_line(h, scenario, 5, 'def', job_size, rw);
 axis('tight')
 xlabel(h, 'Number of Worker threads')
 ylabel(h, 'Throughput (MiBps)')
 set(h, 'xticklabel', {'','1', '2', '4', '8', '16', '32', '64'})
endfunction

function plot_baseline_nthreads(job_size, rw, legendpos = 'northwest', legendside = 'right')
 h = common_preparation();
 ax_d = plot_file_nthreads_one_line(h, 0, 0, 'd', job_size, rw);
 ax_s = plot_file_nthreads_one_line(h, 0, 0, 's', job_size, rw);
 axis('tight')
 xlabel(h, 'Number of Worker threads')
 ylabel(h, 'Throughput (MiBps)')
 axis('tight')
 set(h, 'xticklabel', {'','1', '2', '4', '8', '16', '32', '64'})
 make_legend(h, {[0 1], [0 2]}, legendpos, legendside)
 make_title(h, ['Local disk - ' num2str(job_size) ' - ' rw]);
 print_to_file(['baseline_nthreads-' rw '_j' num2str(job_size)])
 close(gcf)
endfunction

function AX = plot_file_nthreads_one_line(h, scenario, fs, flag, job_size, rw)
 [A D] = get_fileTHPvNTH_array(scenario, fs, flag, job_size, rw);
 global no_errorbar
 if (no_errorbar == 1)
  AX = plot(h, A);
 else
  AX = errorbar(h, A, D, "~");
 endif
 set_axis(AX, fs, flag);
endfunction

function AX = plot_file_1thread_one_line(h, scenario, fs, flag, rw)
 [A D] = get_1thTHP_array(scenario, fs, flag, rw);
 global no_errorbar
 if (no_errorbar == 1)
  AX = plot(h, A);
 else
  AX = errorbar(h, A, D, "~");
 endif
 set_axis(AX, fs, flag);
endfunction

function plot_fs_and_flag_1thread(scenario, rw, legendpos = 'southeast', legendside = 'left')
 h = common_preparation();

 plot_file_1thread_one_line(h, scenario, 1, 'd', rw);
 plot_file_1thread_one_line(h, scenario, 1, 's', rw);
 plot_file_1thread_one_line(h, scenario, 2, 'd', rw);
 plot_file_1thread_one_line(h, scenario, 2, 's', rw);
 plot_file_1thread_one_line(h, scenario, 5, 'def', rw);

 global typical_target_legends
 make_legend(h, typical_target_legends, legendpos, legendside)
 title_text = strcat('Single Thread - ',get_scenario_remark(scenario),' - ',rw);
 tx = make_title(h, title_text);
 xlabel(h, 'File Size')
 ylabel(h, 'Throughput (MiBps)')
 axis('tight')
 set(h, 'xtick', [0 1 2 3 4 5 6 7 8])
 set(h, 'xticklabel', {'', '4K', '16K', '64K', '256K', '1M', '4M', '16M', '64M'})

 print_to_file(['sthTHP_c' num2str(scenario) '-' rw])
 close(gcf)
endfunction

function plot_baseline_1thread(rw, legendpos = 'southeast', legendside = 'left')
 h = common_preparation();

 plot_file_1thread_one_line(h, 0, 0, 'd', rw);
 plot_file_1thread_one_line(h, 0, 0, 's', rw);

 global typical_target_legends
 make_legend(h, {[0 1], [0 2]}, legendpos, legendside)
 tx = make_title(h, ['Local disk - single thread - ' rw]);
 xlabel(h, 'File Size')
 ylabel(h, 'Throughput (MiBps)')
 axis('tight')
 set(h, 'xtick', [0 1 2 3 4 5 6 7 8])
 set(h, 'xticklabel', {'', '4K', '16K', '64K', '256K', '1M', '4M', '16M', '64M'})

 print_to_file(['baseline_sth-' rw])
 close(gcf)
endfunction



function AX = plot_file_1thread_ov_one_line(h, scenario, fs, flag, rw)
 [At Dt] = get_1thTHP_array(scenario, fs, flag, rw);
 [Ax Dx] = get_1thXFER_array(scenario, fs, flag, rw);
 AX = plot(h, Ax ./ At);
 set_axis(AX, fs, flag);
endfunction

function plot_fs_and_flag_ov_1thread(scenario, rw, legendpos = 'southeast', legendside = 'left')
 h = common_preparation();

 plot_file_1thread_ov_one_line(h, scenario, 1, 'd', rw);
 plot_file_1thread_ov_one_line(h, scenario, 1, 's', rw);
 plot_file_1thread_ov_one_line(h, scenario, 2, 'd', rw);
 plot_file_1thread_ov_one_line(h, scenario, 2, 's', rw);
 plot_file_1thread_ov_one_line(h, scenario, 5, 'def', rw);

 global typical_target_legends
 make_legend(h, typical_target_legends, legendpos, legendside)
 title_text = strcat('Single Thread ov - ',get_scenario_remark(scenario),' - ',rw);
 tx = make_title(h, title_text);
 xlabel(h, 'File Size')
 ylabel(h, 'Amplification Ratio (times)')
 axis('tight')
 set(h, 'xtick', [0 1 2 3 4 5 6 7 8])
 set(h, 'xticklabel', {'', '4K', '16K', '64K', '256K', '1M', '4M', '16M', '64M'})

 print_to_file(['sthTHP_ov_c' num2str(scenario) '-' rw])
 close(gcf)
endfunction

function plot_thp_vs_delay(prefix, n_threads, job_size, rw, legendpos = 'northwest', legendside = 'right')
 h = common_preparation();

 plot_thp_vs_delay_core(h, prefix, n_threads, job_size, rw)
 global typical_target_legends
 make_legend(h, typical_target_legends, legendpos, legendside)
 tx = make_title(h, strcat('Delay test - ', prefix, ' - ', num2str(n_threads), ' threads, job_size:', num2str(job_size), ' - ', rw));

 print_to_file(['delayTHP_' prefix '_n' num2str(n_threads) '_' rw '_j' num2str(job_size)])
 close(gcf)
endfunction

function AX = plot_thp_vs_delay_one_line(h, x_axis, prefix, fs, flag, n_threads, job_size, rw)
 [A D] = get_delayTHP_array(prefix, fs, flag, n_threads, job_size, rw);
 global no_errorbar
 if (no_errorbar == 1)
  AX = plot(h, x_axis, A);
 else
  AX = errorbar(h, x_axis, A, D, "~");
 endif
 set_axis(AX, fs, flag)
endfunction

function plot_thp_vs_delay_core(h, prefix, n_threads, job_size, rw)
 % TODO hard coded
 x_axis = [ 0 20 50 160 250 ];
 plot_thp_vs_delay_one_line(h, x_axis, prefix, 1, 'd', n_threads, job_size, rw);
 plot_thp_vs_delay_one_line(h, x_axis, prefix, 1, 's', n_threads, job_size, rw);
 plot_thp_vs_delay_one_line(h, x_axis, prefix, 2, 'd', n_threads, job_size, rw);
 plot_thp_vs_delay_one_line(h, x_axis, prefix, 2, 's', n_threads, job_size, rw);
 plot_thp_vs_delay_one_line(h, x_axis, prefix, 5, 'def', n_threads, job_size, rw);

 set(h, 'xtick', x_axis)
 axis('tight')
 xlabel(h, 'RTT (ms)')
 ylabel(h, 'Throughput (MiBps)')
endfunction

function plot_thp_vs_loss(prefix, n_threads, job_size, rw, legendpos = 'northwest', legendside = 'right')
 h = common_preparation();

 plot_thp_vs_loss_core(h, prefix, n_threads, job_size, rw)
 global typical_target_legends
 make_legend(h, typical_target_legends, legendpos, legendside)
 tx = make_title(h, strcat('Loss test - ', prefix, ' - ', num2str(n_threads), ' threads, job_size:', num2str(job_size), ' - ', rw));
 print_to_file(['lossTHP_' prefix '_n' num2str(n_threads) '_' rw '_j' num2str(job_size)])
 close(gcf)
endfunction

function AX = plot_thp_vs_loss_one_line(h, x_axis, prefix, fs, flag, n_threads, job_size, rw)
 [A D] = get_lossTHP_array(prefix, fs, flag, n_threads, job_size, rw);
 global no_errorbar
 if (no_errorbar == 1)
  AX = plot(h, x_axis, A);
 else
  AX = errorbar(h, x_axis, A, D, "~");
 endif
 set_axis(AX, fs, flag)
endfunction

function plot_thp_vs_loss_core(h, prefix, n_threads, job_size, rw)
 % TODO hard coded
 x_axis = [ 0 0.1 1 2.5 ];
 plot_thp_vs_loss_one_line(h, x_axis, prefix, 1, 'd', n_threads, job_size, rw);
 plot_thp_vs_loss_one_line(h, x_axis, prefix, 1, 's', n_threads, job_size, rw);
 plot_thp_vs_loss_one_line(h, x_axis, prefix, 2, 'd', n_threads, job_size, rw);
 plot_thp_vs_loss_one_line(h, x_axis, prefix, 2, 's', n_threads, job_size, rw);
 plot_thp_vs_loss_one_line(h, x_axis, prefix, 5, 'def', n_threads, job_size, rw);

 set(h, 'xtick', x_axis)
 axis('tight')
 xlabel(h, 'Loss rate (percent)')
 ylabel(h, 'Throughput (MiBps)')
endfunction

function AX = plot_file_nthreads_ov_one_line(h, scenario, fs, flag, job_size, rw)
 [Ax Dx] = get_fileXFERvNTH_array(scenario, fs, flag, job_size, rw);
 [At Dt] = get_fileTHPvNTH_array(scenario, fs, flag, job_size, rw);
 AX = plot(h, Ax ./ At);
 set_axis(AX, fs, flag);
endfunction

function plot_file_nthreads_ov_core(h, scenario, job_size, rw)
 ax_nfs_d = plot_file_nthreads_ov_one_line(h, scenario, 1, 'd', job_size, rw);
 ax_nfs_s = plot_file_nthreads_ov_one_line(h, scenario, 1, 's', job_size, rw);
 ax_iscsi_cfq_d = plot_file_nthreads_ov_one_line(h, scenario, 2, 'd', job_size, rw);
 ax_iscsi_cfq_s = plot_file_nthreads_ov_one_line(h, scenario, 2, 's', job_size, rw);
 ax_fuse_def = plot_file_nthreads_ov_one_line(h, scenario, 5, 'def', job_size, rw);
 axis('tight')
 xlabel(h, 'Number of Worker threads')
 set(h, 'xticklabel', {'1', '2', '4', '8', '16', '32', '64'})
 ylabel(h, 'Amplification Ratio (times)')
endfunction

function plot_file_nthreads_ov(scenario, job_size, rw, legendpos = 'northeast', legendside = 'left')
 h = common_preparation();
 plot_file_nthreads_ov_core(h, scenario, job_size, rw);
 global typical_target_legends
 make_legend(h, typical_target_legends, legendpos, legendside);
 make_title(h, ['File overhead - c' num2str(scenario) ' j' num2str(job_size) ' - ' rw]);
 print_to_file(['file_ov_c' num2str(scenario) '_' rw '_j' num2str(job_size)])
 close(gcf)
endfunction

function plot_file_ioscheduler(scenario, job_size, rw, legendpos = 'northeast', legendside = 'left')
 h = common_preparation();
 cfq_d = plot_file_nthreads_one_line(h, scenario, 2, 'd', job_size, rw);
 cfq_s = plot_file_nthreads_one_line(h, scenario, 2, 's', job_size, rw);
 dead_d = plot_file_nthreads_one_line(h, scenario, 3, 'd', job_size, rw);
 dead_s = plot_file_nthreads_one_line(h, scenario, 3, 's', job_size, rw);
 make_legend(h, {[2 1],[2 2],[3 1],[3 2]}, legendpos, legendside);
 make_title(h, ['I/O scheduler c' num2str(scenario) ' ' rw ' j' num2str(job_size)]);
 xlabel(h, 'Number of Worker threads')
 axis('tight')
 set(h, 'xticklabel', {'', '1', '2', '4', '8', '16', '32', '64'})
 ylabel(h, 'Throughput (MiBps)')
 print_to_file(['file_sched_c' num2str(scenario) '_' rw '_j' num2str(job_size)]);
 close(gcf);
endfunction

