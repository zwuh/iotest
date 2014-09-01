
#define PATH_LENGTH 1024
#define FILL_BYTE   0x3e
#define MAX_THREADS 256
#define NAME_LENGTH 32

#define DEFAULT_N_THREADS  10
#define DEFAULT_N_LOOPS    10
#define DEFAULT_N_BLOCKS   1
#define DEFAULT_JOBS_PER_THREAD 1
#define DEFAULT_JOB_SIZE   4096
#define DEFAULT_BLOCK_SIZE DEFAULT_JOB_SIZE
#define DEFAULT_DURATION   0
#define DEFAULT_BASE_JOBSN 0

#define DEFAULT_TARGET "/dev/shm"

#define DEFAULT_BINEXT ".bin"

#define RW_UNSET    0
#define RW_READ     1
#define RW_WRITE    2

#define IO_RETRY    3

#define STATUS_SUCCESS    0
#define STATUS_ERROR      1
#define STATUS_WRONG_SIZE 2
#define STATUS_HAS_RETRY  4

#define TRUE  1
#define FALSE 0

/* Maximum number of files per directory */
#define BUCKET_THRESHOLD  4096
//#define NOBUCKET

/* Show per-thread time stamps */
//#define TIMELIME

void *ptr_align(const void *p, size_t alignment);

void print_time(const struct timespec * const t);

void time_diff(struct timespec * diff, const struct timespec * const start,
               const struct timespec * const end);

void time_add(struct timespec * sum, const struct timespec * const a,
               const struct timespec * const b);

int time_cmp(const struct timespec * const a, const struct timespec * const b);

int open_file(const char * const path, const int ext_flags, const int rw);

int write_file(const int fd, const char *last_part,
               char *buf, const int bs, const int nblk);

int read_file(const int fd, const char *last_part,
              char *buf, const int bs, const int nblk);


char *bucket_path(char *path_last_part, int n_jobs, int job_sn);

