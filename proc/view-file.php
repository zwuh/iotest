<!DOCTYPE html>
<html>
<head>
<title>File</title>
<link rel="stylesheet"  type="text/css"  href="style.css" media="screen" />
</head>
<body>

<?php
 require_once('common_head.php');
 set_default_scenario_if_not_set();
 show_filter_form('view-file.php');
 show_fs_list_in_table($available_fs);
 $filter_where = $scenario_where.$date_where.$bucketed_4k_where;

 // Get a list of job_size's
 $job_size_list = array();
 $res = $db->query("select distinct job_size from file where 1 $filter_where order by job_size asc");
 while ($entry = $res->fetch_assoc()) {
  //echo "job size: ".$entry['job_size']."\n";
  $job_size_list[] = $entry['job_size'];
 }
 $res->close();
 // Get a list of flag's
 $flag_list = array();
 $res = $db->query("select distinct flag from file where 1 $filter_where order by flag asc");
 while ($entry = $res->fetch_assoc()) {
  //echo "flag: ".$entry['flag']."\n";
  $flag_list[] = $entry['flag'];
 }
 $res->close();
 // Get a list of n_threads'
 $n_threads_list = array();
 $res = $db->query("select distinct n_threads from file where 1 $filter_where order by n_threads asc");
 while ($entry = $res->fetch_assoc()) {
  //echo "n_threads: ".$entry['n_threads']."\n";
  $n_threads_list[] = $entry['n_threads'];
 }
 $res->close();
 
 class result_entry {
  var $throughput;
  var $xfer;
  var $pps;
 }

 show_scenario_heading($scenario, "File-Test");

 echo "Start date: ".$start_date;
 echo " End date: ".$end_date;
 echo "<br />\n";

 $results = array();

 $thp_field = "throughput";
 if (true == $show_elapsed) {
  echo "<h2>Showing Elapsed Time instead of Throughput</h2>\n";
  $thp_field = "elapsed";
 }
 if (true == $show_standard_deviation) {
  echo "<h2>Showing Standard Deviation</h2>\n";
  $sql = "select fs, n_threads, flag, job_size, rw, round(stddev($thp_field),3) as thp, round(stddev(transferred/elapsed),2) as xfer, round(stddev(npkt/elapsed),2) as pps from file ";
 } else {
  $sql = "select fs, n_threads, flag, job_size, rw, round(avg($thp_field),3) as thp, round(avg(transferred/elapsed),2) as xfer, round(avg(npkt/elapsed),2) as pps from file ";
 }

 $sql .= " where 1 $filter_where ".
       " group by n_threads, fs, flag, rw, job_size ".
       " order by fs asc, n_threads asc, flag asc, job_size asc, rw asc";
 $res = $db->query($sql);
 echo "SQL: ".$sql."<br />\n";
 echo "Number of rows: ".$res->num_rows."<br />\n";

 while ($entry = $res->fetch_assoc()) {
  $r_ent = new result_entry();
  $r_ent->throughput = $entry['thp'];
  $r_ent->xfer = $entry['xfer'];
  $r_ent->pps = $entry['pps'];
  $results[$entry['fs']][$entry['job_size']][$entry['flag']][$entry['rw']][$entry['n_threads']] = $r_ent;
 }
 $res->close();
 //print_r($results);
 //exit;
 
 foreach ($job_size_list as $job_size) {
  echo "<h4>job_size: ".$job_size."</h4>\n";
  foreach ($available_fs as $fs) {
   if (!isset($results["$fs->id"]) ||
       0 == count($results["$fs->id"]) ||
       0 == count($results["$fs->id"]["$job_size"])) {
     continue;
   }
   echo "<table border=\"1\">\n";
   $n_diff_n_threads = count($n_threads_list);
   echo "<tr><th class=\"target\">".$fs->name."</th><th colspan='".$n_diff_n_threads."'>Write</th><th colspan='".$n_diff_n_threads."'>Read</th></tr>\n";
   echo "<tr><th>n_threads</th>";
   foreach ($n_threads_list as $n_threads) {
    echo "<th>".$n_threads."</th>";
   }
   foreach ($n_threads_list as $n_threads) {
    echo "<th>".$n_threads."</th>";
   }
   echo "</tr>\n";
 
   foreach ($flag_list as $flag) {
    if (!isset($results["$fs->id"]["$job_size"]["$flag"])) {
      continue;
    }
    echo "<tr class=\"throughput\"><th>[".$flag."] thp</th>";
    foreach ($n_threads_list as $n_threads) {
      echo "<td>";
      if (isset($results["$fs->id"]["$job_size"]["$flag"]["w"]["$n_threads"])) {
       echo $results["$fs->id"]["$job_size"]["$flag"]["w"]["$n_threads"]->throughput;
      } else { echo "X"; }
      echo "</td>";
    }
    foreach ($n_threads_list as $n_threads) {
      echo "<td>";
      if (isset($results["$fs->id"]["$job_size"]["$flag"]["r"]["$n_threads"])) {
       echo $results["$fs->id"]["$job_size"]["$flag"]["r"]["$n_threads"]->throughput;
      } else { echo "X"; }
      echo "</td>";
    }
    echo "</tr>\n";
/*
    echo "<tr><th>elapsed</th>";
    foreach ($n_threads_list as $n_threads) {
      echo "<td>";
      if (isset($results["$fs->id"]["$job_size"]["$flag"]["w"]["$n_threads"])) {
       echo $results["$fs->id"]["$job_size"]["$flag"]["w"]["$n_threads"]->elapsed;
      } else { echo "X"; }
      echo "</td>";
    }
    foreach ($n_threads_list as $n_threads) {
      echo "<td>";
      if (isset($results["$fs->id"]["$job_size"]["$flag"]["r"]["$n_threads"])) {
       echo $results["$fs->id"]["$job_size"]["$flag"]["r"]["$n_threads"]->elapsed;
      } else { echo "X"; }
      echo "</td>";
    }
    echo "</tr>\n";
*/
    echo "<tr><th>pps</th>";
    foreach ($n_threads_list as $n_threads) {
      echo "<td>";
      if (isset($results["$fs->id"]["$job_size"]["$flag"]["w"]["$n_threads"])) {
       echo $results["$fs->id"]["$job_size"]["$flag"]["w"]["$n_threads"]->pps;
      } else { echo "X"; }
      echo "</td>";
    }
    foreach ($n_threads_list as $n_threads) {
      echo "<td>";
      if (isset($results["$fs->id"]["$job_size"]["$flag"]["r"]["$n_threads"])) {
       echo $results["$fs->id"]["$job_size"]["$flag"]["r"]["$n_threads"]->pps;
      } else { echo "X"; }
      echo "</td>";
    }
    echo "</tr>\n";


    echo "<tr class=\"line_xfer\"><th>xfer</th>";
    foreach ($n_threads_list as $n_threads) {
      echo "<td>";
      if (isset($results["$fs->id"]["$job_size"]["$flag"]["w"]["$n_threads"])) {
       echo round($results["$fs->id"]["$job_size"]["$flag"]["w"]["$n_threads"]->xfer / 1048576, 3);
      } else { echo "X"; }
      echo "</td>";
    }
    foreach ($n_threads_list as $n_threads) {
      echo "<td>";
      if (isset($results["$fs->id"]["$job_size"]["$flag"]["r"]["$n_threads"])) {
       echo round($results["$fs->id"]["$job_size"]["$flag"]["r"]["$n_threads"]->xfer / 1048576, 3);
      } else { echo "X"; }
      echo "</td>";
    }
    echo "</tr>\n";

/*
    echo "<tr class=\"line_xfer\"><th>xfer_rate</th>";
    foreach ($n_threads_list as $n_threads) {
      echo "<td>";
      if (isset($results["$fs->id"]["$job_size"]["$flag"]["w"]["$n_threads"])) {
       echo round($results["$fs->id"]["$job_size"]["$flag"]["w"]["$n_threads"]->xfer/$results["$fs->id"]["$job_size"]["$flag"]["w"]["$n_threads"]->elapsed/1048576,2);
      } else { echo "X"; }
      echo "</td>";
    }
    foreach ($n_threads_list as $n_threads) {
      echo "<td>";
      if (isset($results["$fs->id"]["$job_size"]["$flag"]["r"]["$n_threads"])) {
       echo round($results["$fs->id"]["$job_size"]["$flag"]["r"]["$n_threads"]->xfer/$results["$fs->id"]["$job_size"]["$flag"]["r"]["$n_threads"]->elapsed/1048576,2);
      } else { echo "X"; }
      echo "</td>";
    }
    echo "</tr>\n";
*/ 
   }
   echo "</table>\n";
  } // fs
 } // job_size

 $db->close();
?>

</body>
</html>

