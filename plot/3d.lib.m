% 3D plotting functions
% TODO include this from lib.m

function plot3d_4args_print(func, prefix, target, flag, rw)
 h = common_preparation();
 feval(['plot3d_' func], h, prefix, target, flag, rw)
 view(223,22)
 print_to_file([func '_' prefix '_t' num2str(target) '_F' flag '_' rw])
 close(gcf)
endfunction

function plot3d_5args_print(func, prefix, target, flag, job_size, rw)
 h = common_preparation();
 feval(['plot3d_' func], h, prefix, target, flag, job_size, rw)
 view(223,22)
 print_to_file([func '_' prefix '_t' num2str(target) '_F' flag '_j' num2str(job_size) '_' rw])
 close(gcf)
endfunction

function plot3d_bs_vs_delay(h, prefix, target, flag, rw)
 if (strcmp(prefix,'GbE') == 1)
  D = [get_bsTHP_array(1,target,flag,rw);get_bsTHP_array(14,target,flag,rw);get_bsTHP_array(7,target,flag,rw);get_bsTHP_array(12,target,flag,rw);get_bsTHP_array(9,target,flag,rw)];
 else
  D = [get_bsTHP_array(3,target,flag,rw);get_bsTHP_array(18,target,flag,rw);get_bsTHP_array(5,target,flag,rw);get_bsTHP_array(19,target,flag,rw);get_bsTHP_array(20,target,flag,rw)];
 endif

 surf(h, D)
 xlabel('Block Size')
 set(h, 'xticklabel',{'4K','16K','64K','256K','1M','4M','16M','64M'})
 ylabel('RTT (ms)')
 set(h, 'yticklabel',{'0','20','50','160','250'})
 zlabel('Throughput (MiBps)')
 make_title(h, [prefix '\_t' num2str(target) '\_F' flag '\_' rw ' Block Size vs. Delay']);
endfunction

function plot3d_bs_vs_loss(h, prefix, target, flag, rw)
 if (strcmp(prefix,'GbE') == 1)
  D = [get_bsTHP_array(1,target,flag,rw);get_bsTHP_array(23,target,flag,rw);get_bsTHP_array(10,target,flag,rw);get_bsTHP_array(11,target,flag,rw)];
 else
  D = [get_bsTHP_array(3,target,flag,rw);get_bsTHP_array(25,target,flag,rw);get_bsTHP_array(21,target,flag,rw);get_bsTHP_array(22,target,flag,rw)];
 endif

 surf(h, D)
 xlabel('Block Size')
 set(h, 'xticklabel',{'4K','16K','64K','256K','1M','4M','16M','64M'})
 ylabel('Loss (percent)')
 set(h, 'ytick', [1 2 3 4])
 set(h, 'yticklabel',{'0','0.1','1','2.5'})
 zlabel('Throughput (MiBps)')
 make_title(h, [prefix '\_t' num2str(target) '\_F' flag '\_' rw ' Block Size vs. Loss']);
endfunction

function plot3d_op_vs_delay(h, prefix, target, flag, rw)
 if (strcmp(prefix,'GbE') == 1)
  D = [get_oneTHP_array(1,target,flag,rw);get_oneTHP_array(14,target,flag,rw);get_oneTHP_array(7,target,flag,rw);get_oneTHP_array(12,target,flag,rw);get_oneTHP_array(9,target,flag,rw)];
 else
  D = [get_oneTHP_array(3,target,flag,rw);get_oneTHP_array(18,target,flag,rw);get_oneTHP_array(5,target,flag,rw);get_oneTHP_array(19,target,flag,rw);get_oneTHP_array(20,target,flag,rw)];
 endif

 surf(h, D)
 xlabel('File Size')
 set(h, 'xticklabel',{'4K','16K','64K','256K','1M','4M','16M','64M'})
 ylabel('RTT (ms)')
 set(h, 'yticklabel',{'0','20','50','160','250'})
 zlabel('Throughput (MiBps)')
 make_title(h, [prefix '\_t' num2str(target) '\_F' flag '\_' rw ' One-File Size vs. Delay']);
endfunction

function plot3d_op_vs_loss(h, prefix, target, flag, rw)
 if (strcmp(prefix,'GbE') == 1)
  D = [get_oneTHP_array(1,target,flag,rw);get_oneTHP_array(23,target,flag,rw);get_oneTHP_array(10,target,flag,rw);get_oneTHP_array(11,target,flag,rw)];
 else
  D = [get_oneTHP_array(3,target,flag,rw);get_oneTHP_array(25,target,flag,rw);get_oneTHP_array(21,target,flag,rw);get_oneTHP_array(22,target,flag,rw)];
 endif

 surf(h, D)
 xlabel('File Size')
 set(h, 'xticklabel',{'4K','16K','64K','256K','1M','4M','16M','64M'})
 ylabel('Loss (percent)')
 set(h, 'ytick', [1 2 3 4])
 set(h, 'yticklabel',{'0','0.1','1','2.5'})
 zlabel('Throughput (MiBps)')
 make_title(h, [prefix '\_t' num2str(target) '\_F' flag '\_' rw ' One-File Size vs. Loss']);
endfunction

function plot3d_nthreads_vs_delay(h, prefix, target, flag, job_size, rw)
 if (strcmp(prefix,'GbE') == 1)
  D = [get_fileTHPvNTH_array(1,target,flag,job_size,rw);get_fileTHPvNTH_array(14,target,flag,job_size,rw);get_fileTHPvNTH_array(7,target,flag,job_size,rw);get_fileTHPvNTH_array(12,target,flag,job_size,rw);get_fileTHPvNTH_array(9,target,flag,job_size,rw)];
 else
  D = [get_fileTHPvNTH_array(3,target,flag,job_size,rw);get_fileTHPvNTH_array(18,target,flag,job_size,rw);get_fileTHPvNTH_array(5,target,flag,job_size,rw);get_fileTHPvNTH_array(19,target,flag,job_size,rw);get_fileTHPvNTH_array(20,target,flag,job_size,rw)];
 endif

 surf(h, D)
 xlabel('Number of Threads')
 set(h, 'xticklabel',{'1','2','4','8','16','32','64'})
 ylabel('RTT (ms)')
 set(h, 'yticklabel',{'0','20','50','160','250'})
 zlabel('Throughput (MiBps)')
 make_title(h, [prefix '\_t' num2str(target) '\_F' flag '\_' rw '\_j' num2str(job_size) ' Threads vs. Delay']);
endfunction

function plot3d_nthreads_vs_loss(h, prefix, target, flag, job_size, rw)
 if (strcmp(prefix,'GbE') == 1)
  D = [get_fileTHPvNTH_array(1,target,flag,job_size,rw);get_fileTHPvNTH_array(23,target,flag,job_size,rw);get_fileTHPvNTH_array(10,target,flag,job_size,rw);get_fileTHPvNTH_array(11,target,flag,job_size,rw)];
 else
  D = [get_fileTHPvNTH_array(3,target,flag,job_size,rw);get_fileTHPvNTH_array(25,target,flag,job_size,rw);get_fileTHPvNTH_array(21,target,flag,job_size,rw);get_fileTHPvNTH_array(22,target,flag,job_size,rw)];
 endif

 surf(h, D)
 xlabel('Number of Threads')
 set(h, 'xticklabel',{'1','2','4','8','16','32','64'})
 ylabel('Loss (percent)')
 set(h, 'ytick', [1 2 3 4])
 set(h, 'yticklabel',{'0','0.1','1','2.5'})
 zlabel('Throughput (MiBps)')
 make_title(h, [prefix '\_t' num2str(target) '\_F' flag '\_' rw '\_j' num2str(job_size) ' Threads vs. Loss']);
endfunction

