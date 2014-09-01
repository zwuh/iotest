#define _GNU_SOURCE /* O_DIRECT */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <pthread.h>
#include <signal.h>

#include "iotest.h"

pthread_mutex_t mutex;
pthread_t threads[MAX_THREADS];
struct timespec start_ts[MAX_THREADS];
struct timespec end_ts[MAX_THREADS];
struct timespec elapsed_thread[MAX_THREADS];
int request_serviced[MAX_THREADS];
int status[MAX_THREADS];

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
int duration = DEFAULT_DURATION;

int open_ext_flags = 0;
int alarm_fired = FALSE;
timer_t timer;


static void handler(int sig, siginfo_t *si, void *uc)
{
  (void)(si); /* circumvent -Wunused-parameter */
  (void)(uc);
  alarm_fired = TRUE;
  signal(sig, SIG_IGN);
}

static int setup_alarm()
{
  struct sigaction sa;
  struct itimerspec its;

  if (0 == duration) {
    return 0;
  }

  sa.sa_flags = SA_SIGINFO;
  sa.sa_sigaction = handler;
  sigemptyset(&sa.sa_mask);
  if (-1 == sigaction(SIGALRM, &sa, NULL)) {
    return 1;
  }

  if (-1 == timer_create(CLOCK_REALTIME, NULL, &timer)) {
    return 1;
  }

  memset(&its, 0, sizeof(struct itimerspec));
  its.it_value.tv_sec = duration;
  its.it_value.tv_nsec = 0;

  if (-1 == timer_settime(timer, 0, &its, NULL)) {
    return 1;
  }

  return 0;
}

static int check_goal_status(long thread_id)
{
 if (TRUE == alarm_fired && request_serviced[thread_id] > 0) {
   /* printf("check_goal_staus: true\n"); */
   return TRUE;
 }
 return FALSE;
}

static void *worker(void *arg)
{
  long tid = (long)arg;
  int fd;
  int job_id = -1;
  char name[32];
  struct timespec tmp, begin, end;
  int rval;
  int err;
  int file_jobsn;

  /*printf("Hello, thread #%ld\n", tid);*/

  status[tid] = STATUS_SUCCESS;

  while (1) {
    if (TRUE == check_goal_status(tid)) {
      break;
    }

    pthread_mutex_lock(&mutex);
    job_id = next_job;
    if (next_job < n_jobs) {
      next_job = next_job + 1;
    }
    pthread_mutex_unlock(&mutex);
    if (job_id >= n_jobs) {
      break;
    }

    /*printf("Thread #%ld processing job #%d\n", tid, job_id);*/

    file_jobsn = job_id + base_jobsn;
    bucket_path(name, n_jobs, file_jobsn);
    fd = open_file(name, open_ext_flags, rw);
    if (fd == -1) {
      continue;
    }

    clock_gettime(CLOCK_REALTIME, &begin);
    if (request_serviced[tid] == 0) {
      clock_gettime(CLOCK_REALTIME, &start_ts[tid]);
    }
    if (rw == RW_WRITE) {
     rval = write_file(fd, name, block, block_size, job_size/block_size);
    } else {
     rval = read_file(fd, name, block, block_size, job_size/block_size);
    }
    if (close(fd) != 0) {
     err = errno;
     fprintf(stderr, "ERR close(%s): %s\n", name, strerror(err));
    }
    clock_gettime(CLOCK_REALTIME, &end);
    time_diff(&tmp, &begin, &end);
    time_add(&elapsed_thread[tid], &elapsed_thread[tid], &tmp);
    request_serviced[tid]++;
    status[tid] |= rval;

    if (rval != STATUS_SUCCESS) {
      switch (rval) {
        case STATUS_ERROR:
          fprintf(stderr, "ERR: %s I/O error\n", name);
          break;
        case STATUS_WRONG_SIZE:
          fprintf(stderr, "ERR: %s wrong size\n", name);
          break;
        case STATUS_HAS_RETRY:
          fprintf(stderr, "ERR: %s has retries\n", name);
          break;
      }
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

  while ((opt = getopt(argc, argv, "n:t:b:s:j:k:u:dcrwq")) != -1) {
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
      case 'b':
        block_size = atoi(optarg);
        break;
      case 'j':
        job_size = atoi(optarg);
        break;
      case 's':
        n_jobs = atoi(optarg);
        break;
      case 'k':
        base_jobsn = atoi(optarg);
        break;
      case 'u':
        duration = atoi(optarg);
        break;
      case 'd':
        open_ext_flags |= O_DIRECT;
        break;
      case 'c':
        open_ext_flags |= O_SYNC;
        break;
      case 'r':
        if (rw == RW_UNSET) {
          rw = RW_READ;
        }
        break;
      case 'w':
        rw = RW_WRITE;
        break;
      case 'q':
        quiet = 1;
        break;
      default:
        printf("Usage: %s [-r|-w] [-n n_threads] [-t target_dir]\n", argv[0]);
        printf("          [-b block_size] [-j job_size] [-s num_jobs]\n");
        printf("          [-k base_jobsn] [-u duration]\n");
        printf("          [-d] O_DIRECT [-c] O_SYNC [-q]uiet [-f]use_hack\n");
        exit(EXIT_FAILURE);
        break;
    }
  }
  if (rw == RW_UNSET) { rw = RW_WRITE; }

  if (job_size % block_size != 0) {
    printf("Error: job_size must be a multiple of block_size!\n");
    exit(EXIT_FAILURE);
  }
}

void print_config(void)
{
  if (quiet != 0) return;
  printf("Configuration:\n");
  printf(" number of workers: %d\n", n_threads);
  printf(" block_size: %d\n", block_size);
  printf(" job size: %d\n", job_size);
  printf(" number of jobs: %d\n", n_jobs);
  printf(" base job number: %d\n", base_jobsn);
  printf(" duration: %d sec\n", duration);
  printf(" target: %s\n", target_dir);
  printf(" ext_flags to open: ");
  if (open_ext_flags & O_DIRECT) printf(" O_DIRECT");
  if (open_ext_flags & O_SYNC) printf(" O_SYNC");
  printf("\n");
  printf(" read/write: ");
  if (rw == RW_READ) printf("read\n");
  else printf("write\n");
}

int main(int argc, char *argv[])
{
  int rc;
  long t;
  void *blk_mem;
  struct timespec start, end, diff;
  int index_first_start, index_last_end;
  int overall_status;
  int total_serviced;

  memset(target_dir, 0, PATH_LENGTH);
  /* default target dir */
  snprintf(target_dir, PATH_LENGTH-1, DEFAULT_TARGET);

  process_arg(argc, argv);
  print_config();

  if (chdir(target_dir)) {
    perror("Unable to chdir() to target_dir");
    goto exit_failure;
  }

  if (pthread_mutex_init(&mutex, NULL)) {
    perror("Error setting up mutex");
    goto exit_failure;
  }

  if ((blk_mem = malloc(block_size*2-1)) == NULL) {
    perror("Unable to allocate write buffer");
    goto exit_failure;
  }
  memset(blk_mem, FILL_BYTE, block_size*2-1);
  block = ptr_align(blk_mem, block_size);

  next_job = 0;
  memset(elapsed_thread, 0, sizeof(struct timespec)*n_threads);
  memset(request_serviced, 0, sizeof(int)*n_threads);

  if (setup_alarm()) {
    perror("Error setting alarm clock");
    goto exit_failure;
  }

  clock_gettime(CLOCK_REALTIME, &start);

  for (t = 0;t < n_threads;t ++) {
    /*printf("Creating thread #%ld\n", t);*/
    rc = pthread_create(&threads[t], NULL, worker, (void *)t);
    if (rc) {
      perror("Error creating thread");
      goto exit_failure;
    }
  }

  index_first_start = index_last_end = 0;
  overall_status = STATUS_SUCCESS;

  for (t = 0; t < n_threads;t ++) {
    pthread_join(threads[t], NULL);
    overall_status |= status[t];
    if (time_cmp(&start_ts[index_first_start], &start_ts[t]) == 1) {
      index_first_start = t;
    }
    if (time_cmp(&end_ts[t], &end_ts[index_last_end]) == 1) {
      index_last_end = t;
    }
  }

  clock_gettime(CLOCK_REALTIME, &end);

  pthread_mutex_destroy(&mutex);

  free(blk_mem);

  /*printf("Syncing ...\n");
  sync();*/

#ifdef TIMELINE
  printf("Overall start:  "); print_time(&start);
  for (t = 0;t < n_threads;t ++)
  {
   printf("Thread #%ld: end: ", t); print_time(&end_ts[t]);
  }
  printf("Overall   end:  "); print_time(&end);
#endif

  total_serviced = 0;
  /* per-thread statistics */
  for (t = 0;t < n_threads;t ++) {
    printf("%d ", request_serviced[t]);
    total_serviced += request_serviced[t];
    print_time(&elapsed_thread[t]);
  }

  /* total serviced jobs */
  printf("%d\n", total_serviced);  
  /* "internal" time */
  time_diff(&diff, &start_ts[index_first_start], &end_ts[index_last_end]);
  print_time(&diff);
  /* start-to-end time */
  time_diff(&diff, &start, &end);
  print_time(&diff);

  exit(EXIT_SUCCESS);
exit_failure:
  exit(EXIT_FAILURE);
}

