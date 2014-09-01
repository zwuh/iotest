<!DOCTYPE html>
<html>
<head>
<title>Metadata</title>
<link rel="stylesheet"  type="text/css"  href="style.css" media="screen" />
</head>
<body>

<?php
 require_once('common_head.php');
 set_default_scenario_if_not_set();
 show_filter_form('view-meta.php');
 show_fs_list_in_table($available_fs);

 // Get a list of n_jobs(n_loops)'
 $n_jobs_list = array();
 $res = $db->query("select distinct n_jobs from metadata where 1 $scenario_where $date_where order by n_jobs asc");
 while ($entry = $res->fetch_assoc()) {
  //echo "n_jobs: ".$entry['n_jobs']."\n";
  $n_jobs_list[] = $entry['n_jobs'];
 }
 $res->close();
 
 class result_entry {
  var $elapsed;
  var $transferred;
  var $npkt;
 }

 show_scenario_heading($scenario, "Metadata");

 echo "Start date: ".$start_date;
 echo " End date: ".$end_date;
 echo "<br />\n";

 $results = array();
 if ($show_standard_deviation == true) {
   echo "<h2>Showing Standard Deviation</h2>\n";
   $sql = "select fs, op, n_jobs, round(stddev(elapsed),4) as elapsed, ceil(stddev(transferred)) as transferred, ceil(stddev(npkt)) as npkt from metadata ";
 } else {
   $sql = "select fs, op, n_jobs, round(avg(elapsed),4) as elapsed, ceil(avg(transferred)) as transferred, ceil(avg(npkt)) as npkt from metadata ";
 }
 $sql .= " where 1 $scenario_where $date_where ".
       " group by fs, op, n_jobs ".
       " order by fs asc, op asc, n_jobs asc";
 $res = $db->query($sql);
 echo "SQL: ".$sql."<br />\n";
 echo "Number of rows: ".$res->num_rows."<br />\n";

 // TODO Hard-coded
 $available_op = array('mkdir','touch','ls','unlink','rmdir');

 while ($entry = $res->fetch_assoc()) {
  $r_ent = new result_entry();
  $r_ent->elapsed = $entry['elapsed'];
  $r_ent->transferred = $entry['transferred'];
  $r_ent->npkt = $entry['npkt'];
  $results[$entry['op']][$entry['fs']][$entry['n_jobs']] = $r_ent;
 }
 $res->close();
 //print_r($results);
 //exit;

 foreach ($available_op as $op) {
  if (0 == count($results["$op"])) {
   continue;
  }
  echo "<h4>Operation: ".$op."</h4>\n";
  if (!strcmp($op, "ls")) {
    echo "Note: ls is performed only once<br />\n";
  }
  echo "<table border=\"1\">\n";
  echo "<tr><th></th>";
  foreach ($n_jobs_list as $n_jobs) {
   echo "<th>".$n_jobs."</th>";
  }
  echo "</tr>\n";

  foreach ($available_fs as $fs) {
   if (!isset($results["$op"]) ||
       !isset($results["$op"]["$fs->id"]) ||
       0 == count($results["$op"]["$fs->id"])) {
    continue;
   }
   echo "<tr class=\"time\"><th class=\"target\">".$fs->name."</th>";
   foreach ($n_jobs_list as $n_jobs) {
     echo "<td>";
     if (isset($results["$op"]["$fs->id"]["$n_jobs"])) {
       echo $results["$op"]["$fs->id"]["$n_jobs"]->elapsed;
     } else { echo "X"; }
     echo "</td>";
   }
   echo "</tr>\n";

   echo "<tr><th>npkt</th>";
   foreach ($n_jobs_list as $n_jobs) {
     echo "<td>";
     if (isset($results["$op"]["$fs->id"]["$n_jobs"])) {
       echo $results["$op"]["$fs->id"]["$n_jobs"]->npkt;
     } else { echo "X"; }
     echo "</td>";
   }
   echo "</tr>\n";
 
   echo "<tr><th>transferred</th>";
   foreach ($n_jobs_list as $n_jobs) {
     echo "<td>";
     if (isset($results["$op"]["$fs->id"]["$n_jobs"])) {
       echo $results["$op"]["$fs->id"]["$n_jobs"]->transferred;
     } else { echo "X"; }
     echo "</td>";
   }
   echo "</tr>\n";
 

  }
  echo "</table>\n";
 }

 $db->close();
?>

</body>
</html>

