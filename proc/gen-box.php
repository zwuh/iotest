<?php
 require_once('common_head.php');

 /* Generate matrices for boxplot(). */

 function gen_meta_box($_db, $_scenario, $_fs, $_op)
 {
  global $date_where;
  $filter_where = " scenario=".$_scenario." and fs=".$_fs." and op='".$_op."' ".$date_where;
  $sql = "select distinct n_jobs as k from metadata where ".$filter_where." order by k asc";
  $res = $_db->query($sql);
  $keys = array();
  while ($entry = $res->fetch_assoc()) {
   $keys[] = $entry['k'];
  }
  $res->close();

  $ar_name = "metaTIME_c".$_scenario."_t".$_fs."_".$_op;
  echo "global $ar_name\n$ar_name = {\n";
  foreach($keys as $k) {
   echo " [";
   $sql = "select elapsed from metadata where ".$filter_where." and n_jobs=$k";
   $res = $_db->query($sql);
   while ($entry = $res->fetch_assoc()) {
    echo $entry['elapsed'].",";
   }
   echo " ],\n";
   $res->close();
  }
  echo " };\n";
 }


 function gen_thp_thread_box($_db, $_scenario, $_fs, $_flag, $_job_size, $_rw)
 {
  global $date_where;
  global $bucketed_4k_where;
  $filter_where = "scenario=".$_scenario." and fs=".$_fs.
    " and job_size=".$_job_size." and flag='".$_flag.
    "' and rw='".$_rw."' ".
    $date_where.$bucketed_4k_where;

  $sql = "select distinct n_threads as k from file where ".$filter_where." order by k asc";
  $res = $_db->query($sql);
  $keys = array();
  while ($entry = $res->fetch_assoc()) {
   $keys[] = $entry['k'];
  }
  $res->close();

  $ar_name = "fileTHPvNTH_c".$_scenario."_t".$_fs."_F".$_flag."_j".$_job_size."_".$_rw;
  echo "global $ar_name\n$ar_name = {\n";
  foreach($keys as $k) {
   echo " [";
   $sql = "select throughput thp from file where ".$filter_where." and n_threads=$k";
   $res = $_db->query($sql);
   while ($entry = $res->fetch_assoc()) {
    echo $entry['thp'].",";
   }
   echo " ],\n";
   $res->close();
  }
  echo " };\n";
 }


 function gen_thp_bs_box($_db, $_scenario, $_fs, $_flag, $_rw)
 {
  global $date_where;
  $filter_where = " job_size=16777216 and n_threads=1 and scenario=".$_scenario.
    " and fs=".$_fs." and flag='".$_flag."' and rw='".$_rw."' ".$date_where;

  $sql = "select distinct block_size as k from blocksize where ".$filter_where." order by k asc";
  $res = $_db->query($sql);
  $keys = array();
  while ($entry = $res->fetch_assoc()) {
   $keys[] = $entry['k'];
  }
  $res->close();

  $ar_name = "bsTHP_c".$_scenario."_t".$_fs."_F".$_flag."_".$_rw;
  echo "global $ar_name\n$ar_name = {\n";
  foreach($keys as $k) {
   echo " [";
   $sql = "select throughput as thp from blocksize where ".$filter_where." and block_size=$k";
   $res = $_db->query($sql);
   while ($entry = $res->fetch_assoc()) {
    echo $entry['thp'].",";
   }
   echo " ],\n";
   $res->close();
  }
  echo " };\n";
 }


 function gen_one_thread_box($_db, $_scenario, $_fs, $_flag, $_rw)
 {
  global $date_where;
  global $bucketed_4k_where;
  $filter_where = " n_threads=1 and scenario=".$_scenario.
    " and fs=".$_fs." and flag='".$_flag."' and rw='".$_rw."' ".
    $date_where.$bucketed_4k_where;

  $sql = "select distinct job_size as k from file where ".$filter_where." order by k asc";
  $res = $_db->query($sql);
  $keys = array();
  while ($entry = $res->fetch_assoc()) {
   $keys[] = $entry['k'];
  }
  $res->close();

  $ar_name = "sthTHP_c".$_scenario."_t".$_fs."_F".$_flag."_".$_rw;
  echo "global $ar_name\n$ar_name = {\n";
  foreach($keys as $k) {
   echo " [";
   $sql = "select throughput as thp from file where ".$filter_where." and job_size=$k";
   $res = $_db->query($sql);
   while ($entry = $res->fetch_assoc()) {
    echo $entry['thp'].",";
   }
   echo " ],\n";
   $res->close();
  }
  echo " };\n";
 }


 function gen_thp_one_file_box($_db, $_scenario, $_fs, $_flag, $_rw)
 {
  global $date_where;
  $filter_where = " job_size=block_size and n_threads=1 and scenario=".$_scenario.
    " and fs=".$_fs." and flag='".$_flag."' and rw='".$_rw."' ".
    $date_where;

  $sql = "select distinct job_size as k from blocksize where ".$filter_where." order by k asc";
  $res = $_db->query($sql);
  $keys = array();
  while ($entry = $res->fetch_assoc()) {
   $keys[] = $entry['k'];
  }
  $res->close();

  $ar_name = "oneTHP_c".$_scenario."_t".$_fs."_F".$_flag."_".$_rw;
  echo "global $ar_name\n$ar_name = {\n";
  foreach($keys as $k) {
   echo " [";
   $sql = "select throughput as thp from blocksize where ".$filter_where." and block_size=$k";
   $res = $_db->query($sql);
   while ($entry = $res->fetch_assoc()) {
    echo $entry['thp'].",";
   }
   echo " ],\n";
   $res->close();
  }
  echo " };\n";
 }


 function gen_macro_box($_db, $_fs, $_bench, $_conf)
 {
  global $date_where;
  $filter_where = " bench=$_bench and conf=$_conf and fs=$_fs ".$date_where;

  $sql = "select distinct scenario as k from macro where ".$filter_where;
  $res = $_db->query($sql);
  $keys = array();
  while ($entry = $res->fetch_assoc()) {
   $keys[] = $entry['k'];
  }
  $res->close();

  $ar_name = "macro_t".$_fs."_b".$_bench."_c".$_conf;
  echo "global $ar_name\n$ar_name = {\n";
  foreach($keys as $k) {
   echo " [";
   $sql = "select throughput as thp from macro where ".$filter_where." and scenario=$k";
   $res = $_db->query($sql);
   while ($entry = $res->fetch_assoc()) {
    echo $entry['thp'].",";
   }
   echo " ],\n";
   $res->close();
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

 $scenario_list = array(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27);
 $fs_list = array(1,2,3,4,5);
 $rw_list = array('r','w');
 $job_size_list = array(4096,1048576,16777216);
 $flag_list = array('d','s');
 $meta_op_list = array('mkdir','ls');
 $sth_scenario_list = array(1,2,3,4,5,6,7,8,16,17,24,26,27);
 $bs_def_scenario_list = array(1,3,5,7);

 // baseline
 foreach ($meta_op_list as $op) {
  gen_meta_box($db, 0, 0, $op);
 }
 foreach ($rw_list as $rw) {
  foreach ($flag_list as $flag) {
   foreach ($job_size_list as $job_size) {
    gen_thp_thread_box($db, 0, 0, $flag, $job_size, $rw);
   }
   gen_thp_bs_box($db, 0, 0, $flag, $rw);
   gen_one_thread_box($db, 0, 0, $flag, $rw);
   gen_thp_one_file_box($db, 0, 0, $flag, $rw);
  }
 }
 gen_macro_box($db, 0, 1, 1);
 gen_macro_box($db, 0, 2, 2);
 gen_macro_box($db, 0, 3, 3);
 gen_macro_box($db, 0, 3, 4);

 // network
 foreach ($scenario_list as $scenario) {
  foreach ($fs_list as $fs) {
   foreach ($meta_op_list as $op) {
    gen_meta_box($db, $scenario, $fs, $op);
   }
   foreach ($rw_list as $rw) {
    if ($fs == 5) {
     foreach ($job_size_list as $job_size) {
      gen_thp_thread_box($db, $scenario, $fs, 'def', $job_size, $rw);
     }
     gen_thp_bs_box($db, $scenario, $fs, 'def', $rw);
     gen_thp_one_file_box($db, $scenario, $fs, 'def', $rw);
    } else {
     foreach ($flag_list as $flag) {
      foreach ($job_size_list as $job_size) {
       gen_thp_thread_box($db, $scenario, $fs, $flag, $job_size, $rw);
      }
      gen_thp_bs_box($db, $scenario, $fs, $flag, $rw);
      gen_thp_one_file_box($db, $scenario, $fs, $flag, $rw);
     }
    }
   }
  }
 }

 foreach ($sth_scenario_list as $scenario) {
  foreach ($rw_list as $rw) {
   foreach ($fs_list as $fs) {
    if ($fs == 5) {
     gen_one_thread_box($db, $scenario, $fs, 'def', $rw);
    } else {
     gen_one_thread_box($db, $scenario, $fs, 'd', $rw);
     gen_one_thread_box($db, $scenario, $fs, 's', $rw);
    }
   }
  }
 }

 foreach ($bs_def_scenario_list as $scenario) {
  foreach ($rw_list as $rw) {
   gen_thp_bs_box($db, $scenario, 1, 'def', $rw);
   gen_thp_bs_box($db, $scenario, 2, 'def', $rw);
   gen_thp_bs_box($db, $scenario, 3, 'def', $rw);
  }
 }


 foreach ($fs_list as $fs) {
  gen_macro_box($db, $fs, 1, 1);
  gen_macro_box($db, $fs, 2, 2);
  gen_macro_box($db, $fs, 3, 3);
  gen_macro_box($db, $fs, 3, 4);
 }


 $db->close();
?>

