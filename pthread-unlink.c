#define _GNU_SOURCE /* O_DIRECT */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <errno.h>
#include <unistd.h>
#include <pthread.h>

#include "iotest.h"

#define TIMELINE

pthread_mutex_t mutex;
pthread_t threads[MAX_THREADS];
struct timespec start_ts[MAX_THREADS];
struct timespec end_ts[MAX_THREADS];
int request_serviced[MAX_THREADS];

int n_threads  = DEFAULT_N_THREADS;
int job_size   = DEFAULT_JOB_SIZE;
int n_jobs     = (DEFAULT_N_THREADS*DEFAULT_JOBS_PER_THREAD);
int block_size = DEFAULT_BLOCK_SIZE;
char target_dir[PATH_LENGTH];
char *block;
int rw = RW_UNSET;
int quiet = 0;
int next_job = 0;
int base_jobsn = DEFAULT_BASE_JOBSN;

int open_ext_flags = 0;


void *worker(void *arg)
{
  long tid = (long)arg;
  int job_id = -1;
  char name[32];
  int rval;
  int err;
  int file_jobsn;

  /*printf("Hello, thread #%ld\n", tid);*/

  while (1) {
    pthread_mutex_lock(&mutex);
    job_id = next_job;
    if (next_job < n_jobs) {
      next_job = next_job + 1;
    }
    pthread_mutex_unlock(&mutex);
    if (job_id >= n_jobs) {
      break;
    }

    if (request_serviced[tid] == 0) {
      clock_gettime(CLOCK_REALTIME, &start_ts[tid]);
    }

    /*printf("Thread #%ld processing job #%d\n", tid, job_id);*/

    file_jobsn = job_id + base_jobsn;
    bucket_path(name, n_jobs, file_jobsn);
    rval = unlink(name);

    if (0 != rval) {
     err = errno;
     if (err != ENOENT) {
       fprintf(stderr, "ERR unlink(%s): %s\n", name, strerror(err));
     }
    } else {
     request_serviced[tid]++;
    }
  }

  clock_gettime(CLOCK_REALTIME, &end_ts[tid]);
  /* Set start to end if we served no request, so elapsed will be 0 */
  if (request_serviced[tid] == 0) {
    memcpy(&start_ts[tid], &end_ts[tid], sizeof(struct timespec));
  }

  /*printf("Bye, thread #%ld\n", tid);*/

  pthread_exit(NULL);
}

void process_arg(int argc, char *argv[])
{
  int opt;

  while ((opt = getopt(argc, argv, "n:t:s:k:q")) != -1) {
    switch (opt) {
      case 'n':
        n_threads = atoi(optarg);
        if (n_threads < 0 || n_threads > MAX_THREADS) {
          printf("Too many threads.\n");
          exit(EXIT_FAILURE);
        }
        break;
      case 't':
        strncpy(target_dir, optarg, PATH_LENGTH-1);
        break;
      case 's':
        n_jobs = atoi(optarg);
        break;
      case 'k':
        base_jobsn = atoi(optarg);
        break;
      case 'q':
        quiet = 1;
        break;
      default:
        printf("Usage: %s [-t target_dir] [-s num_jobs] [-k base_jobsn] [-q]uiet [-f]use_hack\n", argv[0]);
        exit(EXIT_FAILURE);
        break;
    }
  }
}

void print_config(void)
{
  if (quiet != 0) return;
  printf("Configuration:\n");
  printf(" number of workers: %d\n", n_threads);
  printf(" number of jobs: %d\n", n_jobs);
  printf(" base job number: %d\n", base_jobsn);
  printf(" target: %s\n", target_dir);
}

int main(int argc, char *argv[])
{
  int rc;
  long t;
  struct timespec start, end, diff;
  int total_serviced;

  memset(target_dir, 0, PATH_LENGTH);
  /* default target dir */
  snprintf(target_dir, PATH_LENGTH-1, DEFAULT_TARGET);

  process_arg(argc, argv);
  print_config();

  if (chdir(target_dir)) {
    perror("ERR Unable to chdir() to target_dir");
    exit(EXIT_FAILURE);
  }

  if (pthread_mutex_init(&mutex, NULL)) {
    perror("ERR Error setting up mutex");
    exit(EXIT_FAILURE);
  }

  next_job = 0;
  memset(request_serviced, 0, sizeof(int)*n_threads);

  clock_gettime(CLOCK_REALTIME, &start);

  for (t = 0;t < n_threads;t ++) {
    /*printf("Creating thread #%ld\n", t);*/
    rc = pthread_create(&threads[t], NULL, worker, (void *)t);
    if (rc) {
      perror("ERR Error creating thread");
      exit(EXIT_FAILURE);
    }
  }

  for (t = 0; t < n_threads;t ++) {
    pthread_join(threads[t], NULL);
  }

  clock_gettime(CLOCK_REALTIME, &end);

  pthread_mutex_destroy(&mutex);

  /*printf("Syncing ...\n");
  sync();*/

  if (0 == quiet) {
   printf("Overall start:  "); print_time(&start);
   printf("Overall   end:  "); print_time(&end);
  }

  total_serviced = 0;
  for (t = 0;t < n_threads;t ++) {
    total_serviced += request_serviced[t];
    if (0 == quiet) {
      /* per-thread statistics */
      time_diff(&diff, &start_ts[t], &end_ts[t]);
      printf("#%ld %d ", t, request_serviced[t]);
      print_time(&diff);
    }
  }

  printf("INFO punlink S/n:%d/%d T:%s E:", total_serviced, n_jobs, target_dir);
  print_time(&diff);

  exit(EXIT_SUCCESS);
}

