<?php
 require_once('common_head.php');

 /* Generate series/vectors for plot()s. */

 function gen_meta_series($_db, $_scenario, $_fs, $_op)
 {
  global $date_where;
  $filter_where = $date_where;

  $sql = "select round(avg(elapsed),2) as elapsed, ".
    " round(stddev(elapsed),2) as elapsed_dev, ".
    " ceil(avg(npkt)) as npkt, ".
    " ceil(stddev(npkt)) as npkt_dev, ".
    " ceil(avg(transferred/if(npkt=0,1,npkt))) as pktsz, ".
    " ceil(stddev(transferred/if(npkt=0,1,npkt))) as pktsz_dev ".
    " from metadata ".
    " where scenario=".$_scenario." and fs=".$_fs." and op='".$_op."' ".$filter_where.
    " group by n_jobs order by n_jobs asc;";
  $res = $_db->query($sql);
  $elapsed = array();
  $elapsed_dev = array();
  $npkt = array();
  $npkt_dev = array();
  $pktsz = array();
  $pktsz_dev = array();
  while ($entry = $res->fetch_assoc()) {
   $elapsed[] = $entry['elapsed'];
   $elapsed_dev[] = $entry['elapsed_dev'];
   $npkt[] = $entry['npkt'];
   $npkt_dev[] = $entry['npkt_dev'];
   $pktsz[] = $entry['pktsz'];
   $pktsz_dev[] = $entry['pktsz_dev'];
  }
  $res->close();
  $ar_name = "metaTIME_c".$_scenario."_t".$_fs."_".$_op;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($elapsed as $v) { echo $v." "; }
  echo "];\n";
  $ar_name = "metaTIMEdev_c".$_scenario."_t".$_fs."_".$_op;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($elapsed_dev as $v) { echo $v." "; }
  echo "];\n";

  $ar_name = "metaNPKT_c".$_scenario."_t".$_fs."_".$_op;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($npkt as $v) { echo $v." "; }
  echo "];\n";
  $ar_name = "metaNPKTdev_c".$_scenario."_t".$_fs."_".$_op;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($npkt_dev as $v) { echo $v." "; }
  echo "];\n";

  $ar_name = "metaPKTSZ_c".$_scenario."_t".$_fs."_".$_op;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($pktsz as $v) { echo $v." "; }
  echo "];\n";
  $ar_name = "metaPKTSZdev_c".$_scenario."_t".$_fs."_".$_op;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($pktsz_dev as $v) { echo $v." "; }
  echo "];\n";
 }

 function gen_thp_thread_series($_db, $_scenario, $_fs, $_flag, $_job_size, $_rw)
 {
  global $date_where;
  global $bucketed_4k_where;
  $filter_where = $date_where.$bucketed_4k_where;

  $sql = "select round(avg(throughput),2) as thp, ".
    " round(stddev(throughput),2) as thp_dev, ".
    " round(avg(transferred/elapsed/1048576),2) as xfer, ".
    " round(stddev(transferred/elapsed/1048576),2) as xfer_dev ".
    " from file ".
    " where scenario=".$_scenario." and fs=".$_fs." and job_size=".$_job_size.
    " and flag='".$_flag."' and rw='".$_rw."' ".$filter_where.
    " group by n_threads order by n_threads asc;";
  $res = $_db->query($sql);
  $thp = array();
  $thp_dev = array();
  $xfer = array();
  $xfer_dev = array();
  while ($entry = $res->fetch_assoc()) {
   $thp[] = $entry['thp'];
   $thp_dev[] = $entry['thp_dev'];
   $xfer[] = $entry['xfer'];
   $xfer_dev[] = $entry['xfer_dev'];
  }
  $res->close();
  $ar_name = "fileTHPvNTH_c".$_scenario."_t".$_fs."_F".$_flag."_j".$_job_size."_".$_rw;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($thp as $v) { echo $v." "; }
  echo "];\n";
  $ar_name = "fileTHPvNTHdev_c".$_scenario."_t".$_fs."_F".$_flag."_j".$_job_size."_".$_rw;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($thp_dev as $v) { echo $v." "; }
  echo "];\n";

  $ar_name = "fileXFERvNTH_c".$_scenario."_t".$_fs."_F".$_flag."_j".$_job_size."_".$_rw;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($xfer as $v) { echo $v." "; }
  echo "];\n";
  $ar_name = "fileXFERvNTHdev_c".$_scenario."_t".$_fs."_F".$_flag."_j".$_job_size."_".$_rw;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($xfer_dev as $v) { echo $v." "; }
  echo "];\n";
 }

 function gen_thp_bs_series($_db, $_scenario, $_fs, $_flag, $_rw)
 {
  global $date_where;
  $filter_where = $date_where;

  // XXX Hard coded job_size and n_threads
  $sql = "select round(avg(throughput),2) as thp, ".
    " round(stddev(throughput),2) as thp_dev, ".
    " ceil(avg(transferred)) as xfer, ".
    " ceil(stddev(transferred)) as xfer_dev, ".
    " ceil(avg(npkt)) as npkt, ".
    " ceil(stddev(npkt)) as npkt_dev ".
    " from blocksize ".
    " where job_size=16777216 and n_threads=1 and scenario=".$_scenario.
    " and fs=".$_fs." and flag='".$_flag."' and rw='".$_rw."' ".$filter_where.
    " group by block_size order by block_size asc;";
  $res = $_db->query($sql);
  $thp = array();
  $thp_dev = array();
  $xfer = array();
  $xfer_dev = array();
  $npkt = array();
  $npkt_dev = array();
  while ($entry = $res->fetch_assoc()) {
   $thp[] = $entry['thp'];
   $thp_dev[] = $entry['thp_dev'];
   $xfer[] = $entry['xfer'];
   $xfer_dev[] = $entry['xfer_dev'];
   $npkt[] = $entry['npkt'];
   $npkt_dev[] = $entry['npkt_dev'];
  }
  $res->close();

  $ar_name = "bsTHP_c".$_scenario."_t".$_fs."_F".$_flag."_".$_rw;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($thp as $v) { echo $v." "; }
  echo "];\n";
  $ar_name = "bsTHPdev_c".$_scenario."_t".$_fs."_F".$_flag."_".$_rw;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($thp_dev as $v) { echo $v." "; }
  echo "];\n";

  $ar_name = "bsXFER_c".$_scenario."_t".$_fs."_F".$_flag."_".$_rw;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($xfer as $v) { echo $v." "; }
  echo "];\n";
  $ar_name = "bsXFERdev_c".$_scenario."_t".$_fs."_F".$_flag."_".$_rw;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($xfer_dev as $v) { echo $v." "; }
  echo "];\n";

  $ar_name = "bsNPKT_c".$_scenario."_t".$_fs."_F".$_flag."_".$_rw;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($npkt as $v) { echo $v." "; }
  echo "];\n";
  $ar_name = "bsNPKTdev_c".$_scenario."_t".$_fs."_F".$_flag."_".$_rw;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($npkt_dev as $v) { echo $v." "; }
  echo "];\n";
 }

 function gen_one_thread_series($_db, $_scenario, $_fs, $_flag, $_rw)
 {
  global $date_where;
  global $bucketed_4k_where;
  $filter_where = $date_where.$bucketed_4k_where;

  $sql = "select round(avg(throughput),2) as thp, ".
    " round(stddev(throughput),2) as thp_dev, ".
    " round(avg(transferred/elapsed/1048576),2) as xfer, ".
    " round(stddev(transferred/elapsed/1048576),2) as xfer_dev ".
    " from file ".
    " where n_threads=1 and scenario=".$_scenario.
    " and fs=".$_fs." and flag='".$_flag."' and rw='".$_rw."' ".$filter_where.
    " group by job_size order by job_size asc;";
  $res = $_db->query($sql);
  $thp = array();
  $thp_dev = array();
  $xfer = array();
  $xfer_dev = array();
  while ($entry = $res->fetch_assoc()) {
   $thp[] = $entry['thp'];
   $thp_dev[] = $entry['thp_dev'];
   $xfer[] = $entry['xfer'];
   $xfer_dev[] = $entry['xfer_dev'];
  }
  $res->close();

  $ar_name = "sthTHP_c".$_scenario."_t".$_fs."_F".$_flag."_".$_rw;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($thp as $v) { echo $v." "; }
  echo "];\n";
  $ar_name = "sthTHPdev_c".$_scenario."_t".$_fs."_F".$_flag."_".$_rw;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($thp_dev as $v) { echo $v." "; }
  echo "];\n";

  $ar_name = "sthXFER_c".$_scenario."_t".$_fs."_F".$_flag."_".$_rw;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($xfer as $v) { echo $v." "; }
  echo "];\n";
  $ar_name = "sthXFERdev_c".$_scenario."_t".$_fs."_F".$_flag."_".$_rw;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($xfer_dev as $v) { echo $v." "; }
  echo "];\n";
 }

 function gen_thp_one_file_series($_db, $_scenario, $_fs, $_flag, $_rw)
 {
  global $date_where;
  $filter_where = $date_where;

  $sql = "select round(avg(throughput),2) as thp, ".
    " round(stddev(throughput),2) as thp_dev, ".
    " ceil(avg(transferred)) as xfer, ".
    " ceil(stddev(transferred)) as xfer_dev, ".
    " ceil(avg(npkt)) as npkt, ".
    " ceil(stddev(npkt)) as npkt_dev ".
    " from blocksize ".
    " where job_size=block_size and n_threads=1 and scenario=".$_scenario.
    " and fs=".$_fs." and flag='".$_flag."' and rw='".$_rw."' ".$filter_where.
    " group by block_size order by block_size asc;";
  $res = $_db->query($sql);
  $thp = array();
  $thp_dev = array();
  $xfer = array();
  $xfer_dev = array();
  $npkt = array();
  $npkt_dev = array();
  while ($entry = $res->fetch_assoc()) {
   $thp[] = $entry['thp'];
   $thp_dev[] = $entry['thp_dev'];
   $xfer[] = $entry['xfer'];
   $xfer_dev[] = $entry['xfer_dev'];
   $npkt[] = $entry['npkt'];
   $npkt_dev[] = $entry['npkt_dev'];
  }
  $res->close();

  $ar_name = "oneTHP_c".$_scenario."_t".$_fs."_F".$_flag."_".$_rw;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($thp as $v) { echo $v." "; }
  echo "];\n";
  $ar_name = "oneTHPdev_c".$_scenario."_t".$_fs."_F".$_flag."_".$_rw;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($thp_dev as $v) { echo $v." "; }
  echo "];\n";

  $ar_name = "oneXFER_c".$_scenario."_t".$_fs."_F".$_flag."_".$_rw;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($xfer as $v) { echo $v." "; }
  echo "];\n";
  $ar_name = "oneXFERdev_c".$_scenario."_t".$_fs."_F".$_flag."_".$_rw;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($xfer_dev as $v) { echo $v." "; }
  echo "];\n";

  $ar_name = "oneNPKT_c".$_scenario."_t".$_fs."_F".$_flag."_".$_rw;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($npkt as $v) { echo $v." "; }
  echo "];\n";
  $ar_name = "oneNPKTdev_c".$_scenario."_t".$_fs."_F".$_flag."_".$_rw;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($npkt_dev as $v) { echo $v." "; }
  echo "];\n";
 }

 function gen_thp_delay($_db, $_scenarios, $_prefix, $_fs, $_flag, $_n_threads, $_job_size, $_rw)
 {
  gen_thp_loss_or_delay($_db, $_scenarios, $_prefix, $_fs, $_flag, $_n_threads, $_job_size, $_rw, 'delay');
 }

 function gen_thp_loss($_db, $_scenarios, $_prefix, $_fs, $_flag, $_n_threads, $_job_size, $_rw)
 {
  gen_thp_loss_or_delay($_db, $_scenarios, $_prefix, $_fs, $_flag, $_n_threads, $_job_size, $_rw, 'loss');
 }

 function gen_thp_loss_or_delay($_db, $_scenarios, $_prefix, $_fs, $_flag, $_n_threads, $_job_size, $_rw, $_loss_delay)
 {
  global $date_where;
  global $bucketed_4k_where;
  $filter_where = $date_where.$bucketed_4k_where;

  if (strcmp($_loss_delay,'loss') && strcmp($_loss_delay,'delay')) {
   exit('gen_thp_loss_or_delay: invalid loss_delay:'.$_loss_delay);
  }

  $selected_scenarios = " and (0";
  foreach ($_scenarios as $s) {
   $selected_scenarios .= " or scenario=$s";
  }
  $selected_scenarios .= ")";
  $sql = "select round(avg(throughput),2) as thp, ".
    " round(stddev(throughput),2) as thp_dev, ".
    " round(avg(transferred/elapsed/1048576),2) as xfer, ".
    " round(stddev(transferred/elapsed/1048576),2) as xfer_dev ".
    " from file ".
    " left join scenario on file.scenario=scenario.id ".
    " where job_size=$_job_size and n_threads=$_n_threads ".$selected_scenarios.
    " and fs=".$_fs." and flag='".$_flag."' and rw='".$_rw."' ".$filter_where.
    " group by scenario order by scenario.".$_loss_delay." asc;";
  $res = $_db->query($sql);
  $thp = array();
  $thp_dev = array();
  $xfer = array();
  $xfer_dev = array();
  while ($entry = $res->fetch_assoc()) {
   $thp[] = $entry['thp'];
   $thp_dev[] = $entry['thp_dev'];
   $xfer[] = $entry['xfer'];
   $xfer_dev[] = $entry['xfer_dev'];
  }
  $res->close();

  $ar_name = "${_prefix}${_loss_delay}THP_t".$_fs."_n".$_n_threads."_F".$_flag."_".$_rw."_j".$_job_size;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($thp as $v) { echo $v." "; }
  echo "];\n";
  $ar_name = "${_prefix}${_loss_delay}THPdev_t".$_fs."_n".$_n_threads."_F".$_flag."_".$_rw."_j".$_job_size;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($thp_dev as $v) { echo $v." "; }
  echo "];\n";

  $ar_name = "${_prefix}${_loss_delay}XFER_t".$_fs."_n".$_n_threads."_F".$_flag."_".$_rw."_j".$_job_size;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($xfer as $v) { echo $v." "; }
  echo "];\n";
  $ar_name = "${_prefix}${_loss_delay}XFERdev_t".$_fs."_n".$_n_threads."_F".$_flag."_".$_rw."_j".$_job_size;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($xfer_dev as $v) { echo $v." "; }
  echo "];\n";
 }

 function gen_meta_loss($_db, $_scenarios, $_prefix, $_fs, $_op)
 { gen_meta_loss_or_delay($_db, $_scenarios, $_prefix, $_fs, 'loss', $_op); }

 function gen_meta_delay($_db, $_scenarios, $_prefix, $_fs, $_op)
 { gen_meta_loss_or_delay($_db, $_scenarios, $_prefix, $_fs, 'delay', $_op); }

 function gen_meta_loss_or_delay($_db, $_scenarios, $_prefix, $_fs, $_loss_delay, $_op)
 {
  global $date_where;
  $filter_where = $date_where;

  if (strcmp($_loss_delay,'loss') && strcmp($_loss_delay,'delay')) {
   exit('gen_meta_loss_or_delay: invalid loss_delay:'.$_loss_delay);
  }

  $selected_scenarios = " and (0";
  foreach ($_scenarios as $s) {
   $selected_scenarios .= " or scenario=$s";
  }
  $selected_scenarios .= ")";
  $sql = "select round(avg(elapsed),2) as elapsed, ".
    " round(stddev(elapsed),2) as elapsed_dev, ".
    " ceil(avg(transferred/npkt)) as pktsz, ".
    " ceil(stddev(transferred/npkt)) as pktsz_dev, ".
    " ceil(avg(npkt)) as npkt, ".
    " ceil(stddev(npkt)) as npkt_dev ".
    " from metadata ".
    " left join scenario on metadata.scenario=scenario.id ".
    " where fs=".$_fs." and n_jobs=1000 and op='".$_op."' ".
     $selected_scenarios.$filter_where.
    " group by scenario order by scenario.".$_loss_delay." asc;";
  $res = $_db->query($sql);
  $elapsed = array();
  $elapsed_dev = array();
  $npkt = array();
  $npkt_dev = array();
  $pktsz = array();
  $pktsz_dev = array();
  while ($entry = $res->fetch_assoc()) {
   $elapsed[] = $entry['elapsed'];
   $elapsed_dev[] = $entry['elapsed_dev'];
   $npkt[] = $entry['npkt'];
   $npkt_dev[] = $entry['npkt_dev'];
   $pktsz[] = $entry['pktsz'];
   $pktsz_dev[] = $entry['pktsz_dev'];
  }
  $res->close();

  $ar_name = "${_prefix}meta${_loss_delay}TIME_t".$_fs."_".$_op;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($elapsed as $v) { echo $v." "; }
  echo "];\n";
  $ar_name = "${_prefix}meta${_loss_delay}TIMEdev_t".$_fs."_".$_op;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($elapsed_dev as $v) { echo $v." "; }
  echo "];\n";

  $ar_name = "${_prefix}meta${_loss_delay}NPKT_t".$_fs."_".$_op;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($npkt as $v) { echo $v." "; }
  echo "];\n";
  $ar_name = "${_prefix}meta${_loss_delay}NPKTdev_t".$_fs."_".$_op;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($npkt_dev as $v) { echo $v." "; }
  echo "];\n";

  $ar_name = "${_prefix}meta${_loss_delay}PKTSZ_t".$_fs."_".$_op;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($pktsz as $v) { echo $v." "; }
  echo "];\n";
  $ar_name = "${_prefix}meta${_loss_delay}PKTSZdev_t".$_fs."_".$_op;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($pktsz_dev as $v) { echo $v." "; }
  echo "];\n";
 }

 function gen_macro_loss($_db, $_scenarios, $_prefix, $_fs, $_bench, $_conf)
 { gen_macro_loss_or_delay($_db, $_scenarios, $_prefix, $_fs, 'loss', $_bench, $_conf); }

 function gen_macro_delay($_db, $_scenarios, $_prefix, $_fs, $_bench, $_conf)
 { gen_macro_loss_or_delay($_db, $_scenarios, $_prefix, $_fs, 'delay', $_bench, $_conf); }

 function gen_macro_loss_or_delay($_db, $_scenarios, $_prefix, $_fs, $_loss_delay, $_bench, $_conf)
 {
  global $date_where;
  $filter_where = $date_where;

  if (strcmp($_loss_delay,'loss') && strcmp($_loss_delay,'delay')) {
   exit('gen_macro_loss_or_delay: invalid loss_delay:'.$_loss_delay);
  }

  $selected_scenarios = " and (0";
  foreach ($_scenarios as $s) {
   $selected_scenarios .= " or scenario=$s";
  }
  $selected_scenarios .= ")";

  $sql = "select round(avg(throughput),0) as iops, ".
    " round(stddev(throughput),1) as iops_dev, ".
    " round(avg(elapsed),0) as elapsed, ".
    " round(stddev(elapsed),1) as elapsed_dev ".
    " from macro ".
    " left join scenario on macro.scenario=scenario.id ".
    " where fs=".$_fs." and bench=".$_bench." and conf=".$_conf.
    $selected_scenarios.$filter_where.
    " group by scenario order by scenario.".$_loss_delay." asc;";
  $res = $_db->query($sql);
  $iops = array();
  $iops_dev = array();
  $elapsed = array();
  $elapsed_dev = array();
  while ($entry = $res->fetch_assoc()) {
   $iops[] = $entry['iops'];
   $iops_dev[] = $entry['iops_dev'];
   $elapsed[] = $entry['elapsed'];
   $elapsed_dev[] = $entry['elapsed_dev'];
  }
  $res->close();

  $ar_name = $_prefix."macroTIME".$_loss_delay."_t".$_fs."_b".$_bench."_g".$_conf;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($elapsed as $v) { echo $v." "; }
  echo "];\n";
  $ar_name = $_prefix."macroTIMEdev".$_loss_delay."_t".$_fs."_b".$_bench."_g".$_conf;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($elapsed_dev as $v) { echo $v." "; }
  echo "];\n";

  $ar_name = $_prefix."macroIOPS".$_loss_delay."_t".$_fs."_b".$_bench."_g".$_conf;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($iops as $v) { echo $v." "; }
  echo "];\n";
  $ar_name = $_prefix."macroIOPSdev".$_loss_delay."_t".$_fs."_b".$_bench."_g".$_conf;
  echo "global $ar_name\n$ar_name = [ ";
  foreach ($iops_dev as $v) { echo $v." "; }
  echo "];\n";
 }

 function gen_scenario_list()
 {
  global $scenario_list;
  $ar_name = "scenario_remark_list";
  echo "global $ar_name\n$ar_name = { ";
  foreach ($scenario_list as $s) {
    echo " '".$s->remark."', ";
  }
  echo " };\n";
  $ar_name = "scenario_delay_list";
  echo "global $ar_name\n$ar_name = { ";
  foreach ($scenario_list as $s) {
    echo " '".$s->delay."', ";
  }
  echo " };\n";
  $ar_name = "scenario_loss_list";
  echo "global $ar_name\n$ar_name = { ";
  foreach ($scenario_list as $s) {
    echo " '".$s->loss."', ";
  }
  echo " };\n";

 }

 /* +++++++++++++++++++++++++++++++++++++++++++++ */

 if (strcmp($date_where, "")) {
  echo "% date_where = ".$date_where."\n";
 }
 if (strcmp($bucketed_4k_where, "")) {
  echo "% buckted_4k_where = ".$bucketed_4k_where."\n";
 }

 gen_scenario_list();

 // tcs2 local disk
 gen_meta_series($db, 0, 0, 'mkdir');
 gen_meta_series($db, 0, 0, 'touch');
 gen_meta_series($db, 0, 0, 'ls');
 gen_meta_series($db, 0, 0, 'unlink');
 gen_meta_series($db, 0, 0, 'rmdir');
 gen_thp_bs_series($db, 0, 0, 'd', 'r');
 gen_thp_bs_series($db, 0, 0, 'd', 'w');
 gen_thp_one_file_series($db, 0, 0, 'd', 'r');
 gen_thp_one_file_series($db, 0, 0, 'd', 'w');
 gen_thp_thread_series($db, 0, 0, 'd', 4096, 'r');
 gen_thp_thread_series($db, 0, 0, 'd', 4096, 'w');
 gen_thp_thread_series($db, 0, 0, 'd', 1048576, 'r');
 gen_thp_thread_series($db, 0, 0, 'd', 1048576, 'w');
 gen_thp_thread_series($db, 0, 0, 'd', 16777216, 'r');
 gen_thp_thread_series($db, 0, 0, 'd', 16777216, 'w');
 gen_one_thread_series($db, 0, 0, 'd', 'r');
 gen_one_thread_series($db, 0, 0, 'd', 'w');
 gen_thp_bs_series($db, 0, 0, 's', 'r');
 gen_thp_bs_series($db, 0, 0, 's', 'w');
 gen_thp_one_file_series($db, 0, 0, 's', 'r');
 gen_thp_one_file_series($db, 0, 0, 's', 'w');
 gen_thp_thread_series($db, 0, 0, 's', 4096, 'r');
 gen_thp_thread_series($db, 0, 0, 's', 4096, 'w');
 gen_thp_thread_series($db, 0, 0, 's', 1048576, 'r');
 gen_thp_thread_series($db, 0, 0, 's', 1048576, 'w');
 gen_thp_thread_series($db, 0, 0, 's', 16777216, 'r');
 gen_thp_thread_series($db, 0, 0, 's', 16777216, 'w');
 gen_one_thread_series($db, 0, 0, 's', 'r');
 gen_one_thread_series($db, 0, 0, 's', 'w');


 // 1Gbps vs RTT=0,20,50,160,250
 $delay_scenarios = array( 1, 14, 7, 12, 9 );
 foreach (array(4096,1048576,16777216) as $j) {
  // n_threads
  foreach (array(1,8,32) as $n) {
   gen_thp_delay($db, $delay_scenarios, 'GbE', 1, 's', $n, $j, 'r');
   gen_thp_delay($db, $delay_scenarios, 'GbE', 1, 'd', $n, $j, 'r');
   gen_thp_delay($db, $delay_scenarios, 'GbE', 2, 's', $n, $j, 'r');
   gen_thp_delay($db, $delay_scenarios, 'GbE', 2, 'd', $n, $j, 'r');
   gen_thp_delay($db, $delay_scenarios, 'GbE', 3, 's', $n, $j, 'r');
   gen_thp_delay($db, $delay_scenarios, 'GbE', 3, 'd', $n, $j, 'r');
   gen_thp_delay($db, $delay_scenarios, 'GbE', 5, 'def', $n, $j, 'r');
   gen_thp_delay($db, $delay_scenarios, 'GbE', 1, 's', $n, $j, 'w');
   gen_thp_delay($db, $delay_scenarios, 'GbE', 1, 'd', $n, $j, 'w');
   gen_thp_delay($db, $delay_scenarios, 'GbE', 2, 's', $n, $j, 'w');
   gen_thp_delay($db, $delay_scenarios, 'GbE', 2, 'd', $n, $j, 'w');
   gen_thp_delay($db, $delay_scenarios, 'GbE', 3, 's', $n, $j, 'w');
   gen_thp_delay($db, $delay_scenarios, 'GbE', 3, 'd', $n, $j, 'w');
   gen_thp_delay($db, $delay_scenarios, 'GbE', 5, 'def', $n, $j, 'w');
  }
 }
 foreach (array(1,2,3,5) as $fs) {
  gen_macro_delay($db, $delay_scenarios, 'GbE', $fs, 1, 1);
  gen_macro_delay($db, $delay_scenarios, 'GbE', $fs, 2, 2);
  gen_macro_delay($db, $delay_scenarios, 'GbE', $fs, 3, 3);
  gen_macro_delay($db, $delay_scenarios, 'GbE', $fs, 3, 4);
  gen_meta_delay($db, $delay_scenarios, 'GbE', $fs, 'mkdir');
  gen_meta_delay($db, $delay_scenarios, 'GbE', $fs, 'ls');
 }

 // 1Gbps vs loss 0, 0.1, 1, 2.5
 $loss_scenarios = array( 1, 23, 10, 11 );
 foreach (array(4096,1048576,16777216) as $j) {
  // n_threads
  foreach (array(1,8,32) as $n) {
   gen_thp_loss($db, $loss_scenarios, 'GbE', 1, 's', $n, $j, 'r');
   gen_thp_loss($db, $loss_scenarios, 'GbE', 1, 'd', $n, $j, 'r');
   gen_thp_loss($db, $loss_scenarios, 'GbE', 2, 's', $n, $j, 'r');
   gen_thp_loss($db, $loss_scenarios, 'GbE', 2, 'd', $n, $j, 'r');
   gen_thp_loss($db, $loss_scenarios, 'GbE', 3, 's', $n, $j, 'r');
   gen_thp_loss($db, $loss_scenarios, 'GbE', 3, 'd', $n, $j, 'r');
   gen_thp_loss($db, $loss_scenarios, 'GbE', 5, 'def', $n, $j, 'r');
   gen_thp_loss($db, $loss_scenarios, 'GbE', 1, 's', $n, $j, 'w');
   gen_thp_loss($db, $loss_scenarios, 'GbE', 1, 'd', $n, $j, 'w');
   gen_thp_loss($db, $loss_scenarios, 'GbE', 2, 's', $n, $j, 'w');
   gen_thp_loss($db, $loss_scenarios, 'GbE', 2, 'd', $n, $j, 'w');
   gen_thp_loss($db, $loss_scenarios, 'GbE', 3, 's', $n, $j, 'w');
   gen_thp_loss($db, $loss_scenarios, 'GbE', 3, 'd', $n, $j, 'w');
   gen_thp_loss($db, $loss_scenarios, 'GbE', 5, 'def', $n, $j, 'w');
  }
 }
 foreach (array(1,2,3,5) as $fs) {
  gen_macro_loss($db, $loss_scenarios, 'GbE', $fs, 1, 1);
  gen_macro_loss($db, $loss_scenarios, 'GbE', $fs, 2, 2);
  gen_macro_loss($db, $loss_scenarios, 'GbE', $fs, 3, 3);
  gen_macro_loss($db, $loss_scenarios, 'GbE', $fs, 3, 4);
  gen_meta_loss($db, $loss_scenarios, 'GbE', $fs, 'mkdir');
  gen_meta_loss($db, $loss_scenarios, 'GbE', $fs, 'ls');
 }


 // 100M vs RTT=0,20,50,160,250
 $delay_scenarios = array( 3, 18, 5, 19, 20 );
 foreach (array(4096,1048576,16777216) as $j) {
  // n_threads
  foreach (array(1,8,32) as $n) {
   gen_thp_delay($db, $delay_scenarios, 'FastE', 1, 's', $n, $j, 'r');
   gen_thp_delay($db, $delay_scenarios, 'FastE', 1, 'd', $n, $j, 'r');
   gen_thp_delay($db, $delay_scenarios, 'FastE', 2, 's', $n, $j, 'r');
   gen_thp_delay($db, $delay_scenarios, 'FastE', 2, 'd', $n, $j, 'r');
   gen_thp_delay($db, $delay_scenarios, 'FastE', 3, 's', $n, $j, 'r');
   gen_thp_delay($db, $delay_scenarios, 'FastE', 3, 'd', $n, $j, 'r');
   gen_thp_delay($db, $delay_scenarios, 'FastE', 5, 'def', $n, $j, 'r');
   gen_thp_delay($db, $delay_scenarios, 'FastE', 1, 's', $n, $j, 'w');
   gen_thp_delay($db, $delay_scenarios, 'FastE', 1, 'd', $n, $j, 'w');
   gen_thp_delay($db, $delay_scenarios, 'FastE', 2, 's', $n, $j, 'w');
   gen_thp_delay($db, $delay_scenarios, 'FastE', 2, 'd', $n, $j, 'w');
   gen_thp_delay($db, $delay_scenarios, 'FastE', 3, 's', $n, $j, 'w');
   gen_thp_delay($db, $delay_scenarios, 'FastE', 3, 'd', $n, $j, 'w');
   gen_thp_delay($db, $delay_scenarios, 'FastE', 5, 'def', $n, $j, 'w');
  }
 }
 foreach (array(1,2,3,5) as $fs) {
  gen_macro_delay($db, $delay_scenarios, 'FastE', $fs, 1, 1);
  gen_macro_delay($db, $delay_scenarios, 'FastE', $fs, 2, 2);
  gen_macro_delay($db, $delay_scenarios, 'FastE', $fs, 3, 3);
  gen_macro_delay($db, $delay_scenarios, 'FastE', $fs, 3, 4);
  gen_meta_delay($db, $delay_scenarios, 'FastE', $fs, 'mkdir');
  gen_meta_delay($db, $delay_scenarios, 'FastE', $fs, 'ls');
 }


 // 100Mbps vs loss 0, 0.1, 1, 2.5
 $loss_scenarios = array( 3, 25, 21, 22 );
 foreach (array(4096,1048576,16777216) as $j) {
  // n_threads
  foreach (array(1,8,32) as $n) {
   gen_thp_loss($db, $loss_scenarios, 'FastE', 1, 's', $n, $j, 'r');
   gen_thp_loss($db, $loss_scenarios, 'FastE', 1, 'd', $n, $j, 'r');
   gen_thp_loss($db, $loss_scenarios, 'FastE', 2, 's', $n, $j, 'r');
   gen_thp_loss($db, $loss_scenarios, 'FastE', 2, 'd', $n, $j, 'r');
   gen_thp_loss($db, $loss_scenarios, 'FastE', 3, 's', $n, $j, 'r');
   gen_thp_loss($db, $loss_scenarios, 'FastE', 3, 'd', $n, $j, 'r');
   gen_thp_loss($db, $loss_scenarios, 'FastE', 5, 'def', $n, $j, 'r');
   gen_thp_loss($db, $loss_scenarios, 'FastE', 1, 's', $n, $j, 'w');
   gen_thp_loss($db, $loss_scenarios, 'FastE', 1, 'd', $n, $j, 'w');
   gen_thp_loss($db, $loss_scenarios, 'FastE', 2, 's', $n, $j, 'w');
   gen_thp_loss($db, $loss_scenarios, 'FastE', 2, 'd', $n, $j, 'w');
   gen_thp_loss($db, $loss_scenarios, 'FastE', 3, 's', $n, $j, 'w');
   gen_thp_loss($db, $loss_scenarios, 'FastE', 3, 'd', $n, $j, 'w');
   gen_thp_loss($db, $loss_scenarios, 'FastE', 5, 'def', $n, $j, 'w');
  }
 }
 foreach (array(1,2,3,5) as $fs) {
  gen_macro_loss($db, $loss_scenarios, 'FastE', $fs, 1, 1);
  gen_macro_loss($db, $loss_scenarios, 'FastE', $fs, 2, 2);
  gen_macro_loss($db, $loss_scenarios, 'FastE', $fs, 3, 3);
  gen_macro_loss($db, $loss_scenarios, 'FastE', $fs, 3, 4);
  gen_meta_loss($db, $loss_scenarios, 'FastE', $fs, 'mkdir');
  gen_meta_loss($db, $loss_scenarios, 'FastE', $fs, 'ls');
 }


 $general_scenarios=array(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27);
 foreach ($general_scenarios as $s) {
  foreach (array(4096,1048576,16777216) as $j) {
   gen_thp_thread_series($db, $s, 1, 's', $j, 'r'); 
   gen_thp_thread_series($db, $s, 1, 'd', $j, 'r'); 
   gen_thp_thread_series($db, $s, 2, 's', $j, 'r'); 
   gen_thp_thread_series($db, $s, 2, 'd', $j, 'r'); 
   gen_thp_thread_series($db, $s, 3, 's', $j, 'r'); 
   gen_thp_thread_series($db, $s, 3, 'd', $j, 'r'); 
   gen_thp_thread_series($db, $s, 5, 'def', $j, 'r'); 
   gen_thp_thread_series($db, $s, 1, 's', $j, 'w'); 
   gen_thp_thread_series($db, $s, 1, 'd', $j, 'w'); 
   gen_thp_thread_series($db, $s, 2, 's', $j, 'w'); 
   gen_thp_thread_series($db, $s, 2, 'd', $j, 'w'); 
   gen_thp_thread_series($db, $s, 3, 's', $j, 'w'); 
   gen_thp_thread_series($db, $s, 3, 'd', $j, 'w'); 
   gen_thp_thread_series($db, $s, 5, 'def', $j, 'w');
  }

  gen_meta_series($db, $s, 1, 'mkdir');
  gen_meta_series($db, $s, 2, 'mkdir');
  gen_meta_series($db, $s, 3, 'mkdir');
  gen_meta_series($db, $s, 5, 'mkdir');
  gen_meta_series($db, $s, 1, 'ls');
  gen_meta_series($db, $s, 2, 'ls');
  gen_meta_series($db, $s, 3, 'ls');
  gen_meta_series($db, $s, 5, 'ls');
  gen_meta_series($db, $s, 1, 'unlink');
  gen_meta_series($db, $s, 2, 'unlink');
  gen_meta_series($db, $s, 3, 'unlink');
  gen_meta_series($db, $s, 5, 'unlink');



  gen_thp_bs_series($db, $s, 1, 'd', 'r');
  gen_thp_bs_series($db, $s, 1, 's', 'r');  
  gen_thp_bs_series($db, $s, 2, 's', 'r');
  gen_thp_bs_series($db, $s, 2, 'd', 'r');
  gen_thp_bs_series($db, $s, 3, 's', 'r');
  gen_thp_bs_series($db, $s, 3, 'd', 'r');
  gen_thp_bs_series($db, $s, 5, 'def', 'r');
  gen_thp_bs_series($db, $s, 1, 's', 'w');
  gen_thp_bs_series($db, $s, 1, 'd', 'w');
  gen_thp_bs_series($db, $s, 2, 's', 'w');
  gen_thp_bs_series($db, $s, 2, 'd', 'w');
  gen_thp_bs_series($db, $s, 3, 's', 'w');
  gen_thp_bs_series($db, $s, 3, 'd', 'w');
  gen_thp_bs_series($db, $s, 5, 'def', 'w');
 
  gen_thp_one_file_series($db, $s, 1, 'd', 'r');
  gen_thp_one_file_series($db, $s, 1, 's', 'r');
  gen_thp_one_file_series($db, $s, 2, 's', 'r');
  gen_thp_one_file_series($db, $s, 2, 'd', 'r');
  gen_thp_one_file_series($db, $s, 3, 's', 'r');
  gen_thp_one_file_series($db, $s, 3, 'd', 'r');
  gen_thp_one_file_series($db, $s, 5, 'def', 'r');
  gen_thp_one_file_series($db, $s, 1, 's', 'w');
  gen_thp_one_file_series($db, $s, 1, 'd', 'w');
  gen_thp_one_file_series($db, $s, 2, 's', 'w');
  gen_thp_one_file_series($db, $s, 2, 'd', 'w');
  gen_thp_one_file_series($db, $s, 3, 's', 'w');
  gen_thp_one_file_series($db, $s, 3, 'd', 'w');
  gen_thp_one_file_series($db, $s, 5, 'def', 'w');
 }

 // Additional scenarios for access pattern comparison
 foreach (array(1,3,5,7) as $s) {
  gen_thp_bs_series($db, $s, 1, 'def', 'r');
  gen_thp_bs_series($db, $s, 1, 'def', 'w');
  gen_thp_bs_series($db, $s, 2, 'def', 'r');
  gen_thp_bs_series($db, $s, 2, 'def', 'w');
  gen_thp_bs_series($db, $s, 3, 'def', 'r');
  gen_thp_bs_series($db, $s, 3, 'def', 'w');
 }

 // One-Thread over job_size, list desired scenarios
 foreach (array(1,2,3,4,5,6,7,8,16,17,24,26,27) as $s) {
  gen_one_thread_series($db, $s, 1, 'd', 'r');
  gen_one_thread_series($db, $s, 1, 's', 'r');
  gen_one_thread_series($db, $s, 2, 'd', 'r');
  gen_one_thread_series($db, $s, 2, 's', 'r');
  gen_one_thread_series($db, $s, 3, 'd', 'r');
  gen_one_thread_series($db, $s, 3, 's', 'r');
  gen_one_thread_series($db, $s, 4, 'd', 'r');
  gen_one_thread_series($db, $s, 4, 's', 'r');
  gen_one_thread_series($db, $s, 5, 'def', 'r');
  gen_one_thread_series($db, $s, 1, 'd', 'w');
  gen_one_thread_series($db, $s, 1, 's', 'w');
  gen_one_thread_series($db, $s, 2, 'd', 'w');
  gen_one_thread_series($db, $s, 2, 's', 'w');
  gen_one_thread_series($db, $s, 3, 'd', 'w');
  gen_one_thread_series($db, $s, 3, 's', 'w');
  gen_one_thread_series($db, $s, 4, 'd', 'w');
  gen_one_thread_series($db, $s, 4, 's', 'w');
  gen_one_thread_series($db, $s, 5, 'def', 'w');
 }

 $db->close();
?>

