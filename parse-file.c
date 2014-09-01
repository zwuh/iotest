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
int has_serviced = TRUE;

char table_name[32] = "_TABLE_";

double abs_double(double x)
{
  if (x < 0) { return -x; }
  return x;
}

int sql_error(int n_jobs, int total_serviced, double throughput)
{
  if (TRUE == has_serviced) {
   return n_jobs - total_serviced;
  }
  if (throughput < 0) { return 1; }
  return 0;
}

void process_arg(int argc, char *argv[])
{
  int opt;

  while ((opt = getopt(argc, argv, "tsnfbe")) != -1) {
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
      case 'f':
       strcpy(table_name, "file");
       break;
      case 'b':
       strcpy(table_name, "blocksize");
       break;
      case 'e':
       has_serviced = FALSE;
       break;
      default:
       printf("Usage: parse-file [-t] [-s] [-n] [-b] [-f]\n");
       printf(" -t : tcpdump\n -s : SQL output\n -n : new tcpdump\n");
       printf(" -f : SQL table=file\n -b : SQL table=blocksize\n");
       printf(" -e : No Serviced: line.\n");
       exit(0);
       break;
    }
  }
}

int main(int argc, char *argv[])
{
 char line[1024], misc[1024];
 char fs[16], flag[8], rw[4];
 int n_threads, bs, n_jobs, job_sz, jobpt, base, du;
 double elapsed, throughput;
 int error = 0;
 int last_errno, count=0;
 int total_serviced=0;
 long long cpu_useful_start , cpu_total_start;
 long long cpu_useful_end , cpu_total_end;
 long long cpu_useful_clean , cpu_total_clean;
 long long net_pkt_start , net_bytes_start;
 long long net_pkt_end , net_bytes_end;
 long long net_pkt_clean , net_bytes_clean;
 long long tcpdump_pkt, tcpdump_bytes;

 process_arg(argc, argv);

 if (FALSE == want_sql) { /* default CSV output */
  fprintf(stderr, "Generating CSV output\n");
  printf("fs,flag,thread,bs,job_sz,n_job,serviced,base,rw,elapsed,throughput,cpu,pkt,bytes,pkt_delta,bytes_delta,cpu_clean,pkt_clean,bytes_clean\n");
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
    sscanf(line, "fs:%s flag:%s n:%d bs:%d job_sz:%d jobpt:%d n_job:%d base:%d du:%d rw:%s",
     fs, flag, &n_threads, &bs, &job_sz, &jobpt, &n_jobs, &base, &du, rw);
   } else { error = 1; last_errno = errno; }

   if (error == 0 && NULL != fgets(line, 1023, stdin)) {
    sscanf(line, "CPU %Ld %Ld", &cpu_useful_start, &cpu_total_start);
    //printf("%Ld %Ld\n", cpu_useful_start, cpu_total_start);
   } else { error = 2; last_errno = errno; }

   if (error == 0 && NULL != fgets(line, 1023, stdin)) {
    sscanf(line, "NET %Ld %Ld", &net_pkt_start, &net_bytes_start);
    //printf("%Ld %Ld\n", net_pkt_start, net_bytes_start);
   } else { error = 3; last_errno = errno; }

   if (error == 0 && NULL != fgets(line, 1023, stdin)) {
    sscanf(line, "END-CPU %Ld %Ld", &cpu_useful_end, &cpu_total_end);
    //printf("%Ld %Ld\n", cpu_useful_end, cpu_total_end);
   } else { error = 4;  last_errno = errno; }

   if (error == 0 && NULL != fgets(line, 1023, stdin)) {
    sscanf(line, "END-NET %Ld %Ld", &net_pkt_end, &net_bytes_end);
    //printf("%Ld %Ld\n", net_pkt_end, net_bytes_end);
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

   if (error == 0 && NULL != fgets(line, 1023, stdin)) {
    sscanf(line, "CLEAN-CPU %Ld %Ld\n", &cpu_useful_clean, &cpu_total_clean);
    //printf("%Ld %Ld\n", cpu_useful_clean, cpu_total_clean);
   } else { error = 7;  last_errno = errno; }

   if (error == 0 && NULL != fgets(line, 1023, stdin)) {
    sscanf(line, "CLEAN-NET %Ld %Ld", &net_pkt_clean, &net_bytes_clean);
    //printf("%Ld %Ld : %s \n", net_pkt_clean, net_bytes_clean, line);
   } else { error = 8;  last_errno = errno; }

   if (TRUE == has_serviced) {
    if (error == 0 && NULL != fgets(line, 1023, stdin)) {
     sscanf(line, "Serviced: %d", &total_serviced);
    } else { error = 9; last_errno = errno; }
   }

   if (error == 0 && NULL != fgets(line, 1023, stdin)) {
    sscanf(line, "Elapsed: %lf", &elapsed);
    //printf("%.9lf\n", elapsed);
   } else { error = 10;  last_errno = errno; }

   if (error == 0 && NULL != fgets(line, 1023, stdin)) {
    sscanf(line, "Throughput: %lf", &throughput);
    //printf("%.9lf\n", throughput);
   } else { error = 11;  last_errno = errno; }

   if (error != 0) { fprintf(stderr, "Error:C%d S%d %s\n", count, error, strerror(last_errno)); break; }

   count ++;

  if (TRUE == want_sql) {
   printf("INSERT INTO %s (scenario,fs,date,n_threads,n_jobs,job_size,block_size,rw,flag,cpu,throughput,elapsed,npkt,transferred,bytes_clean,error)", table_name);
   printf(" VALUE (_SCENE_,%s,'_DATE_',%d,%d,%d,%d,'%s','%s',%lf,%lf,%lf,%lld,%lld,%lld,%d);\n",
    fs, n_threads, n_jobs, job_sz, bs, rw, flag, (double)(cpu_useful_end-cpu_useful_start)/(cpu_total_end-cpu_total_start),
    abs_double(throughput), elapsed,
    tcpdump_pkt, tcpdump_bytes, net_bytes_clean-net_bytes_end,
    sql_error(n_jobs, total_serviced, throughput));
  } else {
   printf("%s,%s,%d,%d,%d,%d,%d,%d,%s,%lf,%lf",
    fs, flag, n_threads, bs, job_sz, n_jobs, total_serviced, base, rw, elapsed, throughput);
   printf(",%lf,%lld,%lld,%lld,%lld",(double)(cpu_useful_end-cpu_useful_start)/(cpu_total_end-cpu_total_start),
    tcpdump_pkt, tcpdump_bytes, net_pkt_end-net_pkt_start-tcpdump_pkt, net_bytes_end-net_bytes_start-tcpdump_bytes);
   printf(",%lf,%lld,%lld",(double)(cpu_useful_clean-cpu_useful_end)/(cpu_total_clean-cpu_total_end),
    net_pkt_clean-net_pkt_end, net_bytes_clean-net_bytes_end);
   putchar('\n');
  }

 }
 return 0;
}

