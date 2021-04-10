
user/_ln:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  if(argc != 3){
   a:	478d                	li	a5,3
   c:	02f50063          	beq	a0,a5,2c <main+0x2c>
    fprintf(2, "Usage: ln old new\n");
  10:	00001597          	auipc	a1,0x1
  14:	84858593          	addi	a1,a1,-1976 # 858 <malloc+0xe8>
  18:	4509                	li	a0,2
  1a:	00000097          	auipc	ra,0x0
  1e:	66a080e7          	jalr	1642(ra) # 684 <fprintf>
    exit(1);
  22:	4505                	li	a0,1
  24:	00000097          	auipc	ra,0x0
  28:	306080e7          	jalr	774(ra) # 32a <exit>
  2c:	84ae                	mv	s1,a1
  }
  if(link(argv[1], argv[2]) < 0)
  2e:	698c                	ld	a1,16(a1)
  30:	6488                	ld	a0,8(s1)
  32:	00000097          	auipc	ra,0x0
  36:	358080e7          	jalr	856(ra) # 38a <link>
  3a:	00054763          	bltz	a0,48 <main+0x48>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	2ea080e7          	jalr	746(ra) # 32a <exit>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  48:	6894                	ld	a3,16(s1)
  4a:	6490                	ld	a2,8(s1)
  4c:	00001597          	auipc	a1,0x1
  50:	82458593          	addi	a1,a1,-2012 # 870 <malloc+0x100>
  54:	4509                	li	a0,2
  56:	00000097          	auipc	ra,0x0
  5a:	62e080e7          	jalr	1582(ra) # 684 <fprintf>
  5e:	b7c5                	j	3e <main+0x3e>

0000000000000060 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  60:	1141                	addi	sp,sp,-16
  62:	e422                	sd	s0,8(sp)
  64:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  66:	87aa                	mv	a5,a0
  68:	0585                	addi	a1,a1,1
  6a:	0785                	addi	a5,a5,1
  6c:	fff5c703          	lbu	a4,-1(a1)
  70:	fee78fa3          	sb	a4,-1(a5)
  74:	fb75                	bnez	a4,68 <strcpy+0x8>
    ;
  return os;
}
  76:	6422                	ld	s0,8(sp)
  78:	0141                	addi	sp,sp,16
  7a:	8082                	ret

000000000000007c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  7c:	1141                	addi	sp,sp,-16
  7e:	e422                	sd	s0,8(sp)
  80:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  82:	00054783          	lbu	a5,0(a0)
  86:	cb91                	beqz	a5,9a <strcmp+0x1e>
  88:	0005c703          	lbu	a4,0(a1)
  8c:	00f71763          	bne	a4,a5,9a <strcmp+0x1e>
    p++, q++;
  90:	0505                	addi	a0,a0,1
  92:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  94:	00054783          	lbu	a5,0(a0)
  98:	fbe5                	bnez	a5,88 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  9a:	0005c503          	lbu	a0,0(a1)
}
  9e:	40a7853b          	subw	a0,a5,a0
  a2:	6422                	ld	s0,8(sp)
  a4:	0141                	addi	sp,sp,16
  a6:	8082                	ret

00000000000000a8 <strlen>:

uint
strlen(const char *s)
{
  a8:	1141                	addi	sp,sp,-16
  aa:	e422                	sd	s0,8(sp)
  ac:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ae:	00054783          	lbu	a5,0(a0)
  b2:	cf91                	beqz	a5,ce <strlen+0x26>
  b4:	0505                	addi	a0,a0,1
  b6:	87aa                	mv	a5,a0
  b8:	4685                	li	a3,1
  ba:	9e89                	subw	a3,a3,a0
  bc:	00f6853b          	addw	a0,a3,a5
  c0:	0785                	addi	a5,a5,1
  c2:	fff7c703          	lbu	a4,-1(a5)
  c6:	fb7d                	bnez	a4,bc <strlen+0x14>
    ;
  return n;
}
  c8:	6422                	ld	s0,8(sp)
  ca:	0141                	addi	sp,sp,16
  cc:	8082                	ret
  for(n = 0; s[n]; n++)
  ce:	4501                	li	a0,0
  d0:	bfe5                	j	c8 <strlen+0x20>

00000000000000d2 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d2:	1141                	addi	sp,sp,-16
  d4:	e422                	sd	s0,8(sp)
  d6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  d8:	ca19                	beqz	a2,ee <memset+0x1c>
  da:	87aa                	mv	a5,a0
  dc:	1602                	slli	a2,a2,0x20
  de:	9201                	srli	a2,a2,0x20
  e0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  e4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  e8:	0785                	addi	a5,a5,1
  ea:	fee79de3          	bne	a5,a4,e4 <memset+0x12>
  }
  return dst;
}
  ee:	6422                	ld	s0,8(sp)
  f0:	0141                	addi	sp,sp,16
  f2:	8082                	ret

00000000000000f4 <strchr>:

char*
strchr(const char *s, char c)
{
  f4:	1141                	addi	sp,sp,-16
  f6:	e422                	sd	s0,8(sp)
  f8:	0800                	addi	s0,sp,16
  for(; *s; s++)
  fa:	00054783          	lbu	a5,0(a0)
  fe:	cb99                	beqz	a5,114 <strchr+0x20>
    if(*s == c)
 100:	00f58763          	beq	a1,a5,10e <strchr+0x1a>
  for(; *s; s++)
 104:	0505                	addi	a0,a0,1
 106:	00054783          	lbu	a5,0(a0)
 10a:	fbfd                	bnez	a5,100 <strchr+0xc>
      return (char*)s;
  return 0;
 10c:	4501                	li	a0,0
}
 10e:	6422                	ld	s0,8(sp)
 110:	0141                	addi	sp,sp,16
 112:	8082                	ret
  return 0;
 114:	4501                	li	a0,0
 116:	bfe5                	j	10e <strchr+0x1a>

0000000000000118 <gets>:

char*
gets(char *buf, int max)
{
 118:	711d                	addi	sp,sp,-96
 11a:	ec86                	sd	ra,88(sp)
 11c:	e8a2                	sd	s0,80(sp)
 11e:	e4a6                	sd	s1,72(sp)
 120:	e0ca                	sd	s2,64(sp)
 122:	fc4e                	sd	s3,56(sp)
 124:	f852                	sd	s4,48(sp)
 126:	f456                	sd	s5,40(sp)
 128:	f05a                	sd	s6,32(sp)
 12a:	ec5e                	sd	s7,24(sp)
 12c:	1080                	addi	s0,sp,96
 12e:	8baa                	mv	s7,a0
 130:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 132:	892a                	mv	s2,a0
 134:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 136:	4aa9                	li	s5,10
 138:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 13a:	89a6                	mv	s3,s1
 13c:	2485                	addiw	s1,s1,1
 13e:	0344d863          	bge	s1,s4,16e <gets+0x56>
    cc = read(0, &c, 1);
 142:	4605                	li	a2,1
 144:	faf40593          	addi	a1,s0,-81
 148:	4501                	li	a0,0
 14a:	00000097          	auipc	ra,0x0
 14e:	1f8080e7          	jalr	504(ra) # 342 <read>
    if(cc < 1)
 152:	00a05e63          	blez	a0,16e <gets+0x56>
    buf[i++] = c;
 156:	faf44783          	lbu	a5,-81(s0)
 15a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 15e:	01578763          	beq	a5,s5,16c <gets+0x54>
 162:	0905                	addi	s2,s2,1
 164:	fd679be3          	bne	a5,s6,13a <gets+0x22>
  for(i=0; i+1 < max; ){
 168:	89a6                	mv	s3,s1
 16a:	a011                	j	16e <gets+0x56>
 16c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 16e:	99de                	add	s3,s3,s7
 170:	00098023          	sb	zero,0(s3)
  return buf;
}
 174:	855e                	mv	a0,s7
 176:	60e6                	ld	ra,88(sp)
 178:	6446                	ld	s0,80(sp)
 17a:	64a6                	ld	s1,72(sp)
 17c:	6906                	ld	s2,64(sp)
 17e:	79e2                	ld	s3,56(sp)
 180:	7a42                	ld	s4,48(sp)
 182:	7aa2                	ld	s5,40(sp)
 184:	7b02                	ld	s6,32(sp)
 186:	6be2                	ld	s7,24(sp)
 188:	6125                	addi	sp,sp,96
 18a:	8082                	ret

000000000000018c <stat>:

int
stat(const char *n, struct stat *st)
{
 18c:	1101                	addi	sp,sp,-32
 18e:	ec06                	sd	ra,24(sp)
 190:	e822                	sd	s0,16(sp)
 192:	e426                	sd	s1,8(sp)
 194:	e04a                	sd	s2,0(sp)
 196:	1000                	addi	s0,sp,32
 198:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 19a:	4581                	li	a1,0
 19c:	00000097          	auipc	ra,0x0
 1a0:	1ce080e7          	jalr	462(ra) # 36a <open>
  if(fd < 0)
 1a4:	02054563          	bltz	a0,1ce <stat+0x42>
 1a8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1aa:	85ca                	mv	a1,s2
 1ac:	00000097          	auipc	ra,0x0
 1b0:	1d6080e7          	jalr	470(ra) # 382 <fstat>
 1b4:	892a                	mv	s2,a0
  close(fd);
 1b6:	8526                	mv	a0,s1
 1b8:	00000097          	auipc	ra,0x0
 1bc:	19a080e7          	jalr	410(ra) # 352 <close>
  return r;
}
 1c0:	854a                	mv	a0,s2
 1c2:	60e2                	ld	ra,24(sp)
 1c4:	6442                	ld	s0,16(sp)
 1c6:	64a2                	ld	s1,8(sp)
 1c8:	6902                	ld	s2,0(sp)
 1ca:	6105                	addi	sp,sp,32
 1cc:	8082                	ret
    return -1;
 1ce:	597d                	li	s2,-1
 1d0:	bfc5                	j	1c0 <stat+0x34>

00000000000001d2 <atoi>:

int
atoi(const char *s)
{
 1d2:	1141                	addi	sp,sp,-16
 1d4:	e422                	sd	s0,8(sp)
 1d6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1d8:	00054603          	lbu	a2,0(a0)
 1dc:	fd06079b          	addiw	a5,a2,-48
 1e0:	0ff7f793          	andi	a5,a5,255
 1e4:	4725                	li	a4,9
 1e6:	02f76963          	bltu	a4,a5,218 <atoi+0x46>
 1ea:	86aa                	mv	a3,a0
  n = 0;
 1ec:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1ee:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1f0:	0685                	addi	a3,a3,1
 1f2:	0025179b          	slliw	a5,a0,0x2
 1f6:	9fa9                	addw	a5,a5,a0
 1f8:	0017979b          	slliw	a5,a5,0x1
 1fc:	9fb1                	addw	a5,a5,a2
 1fe:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 202:	0006c603          	lbu	a2,0(a3)
 206:	fd06071b          	addiw	a4,a2,-48
 20a:	0ff77713          	andi	a4,a4,255
 20e:	fee5f1e3          	bgeu	a1,a4,1f0 <atoi+0x1e>
  return n;
}
 212:	6422                	ld	s0,8(sp)
 214:	0141                	addi	sp,sp,16
 216:	8082                	ret
  n = 0;
 218:	4501                	li	a0,0
 21a:	bfe5                	j	212 <atoi+0x40>

000000000000021c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 21c:	1141                	addi	sp,sp,-16
 21e:	e422                	sd	s0,8(sp)
 220:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 222:	02b57463          	bgeu	a0,a1,24a <memmove+0x2e>
    while(n-- > 0)
 226:	00c05f63          	blez	a2,244 <memmove+0x28>
 22a:	1602                	slli	a2,a2,0x20
 22c:	9201                	srli	a2,a2,0x20
 22e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 232:	872a                	mv	a4,a0
      *dst++ = *src++;
 234:	0585                	addi	a1,a1,1
 236:	0705                	addi	a4,a4,1
 238:	fff5c683          	lbu	a3,-1(a1)
 23c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 240:	fee79ae3          	bne	a5,a4,234 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 244:	6422                	ld	s0,8(sp)
 246:	0141                	addi	sp,sp,16
 248:	8082                	ret
    dst += n;
 24a:	00c50733          	add	a4,a0,a2
    src += n;
 24e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 250:	fec05ae3          	blez	a2,244 <memmove+0x28>
 254:	fff6079b          	addiw	a5,a2,-1
 258:	1782                	slli	a5,a5,0x20
 25a:	9381                	srli	a5,a5,0x20
 25c:	fff7c793          	not	a5,a5
 260:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 262:	15fd                	addi	a1,a1,-1
 264:	177d                	addi	a4,a4,-1
 266:	0005c683          	lbu	a3,0(a1)
 26a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 26e:	fee79ae3          	bne	a5,a4,262 <memmove+0x46>
 272:	bfc9                	j	244 <memmove+0x28>

0000000000000274 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 274:	1141                	addi	sp,sp,-16
 276:	e422                	sd	s0,8(sp)
 278:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 27a:	ca05                	beqz	a2,2aa <memcmp+0x36>
 27c:	fff6069b          	addiw	a3,a2,-1
 280:	1682                	slli	a3,a3,0x20
 282:	9281                	srli	a3,a3,0x20
 284:	0685                	addi	a3,a3,1
 286:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 288:	00054783          	lbu	a5,0(a0)
 28c:	0005c703          	lbu	a4,0(a1)
 290:	00e79863          	bne	a5,a4,2a0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 294:	0505                	addi	a0,a0,1
    p2++;
 296:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 298:	fed518e3          	bne	a0,a3,288 <memcmp+0x14>
  }
  return 0;
 29c:	4501                	li	a0,0
 29e:	a019                	j	2a4 <memcmp+0x30>
      return *p1 - *p2;
 2a0:	40e7853b          	subw	a0,a5,a4
}
 2a4:	6422                	ld	s0,8(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret
  return 0;
 2aa:	4501                	li	a0,0
 2ac:	bfe5                	j	2a4 <memcmp+0x30>

00000000000002ae <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2ae:	1141                	addi	sp,sp,-16
 2b0:	e406                	sd	ra,8(sp)
 2b2:	e022                	sd	s0,0(sp)
 2b4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2b6:	00000097          	auipc	ra,0x0
 2ba:	f66080e7          	jalr	-154(ra) # 21c <memmove>
}
 2be:	60a2                	ld	ra,8(sp)
 2c0:	6402                	ld	s0,0(sp)
 2c2:	0141                	addi	sp,sp,16
 2c4:	8082                	ret

00000000000002c6 <my_strcat>:

// functions added by us

char* my_strcat(char* destination, const char* source)
{
 2c6:	1141                	addi	sp,sp,-16
 2c8:	e422                	sd	s0,8(sp)
 2ca:	0800                	addi	s0,sp,16
    int i, j;
 
    // move to the end of destination string
    for (i = 0; destination[i] != '\0'; i++);
 2cc:	00054783          	lbu	a5,0(a0)
 2d0:	c7a9                	beqz	a5,31a <my_strcat+0x54>
 2d2:	00150713          	addi	a4,a0,1
 2d6:	87ba                	mv	a5,a4
 2d8:	4685                	li	a3,1
 2da:	9e99                	subw	a3,a3,a4
 2dc:	00f6863b          	addw	a2,a3,a5
 2e0:	0785                	addi	a5,a5,1
 2e2:	fff7c703          	lbu	a4,-1(a5)
 2e6:	fb7d                	bnez	a4,2dc <my_strcat+0x16>
 
    // i now points to terminating null character in destination
 
    // Appends characters of source to the destination string
    for (j = 0; source[j] != '\0'; j++)
 2e8:	0005c683          	lbu	a3,0(a1)
 2ec:	ca8d                	beqz	a3,31e <my_strcat+0x58>
 2ee:	4785                	li	a5,1
        destination[i + j] = source[j];
 2f0:	00f60733          	add	a4,a2,a5
 2f4:	972a                	add	a4,a4,a0
 2f6:	fed70fa3          	sb	a3,-1(a4)
    for (j = 0; source[j] != '\0'; j++)
 2fa:	0007881b          	sext.w	a6,a5
 2fe:	0785                	addi	a5,a5,1
 300:	00f58733          	add	a4,a1,a5
 304:	fff74683          	lbu	a3,-1(a4)
 308:	f6e5                	bnez	a3,2f0 <my_strcat+0x2a>
 
    // null terminate destination string
    destination[i + j] = '\0';
 30a:	0106063b          	addw	a2,a2,a6
 30e:	962a                	add	a2,a2,a0
 310:	00060023          	sb	zero,0(a2)
 
    // destination is returned by standard strcat()
    return destination;
 314:	6422                	ld	s0,8(sp)
 316:	0141                	addi	sp,sp,16
 318:	8082                	ret
    for (i = 0; destination[i] != '\0'; i++);
 31a:	4601                	li	a2,0
 31c:	b7f1                	j	2e8 <my_strcat+0x22>
    for (j = 0; source[j] != '\0'; j++)
 31e:	4801                	li	a6,0
 320:	b7ed                	j	30a <my_strcat+0x44>

0000000000000322 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 322:	4885                	li	a7,1
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <exit>:
.global exit
exit:
 li a7, SYS_exit
 32a:	4889                	li	a7,2
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <wait>:
.global wait
wait:
 li a7, SYS_wait
 332:	488d                	li	a7,3
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 33a:	4891                	li	a7,4
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <read>:
.global read
read:
 li a7, SYS_read
 342:	4895                	li	a7,5
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <write>:
.global write
write:
 li a7, SYS_write
 34a:	48c1                	li	a7,16
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <close>:
.global close
close:
 li a7, SYS_close
 352:	48d5                	li	a7,21
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <kill>:
.global kill
kill:
 li a7, SYS_kill
 35a:	4899                	li	a7,6
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <exec>:
.global exec
exec:
 li a7, SYS_exec
 362:	489d                	li	a7,7
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <open>:
.global open
open:
 li a7, SYS_open
 36a:	48bd                	li	a7,15
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 372:	48c5                	li	a7,17
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 37a:	48c9                	li	a7,18
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 382:	48a1                	li	a7,8
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <link>:
.global link
link:
 li a7, SYS_link
 38a:	48cd                	li	a7,19
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 392:	48d1                	li	a7,20
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 39a:	48a5                	li	a7,9
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3a2:	48a9                	li	a7,10
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3aa:	48ad                	li	a7,11
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3b2:	48b1                	li	a7,12
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3ba:	48b5                	li	a7,13
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3c2:	48b9                	li	a7,14
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <trace>:
.global trace
trace:
 li a7, SYS_trace
 3ca:	48d9                	li	a7,22
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <wait_stat>:
.global wait_stat
wait_stat:
 li a7, SYS_wait_stat
 3d2:	48dd                	li	a7,23
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3da:	1101                	addi	sp,sp,-32
 3dc:	ec06                	sd	ra,24(sp)
 3de:	e822                	sd	s0,16(sp)
 3e0:	1000                	addi	s0,sp,32
 3e2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3e6:	4605                	li	a2,1
 3e8:	fef40593          	addi	a1,s0,-17
 3ec:	00000097          	auipc	ra,0x0
 3f0:	f5e080e7          	jalr	-162(ra) # 34a <write>
}
 3f4:	60e2                	ld	ra,24(sp)
 3f6:	6442                	ld	s0,16(sp)
 3f8:	6105                	addi	sp,sp,32
 3fa:	8082                	ret

00000000000003fc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3fc:	7139                	addi	sp,sp,-64
 3fe:	fc06                	sd	ra,56(sp)
 400:	f822                	sd	s0,48(sp)
 402:	f426                	sd	s1,40(sp)
 404:	f04a                	sd	s2,32(sp)
 406:	ec4e                	sd	s3,24(sp)
 408:	0080                	addi	s0,sp,64
 40a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 40c:	c299                	beqz	a3,412 <printint+0x16>
 40e:	0805c863          	bltz	a1,49e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 412:	2581                	sext.w	a1,a1
  neg = 0;
 414:	4881                	li	a7,0
 416:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 41a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 41c:	2601                	sext.w	a2,a2
 41e:	00000517          	auipc	a0,0x0
 422:	47250513          	addi	a0,a0,1138 # 890 <digits>
 426:	883a                	mv	a6,a4
 428:	2705                	addiw	a4,a4,1
 42a:	02c5f7bb          	remuw	a5,a1,a2
 42e:	1782                	slli	a5,a5,0x20
 430:	9381                	srli	a5,a5,0x20
 432:	97aa                	add	a5,a5,a0
 434:	0007c783          	lbu	a5,0(a5)
 438:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 43c:	0005879b          	sext.w	a5,a1
 440:	02c5d5bb          	divuw	a1,a1,a2
 444:	0685                	addi	a3,a3,1
 446:	fec7f0e3          	bgeu	a5,a2,426 <printint+0x2a>
  if(neg)
 44a:	00088b63          	beqz	a7,460 <printint+0x64>
    buf[i++] = '-';
 44e:	fd040793          	addi	a5,s0,-48
 452:	973e                	add	a4,a4,a5
 454:	02d00793          	li	a5,45
 458:	fef70823          	sb	a5,-16(a4)
 45c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 460:	02e05863          	blez	a4,490 <printint+0x94>
 464:	fc040793          	addi	a5,s0,-64
 468:	00e78933          	add	s2,a5,a4
 46c:	fff78993          	addi	s3,a5,-1
 470:	99ba                	add	s3,s3,a4
 472:	377d                	addiw	a4,a4,-1
 474:	1702                	slli	a4,a4,0x20
 476:	9301                	srli	a4,a4,0x20
 478:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 47c:	fff94583          	lbu	a1,-1(s2)
 480:	8526                	mv	a0,s1
 482:	00000097          	auipc	ra,0x0
 486:	f58080e7          	jalr	-168(ra) # 3da <putc>
  while(--i >= 0)
 48a:	197d                	addi	s2,s2,-1
 48c:	ff3918e3          	bne	s2,s3,47c <printint+0x80>
}
 490:	70e2                	ld	ra,56(sp)
 492:	7442                	ld	s0,48(sp)
 494:	74a2                	ld	s1,40(sp)
 496:	7902                	ld	s2,32(sp)
 498:	69e2                	ld	s3,24(sp)
 49a:	6121                	addi	sp,sp,64
 49c:	8082                	ret
    x = -xx;
 49e:	40b005bb          	negw	a1,a1
    neg = 1;
 4a2:	4885                	li	a7,1
    x = -xx;
 4a4:	bf8d                	j	416 <printint+0x1a>

00000000000004a6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4a6:	7119                	addi	sp,sp,-128
 4a8:	fc86                	sd	ra,120(sp)
 4aa:	f8a2                	sd	s0,112(sp)
 4ac:	f4a6                	sd	s1,104(sp)
 4ae:	f0ca                	sd	s2,96(sp)
 4b0:	ecce                	sd	s3,88(sp)
 4b2:	e8d2                	sd	s4,80(sp)
 4b4:	e4d6                	sd	s5,72(sp)
 4b6:	e0da                	sd	s6,64(sp)
 4b8:	fc5e                	sd	s7,56(sp)
 4ba:	f862                	sd	s8,48(sp)
 4bc:	f466                	sd	s9,40(sp)
 4be:	f06a                	sd	s10,32(sp)
 4c0:	ec6e                	sd	s11,24(sp)
 4c2:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4c4:	0005c903          	lbu	s2,0(a1)
 4c8:	18090f63          	beqz	s2,666 <vprintf+0x1c0>
 4cc:	8aaa                	mv	s5,a0
 4ce:	8b32                	mv	s6,a2
 4d0:	00158493          	addi	s1,a1,1
  state = 0;
 4d4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4d6:	02500a13          	li	s4,37
      if(c == 'd'){
 4da:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4de:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4e2:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4e6:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4ea:	00000b97          	auipc	s7,0x0
 4ee:	3a6b8b93          	addi	s7,s7,934 # 890 <digits>
 4f2:	a839                	j	510 <vprintf+0x6a>
        putc(fd, c);
 4f4:	85ca                	mv	a1,s2
 4f6:	8556                	mv	a0,s5
 4f8:	00000097          	auipc	ra,0x0
 4fc:	ee2080e7          	jalr	-286(ra) # 3da <putc>
 500:	a019                	j	506 <vprintf+0x60>
    } else if(state == '%'){
 502:	01498f63          	beq	s3,s4,520 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 506:	0485                	addi	s1,s1,1
 508:	fff4c903          	lbu	s2,-1(s1)
 50c:	14090d63          	beqz	s2,666 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 510:	0009079b          	sext.w	a5,s2
    if(state == 0){
 514:	fe0997e3          	bnez	s3,502 <vprintf+0x5c>
      if(c == '%'){
 518:	fd479ee3          	bne	a5,s4,4f4 <vprintf+0x4e>
        state = '%';
 51c:	89be                	mv	s3,a5
 51e:	b7e5                	j	506 <vprintf+0x60>
      if(c == 'd'){
 520:	05878063          	beq	a5,s8,560 <vprintf+0xba>
      } else if(c == 'l') {
 524:	05978c63          	beq	a5,s9,57c <vprintf+0xd6>
      } else if(c == 'x') {
 528:	07a78863          	beq	a5,s10,598 <vprintf+0xf2>
      } else if(c == 'p') {
 52c:	09b78463          	beq	a5,s11,5b4 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 530:	07300713          	li	a4,115
 534:	0ce78663          	beq	a5,a4,600 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 538:	06300713          	li	a4,99
 53c:	0ee78e63          	beq	a5,a4,638 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 540:	11478863          	beq	a5,s4,650 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 544:	85d2                	mv	a1,s4
 546:	8556                	mv	a0,s5
 548:	00000097          	auipc	ra,0x0
 54c:	e92080e7          	jalr	-366(ra) # 3da <putc>
        putc(fd, c);
 550:	85ca                	mv	a1,s2
 552:	8556                	mv	a0,s5
 554:	00000097          	auipc	ra,0x0
 558:	e86080e7          	jalr	-378(ra) # 3da <putc>
      }
      state = 0;
 55c:	4981                	li	s3,0
 55e:	b765                	j	506 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 560:	008b0913          	addi	s2,s6,8
 564:	4685                	li	a3,1
 566:	4629                	li	a2,10
 568:	000b2583          	lw	a1,0(s6)
 56c:	8556                	mv	a0,s5
 56e:	00000097          	auipc	ra,0x0
 572:	e8e080e7          	jalr	-370(ra) # 3fc <printint>
 576:	8b4a                	mv	s6,s2
      state = 0;
 578:	4981                	li	s3,0
 57a:	b771                	j	506 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 57c:	008b0913          	addi	s2,s6,8
 580:	4681                	li	a3,0
 582:	4629                	li	a2,10
 584:	000b2583          	lw	a1,0(s6)
 588:	8556                	mv	a0,s5
 58a:	00000097          	auipc	ra,0x0
 58e:	e72080e7          	jalr	-398(ra) # 3fc <printint>
 592:	8b4a                	mv	s6,s2
      state = 0;
 594:	4981                	li	s3,0
 596:	bf85                	j	506 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 598:	008b0913          	addi	s2,s6,8
 59c:	4681                	li	a3,0
 59e:	4641                	li	a2,16
 5a0:	000b2583          	lw	a1,0(s6)
 5a4:	8556                	mv	a0,s5
 5a6:	00000097          	auipc	ra,0x0
 5aa:	e56080e7          	jalr	-426(ra) # 3fc <printint>
 5ae:	8b4a                	mv	s6,s2
      state = 0;
 5b0:	4981                	li	s3,0
 5b2:	bf91                	j	506 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5b4:	008b0793          	addi	a5,s6,8
 5b8:	f8f43423          	sd	a5,-120(s0)
 5bc:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5c0:	03000593          	li	a1,48
 5c4:	8556                	mv	a0,s5
 5c6:	00000097          	auipc	ra,0x0
 5ca:	e14080e7          	jalr	-492(ra) # 3da <putc>
  putc(fd, 'x');
 5ce:	85ea                	mv	a1,s10
 5d0:	8556                	mv	a0,s5
 5d2:	00000097          	auipc	ra,0x0
 5d6:	e08080e7          	jalr	-504(ra) # 3da <putc>
 5da:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5dc:	03c9d793          	srli	a5,s3,0x3c
 5e0:	97de                	add	a5,a5,s7
 5e2:	0007c583          	lbu	a1,0(a5)
 5e6:	8556                	mv	a0,s5
 5e8:	00000097          	auipc	ra,0x0
 5ec:	df2080e7          	jalr	-526(ra) # 3da <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5f0:	0992                	slli	s3,s3,0x4
 5f2:	397d                	addiw	s2,s2,-1
 5f4:	fe0914e3          	bnez	s2,5dc <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5f8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5fc:	4981                	li	s3,0
 5fe:	b721                	j	506 <vprintf+0x60>
        s = va_arg(ap, char*);
 600:	008b0993          	addi	s3,s6,8
 604:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 608:	02090163          	beqz	s2,62a <vprintf+0x184>
        while(*s != 0){
 60c:	00094583          	lbu	a1,0(s2)
 610:	c9a1                	beqz	a1,660 <vprintf+0x1ba>
          putc(fd, *s);
 612:	8556                	mv	a0,s5
 614:	00000097          	auipc	ra,0x0
 618:	dc6080e7          	jalr	-570(ra) # 3da <putc>
          s++;
 61c:	0905                	addi	s2,s2,1
        while(*s != 0){
 61e:	00094583          	lbu	a1,0(s2)
 622:	f9e5                	bnez	a1,612 <vprintf+0x16c>
        s = va_arg(ap, char*);
 624:	8b4e                	mv	s6,s3
      state = 0;
 626:	4981                	li	s3,0
 628:	bdf9                	j	506 <vprintf+0x60>
          s = "(null)";
 62a:	00000917          	auipc	s2,0x0
 62e:	25e90913          	addi	s2,s2,606 # 888 <malloc+0x118>
        while(*s != 0){
 632:	02800593          	li	a1,40
 636:	bff1                	j	612 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 638:	008b0913          	addi	s2,s6,8
 63c:	000b4583          	lbu	a1,0(s6)
 640:	8556                	mv	a0,s5
 642:	00000097          	auipc	ra,0x0
 646:	d98080e7          	jalr	-616(ra) # 3da <putc>
 64a:	8b4a                	mv	s6,s2
      state = 0;
 64c:	4981                	li	s3,0
 64e:	bd65                	j	506 <vprintf+0x60>
        putc(fd, c);
 650:	85d2                	mv	a1,s4
 652:	8556                	mv	a0,s5
 654:	00000097          	auipc	ra,0x0
 658:	d86080e7          	jalr	-634(ra) # 3da <putc>
      state = 0;
 65c:	4981                	li	s3,0
 65e:	b565                	j	506 <vprintf+0x60>
        s = va_arg(ap, char*);
 660:	8b4e                	mv	s6,s3
      state = 0;
 662:	4981                	li	s3,0
 664:	b54d                	j	506 <vprintf+0x60>
    }
  }
}
 666:	70e6                	ld	ra,120(sp)
 668:	7446                	ld	s0,112(sp)
 66a:	74a6                	ld	s1,104(sp)
 66c:	7906                	ld	s2,96(sp)
 66e:	69e6                	ld	s3,88(sp)
 670:	6a46                	ld	s4,80(sp)
 672:	6aa6                	ld	s5,72(sp)
 674:	6b06                	ld	s6,64(sp)
 676:	7be2                	ld	s7,56(sp)
 678:	7c42                	ld	s8,48(sp)
 67a:	7ca2                	ld	s9,40(sp)
 67c:	7d02                	ld	s10,32(sp)
 67e:	6de2                	ld	s11,24(sp)
 680:	6109                	addi	sp,sp,128
 682:	8082                	ret

0000000000000684 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 684:	715d                	addi	sp,sp,-80
 686:	ec06                	sd	ra,24(sp)
 688:	e822                	sd	s0,16(sp)
 68a:	1000                	addi	s0,sp,32
 68c:	e010                	sd	a2,0(s0)
 68e:	e414                	sd	a3,8(s0)
 690:	e818                	sd	a4,16(s0)
 692:	ec1c                	sd	a5,24(s0)
 694:	03043023          	sd	a6,32(s0)
 698:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 69c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6a0:	8622                	mv	a2,s0
 6a2:	00000097          	auipc	ra,0x0
 6a6:	e04080e7          	jalr	-508(ra) # 4a6 <vprintf>
}
 6aa:	60e2                	ld	ra,24(sp)
 6ac:	6442                	ld	s0,16(sp)
 6ae:	6161                	addi	sp,sp,80
 6b0:	8082                	ret

00000000000006b2 <printf>:

void
printf(const char *fmt, ...)
{
 6b2:	711d                	addi	sp,sp,-96
 6b4:	ec06                	sd	ra,24(sp)
 6b6:	e822                	sd	s0,16(sp)
 6b8:	1000                	addi	s0,sp,32
 6ba:	e40c                	sd	a1,8(s0)
 6bc:	e810                	sd	a2,16(s0)
 6be:	ec14                	sd	a3,24(s0)
 6c0:	f018                	sd	a4,32(s0)
 6c2:	f41c                	sd	a5,40(s0)
 6c4:	03043823          	sd	a6,48(s0)
 6c8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6cc:	00840613          	addi	a2,s0,8
 6d0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6d4:	85aa                	mv	a1,a0
 6d6:	4505                	li	a0,1
 6d8:	00000097          	auipc	ra,0x0
 6dc:	dce080e7          	jalr	-562(ra) # 4a6 <vprintf>
}
 6e0:	60e2                	ld	ra,24(sp)
 6e2:	6442                	ld	s0,16(sp)
 6e4:	6125                	addi	sp,sp,96
 6e6:	8082                	ret

00000000000006e8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6e8:	1141                	addi	sp,sp,-16
 6ea:	e422                	sd	s0,8(sp)
 6ec:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6ee:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f2:	00000797          	auipc	a5,0x0
 6f6:	1b67b783          	ld	a5,438(a5) # 8a8 <freep>
 6fa:	a805                	j	72a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6fc:	4618                	lw	a4,8(a2)
 6fe:	9db9                	addw	a1,a1,a4
 700:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 704:	6398                	ld	a4,0(a5)
 706:	6318                	ld	a4,0(a4)
 708:	fee53823          	sd	a4,-16(a0)
 70c:	a091                	j	750 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 70e:	ff852703          	lw	a4,-8(a0)
 712:	9e39                	addw	a2,a2,a4
 714:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 716:	ff053703          	ld	a4,-16(a0)
 71a:	e398                	sd	a4,0(a5)
 71c:	a099                	j	762 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 71e:	6398                	ld	a4,0(a5)
 720:	00e7e463          	bltu	a5,a4,728 <free+0x40>
 724:	00e6ea63          	bltu	a3,a4,738 <free+0x50>
{
 728:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 72a:	fed7fae3          	bgeu	a5,a3,71e <free+0x36>
 72e:	6398                	ld	a4,0(a5)
 730:	00e6e463          	bltu	a3,a4,738 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 734:	fee7eae3          	bltu	a5,a4,728 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 738:	ff852583          	lw	a1,-8(a0)
 73c:	6390                	ld	a2,0(a5)
 73e:	02059813          	slli	a6,a1,0x20
 742:	01c85713          	srli	a4,a6,0x1c
 746:	9736                	add	a4,a4,a3
 748:	fae60ae3          	beq	a2,a4,6fc <free+0x14>
    bp->s.ptr = p->s.ptr;
 74c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 750:	4790                	lw	a2,8(a5)
 752:	02061593          	slli	a1,a2,0x20
 756:	01c5d713          	srli	a4,a1,0x1c
 75a:	973e                	add	a4,a4,a5
 75c:	fae689e3          	beq	a3,a4,70e <free+0x26>
  } else
    p->s.ptr = bp;
 760:	e394                	sd	a3,0(a5)
  freep = p;
 762:	00000717          	auipc	a4,0x0
 766:	14f73323          	sd	a5,326(a4) # 8a8 <freep>
}
 76a:	6422                	ld	s0,8(sp)
 76c:	0141                	addi	sp,sp,16
 76e:	8082                	ret

0000000000000770 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 770:	7139                	addi	sp,sp,-64
 772:	fc06                	sd	ra,56(sp)
 774:	f822                	sd	s0,48(sp)
 776:	f426                	sd	s1,40(sp)
 778:	f04a                	sd	s2,32(sp)
 77a:	ec4e                	sd	s3,24(sp)
 77c:	e852                	sd	s4,16(sp)
 77e:	e456                	sd	s5,8(sp)
 780:	e05a                	sd	s6,0(sp)
 782:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 784:	02051493          	slli	s1,a0,0x20
 788:	9081                	srli	s1,s1,0x20
 78a:	04bd                	addi	s1,s1,15
 78c:	8091                	srli	s1,s1,0x4
 78e:	0014899b          	addiw	s3,s1,1
 792:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 794:	00000517          	auipc	a0,0x0
 798:	11453503          	ld	a0,276(a0) # 8a8 <freep>
 79c:	c515                	beqz	a0,7c8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 79e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7a0:	4798                	lw	a4,8(a5)
 7a2:	02977f63          	bgeu	a4,s1,7e0 <malloc+0x70>
 7a6:	8a4e                	mv	s4,s3
 7a8:	0009871b          	sext.w	a4,s3
 7ac:	6685                	lui	a3,0x1
 7ae:	00d77363          	bgeu	a4,a3,7b4 <malloc+0x44>
 7b2:	6a05                	lui	s4,0x1
 7b4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7b8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7bc:	00000917          	auipc	s2,0x0
 7c0:	0ec90913          	addi	s2,s2,236 # 8a8 <freep>
  if(p == (char*)-1)
 7c4:	5afd                	li	s5,-1
 7c6:	a895                	j	83a <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7c8:	00000797          	auipc	a5,0x0
 7cc:	0e878793          	addi	a5,a5,232 # 8b0 <base>
 7d0:	00000717          	auipc	a4,0x0
 7d4:	0cf73c23          	sd	a5,216(a4) # 8a8 <freep>
 7d8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7da:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7de:	b7e1                	j	7a6 <malloc+0x36>
      if(p->s.size == nunits)
 7e0:	02e48c63          	beq	s1,a4,818 <malloc+0xa8>
        p->s.size -= nunits;
 7e4:	4137073b          	subw	a4,a4,s3
 7e8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7ea:	02071693          	slli	a3,a4,0x20
 7ee:	01c6d713          	srli	a4,a3,0x1c
 7f2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7f4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7f8:	00000717          	auipc	a4,0x0
 7fc:	0aa73823          	sd	a0,176(a4) # 8a8 <freep>
      return (void*)(p + 1);
 800:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 804:	70e2                	ld	ra,56(sp)
 806:	7442                	ld	s0,48(sp)
 808:	74a2                	ld	s1,40(sp)
 80a:	7902                	ld	s2,32(sp)
 80c:	69e2                	ld	s3,24(sp)
 80e:	6a42                	ld	s4,16(sp)
 810:	6aa2                	ld	s5,8(sp)
 812:	6b02                	ld	s6,0(sp)
 814:	6121                	addi	sp,sp,64
 816:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 818:	6398                	ld	a4,0(a5)
 81a:	e118                	sd	a4,0(a0)
 81c:	bff1                	j	7f8 <malloc+0x88>
  hp->s.size = nu;
 81e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 822:	0541                	addi	a0,a0,16
 824:	00000097          	auipc	ra,0x0
 828:	ec4080e7          	jalr	-316(ra) # 6e8 <free>
  return freep;
 82c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 830:	d971                	beqz	a0,804 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 832:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 834:	4798                	lw	a4,8(a5)
 836:	fa9775e3          	bgeu	a4,s1,7e0 <malloc+0x70>
    if(p == freep)
 83a:	00093703          	ld	a4,0(s2)
 83e:	853e                	mv	a0,a5
 840:	fef719e3          	bne	a4,a5,832 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 844:	8552                	mv	a0,s4
 846:	00000097          	auipc	ra,0x0
 84a:	b6c080e7          	jalr	-1172(ra) # 3b2 <sbrk>
  if(p == (char*)-1)
 84e:	fd5518e3          	bne	a0,s5,81e <malloc+0xae>
        return 0;
 852:	4501                	li	a0,0
 854:	bf45                	j	804 <malloc+0x94>
