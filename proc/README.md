Data Processor and Viewer
=====

 - Get statistics from log.
```
grep -e "fs:" -e NET -e CPU -e "00\.00" -e Ser -e Elap -e Thro log.txt
```

 - Replacement templates
```
# general template
sed "s/_SCENE_//; s/_DATE_/2014-07-/; s/iscsi//; s/nfs/1/; s/fuse/5/;"
# cfq
sed "s/_SCENE_//; s/_DATE_/2014-07-0/; s/iscsi/2/; s/nfs/1/; s/fuse/5/;"
# deadline
sed "s/_SCENE_//; s/_DATE_/2014-07-0/; s/iscsi/3/; s/nfs/1/; s/fuse/5/;"
# noop
sed "s/_SCENE_//; s/_DATE_/2014-07-0/; s/iscsi/4/; s/nfs/1/; s/fuse/5/;"
```

 - FileBench - fileserver.f
```
# filebench - fileserver
grep -e Summary -r * | cut -d\, -f -2
insert into macro (elapsed,bench,conf,date,scenario,fs,throughput) value (120,3,3,'2014-07-0',S,F,T);

insert into macro (elapsed,bench,conf,date,scenario,fs,throughput) value
 (120,3,3,'2014-07-0',S,4,T),
 (120,3,3,'2014-07-0',S,1,T),
 (120,3,3,'2014-07-0',S,3,T),
 (120,3,3,'2014-07-0',S,2,T),
 (120,3,3,'2014-07-0',S,5,T);
```

 - PostMark 1.53 typical
```
grep -e "seconds" -r *
insert into macro (bench,conf,date,scenario,fs,elapsed,throughput) value (1,1,'2014-07-0',S,F,E,T);

insert into macro (bench,conf,date,scenario,fs,elapsed,throughput) value
 (1,1,'2014-07-0',S,4,E,T),
 (1,1,'2014-07-0',S,1,E,T),
 (1,1,'2014-07-0',S,3,E,T),
 (1,1,'2014-07-0',S,2,E,T),
 (1,1,'2014-07-0',S,5,E,T);
```

```
noop nfs dead cfq fuse
4 1 3 2 5
```

