<!DOCTYPE html>
<html>
<head>
<title>Block-Size</title>
<link rel="stylesheet"  type="text/css"  href="style.css" media="screen" />
</head>
<body>

<?php
 require_once('common_head.php');

 set_default_scenario_if_not_set();
 show_filter_form('view-bs.php');
 show_fs_list_in_table($available_fs);

 if (true == $show_one_file) {
  // One-File mode
  show_scenario_heading($scenario, "One-File");
   echo "<h2>One-File mode n_threads:1</h2>";
 } else {
  // job_size fixed at 16777216, n_threads at 1
  show_scenario_heading($scenario, "Block-Size");
  echo "<h2>Block-Size job_size: 16777216 n_threads: 1</h2>";
 }
 $filter_where = $scenario_where.$date_where.$bs_op_where;

/*
 $res = $db->query("select distinct job_size from blocksize where job_size <> 16777216");
 if ($res->num_rows != 0) {
  echo "Error: job_size check failed.";
  exit;
 }
 $res->close();
 $res = $db->query("select distinct n_threads from blocksize where n_threads <> 1");
 if ($res->num_rows != 0) {
  echo "Error: n_threads check failed.";
  exit;
 }
 $res->close();
*/

 // Get a list of block_size's
 $block_size_list = array();
 $res = $db->query("select distinct block_size from blocksize where 1 $filter_where order by block_size asc");
 while ($entry = $res->fetch_assoc()) {
  //echo "block size: ".$entry['block_size']."\n";
  $block_size_list[] = $entry['block_size'];
 }
 $n_diff_block_size = $res->num_rows;
 $res->close();
 // Get a list of flag's
 $flag_list = array();
 $res = $db->query("select distinct flag from blocksize where 1 $filter_where order by flag asc");
 while ($entry = $res->fetch_assoc()) {
  //echo "flag: ".$entry['flag']."\n";
  $flag_list[] = $entry['flag'];
 }
 $res->close();

 class result_entry {
  var $throughput;
  var $xfer;
  var $npkt;
 }

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
   $sql = "select fs, flag, block_size, rw, round(stddev($thp_field),3) as thp, round(stddev(transferred),2) as xfer, ceil(stddev(npkt)) as npkt from blocksize ";
 } else {
   $sql = "select fs, flag, block_size, rw, round(avg($thp_field),3) as thp, ceil(avg(transferred)) as xfer, ceil(avg(npkt)) as npkt from blocksize ";
 }
 $sql .= " where 1 $filter_where ".
       " group by fs, flag, rw, block_size ".
       " order by fs asc, flag asc, rw asc, block_size asc";
 $res = $db->query($sql);
 echo "SQL: ".$sql."<br />\n";
 echo "Number of rows: ".$res->num_rows."<br />\n";

 while ($entry = $res->fetch_assoc()) {
  $r_ent = new result_entry();
  $r_ent->throughput = $entry['thp'];
  $r_ent->xfer = $entry['xfer'];
  $r_ent->npkt = $entry['npkt'];
  $results[$entry['fs']][$entry['flag']][$entry['rw']][$entry['block_size']] = $r_ent;
 }
 $res->close();
 //print_r($results);
 //exit;
 
 foreach ($available_fs as $fs) {
  if (!isset($results["$fs->id"]) ||
      0 == count($results["$fs->id"])) {
     continue;
  }
  echo "<table border=\"1\">\n";
  echo "<tr><th class=\"target\">".$fs->name."</th><th colspan='".$n_diff_block_size."'>Write</th><th colspan='".$n_diff_block_size."'>Read</th></tr>\n";
  echo "<tr><th>block_size</th>";
  foreach ($block_size_list as $block_size) {
   echo "<th>".$block_size."</th>";
  }
  foreach ($block_size_list as $block_size) {
   echo "<th>".$block_size."</th>";
  }
  echo "</tr>\n";
 
  foreach ($flag_list as $flag) {
   if (!isset($results["$fs->id"]["$flag"])) {
     continue;
   }
   echo "<tr class=\"throughput\"><th>[".$flag."] thp</th>";
   foreach ($block_size_list as $block_size) {
     echo "<td>";
     if (isset($results["$fs->id"]["$flag"]["w"]["$block_size"])) {
      echo $results["$fs->id"]["$flag"]["w"]["$block_size"]->throughput;
     } else { echo "X"; }
     echo "</td>";
   }
   foreach ($block_size_list as $block_size) {
     echo "<td>";
     if (isset($results["$fs->id"]["$flag"]["r"]["$block_size"])) {
      echo $results["$fs->id"]["$flag"]["r"]["$block_size"]->throughput;
     } else { echo "X"; }
     echo "</td>";
   }
   echo "</tr>\n";

   echo "<tr class=\"npkt\"><th>npkt</th>";
   foreach ($block_size_list as $block_size) {
     echo "<td>";
     if (isset($results["$fs->id"]["$flag"]["w"]["$block_size"])) {
      echo $results["$fs->id"]["$flag"]["w"]["$block_size"]->npkt;
     } else { echo "X"; }
     echo "</td>";
   }
   foreach ($block_size_list as $block_size) {
     echo "<td>";
     if (isset($results["$fs->id"]["$flag"]["r"]["$block_size"])) {
      echo $results["$fs->id"]["$flag"]["r"]["$block_size"]->npkt;
     } else { echo "X"; }
     echo "</td>";
   }
   echo "</tr>\n";


   echo "<tr class=\"line_xfer\"><th>transferred</th>";
   foreach ($block_size_list as $block_size) {
     echo "<td>";
     if (isset($results["$fs->id"]["$flag"]["w"]["$block_size"])) {
      echo $results["$fs->id"]["$flag"]["w"]["$block_size"]->xfer;
     } else { echo "X"; }
     echo "</td>";
   }
   foreach ($block_size_list as $block_size) {
     echo "<td>";
     if (isset($results["$fs->id"]["$flag"]["r"]["$block_size"])) {
      echo $results["$fs->id"]["$flag"]["r"]["$block_size"]->xfer;
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

