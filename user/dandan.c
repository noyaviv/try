#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

struct perf {
  int ctime;                   // Process creation time
  int ttime;                   // Process termination time    
  int stime;                   // Total time spent SLEEPING state
  int retime;                  // Total time spent RUNNABLE state
  int rutime;                  // Total time spent RUNNING state
  int average_bursttime;       // approx. estimated burst time
};


int main(int argc, char** argv){

    printf("started\n");
    int pid2= fork();
     
    if (pid2 == 0)
    {
    
       int c = 0;

        while (c < 3)
        {
            printf("child is running\n");
            sleep(10);
            c++;
        }
        while (c < 3000)
        {
            printf("%d", c);
            c++;
        }
        printf("\n");
     }
     else
     {
        int* status;
        struct perf p;
        int id = getpid();
        status = &id;
        

         int x = wait_stat(status, &p);

        printf("ret val: %d \n", x);
        printf("ctime: %d \n", p.ctime);
        printf("ttime: %d \n", p.ttime);
        printf("stime: %d \n", p.stime);
        printf("retime: %d \n", p.retime);
        printf("rutime: %d\n", p.rutime);
        printf("avgburst: %d\n", p.average_bursttime);
        set_priority(1);
     }

    sleep(1);
    exit(0);


    // fprintf(2, "Hello world!\n");
    // int mask = 1;               //for printing fork
    // sleep(1);                   //doesn't print this sleep
    // trace(mask, getpid());
    // int cpid = fork();          //prints fork once
    // if (cpid == 0){
    //     fork();                 // prints fork for the second time - the first son forks
    //     mask = 8191;            //to turn on only the sleep bit
    //     //mask = 4097;          //you can uncomment this in order to check you print for both fork and sleep syscalls
    //     trace(mask, getpid());  //the first son and the grandchilde changes mask to print sleep
    //     sleep(1);
    //     fork();                 //should print nothing
    //     sbrk(2048);
    //     kill(getpid());
    //     exit(0);                //shold print nothing
    // }
    // else {
    //     sleep(10);              // the father doesnt print it - has original mask
    // }

    
}

/* example for right printing:

3: syscall fork 0-> 4
4: syscall fork 0-> 5 of line 12
4: syscall sleep -> 0
5: syscall sleep -> 0
 */