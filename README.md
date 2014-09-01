Benchmarking of IP-based Network Storage Systems
=========

Tools used in the project.
Including our custom, ad hoc, microbenchmark, macrobenchmark batch drivers, and other tools.


Tools
-----

 - Generate image files for read tests and create buckets for write tests.
  - `prepare-buckets.sh`

 - Disable TCP offload engines
  - `offload.sh`

 - Sequential access
  - `loop` : 'c' that does open/read/write in a loop.
  - `loop-{dd,c,swift}.sh` : sequential test driver.

 - Parallel access
  - `pthread` : 'c' in which each thread does a give number of open/read/write.
  - `parallel-{dd,c,swift}.sh` : parallel test driver.

  - `worker` : a pool of worker threads handles a given amount of open/read/write together.
  - `worker-c.sh` : driver script for worker.

 - Block-Size (access unit size) test
  - `run-worker-bs.sh`

 - One-File test
  - `run-one-pkt.sh`

 - Metadata test
  - `meta.sh`

 - Batch run
  - `run-*.sh` : batch test driver.
  - `batch.sh` : whole round driver.

 - Configurable options
  - `local.inc.sh` and `iotest.h`

 - Important environment variables
  - Set to non-zero values to activate. All but `DRY` default to inactive.
  - `DRY`: dry run, do no actual read/write.
  - `FSHOT`: filesystem is 'hot', do not warm-up.
  - `RESUME`: resume a previously interrupted test.
  - `CLEANSERVERCACHE`: whether to clean server cache or not.
  - `SERVERAIDEDDELETE`: server side helps when delete.

 - Result parser:
  - `parse-file` : parse results from file I/O tests.
   - For Block-Size and One-File tests, use `-e` option.
   - SQL output: `-s` option. File test add `-f` ; Block-Size and One-File add `-b` option.
  - `parse-meta` : parse results from metadata tests.


Testbed Configuration Notes
-----

 - The user running the test must be able to `ssh` to and `sudo` on each node without typing password.
 - Moreover, he must be able to `sudo` in an `ssh` session without terminal.
  - Disable all `requiretty` entries in `visudo`.


Data Release
-----

Our experimental data is availabe as a MySQL/MariaDB dump in `data/`.



Data Processor and Viewer
-----

PHP scripts in `proc/`.



Plotter
-----

Octave scripts in `plot/`.



Macrobenchmark Drivers
-----

Scripts in `macro/`.
