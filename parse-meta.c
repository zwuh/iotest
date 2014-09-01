#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>

#define TRUE  1
#define FALSE 0

int has_tcpdump = FALSE;
int new_tcpdump = FALSE;
int want_sql = FALSE;

double abs_double(double x)
{
  if (x < 0) { return -x; }
  return x;
}

void process_arg(int argc, char *argv[])
{
  int opt;

  while ((opt = getopt(argc, argv, "tsn")) != -1) {
    switch (opt) {
      case 't':
       has_tcpdump = TRUE;
       break;
      case 's':
       want_sql = TRUE;
       break;
      case 'n':
       has_tcpdump = TRUE;
       new_tcpdump = TRUE;
       break;
      default:
       printf("Usage: parse-meta [-t] [-s] [-n]\n");
       printf(" -t : tcpdump\n -s : SQL output\n -n : new tcpdump\n");
       exit(0);
       break;
    }
  }
}

int main(int argc, char *argv[])
{
 char line[1024], misc[1024];
 char fs[16], op[16];
 int n_jobs;
 double elapsed;
 int error = 0;
 int last_errno, count=0;
 long long cpu_useful_start , cpu_total_start;
 long long cpu_useful_end , cpu_total_end;
 long long net_pkt_start , net_bytes_start;
 long long net_pkt_end , net_bytes_end;
 long long tcpdump_pkt, tcpdump_bytes;

 process_arg(argc, argv);

 if (FALSE == want_sql) { /* default CSV output */
  fprintf(stderr, "Generating CSV output\n");
  printf("fs,op,n_jobs,elapsed,cpu,pkt,bytes,pkt_delta,bytes_delta\n");
 } else {
  fprintf(stderr, "Generating SQL output\n");
 }

 if (TRUE == has_tcpdump) {
  if (TRUE == new_tcpdump) {
   fprintf(stderr, "Expecting new tcpdump format.\n");
  } else {
   fprintf(stderr, "Expecting old tcpdump format.\n");
  }
 } else {
  fprintf(stderr, "No tcpdump output, using kernel counters only.\n");
 }

 while (0 == error) {
   if (NULL != fgets(line, 1023, stdin)) {
    sscanf(line, "fs:%s op:%s n_jobs:%d",
     fs, op, &n_jobs);
   } else { error = 1; last_errno = errno; }

   if (error == 0 && NULL != fgets(line, 1023, stdin)) {
    sscanf(line, "CPU %lld %lld", &cpu_useful_start, &cpu_total_start);
   } else { error = 2; last_errno = errno; }

   if (error == 0 && NULL != fgets(line, 1023, stdin)) {
    sscanf(line, "NET %lld %lld", &net_pkt_start, &net_bytes_start);
   } else { error = 3; last_errno = errno; }

   if (error == 0 && NULL != fgets(line, 1023, stdin)) {
    sscanf(line, "END-CPU %lld %lld", &cpu_useful_end, &cpu_total_end);
   } else { error = 4;  last_errno = errno; }

   if (error == 0 && NULL != fgets(line, 1023, stdin)) {
    sscanf(line, "END-NET %lld %lld", &net_pkt_end, &net_bytes_end);
   } else { error = 5;  last_errno = errno; }

   if (FALSE == has_tcpdump) {
    (void)misc;
    tcpdump_pkt = net_pkt_end - net_pkt_start;
    tcpdump_bytes = net_bytes_end - net_bytes_start;
   } else if (error == 0 && NULL != fgets(line, 1023, stdin)) {
    if (TRUE == new_tcpdump) {
     (void)misc;
     sscanf(line, "|%*f <> %*f | %Ld | %Ld |", &tcpdump_pkt, &tcpdump_bytes);
    } else {
     sscanf(line, "%s %Ld %Ld", misc, &tcpdump_pkt, &tcpdump_bytes);
    }
   } else { error = 6;  last_errno = errno; }
/*
   printf("DBG tp %lld tb %lld nps %lld nbs %lld npe %lld nbe %lld\n",
    tcpdump_pkt, tcpdump_bytes, net_pkt_start, net_bytes_start,
    net_pkt_end, net_bytes_end);
*/

   if (error == 0 && NULL != fgets(line, 1023, stdin)) {
    sscanf(line, "Elapsed: %lf", &elapsed);
   } else { error = 7;  last_errno = errno; }

   if (error != 0) { fprintf(stderr, "Error:C%d S%d %s\n", count, error, strerror(last_errno)); break; }

   count ++;

  if (TRUE == want_sql) {
   printf("INSERT INTO metadata (scenario,fs,date,n_jobs,op,cpu,elapsed,npkt,transferred)");
   printf(" VALUE (_SCENE_,%s,'_DATE_',%d,'%s',%lf,%lf,%lld,%lld);\n",
    fs, n_jobs, op,
    (double)(cpu_useful_end-cpu_useful_start)/(cpu_total_end-cpu_total_start),
    elapsed, tcpdump_pkt, tcpdump_bytes);
  } else {
   printf("%s,%s,%d,%lf", fs, op, n_jobs, elapsed);
   printf(",%lf,%lld,%lld,%lld,%lld",
     (double)(cpu_useful_end-cpu_useful_start)/(cpu_total_end-cpu_total_start),
     tcpdump_pkt, tcpdump_bytes,
     net_pkt_end-net_pkt_start-tcpdump_pkt,
     net_bytes_end-net_bytes_start-tcpdump_bytes);
   putchar('\n');
  }

 }
 return 0;
}

