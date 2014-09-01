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

 if (true == $show_elapsed) {
  $field_shown = "elapsed";
  echo "<h3>Showing elapsed time instead. (Not necessarily meaningful!)</h3>";
  echo "<h3>Unit: Seconds</h3>";
 } else {
  $field_shown = "throughput";
  echo "<h3>Unit: IOPS</h3>";
 }

 foreach ($benchmark_list as $b) {
  $b->results = array();
  if ($show_standard_deviation == false) {
   $sql = "select round(avg($field_shown),3) as throughput ";
  } else {
   $sql = "select round(stddev($field_shown),3) as throughput ";
  }
  $sql .= ",scenario,fs from macro ".
       "where bench=".$b->bench_id." and conf=".$b->conf_id.$filter_where.
       " group by scenario,fs order by scenario asc, fs asc";

  //echo "sql: ".$sql."<br />\n";
  $res = $db->query($sql);
  while ($entry = $res->fetch_assoc()) {
   //echo "entry: scenario:".$entry['scenario']." fs:".$entry['fs']." thp:".$entry['throughput']."<br />\n";
   $b->results[$entry['scenario']][$entry['fs']] = $entry['throughput'];
  }
  $res->close();
  echo "<h4>bench: ".$b->bench." conf:<a href=\"view-macroconf.php?conf=".$b->conf_id."\">".$b->conf."</a></h4>\n";

  if (isset($b->results[0][0])) { // local
   echo "local ext4 disk: ".$b->results[0][0]."<br />\n";
  }

  echo "<table border=\"1\">\n<caption>bench: ".$b->bench." conf:".$b->conf."</caption>\n";
  echo "<tr><th>id</th><th>bandwidth</th><th>delay</th><th>loss</th><th>jitter</th><th>remark</th>";
  foreach ($available_fs as $fs) {
   if ($fs->id == 0) { continue; } // local
   echo "<th>".$fs->name."</th>";
  }
  echo "</tr>\n";
  //print_r($b->results);
  foreach ($scenario_list as $scene) {
   if (!strcmp($scene->clean,"yes")) { continue; } // not applicable
   if ($scene->id == 0) { continue; } // local
   if (!isset($b->results[$scene->id])) { continue; } // no results
   echo "<tr>";
   echo "<td>".$scene->id."</td><td>".$scene->bandwidth."</td><td>".$scene->delay."</td><td>".$scene->loss."</td><td>".$scene->jitter."</td><td>".$scene->remark."</td>";
   foreach ($available_fs as $fs) {
    if ($fs->id == 0) { continue; } // local
    echo "<td>";
    if (isset($b->results[$scene->id][$fs->id])) {
     echo $b->results[$scene->id][$fs->id];
    } else { echo 'X'; }
    echo "</td>";
   }
   echo "</tr>\n";
  }
  echo "</table>\n";
 }
?>


<?php
 $db->close();
?>
</body>
</html>

