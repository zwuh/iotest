% boxplot plotting functions
% TODO include this from lib.m


function M = get_box_matrix(exp_name, scenario, target, op_flag, rw='r', job_size=4096)
 if (1 == strcmp(exp_name, "meta"))
  name = ['metaTIME_c' num2str(scenario) '_t' num2str(target) '_' op_flag ];
 elseif (1 == strcmp(exp_name, "bs"))
  name = ['bsTHP_c' num2str(scenario) '_t' num2str(target) '_F' op_flag '_' rw];
 elseif (1 == strcmp(exp_name, "nthread"))
  name = ['fileTHPvNTH_c' num2str(scenario) '_t' num2str(target) '_F' op_flag '_j' num2str(job_size) '_' rw];
 elseif (1 == strcmp(exp_name, "op"))
  name = ['oneTHP_c' num2str(scenario) '_t' num2str(target) '_F' op_flag '_' rw];
 elseif (1 == strcmp(exp_name, "1thread"))
  name = ['sthTHP_c' num2str(scenario) '_t' num2str(target) '_F' op_flag '_' rw];
 endif

 eval(['global ' name]);
 M = eval(name);
endfunction

function M = get_box_macro_matrix(target, bench, conf)
 name = ['macro_t' num2str(target) '_b' num2str(bench) '_c' num2str(conf)];
 eval(['global ' name]);
 M = eval(name);
endfunction


function plot_box(exp_name, scenario, target, op_flag, rw='r', job_size=4096)
 %display(['exp:' exp_name ' c:' num2str(scenario) ' t:' num2str(target) ' of:' op_flag ' rw:' rw ' j:' num2str(job_size)])
 h = common_preparation();
 M = get_box_matrix(exp_name, scenario, target, op_flag, rw, job_size);
 % TODO XXX workaround : not always have at least two samples.
 try
  [s hx] = boxplot(M, 1);
 catch
  ;
 end_try_catch

 file_name = ['box_' exp_name '_c' num2str(scenario) '_t' num2str(target)];
 y_label = 'Throughput (MiBps)';
 if (1 == strcmp(exp_name, "meta"))
  x_tick = [1 2 3 4];
  x_ticklabel = {'1','10','100','1K'};
  y_label = 'Completion time (seconds)';
  x_label = 'Number of Operations';
  file_name = [file_name '_' op_flag];
 elseif (1 == strcmp(exp_name, "bs"))
  x_tick = [1 2 3 4 5 6 7];
  x_ticklabel = {'4K', '16K', '64K', '256K', '1M', '4M', '16M'};
  x_label = 'Access Unit Size (bytes)';
  file_name = [file_name '_F' op_flag '_' rw];
 elseif (1 == strcmp(exp_name, "nthread"))
  x_tick = [1 2 3 4 5 6 7];
  x_ticklabel = {'1', '2', '4', '8', '16', '32', '64'};
  x_label = 'Number of Worker threads';
  file_name = [file_name '_F' op_flag '_' rw '_j' num2str(job_size)];
 elseif (1 == strcmp(exp_name, "op"))
  x_tick = [1 2 3 4 5 6 7 8];
  x_ticklabel = {'4K', '16K', '64K', '256K', '1M', '4M', '16M', '64M'};
  x_label = 'File Size';
  file_name = [file_name '_F' op_flag '_' rw];
 elseif (1 == strcmp(exp_name, "1thread"))
  x_tick = [1 2 3 4 5 6 7 8];
  x_ticklabel = {'4K', '16K', '64K', '256K', '1M', '4M', '16M', '64M'};
  x_label = 'File Size';
  file_name = [file_name '_F' op_flag '_' rw];
 endif

 axis(h, 'tight')
 xlabel(h, x_label)
 ylabel(h, y_label)
 set(h, 'xtick', x_tick)
 set(h, 'xticklabel', x_ticklabel)
 print_to_file(file_name)
 close(gcf);
endfunction

function plot_box_macro(target, bench, conf)
 h = common_preparation();
 M = get_box_macro_matrix(target, bench, conf);
 [s hx] = boxplot(M, 1);
 set(h, 'xtick', [1:20])
 set(h, 'xticklabel', {'1','3','5','7','9','10','11','12','14','16','17','18','19','20','21','22','23','24','25','26'});
 axis(h, 'tight')
 xlabel(h, 'Scenario')
 ylabel(h, 'IOPS')
 print_to_file(['box_macro_b' num2str(bench) '_c' num2str(conf)])
 close(gcf)
endfunction

function test_box()
 return
 plot_box_macro(1,1,1)
 plot_box('meta',1,1,'ls')
 plot_box('bs',1,1,'s','w')
 plot_box('nthread',1,1,'s','w',1048576)
 plot_box('op',1,1,'d','w')
 plot_box('1thread',1,1,'s','r')
 return
 boxplot(get_box_macro_matrix(1,1,1),1);
 print_to_file('box_macro')
 boxplot(get_box_matrix('meta',1,1,'ls'),1);
 print_to_file('box_meta')
 boxplot(get_box_matrix('bs',1,1,'s','w'),1);
 print_to_file('box_bs')
 boxplot(get_box_matrix('nthread',1,1,'s','w',1048576),1);
 print_to_file('box_nthread')
 boxplot(get_box_matrix('op',1,1,'d','w'),1);
 print_to_file('box_op')
 boxplot(get_box_matrix('1thread',1,1,'s','r'),1);
 print_to_file('box_1thread')

endfunction

