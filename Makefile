CC= gcc
CFLAGS= -Wall -Wextra
OFLAGS= $(CFLAGS)

# Clear default suffixes.
.SUFFIXES:

.PHONY: all
all: pthread loop worker punlink parse-file parse-meta

loop: loop-file.o util.o
	$(CC) $(OFLAGS) $^ -lrt -o $@

pthread: pthread-file.o util.o
	$(CC) $(OFLAGS) -pthread $^ -lrt -o $@

worker: pthread-worker.o util.o
	$(CC) $(OFLAGS) -pthread $^ -lrt -o $@

punlink: pthread-unlink.o util.o
	$(CC) $(OFLAGS) -pthread $^ -lrt -o $@

parse-file: parse-file.o
	$(CC) $(OFLAGS) $^ -o $@

parse-meta: parse-meta.o
	$(CC) $(OFLAGS) $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $^

.PHONY: clean
clean:
	rm -f a.out *.o loop pthread worker punlink parse-log parse-file parse-meta

