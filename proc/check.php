<!DOCTYPE html>
<html>
<head>
<title>check</title>
</head>
<body>
<?php
 require_once('common_head.php');

 show_filter_form('check.php');
?>
<h1>File I/O stats</h1>
<h4>Targets(fs)</h4><br />
<table border="1">
 <tr><th>id</th><th>name</th><th>remark</th><th>count</th><th>max_elapsed</th><th>min_elapsed</th><th>max_throughput</th><th>min_throughput</th></tr>
<?php
 $file_filter_where = $scenario_where.$date_where.$buckted_4k_where;
 $sql = "select target.id as id, target.name as name, target.remark as remark, count(file.id) as count, max(file.elapsed) as max_elapsed, min(file.elapsed) as min_elapsed, max(file.throughput) as max_throughput, min(file.throughput) as min_throughput from file left join target on fs=target.id  where 1 $file_filter_where group by fs";
 $res = $db->query($sql);
 while ($entry = $res->fetch_assoc()) {
  echo "<tr>";
  echo "<td>".$entry['id']."</td><td>".$entry['name']."</td><td>".$entry['remark']."</td><td>".$entry['count']."</td><td>".$entry['max_elapsed']."</td><td>".$entry['min_elapsed']."</td><td>".$entry['max_throughput']."</td><td>".$entry['min_throughput']."</td>";
  echo "</tr>\n";
 }
 $res->close();
?>
</table>

<h4>Scenarios</h4><br />
<table border="1">
 <tr><th>id</th><th>bandwidth</th><th>delay</th><th>loss</th><th>jitter</th><th>cleansrv</th><th>remark</th><th>count</th><th>max_elapsed</th><th>min_elapsed</th><th>max_throughput</th><th>min_throughput</th></tr>
<?php
 $sql = "select scenario.id as id, bandwidth, loss, delay, jitter, clean, scenario.remark as remark, count(file.id) as count, max(file.elapsed) as max_elapsed, min(file.elapsed) as min_elapsed, max(file.throughput) as max_throughput, min(file.throughput) as min_throughput from file left join scenario on file.scenario=scenario.id  where 1 $file_filter_where group by scenario";
 $res = $db->query($sql);
 while ($entry = $res->fetch_assoc()) {
  echo "<tr>";
  echo "<td>".$entry['id']."</td><td>".$entry['bandwidth']."</td><td>".$entry['delay']."</td><td>".$entry['loss']."</td><td>".$entry['jitter']."</td><td>".$entry['clean']."</td><td>".$entry['remark']."</td><td>".$entry['count']."</td><td>".$entry['max_elapsed']."</td><td>".$entry['min_elapsed']."</td><td>".$entry['max_throughput']."</td><td>".$entry['min_throughput']."</td>";
  echo "</tr>\n";
 }
 $res->close();
?>
</table>

<h4>Dates</h4><br />
<table border="1">
 <tr><th>date</th><th>count</th><th>max_elapsed</th><th>min_elapsed</th><th>max_throughput</th><th>min_throughput</th></tr>
<?php
 $sql = "select date, count(file.id) as count, max(file.elapsed) as max_elapsed, min(file.elapsed) as min_elapsed, max(file.throughput) as max_throughput, min(file.throughput) as min_throughput from file where 1 $file_filter_where group by date";
 $res = $db->query($sql);
 while ($entry = $res->fetch_assoc()) {
  echo "<tr>";
  echo "<td>".$entry['date']."</td><td>".$entry['count']."</td><td>".$entry['max_elapsed']."</td><td>".$entry['min_elapsed']."</td><td>".$entry['max_throughput']."</td><td>".$entry['min_throughput']."</td>";
  echo "</tr>\n";
 }
 $res->close();
?>
</table>

<hr />

<h1>Metadata stats</h1>
<h4>Targets(fs)</h4><br />
<table border="1">
 <tr><th>id</th><th>name</th><th>remark</th><th>count</th><th>max_elapsed</th><th>min_elapsed</th><th>max_xfer</th><th>min_xfer</th></tr>
<?php
 $meta_filter_where = $scenario_where.$date_where;
 $sql = "select target.id as id, target.name as name, target.remark as remark, count(metadata.id) as count, max(metadata.elapsed) as max_elapsed, min(metadata.elapsed) as min_elapsed, max(metadata.transferred) as max_xfer, min(metadata.transferred) as min_xfer from metadata left join target on fs=target.id  where 1 $meta_filter_where group by fs";
 $res = $db->query($sql);
 while ($entry = $res->fetch_assoc()) {
  echo "<tr>";
  echo "<td>".$entry['id']."</td><td>".$entry['name']."</td><td>".$entry['remark']."</td><td>".$entry['count']."</td><td>".$entry['max_elapsed']."</td><td>".$entry['min_elapsed']."</td><td>".$entry['max_xfer']."</td><td>".$entry['min_xfer']."</td>";
  echo "</tr>\n";
 }
 $res->close();
?>
</table>

<h4>Scenarios</h4><br />
<table border="1">
 <tr><th>id</th><th>bandwidth</th><th>delay</th><th>loss</th><th>jitter</th><th>cleansrv</th><th>remark</th><th>count</th><th>max_elapsed</th><th>min_elapsed</th><th>max_xfer</th><th>min_xfer</th></tr>
<?php
 $sql = "select scenario.id as id, bandwidth, loss, delay, jitter, clean, scenario.remark as remark, count(metadata.id) as count, max(metadata.elapsed) as max_elapsed, min(metadata.elapsed) as min_elapsed, max(metadata.transferred) as max_xfer, min(metadata.transferred) as min_xfer from metadata left join scenario on metadata.scenario=scenario.id where 1 $meta_filter_where group by scenario";
 $res = $db->query($sql);
 while ($entry = $res->fetch_assoc()) {
  echo "<tr>";
  echo "<td>".$entry['id']."</td><td>".$entry['bandwidth']."</td><td>".$entry['delay']."</td><td>".$entry['loss']."</td><td>".$entry['jitter']."</td><td>".$entry['clean']."</td><td>".$entry['remark']."</td><td>".$entry['count']."</td><td>".$entry['max_elapsed']."</td><td>".$entry['min_elapsed']."</td><td>".$entry['max_xfer']."</td><td>".$entry['min_xfer']."</td>";
  echo "</tr>\n";
 }
 $res->close();
?>
</table>

<h4>Dates</h4><br />
<table border="1">
 <tr><th>date</th><th>count</th><th>max_elapsed</th><th>min_elapsed</th><th>max_xfer</th><th>min_xfer</th></tr>
<?php
 $sql = "select date, count(metadata.id) as count, max(metadata.elapsed) as max_elapsed, min(metadata.elapsed) as min_elapsed, max(metadata.transferred) as max_xfer, min(metadata.transferred) as min_xfer from metadata where 1 $meta_filter_where group by date";
 $res = $db->query($sql);
 while ($entry = $res->fetch_assoc()) {
  echo "<tr>";
  echo "<td>".$entry['date']."</td><td>".$entry['count']."</td><td>".$entry['max_elapsed']."</td><td>".$entry['min_elapsed']."</td><td>".$entry['max_xfer']."</td><td>".$entry['min_xfer']."</td>";
  echo "</tr>\n";
 }
 $res->close();
?>
</table>

<hr />

<h1>Block-Size stats</h1>
<h4>Targets(fs)</h4><br />
<table border="1">
 <tr><th>id</th><th>name</th><th>remark</th><th>count</th><th>max_elapsed</th><th>min_elapsed</th><th>max_throughput</th><th>min_throughput</th></tr>
<?php
 $bs_filter_where = $scenario_where.$date_where.$bs_op_where;
 $sql = "select target.id as id, target.name as name, target.remark as remark, count(blocksize.id) as count, max(blocksize.elapsed) as max_elapsed, min(blocksize.elapsed) as min_elapsed, max(blocksize.throughput) as max_throughput, min(blocksize.throughput) as min_throughput from blocksize left join target on fs=target.id  where 1 $bs_filter_where group by fs";
 $res = $db->query($sql);
 while ($entry = $res->fetch_assoc()) {
  echo "<tr>";
  echo "<td>".$entry['id']."</td><td>".$entry['name']."</td><td>".$entry['remark']."</td><td>".$entry['count']."</td><td>".$entry['max_elapsed']."</td><td>".$entry['min_elapsed']."</td><td>".$entry['max_throughput']."</td><td>".$entry['min_throughput']."</td>";
  echo "</tr>\n";
 }
 $res->close();
?>
</table>

<h4>Scenarios</h4><br />
<table border="1">
 <tr><th>id</th><th>bandwidth</th><th>delay</th><th>loss</th><th>jitter</th><th>cleansrv</th><th>remark</th><th>count</th><th>max_elapsed</th><th>min_elapsed</th><th>max_throughput</th><th>min_throughput</th></tr>
<?php
 $sql = "select scenario.id as id, bandwidth, loss, delay, jitter, clean, scenario.remark as remark, count(blocksize.id) as count, max(blocksize.elapsed) as max_elapsed, min(blocksize.elapsed) as min_elapsed, max(blocksize.throughput) as max_throughput, min(blocksize.throughput) as min_throughput from blocksize left join scenario on blocksize.scenario=scenario.id where 1 $bs_filter_where group by scenario";
 $res = $db->query($sql);
 while ($entry = $res->fetch_assoc()) {
  echo "<tr>";
  echo "<td>".$entry['id']."</td><td>".$entry['bandwidth']."</td><td>".$entry['delay']."</td><td>".$entry['loss']."</td><td>".$entry['jitter']."</td><td>".$entry['clean']."</td><td>".$entry['remark']."</td><td>".$entry['count']."</td><td>".$entry['max_elapsed']."</td><td>".$entry['min_elapsed']."</td><td>".$entry['max_throughput']."</td><td>".$entry['min_throughput']."</td>";
  echo "</tr>\n";
 }
 $res->close();
?>
</table>

<h4>Dates</h4><br />
<table border="1">
 <tr><th>date</th><th>count</th><th>max_elapsed</th><th>min_elapsed</th><th>max_throughput</th><th>min_throughput</th></tr>
<?php
 $sql = "select date, count(blocksize.id) as count, max(blocksize.elapsed) as max_elapsed, min(blocksize.elapsed) as min_elapsed, max(blocksize.throughput) as max_throughput, min(blocksize.throughput) as min_throughput from blocksize where 1 $bs_filter_where group by date";
 $res = $db->query($sql);
 while ($entry = $res->fetch_assoc()) {
  echo "<tr>";
  echo "<td>".$entry['date']."</td><td>".$entry['count']."</td><td>".$entry['max_elapsed']."</td><td>".$entry['min_elapsed']."</td><td>".$entry['max_throughput']."</td><td>".$entry['min_throughput']."</td>";
  echo "</tr>\n";
 }
 $res->close();
?>
</table>



<?php
 $db->close();
?>
</body>
</html>

