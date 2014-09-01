<!DOCTYPE html>
<html>
<head>
<title>macrobenchmark</title>
<link rel="stylesheet"  type="text/css"  href="style.css" media="screen" />
</head>
<body>
<?php
 require_once('common_head.php');

 show_filter_form('view-macro.php');

 $filter_where = $scenario_where . $date_where;

 class macrobench {
  var $bench_id;
  var $conf_id;
  var $bench;
  var $conf;
  var $results;
 }

 $sql = "select distinct macro.bench as bench_id, macro.conf as conf_id, ".
        "macrobench.name as bench, macroconf.remark as conf from macro ".
        "left join macrobench on macro.bench=macrobench.id ".
        "left join macroconf on macro.conf=macroconf.id ".
        "where 1 ".$filter_where." order by bench asc, conf asc";
 $res = $db->query($sql);
 $benchmark_list = array();
 while ($entry = $res->fetch_assoc()) {
  $r_ent = new macrobench();
  $r_ent->bench_id = $entry['bench_id'];
  $r_ent->conf_id = $entry['conf_id'];
  $r_ent->bench = $entry['bench'];
  $r_ent->conf = $entry['conf'];
  $benchmark_list[] = $r_ent;
 }
 $res->close();

 echo "<pre>\n";

 foreach ($benchmark_list as $b) {
  $b->results = array();
  if ($show_standard_deviation == false) {
   $sql = "select round(avg(throughput),0) as iops, round(avg(elapsed),0) as time ";
  } else {
   echo "% Standard Deviation !\n";
   $sql = "select round(stddev(throughput),0) as iops, round(stddev(elapsed),0) as time ";
  }
  $sql .= ",scenario,fs from macro ".
       "where bench=".$b->bench_id." and conf=".$b->conf_id.$filter_where.
       " group by scenario,fs order by scenario asc, fs asc";

  //echo "% sql: ".$sql."<br />\n";
  $res = $db->query($sql);
  while ($entry = $res->fetch_assoc()) {
   //echo "entry: scenario:".$entry['scenario']." fs:".$entry['fs']." thp:".$entry['throughput']."<br />\n";
   $b->results[$entry['scenario']][$entry['fs']] =
    array( "iops" => $entry['iops'], "time" => $entry['time'] );
  }
  $res->close();

  echo "% bench: ".$b->bench." conf:".$b->conf."\n";
  if ($b->bench_id == 3) // FileBench
  {
   echo "% scenario remark, nfs iops, cfq iops, dead iops, swift iops\n";
  } else {
   echo "% scenario remark, nfs iops, nfs time, cfq iops, cfq time, dead iops, dead time, swift iops, swift time\n";
  }

  foreach ($scenario_list as $scene) {
   if (!strcmp($scene->clean,"yes")) { continue; } // not applicable
   if ($scene->id == 0) { continue; } // local
   if (!isset($b->results[$scene->id])) { continue; } // no results
   $r = $b->results[$scene->id];
   echo $scene->remark;
   if ($b->bench_id == 3)
   {
    echo " & ".$r[1]['iops'].
     " & ".$r[2]['iops'].
     " & ".$r[3]['iops'].
     " & ".$r[5]['iops'];
   } else {
    echo " & ".$r[1]['iops']." & ".$r[1]['time'].
     " & ".$r[2]['iops']." & ".$r[2]['time'].
     " & ".$r[3]['iops']." & ".$r[3]['time'].
     " & ".$r[5]['iops']." & ".$r[5]['time'];
   }
   echo " \\\\\n";
  }
  echo "% end\n\n\n";
 }

 echo "</pre>\n";
?>


<?php
 $db->close();
?>
</body>
</html>

