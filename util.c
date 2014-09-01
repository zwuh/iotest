#define _GNU_SOURCE /* O_DIRECT */
#include <time.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <errno.h>

#include "iotest.h"


void *ptr_align(const void *p, size_t alignment)
{
  void const *p0 = p;
  void const *p1 = p0+alignment-1;
  return (void *)(p1 - (size_t)p1 % alignment);
}

void print_time(const struct timespec * const t)
{
  if (t->tv_sec == 0) {
    printf("%ld\n", t->tv_nsec);
  } else {
    printf("%ld%09ld\n", t->tv_sec, t->tv_nsec);
  }
}

void time_diff(struct timespec * diff, const struct timespec * const start,
               const struct timespec * const end)
{
  struct timespec tmp;
  tmp.tv_sec = end->tv_sec - start->tv_sec;
  tmp.tv_nsec = end->tv_nsec - start->tv_nsec;
  if (tmp.tv_nsec < 0) {
    tmp.tv_sec -= 1;
    tmp.tv_nsec += 1000000000;
  }
  diff->tv_sec = tmp.tv_sec;
  diff->tv_nsec = tmp.tv_nsec;
}


void time_add(struct timespec * sum, const struct timespec * const a,
               const struct timespec * const b)
{
  struct timespec tmp;
  tmp.tv_sec = a->tv_sec + b->tv_sec;
  tmp.tv_nsec = a->tv_nsec + b->tv_nsec;
  if (tmp.tv_nsec >= 1000000000) {
    tmp.tv_sec += 1;
    tmp.tv_nsec -= 1000000000;
  }
  sum->tv_sec = tmp.tv_sec;
  sum->tv_nsec = tmp.tv_nsec;
}


int time_cmp(const struct timespec * const a, const struct timespec * const b)
{
  if (a->tv_sec > b->tv_sec) {
    return 1;
  } else if (b->tv_sec > a->tv_sec) {
    return -1;
  } else {
    if (a->tv_nsec > b->tv_nsec) {
      return 1;
    } else if (b->tv_nsec > a->tv_nsec) {
      return -1;
    }
  }
  return 0;
}

char *bucket_path(char *path_last_part, int n_jobs, int job_sn)
{
#ifndef NOBUCKET
  if (n_jobs <= BUCKET_THRESHOLD) {
#else
    (void)n_jobs;
#endif
    sprintf(path_last_part, "%d" DEFAULT_BINEXT, job_sn);
#ifndef NOBUCKET
  } else {
    sprintf(path_last_part, "%d/%d" DEFAULT_BINEXT, job_sn / BUCKET_THRESHOLD, job_sn);
  }
#endif
  return path_last_part;
}

int open_file(const char * const path, const int ext_flags, const int rw)
{
  int fd;
  int err;

  if (rw == RW_WRITE) {
    fd = open(path, O_WRONLY|O_TRUNC|O_CREAT|ext_flags, S_IRUSR|S_IWUSR);
  } else {
    fd = open(path, O_RDONLY|ext_flags, 0);
  }
  if (fd == -1) {
    err = errno;
    fprintf(stderr, "ERR open: %s : (%d)%s\n", path, err, strerror(err));
  }
  return fd;
}


int write_file(const int fd, const char * last_part,
               char *buf, const int bs, const int nblk)
{
  int i, count=0, rc=0;
  int retry=0;
  struct stat s;

  for (i = 0;i < nblk;i ++) {
    count = 0;
    while (count < bs) {
      rc = write(fd, buf+count, bs-count);
      if (rc == 0 && retry < IO_RETRY) {
        retry ++;
      } else if (rc <= 0) {
        fprintf(stderr, "ERR write(%s) = %d:%s\n", last_part, errno, strerror(errno));
        return STATUS_ERROR;
      } else {
        count += rc;
      }
    }
  }
  if (fstat(fd, &s) == -1) {
    fprintf(stderr, "ERR fstat(%s) = %d:%s\n", last_part, errno, strerror(errno));
  } else if (s.st_size != bs*nblk) {
    fprintf(stderr, "ERR %s size: exptected %d got %ld\n", last_part, bs*nblk, s.st_size);
    return STATUS_WRONG_SIZE;
  }
  if (retry != 0) {
    return STATUS_HAS_RETRY;
  }
  return STATUS_SUCCESS;
}


int read_file(const int fd, const char *last_part,
              char *buf, const int bs, const int nblk)
{
  int i, count=0, rc=0;
  struct stat s;
  int retry=0;

  if (fstat(fd, &s) == -1) {
   fprintf(stderr, "ERR fstat(%s) = %d:%s\n", last_part, errno, strerror(errno));
  } else if (s.st_size < bs*nblk) {
   fprintf(stderr, "ERR %s size: exptected at least %d got %ld\n", last_part, bs*nblk, s.st_size);
   return STATUS_WRONG_SIZE;
  }

  for (i = 0;i < nblk;i ++) {
    count = 0;
    while (count < bs) {
      rc = read(fd, buf+count, bs-count);
      if (rc == 0 && retry < IO_RETRY) {
        retry ++;
      } else if (rc <= 0) {
        fprintf(stderr, "ERR read(%s) = %d:%s\n", last_part, errno, strerror(errno));
        return STATUS_ERROR;
      } else {
        count += rc;
      }
    }
  }
  if (retry != 0) {
    return STATUS_HAS_RETRY;
  }
  return STATUS_SUCCESS;
}

