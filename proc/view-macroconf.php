<!DOCTYPE html>
<html>
<head>
<title>macrobenchmark configuration</title>
</head>
<body>
<?php
 require_once('common_head.php');

 $conf_id = -1;
 if (isset($_REQUEST['conf'])) {
  $conf_id = intval($_REQUEST['conf']);
 }

 $sql = "select macroconf.id as id, macroconf.bench as bench, macrobench.name as name, macroconf.remark as remark, macroconf.conf as conf ".
        "from macroconf left join macrobench on macrobench.id=macroconf.bench ".
        "where macroconf.id = $conf_id limit 1";
 $res = $db->query($sql);
 $conf = null;
 if (FALSE !== $res) {
  $conf = $res->fetch_assoc();
  $res->close();
 }
?>
<pre>
<?php
 if ($conf == null) {
  echo "# No such configuration, invalid configuration identifier.\n";
 } else {
  echo "# id: ".$conf['id']."\n";
  echo "# bench: ".$conf['bench']." : ".$conf['name']."\n";
  echo "# remark: ".$conf['remark']."\n\n";
  echo $conf['conf']."\n";
 }
?>
</pre>
<?php
 $db->close();
?>
</body>
</html>

