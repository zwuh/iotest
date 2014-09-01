#define _GNU_SOURCE /* O_DIRECT */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <pthread.h>

#include "iotest.h"

pthread_barrier_t barrier;
pthread_t threads[MAX_THREADS];
struct timespec start_ts[MAX_THREADS];
struct timespec end_ts[MAX_THREADS];

int n_threads  = DEFAULT_N_THREADS;
int block_size = DEFAULT_BLOCK_SIZE;
int n_blocks   = DEFAULT_N_BLOCKS;
char target_dir[PATH_LENGTH];
char *block;
int rw = RW_UNSET;
int quiet = 0;

int open_ext_flags = 0;

void *worker(void *arg)
{
  long tid = (long)arg;
  int fd;
  char name[32];
  int err;

  sprintf(name, "%ld" DEFAULT_BINEXT, tid);
  fd = open_file(name, open_ext_flags, rw);
  if (fd == -1) {
    pthread_exit(NULL);
  }
  /*printf("Hello, thread #%ld\n", tid);*/
  /*pthread_barrier_wait(&barrier);*/
  /*printf("Forward, thread #%ld\n", tid);*/
  clock_gettime(CLOCK_REALTIME, &start_ts[tid]);
  if (rw == RW_WRITE) {
   write_file(fd, name, block, block_size, n_blocks);
  } else {
   read_file(fd, name, block, block_size, n_blocks);
  }
  if (close(fd) != 0) {
   err = errno;
   fprintf(stderr, "ERR close(%s): %s\n", name, strerror(err));
  }
  clock_gettime(CLOCK_REALTIME, &end_ts[tid]);
  print_time(&start_ts[tid]);
  print_time(&end_ts[tid]);
  /*printf("Bye, thread #%ld\n", tid);*/
  pthread_exit(NULL);
}

void process_arg(int argc, char *argv[])
{
  int opt;

  while ((opt = getopt(argc, argv, "n:t:b:s:dcrwq")) != -1) {
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
      case 's':
        n_blocks = atoi(optarg);
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
        printf("          [-b block_size] [-s num_blocks]\n");
        printf("          [-d] O_DIRECT [-c] O_SYNC [-q]uiet\n");
        exit(EXIT_FAILURE);
        break;
    }
  }
  if (rw == RW_UNSET) { rw = RW_WRITE; }
}

void print_config(void)
{
  if (quiet != 0) return;
  printf("Configuration:\n");
  printf(" number of threads: %d\n", n_threads);
  printf(" block size: %d\n", block_size);
  printf(" number of blocks: %d\n", n_blocks);
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

  memset(target_dir, 0, PATH_LENGTH);
  /* default target dir */
  snprintf(target_dir, PATH_LENGTH-1, DEFAULT_TARGET);

  process_arg(argc, argv);
  print_config();

  if (chdir(target_dir)) {
    perror("Unable to chdir() to target_dir");
    exit(EXIT_FAILURE);
  }

  if (pthread_barrier_init(&barrier, NULL, n_threads)) {
    perror("Error setting up barrier");
    exit(EXIT_FAILURE);
  }

  if ((blk_mem = malloc(block_size*2-1)) == NULL) {
    perror("Unable to allocate write buffer");
    exit(EXIT_FAILURE);
  }
  memset(blk_mem, FILL_BYTE, block_size*2-1);
  block = ptr_align(blk_mem, block_size);

  clock_gettime(CLOCK_REALTIME, &start);

  for (t = 0;t < n_threads;t ++) {
    /*printf("Creating thread #%ld\n", t);*/
    rc = pthread_create(&threads[t], NULL, worker, (void *)t);
    if (rc) {
      perror("Error creating thread");
      exit(EXIT_FAILURE);
    }
  }

  index_first_start = index_last_end = 0;
  for (t = 0; t < n_threads;t ++) {
    pthread_join(threads[t], NULL);
    if (time_cmp(&start_ts[index_first_start], &start_ts[t]) == 1) {
      index_first_start = t;
    }
    if (time_cmp(&end_ts[t], &end_ts[index_last_end]) == 1) {
      index_last_end = t;
    }
  }

  clock_gettime(CLOCK_REALTIME, &end);

  pthread_barrier_destroy(&barrier);

  free(blk_mem);

  /*printf("Syncing ...\n");
  sync();*/

  /* "internal" time */
  /*
  printf("first_start: %d  last_end:%d\n", index_first_start, index_last_end);
  */
  time_diff(&diff, &start_ts[index_first_start], &end_ts[index_last_end]);
  print_time(&diff);
  /* start-to-end time */
  time_diff(&diff, &start, &end);
  print_time(&diff);

  exit(EXIT_SUCCESS);
}

