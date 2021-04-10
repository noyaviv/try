#include "../kernel/types.h"
#include "user.h"
#include "../kernel/fcntl.h"
#include "../kernel/syscall.h"

struct perf
{
    int ctime;
    int ttime;
    int stime;
    int retime;
    int rutime;
    int average_bursttime;
};
void printPerf(struct perf*,int);
int
main(int argc, char *argv[]){
    int cpid;
    int cexst;
    struct perf per;

    long j=9999999;
    int sec = argc > 1 ? 10*atoi(argv[1]) : 10;
    printf("%d is counting!\n",getpid());
    while(j-->0);

    if((cpid = fork()) == 0){
        sleep(sec);
        long i = 99999999;
        printf("%d is counting!\n",getpid());
        while(i-->0);

        exit(4);
    }
    else{
        wait_stat(&cexst,&per);
        printf("child(%d) exit with code %d\n",cpid,cexst);
        printPerf(&per,cpid);
    }

    exit(0);
}

void
printPerf(struct perf* per,int cpid){
    printf("PID: %d\nctime: %d\nttime: %d\nstime: %d\nretime: %d\nrutime: %d\n",cpid,per->ctime,per->ttime,per->stime,per->retime,per->rutime);
}



