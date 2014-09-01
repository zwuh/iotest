<?php
 $db = new mysqli("localhost", "iotest", "iotest", "iotest");
 if ($db->connect_errno) {
  echo "Connect Failed, errno:".$db->connect_errno;
  exit;
 }
 $db->set_charset('utf8');

 $scenario = -1;
 $scenario_where = "";
 if (isset($_REQUEST['scenario']) && "" != trim($_REQUEST['scenario'])) {
  $scenario = intval($_REQUEST['scenario']);
  $scenario_where = " and scenario=$scenario ";
 }

 function set_default_scenario_if_not_set()
 {
  global $scenario;
  global $scenario_where;

  if ("" == $scenario_where) {
   $scenario = 1;
   $scenario_where = " and scenario=$scenario";
  }
 }

 $date_where = "";
 $start_date = "";
 $end_date = "";

 if (isset($_REQUEST['start_date']) && "" != trim($_REQUEST['start_date'])) {
   $start_date = $db->real_escape_string($_REQUEST['start_date']);
   $date_where .= " and date >= '$start_date' ";
 }
 if (isset($_REQUEST['end_date']) && "" != trim($_REQUEST['end_date'])) {
   $end_date = $db->real_escape_string($_REQUEST['end_date']);
   $date_where .= " and date <= '$end_date' ";
 }

 $show_standard_deviation = false;
 if (isset($_REQUEST['show_stddev'])) {
   $show_standard_deviation = true;
 }

 $show_one_file = false;
 $bs_op_where = " and job_size=16777216 and n_threads=1 ";
 if (isset($_REQUEST['show_one_file'])) {
   $show_one_file = true;
   $bs_op_where = " and block_size=job_size and n_threads=1 ";
 }

 $show_only_bucketed_4k = true;
 $bucketed_4k_where = " and (job_size <> 4096 or (date >='2014-05-28')) ";
 if (isset($_REQUEST['show_non_bucketed_4k']) || strcmp($date_where,"")) {
   echo "<h4>INFO: Showing non-bucketed 4K results (explicitly or overriden by dates)</h4>\n";
   $show_only_bucketed_4k = false;
   $bucketed_4k_where = "";
 }

 $show_elapsed = false;
 if (isset($_REQUEST['show_elapsed'])) {
   $show_elapsed = true;
 }

 class scenario_entry {
  var $id;
  var $delay;
  var $bandwidth;
  var $loss;
  var $jitter;
  var $clean;
  var $remark;
 }

 // Get a list of available scenarios in database.
 $scenario_list = array();
 $res = $db->query("select * from scenario");
 while ($entry = $res->fetch_assoc()) {
  //echo "id:".$entry['id']." delay:".$entry['delay']." bw:".$entry['bandwidth'];
  //echo " loss:".$entry['loss']." remark:".$entry['remark']."<br />\n";
  $r_ent = new scenario_entry();
  $r_ent->id = $entry['id'];
  $r_ent->delay = $entry['delay'];
  $r_ent->bandwidth = $entry['bandwidth'];
  $r_ent->loss = $entry['loss'];
  $r_ent->jitter = $entry['jitter'];
  $r_ent->clean = $entry['clean'];
  $r_ent->remark = $entry['remark'];
  $scenario_list[$entry['id']] = $r_ent;
}
 $res->close();
 class fs_entry {
  var $id;
  var $name;
  var $remark;
 }

 // Get a list of targets available in database.
 $available_fs = array();
 $res = $db->query("select * from target");
 while ($entry = $res->fetch_assoc()) {
   $r_ent = new fs_entry();
   $r_ent->id = $entry['id'];
   $r_ent->name = $entry['name'];
   $r_ent->remark = $entry['remark'];
   $available_fs[$entry['id']] = $r_ent;
 }
 $res->close();

 function show_fs_list_in_table($fs_list)
 {
   global $available_fs;

   echo "Available target(fs):<br />\n";
   echo "<table border=\"1\">\n";
   echo "<tr><th>Id</th><th>name</th><th>remark</th></tr>\n";
   foreach ($available_fs as $fs) {
     echo "<tr><td>".$fs->id."</td><td>".$fs->name."</td><td>".$fs->remark."</td></tr>\n";
   }
   echo "</table>\n";
 }

 function show_filter_form($action)
 {
   global $scenario_list;
   global $scenario;
   global $start_date;
   global $end_date;

   echo "<form name=\"filter\" action=\"$action\" method=\"get\">\n";

   echo "Available scenarios:<select name=\"scenario\">\n";
   echo "<option value=\"\"></option>\n";
   foreach ($scenario_list as $s) {
     echo "<option value=\"".$s->id."\"";
     if ($s->id == $scenario) { echo " selected"; }
     echo ">".$s->id.": delay:".$s->delay." bw:".$s->bandwidth;
     echo " loss:".$s->loss." jitter:".$s->jitter." cleansrv:".$s->clean." ".$s->remark."</option>\n";
   }
   echo "</select><br />\n";

   echo "Start Date:<input type=\"text\" name=\"start_date\" ";
   if ("" != $start_date) { echo "value=\"$start_date\""; }
   echo " length=\"10\" /><br />\n";
   echo "End Date:<input type=\"text\" name=\"end_date\" ";
   if ("" != $end_date) { echo "value=\"$end_date\""; }
   echo " length=\"10\" /><br />\n";
   echo "Show standard deviation instead: <input type=\"checkbox\" name=\"show_stddev\" /><br />\n";
   echo "Show elapsed time instead: <input type=\"checkbox\" name=\"show_elapsed\" /><br />\n";
   echo "Include non-bucketed 4K results (date < 2014-05-28): <input type=\"checkbox\" name=\"show_non_bucketed_4k\" /><br />\n";
   echo "bs: Switch to One-File mode: <input type=\"checkbox\" name=\"show_one_file\" /><br />\n";
   echo "<input type=\"submit\" value=\"show\" />\n";
   echo "<input type=\"reset\" value=\"reset\" />\n";
   echo "</form>";
 }

 function show_scenario_heading($sid, $test_name = '')
 {
   global $scenario_list;
   echo "<h2>$test_name Scenario #$sid bw:".$scenario_list["$sid"]->bandwidth.
    " delay:".$scenario_list["$sid"]->delay." jitter:".$scenario_list["$sid"]->jitter.
    " loss:".$scenario_list["$sid"]->loss." cleansrv:".$scenario_list["$sid"]->clean.
    " - ".$scenario_list["$sid"]->remark."</h2>\n";
 }
?>

