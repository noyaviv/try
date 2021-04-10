
user/_tracetest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

#include "kernel/fcntl.h"



int main(int argc, char** argv){
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16

    fprintf(2, "Hello world!\n");
   8:	00001597          	auipc	a1,0x1
   c:	88058593          	addi	a1,a1,-1920 # 888 <malloc+0xea>
  10:	4509                	li	a0,2
  12:	00000097          	auipc	ra,0x0
  16:	6a0080e7          	jalr	1696(ra) # 6b2 <fprintf>

    //mask=(1<< SYS_fork)|( 1<< SYS_kill)| ( 1<< SYS_sbrk) | ( 1<< SYS_write);

    int mask=(1<< 1);

    sleep(1); //doesn't print this sleep
  1a:	4505                	li	a0,1
  1c:	00000097          	auipc	ra,0x0
  20:	3cc080e7          	jalr	972(ra) # 3e8 <sleep>

    trace(mask, getpid());
  24:	00000097          	auipc	ra,0x0
  28:	3b4080e7          	jalr	948(ra) # 3d8 <getpid>
  2c:	85aa                	mv	a1,a0
  2e:	4509                	li	a0,2
  30:	00000097          	auipc	ra,0x0
  34:	3c8080e7          	jalr	968(ra) # 3f8 <trace>

    int cpid=fork();//prints fork once
  38:	00000097          	auipc	ra,0x0
  3c:	318080e7          	jalr	792(ra) # 350 <fork>

    if (cpid==0){
  40:	ed0d                	bnez	a0,7a <main+0x7a>

        fork();// prints fork for the second time - the first son forks
  42:	00000097          	auipc	ra,0x0
  46:	30e080e7          	jalr	782(ra) # 350 <fork>

        mask= (1<< 13); //to turn on only the sleep bit

        //mask= (1<< 1)|(1<< 13); you can uncomment this inorder to check you print for both fork and sleep syscalls

        trace(mask, getpid()); //the first son and the grandchilde changes mask to print sleep
  4a:	00000097          	auipc	ra,0x0
  4e:	38e080e7          	jalr	910(ra) # 3d8 <getpid>
  52:	85aa                	mv	a1,a0
  54:	6509                	lui	a0,0x2
  56:	00000097          	auipc	ra,0x0
  5a:	3a2080e7          	jalr	930(ra) # 3f8 <trace>

        sleep(1);
  5e:	4505                	li	a0,1
  60:	00000097          	auipc	ra,0x0
  64:	388080e7          	jalr	904(ra) # 3e8 <sleep>

        fork();//should print nothing
  68:	00000097          	auipc	ra,0x0
  6c:	2e8080e7          	jalr	744(ra) # 350 <fork>

        exit(0);//shold print nothing
  70:	4501                	li	a0,0
  72:	00000097          	auipc	ra,0x0
  76:	2e6080e7          	jalr	742(ra) # 358 <exit>

    }

    else {

        sleep(10);// the father doesnt pring it - has original mask
  7a:	4529                	li	a0,10
  7c:	00000097          	auipc	ra,0x0
  80:	36c080e7          	jalr	876(ra) # 3e8 <sleep>

    }

    exit(0);
  84:	4501                	li	a0,0
  86:	00000097          	auipc	ra,0x0
  8a:	2d2080e7          	jalr	722(ra) # 358 <exit>

000000000000008e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  8e:	1141                	addi	sp,sp,-16
  90:	e422                	sd	s0,8(sp)
  92:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  94:	87aa                	mv	a5,a0
  96:	0585                	addi	a1,a1,1
  98:	0785                	addi	a5,a5,1
  9a:	fff5c703          	lbu	a4,-1(a1)
  9e:	fee78fa3          	sb	a4,-1(a5)
  a2:	fb75                	bnez	a4,96 <strcpy+0x8>
    ;
  return os;
}
  a4:	6422                	ld	s0,8(sp)
  a6:	0141                	addi	sp,sp,16
  a8:	8082                	ret

00000000000000aa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  aa:	1141                	addi	sp,sp,-16
  ac:	e422                	sd	s0,8(sp)
  ae:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  b0:	00054783          	lbu	a5,0(a0) # 2000 <__global_pointer$+0xf4f>
  b4:	cb91                	beqz	a5,c8 <strcmp+0x1e>
  b6:	0005c703          	lbu	a4,0(a1)
  ba:	00f71763          	bne	a4,a5,c8 <strcmp+0x1e>
    p++, q++;
  be:	0505                	addi	a0,a0,1
  c0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  c2:	00054783          	lbu	a5,0(a0)
  c6:	fbe5                	bnez	a5,b6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  c8:	0005c503          	lbu	a0,0(a1)
}
  cc:	40a7853b          	subw	a0,a5,a0
  d0:	6422                	ld	s0,8(sp)
  d2:	0141                	addi	sp,sp,16
  d4:	8082                	ret

00000000000000d6 <strlen>:

uint
strlen(const char *s)
{
  d6:	1141                	addi	sp,sp,-16
  d8:	e422                	sd	s0,8(sp)
  da:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  dc:	00054783          	lbu	a5,0(a0)
  e0:	cf91                	beqz	a5,fc <strlen+0x26>
  e2:	0505                	addi	a0,a0,1
  e4:	87aa                	mv	a5,a0
  e6:	4685                	li	a3,1
  e8:	9e89                	subw	a3,a3,a0
  ea:	00f6853b          	addw	a0,a3,a5
  ee:	0785                	addi	a5,a5,1
  f0:	fff7c703          	lbu	a4,-1(a5)
  f4:	fb7d                	bnez	a4,ea <strlen+0x14>
    ;
  return n;
}
  f6:	6422                	ld	s0,8(sp)
  f8:	0141                	addi	sp,sp,16
  fa:	8082                	ret
  for(n = 0; s[n]; n++)
  fc:	4501                	li	a0,0
  fe:	bfe5                	j	f6 <strlen+0x20>

0000000000000100 <memset>:

void*
memset(void *dst, int c, uint n)
{
 100:	1141                	addi	sp,sp,-16
 102:	e422                	sd	s0,8(sp)
 104:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 106:	ca19                	beqz	a2,11c <memset+0x1c>
 108:	87aa                	mv	a5,a0
 10a:	1602                	slli	a2,a2,0x20
 10c:	9201                	srli	a2,a2,0x20
 10e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 112:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 116:	0785                	addi	a5,a5,1
 118:	fee79de3          	bne	a5,a4,112 <memset+0x12>
  }
  return dst;
}
 11c:	6422                	ld	s0,8(sp)
 11e:	0141                	addi	sp,sp,16
 120:	8082                	ret

0000000000000122 <strchr>:

char*
strchr(const char *s, char c)
{
 122:	1141                	addi	sp,sp,-16
 124:	e422                	sd	s0,8(sp)
 126:	0800                	addi	s0,sp,16
  for(; *s; s++)
 128:	00054783          	lbu	a5,0(a0)
 12c:	cb99                	beqz	a5,142 <strchr+0x20>
    if(*s == c)
 12e:	00f58763          	beq	a1,a5,13c <strchr+0x1a>
  for(; *s; s++)
 132:	0505                	addi	a0,a0,1
 134:	00054783          	lbu	a5,0(a0)
 138:	fbfd                	bnez	a5,12e <strchr+0xc>
      return (char*)s;
  return 0;
 13a:	4501                	li	a0,0
}
 13c:	6422                	ld	s0,8(sp)
 13e:	0141                	addi	sp,sp,16
 140:	8082                	ret
  return 0;
 142:	4501                	li	a0,0
 144:	bfe5                	j	13c <strchr+0x1a>

0000000000000146 <gets>:

char*
gets(char *buf, int max)
{
 146:	711d                	addi	sp,sp,-96
 148:	ec86                	sd	ra,88(sp)
 14a:	e8a2                	sd	s0,80(sp)
 14c:	e4a6                	sd	s1,72(sp)
 14e:	e0ca                	sd	s2,64(sp)
 150:	fc4e                	sd	s3,56(sp)
 152:	f852                	sd	s4,48(sp)
 154:	f456                	sd	s5,40(sp)
 156:	f05a                	sd	s6,32(sp)
 158:	ec5e                	sd	s7,24(sp)
 15a:	1080                	addi	s0,sp,96
 15c:	8baa                	mv	s7,a0
 15e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 160:	892a                	mv	s2,a0
 162:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 164:	4aa9                	li	s5,10
 166:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 168:	89a6                	mv	s3,s1
 16a:	2485                	addiw	s1,s1,1
 16c:	0344d863          	bge	s1,s4,19c <gets+0x56>
    cc = read(0, &c, 1);
 170:	4605                	li	a2,1
 172:	faf40593          	addi	a1,s0,-81
 176:	4501                	li	a0,0
 178:	00000097          	auipc	ra,0x0
 17c:	1f8080e7          	jalr	504(ra) # 370 <read>
    if(cc < 1)
 180:	00a05e63          	blez	a0,19c <gets+0x56>
    buf[i++] = c;
 184:	faf44783          	lbu	a5,-81(s0)
 188:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 18c:	01578763          	beq	a5,s5,19a <gets+0x54>
 190:	0905                	addi	s2,s2,1
 192:	fd679be3          	bne	a5,s6,168 <gets+0x22>
  for(i=0; i+1 < max; ){
 196:	89a6                	mv	s3,s1
 198:	a011                	j	19c <gets+0x56>
 19a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 19c:	99de                	add	s3,s3,s7
 19e:	00098023          	sb	zero,0(s3)
  return buf;
}
 1a2:	855e                	mv	a0,s7
 1a4:	60e6                	ld	ra,88(sp)
 1a6:	6446                	ld	s0,80(sp)
 1a8:	64a6                	ld	s1,72(sp)
 1aa:	6906                	ld	s2,64(sp)
 1ac:	79e2                	ld	s3,56(sp)
 1ae:	7a42                	ld	s4,48(sp)
 1b0:	7aa2                	ld	s5,40(sp)
 1b2:	7b02                	ld	s6,32(sp)
 1b4:	6be2                	ld	s7,24(sp)
 1b6:	6125                	addi	sp,sp,96
 1b8:	8082                	ret

00000000000001ba <stat>:

int
stat(const char *n, struct stat *st)
{
 1ba:	1101                	addi	sp,sp,-32
 1bc:	ec06                	sd	ra,24(sp)
 1be:	e822                	sd	s0,16(sp)
 1c0:	e426                	sd	s1,8(sp)
 1c2:	e04a                	sd	s2,0(sp)
 1c4:	1000                	addi	s0,sp,32
 1c6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1c8:	4581                	li	a1,0
 1ca:	00000097          	auipc	ra,0x0
 1ce:	1ce080e7          	jalr	462(ra) # 398 <open>
  if(fd < 0)
 1d2:	02054563          	bltz	a0,1fc <stat+0x42>
 1d6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1d8:	85ca                	mv	a1,s2
 1da:	00000097          	auipc	ra,0x0
 1de:	1d6080e7          	jalr	470(ra) # 3b0 <fstat>
 1e2:	892a                	mv	s2,a0
  close(fd);
 1e4:	8526                	mv	a0,s1
 1e6:	00000097          	auipc	ra,0x0
 1ea:	19a080e7          	jalr	410(ra) # 380 <close>
  return r;
}
 1ee:	854a                	mv	a0,s2
 1f0:	60e2                	ld	ra,24(sp)
 1f2:	6442                	ld	s0,16(sp)
 1f4:	64a2                	ld	s1,8(sp)
 1f6:	6902                	ld	s2,0(sp)
 1f8:	6105                	addi	sp,sp,32
 1fa:	8082                	ret
    return -1;
 1fc:	597d                	li	s2,-1
 1fe:	bfc5                	j	1ee <stat+0x34>

0000000000000200 <atoi>:

int
atoi(const char *s)
{
 200:	1141                	addi	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 206:	00054603          	lbu	a2,0(a0)
 20a:	fd06079b          	addiw	a5,a2,-48
 20e:	0ff7f793          	andi	a5,a5,255
 212:	4725                	li	a4,9
 214:	02f76963          	bltu	a4,a5,246 <atoi+0x46>
 218:	86aa                	mv	a3,a0
  n = 0;
 21a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 21c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 21e:	0685                	addi	a3,a3,1
 220:	0025179b          	slliw	a5,a0,0x2
 224:	9fa9                	addw	a5,a5,a0
 226:	0017979b          	slliw	a5,a5,0x1
 22a:	9fb1                	addw	a5,a5,a2
 22c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 230:	0006c603          	lbu	a2,0(a3)
 234:	fd06071b          	addiw	a4,a2,-48
 238:	0ff77713          	andi	a4,a4,255
 23c:	fee5f1e3          	bgeu	a1,a4,21e <atoi+0x1e>
  return n;
}
 240:	6422                	ld	s0,8(sp)
 242:	0141                	addi	sp,sp,16
 244:	8082                	ret
  n = 0;
 246:	4501                	li	a0,0
 248:	bfe5                	j	240 <atoi+0x40>

000000000000024a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 24a:	1141                	addi	sp,sp,-16
 24c:	e422                	sd	s0,8(sp)
 24e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 250:	02b57463          	bgeu	a0,a1,278 <memmove+0x2e>
    while(n-- > 0)
 254:	00c05f63          	blez	a2,272 <memmove+0x28>
 258:	1602                	slli	a2,a2,0x20
 25a:	9201                	srli	a2,a2,0x20
 25c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 260:	872a                	mv	a4,a0
      *dst++ = *src++;
 262:	0585                	addi	a1,a1,1
 264:	0705                	addi	a4,a4,1
 266:	fff5c683          	lbu	a3,-1(a1)
 26a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 26e:	fee79ae3          	bne	a5,a4,262 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 272:	6422                	ld	s0,8(sp)
 274:	0141                	addi	sp,sp,16
 276:	8082                	ret
    dst += n;
 278:	00c50733          	add	a4,a0,a2
    src += n;
 27c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 27e:	fec05ae3          	blez	a2,272 <memmove+0x28>
 282:	fff6079b          	addiw	a5,a2,-1
 286:	1782                	slli	a5,a5,0x20
 288:	9381                	srli	a5,a5,0x20
 28a:	fff7c793          	not	a5,a5
 28e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 290:	15fd                	addi	a1,a1,-1
 292:	177d                	addi	a4,a4,-1
 294:	0005c683          	lbu	a3,0(a1)
 298:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 29c:	fee79ae3          	bne	a5,a4,290 <memmove+0x46>
 2a0:	bfc9                	j	272 <memmove+0x28>

00000000000002a2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2a2:	1141                	addi	sp,sp,-16
 2a4:	e422                	sd	s0,8(sp)
 2a6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2a8:	ca05                	beqz	a2,2d8 <memcmp+0x36>
 2aa:	fff6069b          	addiw	a3,a2,-1
 2ae:	1682                	slli	a3,a3,0x20
 2b0:	9281                	srli	a3,a3,0x20
 2b2:	0685                	addi	a3,a3,1
 2b4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2b6:	00054783          	lbu	a5,0(a0)
 2ba:	0005c703          	lbu	a4,0(a1)
 2be:	00e79863          	bne	a5,a4,2ce <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2c2:	0505                	addi	a0,a0,1
    p2++;
 2c4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2c6:	fed518e3          	bne	a0,a3,2b6 <memcmp+0x14>
  }
  return 0;
 2ca:	4501                	li	a0,0
 2cc:	a019                	j	2d2 <memcmp+0x30>
      return *p1 - *p2;
 2ce:	40e7853b          	subw	a0,a5,a4
}
 2d2:	6422                	ld	s0,8(sp)
 2d4:	0141                	addi	sp,sp,16
 2d6:	8082                	ret
  return 0;
 2d8:	4501                	li	a0,0
 2da:	bfe5                	j	2d2 <memcmp+0x30>

00000000000002dc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2dc:	1141                	addi	sp,sp,-16
 2de:	e406                	sd	ra,8(sp)
 2e0:	e022                	sd	s0,0(sp)
 2e2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2e4:	00000097          	auipc	ra,0x0
 2e8:	f66080e7          	jalr	-154(ra) # 24a <memmove>
}
 2ec:	60a2                	ld	ra,8(sp)
 2ee:	6402                	ld	s0,0(sp)
 2f0:	0141                	addi	sp,sp,16
 2f2:	8082                	ret

00000000000002f4 <my_strcat>:

// functions added by us

char* my_strcat(char* destination, const char* source)
{
 2f4:	1141                	addi	sp,sp,-16
 2f6:	e422                	sd	s0,8(sp)
 2f8:	0800                	addi	s0,sp,16
    int i, j;
 
    // move to the end of destination string
    for (i = 0; destination[i] != '\0'; i++);
 2fa:	00054783          	lbu	a5,0(a0)
 2fe:	c7a9                	beqz	a5,348 <my_strcat+0x54>
 300:	00150713          	addi	a4,a0,1
 304:	87ba                	mv	a5,a4
 306:	4685                	li	a3,1
 308:	9e99                	subw	a3,a3,a4
 30a:	00f6863b          	addw	a2,a3,a5
 30e:	0785                	addi	a5,a5,1
 310:	fff7c703          	lbu	a4,-1(a5)
 314:	fb7d                	bnez	a4,30a <my_strcat+0x16>
 
    // i now points to terminating null character in destination
 
    // Appends characters of source to the destination string
    for (j = 0; source[j] != '\0'; j++)
 316:	0005c683          	lbu	a3,0(a1)
 31a:	ca8d                	beqz	a3,34c <my_strcat+0x58>
 31c:	4785                	li	a5,1
        destination[i + j] = source[j];
 31e:	00f60733          	add	a4,a2,a5
 322:	972a                	add	a4,a4,a0
 324:	fed70fa3          	sb	a3,-1(a4)
    for (j = 0; source[j] != '\0'; j++)
 328:	0007881b          	sext.w	a6,a5
 32c:	0785                	addi	a5,a5,1
 32e:	00f58733          	add	a4,a1,a5
 332:	fff74683          	lbu	a3,-1(a4)
 336:	f6e5                	bnez	a3,31e <my_strcat+0x2a>
 
    // null terminate destination string
    destination[i + j] = '\0';
 338:	0106063b          	addw	a2,a2,a6
 33c:	962a                	add	a2,a2,a0
 33e:	00060023          	sb	zero,0(a2)
 
    // destination is returned by standard strcat()
    return destination;
 342:	6422                	ld	s0,8(sp)
 344:	0141                	addi	sp,sp,16
 346:	8082                	ret
    for (i = 0; destination[i] != '\0'; i++);
 348:	4601                	li	a2,0
 34a:	b7f1                	j	316 <my_strcat+0x22>
    for (j = 0; source[j] != '\0'; j++)
 34c:	4801                	li	a6,0
 34e:	b7ed                	j	338 <my_strcat+0x44>

0000000000000350 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 350:	4885                	li	a7,1
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <exit>:
.global exit
exit:
 li a7, SYS_exit
 358:	4889                	li	a7,2
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <wait>:
.global wait
wait:
 li a7, SYS_wait
 360:	488d                	li	a7,3
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 368:	4891                	li	a7,4
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <read>:
.global read
read:
 li a7, SYS_read
 370:	4895                	li	a7,5
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <write>:
.global write
write:
 li a7, SYS_write
 378:	48c1                	li	a7,16
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <close>:
.global close
close:
 li a7, SYS_close
 380:	48d5                	li	a7,21
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <kill>:
.global kill
kill:
 li a7, SYS_kill
 388:	4899                	li	a7,6
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <exec>:
.global exec
exec:
 li a7, SYS_exec
 390:	489d                	li	a7,7
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <open>:
.global open
open:
 li a7, SYS_open
 398:	48bd                	li	a7,15
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3a0:	48c5                	li	a7,17
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3a8:	48c9                	li	a7,18
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3b0:	48a1                	li	a7,8
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <link>:
.global link
link:
 li a7, SYS_link
 3b8:	48cd                	li	a7,19
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3c0:	48d1                	li	a7,20
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3c8:	48a5                	li	a7,9
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3d0:	48a9                	li	a7,10
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3d8:	48ad                	li	a7,11
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3e0:	48b1                	li	a7,12
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3e8:	48b5                	li	a7,13
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3f0:	48b9                	li	a7,14
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <trace>:
.global trace
trace:
 li a7, SYS_trace
 3f8:	48d9                	li	a7,22
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <wait_stat>:
.global wait_stat
wait_stat:
 li a7, SYS_wait_stat
 400:	48dd                	li	a7,23
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 408:	1101                	addi	sp,sp,-32
 40a:	ec06                	sd	ra,24(sp)
 40c:	e822                	sd	s0,16(sp)
 40e:	1000                	addi	s0,sp,32
 410:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 414:	4605                	li	a2,1
 416:	fef40593          	addi	a1,s0,-17
 41a:	00000097          	auipc	ra,0x0
 41e:	f5e080e7          	jalr	-162(ra) # 378 <write>
}
 422:	60e2                	ld	ra,24(sp)
 424:	6442                	ld	s0,16(sp)
 426:	6105                	addi	sp,sp,32
 428:	8082                	ret

000000000000042a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 42a:	7139                	addi	sp,sp,-64
 42c:	fc06                	sd	ra,56(sp)
 42e:	f822                	sd	s0,48(sp)
 430:	f426                	sd	s1,40(sp)
 432:	f04a                	sd	s2,32(sp)
 434:	ec4e                	sd	s3,24(sp)
 436:	0080                	addi	s0,sp,64
 438:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 43a:	c299                	beqz	a3,440 <printint+0x16>
 43c:	0805c863          	bltz	a1,4cc <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 440:	2581                	sext.w	a1,a1
  neg = 0;
 442:	4881                	li	a7,0
 444:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 448:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 44a:	2601                	sext.w	a2,a2
 44c:	00000517          	auipc	a0,0x0
 450:	45450513          	addi	a0,a0,1108 # 8a0 <digits>
 454:	883a                	mv	a6,a4
 456:	2705                	addiw	a4,a4,1
 458:	02c5f7bb          	remuw	a5,a1,a2
 45c:	1782                	slli	a5,a5,0x20
 45e:	9381                	srli	a5,a5,0x20
 460:	97aa                	add	a5,a5,a0
 462:	0007c783          	lbu	a5,0(a5)
 466:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 46a:	0005879b          	sext.w	a5,a1
 46e:	02c5d5bb          	divuw	a1,a1,a2
 472:	0685                	addi	a3,a3,1
 474:	fec7f0e3          	bgeu	a5,a2,454 <printint+0x2a>
  if(neg)
 478:	00088b63          	beqz	a7,48e <printint+0x64>
    buf[i++] = '-';
 47c:	fd040793          	addi	a5,s0,-48
 480:	973e                	add	a4,a4,a5
 482:	02d00793          	li	a5,45
 486:	fef70823          	sb	a5,-16(a4)
 48a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 48e:	02e05863          	blez	a4,4be <printint+0x94>
 492:	fc040793          	addi	a5,s0,-64
 496:	00e78933          	add	s2,a5,a4
 49a:	fff78993          	addi	s3,a5,-1
 49e:	99ba                	add	s3,s3,a4
 4a0:	377d                	addiw	a4,a4,-1
 4a2:	1702                	slli	a4,a4,0x20
 4a4:	9301                	srli	a4,a4,0x20
 4a6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4aa:	fff94583          	lbu	a1,-1(s2)
 4ae:	8526                	mv	a0,s1
 4b0:	00000097          	auipc	ra,0x0
 4b4:	f58080e7          	jalr	-168(ra) # 408 <putc>
  while(--i >= 0)
 4b8:	197d                	addi	s2,s2,-1
 4ba:	ff3918e3          	bne	s2,s3,4aa <printint+0x80>
}
 4be:	70e2                	ld	ra,56(sp)
 4c0:	7442                	ld	s0,48(sp)
 4c2:	74a2                	ld	s1,40(sp)
 4c4:	7902                	ld	s2,32(sp)
 4c6:	69e2                	ld	s3,24(sp)
 4c8:	6121                	addi	sp,sp,64
 4ca:	8082                	ret
    x = -xx;
 4cc:	40b005bb          	negw	a1,a1
    neg = 1;
 4d0:	4885                	li	a7,1
    x = -xx;
 4d2:	bf8d                	j	444 <printint+0x1a>

00000000000004d4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d4:	7119                	addi	sp,sp,-128
 4d6:	fc86                	sd	ra,120(sp)
 4d8:	f8a2                	sd	s0,112(sp)
 4da:	f4a6                	sd	s1,104(sp)
 4dc:	f0ca                	sd	s2,96(sp)
 4de:	ecce                	sd	s3,88(sp)
 4e0:	e8d2                	sd	s4,80(sp)
 4e2:	e4d6                	sd	s5,72(sp)
 4e4:	e0da                	sd	s6,64(sp)
 4e6:	fc5e                	sd	s7,56(sp)
 4e8:	f862                	sd	s8,48(sp)
 4ea:	f466                	sd	s9,40(sp)
 4ec:	f06a                	sd	s10,32(sp)
 4ee:	ec6e                	sd	s11,24(sp)
 4f0:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4f2:	0005c903          	lbu	s2,0(a1)
 4f6:	18090f63          	beqz	s2,694 <vprintf+0x1c0>
 4fa:	8aaa                	mv	s5,a0
 4fc:	8b32                	mv	s6,a2
 4fe:	00158493          	addi	s1,a1,1
  state = 0;
 502:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 504:	02500a13          	li	s4,37
      if(c == 'd'){
 508:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 50c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 510:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 514:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 518:	00000b97          	auipc	s7,0x0
 51c:	388b8b93          	addi	s7,s7,904 # 8a0 <digits>
 520:	a839                	j	53e <vprintf+0x6a>
        putc(fd, c);
 522:	85ca                	mv	a1,s2
 524:	8556                	mv	a0,s5
 526:	00000097          	auipc	ra,0x0
 52a:	ee2080e7          	jalr	-286(ra) # 408 <putc>
 52e:	a019                	j	534 <vprintf+0x60>
    } else if(state == '%'){
 530:	01498f63          	beq	s3,s4,54e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 534:	0485                	addi	s1,s1,1
 536:	fff4c903          	lbu	s2,-1(s1)
 53a:	14090d63          	beqz	s2,694 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 53e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 542:	fe0997e3          	bnez	s3,530 <vprintf+0x5c>
      if(c == '%'){
 546:	fd479ee3          	bne	a5,s4,522 <vprintf+0x4e>
        state = '%';
 54a:	89be                	mv	s3,a5
 54c:	b7e5                	j	534 <vprintf+0x60>
      if(c == 'd'){
 54e:	05878063          	beq	a5,s8,58e <vprintf+0xba>
      } else if(c == 'l') {
 552:	05978c63          	beq	a5,s9,5aa <vprintf+0xd6>
      } else if(c == 'x') {
 556:	07a78863          	beq	a5,s10,5c6 <vprintf+0xf2>
      } else if(c == 'p') {
 55a:	09b78463          	beq	a5,s11,5e2 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 55e:	07300713          	li	a4,115
 562:	0ce78663          	beq	a5,a4,62e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 566:	06300713          	li	a4,99
 56a:	0ee78e63          	beq	a5,a4,666 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 56e:	11478863          	beq	a5,s4,67e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 572:	85d2                	mv	a1,s4
 574:	8556                	mv	a0,s5
 576:	00000097          	auipc	ra,0x0
 57a:	e92080e7          	jalr	-366(ra) # 408 <putc>
        putc(fd, c);
 57e:	85ca                	mv	a1,s2
 580:	8556                	mv	a0,s5
 582:	00000097          	auipc	ra,0x0
 586:	e86080e7          	jalr	-378(ra) # 408 <putc>
      }
      state = 0;
 58a:	4981                	li	s3,0
 58c:	b765                	j	534 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 58e:	008b0913          	addi	s2,s6,8
 592:	4685                	li	a3,1
 594:	4629                	li	a2,10
 596:	000b2583          	lw	a1,0(s6)
 59a:	8556                	mv	a0,s5
 59c:	00000097          	auipc	ra,0x0
 5a0:	e8e080e7          	jalr	-370(ra) # 42a <printint>
 5a4:	8b4a                	mv	s6,s2
      state = 0;
 5a6:	4981                	li	s3,0
 5a8:	b771                	j	534 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5aa:	008b0913          	addi	s2,s6,8
 5ae:	4681                	li	a3,0
 5b0:	4629                	li	a2,10
 5b2:	000b2583          	lw	a1,0(s6)
 5b6:	8556                	mv	a0,s5
 5b8:	00000097          	auipc	ra,0x0
 5bc:	e72080e7          	jalr	-398(ra) # 42a <printint>
 5c0:	8b4a                	mv	s6,s2
      state = 0;
 5c2:	4981                	li	s3,0
 5c4:	bf85                	j	534 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5c6:	008b0913          	addi	s2,s6,8
 5ca:	4681                	li	a3,0
 5cc:	4641                	li	a2,16
 5ce:	000b2583          	lw	a1,0(s6)
 5d2:	8556                	mv	a0,s5
 5d4:	00000097          	auipc	ra,0x0
 5d8:	e56080e7          	jalr	-426(ra) # 42a <printint>
 5dc:	8b4a                	mv	s6,s2
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	bf91                	j	534 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5e2:	008b0793          	addi	a5,s6,8
 5e6:	f8f43423          	sd	a5,-120(s0)
 5ea:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5ee:	03000593          	li	a1,48
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	e14080e7          	jalr	-492(ra) # 408 <putc>
  putc(fd, 'x');
 5fc:	85ea                	mv	a1,s10
 5fe:	8556                	mv	a0,s5
 600:	00000097          	auipc	ra,0x0
 604:	e08080e7          	jalr	-504(ra) # 408 <putc>
 608:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 60a:	03c9d793          	srli	a5,s3,0x3c
 60e:	97de                	add	a5,a5,s7
 610:	0007c583          	lbu	a1,0(a5)
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	df2080e7          	jalr	-526(ra) # 408 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 61e:	0992                	slli	s3,s3,0x4
 620:	397d                	addiw	s2,s2,-1
 622:	fe0914e3          	bnez	s2,60a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 626:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 62a:	4981                	li	s3,0
 62c:	b721                	j	534 <vprintf+0x60>
        s = va_arg(ap, char*);
 62e:	008b0993          	addi	s3,s6,8
 632:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 636:	02090163          	beqz	s2,658 <vprintf+0x184>
        while(*s != 0){
 63a:	00094583          	lbu	a1,0(s2)
 63e:	c9a1                	beqz	a1,68e <vprintf+0x1ba>
          putc(fd, *s);
 640:	8556                	mv	a0,s5
 642:	00000097          	auipc	ra,0x0
 646:	dc6080e7          	jalr	-570(ra) # 408 <putc>
          s++;
 64a:	0905                	addi	s2,s2,1
        while(*s != 0){
 64c:	00094583          	lbu	a1,0(s2)
 650:	f9e5                	bnez	a1,640 <vprintf+0x16c>
        s = va_arg(ap, char*);
 652:	8b4e                	mv	s6,s3
      state = 0;
 654:	4981                	li	s3,0
 656:	bdf9                	j	534 <vprintf+0x60>
          s = "(null)";
 658:	00000917          	auipc	s2,0x0
 65c:	24090913          	addi	s2,s2,576 # 898 <malloc+0xfa>
        while(*s != 0){
 660:	02800593          	li	a1,40
 664:	bff1                	j	640 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 666:	008b0913          	addi	s2,s6,8
 66a:	000b4583          	lbu	a1,0(s6)
 66e:	8556                	mv	a0,s5
 670:	00000097          	auipc	ra,0x0
 674:	d98080e7          	jalr	-616(ra) # 408 <putc>
 678:	8b4a                	mv	s6,s2
      state = 0;
 67a:	4981                	li	s3,0
 67c:	bd65                	j	534 <vprintf+0x60>
        putc(fd, c);
 67e:	85d2                	mv	a1,s4
 680:	8556                	mv	a0,s5
 682:	00000097          	auipc	ra,0x0
 686:	d86080e7          	jalr	-634(ra) # 408 <putc>
      state = 0;
 68a:	4981                	li	s3,0
 68c:	b565                	j	534 <vprintf+0x60>
        s = va_arg(ap, char*);
 68e:	8b4e                	mv	s6,s3
      state = 0;
 690:	4981                	li	s3,0
 692:	b54d                	j	534 <vprintf+0x60>
    }
  }
}
 694:	70e6                	ld	ra,120(sp)
 696:	7446                	ld	s0,112(sp)
 698:	74a6                	ld	s1,104(sp)
 69a:	7906                	ld	s2,96(sp)
 69c:	69e6                	ld	s3,88(sp)
 69e:	6a46                	ld	s4,80(sp)
 6a0:	6aa6                	ld	s5,72(sp)
 6a2:	6b06                	ld	s6,64(sp)
 6a4:	7be2                	ld	s7,56(sp)
 6a6:	7c42                	ld	s8,48(sp)
 6a8:	7ca2                	ld	s9,40(sp)
 6aa:	7d02                	ld	s10,32(sp)
 6ac:	6de2                	ld	s11,24(sp)
 6ae:	6109                	addi	sp,sp,128
 6b0:	8082                	ret

00000000000006b2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6b2:	715d                	addi	sp,sp,-80
 6b4:	ec06                	sd	ra,24(sp)
 6b6:	e822                	sd	s0,16(sp)
 6b8:	1000                	addi	s0,sp,32
 6ba:	e010                	sd	a2,0(s0)
 6bc:	e414                	sd	a3,8(s0)
 6be:	e818                	sd	a4,16(s0)
 6c0:	ec1c                	sd	a5,24(s0)
 6c2:	03043023          	sd	a6,32(s0)
 6c6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6ca:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6ce:	8622                	mv	a2,s0
 6d0:	00000097          	auipc	ra,0x0
 6d4:	e04080e7          	jalr	-508(ra) # 4d4 <vprintf>
}
 6d8:	60e2                	ld	ra,24(sp)
 6da:	6442                	ld	s0,16(sp)
 6dc:	6161                	addi	sp,sp,80
 6de:	8082                	ret

00000000000006e0 <printf>:

void
printf(const char *fmt, ...)
{
 6e0:	711d                	addi	sp,sp,-96
 6e2:	ec06                	sd	ra,24(sp)
 6e4:	e822                	sd	s0,16(sp)
 6e6:	1000                	addi	s0,sp,32
 6e8:	e40c                	sd	a1,8(s0)
 6ea:	e810                	sd	a2,16(s0)
 6ec:	ec14                	sd	a3,24(s0)
 6ee:	f018                	sd	a4,32(s0)
 6f0:	f41c                	sd	a5,40(s0)
 6f2:	03043823          	sd	a6,48(s0)
 6f6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6fa:	00840613          	addi	a2,s0,8
 6fe:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 702:	85aa                	mv	a1,a0
 704:	4505                	li	a0,1
 706:	00000097          	auipc	ra,0x0
 70a:	dce080e7          	jalr	-562(ra) # 4d4 <vprintf>
}
 70e:	60e2                	ld	ra,24(sp)
 710:	6442                	ld	s0,16(sp)
 712:	6125                	addi	sp,sp,96
 714:	8082                	ret

0000000000000716 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 716:	1141                	addi	sp,sp,-16
 718:	e422                	sd	s0,8(sp)
 71a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 71c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 720:	00000797          	auipc	a5,0x0
 724:	1987b783          	ld	a5,408(a5) # 8b8 <freep>
 728:	a805                	j	758 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 72a:	4618                	lw	a4,8(a2)
 72c:	9db9                	addw	a1,a1,a4
 72e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 732:	6398                	ld	a4,0(a5)
 734:	6318                	ld	a4,0(a4)
 736:	fee53823          	sd	a4,-16(a0)
 73a:	a091                	j	77e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 73c:	ff852703          	lw	a4,-8(a0)
 740:	9e39                	addw	a2,a2,a4
 742:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 744:	ff053703          	ld	a4,-16(a0)
 748:	e398                	sd	a4,0(a5)
 74a:	a099                	j	790 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 74c:	6398                	ld	a4,0(a5)
 74e:	00e7e463          	bltu	a5,a4,756 <free+0x40>
 752:	00e6ea63          	bltu	a3,a4,766 <free+0x50>
{
 756:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 758:	fed7fae3          	bgeu	a5,a3,74c <free+0x36>
 75c:	6398                	ld	a4,0(a5)
 75e:	00e6e463          	bltu	a3,a4,766 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 762:	fee7eae3          	bltu	a5,a4,756 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 766:	ff852583          	lw	a1,-8(a0)
 76a:	6390                	ld	a2,0(a5)
 76c:	02059813          	slli	a6,a1,0x20
 770:	01c85713          	srli	a4,a6,0x1c
 774:	9736                	add	a4,a4,a3
 776:	fae60ae3          	beq	a2,a4,72a <free+0x14>
    bp->s.ptr = p->s.ptr;
 77a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 77e:	4790                	lw	a2,8(a5)
 780:	02061593          	slli	a1,a2,0x20
 784:	01c5d713          	srli	a4,a1,0x1c
 788:	973e                	add	a4,a4,a5
 78a:	fae689e3          	beq	a3,a4,73c <free+0x26>
  } else
    p->s.ptr = bp;
 78e:	e394                	sd	a3,0(a5)
  freep = p;
 790:	00000717          	auipc	a4,0x0
 794:	12f73423          	sd	a5,296(a4) # 8b8 <freep>
}
 798:	6422                	ld	s0,8(sp)
 79a:	0141                	addi	sp,sp,16
 79c:	8082                	ret

000000000000079e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 79e:	7139                	addi	sp,sp,-64
 7a0:	fc06                	sd	ra,56(sp)
 7a2:	f822                	sd	s0,48(sp)
 7a4:	f426                	sd	s1,40(sp)
 7a6:	f04a                	sd	s2,32(sp)
 7a8:	ec4e                	sd	s3,24(sp)
 7aa:	e852                	sd	s4,16(sp)
 7ac:	e456                	sd	s5,8(sp)
 7ae:	e05a                	sd	s6,0(sp)
 7b0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7b2:	02051493          	slli	s1,a0,0x20
 7b6:	9081                	srli	s1,s1,0x20
 7b8:	04bd                	addi	s1,s1,15
 7ba:	8091                	srli	s1,s1,0x4
 7bc:	0014899b          	addiw	s3,s1,1
 7c0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7c2:	00000517          	auipc	a0,0x0
 7c6:	0f653503          	ld	a0,246(a0) # 8b8 <freep>
 7ca:	c515                	beqz	a0,7f6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7cc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ce:	4798                	lw	a4,8(a5)
 7d0:	02977f63          	bgeu	a4,s1,80e <malloc+0x70>
 7d4:	8a4e                	mv	s4,s3
 7d6:	0009871b          	sext.w	a4,s3
 7da:	6685                	lui	a3,0x1
 7dc:	00d77363          	bgeu	a4,a3,7e2 <malloc+0x44>
 7e0:	6a05                	lui	s4,0x1
 7e2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7e6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7ea:	00000917          	auipc	s2,0x0
 7ee:	0ce90913          	addi	s2,s2,206 # 8b8 <freep>
  if(p == (char*)-1)
 7f2:	5afd                	li	s5,-1
 7f4:	a895                	j	868 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7f6:	00000797          	auipc	a5,0x0
 7fa:	0ca78793          	addi	a5,a5,202 # 8c0 <base>
 7fe:	00000717          	auipc	a4,0x0
 802:	0af73d23          	sd	a5,186(a4) # 8b8 <freep>
 806:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 808:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 80c:	b7e1                	j	7d4 <malloc+0x36>
      if(p->s.size == nunits)
 80e:	02e48c63          	beq	s1,a4,846 <malloc+0xa8>
        p->s.size -= nunits;
 812:	4137073b          	subw	a4,a4,s3
 816:	c798                	sw	a4,8(a5)
        p += p->s.size;
 818:	02071693          	slli	a3,a4,0x20
 81c:	01c6d713          	srli	a4,a3,0x1c
 820:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 822:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 826:	00000717          	auipc	a4,0x0
 82a:	08a73923          	sd	a0,146(a4) # 8b8 <freep>
      return (void*)(p + 1);
 82e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 832:	70e2                	ld	ra,56(sp)
 834:	7442                	ld	s0,48(sp)
 836:	74a2                	ld	s1,40(sp)
 838:	7902                	ld	s2,32(sp)
 83a:	69e2                	ld	s3,24(sp)
 83c:	6a42                	ld	s4,16(sp)
 83e:	6aa2                	ld	s5,8(sp)
 840:	6b02                	ld	s6,0(sp)
 842:	6121                	addi	sp,sp,64
 844:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 846:	6398                	ld	a4,0(a5)
 848:	e118                	sd	a4,0(a0)
 84a:	bff1                	j	826 <malloc+0x88>
  hp->s.size = nu;
 84c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 850:	0541                	addi	a0,a0,16
 852:	00000097          	auipc	ra,0x0
 856:	ec4080e7          	jalr	-316(ra) # 716 <free>
  return freep;
 85a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 85e:	d971                	beqz	a0,832 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 860:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 862:	4798                	lw	a4,8(a5)
 864:	fa9775e3          	bgeu	a4,s1,80e <malloc+0x70>
    if(p == freep)
 868:	00093703          	ld	a4,0(s2)
 86c:	853e                	mv	a0,a5
 86e:	fef719e3          	bne	a4,a5,860 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 872:	8552                	mv	a0,s4
 874:	00000097          	auipc	ra,0x0
 878:	b6c080e7          	jalr	-1172(ra) # 3e0 <sbrk>
  if(p == (char*)-1)
 87c:	fd5518e3          	bne	a0,s5,84c <malloc+0xae>
        return 0;
 880:	4501                	li	a0,0
 882:	bf45                	j	832 <malloc+0x94>
