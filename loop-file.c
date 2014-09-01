#define _GNU_SOURCE /* O_DIRECT */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>

#include "iotest.h"

int n_loops    = DEFAULT_N_LOOPS;
int block_size = DEFAULT_BLOCK_SIZE;
int n_blocks   = DEFAULT_N_BLOCKS;
char target_dir[PATH_LENGTH];
char *block;
int rw = RW_UNSET;
int quiet = 0;

int open_ext_flags = 0;

struct timespec dd_like_sum;

void worker(int round_id)
{
  int fd;
  char name[32];
  int err;

  struct timespec start, end, diff;

  sprintf(name, "%d" DEFAULT_BINEXT, round_id);
  fd = open_file(name, open_ext_flags, rw);
  if (fd == -1) {
    return;
  }

  clock_gettime(CLOCK_REALTIME, &start);

  if (rw == RW_WRITE) {
    write_file(fd, name, block, block_size, n_blocks);
  } else {
    read_file(fd, name, block, block_size, n_blocks);
  }
  if (close(fd) != 0) {
    err = errno;
    fprintf(stderr, "ERR close(%s): %s\n", name, strerror(err));
  }

  clock_gettime(CLOCK_REALTIME, &end);

  time_diff(&diff, &start, &end);
  time_add(&dd_like_sum, &dd_like_sum, &diff);

  return;
}

void process_arg(int argc, char *argv[])
{
  int opt;

  while ((opt = getopt(argc, argv, "n:t:b:s:dcrwq")) != -1) {
    switch (opt) {
      case 'n':
        n_loops = atoi(optarg);
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
        printf("Usage: %s [-r|-w] [-n n_loops] [-t target_dir]\n", argv[0]);
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
  printf(" number of iterations: %d\n", n_loops);
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
  int round;
  void *blk_mem;
  struct timespec start, end, diff;

  memset(&dd_like_sum, 0, sizeof(struct timespec));

  clock_gettime(CLOCK_REALTIME, &start);

  memset(target_dir, 0, PATH_LENGTH);
  /* default target dir */
  snprintf(target_dir, PATH_LENGTH-1, DEFAULT_TARGET);

  process_arg(argc, argv);
  print_config();

  if (chdir(target_dir)) {
    perror("Unable to chdir() to target_dir");
    exit(EXIT_FAILURE);
  }

  if ((blk_mem = malloc(block_size*2-1)) == NULL) {
    perror("Unable to allocate write buffer");
    exit(EXIT_FAILURE);
  }
  memset(blk_mem, FILL_BYTE, block_size*2-1);
  block = ptr_align(blk_mem, block_size);

  for (round = 0;round < n_loops;round ++) {
    /*printf("Iteration #%d\n", round);*/
    worker(round);
  }

  /*printf("Syncing ...\n");
  sync();*/

  free(blk_mem);

  clock_gettime(CLOCK_REALTIME, &end);

  time_diff(&diff, &start, &end);

  if (quiet == 0) {
   printf("dd-like-sum (ns): ");
  }
  print_time(&dd_like_sum);
  if (quiet == 0) {
   printf("start-end (ns): ");
  }
  print_time(&diff);

  exit(EXIT_SUCCESS);
}

