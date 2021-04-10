
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	18010113          	addi	sp,sp,384 # 80009180 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	fee70713          	addi	a4,a4,-18 # 80009040 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	1ac78793          	addi	a5,a5,428 # 80006210 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dbe78793          	addi	a5,a5,-578 # 80000e6c <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  timerinit();
    800000d8:	00000097          	auipc	ra,0x0
    800000dc:	f44080e7          	jalr	-188(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000e0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000e4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000e6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e8:	30200073          	mret
}
    800000ec:	60a2                	ld	ra,8(sp)
    800000ee:	6402                	ld	s0,0(sp)
    800000f0:	0141                	addi	sp,sp,16
    800000f2:	8082                	ret

00000000800000f4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000f4:	715d                	addi	sp,sp,-80
    800000f6:	e486                	sd	ra,72(sp)
    800000f8:	e0a2                	sd	s0,64(sp)
    800000fa:	fc26                	sd	s1,56(sp)
    800000fc:	f84a                	sd	s2,48(sp)
    800000fe:	f44e                	sd	s3,40(sp)
    80000100:	f052                	sd	s4,32(sp)
    80000102:	ec56                	sd	s5,24(sp)
    80000104:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000106:	04c05663          	blez	a2,80000152 <consolewrite+0x5e>
    8000010a:	8a2a                	mv	s4,a0
    8000010c:	84ae                	mv	s1,a1
    8000010e:	89b2                	mv	s3,a2
    80000110:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000112:	5afd                	li	s5,-1
    80000114:	4685                	li	a3,1
    80000116:	8626                	mv	a2,s1
    80000118:	85d2                	mv	a1,s4
    8000011a:	fbf40513          	addi	a0,s0,-65
    8000011e:	00002097          	auipc	ra,0x2
    80000122:	512080e7          	jalr	1298(ra) # 80002630 <either_copyin>
    80000126:	01550c63          	beq	a0,s5,8000013e <consolewrite+0x4a>
      break;
    uartputc(c);
    8000012a:	fbf44503          	lbu	a0,-65(s0)
    8000012e:	00000097          	auipc	ra,0x0
    80000132:	77a080e7          	jalr	1914(ra) # 800008a8 <uartputc>
  for(i = 0; i < n; i++){
    80000136:	2905                	addiw	s2,s2,1
    80000138:	0485                	addi	s1,s1,1
    8000013a:	fd299de3          	bne	s3,s2,80000114 <consolewrite+0x20>
  }

  return i;
}
    8000013e:	854a                	mv	a0,s2
    80000140:	60a6                	ld	ra,72(sp)
    80000142:	6406                	ld	s0,64(sp)
    80000144:	74e2                	ld	s1,56(sp)
    80000146:	7942                	ld	s2,48(sp)
    80000148:	79a2                	ld	s3,40(sp)
    8000014a:	7a02                	ld	s4,32(sp)
    8000014c:	6ae2                	ld	s5,24(sp)
    8000014e:	6161                	addi	sp,sp,80
    80000150:	8082                	ret
  for(i = 0; i < n; i++){
    80000152:	4901                	li	s2,0
    80000154:	b7ed                	j	8000013e <consolewrite+0x4a>

0000000080000156 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000156:	7159                	addi	sp,sp,-112
    80000158:	f486                	sd	ra,104(sp)
    8000015a:	f0a2                	sd	s0,96(sp)
    8000015c:	eca6                	sd	s1,88(sp)
    8000015e:	e8ca                	sd	s2,80(sp)
    80000160:	e4ce                	sd	s3,72(sp)
    80000162:	e0d2                	sd	s4,64(sp)
    80000164:	fc56                	sd	s5,56(sp)
    80000166:	f85a                	sd	s6,48(sp)
    80000168:	f45e                	sd	s7,40(sp)
    8000016a:	f062                	sd	s8,32(sp)
    8000016c:	ec66                	sd	s9,24(sp)
    8000016e:	e86a                	sd	s10,16(sp)
    80000170:	1880                	addi	s0,sp,112
    80000172:	8aaa                	mv	s5,a0
    80000174:	8a2e                	mv	s4,a1
    80000176:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000178:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000017c:	00011517          	auipc	a0,0x11
    80000180:	00450513          	addi	a0,a0,4 # 80011180 <cons>
    80000184:	00001097          	auipc	ra,0x1
    80000188:	a3e080e7          	jalr	-1474(ra) # 80000bc2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000018c:	00011497          	auipc	s1,0x11
    80000190:	ff448493          	addi	s1,s1,-12 # 80011180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000194:	00011917          	auipc	s2,0x11
    80000198:	08490913          	addi	s2,s2,132 # 80011218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    8000019c:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000019e:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001a0:	4ca9                	li	s9,10
  while(n > 0){
    800001a2:	07305863          	blez	s3,80000212 <consoleread+0xbc>
    while(cons.r == cons.w){
    800001a6:	0984a783          	lw	a5,152(s1)
    800001aa:	09c4a703          	lw	a4,156(s1)
    800001ae:	02f71463          	bne	a4,a5,800001d6 <consoleread+0x80>
      if(myproc()->killed){
    800001b2:	00001097          	auipc	ra,0x1
    800001b6:	7e4080e7          	jalr	2020(ra) # 80001996 <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	004080e7          	jalr	4(ra) # 800021c6 <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef700e3          	beq	a4,a5,800001b2 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001d6:	0017871b          	addiw	a4,a5,1
    800001da:	08e4ac23          	sw	a4,152(s1)
    800001de:	07f7f713          	andi	a4,a5,127
    800001e2:	9726                	add	a4,a4,s1
    800001e4:	01874703          	lbu	a4,24(a4)
    800001e8:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001ec:	077d0563          	beq	s10,s7,80000256 <consoleread+0x100>
    cbuf = c;
    800001f0:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001f4:	4685                	li	a3,1
    800001f6:	f9f40613          	addi	a2,s0,-97
    800001fa:	85d2                	mv	a1,s4
    800001fc:	8556                	mv	a0,s5
    800001fe:	00002097          	auipc	ra,0x2
    80000202:	3dc080e7          	jalr	988(ra) # 800025da <either_copyout>
    80000206:	01850663          	beq	a0,s8,80000212 <consoleread+0xbc>
    dst++;
    8000020a:	0a05                	addi	s4,s4,1
    --n;
    8000020c:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    8000020e:	f99d1ae3          	bne	s10,s9,800001a2 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000212:	00011517          	auipc	a0,0x11
    80000216:	f6e50513          	addi	a0,a0,-146 # 80011180 <cons>
    8000021a:	00001097          	auipc	ra,0x1
    8000021e:	a5c080e7          	jalr	-1444(ra) # 80000c76 <release>

  return target - n;
    80000222:	413b053b          	subw	a0,s6,s3
    80000226:	a811                	j	8000023a <consoleread+0xe4>
        release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	f5850513          	addi	a0,a0,-168 # 80011180 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a46080e7          	jalr	-1466(ra) # 80000c76 <release>
        return -1;
    80000238:	557d                	li	a0,-1
}
    8000023a:	70a6                	ld	ra,104(sp)
    8000023c:	7406                	ld	s0,96(sp)
    8000023e:	64e6                	ld	s1,88(sp)
    80000240:	6946                	ld	s2,80(sp)
    80000242:	69a6                	ld	s3,72(sp)
    80000244:	6a06                	ld	s4,64(sp)
    80000246:	7ae2                	ld	s5,56(sp)
    80000248:	7b42                	ld	s6,48(sp)
    8000024a:	7ba2                	ld	s7,40(sp)
    8000024c:	7c02                	ld	s8,32(sp)
    8000024e:	6ce2                	ld	s9,24(sp)
    80000250:	6d42                	ld	s10,16(sp)
    80000252:	6165                	addi	sp,sp,112
    80000254:	8082                	ret
      if(n < target){
    80000256:	0009871b          	sext.w	a4,s3
    8000025a:	fb677ce3          	bgeu	a4,s6,80000212 <consoleread+0xbc>
        cons.r--;
    8000025e:	00011717          	auipc	a4,0x11
    80000262:	faf72d23          	sw	a5,-70(a4) # 80011218 <cons+0x98>
    80000266:	b775                	j	80000212 <consoleread+0xbc>

0000000080000268 <consputc>:
{
    80000268:	1141                	addi	sp,sp,-16
    8000026a:	e406                	sd	ra,8(sp)
    8000026c:	e022                	sd	s0,0(sp)
    8000026e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000270:	10000793          	li	a5,256
    80000274:	00f50a63          	beq	a0,a5,80000288 <consputc+0x20>
    uartputc_sync(c);
    80000278:	00000097          	auipc	ra,0x0
    8000027c:	55e080e7          	jalr	1374(ra) # 800007d6 <uartputc_sync>
}
    80000280:	60a2                	ld	ra,8(sp)
    80000282:	6402                	ld	s0,0(sp)
    80000284:	0141                	addi	sp,sp,16
    80000286:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000288:	4521                	li	a0,8
    8000028a:	00000097          	auipc	ra,0x0
    8000028e:	54c080e7          	jalr	1356(ra) # 800007d6 <uartputc_sync>
    80000292:	02000513          	li	a0,32
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	540080e7          	jalr	1344(ra) # 800007d6 <uartputc_sync>
    8000029e:	4521                	li	a0,8
    800002a0:	00000097          	auipc	ra,0x0
    800002a4:	536080e7          	jalr	1334(ra) # 800007d6 <uartputc_sync>
    800002a8:	bfe1                	j	80000280 <consputc+0x18>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	e04a                	sd	s2,0(sp)
    800002b4:	1000                	addi	s0,sp,32
    800002b6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b8:	00011517          	auipc	a0,0x11
    800002bc:	ec850513          	addi	a0,a0,-312 # 80011180 <cons>
    800002c0:	00001097          	auipc	ra,0x1
    800002c4:	902080e7          	jalr	-1790(ra) # 80000bc2 <acquire>

  switch(c){
    800002c8:	47d5                	li	a5,21
    800002ca:	0af48663          	beq	s1,a5,80000376 <consoleintr+0xcc>
    800002ce:	0297ca63          	blt	a5,s1,80000302 <consoleintr+0x58>
    800002d2:	47a1                	li	a5,8
    800002d4:	0ef48763          	beq	s1,a5,800003c2 <consoleintr+0x118>
    800002d8:	47c1                	li	a5,16
    800002da:	10f49a63          	bne	s1,a5,800003ee <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002de:	00002097          	auipc	ra,0x2
    800002e2:	3a8080e7          	jalr	936(ra) # 80002686 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002e6:	00011517          	auipc	a0,0x11
    800002ea:	e9a50513          	addi	a0,a0,-358 # 80011180 <cons>
    800002ee:	00001097          	auipc	ra,0x1
    800002f2:	988080e7          	jalr	-1656(ra) # 80000c76 <release>
}
    800002f6:	60e2                	ld	ra,24(sp)
    800002f8:	6442                	ld	s0,16(sp)
    800002fa:	64a2                	ld	s1,8(sp)
    800002fc:	6902                	ld	s2,0(sp)
    800002fe:	6105                	addi	sp,sp,32
    80000300:	8082                	ret
  switch(c){
    80000302:	07f00793          	li	a5,127
    80000306:	0af48e63          	beq	s1,a5,800003c2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000030a:	00011717          	auipc	a4,0x11
    8000030e:	e7670713          	addi	a4,a4,-394 # 80011180 <cons>
    80000312:	0a072783          	lw	a5,160(a4)
    80000316:	09872703          	lw	a4,152(a4)
    8000031a:	9f99                	subw	a5,a5,a4
    8000031c:	07f00713          	li	a4,127
    80000320:	fcf763e3          	bltu	a4,a5,800002e6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000324:	47b5                	li	a5,13
    80000326:	0cf48763          	beq	s1,a5,800003f4 <consoleintr+0x14a>
      consputc(c);
    8000032a:	8526                	mv	a0,s1
    8000032c:	00000097          	auipc	ra,0x0
    80000330:	f3c080e7          	jalr	-196(ra) # 80000268 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000334:	00011797          	auipc	a5,0x11
    80000338:	e4c78793          	addi	a5,a5,-436 # 80011180 <cons>
    8000033c:	0a07a703          	lw	a4,160(a5)
    80000340:	0017069b          	addiw	a3,a4,1
    80000344:	0006861b          	sext.w	a2,a3
    80000348:	0ad7a023          	sw	a3,160(a5)
    8000034c:	07f77713          	andi	a4,a4,127
    80000350:	97ba                	add	a5,a5,a4
    80000352:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000356:	47a9                	li	a5,10
    80000358:	0cf48563          	beq	s1,a5,80000422 <consoleintr+0x178>
    8000035c:	4791                	li	a5,4
    8000035e:	0cf48263          	beq	s1,a5,80000422 <consoleintr+0x178>
    80000362:	00011797          	auipc	a5,0x11
    80000366:	eb67a783          	lw	a5,-330(a5) # 80011218 <cons+0x98>
    8000036a:	0807879b          	addiw	a5,a5,128
    8000036e:	f6f61ce3          	bne	a2,a5,800002e6 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000372:	863e                	mv	a2,a5
    80000374:	a07d                	j	80000422 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000376:	00011717          	auipc	a4,0x11
    8000037a:	e0a70713          	addi	a4,a4,-502 # 80011180 <cons>
    8000037e:	0a072783          	lw	a5,160(a4)
    80000382:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000386:	00011497          	auipc	s1,0x11
    8000038a:	dfa48493          	addi	s1,s1,-518 # 80011180 <cons>
    while(cons.e != cons.w &&
    8000038e:	4929                	li	s2,10
    80000390:	f4f70be3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000394:	37fd                	addiw	a5,a5,-1
    80000396:	07f7f713          	andi	a4,a5,127
    8000039a:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000039c:	01874703          	lbu	a4,24(a4)
    800003a0:	f52703e3          	beq	a4,s2,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003a4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003a8:	10000513          	li	a0,256
    800003ac:	00000097          	auipc	ra,0x0
    800003b0:	ebc080e7          	jalr	-324(ra) # 80000268 <consputc>
    while(cons.e != cons.w &&
    800003b4:	0a04a783          	lw	a5,160(s1)
    800003b8:	09c4a703          	lw	a4,156(s1)
    800003bc:	fcf71ce3          	bne	a4,a5,80000394 <consoleintr+0xea>
    800003c0:	b71d                	j	800002e6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003c2:	00011717          	auipc	a4,0x11
    800003c6:	dbe70713          	addi	a4,a4,-578 # 80011180 <cons>
    800003ca:	0a072783          	lw	a5,160(a4)
    800003ce:	09c72703          	lw	a4,156(a4)
    800003d2:	f0f70ae3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003d6:	37fd                	addiw	a5,a5,-1
    800003d8:	00011717          	auipc	a4,0x11
    800003dc:	e4f72423          	sw	a5,-440(a4) # 80011220 <cons+0xa0>
      consputc(BACKSPACE);
    800003e0:	10000513          	li	a0,256
    800003e4:	00000097          	auipc	ra,0x0
    800003e8:	e84080e7          	jalr	-380(ra) # 80000268 <consputc>
    800003ec:	bded                	j	800002e6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003ee:	ee048ce3          	beqz	s1,800002e6 <consoleintr+0x3c>
    800003f2:	bf21                	j	8000030a <consoleintr+0x60>
      consputc(c);
    800003f4:	4529                	li	a0,10
    800003f6:	00000097          	auipc	ra,0x0
    800003fa:	e72080e7          	jalr	-398(ra) # 80000268 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003fe:	00011797          	auipc	a5,0x11
    80000402:	d8278793          	addi	a5,a5,-638 # 80011180 <cons>
    80000406:	0a07a703          	lw	a4,160(a5)
    8000040a:	0017069b          	addiw	a3,a4,1
    8000040e:	0006861b          	sext.w	a2,a3
    80000412:	0ad7a023          	sw	a3,160(a5)
    80000416:	07f77713          	andi	a4,a4,127
    8000041a:	97ba                	add	a5,a5,a4
    8000041c:	4729                	li	a4,10
    8000041e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000422:	00011797          	auipc	a5,0x11
    80000426:	dec7ad23          	sw	a2,-518(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    8000042a:	00011517          	auipc	a0,0x11
    8000042e:	dee50513          	addi	a0,a0,-530 # 80011218 <cons+0x98>
    80000432:	00002097          	auipc	ra,0x2
    80000436:	f20080e7          	jalr	-224(ra) # 80002352 <wakeup>
    8000043a:	b575                	j	800002e6 <consoleintr+0x3c>

000000008000043c <consoleinit>:

void
consoleinit(void)
{
    8000043c:	1141                	addi	sp,sp,-16
    8000043e:	e406                	sd	ra,8(sp)
    80000440:	e022                	sd	s0,0(sp)
    80000442:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000444:	00008597          	auipc	a1,0x8
    80000448:	bcc58593          	addi	a1,a1,-1076 # 80008010 <etext+0x10>
    8000044c:	00011517          	auipc	a0,0x11
    80000450:	d3450513          	addi	a0,a0,-716 # 80011180 <cons>
    80000454:	00000097          	auipc	ra,0x0
    80000458:	6de080e7          	jalr	1758(ra) # 80000b32 <initlock>

  uartinit();
    8000045c:	00000097          	auipc	ra,0x0
    80000460:	32a080e7          	jalr	810(ra) # 80000786 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000464:	00021797          	auipc	a5,0x21
    80000468:	6cc78793          	addi	a5,a5,1740 # 80021b30 <devsw>
    8000046c:	00000717          	auipc	a4,0x0
    80000470:	cea70713          	addi	a4,a4,-790 # 80000156 <consoleread>
    80000474:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000476:	00000717          	auipc	a4,0x0
    8000047a:	c7e70713          	addi	a4,a4,-898 # 800000f4 <consolewrite>
    8000047e:	ef98                	sd	a4,24(a5)
}
    80000480:	60a2                	ld	ra,8(sp)
    80000482:	6402                	ld	s0,0(sp)
    80000484:	0141                	addi	sp,sp,16
    80000486:	8082                	ret

0000000080000488 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000488:	7179                	addi	sp,sp,-48
    8000048a:	f406                	sd	ra,40(sp)
    8000048c:	f022                	sd	s0,32(sp)
    8000048e:	ec26                	sd	s1,24(sp)
    80000490:	e84a                	sd	s2,16(sp)
    80000492:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80000494:	c219                	beqz	a2,8000049a <printint+0x12>
    80000496:	08054663          	bltz	a0,80000522 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    8000049a:	2501                	sext.w	a0,a0
    8000049c:	4881                	li	a7,0
    8000049e:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004a2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004a4:	2581                	sext.w	a1,a1
    800004a6:	00008617          	auipc	a2,0x8
    800004aa:	b9a60613          	addi	a2,a2,-1126 # 80008040 <digits>
    800004ae:	883a                	mv	a6,a4
    800004b0:	2705                	addiw	a4,a4,1
    800004b2:	02b577bb          	remuw	a5,a0,a1
    800004b6:	1782                	slli	a5,a5,0x20
    800004b8:	9381                	srli	a5,a5,0x20
    800004ba:	97b2                	add	a5,a5,a2
    800004bc:	0007c783          	lbu	a5,0(a5)
    800004c0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004c4:	0005079b          	sext.w	a5,a0
    800004c8:	02b5553b          	divuw	a0,a0,a1
    800004cc:	0685                	addi	a3,a3,1
    800004ce:	feb7f0e3          	bgeu	a5,a1,800004ae <printint+0x26>

  if(sign)
    800004d2:	00088b63          	beqz	a7,800004e8 <printint+0x60>
    buf[i++] = '-';
    800004d6:	fe040793          	addi	a5,s0,-32
    800004da:	973e                	add	a4,a4,a5
    800004dc:	02d00793          	li	a5,45
    800004e0:	fef70823          	sb	a5,-16(a4)
    800004e4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004e8:	02e05763          	blez	a4,80000516 <printint+0x8e>
    800004ec:	fd040793          	addi	a5,s0,-48
    800004f0:	00e784b3          	add	s1,a5,a4
    800004f4:	fff78913          	addi	s2,a5,-1
    800004f8:	993a                	add	s2,s2,a4
    800004fa:	377d                	addiw	a4,a4,-1
    800004fc:	1702                	slli	a4,a4,0x20
    800004fe:	9301                	srli	a4,a4,0x20
    80000500:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000504:	fff4c503          	lbu	a0,-1(s1)
    80000508:	00000097          	auipc	ra,0x0
    8000050c:	d60080e7          	jalr	-672(ra) # 80000268 <consputc>
  while(--i >= 0)
    80000510:	14fd                	addi	s1,s1,-1
    80000512:	ff2499e3          	bne	s1,s2,80000504 <printint+0x7c>
}
    80000516:	70a2                	ld	ra,40(sp)
    80000518:	7402                	ld	s0,32(sp)
    8000051a:	64e2                	ld	s1,24(sp)
    8000051c:	6942                	ld	s2,16(sp)
    8000051e:	6145                	addi	sp,sp,48
    80000520:	8082                	ret
    x = -xx;
    80000522:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000526:	4885                	li	a7,1
    x = -xx;
    80000528:	bf9d                	j	8000049e <printint+0x16>

000000008000052a <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000052a:	1101                	addi	sp,sp,-32
    8000052c:	ec06                	sd	ra,24(sp)
    8000052e:	e822                	sd	s0,16(sp)
    80000530:	e426                	sd	s1,8(sp)
    80000532:	1000                	addi	s0,sp,32
    80000534:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000536:	00011797          	auipc	a5,0x11
    8000053a:	d007a523          	sw	zero,-758(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    8000053e:	00008517          	auipc	a0,0x8
    80000542:	ada50513          	addi	a0,a0,-1318 # 80008018 <etext+0x18>
    80000546:	00000097          	auipc	ra,0x0
    8000054a:	02e080e7          	jalr	46(ra) # 80000574 <printf>
  printf(s);
    8000054e:	8526                	mv	a0,s1
    80000550:	00000097          	auipc	ra,0x0
    80000554:	024080e7          	jalr	36(ra) # 80000574 <printf>
  printf("\n");
    80000558:	00008517          	auipc	a0,0x8
    8000055c:	b7050513          	addi	a0,a0,-1168 # 800080c8 <digits+0x88>
    80000560:	00000097          	auipc	ra,0x0
    80000564:	014080e7          	jalr	20(ra) # 80000574 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000568:	4785                	li	a5,1
    8000056a:	00009717          	auipc	a4,0x9
    8000056e:	a8f72b23          	sw	a5,-1386(a4) # 80009000 <panicked>
  for(;;)
    80000572:	a001                	j	80000572 <panic+0x48>

0000000080000574 <printf>:
{
    80000574:	7131                	addi	sp,sp,-192
    80000576:	fc86                	sd	ra,120(sp)
    80000578:	f8a2                	sd	s0,112(sp)
    8000057a:	f4a6                	sd	s1,104(sp)
    8000057c:	f0ca                	sd	s2,96(sp)
    8000057e:	ecce                	sd	s3,88(sp)
    80000580:	e8d2                	sd	s4,80(sp)
    80000582:	e4d6                	sd	s5,72(sp)
    80000584:	e0da                	sd	s6,64(sp)
    80000586:	fc5e                	sd	s7,56(sp)
    80000588:	f862                	sd	s8,48(sp)
    8000058a:	f466                	sd	s9,40(sp)
    8000058c:	f06a                	sd	s10,32(sp)
    8000058e:	ec6e                	sd	s11,24(sp)
    80000590:	0100                	addi	s0,sp,128
    80000592:	8a2a                	mv	s4,a0
    80000594:	e40c                	sd	a1,8(s0)
    80000596:	e810                	sd	a2,16(s0)
    80000598:	ec14                	sd	a3,24(s0)
    8000059a:	f018                	sd	a4,32(s0)
    8000059c:	f41c                	sd	a5,40(s0)
    8000059e:	03043823          	sd	a6,48(s0)
    800005a2:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005a6:	00011d97          	auipc	s11,0x11
    800005aa:	c9adad83          	lw	s11,-870(s11) # 80011240 <pr+0x18>
  if(locking)
    800005ae:	020d9b63          	bnez	s11,800005e4 <printf+0x70>
  if (fmt == 0)
    800005b2:	040a0263          	beqz	s4,800005f6 <printf+0x82>
  va_start(ap, fmt);
    800005b6:	00840793          	addi	a5,s0,8
    800005ba:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005be:	000a4503          	lbu	a0,0(s4)
    800005c2:	14050f63          	beqz	a0,80000720 <printf+0x1ac>
    800005c6:	4981                	li	s3,0
    if(c != '%'){
    800005c8:	02500a93          	li	s5,37
    switch(c){
    800005cc:	07000b93          	li	s7,112
  consputc('x');
    800005d0:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005d2:	00008b17          	auipc	s6,0x8
    800005d6:	a6eb0b13          	addi	s6,s6,-1426 # 80008040 <digits>
    switch(c){
    800005da:	07300c93          	li	s9,115
    800005de:	06400c13          	li	s8,100
    800005e2:	a82d                	j	8000061c <printf+0xa8>
    acquire(&pr.lock);
    800005e4:	00011517          	auipc	a0,0x11
    800005e8:	c4450513          	addi	a0,a0,-956 # 80011228 <pr>
    800005ec:	00000097          	auipc	ra,0x0
    800005f0:	5d6080e7          	jalr	1494(ra) # 80000bc2 <acquire>
    800005f4:	bf7d                	j	800005b2 <printf+0x3e>
    panic("null fmt");
    800005f6:	00008517          	auipc	a0,0x8
    800005fa:	a3250513          	addi	a0,a0,-1486 # 80008028 <etext+0x28>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	f2c080e7          	jalr	-212(ra) # 8000052a <panic>
      consputc(c);
    80000606:	00000097          	auipc	ra,0x0
    8000060a:	c62080e7          	jalr	-926(ra) # 80000268 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000060e:	2985                	addiw	s3,s3,1
    80000610:	013a07b3          	add	a5,s4,s3
    80000614:	0007c503          	lbu	a0,0(a5)
    80000618:	10050463          	beqz	a0,80000720 <printf+0x1ac>
    if(c != '%'){
    8000061c:	ff5515e3          	bne	a0,s5,80000606 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000620:	2985                	addiw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c783          	lbu	a5,0(a5)
    8000062a:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000062e:	cbed                	beqz	a5,80000720 <printf+0x1ac>
    switch(c){
    80000630:	05778a63          	beq	a5,s7,80000684 <printf+0x110>
    80000634:	02fbf663          	bgeu	s7,a5,80000660 <printf+0xec>
    80000638:	09978863          	beq	a5,s9,800006c8 <printf+0x154>
    8000063c:	07800713          	li	a4,120
    80000640:	0ce79563          	bne	a5,a4,8000070a <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	85ea                	mv	a1,s10
    80000654:	4388                	lw	a0,0(a5)
    80000656:	00000097          	auipc	ra,0x0
    8000065a:	e32080e7          	jalr	-462(ra) # 80000488 <printint>
      break;
    8000065e:	bf45                	j	8000060e <printf+0x9a>
    switch(c){
    80000660:	09578f63          	beq	a5,s5,800006fe <printf+0x18a>
    80000664:	0b879363          	bne	a5,s8,8000070a <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000668:	f8843783          	ld	a5,-120(s0)
    8000066c:	00878713          	addi	a4,a5,8
    80000670:	f8e43423          	sd	a4,-120(s0)
    80000674:	4605                	li	a2,1
    80000676:	45a9                	li	a1,10
    80000678:	4388                	lw	a0,0(a5)
    8000067a:	00000097          	auipc	ra,0x0
    8000067e:	e0e080e7          	jalr	-498(ra) # 80000488 <printint>
      break;
    80000682:	b771                	j	8000060e <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000684:	f8843783          	ld	a5,-120(s0)
    80000688:	00878713          	addi	a4,a5,8
    8000068c:	f8e43423          	sd	a4,-120(s0)
    80000690:	0007b903          	ld	s2,0(a5)
  consputc('0');
    80000694:	03000513          	li	a0,48
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	bd0080e7          	jalr	-1072(ra) # 80000268 <consputc>
  consputc('x');
    800006a0:	07800513          	li	a0,120
    800006a4:	00000097          	auipc	ra,0x0
    800006a8:	bc4080e7          	jalr	-1084(ra) # 80000268 <consputc>
    800006ac:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ae:	03c95793          	srli	a5,s2,0x3c
    800006b2:	97da                	add	a5,a5,s6
    800006b4:	0007c503          	lbu	a0,0(a5)
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bb0080e7          	jalr	-1104(ra) # 80000268 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006c0:	0912                	slli	s2,s2,0x4
    800006c2:	34fd                	addiw	s1,s1,-1
    800006c4:	f4ed                	bnez	s1,800006ae <printf+0x13a>
    800006c6:	b7a1                	j	8000060e <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006c8:	f8843783          	ld	a5,-120(s0)
    800006cc:	00878713          	addi	a4,a5,8
    800006d0:	f8e43423          	sd	a4,-120(s0)
    800006d4:	6384                	ld	s1,0(a5)
    800006d6:	cc89                	beqz	s1,800006f0 <printf+0x17c>
      for(; *s; s++)
    800006d8:	0004c503          	lbu	a0,0(s1)
    800006dc:	d90d                	beqz	a0,8000060e <printf+0x9a>
        consputc(*s);
    800006de:	00000097          	auipc	ra,0x0
    800006e2:	b8a080e7          	jalr	-1142(ra) # 80000268 <consputc>
      for(; *s; s++)
    800006e6:	0485                	addi	s1,s1,1
    800006e8:	0004c503          	lbu	a0,0(s1)
    800006ec:	f96d                	bnez	a0,800006de <printf+0x16a>
    800006ee:	b705                	j	8000060e <printf+0x9a>
        s = "(null)";
    800006f0:	00008497          	auipc	s1,0x8
    800006f4:	93048493          	addi	s1,s1,-1744 # 80008020 <etext+0x20>
      for(; *s; s++)
    800006f8:	02800513          	li	a0,40
    800006fc:	b7cd                	j	800006de <printf+0x16a>
      consputc('%');
    800006fe:	8556                	mv	a0,s5
    80000700:	00000097          	auipc	ra,0x0
    80000704:	b68080e7          	jalr	-1176(ra) # 80000268 <consputc>
      break;
    80000708:	b719                	j	8000060e <printf+0x9a>
      consputc('%');
    8000070a:	8556                	mv	a0,s5
    8000070c:	00000097          	auipc	ra,0x0
    80000710:	b5c080e7          	jalr	-1188(ra) # 80000268 <consputc>
      consputc(c);
    80000714:	8526                	mv	a0,s1
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b52080e7          	jalr	-1198(ra) # 80000268 <consputc>
      break;
    8000071e:	bdc5                	j	8000060e <printf+0x9a>
  if(locking)
    80000720:	020d9163          	bnez	s11,80000742 <printf+0x1ce>
}
    80000724:	70e6                	ld	ra,120(sp)
    80000726:	7446                	ld	s0,112(sp)
    80000728:	74a6                	ld	s1,104(sp)
    8000072a:	7906                	ld	s2,96(sp)
    8000072c:	69e6                	ld	s3,88(sp)
    8000072e:	6a46                	ld	s4,80(sp)
    80000730:	6aa6                	ld	s5,72(sp)
    80000732:	6b06                	ld	s6,64(sp)
    80000734:	7be2                	ld	s7,56(sp)
    80000736:	7c42                	ld	s8,48(sp)
    80000738:	7ca2                	ld	s9,40(sp)
    8000073a:	7d02                	ld	s10,32(sp)
    8000073c:	6de2                	ld	s11,24(sp)
    8000073e:	6129                	addi	sp,sp,192
    80000740:	8082                	ret
    release(&pr.lock);
    80000742:	00011517          	auipc	a0,0x11
    80000746:	ae650513          	addi	a0,a0,-1306 # 80011228 <pr>
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	52c080e7          	jalr	1324(ra) # 80000c76 <release>
}
    80000752:	bfc9                	j	80000724 <printf+0x1b0>

0000000080000754 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000754:	1101                	addi	sp,sp,-32
    80000756:	ec06                	sd	ra,24(sp)
    80000758:	e822                	sd	s0,16(sp)
    8000075a:	e426                	sd	s1,8(sp)
    8000075c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000075e:	00011497          	auipc	s1,0x11
    80000762:	aca48493          	addi	s1,s1,-1334 # 80011228 <pr>
    80000766:	00008597          	auipc	a1,0x8
    8000076a:	8d258593          	addi	a1,a1,-1838 # 80008038 <etext+0x38>
    8000076e:	8526                	mv	a0,s1
    80000770:	00000097          	auipc	ra,0x0
    80000774:	3c2080e7          	jalr	962(ra) # 80000b32 <initlock>
  pr.locking = 1;
    80000778:	4785                	li	a5,1
    8000077a:	cc9c                	sw	a5,24(s1)
}
    8000077c:	60e2                	ld	ra,24(sp)
    8000077e:	6442                	ld	s0,16(sp)
    80000780:	64a2                	ld	s1,8(sp)
    80000782:	6105                	addi	sp,sp,32
    80000784:	8082                	ret

0000000080000786 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000786:	1141                	addi	sp,sp,-16
    80000788:	e406                	sd	ra,8(sp)
    8000078a:	e022                	sd	s0,0(sp)
    8000078c:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000078e:	100007b7          	lui	a5,0x10000
    80000792:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000796:	f8000713          	li	a4,-128
    8000079a:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000079e:	470d                	li	a4,3
    800007a0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007a4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007a8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007ac:	469d                	li	a3,7
    800007ae:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007b2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007b6:	00008597          	auipc	a1,0x8
    800007ba:	8a258593          	addi	a1,a1,-1886 # 80008058 <digits+0x18>
    800007be:	00011517          	auipc	a0,0x11
    800007c2:	a8a50513          	addi	a0,a0,-1398 # 80011248 <uart_tx_lock>
    800007c6:	00000097          	auipc	ra,0x0
    800007ca:	36c080e7          	jalr	876(ra) # 80000b32 <initlock>
}
    800007ce:	60a2                	ld	ra,8(sp)
    800007d0:	6402                	ld	s0,0(sp)
    800007d2:	0141                	addi	sp,sp,16
    800007d4:	8082                	ret

00000000800007d6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007d6:	1101                	addi	sp,sp,-32
    800007d8:	ec06                	sd	ra,24(sp)
    800007da:	e822                	sd	s0,16(sp)
    800007dc:	e426                	sd	s1,8(sp)
    800007de:	1000                	addi	s0,sp,32
    800007e0:	84aa                	mv	s1,a0
  push_off();
    800007e2:	00000097          	auipc	ra,0x0
    800007e6:	394080e7          	jalr	916(ra) # 80000b76 <push_off>

  if(panicked){
    800007ea:	00009797          	auipc	a5,0x9
    800007ee:	8167a783          	lw	a5,-2026(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007f2:	10000737          	lui	a4,0x10000
  if(panicked){
    800007f6:	c391                	beqz	a5,800007fa <uartputc_sync+0x24>
    for(;;)
    800007f8:	a001                	j	800007f8 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007fa:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800007fe:	0207f793          	andi	a5,a5,32
    80000802:	dfe5                	beqz	a5,800007fa <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000804:	0ff4f513          	andi	a0,s1,255
    80000808:	100007b7          	lui	a5,0x10000
    8000080c:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000810:	00000097          	auipc	ra,0x0
    80000814:	406080e7          	jalr	1030(ra) # 80000c16 <pop_off>
}
    80000818:	60e2                	ld	ra,24(sp)
    8000081a:	6442                	ld	s0,16(sp)
    8000081c:	64a2                	ld	s1,8(sp)
    8000081e:	6105                	addi	sp,sp,32
    80000820:	8082                	ret

0000000080000822 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000822:	00008797          	auipc	a5,0x8
    80000826:	7e67b783          	ld	a5,2022(a5) # 80009008 <uart_tx_r>
    8000082a:	00008717          	auipc	a4,0x8
    8000082e:	7e673703          	ld	a4,2022(a4) # 80009010 <uart_tx_w>
    80000832:	06f70a63          	beq	a4,a5,800008a6 <uartstart+0x84>
{
    80000836:	7139                	addi	sp,sp,-64
    80000838:	fc06                	sd	ra,56(sp)
    8000083a:	f822                	sd	s0,48(sp)
    8000083c:	f426                	sd	s1,40(sp)
    8000083e:	f04a                	sd	s2,32(sp)
    80000840:	ec4e                	sd	s3,24(sp)
    80000842:	e852                	sd	s4,16(sp)
    80000844:	e456                	sd	s5,8(sp)
    80000846:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000848:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000084c:	00011a17          	auipc	s4,0x11
    80000850:	9fca0a13          	addi	s4,s4,-1540 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    80000854:	00008497          	auipc	s1,0x8
    80000858:	7b448493          	addi	s1,s1,1972 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000085c:	00008997          	auipc	s3,0x8
    80000860:	7b498993          	addi	s3,s3,1972 # 80009010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000864:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000868:	02077713          	andi	a4,a4,32
    8000086c:	c705                	beqz	a4,80000894 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000086e:	01f7f713          	andi	a4,a5,31
    80000872:	9752                	add	a4,a4,s4
    80000874:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80000878:	0785                	addi	a5,a5,1
    8000087a:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000087c:	8526                	mv	a0,s1
    8000087e:	00002097          	auipc	ra,0x2
    80000882:	ad4080e7          	jalr	-1324(ra) # 80002352 <wakeup>
    
    WriteReg(THR, c);
    80000886:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000088a:	609c                	ld	a5,0(s1)
    8000088c:	0009b703          	ld	a4,0(s3)
    80000890:	fcf71ae3          	bne	a4,a5,80000864 <uartstart+0x42>
  }
}
    80000894:	70e2                	ld	ra,56(sp)
    80000896:	7442                	ld	s0,48(sp)
    80000898:	74a2                	ld	s1,40(sp)
    8000089a:	7902                	ld	s2,32(sp)
    8000089c:	69e2                	ld	s3,24(sp)
    8000089e:	6a42                	ld	s4,16(sp)
    800008a0:	6aa2                	ld	s5,8(sp)
    800008a2:	6121                	addi	sp,sp,64
    800008a4:	8082                	ret
    800008a6:	8082                	ret

00000000800008a8 <uartputc>:
{
    800008a8:	7179                	addi	sp,sp,-48
    800008aa:	f406                	sd	ra,40(sp)
    800008ac:	f022                	sd	s0,32(sp)
    800008ae:	ec26                	sd	s1,24(sp)
    800008b0:	e84a                	sd	s2,16(sp)
    800008b2:	e44e                	sd	s3,8(sp)
    800008b4:	e052                	sd	s4,0(sp)
    800008b6:	1800                	addi	s0,sp,48
    800008b8:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ba:	00011517          	auipc	a0,0x11
    800008be:	98e50513          	addi	a0,a0,-1650 # 80011248 <uart_tx_lock>
    800008c2:	00000097          	auipc	ra,0x0
    800008c6:	300080e7          	jalr	768(ra) # 80000bc2 <acquire>
  if(panicked){
    800008ca:	00008797          	auipc	a5,0x8
    800008ce:	7367a783          	lw	a5,1846(a5) # 80009000 <panicked>
    800008d2:	c391                	beqz	a5,800008d6 <uartputc+0x2e>
    for(;;)
    800008d4:	a001                	j	800008d4 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008d6:	00008717          	auipc	a4,0x8
    800008da:	73a73703          	ld	a4,1850(a4) # 80009010 <uart_tx_w>
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	72a7b783          	ld	a5,1834(a5) # 80009008 <uart_tx_r>
    800008e6:	02078793          	addi	a5,a5,32
    800008ea:	02e79b63          	bne	a5,a4,80000920 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008ee:	00011997          	auipc	s3,0x11
    800008f2:	95a98993          	addi	s3,s3,-1702 # 80011248 <uart_tx_lock>
    800008f6:	00008497          	auipc	s1,0x8
    800008fa:	71248493          	addi	s1,s1,1810 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fe:	00008917          	auipc	s2,0x8
    80000902:	71290913          	addi	s2,s2,1810 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000906:	85ce                	mv	a1,s3
    80000908:	8526                	mv	a0,s1
    8000090a:	00002097          	auipc	ra,0x2
    8000090e:	8bc080e7          	jalr	-1860(ra) # 800021c6 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000912:	00093703          	ld	a4,0(s2)
    80000916:	609c                	ld	a5,0(s1)
    80000918:	02078793          	addi	a5,a5,32
    8000091c:	fee785e3          	beq	a5,a4,80000906 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000920:	00011497          	auipc	s1,0x11
    80000924:	92848493          	addi	s1,s1,-1752 # 80011248 <uart_tx_lock>
    80000928:	01f77793          	andi	a5,a4,31
    8000092c:	97a6                	add	a5,a5,s1
    8000092e:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000932:	0705                	addi	a4,a4,1
    80000934:	00008797          	auipc	a5,0x8
    80000938:	6ce7be23          	sd	a4,1756(a5) # 80009010 <uart_tx_w>
      uartstart();
    8000093c:	00000097          	auipc	ra,0x0
    80000940:	ee6080e7          	jalr	-282(ra) # 80000822 <uartstart>
      release(&uart_tx_lock);
    80000944:	8526                	mv	a0,s1
    80000946:	00000097          	auipc	ra,0x0
    8000094a:	330080e7          	jalr	816(ra) # 80000c76 <release>
}
    8000094e:	70a2                	ld	ra,40(sp)
    80000950:	7402                	ld	s0,32(sp)
    80000952:	64e2                	ld	s1,24(sp)
    80000954:	6942                	ld	s2,16(sp)
    80000956:	69a2                	ld	s3,8(sp)
    80000958:	6a02                	ld	s4,0(sp)
    8000095a:	6145                	addi	sp,sp,48
    8000095c:	8082                	ret

000000008000095e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000095e:	1141                	addi	sp,sp,-16
    80000960:	e422                	sd	s0,8(sp)
    80000962:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000964:	100007b7          	lui	a5,0x10000
    80000968:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000096c:	8b85                	andi	a5,a5,1
    8000096e:	cb91                	beqz	a5,80000982 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000970:	100007b7          	lui	a5,0x10000
    80000974:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000978:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000097c:	6422                	ld	s0,8(sp)
    8000097e:	0141                	addi	sp,sp,16
    80000980:	8082                	ret
    return -1;
    80000982:	557d                	li	a0,-1
    80000984:	bfe5                	j	8000097c <uartgetc+0x1e>

0000000080000986 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000986:	1101                	addi	sp,sp,-32
    80000988:	ec06                	sd	ra,24(sp)
    8000098a:	e822                	sd	s0,16(sp)
    8000098c:	e426                	sd	s1,8(sp)
    8000098e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000990:	54fd                	li	s1,-1
    80000992:	a029                	j	8000099c <uartintr+0x16>
      break;
    consoleintr(c);
    80000994:	00000097          	auipc	ra,0x0
    80000998:	916080e7          	jalr	-1770(ra) # 800002aa <consoleintr>
    int c = uartgetc();
    8000099c:	00000097          	auipc	ra,0x0
    800009a0:	fc2080e7          	jalr	-62(ra) # 8000095e <uartgetc>
    if(c == -1)
    800009a4:	fe9518e3          	bne	a0,s1,80000994 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009a8:	00011497          	auipc	s1,0x11
    800009ac:	8a048493          	addi	s1,s1,-1888 # 80011248 <uart_tx_lock>
    800009b0:	8526                	mv	a0,s1
    800009b2:	00000097          	auipc	ra,0x0
    800009b6:	210080e7          	jalr	528(ra) # 80000bc2 <acquire>
  uartstart();
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	e68080e7          	jalr	-408(ra) # 80000822 <uartstart>
  release(&uart_tx_lock);
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	2b2080e7          	jalr	690(ra) # 80000c76 <release>
}
    800009cc:	60e2                	ld	ra,24(sp)
    800009ce:	6442                	ld	s0,16(sp)
    800009d0:	64a2                	ld	s1,8(sp)
    800009d2:	6105                	addi	sp,sp,32
    800009d4:	8082                	ret

00000000800009d6 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009d6:	1101                	addi	sp,sp,-32
    800009d8:	ec06                	sd	ra,24(sp)
    800009da:	e822                	sd	s0,16(sp)
    800009dc:	e426                	sd	s1,8(sp)
    800009de:	e04a                	sd	s2,0(sp)
    800009e0:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009e2:	03451793          	slli	a5,a0,0x34
    800009e6:	ebb9                	bnez	a5,80000a3c <kfree+0x66>
    800009e8:	84aa                	mv	s1,a0
    800009ea:	00025797          	auipc	a5,0x25
    800009ee:	61678793          	addi	a5,a5,1558 # 80026000 <end>
    800009f2:	04f56563          	bltu	a0,a5,80000a3c <kfree+0x66>
    800009f6:	47c5                	li	a5,17
    800009f8:	07ee                	slli	a5,a5,0x1b
    800009fa:	04f57163          	bgeu	a0,a5,80000a3c <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800009fe:	6605                	lui	a2,0x1
    80000a00:	4585                	li	a1,1
    80000a02:	00000097          	auipc	ra,0x0
    80000a06:	2bc080e7          	jalr	700(ra) # 80000cbe <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a0a:	00011917          	auipc	s2,0x11
    80000a0e:	87690913          	addi	s2,s2,-1930 # 80011280 <kmem>
    80000a12:	854a                	mv	a0,s2
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	1ae080e7          	jalr	430(ra) # 80000bc2 <acquire>
  r->next = kmem.freelist;
    80000a1c:	01893783          	ld	a5,24(s2)
    80000a20:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a22:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	24e080e7          	jalr	590(ra) # 80000c76 <release>
}
    80000a30:	60e2                	ld	ra,24(sp)
    80000a32:	6442                	ld	s0,16(sp)
    80000a34:	64a2                	ld	s1,8(sp)
    80000a36:	6902                	ld	s2,0(sp)
    80000a38:	6105                	addi	sp,sp,32
    80000a3a:	8082                	ret
    panic("kfree");
    80000a3c:	00007517          	auipc	a0,0x7
    80000a40:	62450513          	addi	a0,a0,1572 # 80008060 <digits+0x20>
    80000a44:	00000097          	auipc	ra,0x0
    80000a48:	ae6080e7          	jalr	-1306(ra) # 8000052a <panic>

0000000080000a4c <freerange>:
{
    80000a4c:	7179                	addi	sp,sp,-48
    80000a4e:	f406                	sd	ra,40(sp)
    80000a50:	f022                	sd	s0,32(sp)
    80000a52:	ec26                	sd	s1,24(sp)
    80000a54:	e84a                	sd	s2,16(sp)
    80000a56:	e44e                	sd	s3,8(sp)
    80000a58:	e052                	sd	s4,0(sp)
    80000a5a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a5c:	6785                	lui	a5,0x1
    80000a5e:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a62:	94aa                	add	s1,s1,a0
    80000a64:	757d                	lui	a0,0xfffff
    80000a66:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a68:	94be                	add	s1,s1,a5
    80000a6a:	0095ee63          	bltu	a1,s1,80000a86 <freerange+0x3a>
    80000a6e:	892e                	mv	s2,a1
    kfree(p);
    80000a70:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a72:	6985                	lui	s3,0x1
    kfree(p);
    80000a74:	01448533          	add	a0,s1,s4
    80000a78:	00000097          	auipc	ra,0x0
    80000a7c:	f5e080e7          	jalr	-162(ra) # 800009d6 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a80:	94ce                	add	s1,s1,s3
    80000a82:	fe9979e3          	bgeu	s2,s1,80000a74 <freerange+0x28>
}
    80000a86:	70a2                	ld	ra,40(sp)
    80000a88:	7402                	ld	s0,32(sp)
    80000a8a:	64e2                	ld	s1,24(sp)
    80000a8c:	6942                	ld	s2,16(sp)
    80000a8e:	69a2                	ld	s3,8(sp)
    80000a90:	6a02                	ld	s4,0(sp)
    80000a92:	6145                	addi	sp,sp,48
    80000a94:	8082                	ret

0000000080000a96 <kinit>:
{
    80000a96:	1141                	addi	sp,sp,-16
    80000a98:	e406                	sd	ra,8(sp)
    80000a9a:	e022                	sd	s0,0(sp)
    80000a9c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a9e:	00007597          	auipc	a1,0x7
    80000aa2:	5ca58593          	addi	a1,a1,1482 # 80008068 <digits+0x28>
    80000aa6:	00010517          	auipc	a0,0x10
    80000aaa:	7da50513          	addi	a0,a0,2010 # 80011280 <kmem>
    80000aae:	00000097          	auipc	ra,0x0
    80000ab2:	084080e7          	jalr	132(ra) # 80000b32 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ab6:	45c5                	li	a1,17
    80000ab8:	05ee                	slli	a1,a1,0x1b
    80000aba:	00025517          	auipc	a0,0x25
    80000abe:	54650513          	addi	a0,a0,1350 # 80026000 <end>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	f8a080e7          	jalr	-118(ra) # 80000a4c <freerange>
}
    80000aca:	60a2                	ld	ra,8(sp)
    80000acc:	6402                	ld	s0,0(sp)
    80000ace:	0141                	addi	sp,sp,16
    80000ad0:	8082                	ret

0000000080000ad2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ad2:	1101                	addi	sp,sp,-32
    80000ad4:	ec06                	sd	ra,24(sp)
    80000ad6:	e822                	sd	s0,16(sp)
    80000ad8:	e426                	sd	s1,8(sp)
    80000ada:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000adc:	00010497          	auipc	s1,0x10
    80000ae0:	7a448493          	addi	s1,s1,1956 # 80011280 <kmem>
    80000ae4:	8526                	mv	a0,s1
    80000ae6:	00000097          	auipc	ra,0x0
    80000aea:	0dc080e7          	jalr	220(ra) # 80000bc2 <acquire>
  r = kmem.freelist;
    80000aee:	6c84                	ld	s1,24(s1)
  if(r)
    80000af0:	c885                	beqz	s1,80000b20 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000af2:	609c                	ld	a5,0(s1)
    80000af4:	00010517          	auipc	a0,0x10
    80000af8:	78c50513          	addi	a0,a0,1932 # 80011280 <kmem>
    80000afc:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	178080e7          	jalr	376(ra) # 80000c76 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b06:	6605                	lui	a2,0x1
    80000b08:	4595                	li	a1,5
    80000b0a:	8526                	mv	a0,s1
    80000b0c:	00000097          	auipc	ra,0x0
    80000b10:	1b2080e7          	jalr	434(ra) # 80000cbe <memset>
  return (void*)r;
}
    80000b14:	8526                	mv	a0,s1
    80000b16:	60e2                	ld	ra,24(sp)
    80000b18:	6442                	ld	s0,16(sp)
    80000b1a:	64a2                	ld	s1,8(sp)
    80000b1c:	6105                	addi	sp,sp,32
    80000b1e:	8082                	ret
  release(&kmem.lock);
    80000b20:	00010517          	auipc	a0,0x10
    80000b24:	76050513          	addi	a0,a0,1888 # 80011280 <kmem>
    80000b28:	00000097          	auipc	ra,0x0
    80000b2c:	14e080e7          	jalr	334(ra) # 80000c76 <release>
  if(r)
    80000b30:	b7d5                	j	80000b14 <kalloc+0x42>

0000000080000b32 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b32:	1141                	addi	sp,sp,-16
    80000b34:	e422                	sd	s0,8(sp)
    80000b36:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b38:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b3a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b3e:	00053823          	sd	zero,16(a0)
}
    80000b42:	6422                	ld	s0,8(sp)
    80000b44:	0141                	addi	sp,sp,16
    80000b46:	8082                	ret

0000000080000b48 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b48:	411c                	lw	a5,0(a0)
    80000b4a:	e399                	bnez	a5,80000b50 <holding+0x8>
    80000b4c:	4501                	li	a0,0
  return r;
}
    80000b4e:	8082                	ret
{
    80000b50:	1101                	addi	sp,sp,-32
    80000b52:	ec06                	sd	ra,24(sp)
    80000b54:	e822                	sd	s0,16(sp)
    80000b56:	e426                	sd	s1,8(sp)
    80000b58:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b5a:	6904                	ld	s1,16(a0)
    80000b5c:	00001097          	auipc	ra,0x1
    80000b60:	e1e080e7          	jalr	-482(ra) # 8000197a <mycpu>
    80000b64:	40a48533          	sub	a0,s1,a0
    80000b68:	00153513          	seqz	a0,a0
}
    80000b6c:	60e2                	ld	ra,24(sp)
    80000b6e:	6442                	ld	s0,16(sp)
    80000b70:	64a2                	ld	s1,8(sp)
    80000b72:	6105                	addi	sp,sp,32
    80000b74:	8082                	ret

0000000080000b76 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b76:	1101                	addi	sp,sp,-32
    80000b78:	ec06                	sd	ra,24(sp)
    80000b7a:	e822                	sd	s0,16(sp)
    80000b7c:	e426                	sd	s1,8(sp)
    80000b7e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b80:	100024f3          	csrr	s1,sstatus
    80000b84:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b88:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b8a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b8e:	00001097          	auipc	ra,0x1
    80000b92:	dec080e7          	jalr	-532(ra) # 8000197a <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	de0080e7          	jalr	-544(ra) # 8000197a <mycpu>
    80000ba2:	5d3c                	lw	a5,120(a0)
    80000ba4:	2785                	addiw	a5,a5,1
    80000ba6:	dd3c                	sw	a5,120(a0)
}
    80000ba8:	60e2                	ld	ra,24(sp)
    80000baa:	6442                	ld	s0,16(sp)
    80000bac:	64a2                	ld	s1,8(sp)
    80000bae:	6105                	addi	sp,sp,32
    80000bb0:	8082                	ret
    mycpu()->intena = old;
    80000bb2:	00001097          	auipc	ra,0x1
    80000bb6:	dc8080e7          	jalr	-568(ra) # 8000197a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bba:	8085                	srli	s1,s1,0x1
    80000bbc:	8885                	andi	s1,s1,1
    80000bbe:	dd64                	sw	s1,124(a0)
    80000bc0:	bfe9                	j	80000b9a <push_off+0x24>

0000000080000bc2 <acquire>:
{
    80000bc2:	1101                	addi	sp,sp,-32
    80000bc4:	ec06                	sd	ra,24(sp)
    80000bc6:	e822                	sd	s0,16(sp)
    80000bc8:	e426                	sd	s1,8(sp)
    80000bca:	1000                	addi	s0,sp,32
    80000bcc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bce:	00000097          	auipc	ra,0x0
    80000bd2:	fa8080e7          	jalr	-88(ra) # 80000b76 <push_off>
  if(holding(lk))
    80000bd6:	8526                	mv	a0,s1
    80000bd8:	00000097          	auipc	ra,0x0
    80000bdc:	f70080e7          	jalr	-144(ra) # 80000b48 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be0:	4705                	li	a4,1
  if(holding(lk))
    80000be2:	e115                	bnez	a0,80000c06 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	87ba                	mv	a5,a4
    80000be6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bea:	2781                	sext.w	a5,a5
    80000bec:	ffe5                	bnez	a5,80000be4 <acquire+0x22>
  __sync_synchronize();
    80000bee:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bf2:	00001097          	auipc	ra,0x1
    80000bf6:	d88080e7          	jalr	-632(ra) # 8000197a <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00007517          	auipc	a0,0x7
    80000c0a:	46a50513          	addi	a0,a0,1130 # 80008070 <digits+0x30>
    80000c0e:	00000097          	auipc	ra,0x0
    80000c12:	91c080e7          	jalr	-1764(ra) # 8000052a <panic>

0000000080000c16 <pop_off>:

void
pop_off(void)
{
    80000c16:	1141                	addi	sp,sp,-16
    80000c18:	e406                	sd	ra,8(sp)
    80000c1a:	e022                	sd	s0,0(sp)
    80000c1c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1e:	00001097          	auipc	ra,0x1
    80000c22:	d5c080e7          	jalr	-676(ra) # 8000197a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c26:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c2a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c2c:	e78d                	bnez	a5,80000c56 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c2e:	5d3c                	lw	a5,120(a0)
    80000c30:	02f05b63          	blez	a5,80000c66 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c34:	37fd                	addiw	a5,a5,-1
    80000c36:	0007871b          	sext.w	a4,a5
    80000c3a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c3c:	eb09                	bnez	a4,80000c4e <pop_off+0x38>
    80000c3e:	5d7c                	lw	a5,124(a0)
    80000c40:	c799                	beqz	a5,80000c4e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c42:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c46:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c4a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c4e:	60a2                	ld	ra,8(sp)
    80000c50:	6402                	ld	s0,0(sp)
    80000c52:	0141                	addi	sp,sp,16
    80000c54:	8082                	ret
    panic("pop_off - interruptible");
    80000c56:	00007517          	auipc	a0,0x7
    80000c5a:	42250513          	addi	a0,a0,1058 # 80008078 <digits+0x38>
    80000c5e:	00000097          	auipc	ra,0x0
    80000c62:	8cc080e7          	jalr	-1844(ra) # 8000052a <panic>
    panic("pop_off");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	42a50513          	addi	a0,a0,1066 # 80008090 <digits+0x50>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8bc080e7          	jalr	-1860(ra) # 8000052a <panic>

0000000080000c76 <release>:
{
    80000c76:	1101                	addi	sp,sp,-32
    80000c78:	ec06                	sd	ra,24(sp)
    80000c7a:	e822                	sd	s0,16(sp)
    80000c7c:	e426                	sd	s1,8(sp)
    80000c7e:	1000                	addi	s0,sp,32
    80000c80:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	ec6080e7          	jalr	-314(ra) # 80000b48 <holding>
    80000c8a:	c115                	beqz	a0,80000cae <release+0x38>
  lk->cpu = 0;
    80000c8c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c90:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c94:	0f50000f          	fence	iorw,ow
    80000c98:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c9c:	00000097          	auipc	ra,0x0
    80000ca0:	f7a080e7          	jalr	-134(ra) # 80000c16 <pop_off>
}
    80000ca4:	60e2                	ld	ra,24(sp)
    80000ca6:	6442                	ld	s0,16(sp)
    80000ca8:	64a2                	ld	s1,8(sp)
    80000caa:	6105                	addi	sp,sp,32
    80000cac:	8082                	ret
    panic("release");
    80000cae:	00007517          	auipc	a0,0x7
    80000cb2:	3ea50513          	addi	a0,a0,1002 # 80008098 <digits+0x58>
    80000cb6:	00000097          	auipc	ra,0x0
    80000cba:	874080e7          	jalr	-1932(ra) # 8000052a <panic>

0000000080000cbe <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cbe:	1141                	addi	sp,sp,-16
    80000cc0:	e422                	sd	s0,8(sp)
    80000cc2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cc4:	ca19                	beqz	a2,80000cda <memset+0x1c>
    80000cc6:	87aa                	mv	a5,a0
    80000cc8:	1602                	slli	a2,a2,0x20
    80000cca:	9201                	srli	a2,a2,0x20
    80000ccc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cd0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cd4:	0785                	addi	a5,a5,1
    80000cd6:	fee79de3          	bne	a5,a4,80000cd0 <memset+0x12>
  }
  return dst;
}
    80000cda:	6422                	ld	s0,8(sp)
    80000cdc:	0141                	addi	sp,sp,16
    80000cde:	8082                	ret

0000000080000ce0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000ce0:	1141                	addi	sp,sp,-16
    80000ce2:	e422                	sd	s0,8(sp)
    80000ce4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000ce6:	ca05                	beqz	a2,80000d16 <memcmp+0x36>
    80000ce8:	fff6069b          	addiw	a3,a2,-1
    80000cec:	1682                	slli	a3,a3,0x20
    80000cee:	9281                	srli	a3,a3,0x20
    80000cf0:	0685                	addi	a3,a3,1
    80000cf2:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cf4:	00054783          	lbu	a5,0(a0)
    80000cf8:	0005c703          	lbu	a4,0(a1)
    80000cfc:	00e79863          	bne	a5,a4,80000d0c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d00:	0505                	addi	a0,a0,1
    80000d02:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d04:	fed518e3          	bne	a0,a3,80000cf4 <memcmp+0x14>
  }

  return 0;
    80000d08:	4501                	li	a0,0
    80000d0a:	a019                	j	80000d10 <memcmp+0x30>
      return *s1 - *s2;
    80000d0c:	40e7853b          	subw	a0,a5,a4
}
    80000d10:	6422                	ld	s0,8(sp)
    80000d12:	0141                	addi	sp,sp,16
    80000d14:	8082                	ret
  return 0;
    80000d16:	4501                	li	a0,0
    80000d18:	bfe5                	j	80000d10 <memcmp+0x30>

0000000080000d1a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d1a:	1141                	addi	sp,sp,-16
    80000d1c:	e422                	sd	s0,8(sp)
    80000d1e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d20:	02a5e563          	bltu	a1,a0,80000d4a <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d24:	fff6069b          	addiw	a3,a2,-1
    80000d28:	ce11                	beqz	a2,80000d44 <memmove+0x2a>
    80000d2a:	1682                	slli	a3,a3,0x20
    80000d2c:	9281                	srli	a3,a3,0x20
    80000d2e:	0685                	addi	a3,a3,1
    80000d30:	96ae                	add	a3,a3,a1
    80000d32:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d34:	0585                	addi	a1,a1,1
    80000d36:	0785                	addi	a5,a5,1
    80000d38:	fff5c703          	lbu	a4,-1(a1)
    80000d3c:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000d40:	fed59ae3          	bne	a1,a3,80000d34 <memmove+0x1a>

  return dst;
}
    80000d44:	6422                	ld	s0,8(sp)
    80000d46:	0141                	addi	sp,sp,16
    80000d48:	8082                	ret
  if(s < d && s + n > d){
    80000d4a:	02061713          	slli	a4,a2,0x20
    80000d4e:	9301                	srli	a4,a4,0x20
    80000d50:	00e587b3          	add	a5,a1,a4
    80000d54:	fcf578e3          	bgeu	a0,a5,80000d24 <memmove+0xa>
    d += n;
    80000d58:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000d5a:	fff6069b          	addiw	a3,a2,-1
    80000d5e:	d27d                	beqz	a2,80000d44 <memmove+0x2a>
    80000d60:	02069613          	slli	a2,a3,0x20
    80000d64:	9201                	srli	a2,a2,0x20
    80000d66:	fff64613          	not	a2,a2
    80000d6a:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000d6c:	17fd                	addi	a5,a5,-1
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	0007c683          	lbu	a3,0(a5)
    80000d74:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000d78:	fef61ae3          	bne	a2,a5,80000d6c <memmove+0x52>
    80000d7c:	b7e1                	j	80000d44 <memmove+0x2a>

0000000080000d7e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d7e:	1141                	addi	sp,sp,-16
    80000d80:	e406                	sd	ra,8(sp)
    80000d82:	e022                	sd	s0,0(sp)
    80000d84:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d86:	00000097          	auipc	ra,0x0
    80000d8a:	f94080e7          	jalr	-108(ra) # 80000d1a <memmove>
}
    80000d8e:	60a2                	ld	ra,8(sp)
    80000d90:	6402                	ld	s0,0(sp)
    80000d92:	0141                	addi	sp,sp,16
    80000d94:	8082                	ret

0000000080000d96 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d96:	1141                	addi	sp,sp,-16
    80000d98:	e422                	sd	s0,8(sp)
    80000d9a:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9c:	ce11                	beqz	a2,80000db8 <strncmp+0x22>
    80000d9e:	00054783          	lbu	a5,0(a0)
    80000da2:	cf89                	beqz	a5,80000dbc <strncmp+0x26>
    80000da4:	0005c703          	lbu	a4,0(a1)
    80000da8:	00f71a63          	bne	a4,a5,80000dbc <strncmp+0x26>
    n--, p++, q++;
    80000dac:	367d                	addiw	a2,a2,-1
    80000dae:	0505                	addi	a0,a0,1
    80000db0:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db2:	f675                	bnez	a2,80000d9e <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db4:	4501                	li	a0,0
    80000db6:	a809                	j	80000dc8 <strncmp+0x32>
    80000db8:	4501                	li	a0,0
    80000dba:	a039                	j	80000dc8 <strncmp+0x32>
  if(n == 0)
    80000dbc:	ca09                	beqz	a2,80000dce <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dbe:	00054503          	lbu	a0,0(a0)
    80000dc2:	0005c783          	lbu	a5,0(a1)
    80000dc6:	9d1d                	subw	a0,a0,a5
}
    80000dc8:	6422                	ld	s0,8(sp)
    80000dca:	0141                	addi	sp,sp,16
    80000dcc:	8082                	ret
    return 0;
    80000dce:	4501                	li	a0,0
    80000dd0:	bfe5                	j	80000dc8 <strncmp+0x32>

0000000080000dd2 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dd2:	1141                	addi	sp,sp,-16
    80000dd4:	e422                	sd	s0,8(sp)
    80000dd6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd8:	872a                	mv	a4,a0
    80000dda:	8832                	mv	a6,a2
    80000ddc:	367d                	addiw	a2,a2,-1
    80000dde:	01005963          	blez	a6,80000df0 <strncpy+0x1e>
    80000de2:	0705                	addi	a4,a4,1
    80000de4:	0005c783          	lbu	a5,0(a1)
    80000de8:	fef70fa3          	sb	a5,-1(a4)
    80000dec:	0585                	addi	a1,a1,1
    80000dee:	f7f5                	bnez	a5,80000dda <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df0:	86ba                	mv	a3,a4
    80000df2:	00c05c63          	blez	a2,80000e0a <strncpy+0x38>
    *s++ = 0;
    80000df6:	0685                	addi	a3,a3,1
    80000df8:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000dfc:	fff6c793          	not	a5,a3
    80000e00:	9fb9                	addw	a5,a5,a4
    80000e02:	010787bb          	addw	a5,a5,a6
    80000e06:	fef048e3          	bgtz	a5,80000df6 <strncpy+0x24>
  return os;
}
    80000e0a:	6422                	ld	s0,8(sp)
    80000e0c:	0141                	addi	sp,sp,16
    80000e0e:	8082                	ret

0000000080000e10 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e10:	1141                	addi	sp,sp,-16
    80000e12:	e422                	sd	s0,8(sp)
    80000e14:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e16:	02c05363          	blez	a2,80000e3c <safestrcpy+0x2c>
    80000e1a:	fff6069b          	addiw	a3,a2,-1
    80000e1e:	1682                	slli	a3,a3,0x20
    80000e20:	9281                	srli	a3,a3,0x20
    80000e22:	96ae                	add	a3,a3,a1
    80000e24:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e26:	00d58963          	beq	a1,a3,80000e38 <safestrcpy+0x28>
    80000e2a:	0585                	addi	a1,a1,1
    80000e2c:	0785                	addi	a5,a5,1
    80000e2e:	fff5c703          	lbu	a4,-1(a1)
    80000e32:	fee78fa3          	sb	a4,-1(a5)
    80000e36:	fb65                	bnez	a4,80000e26 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e38:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e3c:	6422                	ld	s0,8(sp)
    80000e3e:	0141                	addi	sp,sp,16
    80000e40:	8082                	ret

0000000080000e42 <strlen>:

int
strlen(const char *s)
{
    80000e42:	1141                	addi	sp,sp,-16
    80000e44:	e422                	sd	s0,8(sp)
    80000e46:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e48:	00054783          	lbu	a5,0(a0)
    80000e4c:	cf91                	beqz	a5,80000e68 <strlen+0x26>
    80000e4e:	0505                	addi	a0,a0,1
    80000e50:	87aa                	mv	a5,a0
    80000e52:	4685                	li	a3,1
    80000e54:	9e89                	subw	a3,a3,a0
    80000e56:	00f6853b          	addw	a0,a3,a5
    80000e5a:	0785                	addi	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	fb7d                	bnez	a4,80000e56 <strlen+0x14>
    ;
  return n;
}
    80000e62:	6422                	ld	s0,8(sp)
    80000e64:	0141                	addi	sp,sp,16
    80000e66:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e68:	4501                	li	a0,0
    80000e6a:	bfe5                	j	80000e62 <strlen+0x20>

0000000080000e6c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e6c:	1141                	addi	sp,sp,-16
    80000e6e:	e406                	sd	ra,8(sp)
    80000e70:	e022                	sd	s0,0(sp)
    80000e72:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e74:	00001097          	auipc	ra,0x1
    80000e78:	af6080e7          	jalr	-1290(ra) # 8000196a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e7c:	00008717          	auipc	a4,0x8
    80000e80:	19c70713          	addi	a4,a4,412 # 80009018 <started>
  if(cpuid() == 0){
    80000e84:	c139                	beqz	a0,80000eca <main+0x5e>
    while(started == 0)
    80000e86:	431c                	lw	a5,0(a4)
    80000e88:	2781                	sext.w	a5,a5
    80000e8a:	dff5                	beqz	a5,80000e86 <main+0x1a>
      ;
    __sync_synchronize();
    80000e8c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e90:	00001097          	auipc	ra,0x1
    80000e94:	ada080e7          	jalr	-1318(ra) # 8000196a <cpuid>
    80000e98:	85aa                	mv	a1,a0
    80000e9a:	00007517          	auipc	a0,0x7
    80000e9e:	21e50513          	addi	a0,a0,542 # 800080b8 <digits+0x78>
    80000ea2:	fffff097          	auipc	ra,0xfffff
    80000ea6:	6d2080e7          	jalr	1746(ra) # 80000574 <printf>
    kvminithart();    // turn on paging
    80000eaa:	00000097          	auipc	ra,0x0
    80000eae:	0d8080e7          	jalr	216(ra) # 80000f82 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb2:	00002097          	auipc	ra,0x2
    80000eb6:	c7c080e7          	jalr	-900(ra) # 80002b2e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00005097          	auipc	ra,0x5
    80000ebe:	396080e7          	jalr	918(ra) # 80006250 <plicinithart>
  }

  scheduler();        
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	07c080e7          	jalr	124(ra) # 80001f3e <scheduler>
    consoleinit();
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	572080e7          	jalr	1394(ra) # 8000043c <consoleinit>
    printfinit();
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	882080e7          	jalr	-1918(ra) # 80000754 <printfinit>
    printf("\n");
    80000eda:	00007517          	auipc	a0,0x7
    80000ede:	1ee50513          	addi	a0,a0,494 # 800080c8 <digits+0x88>
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	692080e7          	jalr	1682(ra) # 80000574 <printf>
    printf("xv6 kernel is booting\n");
    80000eea:	00007517          	auipc	a0,0x7
    80000eee:	1b650513          	addi	a0,a0,438 # 800080a0 <digits+0x60>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	682080e7          	jalr	1666(ra) # 80000574 <printf>
    printf("\n");
    80000efa:	00007517          	auipc	a0,0x7
    80000efe:	1ce50513          	addi	a0,a0,462 # 800080c8 <digits+0x88>
    80000f02:	fffff097          	auipc	ra,0xfffff
    80000f06:	672080e7          	jalr	1650(ra) # 80000574 <printf>
    kinit();         // physical page allocator
    80000f0a:	00000097          	auipc	ra,0x0
    80000f0e:	b8c080e7          	jalr	-1140(ra) # 80000a96 <kinit>
    kvminit();       // create kernel page table
    80000f12:	00000097          	auipc	ra,0x0
    80000f16:	310080e7          	jalr	784(ra) # 80001222 <kvminit>
    kvminithart();   // turn on paging
    80000f1a:	00000097          	auipc	ra,0x0
    80000f1e:	068080e7          	jalr	104(ra) # 80000f82 <kvminithart>
    procinit();      // process table
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	980080e7          	jalr	-1664(ra) # 800018a2 <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	bdc080e7          	jalr	-1060(ra) # 80002b06 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	bfc080e7          	jalr	-1028(ra) # 80002b2e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00005097          	auipc	ra,0x5
    80000f3e:	300080e7          	jalr	768(ra) # 8000623a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00005097          	auipc	ra,0x5
    80000f46:	30e080e7          	jalr	782(ra) # 80006250 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00002097          	auipc	ra,0x2
    80000f4e:	4d8080e7          	jalr	1240(ra) # 80003422 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	b6a080e7          	jalr	-1174(ra) # 80003abc <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	b18080e7          	jalr	-1256(ra) # 80004a72 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	410080e7          	jalr	1040(ra) # 80006372 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	d28080e7          	jalr	-728(ra) # 80001c92 <userinit>
    __sync_synchronize();
    80000f72:	0ff0000f          	fence
    started = 1;
    80000f76:	4785                	li	a5,1
    80000f78:	00008717          	auipc	a4,0x8
    80000f7c:	0af72023          	sw	a5,160(a4) # 80009018 <started>
    80000f80:	b789                	j	80000ec2 <main+0x56>

0000000080000f82 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f82:	1141                	addi	sp,sp,-16
    80000f84:	e422                	sd	s0,8(sp)
    80000f86:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f88:	00008797          	auipc	a5,0x8
    80000f8c:	0987b783          	ld	a5,152(a5) # 80009020 <kernel_pagetable>
    80000f90:	83b1                	srli	a5,a5,0xc
    80000f92:	577d                	li	a4,-1
    80000f94:	177e                	slli	a4,a4,0x3f
    80000f96:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f98:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f9c:	12000073          	sfence.vma
  sfence_vma();
}
    80000fa0:	6422                	ld	s0,8(sp)
    80000fa2:	0141                	addi	sp,sp,16
    80000fa4:	8082                	ret

0000000080000fa6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fa6:	7139                	addi	sp,sp,-64
    80000fa8:	fc06                	sd	ra,56(sp)
    80000faa:	f822                	sd	s0,48(sp)
    80000fac:	f426                	sd	s1,40(sp)
    80000fae:	f04a                	sd	s2,32(sp)
    80000fb0:	ec4e                	sd	s3,24(sp)
    80000fb2:	e852                	sd	s4,16(sp)
    80000fb4:	e456                	sd	s5,8(sp)
    80000fb6:	e05a                	sd	s6,0(sp)
    80000fb8:	0080                	addi	s0,sp,64
    80000fba:	84aa                	mv	s1,a0
    80000fbc:	89ae                	mv	s3,a1
    80000fbe:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fc0:	57fd                	li	a5,-1
    80000fc2:	83e9                	srli	a5,a5,0x1a
    80000fc4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fc6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fc8:	04b7f263          	bgeu	a5,a1,8000100c <walk+0x66>
    panic("walk");
    80000fcc:	00007517          	auipc	a0,0x7
    80000fd0:	10450513          	addi	a0,a0,260 # 800080d0 <digits+0x90>
    80000fd4:	fffff097          	auipc	ra,0xfffff
    80000fd8:	556080e7          	jalr	1366(ra) # 8000052a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fdc:	060a8663          	beqz	s5,80001048 <walk+0xa2>
    80000fe0:	00000097          	auipc	ra,0x0
    80000fe4:	af2080e7          	jalr	-1294(ra) # 80000ad2 <kalloc>
    80000fe8:	84aa                	mv	s1,a0
    80000fea:	c529                	beqz	a0,80001034 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000fec:	6605                	lui	a2,0x1
    80000fee:	4581                	li	a1,0
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	cce080e7          	jalr	-818(ra) # 80000cbe <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000ff8:	00c4d793          	srli	a5,s1,0xc
    80000ffc:	07aa                	slli	a5,a5,0xa
    80000ffe:	0017e793          	ori	a5,a5,1
    80001002:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001006:	3a5d                	addiw	s4,s4,-9
    80001008:	036a0063          	beq	s4,s6,80001028 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000100c:	0149d933          	srl	s2,s3,s4
    80001010:	1ff97913          	andi	s2,s2,511
    80001014:	090e                	slli	s2,s2,0x3
    80001016:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001018:	00093483          	ld	s1,0(s2)
    8000101c:	0014f793          	andi	a5,s1,1
    80001020:	dfd5                	beqz	a5,80000fdc <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001022:	80a9                	srli	s1,s1,0xa
    80001024:	04b2                	slli	s1,s1,0xc
    80001026:	b7c5                	j	80001006 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001028:	00c9d513          	srli	a0,s3,0xc
    8000102c:	1ff57513          	andi	a0,a0,511
    80001030:	050e                	slli	a0,a0,0x3
    80001032:	9526                	add	a0,a0,s1
}
    80001034:	70e2                	ld	ra,56(sp)
    80001036:	7442                	ld	s0,48(sp)
    80001038:	74a2                	ld	s1,40(sp)
    8000103a:	7902                	ld	s2,32(sp)
    8000103c:	69e2                	ld	s3,24(sp)
    8000103e:	6a42                	ld	s4,16(sp)
    80001040:	6aa2                	ld	s5,8(sp)
    80001042:	6b02                	ld	s6,0(sp)
    80001044:	6121                	addi	sp,sp,64
    80001046:	8082                	ret
        return 0;
    80001048:	4501                	li	a0,0
    8000104a:	b7ed                	j	80001034 <walk+0x8e>

000000008000104c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000104c:	57fd                	li	a5,-1
    8000104e:	83e9                	srli	a5,a5,0x1a
    80001050:	00b7f463          	bgeu	a5,a1,80001058 <walkaddr+0xc>
    return 0;
    80001054:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001056:	8082                	ret
{
    80001058:	1141                	addi	sp,sp,-16
    8000105a:	e406                	sd	ra,8(sp)
    8000105c:	e022                	sd	s0,0(sp)
    8000105e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001060:	4601                	li	a2,0
    80001062:	00000097          	auipc	ra,0x0
    80001066:	f44080e7          	jalr	-188(ra) # 80000fa6 <walk>
  if(pte == 0)
    8000106a:	c105                	beqz	a0,8000108a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000106c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000106e:	0117f693          	andi	a3,a5,17
    80001072:	4745                	li	a4,17
    return 0;
    80001074:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001076:	00e68663          	beq	a3,a4,80001082 <walkaddr+0x36>
}
    8000107a:	60a2                	ld	ra,8(sp)
    8000107c:	6402                	ld	s0,0(sp)
    8000107e:	0141                	addi	sp,sp,16
    80001080:	8082                	ret
  pa = PTE2PA(*pte);
    80001082:	00a7d513          	srli	a0,a5,0xa
    80001086:	0532                	slli	a0,a0,0xc
  return pa;
    80001088:	bfcd                	j	8000107a <walkaddr+0x2e>
    return 0;
    8000108a:	4501                	li	a0,0
    8000108c:	b7fd                	j	8000107a <walkaddr+0x2e>

000000008000108e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000108e:	715d                	addi	sp,sp,-80
    80001090:	e486                	sd	ra,72(sp)
    80001092:	e0a2                	sd	s0,64(sp)
    80001094:	fc26                	sd	s1,56(sp)
    80001096:	f84a                	sd	s2,48(sp)
    80001098:	f44e                	sd	s3,40(sp)
    8000109a:	f052                	sd	s4,32(sp)
    8000109c:	ec56                	sd	s5,24(sp)
    8000109e:	e85a                	sd	s6,16(sp)
    800010a0:	e45e                	sd	s7,8(sp)
    800010a2:	0880                	addi	s0,sp,80
    800010a4:	8aaa                	mv	s5,a0
    800010a6:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010a8:	777d                	lui	a4,0xfffff
    800010aa:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ae:	167d                	addi	a2,a2,-1
    800010b0:	00b609b3          	add	s3,a2,a1
    800010b4:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010b8:	893e                	mv	s2,a5
    800010ba:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010be:	6b85                	lui	s7,0x1
    800010c0:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010c4:	4605                	li	a2,1
    800010c6:	85ca                	mv	a1,s2
    800010c8:	8556                	mv	a0,s5
    800010ca:	00000097          	auipc	ra,0x0
    800010ce:	edc080e7          	jalr	-292(ra) # 80000fa6 <walk>
    800010d2:	c51d                	beqz	a0,80001100 <mappages+0x72>
    if(*pte & PTE_V)
    800010d4:	611c                	ld	a5,0(a0)
    800010d6:	8b85                	andi	a5,a5,1
    800010d8:	ef81                	bnez	a5,800010f0 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010da:	80b1                	srli	s1,s1,0xc
    800010dc:	04aa                	slli	s1,s1,0xa
    800010de:	0164e4b3          	or	s1,s1,s6
    800010e2:	0014e493          	ori	s1,s1,1
    800010e6:	e104                	sd	s1,0(a0)
    if(a == last)
    800010e8:	03390863          	beq	s2,s3,80001118 <mappages+0x8a>
    a += PGSIZE;
    800010ec:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010ee:	bfc9                	j	800010c0 <mappages+0x32>
      panic("remap");
    800010f0:	00007517          	auipc	a0,0x7
    800010f4:	fe850513          	addi	a0,a0,-24 # 800080d8 <digits+0x98>
    800010f8:	fffff097          	auipc	ra,0xfffff
    800010fc:	432080e7          	jalr	1074(ra) # 8000052a <panic>
      return -1;
    80001100:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001102:	60a6                	ld	ra,72(sp)
    80001104:	6406                	ld	s0,64(sp)
    80001106:	74e2                	ld	s1,56(sp)
    80001108:	7942                	ld	s2,48(sp)
    8000110a:	79a2                	ld	s3,40(sp)
    8000110c:	7a02                	ld	s4,32(sp)
    8000110e:	6ae2                	ld	s5,24(sp)
    80001110:	6b42                	ld	s6,16(sp)
    80001112:	6ba2                	ld	s7,8(sp)
    80001114:	6161                	addi	sp,sp,80
    80001116:	8082                	ret
  return 0;
    80001118:	4501                	li	a0,0
    8000111a:	b7e5                	j	80001102 <mappages+0x74>

000000008000111c <kvmmap>:
{
    8000111c:	1141                	addi	sp,sp,-16
    8000111e:	e406                	sd	ra,8(sp)
    80001120:	e022                	sd	s0,0(sp)
    80001122:	0800                	addi	s0,sp,16
    80001124:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001126:	86b2                	mv	a3,a2
    80001128:	863e                	mv	a2,a5
    8000112a:	00000097          	auipc	ra,0x0
    8000112e:	f64080e7          	jalr	-156(ra) # 8000108e <mappages>
    80001132:	e509                	bnez	a0,8000113c <kvmmap+0x20>
}
    80001134:	60a2                	ld	ra,8(sp)
    80001136:	6402                	ld	s0,0(sp)
    80001138:	0141                	addi	sp,sp,16
    8000113a:	8082                	ret
    panic("kvmmap");
    8000113c:	00007517          	auipc	a0,0x7
    80001140:	fa450513          	addi	a0,a0,-92 # 800080e0 <digits+0xa0>
    80001144:	fffff097          	auipc	ra,0xfffff
    80001148:	3e6080e7          	jalr	998(ra) # 8000052a <panic>

000000008000114c <kvmmake>:
{
    8000114c:	1101                	addi	sp,sp,-32
    8000114e:	ec06                	sd	ra,24(sp)
    80001150:	e822                	sd	s0,16(sp)
    80001152:	e426                	sd	s1,8(sp)
    80001154:	e04a                	sd	s2,0(sp)
    80001156:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001158:	00000097          	auipc	ra,0x0
    8000115c:	97a080e7          	jalr	-1670(ra) # 80000ad2 <kalloc>
    80001160:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001162:	6605                	lui	a2,0x1
    80001164:	4581                	li	a1,0
    80001166:	00000097          	auipc	ra,0x0
    8000116a:	b58080e7          	jalr	-1192(ra) # 80000cbe <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000116e:	4719                	li	a4,6
    80001170:	6685                	lui	a3,0x1
    80001172:	10000637          	lui	a2,0x10000
    80001176:	100005b7          	lui	a1,0x10000
    8000117a:	8526                	mv	a0,s1
    8000117c:	00000097          	auipc	ra,0x0
    80001180:	fa0080e7          	jalr	-96(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001184:	4719                	li	a4,6
    80001186:	6685                	lui	a3,0x1
    80001188:	10001637          	lui	a2,0x10001
    8000118c:	100015b7          	lui	a1,0x10001
    80001190:	8526                	mv	a0,s1
    80001192:	00000097          	auipc	ra,0x0
    80001196:	f8a080e7          	jalr	-118(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000119a:	4719                	li	a4,6
    8000119c:	004006b7          	lui	a3,0x400
    800011a0:	0c000637          	lui	a2,0xc000
    800011a4:	0c0005b7          	lui	a1,0xc000
    800011a8:	8526                	mv	a0,s1
    800011aa:	00000097          	auipc	ra,0x0
    800011ae:	f72080e7          	jalr	-142(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011b2:	00007917          	auipc	s2,0x7
    800011b6:	e4e90913          	addi	s2,s2,-434 # 80008000 <etext>
    800011ba:	4729                	li	a4,10
    800011bc:	80007697          	auipc	a3,0x80007
    800011c0:	e4468693          	addi	a3,a3,-444 # 8000 <_entry-0x7fff8000>
    800011c4:	4605                	li	a2,1
    800011c6:	067e                	slli	a2,a2,0x1f
    800011c8:	85b2                	mv	a1,a2
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f50080e7          	jalr	-176(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011d4:	4719                	li	a4,6
    800011d6:	46c5                	li	a3,17
    800011d8:	06ee                	slli	a3,a3,0x1b
    800011da:	412686b3          	sub	a3,a3,s2
    800011de:	864a                	mv	a2,s2
    800011e0:	85ca                	mv	a1,s2
    800011e2:	8526                	mv	a0,s1
    800011e4:	00000097          	auipc	ra,0x0
    800011e8:	f38080e7          	jalr	-200(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011ec:	4729                	li	a4,10
    800011ee:	6685                	lui	a3,0x1
    800011f0:	00006617          	auipc	a2,0x6
    800011f4:	e1060613          	addi	a2,a2,-496 # 80007000 <_trampoline>
    800011f8:	040005b7          	lui	a1,0x4000
    800011fc:	15fd                	addi	a1,a1,-1
    800011fe:	05b2                	slli	a1,a1,0xc
    80001200:	8526                	mv	a0,s1
    80001202:	00000097          	auipc	ra,0x0
    80001206:	f1a080e7          	jalr	-230(ra) # 8000111c <kvmmap>
  proc_mapstacks(kpgtbl);
    8000120a:	8526                	mv	a0,s1
    8000120c:	00000097          	auipc	ra,0x0
    80001210:	600080e7          	jalr	1536(ra) # 8000180c <proc_mapstacks>
}
    80001214:	8526                	mv	a0,s1
    80001216:	60e2                	ld	ra,24(sp)
    80001218:	6442                	ld	s0,16(sp)
    8000121a:	64a2                	ld	s1,8(sp)
    8000121c:	6902                	ld	s2,0(sp)
    8000121e:	6105                	addi	sp,sp,32
    80001220:	8082                	ret

0000000080001222 <kvminit>:
{
    80001222:	1141                	addi	sp,sp,-16
    80001224:	e406                	sd	ra,8(sp)
    80001226:	e022                	sd	s0,0(sp)
    80001228:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000122a:	00000097          	auipc	ra,0x0
    8000122e:	f22080e7          	jalr	-222(ra) # 8000114c <kvmmake>
    80001232:	00008797          	auipc	a5,0x8
    80001236:	dea7b723          	sd	a0,-530(a5) # 80009020 <kernel_pagetable>
}
    8000123a:	60a2                	ld	ra,8(sp)
    8000123c:	6402                	ld	s0,0(sp)
    8000123e:	0141                	addi	sp,sp,16
    80001240:	8082                	ret

0000000080001242 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001242:	715d                	addi	sp,sp,-80
    80001244:	e486                	sd	ra,72(sp)
    80001246:	e0a2                	sd	s0,64(sp)
    80001248:	fc26                	sd	s1,56(sp)
    8000124a:	f84a                	sd	s2,48(sp)
    8000124c:	f44e                	sd	s3,40(sp)
    8000124e:	f052                	sd	s4,32(sp)
    80001250:	ec56                	sd	s5,24(sp)
    80001252:	e85a                	sd	s6,16(sp)
    80001254:	e45e                	sd	s7,8(sp)
    80001256:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001258:	03459793          	slli	a5,a1,0x34
    8000125c:	e795                	bnez	a5,80001288 <uvmunmap+0x46>
    8000125e:	8a2a                	mv	s4,a0
    80001260:	892e                	mv	s2,a1
    80001262:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001264:	0632                	slli	a2,a2,0xc
    80001266:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000126a:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000126c:	6b05                	lui	s6,0x1
    8000126e:	0735e263          	bltu	a1,s3,800012d2 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001272:	60a6                	ld	ra,72(sp)
    80001274:	6406                	ld	s0,64(sp)
    80001276:	74e2                	ld	s1,56(sp)
    80001278:	7942                	ld	s2,48(sp)
    8000127a:	79a2                	ld	s3,40(sp)
    8000127c:	7a02                	ld	s4,32(sp)
    8000127e:	6ae2                	ld	s5,24(sp)
    80001280:	6b42                	ld	s6,16(sp)
    80001282:	6ba2                	ld	s7,8(sp)
    80001284:	6161                	addi	sp,sp,80
    80001286:	8082                	ret
    panic("uvmunmap: not aligned");
    80001288:	00007517          	auipc	a0,0x7
    8000128c:	e6050513          	addi	a0,a0,-416 # 800080e8 <digits+0xa8>
    80001290:	fffff097          	auipc	ra,0xfffff
    80001294:	29a080e7          	jalr	666(ra) # 8000052a <panic>
      panic("uvmunmap: walk");
    80001298:	00007517          	auipc	a0,0x7
    8000129c:	e6850513          	addi	a0,a0,-408 # 80008100 <digits+0xc0>
    800012a0:	fffff097          	auipc	ra,0xfffff
    800012a4:	28a080e7          	jalr	650(ra) # 8000052a <panic>
      panic("uvmunmap: not mapped");
    800012a8:	00007517          	auipc	a0,0x7
    800012ac:	e6850513          	addi	a0,a0,-408 # 80008110 <digits+0xd0>
    800012b0:	fffff097          	auipc	ra,0xfffff
    800012b4:	27a080e7          	jalr	634(ra) # 8000052a <panic>
      panic("uvmunmap: not a leaf");
    800012b8:	00007517          	auipc	a0,0x7
    800012bc:	e7050513          	addi	a0,a0,-400 # 80008128 <digits+0xe8>
    800012c0:	fffff097          	auipc	ra,0xfffff
    800012c4:	26a080e7          	jalr	618(ra) # 8000052a <panic>
    *pte = 0;
    800012c8:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012cc:	995a                	add	s2,s2,s6
    800012ce:	fb3972e3          	bgeu	s2,s3,80001272 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012d2:	4601                	li	a2,0
    800012d4:	85ca                	mv	a1,s2
    800012d6:	8552                	mv	a0,s4
    800012d8:	00000097          	auipc	ra,0x0
    800012dc:	cce080e7          	jalr	-818(ra) # 80000fa6 <walk>
    800012e0:	84aa                	mv	s1,a0
    800012e2:	d95d                	beqz	a0,80001298 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800012e4:	6108                	ld	a0,0(a0)
    800012e6:	00157793          	andi	a5,a0,1
    800012ea:	dfdd                	beqz	a5,800012a8 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800012ec:	3ff57793          	andi	a5,a0,1023
    800012f0:	fd7784e3          	beq	a5,s7,800012b8 <uvmunmap+0x76>
    if(do_free){
    800012f4:	fc0a8ae3          	beqz	s5,800012c8 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800012f8:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800012fa:	0532                	slli	a0,a0,0xc
    800012fc:	fffff097          	auipc	ra,0xfffff
    80001300:	6da080e7          	jalr	1754(ra) # 800009d6 <kfree>
    80001304:	b7d1                	j	800012c8 <uvmunmap+0x86>

0000000080001306 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001306:	1101                	addi	sp,sp,-32
    80001308:	ec06                	sd	ra,24(sp)
    8000130a:	e822                	sd	s0,16(sp)
    8000130c:	e426                	sd	s1,8(sp)
    8000130e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001310:	fffff097          	auipc	ra,0xfffff
    80001314:	7c2080e7          	jalr	1986(ra) # 80000ad2 <kalloc>
    80001318:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000131a:	c519                	beqz	a0,80001328 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000131c:	6605                	lui	a2,0x1
    8000131e:	4581                	li	a1,0
    80001320:	00000097          	auipc	ra,0x0
    80001324:	99e080e7          	jalr	-1634(ra) # 80000cbe <memset>
  return pagetable;
}
    80001328:	8526                	mv	a0,s1
    8000132a:	60e2                	ld	ra,24(sp)
    8000132c:	6442                	ld	s0,16(sp)
    8000132e:	64a2                	ld	s1,8(sp)
    80001330:	6105                	addi	sp,sp,32
    80001332:	8082                	ret

0000000080001334 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001334:	7179                	addi	sp,sp,-48
    80001336:	f406                	sd	ra,40(sp)
    80001338:	f022                	sd	s0,32(sp)
    8000133a:	ec26                	sd	s1,24(sp)
    8000133c:	e84a                	sd	s2,16(sp)
    8000133e:	e44e                	sd	s3,8(sp)
    80001340:	e052                	sd	s4,0(sp)
    80001342:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001344:	6785                	lui	a5,0x1
    80001346:	04f67863          	bgeu	a2,a5,80001396 <uvminit+0x62>
    8000134a:	8a2a                	mv	s4,a0
    8000134c:	89ae                	mv	s3,a1
    8000134e:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001350:	fffff097          	auipc	ra,0xfffff
    80001354:	782080e7          	jalr	1922(ra) # 80000ad2 <kalloc>
    80001358:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000135a:	6605                	lui	a2,0x1
    8000135c:	4581                	li	a1,0
    8000135e:	00000097          	auipc	ra,0x0
    80001362:	960080e7          	jalr	-1696(ra) # 80000cbe <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001366:	4779                	li	a4,30
    80001368:	86ca                	mv	a3,s2
    8000136a:	6605                	lui	a2,0x1
    8000136c:	4581                	li	a1,0
    8000136e:	8552                	mv	a0,s4
    80001370:	00000097          	auipc	ra,0x0
    80001374:	d1e080e7          	jalr	-738(ra) # 8000108e <mappages>
  memmove(mem, src, sz);
    80001378:	8626                	mv	a2,s1
    8000137a:	85ce                	mv	a1,s3
    8000137c:	854a                	mv	a0,s2
    8000137e:	00000097          	auipc	ra,0x0
    80001382:	99c080e7          	jalr	-1636(ra) # 80000d1a <memmove>
}
    80001386:	70a2                	ld	ra,40(sp)
    80001388:	7402                	ld	s0,32(sp)
    8000138a:	64e2                	ld	s1,24(sp)
    8000138c:	6942                	ld	s2,16(sp)
    8000138e:	69a2                	ld	s3,8(sp)
    80001390:	6a02                	ld	s4,0(sp)
    80001392:	6145                	addi	sp,sp,48
    80001394:	8082                	ret
    panic("inituvm: more than a page");
    80001396:	00007517          	auipc	a0,0x7
    8000139a:	daa50513          	addi	a0,a0,-598 # 80008140 <digits+0x100>
    8000139e:	fffff097          	auipc	ra,0xfffff
    800013a2:	18c080e7          	jalr	396(ra) # 8000052a <panic>

00000000800013a6 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013a6:	1101                	addi	sp,sp,-32
    800013a8:	ec06                	sd	ra,24(sp)
    800013aa:	e822                	sd	s0,16(sp)
    800013ac:	e426                	sd	s1,8(sp)
    800013ae:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013b0:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013b2:	00b67d63          	bgeu	a2,a1,800013cc <uvmdealloc+0x26>
    800013b6:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013b8:	6785                	lui	a5,0x1
    800013ba:	17fd                	addi	a5,a5,-1
    800013bc:	00f60733          	add	a4,a2,a5
    800013c0:	767d                	lui	a2,0xfffff
    800013c2:	8f71                	and	a4,a4,a2
    800013c4:	97ae                	add	a5,a5,a1
    800013c6:	8ff1                	and	a5,a5,a2
    800013c8:	00f76863          	bltu	a4,a5,800013d8 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013cc:	8526                	mv	a0,s1
    800013ce:	60e2                	ld	ra,24(sp)
    800013d0:	6442                	ld	s0,16(sp)
    800013d2:	64a2                	ld	s1,8(sp)
    800013d4:	6105                	addi	sp,sp,32
    800013d6:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013d8:	8f99                	sub	a5,a5,a4
    800013da:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013dc:	4685                	li	a3,1
    800013de:	0007861b          	sext.w	a2,a5
    800013e2:	85ba                	mv	a1,a4
    800013e4:	00000097          	auipc	ra,0x0
    800013e8:	e5e080e7          	jalr	-418(ra) # 80001242 <uvmunmap>
    800013ec:	b7c5                	j	800013cc <uvmdealloc+0x26>

00000000800013ee <uvmalloc>:
  if(newsz < oldsz)
    800013ee:	0ab66163          	bltu	a2,a1,80001490 <uvmalloc+0xa2>
{
    800013f2:	7139                	addi	sp,sp,-64
    800013f4:	fc06                	sd	ra,56(sp)
    800013f6:	f822                	sd	s0,48(sp)
    800013f8:	f426                	sd	s1,40(sp)
    800013fa:	f04a                	sd	s2,32(sp)
    800013fc:	ec4e                	sd	s3,24(sp)
    800013fe:	e852                	sd	s4,16(sp)
    80001400:	e456                	sd	s5,8(sp)
    80001402:	0080                	addi	s0,sp,64
    80001404:	8aaa                	mv	s5,a0
    80001406:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001408:	6985                	lui	s3,0x1
    8000140a:	19fd                	addi	s3,s3,-1
    8000140c:	95ce                	add	a1,a1,s3
    8000140e:	79fd                	lui	s3,0xfffff
    80001410:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001414:	08c9f063          	bgeu	s3,a2,80001494 <uvmalloc+0xa6>
    80001418:	894e                	mv	s2,s3
    mem = kalloc();
    8000141a:	fffff097          	auipc	ra,0xfffff
    8000141e:	6b8080e7          	jalr	1720(ra) # 80000ad2 <kalloc>
    80001422:	84aa                	mv	s1,a0
    if(mem == 0){
    80001424:	c51d                	beqz	a0,80001452 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001426:	6605                	lui	a2,0x1
    80001428:	4581                	li	a1,0
    8000142a:	00000097          	auipc	ra,0x0
    8000142e:	894080e7          	jalr	-1900(ra) # 80000cbe <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001432:	4779                	li	a4,30
    80001434:	86a6                	mv	a3,s1
    80001436:	6605                	lui	a2,0x1
    80001438:	85ca                	mv	a1,s2
    8000143a:	8556                	mv	a0,s5
    8000143c:	00000097          	auipc	ra,0x0
    80001440:	c52080e7          	jalr	-942(ra) # 8000108e <mappages>
    80001444:	e905                	bnez	a0,80001474 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001446:	6785                	lui	a5,0x1
    80001448:	993e                	add	s2,s2,a5
    8000144a:	fd4968e3          	bltu	s2,s4,8000141a <uvmalloc+0x2c>
  return newsz;
    8000144e:	8552                	mv	a0,s4
    80001450:	a809                	j	80001462 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001452:	864e                	mv	a2,s3
    80001454:	85ca                	mv	a1,s2
    80001456:	8556                	mv	a0,s5
    80001458:	00000097          	auipc	ra,0x0
    8000145c:	f4e080e7          	jalr	-178(ra) # 800013a6 <uvmdealloc>
      return 0;
    80001460:	4501                	li	a0,0
}
    80001462:	70e2                	ld	ra,56(sp)
    80001464:	7442                	ld	s0,48(sp)
    80001466:	74a2                	ld	s1,40(sp)
    80001468:	7902                	ld	s2,32(sp)
    8000146a:	69e2                	ld	s3,24(sp)
    8000146c:	6a42                	ld	s4,16(sp)
    8000146e:	6aa2                	ld	s5,8(sp)
    80001470:	6121                	addi	sp,sp,64
    80001472:	8082                	ret
      kfree(mem);
    80001474:	8526                	mv	a0,s1
    80001476:	fffff097          	auipc	ra,0xfffff
    8000147a:	560080e7          	jalr	1376(ra) # 800009d6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000147e:	864e                	mv	a2,s3
    80001480:	85ca                	mv	a1,s2
    80001482:	8556                	mv	a0,s5
    80001484:	00000097          	auipc	ra,0x0
    80001488:	f22080e7          	jalr	-222(ra) # 800013a6 <uvmdealloc>
      return 0;
    8000148c:	4501                	li	a0,0
    8000148e:	bfd1                	j	80001462 <uvmalloc+0x74>
    return oldsz;
    80001490:	852e                	mv	a0,a1
}
    80001492:	8082                	ret
  return newsz;
    80001494:	8532                	mv	a0,a2
    80001496:	b7f1                	j	80001462 <uvmalloc+0x74>

0000000080001498 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001498:	7179                	addi	sp,sp,-48
    8000149a:	f406                	sd	ra,40(sp)
    8000149c:	f022                	sd	s0,32(sp)
    8000149e:	ec26                	sd	s1,24(sp)
    800014a0:	e84a                	sd	s2,16(sp)
    800014a2:	e44e                	sd	s3,8(sp)
    800014a4:	e052                	sd	s4,0(sp)
    800014a6:	1800                	addi	s0,sp,48
    800014a8:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014aa:	84aa                	mv	s1,a0
    800014ac:	6905                	lui	s2,0x1
    800014ae:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014b0:	4985                	li	s3,1
    800014b2:	a821                	j	800014ca <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014b4:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014b6:	0532                	slli	a0,a0,0xc
    800014b8:	00000097          	auipc	ra,0x0
    800014bc:	fe0080e7          	jalr	-32(ra) # 80001498 <freewalk>
      pagetable[i] = 0;
    800014c0:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014c4:	04a1                	addi	s1,s1,8
    800014c6:	03248163          	beq	s1,s2,800014e8 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014ca:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014cc:	00f57793          	andi	a5,a0,15
    800014d0:	ff3782e3          	beq	a5,s3,800014b4 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014d4:	8905                	andi	a0,a0,1
    800014d6:	d57d                	beqz	a0,800014c4 <freewalk+0x2c>
      panic("freewalk: leaf");
    800014d8:	00007517          	auipc	a0,0x7
    800014dc:	c8850513          	addi	a0,a0,-888 # 80008160 <digits+0x120>
    800014e0:	fffff097          	auipc	ra,0xfffff
    800014e4:	04a080e7          	jalr	74(ra) # 8000052a <panic>
    }
  }
  kfree((void*)pagetable);
    800014e8:	8552                	mv	a0,s4
    800014ea:	fffff097          	auipc	ra,0xfffff
    800014ee:	4ec080e7          	jalr	1260(ra) # 800009d6 <kfree>
}
    800014f2:	70a2                	ld	ra,40(sp)
    800014f4:	7402                	ld	s0,32(sp)
    800014f6:	64e2                	ld	s1,24(sp)
    800014f8:	6942                	ld	s2,16(sp)
    800014fa:	69a2                	ld	s3,8(sp)
    800014fc:	6a02                	ld	s4,0(sp)
    800014fe:	6145                	addi	sp,sp,48
    80001500:	8082                	ret

0000000080001502 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001502:	1101                	addi	sp,sp,-32
    80001504:	ec06                	sd	ra,24(sp)
    80001506:	e822                	sd	s0,16(sp)
    80001508:	e426                	sd	s1,8(sp)
    8000150a:	1000                	addi	s0,sp,32
    8000150c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000150e:	e999                	bnez	a1,80001524 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001510:	8526                	mv	a0,s1
    80001512:	00000097          	auipc	ra,0x0
    80001516:	f86080e7          	jalr	-122(ra) # 80001498 <freewalk>
}
    8000151a:	60e2                	ld	ra,24(sp)
    8000151c:	6442                	ld	s0,16(sp)
    8000151e:	64a2                	ld	s1,8(sp)
    80001520:	6105                	addi	sp,sp,32
    80001522:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001524:	6605                	lui	a2,0x1
    80001526:	167d                	addi	a2,a2,-1
    80001528:	962e                	add	a2,a2,a1
    8000152a:	4685                	li	a3,1
    8000152c:	8231                	srli	a2,a2,0xc
    8000152e:	4581                	li	a1,0
    80001530:	00000097          	auipc	ra,0x0
    80001534:	d12080e7          	jalr	-750(ra) # 80001242 <uvmunmap>
    80001538:	bfe1                	j	80001510 <uvmfree+0xe>

000000008000153a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000153a:	c679                	beqz	a2,80001608 <uvmcopy+0xce>
{
    8000153c:	715d                	addi	sp,sp,-80
    8000153e:	e486                	sd	ra,72(sp)
    80001540:	e0a2                	sd	s0,64(sp)
    80001542:	fc26                	sd	s1,56(sp)
    80001544:	f84a                	sd	s2,48(sp)
    80001546:	f44e                	sd	s3,40(sp)
    80001548:	f052                	sd	s4,32(sp)
    8000154a:	ec56                	sd	s5,24(sp)
    8000154c:	e85a                	sd	s6,16(sp)
    8000154e:	e45e                	sd	s7,8(sp)
    80001550:	0880                	addi	s0,sp,80
    80001552:	8b2a                	mv	s6,a0
    80001554:	8aae                	mv	s5,a1
    80001556:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001558:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000155a:	4601                	li	a2,0
    8000155c:	85ce                	mv	a1,s3
    8000155e:	855a                	mv	a0,s6
    80001560:	00000097          	auipc	ra,0x0
    80001564:	a46080e7          	jalr	-1466(ra) # 80000fa6 <walk>
    80001568:	c531                	beqz	a0,800015b4 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000156a:	6118                	ld	a4,0(a0)
    8000156c:	00177793          	andi	a5,a4,1
    80001570:	cbb1                	beqz	a5,800015c4 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001572:	00a75593          	srli	a1,a4,0xa
    80001576:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000157a:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000157e:	fffff097          	auipc	ra,0xfffff
    80001582:	554080e7          	jalr	1364(ra) # 80000ad2 <kalloc>
    80001586:	892a                	mv	s2,a0
    80001588:	c939                	beqz	a0,800015de <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000158a:	6605                	lui	a2,0x1
    8000158c:	85de                	mv	a1,s7
    8000158e:	fffff097          	auipc	ra,0xfffff
    80001592:	78c080e7          	jalr	1932(ra) # 80000d1a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001596:	8726                	mv	a4,s1
    80001598:	86ca                	mv	a3,s2
    8000159a:	6605                	lui	a2,0x1
    8000159c:	85ce                	mv	a1,s3
    8000159e:	8556                	mv	a0,s5
    800015a0:	00000097          	auipc	ra,0x0
    800015a4:	aee080e7          	jalr	-1298(ra) # 8000108e <mappages>
    800015a8:	e515                	bnez	a0,800015d4 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015aa:	6785                	lui	a5,0x1
    800015ac:	99be                	add	s3,s3,a5
    800015ae:	fb49e6e3          	bltu	s3,s4,8000155a <uvmcopy+0x20>
    800015b2:	a081                	j	800015f2 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015b4:	00007517          	auipc	a0,0x7
    800015b8:	bbc50513          	addi	a0,a0,-1092 # 80008170 <digits+0x130>
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	f6e080e7          	jalr	-146(ra) # 8000052a <panic>
      panic("uvmcopy: page not present");
    800015c4:	00007517          	auipc	a0,0x7
    800015c8:	bcc50513          	addi	a0,a0,-1076 # 80008190 <digits+0x150>
    800015cc:	fffff097          	auipc	ra,0xfffff
    800015d0:	f5e080e7          	jalr	-162(ra) # 8000052a <panic>
      kfree(mem);
    800015d4:	854a                	mv	a0,s2
    800015d6:	fffff097          	auipc	ra,0xfffff
    800015da:	400080e7          	jalr	1024(ra) # 800009d6 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800015de:	4685                	li	a3,1
    800015e0:	00c9d613          	srli	a2,s3,0xc
    800015e4:	4581                	li	a1,0
    800015e6:	8556                	mv	a0,s5
    800015e8:	00000097          	auipc	ra,0x0
    800015ec:	c5a080e7          	jalr	-934(ra) # 80001242 <uvmunmap>
  return -1;
    800015f0:	557d                	li	a0,-1
}
    800015f2:	60a6                	ld	ra,72(sp)
    800015f4:	6406                	ld	s0,64(sp)
    800015f6:	74e2                	ld	s1,56(sp)
    800015f8:	7942                	ld	s2,48(sp)
    800015fa:	79a2                	ld	s3,40(sp)
    800015fc:	7a02                	ld	s4,32(sp)
    800015fe:	6ae2                	ld	s5,24(sp)
    80001600:	6b42                	ld	s6,16(sp)
    80001602:	6ba2                	ld	s7,8(sp)
    80001604:	6161                	addi	sp,sp,80
    80001606:	8082                	ret
  return 0;
    80001608:	4501                	li	a0,0
}
    8000160a:	8082                	ret

000000008000160c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000160c:	1141                	addi	sp,sp,-16
    8000160e:	e406                	sd	ra,8(sp)
    80001610:	e022                	sd	s0,0(sp)
    80001612:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001614:	4601                	li	a2,0
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	990080e7          	jalr	-1648(ra) # 80000fa6 <walk>
  if(pte == 0)
    8000161e:	c901                	beqz	a0,8000162e <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001620:	611c                	ld	a5,0(a0)
    80001622:	9bbd                	andi	a5,a5,-17
    80001624:	e11c                	sd	a5,0(a0)
}
    80001626:	60a2                	ld	ra,8(sp)
    80001628:	6402                	ld	s0,0(sp)
    8000162a:	0141                	addi	sp,sp,16
    8000162c:	8082                	ret
    panic("uvmclear");
    8000162e:	00007517          	auipc	a0,0x7
    80001632:	b8250513          	addi	a0,a0,-1150 # 800081b0 <digits+0x170>
    80001636:	fffff097          	auipc	ra,0xfffff
    8000163a:	ef4080e7          	jalr	-268(ra) # 8000052a <panic>

000000008000163e <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000163e:	c6bd                	beqz	a3,800016ac <copyout+0x6e>
{
    80001640:	715d                	addi	sp,sp,-80
    80001642:	e486                	sd	ra,72(sp)
    80001644:	e0a2                	sd	s0,64(sp)
    80001646:	fc26                	sd	s1,56(sp)
    80001648:	f84a                	sd	s2,48(sp)
    8000164a:	f44e                	sd	s3,40(sp)
    8000164c:	f052                	sd	s4,32(sp)
    8000164e:	ec56                	sd	s5,24(sp)
    80001650:	e85a                	sd	s6,16(sp)
    80001652:	e45e                	sd	s7,8(sp)
    80001654:	e062                	sd	s8,0(sp)
    80001656:	0880                	addi	s0,sp,80
    80001658:	8b2a                	mv	s6,a0
    8000165a:	8c2e                	mv	s8,a1
    8000165c:	8a32                	mv	s4,a2
    8000165e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001660:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001662:	6a85                	lui	s5,0x1
    80001664:	a015                	j	80001688 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001666:	9562                	add	a0,a0,s8
    80001668:	0004861b          	sext.w	a2,s1
    8000166c:	85d2                	mv	a1,s4
    8000166e:	41250533          	sub	a0,a0,s2
    80001672:	fffff097          	auipc	ra,0xfffff
    80001676:	6a8080e7          	jalr	1704(ra) # 80000d1a <memmove>

    len -= n;
    8000167a:	409989b3          	sub	s3,s3,s1
    src += n;
    8000167e:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001680:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001684:	02098263          	beqz	s3,800016a8 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001688:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000168c:	85ca                	mv	a1,s2
    8000168e:	855a                	mv	a0,s6
    80001690:	00000097          	auipc	ra,0x0
    80001694:	9bc080e7          	jalr	-1604(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    80001698:	cd01                	beqz	a0,800016b0 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000169a:	418904b3          	sub	s1,s2,s8
    8000169e:	94d6                	add	s1,s1,s5
    if(n > len)
    800016a0:	fc99f3e3          	bgeu	s3,s1,80001666 <copyout+0x28>
    800016a4:	84ce                	mv	s1,s3
    800016a6:	b7c1                	j	80001666 <copyout+0x28>
  }
  return 0;
    800016a8:	4501                	li	a0,0
    800016aa:	a021                	j	800016b2 <copyout+0x74>
    800016ac:	4501                	li	a0,0
}
    800016ae:	8082                	ret
      return -1;
    800016b0:	557d                	li	a0,-1
}
    800016b2:	60a6                	ld	ra,72(sp)
    800016b4:	6406                	ld	s0,64(sp)
    800016b6:	74e2                	ld	s1,56(sp)
    800016b8:	7942                	ld	s2,48(sp)
    800016ba:	79a2                	ld	s3,40(sp)
    800016bc:	7a02                	ld	s4,32(sp)
    800016be:	6ae2                	ld	s5,24(sp)
    800016c0:	6b42                	ld	s6,16(sp)
    800016c2:	6ba2                	ld	s7,8(sp)
    800016c4:	6c02                	ld	s8,0(sp)
    800016c6:	6161                	addi	sp,sp,80
    800016c8:	8082                	ret

00000000800016ca <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016ca:	caa5                	beqz	a3,8000173a <copyin+0x70>
{
    800016cc:	715d                	addi	sp,sp,-80
    800016ce:	e486                	sd	ra,72(sp)
    800016d0:	e0a2                	sd	s0,64(sp)
    800016d2:	fc26                	sd	s1,56(sp)
    800016d4:	f84a                	sd	s2,48(sp)
    800016d6:	f44e                	sd	s3,40(sp)
    800016d8:	f052                	sd	s4,32(sp)
    800016da:	ec56                	sd	s5,24(sp)
    800016dc:	e85a                	sd	s6,16(sp)
    800016de:	e45e                	sd	s7,8(sp)
    800016e0:	e062                	sd	s8,0(sp)
    800016e2:	0880                	addi	s0,sp,80
    800016e4:	8b2a                	mv	s6,a0
    800016e6:	8a2e                	mv	s4,a1
    800016e8:	8c32                	mv	s8,a2
    800016ea:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800016ec:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016ee:	6a85                	lui	s5,0x1
    800016f0:	a01d                	j	80001716 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016f2:	018505b3          	add	a1,a0,s8
    800016f6:	0004861b          	sext.w	a2,s1
    800016fa:	412585b3          	sub	a1,a1,s2
    800016fe:	8552                	mv	a0,s4
    80001700:	fffff097          	auipc	ra,0xfffff
    80001704:	61a080e7          	jalr	1562(ra) # 80000d1a <memmove>

    len -= n;
    80001708:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000170c:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000170e:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001712:	02098263          	beqz	s3,80001736 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001716:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000171a:	85ca                	mv	a1,s2
    8000171c:	855a                	mv	a0,s6
    8000171e:	00000097          	auipc	ra,0x0
    80001722:	92e080e7          	jalr	-1746(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    80001726:	cd01                	beqz	a0,8000173e <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001728:	418904b3          	sub	s1,s2,s8
    8000172c:	94d6                	add	s1,s1,s5
    if(n > len)
    8000172e:	fc99f2e3          	bgeu	s3,s1,800016f2 <copyin+0x28>
    80001732:	84ce                	mv	s1,s3
    80001734:	bf7d                	j	800016f2 <copyin+0x28>
  }
  return 0;
    80001736:	4501                	li	a0,0
    80001738:	a021                	j	80001740 <copyin+0x76>
    8000173a:	4501                	li	a0,0
}
    8000173c:	8082                	ret
      return -1;
    8000173e:	557d                	li	a0,-1
}
    80001740:	60a6                	ld	ra,72(sp)
    80001742:	6406                	ld	s0,64(sp)
    80001744:	74e2                	ld	s1,56(sp)
    80001746:	7942                	ld	s2,48(sp)
    80001748:	79a2                	ld	s3,40(sp)
    8000174a:	7a02                	ld	s4,32(sp)
    8000174c:	6ae2                	ld	s5,24(sp)
    8000174e:	6b42                	ld	s6,16(sp)
    80001750:	6ba2                	ld	s7,8(sp)
    80001752:	6c02                	ld	s8,0(sp)
    80001754:	6161                	addi	sp,sp,80
    80001756:	8082                	ret

0000000080001758 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001758:	c6c5                	beqz	a3,80001800 <copyinstr+0xa8>
{
    8000175a:	715d                	addi	sp,sp,-80
    8000175c:	e486                	sd	ra,72(sp)
    8000175e:	e0a2                	sd	s0,64(sp)
    80001760:	fc26                	sd	s1,56(sp)
    80001762:	f84a                	sd	s2,48(sp)
    80001764:	f44e                	sd	s3,40(sp)
    80001766:	f052                	sd	s4,32(sp)
    80001768:	ec56                	sd	s5,24(sp)
    8000176a:	e85a                	sd	s6,16(sp)
    8000176c:	e45e                	sd	s7,8(sp)
    8000176e:	0880                	addi	s0,sp,80
    80001770:	8a2a                	mv	s4,a0
    80001772:	8b2e                	mv	s6,a1
    80001774:	8bb2                	mv	s7,a2
    80001776:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001778:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000177a:	6985                	lui	s3,0x1
    8000177c:	a035                	j	800017a8 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000177e:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001782:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001784:	0017b793          	seqz	a5,a5
    80001788:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000178c:	60a6                	ld	ra,72(sp)
    8000178e:	6406                	ld	s0,64(sp)
    80001790:	74e2                	ld	s1,56(sp)
    80001792:	7942                	ld	s2,48(sp)
    80001794:	79a2                	ld	s3,40(sp)
    80001796:	7a02                	ld	s4,32(sp)
    80001798:	6ae2                	ld	s5,24(sp)
    8000179a:	6b42                	ld	s6,16(sp)
    8000179c:	6ba2                	ld	s7,8(sp)
    8000179e:	6161                	addi	sp,sp,80
    800017a0:	8082                	ret
    srcva = va0 + PGSIZE;
    800017a2:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017a6:	c8a9                	beqz	s1,800017f8 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017a8:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017ac:	85ca                	mv	a1,s2
    800017ae:	8552                	mv	a0,s4
    800017b0:	00000097          	auipc	ra,0x0
    800017b4:	89c080e7          	jalr	-1892(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    800017b8:	c131                	beqz	a0,800017fc <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017ba:	41790833          	sub	a6,s2,s7
    800017be:	984e                	add	a6,a6,s3
    if(n > max)
    800017c0:	0104f363          	bgeu	s1,a6,800017c6 <copyinstr+0x6e>
    800017c4:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017c6:	955e                	add	a0,a0,s7
    800017c8:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017cc:	fc080be3          	beqz	a6,800017a2 <copyinstr+0x4a>
    800017d0:	985a                	add	a6,a6,s6
    800017d2:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017d4:	41650633          	sub	a2,a0,s6
    800017d8:	14fd                	addi	s1,s1,-1
    800017da:	9b26                	add	s6,s6,s1
    800017dc:	00f60733          	add	a4,a2,a5
    800017e0:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    800017e4:	df49                	beqz	a4,8000177e <copyinstr+0x26>
        *dst = *p;
    800017e6:	00e78023          	sb	a4,0(a5)
      --max;
    800017ea:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800017ee:	0785                	addi	a5,a5,1
    while(n > 0){
    800017f0:	ff0796e3          	bne	a5,a6,800017dc <copyinstr+0x84>
      dst++;
    800017f4:	8b42                	mv	s6,a6
    800017f6:	b775                	j	800017a2 <copyinstr+0x4a>
    800017f8:	4781                	li	a5,0
    800017fa:	b769                	j	80001784 <copyinstr+0x2c>
      return -1;
    800017fc:	557d                	li	a0,-1
    800017fe:	b779                	j	8000178c <copyinstr+0x34>
  int got_null = 0;
    80001800:	4781                	li	a5,0
  if(got_null){
    80001802:	0017b793          	seqz	a5,a5
    80001806:	40f00533          	neg	a0,a5
}
    8000180a:	8082                	ret

000000008000180c <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    8000180c:	7139                	addi	sp,sp,-64
    8000180e:	fc06                	sd	ra,56(sp)
    80001810:	f822                	sd	s0,48(sp)
    80001812:	f426                	sd	s1,40(sp)
    80001814:	f04a                	sd	s2,32(sp)
    80001816:	ec4e                	sd	s3,24(sp)
    80001818:	e852                	sd	s4,16(sp)
    8000181a:	e456                	sd	s5,8(sp)
    8000181c:	e05a                	sd	s6,0(sp)
    8000181e:	0080                	addi	s0,sp,64
    80001820:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001822:	00010497          	auipc	s1,0x10
    80001826:	ec648493          	addi	s1,s1,-314 # 800116e8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000182a:	8b26                	mv	s6,s1
    8000182c:	00006a97          	auipc	s5,0x6
    80001830:	7d4a8a93          	addi	s5,s5,2004 # 80008000 <etext>
    80001834:	04000937          	lui	s2,0x4000
    80001838:	197d                	addi	s2,s2,-1
    8000183a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000183c:	00016a17          	auipc	s4,0x16
    80001840:	0aca0a13          	addi	s4,s4,172 # 800178e8 <tickslock>
    char *pa = kalloc();
    80001844:	fffff097          	auipc	ra,0xfffff
    80001848:	28e080e7          	jalr	654(ra) # 80000ad2 <kalloc>
    8000184c:	862a                	mv	a2,a0
    if(pa == 0)
    8000184e:	c131                	beqz	a0,80001892 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001850:	416485b3          	sub	a1,s1,s6
    80001854:	858d                	srai	a1,a1,0x3
    80001856:	000ab783          	ld	a5,0(s5)
    8000185a:	02f585b3          	mul	a1,a1,a5
    8000185e:	2585                	addiw	a1,a1,1
    80001860:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001864:	4719                	li	a4,6
    80001866:	6685                	lui	a3,0x1
    80001868:	40b905b3          	sub	a1,s2,a1
    8000186c:	854e                	mv	a0,s3
    8000186e:	00000097          	auipc	ra,0x0
    80001872:	8ae080e7          	jalr	-1874(ra) # 8000111c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001876:	18848493          	addi	s1,s1,392
    8000187a:	fd4495e3          	bne	s1,s4,80001844 <proc_mapstacks+0x38>
  }
}
    8000187e:	70e2                	ld	ra,56(sp)
    80001880:	7442                	ld	s0,48(sp)
    80001882:	74a2                	ld	s1,40(sp)
    80001884:	7902                	ld	s2,32(sp)
    80001886:	69e2                	ld	s3,24(sp)
    80001888:	6a42                	ld	s4,16(sp)
    8000188a:	6aa2                	ld	s5,8(sp)
    8000188c:	6b02                	ld	s6,0(sp)
    8000188e:	6121                	addi	sp,sp,64
    80001890:	8082                	ret
      panic("kalloc");
    80001892:	00007517          	auipc	a0,0x7
    80001896:	92e50513          	addi	a0,a0,-1746 # 800081c0 <digits+0x180>
    8000189a:	fffff097          	auipc	ra,0xfffff
    8000189e:	c90080e7          	jalr	-880(ra) # 8000052a <panic>

00000000800018a2 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800018a2:	7139                	addi	sp,sp,-64
    800018a4:	fc06                	sd	ra,56(sp)
    800018a6:	f822                	sd	s0,48(sp)
    800018a8:	f426                	sd	s1,40(sp)
    800018aa:	f04a                	sd	s2,32(sp)
    800018ac:	ec4e                	sd	s3,24(sp)
    800018ae:	e852                	sd	s4,16(sp)
    800018b0:	e456                	sd	s5,8(sp)
    800018b2:	e05a                	sd	s6,0(sp)
    800018b4:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018b6:	00007597          	auipc	a1,0x7
    800018ba:	91258593          	addi	a1,a1,-1774 # 800081c8 <digits+0x188>
    800018be:	00010517          	auipc	a0,0x10
    800018c2:	9e250513          	addi	a0,a0,-1566 # 800112a0 <pid_lock>
    800018c6:	fffff097          	auipc	ra,0xfffff
    800018ca:	26c080e7          	jalr	620(ra) # 80000b32 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018ce:	00007597          	auipc	a1,0x7
    800018d2:	90258593          	addi	a1,a1,-1790 # 800081d0 <digits+0x190>
    800018d6:	00010517          	auipc	a0,0x10
    800018da:	9e250513          	addi	a0,a0,-1566 # 800112b8 <wait_lock>
    800018de:	fffff097          	auipc	ra,0xfffff
    800018e2:	254080e7          	jalr	596(ra) # 80000b32 <initlock>
  initlock(&queue_lock, "queue_counter"); // task 4
    800018e6:	00007597          	auipc	a1,0x7
    800018ea:	8fa58593          	addi	a1,a1,-1798 # 800081e0 <digits+0x1a0>
    800018ee:	00010517          	auipc	a0,0x10
    800018f2:	9e250513          	addi	a0,a0,-1566 # 800112d0 <queue_lock>
    800018f6:	fffff097          	auipc	ra,0xfffff
    800018fa:	23c080e7          	jalr	572(ra) # 80000b32 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018fe:	00010497          	auipc	s1,0x10
    80001902:	dea48493          	addi	s1,s1,-534 # 800116e8 <proc>
      initlock(&p->lock, "proc");
    80001906:	00007b17          	auipc	s6,0x7
    8000190a:	8eab0b13          	addi	s6,s6,-1814 # 800081f0 <digits+0x1b0>
      p->kstack = KSTACK((int) (p - proc));
    8000190e:	8aa6                	mv	s5,s1
    80001910:	00006a17          	auipc	s4,0x6
    80001914:	6f0a0a13          	addi	s4,s4,1776 # 80008000 <etext>
    80001918:	04000937          	lui	s2,0x4000
    8000191c:	197d                	addi	s2,s2,-1
    8000191e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001920:	00016997          	auipc	s3,0x16
    80001924:	fc898993          	addi	s3,s3,-56 # 800178e8 <tickslock>
      initlock(&p->lock, "proc");
    80001928:	85da                	mv	a1,s6
    8000192a:	8526                	mv	a0,s1
    8000192c:	fffff097          	auipc	ra,0xfffff
    80001930:	206080e7          	jalr	518(ra) # 80000b32 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001934:	415487b3          	sub	a5,s1,s5
    80001938:	878d                	srai	a5,a5,0x3
    8000193a:	000a3703          	ld	a4,0(s4)
    8000193e:	02e787b3          	mul	a5,a5,a4
    80001942:	2785                	addiw	a5,a5,1
    80001944:	00d7979b          	slliw	a5,a5,0xd
    80001948:	40f907b3          	sub	a5,s2,a5
    8000194c:	f0bc                	sd	a5,96(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000194e:	18848493          	addi	s1,s1,392
    80001952:	fd349be3          	bne	s1,s3,80001928 <procinit+0x86>
  }
}
    80001956:	70e2                	ld	ra,56(sp)
    80001958:	7442                	ld	s0,48(sp)
    8000195a:	74a2                	ld	s1,40(sp)
    8000195c:	7902                	ld	s2,32(sp)
    8000195e:	69e2                	ld	s3,24(sp)
    80001960:	6a42                	ld	s4,16(sp)
    80001962:	6aa2                	ld	s5,8(sp)
    80001964:	6b02                	ld	s6,0(sp)
    80001966:	6121                	addi	sp,sp,64
    80001968:	8082                	ret

000000008000196a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000196a:	1141                	addi	sp,sp,-16
    8000196c:	e422                	sd	s0,8(sp)
    8000196e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001970:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001972:	2501                	sext.w	a0,a0
    80001974:	6422                	ld	s0,8(sp)
    80001976:	0141                	addi	sp,sp,16
    80001978:	8082                	ret

000000008000197a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    8000197a:	1141                	addi	sp,sp,-16
    8000197c:	e422                	sd	s0,8(sp)
    8000197e:	0800                	addi	s0,sp,16
    80001980:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001982:	2781                	sext.w	a5,a5
    80001984:	079e                	slli	a5,a5,0x7
  return c;
}
    80001986:	00010517          	auipc	a0,0x10
    8000198a:	96250513          	addi	a0,a0,-1694 # 800112e8 <cpus>
    8000198e:	953e                	add	a0,a0,a5
    80001990:	6422                	ld	s0,8(sp)
    80001992:	0141                	addi	sp,sp,16
    80001994:	8082                	ret

0000000080001996 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001996:	1101                	addi	sp,sp,-32
    80001998:	ec06                	sd	ra,24(sp)
    8000199a:	e822                	sd	s0,16(sp)
    8000199c:	e426                	sd	s1,8(sp)
    8000199e:	1000                	addi	s0,sp,32
  push_off();
    800019a0:	fffff097          	auipc	ra,0xfffff
    800019a4:	1d6080e7          	jalr	470(ra) # 80000b76 <push_off>
    800019a8:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019aa:	2781                	sext.w	a5,a5
    800019ac:	079e                	slli	a5,a5,0x7
    800019ae:	00010717          	auipc	a4,0x10
    800019b2:	8f270713          	addi	a4,a4,-1806 # 800112a0 <pid_lock>
    800019b6:	97ba                	add	a5,a5,a4
    800019b8:	67a4                	ld	s1,72(a5)
  pop_off();
    800019ba:	fffff097          	auipc	ra,0xfffff
    800019be:	25c080e7          	jalr	604(ra) # 80000c16 <pop_off>
  return p;
}
    800019c2:	8526                	mv	a0,s1
    800019c4:	60e2                	ld	ra,24(sp)
    800019c6:	6442                	ld	s0,16(sp)
    800019c8:	64a2                	ld	s1,8(sp)
    800019ca:	6105                	addi	sp,sp,32
    800019cc:	8082                	ret

00000000800019ce <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019ce:	1141                	addi	sp,sp,-16
    800019d0:	e406                	sd	ra,8(sp)
    800019d2:	e022                	sd	s0,0(sp)
    800019d4:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019d6:	00000097          	auipc	ra,0x0
    800019da:	fc0080e7          	jalr	-64(ra) # 80001996 <myproc>
    800019de:	fffff097          	auipc	ra,0xfffff
    800019e2:	298080e7          	jalr	664(ra) # 80000c76 <release>

  if (first) {
    800019e6:	00007797          	auipc	a5,0x7
    800019ea:	05a7a783          	lw	a5,90(a5) # 80008a40 <first.1>
    800019ee:	eb89                	bnez	a5,80001a00 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800019f0:	00001097          	auipc	ra,0x1
    800019f4:	156080e7          	jalr	342(ra) # 80002b46 <usertrapret>
}
    800019f8:	60a2                	ld	ra,8(sp)
    800019fa:	6402                	ld	s0,0(sp)
    800019fc:	0141                	addi	sp,sp,16
    800019fe:	8082                	ret
    first = 0;
    80001a00:	00007797          	auipc	a5,0x7
    80001a04:	0407a023          	sw	zero,64(a5) # 80008a40 <first.1>
    fsinit(ROOTDEV);
    80001a08:	4505                	li	a0,1
    80001a0a:	00002097          	auipc	ra,0x2
    80001a0e:	032080e7          	jalr	50(ra) # 80003a3c <fsinit>
    80001a12:	bff9                	j	800019f0 <forkret+0x22>

0000000080001a14 <allocpid>:
allocpid() {
    80001a14:	1101                	addi	sp,sp,-32
    80001a16:	ec06                	sd	ra,24(sp)
    80001a18:	e822                	sd	s0,16(sp)
    80001a1a:	e426                	sd	s1,8(sp)
    80001a1c:	e04a                	sd	s2,0(sp)
    80001a1e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a20:	00010917          	auipc	s2,0x10
    80001a24:	88090913          	addi	s2,s2,-1920 # 800112a0 <pid_lock>
    80001a28:	854a                	mv	a0,s2
    80001a2a:	fffff097          	auipc	ra,0xfffff
    80001a2e:	198080e7          	jalr	408(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001a32:	00007797          	auipc	a5,0x7
    80001a36:	01678793          	addi	a5,a5,22 # 80008a48 <nextpid>
    80001a3a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a3c:	0014871b          	addiw	a4,s1,1
    80001a40:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a42:	854a                	mv	a0,s2
    80001a44:	fffff097          	auipc	ra,0xfffff
    80001a48:	232080e7          	jalr	562(ra) # 80000c76 <release>
}
    80001a4c:	8526                	mv	a0,s1
    80001a4e:	60e2                	ld	ra,24(sp)
    80001a50:	6442                	ld	s0,16(sp)
    80001a52:	64a2                	ld	s1,8(sp)
    80001a54:	6902                	ld	s2,0(sp)
    80001a56:	6105                	addi	sp,sp,32
    80001a58:	8082                	ret

0000000080001a5a <proc_pagetable>:
{
    80001a5a:	1101                	addi	sp,sp,-32
    80001a5c:	ec06                	sd	ra,24(sp)
    80001a5e:	e822                	sd	s0,16(sp)
    80001a60:	e426                	sd	s1,8(sp)
    80001a62:	e04a                	sd	s2,0(sp)
    80001a64:	1000                	addi	s0,sp,32
    80001a66:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a68:	00000097          	auipc	ra,0x0
    80001a6c:	89e080e7          	jalr	-1890(ra) # 80001306 <uvmcreate>
    80001a70:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a72:	c121                	beqz	a0,80001ab2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a74:	4729                	li	a4,10
    80001a76:	00005697          	auipc	a3,0x5
    80001a7a:	58a68693          	addi	a3,a3,1418 # 80007000 <_trampoline>
    80001a7e:	6605                	lui	a2,0x1
    80001a80:	040005b7          	lui	a1,0x4000
    80001a84:	15fd                	addi	a1,a1,-1
    80001a86:	05b2                	slli	a1,a1,0xc
    80001a88:	fffff097          	auipc	ra,0xfffff
    80001a8c:	606080e7          	jalr	1542(ra) # 8000108e <mappages>
    80001a90:	02054863          	bltz	a0,80001ac0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a94:	4719                	li	a4,6
    80001a96:	07893683          	ld	a3,120(s2)
    80001a9a:	6605                	lui	a2,0x1
    80001a9c:	020005b7          	lui	a1,0x2000
    80001aa0:	15fd                	addi	a1,a1,-1
    80001aa2:	05b6                	slli	a1,a1,0xd
    80001aa4:	8526                	mv	a0,s1
    80001aa6:	fffff097          	auipc	ra,0xfffff
    80001aaa:	5e8080e7          	jalr	1512(ra) # 8000108e <mappages>
    80001aae:	02054163          	bltz	a0,80001ad0 <proc_pagetable+0x76>
}
    80001ab2:	8526                	mv	a0,s1
    80001ab4:	60e2                	ld	ra,24(sp)
    80001ab6:	6442                	ld	s0,16(sp)
    80001ab8:	64a2                	ld	s1,8(sp)
    80001aba:	6902                	ld	s2,0(sp)
    80001abc:	6105                	addi	sp,sp,32
    80001abe:	8082                	ret
    uvmfree(pagetable, 0);
    80001ac0:	4581                	li	a1,0
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	00000097          	auipc	ra,0x0
    80001ac8:	a3e080e7          	jalr	-1474(ra) # 80001502 <uvmfree>
    return 0;
    80001acc:	4481                	li	s1,0
    80001ace:	b7d5                	j	80001ab2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ad0:	4681                	li	a3,0
    80001ad2:	4605                	li	a2,1
    80001ad4:	040005b7          	lui	a1,0x4000
    80001ad8:	15fd                	addi	a1,a1,-1
    80001ada:	05b2                	slli	a1,a1,0xc
    80001adc:	8526                	mv	a0,s1
    80001ade:	fffff097          	auipc	ra,0xfffff
    80001ae2:	764080e7          	jalr	1892(ra) # 80001242 <uvmunmap>
    uvmfree(pagetable, 0);
    80001ae6:	4581                	li	a1,0
    80001ae8:	8526                	mv	a0,s1
    80001aea:	00000097          	auipc	ra,0x0
    80001aee:	a18080e7          	jalr	-1512(ra) # 80001502 <uvmfree>
    return 0;
    80001af2:	4481                	li	s1,0
    80001af4:	bf7d                	j	80001ab2 <proc_pagetable+0x58>

0000000080001af6 <proc_freepagetable>:
{
    80001af6:	1101                	addi	sp,sp,-32
    80001af8:	ec06                	sd	ra,24(sp)
    80001afa:	e822                	sd	s0,16(sp)
    80001afc:	e426                	sd	s1,8(sp)
    80001afe:	e04a                	sd	s2,0(sp)
    80001b00:	1000                	addi	s0,sp,32
    80001b02:	84aa                	mv	s1,a0
    80001b04:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b06:	4681                	li	a3,0
    80001b08:	4605                	li	a2,1
    80001b0a:	040005b7          	lui	a1,0x4000
    80001b0e:	15fd                	addi	a1,a1,-1
    80001b10:	05b2                	slli	a1,a1,0xc
    80001b12:	fffff097          	auipc	ra,0xfffff
    80001b16:	730080e7          	jalr	1840(ra) # 80001242 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b1a:	4681                	li	a3,0
    80001b1c:	4605                	li	a2,1
    80001b1e:	020005b7          	lui	a1,0x2000
    80001b22:	15fd                	addi	a1,a1,-1
    80001b24:	05b6                	slli	a1,a1,0xd
    80001b26:	8526                	mv	a0,s1
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	71a080e7          	jalr	1818(ra) # 80001242 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b30:	85ca                	mv	a1,s2
    80001b32:	8526                	mv	a0,s1
    80001b34:	00000097          	auipc	ra,0x0
    80001b38:	9ce080e7          	jalr	-1586(ra) # 80001502 <uvmfree>
}
    80001b3c:	60e2                	ld	ra,24(sp)
    80001b3e:	6442                	ld	s0,16(sp)
    80001b40:	64a2                	ld	s1,8(sp)
    80001b42:	6902                	ld	s2,0(sp)
    80001b44:	6105                	addi	sp,sp,32
    80001b46:	8082                	ret

0000000080001b48 <freeproc>:
{
    80001b48:	1101                	addi	sp,sp,-32
    80001b4a:	ec06                	sd	ra,24(sp)
    80001b4c:	e822                	sd	s0,16(sp)
    80001b4e:	e426                	sd	s1,8(sp)
    80001b50:	1000                	addi	s0,sp,32
    80001b52:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b54:	7d28                	ld	a0,120(a0)
    80001b56:	c509                	beqz	a0,80001b60 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b58:	fffff097          	auipc	ra,0xfffff
    80001b5c:	e7e080e7          	jalr	-386(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    80001b60:	0604bc23          	sd	zero,120(s1)
  if(p->pagetable)
    80001b64:	78a8                	ld	a0,112(s1)
    80001b66:	c511                	beqz	a0,80001b72 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b68:	74ac                	ld	a1,104(s1)
    80001b6a:	00000097          	auipc	ra,0x0
    80001b6e:	f8c080e7          	jalr	-116(ra) # 80001af6 <proc_freepagetable>
  p->pagetable = 0;
    80001b72:	0604b823          	sd	zero,112(s1)
  p->sz = 0;
    80001b76:	0604b423          	sd	zero,104(s1)
  p->pid = 0;
    80001b7a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b7e:	0404bc23          	sd	zero,88(s1)
  p->name[0] = 0;
    80001b82:	16048c23          	sb	zero,376(s1)
  p->chan = 0;
    80001b86:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b8a:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b8e:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b92:	0004ac23          	sw	zero,24(s1)
  p->maskid = 0; //modified
    80001b96:	0204aa23          	sw	zero,52(s1)
}
    80001b9a:	60e2                	ld	ra,24(sp)
    80001b9c:	6442                	ld	s0,16(sp)
    80001b9e:	64a2                	ld	s1,8(sp)
    80001ba0:	6105                	addi	sp,sp,32
    80001ba2:	8082                	ret

0000000080001ba4 <allocproc>:
{
    80001ba4:	1101                	addi	sp,sp,-32
    80001ba6:	ec06                	sd	ra,24(sp)
    80001ba8:	e822                	sd	s0,16(sp)
    80001baa:	e426                	sd	s1,8(sp)
    80001bac:	e04a                	sd	s2,0(sp)
    80001bae:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bb0:	00010497          	auipc	s1,0x10
    80001bb4:	b3848493          	addi	s1,s1,-1224 # 800116e8 <proc>
    80001bb8:	00016917          	auipc	s2,0x16
    80001bbc:	d3090913          	addi	s2,s2,-720 # 800178e8 <tickslock>
    acquire(&p->lock);
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	fffff097          	auipc	ra,0xfffff
    80001bc6:	000080e7          	jalr	ra # 80000bc2 <acquire>
    if(p->state == UNUSED) {
    80001bca:	4c9c                	lw	a5,24(s1)
    80001bcc:	cf81                	beqz	a5,80001be4 <allocproc+0x40>
      release(&p->lock);
    80001bce:	8526                	mv	a0,s1
    80001bd0:	fffff097          	auipc	ra,0xfffff
    80001bd4:	0a6080e7          	jalr	166(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bd8:	18848493          	addi	s1,s1,392
    80001bdc:	ff2492e3          	bne	s1,s2,80001bc0 <allocproc+0x1c>
  return 0;
    80001be0:	4481                	li	s1,0
    80001be2:	a88d                	j	80001c54 <allocproc+0xb0>
  p->pid = allocpid();
    80001be4:	00000097          	auipc	ra,0x0
    80001be8:	e30080e7          	jalr	-464(ra) # 80001a14 <allocpid>
    80001bec:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bee:	4785                	li	a5,1
    80001bf0:	cc9c                	sw	a5,24(s1)
  p->ctime = ticks; 
    80001bf2:	00007797          	auipc	a5,0x7
    80001bf6:	43e7a783          	lw	a5,1086(a5) # 80009030 <ticks>
    80001bfa:	dc9c                	sw	a5,56(s1)
  p->stime =0;      
    80001bfc:	0404a023          	sw	zero,64(s1)
  p->retime =0;     
    80001c00:	0404a223          	sw	zero,68(s1)
  p->rutime=0;      
    80001c04:	0404a423          	sw	zero,72(s1)
  p->ttime = 0;     
    80001c08:	0204ae23          	sw	zero,60(s1)
  p->average_bursttime = QUANTUM*100;
    80001c0c:	1f400793          	li	a5,500
    80001c10:	c4fc                	sw	a5,76(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c12:	fffff097          	auipc	ra,0xfffff
    80001c16:	ec0080e7          	jalr	-320(ra) # 80000ad2 <kalloc>
    80001c1a:	892a                	mv	s2,a0
    80001c1c:	fca8                	sd	a0,120(s1)
    80001c1e:	c131                	beqz	a0,80001c62 <allocproc+0xbe>
  p->pagetable = proc_pagetable(p);
    80001c20:	8526                	mv	a0,s1
    80001c22:	00000097          	auipc	ra,0x0
    80001c26:	e38080e7          	jalr	-456(ra) # 80001a5a <proc_pagetable>
    80001c2a:	892a                	mv	s2,a0
    80001c2c:	f8a8                	sd	a0,112(s1)
  if(p->pagetable == 0){
    80001c2e:	c531                	beqz	a0,80001c7a <allocproc+0xd6>
  memset(&p->context, 0, sizeof(p->context));
    80001c30:	07000613          	li	a2,112
    80001c34:	4581                	li	a1,0
    80001c36:	08048513          	addi	a0,s1,128
    80001c3a:	fffff097          	auipc	ra,0xfffff
    80001c3e:	084080e7          	jalr	132(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    80001c42:	00000797          	auipc	a5,0x0
    80001c46:	d8c78793          	addi	a5,a5,-628 # 800019ce <forkret>
    80001c4a:	e0dc                	sd	a5,128(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c4c:	70bc                	ld	a5,96(s1)
    80001c4e:	6705                	lui	a4,0x1
    80001c50:	97ba                	add	a5,a5,a4
    80001c52:	e4dc                	sd	a5,136(s1)
}
    80001c54:	8526                	mv	a0,s1
    80001c56:	60e2                	ld	ra,24(sp)
    80001c58:	6442                	ld	s0,16(sp)
    80001c5a:	64a2                	ld	s1,8(sp)
    80001c5c:	6902                	ld	s2,0(sp)
    80001c5e:	6105                	addi	sp,sp,32
    80001c60:	8082                	ret
    freeproc(p);
    80001c62:	8526                	mv	a0,s1
    80001c64:	00000097          	auipc	ra,0x0
    80001c68:	ee4080e7          	jalr	-284(ra) # 80001b48 <freeproc>
    release(&p->lock);
    80001c6c:	8526                	mv	a0,s1
    80001c6e:	fffff097          	auipc	ra,0xfffff
    80001c72:	008080e7          	jalr	8(ra) # 80000c76 <release>
    return 0;
    80001c76:	84ca                	mv	s1,s2
    80001c78:	bff1                	j	80001c54 <allocproc+0xb0>
    freeproc(p);
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	00000097          	auipc	ra,0x0
    80001c80:	ecc080e7          	jalr	-308(ra) # 80001b48 <freeproc>
    release(&p->lock);
    80001c84:	8526                	mv	a0,s1
    80001c86:	fffff097          	auipc	ra,0xfffff
    80001c8a:	ff0080e7          	jalr	-16(ra) # 80000c76 <release>
    return 0;
    80001c8e:	84ca                	mv	s1,s2
    80001c90:	b7d1                	j	80001c54 <allocproc+0xb0>

0000000080001c92 <userinit>:
{
    80001c92:	1101                	addi	sp,sp,-32
    80001c94:	ec06                	sd	ra,24(sp)
    80001c96:	e822                	sd	s0,16(sp)
    80001c98:	e426                	sd	s1,8(sp)
    80001c9a:	e04a                	sd	s2,0(sp)
    80001c9c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c9e:	00000097          	auipc	ra,0x0
    80001ca2:	f06080e7          	jalr	-250(ra) # 80001ba4 <allocproc>
    80001ca6:	84aa                	mv	s1,a0
  initproc = p;
    80001ca8:	00007797          	auipc	a5,0x7
    80001cac:	38a7b023          	sd	a0,896(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001cb0:	03400613          	li	a2,52
    80001cb4:	00007597          	auipc	a1,0x7
    80001cb8:	d9c58593          	addi	a1,a1,-612 # 80008a50 <initcode>
    80001cbc:	7928                	ld	a0,112(a0)
    80001cbe:	fffff097          	auipc	ra,0xfffff
    80001cc2:	676080e7          	jalr	1654(ra) # 80001334 <uvminit>
  p->sz = PGSIZE;
    80001cc6:	6785                	lui	a5,0x1
    80001cc8:	f4bc                	sd	a5,104(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cca:	7cb8                	ld	a4,120(s1)
    80001ccc:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cd0:	7cb8                	ld	a4,120(s1)
    80001cd2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cd4:	4641                	li	a2,16
    80001cd6:	00006597          	auipc	a1,0x6
    80001cda:	52258593          	addi	a1,a1,1314 # 800081f8 <digits+0x1b8>
    80001cde:	17848513          	addi	a0,s1,376
    80001ce2:	fffff097          	auipc	ra,0xfffff
    80001ce6:	12e080e7          	jalr	302(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    80001cea:	00006517          	auipc	a0,0x6
    80001cee:	51e50513          	addi	a0,a0,1310 # 80008208 <digits+0x1c8>
    80001cf2:	00002097          	auipc	ra,0x2
    80001cf6:	778080e7          	jalr	1912(ra) # 8000446a <namei>
    80001cfa:	16a4b823          	sd	a0,368(s1)
  p->state = RUNNABLE;
    80001cfe:	478d                	li	a5,3
    80001d00:	cc9c                	sw	a5,24(s1)
  printf("here?\n");
    80001d02:	00006517          	auipc	a0,0x6
    80001d06:	50e50513          	addi	a0,a0,1294 # 80008210 <digits+0x1d0>
    80001d0a:	fffff097          	auipc	ra,0xfffff
    80001d0e:	86a080e7          	jalr	-1942(ra) # 80000574 <printf>
  acquire(&queue_lock);
    80001d12:	0000f917          	auipc	s2,0xf
    80001d16:	5be90913          	addi	s2,s2,1470 # 800112d0 <queue_lock>
    80001d1a:	854a                	mv	a0,s2
    80001d1c:	fffff097          	auipc	ra,0xfffff
    80001d20:	ea6080e7          	jalr	-346(ra) # 80000bc2 <acquire>
  p->queue_location = queue_counter;
    80001d24:	00007717          	auipc	a4,0x7
    80001d28:	d2070713          	addi	a4,a4,-736 # 80008a44 <queue_counter>
    80001d2c:	431c                	lw	a5,0(a4)
    80001d2e:	c8bc                	sw	a5,80(s1)
  queue_counter++;
    80001d30:	2785                	addiw	a5,a5,1
    80001d32:	c31c                	sw	a5,0(a4)
  release(&queue_lock);
    80001d34:	854a                	mv	a0,s2
    80001d36:	fffff097          	auipc	ra,0xfffff
    80001d3a:	f40080e7          	jalr	-192(ra) # 80000c76 <release>
  release(&p->lock);
    80001d3e:	8526                	mv	a0,s1
    80001d40:	fffff097          	auipc	ra,0xfffff
    80001d44:	f36080e7          	jalr	-202(ra) # 80000c76 <release>
}
    80001d48:	60e2                	ld	ra,24(sp)
    80001d4a:	6442                	ld	s0,16(sp)
    80001d4c:	64a2                	ld	s1,8(sp)
    80001d4e:	6902                	ld	s2,0(sp)
    80001d50:	6105                	addi	sp,sp,32
    80001d52:	8082                	ret

0000000080001d54 <growproc>:
{
    80001d54:	1101                	addi	sp,sp,-32
    80001d56:	ec06                	sd	ra,24(sp)
    80001d58:	e822                	sd	s0,16(sp)
    80001d5a:	e426                	sd	s1,8(sp)
    80001d5c:	e04a                	sd	s2,0(sp)
    80001d5e:	1000                	addi	s0,sp,32
    80001d60:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d62:	00000097          	auipc	ra,0x0
    80001d66:	c34080e7          	jalr	-972(ra) # 80001996 <myproc>
    80001d6a:	892a                	mv	s2,a0
  sz = p->sz;
    80001d6c:	752c                	ld	a1,104(a0)
    80001d6e:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d72:	00904f63          	bgtz	s1,80001d90 <growproc+0x3c>
  } else if(n < 0){
    80001d76:	0204cc63          	bltz	s1,80001dae <growproc+0x5a>
  p->sz = sz;
    80001d7a:	1602                	slli	a2,a2,0x20
    80001d7c:	9201                	srli	a2,a2,0x20
    80001d7e:	06c93423          	sd	a2,104(s2)
  return 0;
    80001d82:	4501                	li	a0,0
}
    80001d84:	60e2                	ld	ra,24(sp)
    80001d86:	6442                	ld	s0,16(sp)
    80001d88:	64a2                	ld	s1,8(sp)
    80001d8a:	6902                	ld	s2,0(sp)
    80001d8c:	6105                	addi	sp,sp,32
    80001d8e:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d90:	9e25                	addw	a2,a2,s1
    80001d92:	1602                	slli	a2,a2,0x20
    80001d94:	9201                	srli	a2,a2,0x20
    80001d96:	1582                	slli	a1,a1,0x20
    80001d98:	9181                	srli	a1,a1,0x20
    80001d9a:	7928                	ld	a0,112(a0)
    80001d9c:	fffff097          	auipc	ra,0xfffff
    80001da0:	652080e7          	jalr	1618(ra) # 800013ee <uvmalloc>
    80001da4:	0005061b          	sext.w	a2,a0
    80001da8:	fa69                	bnez	a2,80001d7a <growproc+0x26>
      return -1;
    80001daa:	557d                	li	a0,-1
    80001dac:	bfe1                	j	80001d84 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dae:	9e25                	addw	a2,a2,s1
    80001db0:	1602                	slli	a2,a2,0x20
    80001db2:	9201                	srli	a2,a2,0x20
    80001db4:	1582                	slli	a1,a1,0x20
    80001db6:	9181                	srli	a1,a1,0x20
    80001db8:	7928                	ld	a0,112(a0)
    80001dba:	fffff097          	auipc	ra,0xfffff
    80001dbe:	5ec080e7          	jalr	1516(ra) # 800013a6 <uvmdealloc>
    80001dc2:	0005061b          	sext.w	a2,a0
    80001dc6:	bf55                	j	80001d7a <growproc+0x26>

0000000080001dc8 <fork>:
{
    80001dc8:	7139                	addi	sp,sp,-64
    80001dca:	fc06                	sd	ra,56(sp)
    80001dcc:	f822                	sd	s0,48(sp)
    80001dce:	f426                	sd	s1,40(sp)
    80001dd0:	f04a                	sd	s2,32(sp)
    80001dd2:	ec4e                	sd	s3,24(sp)
    80001dd4:	e852                	sd	s4,16(sp)
    80001dd6:	e456                	sd	s5,8(sp)
    80001dd8:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001dda:	00000097          	auipc	ra,0x0
    80001dde:	bbc080e7          	jalr	-1092(ra) # 80001996 <myproc>
    80001de2:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001de4:	00000097          	auipc	ra,0x0
    80001de8:	dc0080e7          	jalr	-576(ra) # 80001ba4 <allocproc>
    80001dec:	14050763          	beqz	a0,80001f3a <fork+0x172>
    80001df0:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001df2:	068ab603          	ld	a2,104(s5)
    80001df6:	792c                	ld	a1,112(a0)
    80001df8:	070ab503          	ld	a0,112(s5)
    80001dfc:	fffff097          	auipc	ra,0xfffff
    80001e00:	73e080e7          	jalr	1854(ra) # 8000153a <uvmcopy>
    80001e04:	04054c63          	bltz	a0,80001e5c <fork+0x94>
  np->sz = p->sz;
    80001e08:	068ab783          	ld	a5,104(s5)
    80001e0c:	06f9b423          	sd	a5,104(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e10:	078ab683          	ld	a3,120(s5)
    80001e14:	87b6                	mv	a5,a3
    80001e16:	0789b703          	ld	a4,120(s3)
    80001e1a:	12068693          	addi	a3,a3,288
    80001e1e:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e22:	6788                	ld	a0,8(a5)
    80001e24:	6b8c                	ld	a1,16(a5)
    80001e26:	6f90                	ld	a2,24(a5)
    80001e28:	01073023          	sd	a6,0(a4)
    80001e2c:	e708                	sd	a0,8(a4)
    80001e2e:	eb0c                	sd	a1,16(a4)
    80001e30:	ef10                	sd	a2,24(a4)
    80001e32:	02078793          	addi	a5,a5,32
    80001e36:	02070713          	addi	a4,a4,32
    80001e3a:	fed792e3          	bne	a5,a3,80001e1e <fork+0x56>
  (np-> maskid) =  (p->maskid); // modified
    80001e3e:	034aa783          	lw	a5,52(s5)
    80001e42:	02f9aa23          	sw	a5,52(s3)
  np->trapframe->a0 = 0;
    80001e46:	0789b783          	ld	a5,120(s3)
    80001e4a:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e4e:	0f0a8493          	addi	s1,s5,240
    80001e52:	0f098913          	addi	s2,s3,240
    80001e56:	170a8a13          	addi	s4,s5,368
    80001e5a:	a00d                	j	80001e7c <fork+0xb4>
    freeproc(np);
    80001e5c:	854e                	mv	a0,s3
    80001e5e:	00000097          	auipc	ra,0x0
    80001e62:	cea080e7          	jalr	-790(ra) # 80001b48 <freeproc>
    release(&np->lock);
    80001e66:	854e                	mv	a0,s3
    80001e68:	fffff097          	auipc	ra,0xfffff
    80001e6c:	e0e080e7          	jalr	-498(ra) # 80000c76 <release>
    return -1;
    80001e70:	597d                	li	s2,-1
    80001e72:	a855                	j	80001f26 <fork+0x15e>
  for(i = 0; i < NOFILE; i++)
    80001e74:	04a1                	addi	s1,s1,8
    80001e76:	0921                	addi	s2,s2,8
    80001e78:	01448b63          	beq	s1,s4,80001e8e <fork+0xc6>
    if(p->ofile[i])
    80001e7c:	6088                	ld	a0,0(s1)
    80001e7e:	d97d                	beqz	a0,80001e74 <fork+0xac>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e80:	00003097          	auipc	ra,0x3
    80001e84:	c84080e7          	jalr	-892(ra) # 80004b04 <filedup>
    80001e88:	00a93023          	sd	a0,0(s2)
    80001e8c:	b7e5                	j	80001e74 <fork+0xac>
  np->cwd = idup(p->cwd);
    80001e8e:	170ab503          	ld	a0,368(s5)
    80001e92:	00002097          	auipc	ra,0x2
    80001e96:	de4080e7          	jalr	-540(ra) # 80003c76 <idup>
    80001e9a:	16a9b823          	sd	a0,368(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e9e:	4641                	li	a2,16
    80001ea0:	178a8593          	addi	a1,s5,376
    80001ea4:	17898513          	addi	a0,s3,376
    80001ea8:	fffff097          	auipc	ra,0xfffff
    80001eac:	f68080e7          	jalr	-152(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    80001eb0:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001eb4:	854e                	mv	a0,s3
    80001eb6:	fffff097          	auipc	ra,0xfffff
    80001eba:	dc0080e7          	jalr	-576(ra) # 80000c76 <release>
  acquire(&wait_lock);
    80001ebe:	0000f497          	auipc	s1,0xf
    80001ec2:	3fa48493          	addi	s1,s1,1018 # 800112b8 <wait_lock>
    80001ec6:	8526                	mv	a0,s1
    80001ec8:	fffff097          	auipc	ra,0xfffff
    80001ecc:	cfa080e7          	jalr	-774(ra) # 80000bc2 <acquire>
  np->parent = p;
    80001ed0:	0559bc23          	sd	s5,88(s3)
  release(&wait_lock);
    80001ed4:	8526                	mv	a0,s1
    80001ed6:	fffff097          	auipc	ra,0xfffff
    80001eda:	da0080e7          	jalr	-608(ra) # 80000c76 <release>
  acquire(&np->lock);
    80001ede:	854e                	mv	a0,s3
    80001ee0:	fffff097          	auipc	ra,0xfffff
    80001ee4:	ce2080e7          	jalr	-798(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    80001ee8:	478d                	li	a5,3
    80001eea:	00f9ac23          	sw	a5,24(s3)
  acquire(&queue_lock);
    80001eee:	0000f497          	auipc	s1,0xf
    80001ef2:	3e248493          	addi	s1,s1,994 # 800112d0 <queue_lock>
    80001ef6:	8526                	mv	a0,s1
    80001ef8:	fffff097          	auipc	ra,0xfffff
    80001efc:	cca080e7          	jalr	-822(ra) # 80000bc2 <acquire>
  np->queue_location = queue_counter;
    80001f00:	00007717          	auipc	a4,0x7
    80001f04:	b4470713          	addi	a4,a4,-1212 # 80008a44 <queue_counter>
    80001f08:	431c                	lw	a5,0(a4)
    80001f0a:	04f9a823          	sw	a5,80(s3)
  queue_counter++;
    80001f0e:	2785                	addiw	a5,a5,1
    80001f10:	c31c                	sw	a5,0(a4)
  release(&queue_lock);
    80001f12:	8526                	mv	a0,s1
    80001f14:	fffff097          	auipc	ra,0xfffff
    80001f18:	d62080e7          	jalr	-670(ra) # 80000c76 <release>
  release(&np->lock);
    80001f1c:	854e                	mv	a0,s3
    80001f1e:	fffff097          	auipc	ra,0xfffff
    80001f22:	d58080e7          	jalr	-680(ra) # 80000c76 <release>
}
    80001f26:	854a                	mv	a0,s2
    80001f28:	70e2                	ld	ra,56(sp)
    80001f2a:	7442                	ld	s0,48(sp)
    80001f2c:	74a2                	ld	s1,40(sp)
    80001f2e:	7902                	ld	s2,32(sp)
    80001f30:	69e2                	ld	s3,24(sp)
    80001f32:	6a42                	ld	s4,16(sp)
    80001f34:	6aa2                	ld	s5,8(sp)
    80001f36:	6121                	addi	sp,sp,64
    80001f38:	8082                	ret
    return -1;
    80001f3a:	597d                	li	s2,-1
    80001f3c:	b7ed                	j	80001f26 <fork+0x15e>

0000000080001f3e <scheduler>:
{
    80001f3e:	7175                	addi	sp,sp,-144
    80001f40:	e506                	sd	ra,136(sp)
    80001f42:	e122                	sd	s0,128(sp)
    80001f44:	fca6                	sd	s1,120(sp)
    80001f46:	f8ca                	sd	s2,112(sp)
    80001f48:	f4ce                	sd	s3,104(sp)
    80001f4a:	f0d2                	sd	s4,96(sp)
    80001f4c:	ecd6                	sd	s5,88(sp)
    80001f4e:	e8da                	sd	s6,80(sp)
    80001f50:	e4de                	sd	s7,72(sp)
    80001f52:	e0e2                	sd	s8,64(sp)
    80001f54:	fc66                	sd	s9,56(sp)
    80001f56:	f86a                	sd	s10,48(sp)
    80001f58:	f46e                	sd	s11,40(sp)
    80001f5a:	0900                	addi	s0,sp,144
    80001f5c:	8792                	mv	a5,tp
  int id = r_tp();
    80001f5e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f60:	00779693          	slli	a3,a5,0x7
    80001f64:	0000f717          	auipc	a4,0xf
    80001f68:	33c70713          	addi	a4,a4,828 # 800112a0 <pid_lock>
    80001f6c:	9736                	add	a4,a4,a3
    80001f6e:	04073423          	sd	zero,72(a4)
          swtch(&c->context, &proc_for_exec->context);
    80001f72:	0000f717          	auipc	a4,0xf
    80001f76:	37e70713          	addi	a4,a4,894 # 800112f0 <cpus+0x8>
    80001f7a:	9736                	add	a4,a4,a3
    80001f7c:	f8e43023          	sd	a4,-128(s0)
      int next_proc_for_exec=INT_MAX;
    80001f80:	80000737          	lui	a4,0x80000
    80001f84:	fff74713          	not	a4,a4
    80001f88:	f8e43423          	sd	a4,-120(s0)
        acquire(&queue_lock);
    80001f8c:	0000f997          	auipc	s3,0xf
    80001f90:	34498993          	addi	s3,s3,836 # 800112d0 <queue_lock>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001f94:	00016b17          	auipc	s6,0x16
    80001f98:	954b0b13          	addi	s6,s6,-1708 # 800178e8 <tickslock>
          c->proc = proc_for_exec;
    80001f9c:	0000f717          	auipc	a4,0xf
    80001fa0:	30470713          	addi	a4,a4,772 # 800112a0 <pid_lock>
    80001fa4:	00d707b3          	add	a5,a4,a3
    80001fa8:	f6f43c23          	sd	a5,-136(s0)
    80001fac:	a8c9                	j	8000207e <scheduler+0x140>
        release(&queue_lock);
    80001fae:	854e                	mv	a0,s3
    80001fb0:	fffff097          	auipc	ra,0xfffff
    80001fb4:	cc6080e7          	jalr	-826(ra) # 80000c76 <release>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001fb8:	036a7d63          	bgeu	s4,s6,80001ff2 <scheduler+0xb4>
    80001fbc:	18848493          	addi	s1,s1,392
    80001fc0:	e7848a93          	addi	s5,s1,-392
        acquire(&queue_lock);
    80001fc4:	854e                	mv	a0,s3
    80001fc6:	fffff097          	auipc	ra,0xfffff
    80001fca:	bfc080e7          	jalr	-1028(ra) # 80000bc2 <acquire>
        if (( (p->queue_location) >= min_search_index) && ( (p->queue_location) < next_proc_for_exec )){
    80001fce:	8a26                	mv	s4,s1
    80001fd0:	ec84a903          	lw	s2,-312(s1)
    80001fd4:	fd205de3          	blez	s2,80001fae <scheduler+0x70>
    80001fd8:	fd795be3          	bge	s2,s7,80001fae <scheduler+0x70>
        release(&queue_lock);
    80001fdc:	854e                	mv	a0,s3
    80001fde:	fffff097          	auipc	ra,0xfffff
    80001fe2:	c98080e7          	jalr	-872(ra) # 80000c76 <release>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001fe6:	0364f863          	bgeu	s1,s6,80002016 <scheduler+0xd8>
    80001fea:	8cd6                	mv	s9,s5
          next_proc_for_exec=p->queue_location;
    80001fec:	8bca                	mv	s7,s2
          init_proc_for_exec=1;
    80001fee:	8c6a                	mv	s8,s10
    80001ff0:	b7f1                	j	80001fbc <scheduler+0x7e>
      if (init_proc_for_exec == 1){
    80001ff2:	03ac0163          	beq	s8,s10,80002014 <scheduler+0xd6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ff6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ffa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ffe:	10079073          	csrw	sstatus,a5
      for(p = proc; p < &proc[NPROC]; p++) {
    80002002:	00010497          	auipc	s1,0x10
    80002006:	86e48493          	addi	s1,s1,-1938 # 80011870 <proc+0x188>
      int init_proc_for_exec=0;
    8000200a:	8c6e                	mv	s8,s11
      struct proc *proc_for_exec=0;
    8000200c:	8cee                	mv	s9,s11
      int next_proc_for_exec=INT_MAX;
    8000200e:	f8843b83          	ld	s7,-120(s0)
    80002012:	b77d                	j	80001fc0 <scheduler+0x82>
    80002014:	8ae6                	mv	s5,s9
        acquire(&proc_for_exec->lock);
    80002016:	84d6                	mv	s1,s5
    80002018:	8556                	mv	a0,s5
    8000201a:	fffff097          	auipc	ra,0xfffff
    8000201e:	ba8080e7          	jalr	-1112(ra) # 80000bc2 <acquire>
        if(proc_for_exec->state == RUNNABLE) {
    80002022:	018aa703          	lw	a4,24(s5)
    80002026:	478d                	li	a5,3
    80002028:	04f71663          	bne	a4,a5,80002074 <scheduler+0x136>
          acquire(&queue_lock);
    8000202c:	854e                	mv	a0,s3
    8000202e:	fffff097          	auipc	ra,0xfffff
    80002032:	b94080e7          	jalr	-1132(ra) # 80000bc2 <acquire>
          p->queue_location = queue_counter;
    80002036:	00007717          	auipc	a4,0x7
    8000203a:	a0e70713          	addi	a4,a4,-1522 # 80008a44 <queue_counter>
    8000203e:	431c                	lw	a5,0(a4)
    80002040:	04fa2823          	sw	a5,80(s4)
          queue_counter++;
    80002044:	2785                	addiw	a5,a5,1
    80002046:	c31c                	sw	a5,0(a4)
          release(&queue_lock);
    80002048:	854e                	mv	a0,s3
    8000204a:	fffff097          	auipc	ra,0xfffff
    8000204e:	c2c080e7          	jalr	-980(ra) # 80000c76 <release>
          proc_for_exec->state = RUNNING;
    80002052:	4791                	li	a5,4
    80002054:	00faac23          	sw	a5,24(s5)
          c->proc = proc_for_exec;
    80002058:	f7843903          	ld	s2,-136(s0)
    8000205c:	05593423          	sd	s5,72(s2)
          swtch(&c->context, &proc_for_exec->context);
    80002060:	080a8593          	addi	a1,s5,128
    80002064:	f8043503          	ld	a0,-128(s0)
    80002068:	00001097          	auipc	ra,0x1
    8000206c:	a34080e7          	jalr	-1484(ra) # 80002a9c <swtch>
          c->proc = 0;
    80002070:	04093423          	sd	zero,72(s2)
        release(&proc_for_exec->lock);
    80002074:	8526                	mv	a0,s1
    80002076:	fffff097          	auipc	ra,0xfffff
    8000207a:	c00080e7          	jalr	-1024(ra) # 80000c76 <release>
      int init_proc_for_exec=0;
    8000207e:	4d81                	li	s11,0
          init_proc_for_exec=1;
    80002080:	4d05                	li	s10,1
    80002082:	bf95                	j	80001ff6 <scheduler+0xb8>

0000000080002084 <sched>:
{
    80002084:	7179                	addi	sp,sp,-48
    80002086:	f406                	sd	ra,40(sp)
    80002088:	f022                	sd	s0,32(sp)
    8000208a:	ec26                	sd	s1,24(sp)
    8000208c:	e84a                	sd	s2,16(sp)
    8000208e:	e44e                	sd	s3,8(sp)
    80002090:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002092:	00000097          	auipc	ra,0x0
    80002096:	904080e7          	jalr	-1788(ra) # 80001996 <myproc>
    8000209a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000209c:	fffff097          	auipc	ra,0xfffff
    800020a0:	aac080e7          	jalr	-1364(ra) # 80000b48 <holding>
    800020a4:	c93d                	beqz	a0,8000211a <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020a6:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800020a8:	2781                	sext.w	a5,a5
    800020aa:	079e                	slli	a5,a5,0x7
    800020ac:	0000f717          	auipc	a4,0xf
    800020b0:	1f470713          	addi	a4,a4,500 # 800112a0 <pid_lock>
    800020b4:	97ba                	add	a5,a5,a4
    800020b6:	0c07a703          	lw	a4,192(a5)
    800020ba:	4785                	li	a5,1
    800020bc:	06f71763          	bne	a4,a5,8000212a <sched+0xa6>
  if(p->state == RUNNING)
    800020c0:	4c98                	lw	a4,24(s1)
    800020c2:	4791                	li	a5,4
    800020c4:	06f70b63          	beq	a4,a5,8000213a <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020c8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020cc:	8b89                	andi	a5,a5,2
  if(intr_get())
    800020ce:	efb5                	bnez	a5,8000214a <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020d0:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020d2:	0000f917          	auipc	s2,0xf
    800020d6:	1ce90913          	addi	s2,s2,462 # 800112a0 <pid_lock>
    800020da:	2781                	sext.w	a5,a5
    800020dc:	079e                	slli	a5,a5,0x7
    800020de:	97ca                	add	a5,a5,s2
    800020e0:	0c47a983          	lw	s3,196(a5)
    800020e4:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020e6:	2781                	sext.w	a5,a5
    800020e8:	079e                	slli	a5,a5,0x7
    800020ea:	0000f597          	auipc	a1,0xf
    800020ee:	20658593          	addi	a1,a1,518 # 800112f0 <cpus+0x8>
    800020f2:	95be                	add	a1,a1,a5
    800020f4:	08048513          	addi	a0,s1,128
    800020f8:	00001097          	auipc	ra,0x1
    800020fc:	9a4080e7          	jalr	-1628(ra) # 80002a9c <swtch>
    80002100:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002102:	2781                	sext.w	a5,a5
    80002104:	079e                	slli	a5,a5,0x7
    80002106:	97ca                	add	a5,a5,s2
    80002108:	0d37a223          	sw	s3,196(a5)
}
    8000210c:	70a2                	ld	ra,40(sp)
    8000210e:	7402                	ld	s0,32(sp)
    80002110:	64e2                	ld	s1,24(sp)
    80002112:	6942                	ld	s2,16(sp)
    80002114:	69a2                	ld	s3,8(sp)
    80002116:	6145                	addi	sp,sp,48
    80002118:	8082                	ret
    panic("sched p->lock");
    8000211a:	00006517          	auipc	a0,0x6
    8000211e:	0fe50513          	addi	a0,a0,254 # 80008218 <digits+0x1d8>
    80002122:	ffffe097          	auipc	ra,0xffffe
    80002126:	408080e7          	jalr	1032(ra) # 8000052a <panic>
    panic("sched locks");
    8000212a:	00006517          	auipc	a0,0x6
    8000212e:	0fe50513          	addi	a0,a0,254 # 80008228 <digits+0x1e8>
    80002132:	ffffe097          	auipc	ra,0xffffe
    80002136:	3f8080e7          	jalr	1016(ra) # 8000052a <panic>
    panic("sched running");
    8000213a:	00006517          	auipc	a0,0x6
    8000213e:	0fe50513          	addi	a0,a0,254 # 80008238 <digits+0x1f8>
    80002142:	ffffe097          	auipc	ra,0xffffe
    80002146:	3e8080e7          	jalr	1000(ra) # 8000052a <panic>
    panic("sched interruptible");
    8000214a:	00006517          	auipc	a0,0x6
    8000214e:	0fe50513          	addi	a0,a0,254 # 80008248 <digits+0x208>
    80002152:	ffffe097          	auipc	ra,0xffffe
    80002156:	3d8080e7          	jalr	984(ra) # 8000052a <panic>

000000008000215a <yield>:
{
    8000215a:	1101                	addi	sp,sp,-32
    8000215c:	ec06                	sd	ra,24(sp)
    8000215e:	e822                	sd	s0,16(sp)
    80002160:	e426                	sd	s1,8(sp)
    80002162:	e04a                	sd	s2,0(sp)
    80002164:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002166:	00000097          	auipc	ra,0x0
    8000216a:	830080e7          	jalr	-2000(ra) # 80001996 <myproc>
    8000216e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002170:	fffff097          	auipc	ra,0xfffff
    80002174:	a52080e7          	jalr	-1454(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    80002178:	478d                	li	a5,3
    8000217a:	cc9c                	sw	a5,24(s1)
  acquire(&queue_lock);
    8000217c:	0000f917          	auipc	s2,0xf
    80002180:	15490913          	addi	s2,s2,340 # 800112d0 <queue_lock>
    80002184:	854a                	mv	a0,s2
    80002186:	fffff097          	auipc	ra,0xfffff
    8000218a:	a3c080e7          	jalr	-1476(ra) # 80000bc2 <acquire>
  p->queue_location = queue_counter;
    8000218e:	00007717          	auipc	a4,0x7
    80002192:	8b670713          	addi	a4,a4,-1866 # 80008a44 <queue_counter>
    80002196:	431c                	lw	a5,0(a4)
    80002198:	c8bc                	sw	a5,80(s1)
  queue_counter++;
    8000219a:	2785                	addiw	a5,a5,1
    8000219c:	c31c                	sw	a5,0(a4)
  release(&queue_lock);
    8000219e:	854a                	mv	a0,s2
    800021a0:	fffff097          	auipc	ra,0xfffff
    800021a4:	ad6080e7          	jalr	-1322(ra) # 80000c76 <release>
  sched();
    800021a8:	00000097          	auipc	ra,0x0
    800021ac:	edc080e7          	jalr	-292(ra) # 80002084 <sched>
  release(&p->lock);
    800021b0:	8526                	mv	a0,s1
    800021b2:	fffff097          	auipc	ra,0xfffff
    800021b6:	ac4080e7          	jalr	-1340(ra) # 80000c76 <release>
}
    800021ba:	60e2                	ld	ra,24(sp)
    800021bc:	6442                	ld	s0,16(sp)
    800021be:	64a2                	ld	s1,8(sp)
    800021c0:	6902                	ld	s2,0(sp)
    800021c2:	6105                	addi	sp,sp,32
    800021c4:	8082                	ret

00000000800021c6 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800021c6:	7179                	addi	sp,sp,-48
    800021c8:	f406                	sd	ra,40(sp)
    800021ca:	f022                	sd	s0,32(sp)
    800021cc:	ec26                	sd	s1,24(sp)
    800021ce:	e84a                	sd	s2,16(sp)
    800021d0:	e44e                	sd	s3,8(sp)
    800021d2:	1800                	addi	s0,sp,48
    800021d4:	89aa                	mv	s3,a0
    800021d6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800021d8:	fffff097          	auipc	ra,0xfffff
    800021dc:	7be080e7          	jalr	1982(ra) # 80001996 <myproc>
    800021e0:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800021e2:	fffff097          	auipc	ra,0xfffff
    800021e6:	9e0080e7          	jalr	-1568(ra) # 80000bc2 <acquire>
  release(lk);
    800021ea:	854a                	mv	a0,s2
    800021ec:	fffff097          	auipc	ra,0xfffff
    800021f0:	a8a080e7          	jalr	-1398(ra) # 80000c76 <release>

  // Go to sleep.
  p->chan = chan;
    800021f4:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800021f8:	4789                	li	a5,2
    800021fa:	cc9c                	sw	a5,24(s1)

  sched();
    800021fc:	00000097          	auipc	ra,0x0
    80002200:	e88080e7          	jalr	-376(ra) # 80002084 <sched>

  // Tidy up.
  p->chan = 0;
    80002204:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002208:	8526                	mv	a0,s1
    8000220a:	fffff097          	auipc	ra,0xfffff
    8000220e:	a6c080e7          	jalr	-1428(ra) # 80000c76 <release>
  acquire(lk);
    80002212:	854a                	mv	a0,s2
    80002214:	fffff097          	auipc	ra,0xfffff
    80002218:	9ae080e7          	jalr	-1618(ra) # 80000bc2 <acquire>
}
    8000221c:	70a2                	ld	ra,40(sp)
    8000221e:	7402                	ld	s0,32(sp)
    80002220:	64e2                	ld	s1,24(sp)
    80002222:	6942                	ld	s2,16(sp)
    80002224:	69a2                	ld	s3,8(sp)
    80002226:	6145                	addi	sp,sp,48
    80002228:	8082                	ret

000000008000222a <wait>:
{
    8000222a:	715d                	addi	sp,sp,-80
    8000222c:	e486                	sd	ra,72(sp)
    8000222e:	e0a2                	sd	s0,64(sp)
    80002230:	fc26                	sd	s1,56(sp)
    80002232:	f84a                	sd	s2,48(sp)
    80002234:	f44e                	sd	s3,40(sp)
    80002236:	f052                	sd	s4,32(sp)
    80002238:	ec56                	sd	s5,24(sp)
    8000223a:	e85a                	sd	s6,16(sp)
    8000223c:	e45e                	sd	s7,8(sp)
    8000223e:	e062                	sd	s8,0(sp)
    80002240:	0880                	addi	s0,sp,80
    80002242:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002244:	fffff097          	auipc	ra,0xfffff
    80002248:	752080e7          	jalr	1874(ra) # 80001996 <myproc>
    8000224c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000224e:	0000f517          	auipc	a0,0xf
    80002252:	06a50513          	addi	a0,a0,106 # 800112b8 <wait_lock>
    80002256:	fffff097          	auipc	ra,0xfffff
    8000225a:	96c080e7          	jalr	-1684(ra) # 80000bc2 <acquire>
    havekids = 0;
    8000225e:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002260:	4a15                	li	s4,5
        havekids = 1;
    80002262:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002264:	00015997          	auipc	s3,0x15
    80002268:	68498993          	addi	s3,s3,1668 # 800178e8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000226c:	0000fc17          	auipc	s8,0xf
    80002270:	04cc0c13          	addi	s8,s8,76 # 800112b8 <wait_lock>
    havekids = 0;
    80002274:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002276:	0000f497          	auipc	s1,0xf
    8000227a:	47248493          	addi	s1,s1,1138 # 800116e8 <proc>
    8000227e:	a0bd                	j	800022ec <wait+0xc2>
          pid = np->pid;
    80002280:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002284:	000b0e63          	beqz	s6,800022a0 <wait+0x76>
    80002288:	4691                	li	a3,4
    8000228a:	02c48613          	addi	a2,s1,44
    8000228e:	85da                	mv	a1,s6
    80002290:	07093503          	ld	a0,112(s2)
    80002294:	fffff097          	auipc	ra,0xfffff
    80002298:	3aa080e7          	jalr	938(ra) # 8000163e <copyout>
    8000229c:	02054563          	bltz	a0,800022c6 <wait+0x9c>
          freeproc(np);
    800022a0:	8526                	mv	a0,s1
    800022a2:	00000097          	auipc	ra,0x0
    800022a6:	8a6080e7          	jalr	-1882(ra) # 80001b48 <freeproc>
          release(&np->lock);
    800022aa:	8526                	mv	a0,s1
    800022ac:	fffff097          	auipc	ra,0xfffff
    800022b0:	9ca080e7          	jalr	-1590(ra) # 80000c76 <release>
          release(&wait_lock);
    800022b4:	0000f517          	auipc	a0,0xf
    800022b8:	00450513          	addi	a0,a0,4 # 800112b8 <wait_lock>
    800022bc:	fffff097          	auipc	ra,0xfffff
    800022c0:	9ba080e7          	jalr	-1606(ra) # 80000c76 <release>
          return pid;
    800022c4:	a09d                	j	8000232a <wait+0x100>
            release(&np->lock);
    800022c6:	8526                	mv	a0,s1
    800022c8:	fffff097          	auipc	ra,0xfffff
    800022cc:	9ae080e7          	jalr	-1618(ra) # 80000c76 <release>
            release(&wait_lock);
    800022d0:	0000f517          	auipc	a0,0xf
    800022d4:	fe850513          	addi	a0,a0,-24 # 800112b8 <wait_lock>
    800022d8:	fffff097          	auipc	ra,0xfffff
    800022dc:	99e080e7          	jalr	-1634(ra) # 80000c76 <release>
            return -1;
    800022e0:	59fd                	li	s3,-1
    800022e2:	a0a1                	j	8000232a <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    800022e4:	18848493          	addi	s1,s1,392
    800022e8:	03348463          	beq	s1,s3,80002310 <wait+0xe6>
      if(np->parent == p){
    800022ec:	6cbc                	ld	a5,88(s1)
    800022ee:	ff279be3          	bne	a5,s2,800022e4 <wait+0xba>
        acquire(&np->lock);
    800022f2:	8526                	mv	a0,s1
    800022f4:	fffff097          	auipc	ra,0xfffff
    800022f8:	8ce080e7          	jalr	-1842(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    800022fc:	4c9c                	lw	a5,24(s1)
    800022fe:	f94781e3          	beq	a5,s4,80002280 <wait+0x56>
        release(&np->lock);
    80002302:	8526                	mv	a0,s1
    80002304:	fffff097          	auipc	ra,0xfffff
    80002308:	972080e7          	jalr	-1678(ra) # 80000c76 <release>
        havekids = 1;
    8000230c:	8756                	mv	a4,s5
    8000230e:	bfd9                	j	800022e4 <wait+0xba>
    if(!havekids || p->killed){
    80002310:	c701                	beqz	a4,80002318 <wait+0xee>
    80002312:	02892783          	lw	a5,40(s2)
    80002316:	c79d                	beqz	a5,80002344 <wait+0x11a>
      release(&wait_lock);
    80002318:	0000f517          	auipc	a0,0xf
    8000231c:	fa050513          	addi	a0,a0,-96 # 800112b8 <wait_lock>
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	956080e7          	jalr	-1706(ra) # 80000c76 <release>
      return -1;
    80002328:	59fd                	li	s3,-1
}
    8000232a:	854e                	mv	a0,s3
    8000232c:	60a6                	ld	ra,72(sp)
    8000232e:	6406                	ld	s0,64(sp)
    80002330:	74e2                	ld	s1,56(sp)
    80002332:	7942                	ld	s2,48(sp)
    80002334:	79a2                	ld	s3,40(sp)
    80002336:	7a02                	ld	s4,32(sp)
    80002338:	6ae2                	ld	s5,24(sp)
    8000233a:	6b42                	ld	s6,16(sp)
    8000233c:	6ba2                	ld	s7,8(sp)
    8000233e:	6c02                	ld	s8,0(sp)
    80002340:	6161                	addi	sp,sp,80
    80002342:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002344:	85e2                	mv	a1,s8
    80002346:	854a                	mv	a0,s2
    80002348:	00000097          	auipc	ra,0x0
    8000234c:	e7e080e7          	jalr	-386(ra) # 800021c6 <sleep>
    havekids = 0;
    80002350:	b715                	j	80002274 <wait+0x4a>

0000000080002352 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002352:	715d                	addi	sp,sp,-80
    80002354:	e486                	sd	ra,72(sp)
    80002356:	e0a2                	sd	s0,64(sp)
    80002358:	fc26                	sd	s1,56(sp)
    8000235a:	f84a                	sd	s2,48(sp)
    8000235c:	f44e                	sd	s3,40(sp)
    8000235e:	f052                	sd	s4,32(sp)
    80002360:	ec56                	sd	s5,24(sp)
    80002362:	e85a                	sd	s6,16(sp)
    80002364:	e45e                	sd	s7,8(sp)
    80002366:	0880                	addi	s0,sp,80
    80002368:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000236a:	0000f497          	auipc	s1,0xf
    8000236e:	37e48493          	addi	s1,s1,894 # 800116e8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002372:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002374:	4b8d                	li	s7,3
        acquire(&queue_lock);
    80002376:	0000fb17          	auipc	s6,0xf
    8000237a:	f5ab0b13          	addi	s6,s6,-166 # 800112d0 <queue_lock>
        p->queue_location = queue_counter;
    8000237e:	00006a97          	auipc	s5,0x6
    80002382:	6c6a8a93          	addi	s5,s5,1734 # 80008a44 <queue_counter>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002386:	00015917          	auipc	s2,0x15
    8000238a:	56290913          	addi	s2,s2,1378 # 800178e8 <tickslock>
    8000238e:	a811                	j	800023a2 <wakeup+0x50>
        queue_counter++;
        release(&queue_lock);
      }
      release(&p->lock);
    80002390:	8526                	mv	a0,s1
    80002392:	fffff097          	auipc	ra,0xfffff
    80002396:	8e4080e7          	jalr	-1820(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000239a:	18848493          	addi	s1,s1,392
    8000239e:	05248663          	beq	s1,s2,800023ea <wakeup+0x98>
    if(p != myproc()){
    800023a2:	fffff097          	auipc	ra,0xfffff
    800023a6:	5f4080e7          	jalr	1524(ra) # 80001996 <myproc>
    800023aa:	fea488e3          	beq	s1,a0,8000239a <wakeup+0x48>
      acquire(&p->lock);
    800023ae:	8526                	mv	a0,s1
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	812080e7          	jalr	-2030(ra) # 80000bc2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800023b8:	4c9c                	lw	a5,24(s1)
    800023ba:	fd379be3          	bne	a5,s3,80002390 <wakeup+0x3e>
    800023be:	709c                	ld	a5,32(s1)
    800023c0:	fd4798e3          	bne	a5,s4,80002390 <wakeup+0x3e>
        p->state = RUNNABLE;
    800023c4:	0174ac23          	sw	s7,24(s1)
        acquire(&queue_lock);
    800023c8:	855a                	mv	a0,s6
    800023ca:	ffffe097          	auipc	ra,0xffffe
    800023ce:	7f8080e7          	jalr	2040(ra) # 80000bc2 <acquire>
        p->queue_location = queue_counter;
    800023d2:	000aa783          	lw	a5,0(s5)
    800023d6:	c8bc                	sw	a5,80(s1)
        queue_counter++;
    800023d8:	2785                	addiw	a5,a5,1
    800023da:	00faa023          	sw	a5,0(s5)
        release(&queue_lock);
    800023de:	855a                	mv	a0,s6
    800023e0:	fffff097          	auipc	ra,0xfffff
    800023e4:	896080e7          	jalr	-1898(ra) # 80000c76 <release>
    800023e8:	b765                	j	80002390 <wakeup+0x3e>
    }
  }
}
    800023ea:	60a6                	ld	ra,72(sp)
    800023ec:	6406                	ld	s0,64(sp)
    800023ee:	74e2                	ld	s1,56(sp)
    800023f0:	7942                	ld	s2,48(sp)
    800023f2:	79a2                	ld	s3,40(sp)
    800023f4:	7a02                	ld	s4,32(sp)
    800023f6:	6ae2                	ld	s5,24(sp)
    800023f8:	6b42                	ld	s6,16(sp)
    800023fa:	6ba2                	ld	s7,8(sp)
    800023fc:	6161                	addi	sp,sp,80
    800023fe:	8082                	ret

0000000080002400 <reparent>:
{
    80002400:	7179                	addi	sp,sp,-48
    80002402:	f406                	sd	ra,40(sp)
    80002404:	f022                	sd	s0,32(sp)
    80002406:	ec26                	sd	s1,24(sp)
    80002408:	e84a                	sd	s2,16(sp)
    8000240a:	e44e                	sd	s3,8(sp)
    8000240c:	e052                	sd	s4,0(sp)
    8000240e:	1800                	addi	s0,sp,48
    80002410:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002412:	0000f497          	auipc	s1,0xf
    80002416:	2d648493          	addi	s1,s1,726 # 800116e8 <proc>
      pp->parent = initproc;
    8000241a:	00007a17          	auipc	s4,0x7
    8000241e:	c0ea0a13          	addi	s4,s4,-1010 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002422:	00015997          	auipc	s3,0x15
    80002426:	4c698993          	addi	s3,s3,1222 # 800178e8 <tickslock>
    8000242a:	a029                	j	80002434 <reparent+0x34>
    8000242c:	18848493          	addi	s1,s1,392
    80002430:	01348d63          	beq	s1,s3,8000244a <reparent+0x4a>
    if(pp->parent == p){
    80002434:	6cbc                	ld	a5,88(s1)
    80002436:	ff279be3          	bne	a5,s2,8000242c <reparent+0x2c>
      pp->parent = initproc;
    8000243a:	000a3503          	ld	a0,0(s4)
    8000243e:	eca8                	sd	a0,88(s1)
      wakeup(initproc);
    80002440:	00000097          	auipc	ra,0x0
    80002444:	f12080e7          	jalr	-238(ra) # 80002352 <wakeup>
    80002448:	b7d5                	j	8000242c <reparent+0x2c>
}
    8000244a:	70a2                	ld	ra,40(sp)
    8000244c:	7402                	ld	s0,32(sp)
    8000244e:	64e2                	ld	s1,24(sp)
    80002450:	6942                	ld	s2,16(sp)
    80002452:	69a2                	ld	s3,8(sp)
    80002454:	6a02                	ld	s4,0(sp)
    80002456:	6145                	addi	sp,sp,48
    80002458:	8082                	ret

000000008000245a <exit>:
{
    8000245a:	7179                	addi	sp,sp,-48
    8000245c:	f406                	sd	ra,40(sp)
    8000245e:	f022                	sd	s0,32(sp)
    80002460:	ec26                	sd	s1,24(sp)
    80002462:	e84a                	sd	s2,16(sp)
    80002464:	e44e                	sd	s3,8(sp)
    80002466:	e052                	sd	s4,0(sp)
    80002468:	1800                	addi	s0,sp,48
    8000246a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000246c:	fffff097          	auipc	ra,0xfffff
    80002470:	52a080e7          	jalr	1322(ra) # 80001996 <myproc>
    80002474:	89aa                	mv	s3,a0
  if(p == initproc)
    80002476:	00007797          	auipc	a5,0x7
    8000247a:	bb27b783          	ld	a5,-1102(a5) # 80009028 <initproc>
    8000247e:	0f050493          	addi	s1,a0,240
    80002482:	17050913          	addi	s2,a0,368
    80002486:	02a79363          	bne	a5,a0,800024ac <exit+0x52>
    panic("init exiting");
    8000248a:	00006517          	auipc	a0,0x6
    8000248e:	dd650513          	addi	a0,a0,-554 # 80008260 <digits+0x220>
    80002492:	ffffe097          	auipc	ra,0xffffe
    80002496:	098080e7          	jalr	152(ra) # 8000052a <panic>
      fileclose(f);
    8000249a:	00002097          	auipc	ra,0x2
    8000249e:	6bc080e7          	jalr	1724(ra) # 80004b56 <fileclose>
      p->ofile[fd] = 0;
    800024a2:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800024a6:	04a1                	addi	s1,s1,8
    800024a8:	01248563          	beq	s1,s2,800024b2 <exit+0x58>
    if(p->ofile[fd]){
    800024ac:	6088                	ld	a0,0(s1)
    800024ae:	f575                	bnez	a0,8000249a <exit+0x40>
    800024b0:	bfdd                	j	800024a6 <exit+0x4c>
  begin_op();
    800024b2:	00002097          	auipc	ra,0x2
    800024b6:	1d8080e7          	jalr	472(ra) # 8000468a <begin_op>
  iput(p->cwd);
    800024ba:	1709b503          	ld	a0,368(s3)
    800024be:	00002097          	auipc	ra,0x2
    800024c2:	9b0080e7          	jalr	-1616(ra) # 80003e6e <iput>
  end_op();
    800024c6:	00002097          	auipc	ra,0x2
    800024ca:	244080e7          	jalr	580(ra) # 8000470a <end_op>
  p->cwd = 0;
    800024ce:	1609b823          	sd	zero,368(s3)
  acquire(&wait_lock);
    800024d2:	0000f497          	auipc	s1,0xf
    800024d6:	de648493          	addi	s1,s1,-538 # 800112b8 <wait_lock>
    800024da:	8526                	mv	a0,s1
    800024dc:	ffffe097          	auipc	ra,0xffffe
    800024e0:	6e6080e7          	jalr	1766(ra) # 80000bc2 <acquire>
  reparent(p);
    800024e4:	854e                	mv	a0,s3
    800024e6:	00000097          	auipc	ra,0x0
    800024ea:	f1a080e7          	jalr	-230(ra) # 80002400 <reparent>
  wakeup(p->parent);
    800024ee:	0589b503          	ld	a0,88(s3)
    800024f2:	00000097          	auipc	ra,0x0
    800024f6:	e60080e7          	jalr	-416(ra) # 80002352 <wakeup>
  acquire(&p->lock);
    800024fa:	854e                	mv	a0,s3
    800024fc:	ffffe097          	auipc	ra,0xffffe
    80002500:	6c6080e7          	jalr	1734(ra) # 80000bc2 <acquire>
  p->xstate = status;
    80002504:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002508:	4795                	li	a5,5
    8000250a:	00f9ac23          	sw	a5,24(s3)
  p->ttime = ticks;
    8000250e:	00007797          	auipc	a5,0x7
    80002512:	b227a783          	lw	a5,-1246(a5) # 80009030 <ticks>
    80002516:	02f9ae23          	sw	a5,60(s3)
  release(&wait_lock);
    8000251a:	8526                	mv	a0,s1
    8000251c:	ffffe097          	auipc	ra,0xffffe
    80002520:	75a080e7          	jalr	1882(ra) # 80000c76 <release>
  sched();
    80002524:	00000097          	auipc	ra,0x0
    80002528:	b60080e7          	jalr	-1184(ra) # 80002084 <sched>
  panic("zombie exit");
    8000252c:	00006517          	auipc	a0,0x6
    80002530:	d4450513          	addi	a0,a0,-700 # 80008270 <digits+0x230>
    80002534:	ffffe097          	auipc	ra,0xffffe
    80002538:	ff6080e7          	jalr	-10(ra) # 8000052a <panic>

000000008000253c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000253c:	7179                	addi	sp,sp,-48
    8000253e:	f406                	sd	ra,40(sp)
    80002540:	f022                	sd	s0,32(sp)
    80002542:	ec26                	sd	s1,24(sp)
    80002544:	e84a                	sd	s2,16(sp)
    80002546:	e44e                	sd	s3,8(sp)
    80002548:	1800                	addi	s0,sp,48
    8000254a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000254c:	0000f497          	auipc	s1,0xf
    80002550:	19c48493          	addi	s1,s1,412 # 800116e8 <proc>
    80002554:	00015997          	auipc	s3,0x15
    80002558:	39498993          	addi	s3,s3,916 # 800178e8 <tickslock>
    acquire(&p->lock);
    8000255c:	8526                	mv	a0,s1
    8000255e:	ffffe097          	auipc	ra,0xffffe
    80002562:	664080e7          	jalr	1636(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    80002566:	589c                	lw	a5,48(s1)
    80002568:	01278d63          	beq	a5,s2,80002582 <kill+0x46>
        release(&queue_lock);
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000256c:	8526                	mv	a0,s1
    8000256e:	ffffe097          	auipc	ra,0xffffe
    80002572:	708080e7          	jalr	1800(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002576:	18848493          	addi	s1,s1,392
    8000257a:	ff3491e3          	bne	s1,s3,8000255c <kill+0x20>
  }
  return -1;
    8000257e:	557d                	li	a0,-1
    80002580:	a829                	j	8000259a <kill+0x5e>
      p->killed = 1;
    80002582:	4785                	li	a5,1
    80002584:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002586:	4c98                	lw	a4,24(s1)
    80002588:	4789                	li	a5,2
    8000258a:	00f70f63          	beq	a4,a5,800025a8 <kill+0x6c>
      release(&p->lock);
    8000258e:	8526                	mv	a0,s1
    80002590:	ffffe097          	auipc	ra,0xffffe
    80002594:	6e6080e7          	jalr	1766(ra) # 80000c76 <release>
      return 0;
    80002598:	4501                	li	a0,0
}
    8000259a:	70a2                	ld	ra,40(sp)
    8000259c:	7402                	ld	s0,32(sp)
    8000259e:	64e2                	ld	s1,24(sp)
    800025a0:	6942                	ld	s2,16(sp)
    800025a2:	69a2                	ld	s3,8(sp)
    800025a4:	6145                	addi	sp,sp,48
    800025a6:	8082                	ret
        p->state = RUNNABLE;
    800025a8:	478d                	li	a5,3
    800025aa:	cc9c                	sw	a5,24(s1)
        acquire(&queue_lock);
    800025ac:	0000f917          	auipc	s2,0xf
    800025b0:	d2490913          	addi	s2,s2,-732 # 800112d0 <queue_lock>
    800025b4:	854a                	mv	a0,s2
    800025b6:	ffffe097          	auipc	ra,0xffffe
    800025ba:	60c080e7          	jalr	1548(ra) # 80000bc2 <acquire>
        p->queue_location = queue_counter;
    800025be:	00006717          	auipc	a4,0x6
    800025c2:	48670713          	addi	a4,a4,1158 # 80008a44 <queue_counter>
    800025c6:	431c                	lw	a5,0(a4)
    800025c8:	c8bc                	sw	a5,80(s1)
        queue_counter++;
    800025ca:	2785                	addiw	a5,a5,1
    800025cc:	c31c                	sw	a5,0(a4)
        release(&queue_lock);
    800025ce:	854a                	mv	a0,s2
    800025d0:	ffffe097          	auipc	ra,0xffffe
    800025d4:	6a6080e7          	jalr	1702(ra) # 80000c76 <release>
    800025d8:	bf5d                	j	8000258e <kill+0x52>

00000000800025da <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800025da:	7179                	addi	sp,sp,-48
    800025dc:	f406                	sd	ra,40(sp)
    800025de:	f022                	sd	s0,32(sp)
    800025e0:	ec26                	sd	s1,24(sp)
    800025e2:	e84a                	sd	s2,16(sp)
    800025e4:	e44e                	sd	s3,8(sp)
    800025e6:	e052                	sd	s4,0(sp)
    800025e8:	1800                	addi	s0,sp,48
    800025ea:	84aa                	mv	s1,a0
    800025ec:	892e                	mv	s2,a1
    800025ee:	89b2                	mv	s3,a2
    800025f0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025f2:	fffff097          	auipc	ra,0xfffff
    800025f6:	3a4080e7          	jalr	932(ra) # 80001996 <myproc>
  if(user_dst){
    800025fa:	c08d                	beqz	s1,8000261c <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800025fc:	86d2                	mv	a3,s4
    800025fe:	864e                	mv	a2,s3
    80002600:	85ca                	mv	a1,s2
    80002602:	7928                	ld	a0,112(a0)
    80002604:	fffff097          	auipc	ra,0xfffff
    80002608:	03a080e7          	jalr	58(ra) # 8000163e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000260c:	70a2                	ld	ra,40(sp)
    8000260e:	7402                	ld	s0,32(sp)
    80002610:	64e2                	ld	s1,24(sp)
    80002612:	6942                	ld	s2,16(sp)
    80002614:	69a2                	ld	s3,8(sp)
    80002616:	6a02                	ld	s4,0(sp)
    80002618:	6145                	addi	sp,sp,48
    8000261a:	8082                	ret
    memmove((char *)dst, src, len);
    8000261c:	000a061b          	sext.w	a2,s4
    80002620:	85ce                	mv	a1,s3
    80002622:	854a                	mv	a0,s2
    80002624:	ffffe097          	auipc	ra,0xffffe
    80002628:	6f6080e7          	jalr	1782(ra) # 80000d1a <memmove>
    return 0;
    8000262c:	8526                	mv	a0,s1
    8000262e:	bff9                	j	8000260c <either_copyout+0x32>

0000000080002630 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002630:	7179                	addi	sp,sp,-48
    80002632:	f406                	sd	ra,40(sp)
    80002634:	f022                	sd	s0,32(sp)
    80002636:	ec26                	sd	s1,24(sp)
    80002638:	e84a                	sd	s2,16(sp)
    8000263a:	e44e                	sd	s3,8(sp)
    8000263c:	e052                	sd	s4,0(sp)
    8000263e:	1800                	addi	s0,sp,48
    80002640:	892a                	mv	s2,a0
    80002642:	84ae                	mv	s1,a1
    80002644:	89b2                	mv	s3,a2
    80002646:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002648:	fffff097          	auipc	ra,0xfffff
    8000264c:	34e080e7          	jalr	846(ra) # 80001996 <myproc>
  if(user_src){
    80002650:	c08d                	beqz	s1,80002672 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002652:	86d2                	mv	a3,s4
    80002654:	864e                	mv	a2,s3
    80002656:	85ca                	mv	a1,s2
    80002658:	7928                	ld	a0,112(a0)
    8000265a:	fffff097          	auipc	ra,0xfffff
    8000265e:	070080e7          	jalr	112(ra) # 800016ca <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002662:	70a2                	ld	ra,40(sp)
    80002664:	7402                	ld	s0,32(sp)
    80002666:	64e2                	ld	s1,24(sp)
    80002668:	6942                	ld	s2,16(sp)
    8000266a:	69a2                	ld	s3,8(sp)
    8000266c:	6a02                	ld	s4,0(sp)
    8000266e:	6145                	addi	sp,sp,48
    80002670:	8082                	ret
    memmove(dst, (char*)src, len);
    80002672:	000a061b          	sext.w	a2,s4
    80002676:	85ce                	mv	a1,s3
    80002678:	854a                	mv	a0,s2
    8000267a:	ffffe097          	auipc	ra,0xffffe
    8000267e:	6a0080e7          	jalr	1696(ra) # 80000d1a <memmove>
    return 0;
    80002682:	8526                	mv	a0,s1
    80002684:	bff9                	j	80002662 <either_copyin+0x32>

0000000080002686 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002686:	715d                	addi	sp,sp,-80
    80002688:	e486                	sd	ra,72(sp)
    8000268a:	e0a2                	sd	s0,64(sp)
    8000268c:	fc26                	sd	s1,56(sp)
    8000268e:	f84a                	sd	s2,48(sp)
    80002690:	f44e                	sd	s3,40(sp)
    80002692:	f052                	sd	s4,32(sp)
    80002694:	ec56                	sd	s5,24(sp)
    80002696:	e85a                	sd	s6,16(sp)
    80002698:	e45e                	sd	s7,8(sp)
    8000269a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000269c:	00006517          	auipc	a0,0x6
    800026a0:	a2c50513          	addi	a0,a0,-1492 # 800080c8 <digits+0x88>
    800026a4:	ffffe097          	auipc	ra,0xffffe
    800026a8:	ed0080e7          	jalr	-304(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026ac:	0000f497          	auipc	s1,0xf
    800026b0:	1b448493          	addi	s1,s1,436 # 80011860 <proc+0x178>
    800026b4:	00015917          	auipc	s2,0x15
    800026b8:	3ac90913          	addi	s2,s2,940 # 80017a60 <bcache+0x160>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026bc:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800026be:	00006997          	auipc	s3,0x6
    800026c2:	bc298993          	addi	s3,s3,-1086 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    800026c6:	00006a97          	auipc	s5,0x6
    800026ca:	bc2a8a93          	addi	s5,s5,-1086 # 80008288 <digits+0x248>
    printf("\n");
    800026ce:	00006a17          	auipc	s4,0x6
    800026d2:	9faa0a13          	addi	s4,s4,-1542 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026d6:	00006b97          	auipc	s7,0x6
    800026da:	ceab8b93          	addi	s7,s7,-790 # 800083c0 <states.0>
    800026de:	a00d                	j	80002700 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800026e0:	eb86a583          	lw	a1,-328(a3)
    800026e4:	8556                	mv	a0,s5
    800026e6:	ffffe097          	auipc	ra,0xffffe
    800026ea:	e8e080e7          	jalr	-370(ra) # 80000574 <printf>
    printf("\n");
    800026ee:	8552                	mv	a0,s4
    800026f0:	ffffe097          	auipc	ra,0xffffe
    800026f4:	e84080e7          	jalr	-380(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026f8:	18848493          	addi	s1,s1,392
    800026fc:	03248263          	beq	s1,s2,80002720 <procdump+0x9a>
    if(p->state == UNUSED)
    80002700:	86a6                	mv	a3,s1
    80002702:	ea04a783          	lw	a5,-352(s1)
    80002706:	dbed                	beqz	a5,800026f8 <procdump+0x72>
      state = "???";
    80002708:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000270a:	fcfb6be3          	bltu	s6,a5,800026e0 <procdump+0x5a>
    8000270e:	02079713          	slli	a4,a5,0x20
    80002712:	01d75793          	srli	a5,a4,0x1d
    80002716:	97de                	add	a5,a5,s7
    80002718:	6390                	ld	a2,0(a5)
    8000271a:	f279                	bnez	a2,800026e0 <procdump+0x5a>
      state = "???";
    8000271c:	864e                	mv	a2,s3
    8000271e:	b7c9                	j	800026e0 <procdump+0x5a>
  }
}
    80002720:	60a6                	ld	ra,72(sp)
    80002722:	6406                	ld	s0,64(sp)
    80002724:	74e2                	ld	s1,56(sp)
    80002726:	7942                	ld	s2,48(sp)
    80002728:	79a2                	ld	s3,40(sp)
    8000272a:	7a02                	ld	s4,32(sp)
    8000272c:	6ae2                	ld	s5,24(sp)
    8000272e:	6b42                	ld	s6,16(sp)
    80002730:	6ba2                	ld	s7,8(sp)
    80002732:	6161                	addi	sp,sp,80
    80002734:	8082                	ret

0000000080002736 <trace>:

//modified
int 
trace (int mask, int pid)
{
    80002736:	7179                	addi	sp,sp,-48
    80002738:	f406                	sd	ra,40(sp)
    8000273a:	f022                	sd	s0,32(sp)
    8000273c:	ec26                	sd	s1,24(sp)
    8000273e:	e84a                	sd	s2,16(sp)
    80002740:	e44e                	sd	s3,8(sp)
    80002742:	e052                	sd	s4,0(sp)
    80002744:	1800                	addi	s0,sp,48
    80002746:	8a2a                	mv	s4,a0
    80002748:	892e                	mv	s2,a1
  struct proc *p;
  for(p = proc; p < &proc[NPROC]; p++){
    8000274a:	0000f497          	auipc	s1,0xf
    8000274e:	f9e48493          	addi	s1,s1,-98 # 800116e8 <proc>
    80002752:	00015997          	auipc	s3,0x15
    80002756:	19698993          	addi	s3,s3,406 # 800178e8 <tickslock>
    acquire(&p->lock);
    8000275a:	8526                	mv	a0,s1
    8000275c:	ffffe097          	auipc	ra,0xffffe
    80002760:	466080e7          	jalr	1126(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    80002764:	589c                	lw	a5,48(s1)
    80002766:	01278d63          	beq	a5,s2,80002780 <trace+0x4a>
      p->maskid = mask;
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000276a:	8526                	mv	a0,s1
    8000276c:	ffffe097          	auipc	ra,0xffffe
    80002770:	50a080e7          	jalr	1290(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002774:	18848493          	addi	s1,s1,392
    80002778:	ff3491e3          	bne	s1,s3,8000275a <trace+0x24>
  }
  return -1;
    8000277c:	557d                	li	a0,-1
    8000277e:	a809                	j	80002790 <trace+0x5a>
      p->maskid = mask;
    80002780:	0344aa23          	sw	s4,52(s1)
      release(&p->lock);
    80002784:	8526                	mv	a0,s1
    80002786:	ffffe097          	auipc	ra,0xffffe
    8000278a:	4f0080e7          	jalr	1264(ra) # 80000c76 <release>
      return 0;
    8000278e:	4501                	li	a0,0
}
    80002790:	70a2                	ld	ra,40(sp)
    80002792:	7402                	ld	s0,32(sp)
    80002794:	64e2                	ld	s1,24(sp)
    80002796:	6942                	ld	s2,16(sp)
    80002798:	69a2                	ld	s3,8(sp)
    8000279a:	6a02                	ld	s4,0(sp)
    8000279c:	6145                	addi	sp,sp,48
    8000279e:	8082                	ret

00000000800027a0 <wait_stat>:

int 
wait_stat(int* status, struct perf * performance)
{
    800027a0:	711d                	addi	sp,sp,-96
    800027a2:	ec86                	sd	ra,88(sp)
    800027a4:	e8a2                	sd	s0,80(sp)
    800027a6:	e4a6                	sd	s1,72(sp)
    800027a8:	e0ca                	sd	s2,64(sp)
    800027aa:	fc4e                	sd	s3,56(sp)
    800027ac:	f852                	sd	s4,48(sp)
    800027ae:	f456                	sd	s5,40(sp)
    800027b0:	f05a                	sd	s6,32(sp)
    800027b2:	ec5e                	sd	s7,24(sp)
    800027b4:	e862                	sd	s8,16(sp)
    800027b6:	e466                	sd	s9,8(sp)
    800027b8:	1080                	addi	s0,sp,96
    800027ba:	8baa                	mv	s7,a0
    800027bc:	8b2e                	mv	s6,a1
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    800027be:	fffff097          	auipc	ra,0xfffff
    800027c2:	1d8080e7          	jalr	472(ra) # 80001996 <myproc>
    800027c6:	892a                	mv	s2,a0

  acquire(&wait_lock);
    800027c8:	0000f517          	auipc	a0,0xf
    800027cc:	af050513          	addi	a0,a0,-1296 # 800112b8 <wait_lock>
    800027d0:	ffffe097          	auipc	ra,0xffffe
    800027d4:	3f2080e7          	jalr	1010(ra) # 80000bc2 <acquire>

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    800027d8:	4c01                	li	s8,0
        
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if(np->state == ZOMBIE){
    800027da:	4a15                	li	s4,5
        havekids = 1;
    800027dc:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800027de:	00015997          	auipc	s3,0x15
    800027e2:	10a98993          	addi	s3,s3,266 # 800178e8 <tickslock>
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800027e6:	0000fc97          	auipc	s9,0xf
    800027ea:	ad2c8c93          	addi	s9,s9,-1326 # 800112b8 <wait_lock>
    havekids = 0;
    800027ee:	8762                	mv	a4,s8
    for(np = proc; np < &proc[NPROC]; np++){
    800027f0:	0000f497          	auipc	s1,0xf
    800027f4:	ef848493          	addi	s1,s1,-264 # 800116e8 <proc>
    800027f8:	ac35                	j	80002a34 <wait_stat+0x294>
          printf("\nIts got to proc.c line 1");
    800027fa:	00006517          	auipc	a0,0x6
    800027fe:	a9e50513          	addi	a0,a0,-1378 # 80008298 <digits+0x258>
    80002802:	ffffe097          	auipc	ra,0xffffe
    80002806:	d72080e7          	jalr	-654(ra) # 80000574 <printf>
          pid = np->pid;
    8000280a:	0304a983          	lw	s3,48(s1)
          if (copyout(p->pagetable, ((uint64)&(performance->ctime)) , (char *)&np->ctime, 24) < 0){
    8000280e:	46e1                	li	a3,24
    80002810:	03848613          	addi	a2,s1,56
    80002814:	85da                	mv	a1,s6
    80002816:	07093503          	ld	a0,112(s2)
    8000281a:	fffff097          	auipc	ra,0xfffff
    8000281e:	e24080e7          	jalr	-476(ra) # 8000163e <copyout>
    80002822:	0c054463          	bltz	a0,800028ea <wait_stat+0x14a>
          else if (copyout(p->pagetable, ((uint64)&(performance->ttime)) , (char *)&np->ttime, 24) < 0){
    80002826:	46e1                	li	a3,24
    80002828:	03c48613          	addi	a2,s1,60
    8000282c:	004b0593          	addi	a1,s6,4
    80002830:	07093503          	ld	a0,112(s2)
    80002834:	fffff097          	auipc	ra,0xfffff
    80002838:	e0a080e7          	jalr	-502(ra) # 8000163e <copyout>
    8000283c:	0c054e63          	bltz	a0,80002918 <wait_stat+0x178>
          else if (copyout(p->pagetable, ((uint64)&(performance->stime)) , (char *)&np->stime, 24) < 0){
    80002840:	46e1                	li	a3,24
    80002842:	04048613          	addi	a2,s1,64
    80002846:	008b0593          	addi	a1,s6,8
    8000284a:	07093503          	ld	a0,112(s2)
    8000284e:	fffff097          	auipc	ra,0xfffff
    80002852:	df0080e7          	jalr	-528(ra) # 8000163e <copyout>
    80002856:	0e054863          	bltz	a0,80002946 <wait_stat+0x1a6>
          else if (copyout(p->pagetable, ((uint64)&(performance->retime)) , (char *)&np->retime, 24) < 0){
    8000285a:	46e1                	li	a3,24
    8000285c:	04448613          	addi	a2,s1,68
    80002860:	00cb0593          	addi	a1,s6,12
    80002864:	07093503          	ld	a0,112(s2)
    80002868:	fffff097          	auipc	ra,0xfffff
    8000286c:	dd6080e7          	jalr	-554(ra) # 8000163e <copyout>
    80002870:	10054263          	bltz	a0,80002974 <wait_stat+0x1d4>
          else if (copyout(p->pagetable, ((uint64)&(performance->rutime)) , (char *)&np->rutime, 24) < 0){
    80002874:	46e1                	li	a3,24
    80002876:	04848613          	addi	a2,s1,72
    8000287a:	010b0593          	addi	a1,s6,16
    8000287e:	07093503          	ld	a0,112(s2)
    80002882:	fffff097          	auipc	ra,0xfffff
    80002886:	dbc080e7          	jalr	-580(ra) # 8000163e <copyout>
    8000288a:	10054c63          	bltz	a0,800029a2 <wait_stat+0x202>
          else if (copyout(p->pagetable, ((uint64)&(performance->average_bursttime)) , (char *)&np->average_bursttime, 24) < 0){
    8000288e:	46e1                	li	a3,24
    80002890:	04c48613          	addi	a2,s1,76
    80002894:	014b0593          	addi	a1,s6,20
    80002898:	07093503          	ld	a0,112(s2)
    8000289c:	fffff097          	auipc	ra,0xfffff
    800028a0:	da2080e7          	jalr	-606(ra) # 8000163e <copyout>
    800028a4:	12054663          	bltz	a0,800029d0 <wait_stat+0x230>
          else if(((uint64)status) != 0 && copyout(p->pagetable, ((uint64)status) , (char *)&np->xstate,
    800028a8:	000b8e63          	beqz	s7,800028c4 <wait_stat+0x124>
    800028ac:	4691                	li	a3,4
    800028ae:	02c48613          	addi	a2,s1,44
    800028b2:	85de                	mv	a1,s7
    800028b4:	07093503          	ld	a0,112(s2)
    800028b8:	fffff097          	auipc	ra,0xfffff
    800028bc:	d86080e7          	jalr	-634(ra) # 8000163e <copyout>
    800028c0:	12054f63          	bltz	a0,800029fe <wait_stat+0x25e>
          freeproc(np);
    800028c4:	8526                	mv	a0,s1
    800028c6:	fffff097          	auipc	ra,0xfffff
    800028ca:	282080e7          	jalr	642(ra) # 80001b48 <freeproc>
          release(&np->lock);
    800028ce:	8526                	mv	a0,s1
    800028d0:	ffffe097          	auipc	ra,0xffffe
    800028d4:	3a6080e7          	jalr	934(ra) # 80000c76 <release>
          release(&wait_lock);
    800028d8:	0000f517          	auipc	a0,0xf
    800028dc:	9e050513          	addi	a0,a0,-1568 # 800112b8 <wait_lock>
    800028e0:	ffffe097          	auipc	ra,0xffffe
    800028e4:	396080e7          	jalr	918(ra) # 80000c76 <release>
          return pid;
    800028e8:	a269                	j	80002a72 <wait_stat+0x2d2>
            printf("\nIts got to proc.c line 2");
    800028ea:	00006517          	auipc	a0,0x6
    800028ee:	9ce50513          	addi	a0,a0,-1586 # 800082b8 <digits+0x278>
    800028f2:	ffffe097          	auipc	ra,0xffffe
    800028f6:	c82080e7          	jalr	-894(ra) # 80000574 <printf>
            release(&np->lock);
    800028fa:	8526                	mv	a0,s1
    800028fc:	ffffe097          	auipc	ra,0xffffe
    80002900:	37a080e7          	jalr	890(ra) # 80000c76 <release>
            release(&wait_lock);
    80002904:	0000f517          	auipc	a0,0xf
    80002908:	9b450513          	addi	a0,a0,-1612 # 800112b8 <wait_lock>
    8000290c:	ffffe097          	auipc	ra,0xffffe
    80002910:	36a080e7          	jalr	874(ra) # 80000c76 <release>
            return -1;
    80002914:	59fd                	li	s3,-1
    80002916:	aab1                	j	80002a72 <wait_stat+0x2d2>
            printf("\nIts got to proc.c line 3");
    80002918:	00006517          	auipc	a0,0x6
    8000291c:	9c050513          	addi	a0,a0,-1600 # 800082d8 <digits+0x298>
    80002920:	ffffe097          	auipc	ra,0xffffe
    80002924:	c54080e7          	jalr	-940(ra) # 80000574 <printf>
            release(&np->lock);
    80002928:	8526                	mv	a0,s1
    8000292a:	ffffe097          	auipc	ra,0xffffe
    8000292e:	34c080e7          	jalr	844(ra) # 80000c76 <release>
            release(&wait_lock);
    80002932:	0000f517          	auipc	a0,0xf
    80002936:	98650513          	addi	a0,a0,-1658 # 800112b8 <wait_lock>
    8000293a:	ffffe097          	auipc	ra,0xffffe
    8000293e:	33c080e7          	jalr	828(ra) # 80000c76 <release>
            return -1;
    80002942:	59fd                	li	s3,-1
    80002944:	a23d                	j	80002a72 <wait_stat+0x2d2>
            printf("\nIts got to proc.c line 4");
    80002946:	00006517          	auipc	a0,0x6
    8000294a:	9b250513          	addi	a0,a0,-1614 # 800082f8 <digits+0x2b8>
    8000294e:	ffffe097          	auipc	ra,0xffffe
    80002952:	c26080e7          	jalr	-986(ra) # 80000574 <printf>
            release(&np->lock);
    80002956:	8526                	mv	a0,s1
    80002958:	ffffe097          	auipc	ra,0xffffe
    8000295c:	31e080e7          	jalr	798(ra) # 80000c76 <release>
            release(&wait_lock);
    80002960:	0000f517          	auipc	a0,0xf
    80002964:	95850513          	addi	a0,a0,-1704 # 800112b8 <wait_lock>
    80002968:	ffffe097          	auipc	ra,0xffffe
    8000296c:	30e080e7          	jalr	782(ra) # 80000c76 <release>
            return -1;
    80002970:	59fd                	li	s3,-1
    80002972:	a201                	j	80002a72 <wait_stat+0x2d2>
            printf("\nIts got to proc.c line 5");
    80002974:	00006517          	auipc	a0,0x6
    80002978:	9a450513          	addi	a0,a0,-1628 # 80008318 <digits+0x2d8>
    8000297c:	ffffe097          	auipc	ra,0xffffe
    80002980:	bf8080e7          	jalr	-1032(ra) # 80000574 <printf>
            release(&np->lock);
    80002984:	8526                	mv	a0,s1
    80002986:	ffffe097          	auipc	ra,0xffffe
    8000298a:	2f0080e7          	jalr	752(ra) # 80000c76 <release>
            release(&wait_lock);
    8000298e:	0000f517          	auipc	a0,0xf
    80002992:	92a50513          	addi	a0,a0,-1750 # 800112b8 <wait_lock>
    80002996:	ffffe097          	auipc	ra,0xffffe
    8000299a:	2e0080e7          	jalr	736(ra) # 80000c76 <release>
            return -1;
    8000299e:	59fd                	li	s3,-1
    800029a0:	a8c9                	j	80002a72 <wait_stat+0x2d2>
            printf("\nIts got to proc.c line 6");
    800029a2:	00006517          	auipc	a0,0x6
    800029a6:	99650513          	addi	a0,a0,-1642 # 80008338 <digits+0x2f8>
    800029aa:	ffffe097          	auipc	ra,0xffffe
    800029ae:	bca080e7          	jalr	-1078(ra) # 80000574 <printf>
            release(&np->lock);
    800029b2:	8526                	mv	a0,s1
    800029b4:	ffffe097          	auipc	ra,0xffffe
    800029b8:	2c2080e7          	jalr	706(ra) # 80000c76 <release>
            release(&wait_lock);
    800029bc:	0000f517          	auipc	a0,0xf
    800029c0:	8fc50513          	addi	a0,a0,-1796 # 800112b8 <wait_lock>
    800029c4:	ffffe097          	auipc	ra,0xffffe
    800029c8:	2b2080e7          	jalr	690(ra) # 80000c76 <release>
            return -1;
    800029cc:	59fd                	li	s3,-1
    800029ce:	a055                	j	80002a72 <wait_stat+0x2d2>
            printf("\nIts got to proc.c line 7");
    800029d0:	00006517          	auipc	a0,0x6
    800029d4:	98850513          	addi	a0,a0,-1656 # 80008358 <digits+0x318>
    800029d8:	ffffe097          	auipc	ra,0xffffe
    800029dc:	b9c080e7          	jalr	-1124(ra) # 80000574 <printf>
            release(&np->lock);
    800029e0:	8526                	mv	a0,s1
    800029e2:	ffffe097          	auipc	ra,0xffffe
    800029e6:	294080e7          	jalr	660(ra) # 80000c76 <release>
            release(&wait_lock);
    800029ea:	0000f517          	auipc	a0,0xf
    800029ee:	8ce50513          	addi	a0,a0,-1842 # 800112b8 <wait_lock>
    800029f2:	ffffe097          	auipc	ra,0xffffe
    800029f6:	284080e7          	jalr	644(ra) # 80000c76 <release>
            return -1;
    800029fa:	59fd                	li	s3,-1
    800029fc:	a89d                	j	80002a72 <wait_stat+0x2d2>
            printf("\nIts got to proc.c line 8");
    800029fe:	00006517          	auipc	a0,0x6
    80002a02:	97a50513          	addi	a0,a0,-1670 # 80008378 <digits+0x338>
    80002a06:	ffffe097          	auipc	ra,0xffffe
    80002a0a:	b6e080e7          	jalr	-1170(ra) # 80000574 <printf>
            release(&np->lock);
    80002a0e:	8526                	mv	a0,s1
    80002a10:	ffffe097          	auipc	ra,0xffffe
    80002a14:	266080e7          	jalr	614(ra) # 80000c76 <release>
            release(&wait_lock);
    80002a18:	0000f517          	auipc	a0,0xf
    80002a1c:	8a050513          	addi	a0,a0,-1888 # 800112b8 <wait_lock>
    80002a20:	ffffe097          	auipc	ra,0xffffe
    80002a24:	256080e7          	jalr	598(ra) # 80000c76 <release>
            return -1;
    80002a28:	59fd                	li	s3,-1
    80002a2a:	a0a1                	j	80002a72 <wait_stat+0x2d2>
    for(np = proc; np < &proc[NPROC]; np++){
    80002a2c:	18848493          	addi	s1,s1,392
    80002a30:	03348463          	beq	s1,s3,80002a58 <wait_stat+0x2b8>
      if(np->parent == p){
    80002a34:	6cbc                	ld	a5,88(s1)
    80002a36:	ff279be3          	bne	a5,s2,80002a2c <wait_stat+0x28c>
        acquire(&np->lock);
    80002a3a:	8526                	mv	a0,s1
    80002a3c:	ffffe097          	auipc	ra,0xffffe
    80002a40:	186080e7          	jalr	390(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    80002a44:	4c9c                	lw	a5,24(s1)
    80002a46:	db478ae3          	beq	a5,s4,800027fa <wait_stat+0x5a>
        release(&np->lock);
    80002a4a:	8526                	mv	a0,s1
    80002a4c:	ffffe097          	auipc	ra,0xffffe
    80002a50:	22a080e7          	jalr	554(ra) # 80000c76 <release>
        havekids = 1;
    80002a54:	8756                	mv	a4,s5
    80002a56:	bfd9                	j	80002a2c <wait_stat+0x28c>
    if(!havekids || p->killed){
    80002a58:	c701                	beqz	a4,80002a60 <wait_stat+0x2c0>
    80002a5a:	02892783          	lw	a5,40(s2)
    80002a5e:	cb85                	beqz	a5,80002a8e <wait_stat+0x2ee>
      release(&wait_lock);
    80002a60:	0000f517          	auipc	a0,0xf
    80002a64:	85850513          	addi	a0,a0,-1960 # 800112b8 <wait_lock>
    80002a68:	ffffe097          	auipc	ra,0xffffe
    80002a6c:	20e080e7          	jalr	526(ra) # 80000c76 <release>
      return -1;
    80002a70:	59fd                	li	s3,-1
  }
    80002a72:	854e                	mv	a0,s3
    80002a74:	60e6                	ld	ra,88(sp)
    80002a76:	6446                	ld	s0,80(sp)
    80002a78:	64a6                	ld	s1,72(sp)
    80002a7a:	6906                	ld	s2,64(sp)
    80002a7c:	79e2                	ld	s3,56(sp)
    80002a7e:	7a42                	ld	s4,48(sp)
    80002a80:	7aa2                	ld	s5,40(sp)
    80002a82:	7b02                	ld	s6,32(sp)
    80002a84:	6be2                	ld	s7,24(sp)
    80002a86:	6c42                	ld	s8,16(sp)
    80002a88:	6ca2                	ld	s9,8(sp)
    80002a8a:	6125                	addi	sp,sp,96
    80002a8c:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002a8e:	85e6                	mv	a1,s9
    80002a90:	854a                	mv	a0,s2
    80002a92:	fffff097          	auipc	ra,0xfffff
    80002a96:	734080e7          	jalr	1844(ra) # 800021c6 <sleep>
    havekids = 0;
    80002a9a:	bb91                	j	800027ee <wait_stat+0x4e>

0000000080002a9c <swtch>:
    80002a9c:	00153023          	sd	ra,0(a0)
    80002aa0:	00253423          	sd	sp,8(a0)
    80002aa4:	e900                	sd	s0,16(a0)
    80002aa6:	ed04                	sd	s1,24(a0)
    80002aa8:	03253023          	sd	s2,32(a0)
    80002aac:	03353423          	sd	s3,40(a0)
    80002ab0:	03453823          	sd	s4,48(a0)
    80002ab4:	03553c23          	sd	s5,56(a0)
    80002ab8:	05653023          	sd	s6,64(a0)
    80002abc:	05753423          	sd	s7,72(a0)
    80002ac0:	05853823          	sd	s8,80(a0)
    80002ac4:	05953c23          	sd	s9,88(a0)
    80002ac8:	07a53023          	sd	s10,96(a0)
    80002acc:	07b53423          	sd	s11,104(a0)
    80002ad0:	0005b083          	ld	ra,0(a1)
    80002ad4:	0085b103          	ld	sp,8(a1)
    80002ad8:	6980                	ld	s0,16(a1)
    80002ada:	6d84                	ld	s1,24(a1)
    80002adc:	0205b903          	ld	s2,32(a1)
    80002ae0:	0285b983          	ld	s3,40(a1)
    80002ae4:	0305ba03          	ld	s4,48(a1)
    80002ae8:	0385ba83          	ld	s5,56(a1)
    80002aec:	0405bb03          	ld	s6,64(a1)
    80002af0:	0485bb83          	ld	s7,72(a1)
    80002af4:	0505bc03          	ld	s8,80(a1)
    80002af8:	0585bc83          	ld	s9,88(a1)
    80002afc:	0605bd03          	ld	s10,96(a1)
    80002b00:	0685bd83          	ld	s11,104(a1)
    80002b04:	8082                	ret

0000000080002b06 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002b06:	1141                	addi	sp,sp,-16
    80002b08:	e406                	sd	ra,8(sp)
    80002b0a:	e022                	sd	s0,0(sp)
    80002b0c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002b0e:	00006597          	auipc	a1,0x6
    80002b12:	8e258593          	addi	a1,a1,-1822 # 800083f0 <states.0+0x30>
    80002b16:	00015517          	auipc	a0,0x15
    80002b1a:	dd250513          	addi	a0,a0,-558 # 800178e8 <tickslock>
    80002b1e:	ffffe097          	auipc	ra,0xffffe
    80002b22:	014080e7          	jalr	20(ra) # 80000b32 <initlock>
}
    80002b26:	60a2                	ld	ra,8(sp)
    80002b28:	6402                	ld	s0,0(sp)
    80002b2a:	0141                	addi	sp,sp,16
    80002b2c:	8082                	ret

0000000080002b2e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002b2e:	1141                	addi	sp,sp,-16
    80002b30:	e422                	sd	s0,8(sp)
    80002b32:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b34:	00003797          	auipc	a5,0x3
    80002b38:	64c78793          	addi	a5,a5,1612 # 80006180 <kernelvec>
    80002b3c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002b40:	6422                	ld	s0,8(sp)
    80002b42:	0141                	addi	sp,sp,16
    80002b44:	8082                	ret

0000000080002b46 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002b46:	1141                	addi	sp,sp,-16
    80002b48:	e406                	sd	ra,8(sp)
    80002b4a:	e022                	sd	s0,0(sp)
    80002b4c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002b4e:	fffff097          	auipc	ra,0xfffff
    80002b52:	e48080e7          	jalr	-440(ra) # 80001996 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002b5a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b5c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002b60:	00004617          	auipc	a2,0x4
    80002b64:	4a060613          	addi	a2,a2,1184 # 80007000 <_trampoline>
    80002b68:	00004697          	auipc	a3,0x4
    80002b6c:	49868693          	addi	a3,a3,1176 # 80007000 <_trampoline>
    80002b70:	8e91                	sub	a3,a3,a2
    80002b72:	040007b7          	lui	a5,0x4000
    80002b76:	17fd                	addi	a5,a5,-1
    80002b78:	07b2                	slli	a5,a5,0xc
    80002b7a:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b7c:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b80:	7d38                	ld	a4,120(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002b82:	180026f3          	csrr	a3,satp
    80002b86:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002b88:	7d38                	ld	a4,120(a0)
    80002b8a:	7134                	ld	a3,96(a0)
    80002b8c:	6585                	lui	a1,0x1
    80002b8e:	96ae                	add	a3,a3,a1
    80002b90:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002b92:	7d38                	ld	a4,120(a0)
    80002b94:	00000697          	auipc	a3,0x0
    80002b98:	1ac68693          	addi	a3,a3,428 # 80002d40 <usertrap>
    80002b9c:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b9e:	7d38                	ld	a4,120(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002ba0:	8692                	mv	a3,tp
    80002ba2:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ba4:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002ba8:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002bac:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bb0:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002bb4:	7d38                	ld	a4,120(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bb6:	6f18                	ld	a4,24(a4)
    80002bb8:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002bbc:	792c                	ld	a1,112(a0)
    80002bbe:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002bc0:	00004717          	auipc	a4,0x4
    80002bc4:	4d070713          	addi	a4,a4,1232 # 80007090 <userret>
    80002bc8:	8f11                	sub	a4,a4,a2
    80002bca:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002bcc:	577d                	li	a4,-1
    80002bce:	177e                	slli	a4,a4,0x3f
    80002bd0:	8dd9                	or	a1,a1,a4
    80002bd2:	02000537          	lui	a0,0x2000
    80002bd6:	157d                	addi	a0,a0,-1
    80002bd8:	0536                	slli	a0,a0,0xd
    80002bda:	9782                	jalr	a5
}
    80002bdc:	60a2                	ld	ra,8(sp)
    80002bde:	6402                	ld	s0,0(sp)
    80002be0:	0141                	addi	sp,sp,16
    80002be2:	8082                	ret

0000000080002be4 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002be4:	7139                	addi	sp,sp,-64
    80002be6:	fc06                	sd	ra,56(sp)
    80002be8:	f822                	sd	s0,48(sp)
    80002bea:	f426                	sd	s1,40(sp)
    80002bec:	f04a                	sd	s2,32(sp)
    80002bee:	ec4e                	sd	s3,24(sp)
    80002bf0:	e852                	sd	s4,16(sp)
    80002bf2:	e456                	sd	s5,8(sp)
    80002bf4:	0080                	addi	s0,sp,64
  struct proc *p;
  acquire(&tickslock);
    80002bf6:	00015517          	auipc	a0,0x15
    80002bfa:	cf250513          	addi	a0,a0,-782 # 800178e8 <tickslock>
    80002bfe:	ffffe097          	auipc	ra,0xffffe
    80002c02:	fc4080e7          	jalr	-60(ra) # 80000bc2 <acquire>
  ticks++;
    80002c06:	00006717          	auipc	a4,0x6
    80002c0a:	42a70713          	addi	a4,a4,1066 # 80009030 <ticks>
    80002c0e:	431c                	lw	a5,0(a4)
    80002c10:	2785                	addiw	a5,a5,1
    80002c12:	c31c                	sw	a5,0(a4)
  
  for(p = proc; p < &proc[NPROC]; p++){
    80002c14:	0000f497          	auipc	s1,0xf
    80002c18:	ad448493          	addi	s1,s1,-1324 # 800116e8 <proc>
    acquire(&p->lock);
    if (p->state == RUNNING){
    80002c1c:	4991                	li	s3,4
      p->rutime ++;
    }
    else if (p->state == RUNNABLE){
    80002c1e:	4a0d                	li	s4,3
      p->retime ++;
    }
    else if (p->state == SLEEPING){
    80002c20:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++){
    80002c22:	00015917          	auipc	s2,0x15
    80002c26:	cc690913          	addi	s2,s2,-826 # 800178e8 <tickslock>
    80002c2a:	a829                	j	80002c44 <clockintr+0x60>
      p->rutime ++;
    80002c2c:	44bc                	lw	a5,72(s1)
    80002c2e:	2785                	addiw	a5,a5,1
    80002c30:	c4bc                	sw	a5,72(s1)
      p->stime ++;
    }
    release(&p->lock);
    80002c32:	8526                	mv	a0,s1
    80002c34:	ffffe097          	auipc	ra,0xffffe
    80002c38:	042080e7          	jalr	66(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002c3c:	18848493          	addi	s1,s1,392
    80002c40:	03248663          	beq	s1,s2,80002c6c <clockintr+0x88>
    acquire(&p->lock);
    80002c44:	8526                	mv	a0,s1
    80002c46:	ffffe097          	auipc	ra,0xffffe
    80002c4a:	f7c080e7          	jalr	-132(ra) # 80000bc2 <acquire>
    if (p->state == RUNNING){
    80002c4e:	4c9c                	lw	a5,24(s1)
    80002c50:	fd378ee3          	beq	a5,s3,80002c2c <clockintr+0x48>
    else if (p->state == RUNNABLE){
    80002c54:	01478863          	beq	a5,s4,80002c64 <clockintr+0x80>
    else if (p->state == SLEEPING){
    80002c58:	fd579de3          	bne	a5,s5,80002c32 <clockintr+0x4e>
      p->stime ++;
    80002c5c:	40bc                	lw	a5,64(s1)
    80002c5e:	2785                	addiw	a5,a5,1
    80002c60:	c0bc                	sw	a5,64(s1)
    80002c62:	bfc1                	j	80002c32 <clockintr+0x4e>
      p->retime ++;
    80002c64:	40fc                	lw	a5,68(s1)
    80002c66:	2785                	addiw	a5,a5,1
    80002c68:	c0fc                	sw	a5,68(s1)
    80002c6a:	b7e1                	j	80002c32 <clockintr+0x4e>
  }
  wakeup(&ticks);
    80002c6c:	00006517          	auipc	a0,0x6
    80002c70:	3c450513          	addi	a0,a0,964 # 80009030 <ticks>
    80002c74:	fffff097          	auipc	ra,0xfffff
    80002c78:	6de080e7          	jalr	1758(ra) # 80002352 <wakeup>
  release(&tickslock);
    80002c7c:	00015517          	auipc	a0,0x15
    80002c80:	c6c50513          	addi	a0,a0,-916 # 800178e8 <tickslock>
    80002c84:	ffffe097          	auipc	ra,0xffffe
    80002c88:	ff2080e7          	jalr	-14(ra) # 80000c76 <release>
}
    80002c8c:	70e2                	ld	ra,56(sp)
    80002c8e:	7442                	ld	s0,48(sp)
    80002c90:	74a2                	ld	s1,40(sp)
    80002c92:	7902                	ld	s2,32(sp)
    80002c94:	69e2                	ld	s3,24(sp)
    80002c96:	6a42                	ld	s4,16(sp)
    80002c98:	6aa2                	ld	s5,8(sp)
    80002c9a:	6121                	addi	sp,sp,64
    80002c9c:	8082                	ret

0000000080002c9e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002c9e:	1101                	addi	sp,sp,-32
    80002ca0:	ec06                	sd	ra,24(sp)
    80002ca2:	e822                	sd	s0,16(sp)
    80002ca4:	e426                	sd	s1,8(sp)
    80002ca6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ca8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002cac:	00074d63          	bltz	a4,80002cc6 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002cb0:	57fd                	li	a5,-1
    80002cb2:	17fe                	slli	a5,a5,0x3f
    80002cb4:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002cb6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002cb8:	06f70363          	beq	a4,a5,80002d1e <devintr+0x80>
  }
}
    80002cbc:	60e2                	ld	ra,24(sp)
    80002cbe:	6442                	ld	s0,16(sp)
    80002cc0:	64a2                	ld	s1,8(sp)
    80002cc2:	6105                	addi	sp,sp,32
    80002cc4:	8082                	ret
     (scause & 0xff) == 9){
    80002cc6:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002cca:	46a5                	li	a3,9
    80002ccc:	fed792e3          	bne	a5,a3,80002cb0 <devintr+0x12>
    int irq = plic_claim();
    80002cd0:	00003097          	auipc	ra,0x3
    80002cd4:	5b8080e7          	jalr	1464(ra) # 80006288 <plic_claim>
    80002cd8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002cda:	47a9                	li	a5,10
    80002cdc:	02f50763          	beq	a0,a5,80002d0a <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002ce0:	4785                	li	a5,1
    80002ce2:	02f50963          	beq	a0,a5,80002d14 <devintr+0x76>
    return 1;
    80002ce6:	4505                	li	a0,1
    } else if(irq){
    80002ce8:	d8f1                	beqz	s1,80002cbc <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002cea:	85a6                	mv	a1,s1
    80002cec:	00005517          	auipc	a0,0x5
    80002cf0:	70c50513          	addi	a0,a0,1804 # 800083f8 <states.0+0x38>
    80002cf4:	ffffe097          	auipc	ra,0xffffe
    80002cf8:	880080e7          	jalr	-1920(ra) # 80000574 <printf>
      plic_complete(irq);
    80002cfc:	8526                	mv	a0,s1
    80002cfe:	00003097          	auipc	ra,0x3
    80002d02:	5ae080e7          	jalr	1454(ra) # 800062ac <plic_complete>
    return 1;
    80002d06:	4505                	li	a0,1
    80002d08:	bf55                	j	80002cbc <devintr+0x1e>
      uartintr();
    80002d0a:	ffffe097          	auipc	ra,0xffffe
    80002d0e:	c7c080e7          	jalr	-900(ra) # 80000986 <uartintr>
    80002d12:	b7ed                	j	80002cfc <devintr+0x5e>
      virtio_disk_intr();
    80002d14:	00004097          	auipc	ra,0x4
    80002d18:	a2a080e7          	jalr	-1494(ra) # 8000673e <virtio_disk_intr>
    80002d1c:	b7c5                	j	80002cfc <devintr+0x5e>
    if(cpuid() == 0){
    80002d1e:	fffff097          	auipc	ra,0xfffff
    80002d22:	c4c080e7          	jalr	-948(ra) # 8000196a <cpuid>
    80002d26:	c901                	beqz	a0,80002d36 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002d28:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002d2c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002d2e:	14479073          	csrw	sip,a5
    return 2;
    80002d32:	4509                	li	a0,2
    80002d34:	b761                	j	80002cbc <devintr+0x1e>
      clockintr();
    80002d36:	00000097          	auipc	ra,0x0
    80002d3a:	eae080e7          	jalr	-338(ra) # 80002be4 <clockintr>
    80002d3e:	b7ed                	j	80002d28 <devintr+0x8a>

0000000080002d40 <usertrap>:
{
    80002d40:	1101                	addi	sp,sp,-32
    80002d42:	ec06                	sd	ra,24(sp)
    80002d44:	e822                	sd	s0,16(sp)
    80002d46:	e426                	sd	s1,8(sp)
    80002d48:	e04a                	sd	s2,0(sp)
    80002d4a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d4c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002d50:	1007f793          	andi	a5,a5,256
    80002d54:	e3ad                	bnez	a5,80002db6 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d56:	00003797          	auipc	a5,0x3
    80002d5a:	42a78793          	addi	a5,a5,1066 # 80006180 <kernelvec>
    80002d5e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002d62:	fffff097          	auipc	ra,0xfffff
    80002d66:	c34080e7          	jalr	-972(ra) # 80001996 <myproc>
    80002d6a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002d6c:	7d3c                	ld	a5,120(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d6e:	14102773          	csrr	a4,sepc
    80002d72:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d74:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002d78:	47a1                	li	a5,8
    80002d7a:	04f71c63          	bne	a4,a5,80002dd2 <usertrap+0x92>
    if(p->killed)
    80002d7e:	551c                	lw	a5,40(a0)
    80002d80:	e3b9                	bnez	a5,80002dc6 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002d82:	7cb8                	ld	a4,120(s1)
    80002d84:	6f1c                	ld	a5,24(a4)
    80002d86:	0791                	addi	a5,a5,4
    80002d88:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d8a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002d8e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d92:	10079073          	csrw	sstatus,a5
    syscall();
    80002d96:	00000097          	auipc	ra,0x0
    80002d9a:	2e0080e7          	jalr	736(ra) # 80003076 <syscall>
  if(p->killed)
    80002d9e:	549c                	lw	a5,40(s1)
    80002da0:	ebc1                	bnez	a5,80002e30 <usertrap+0xf0>
  usertrapret();
    80002da2:	00000097          	auipc	ra,0x0
    80002da6:	da4080e7          	jalr	-604(ra) # 80002b46 <usertrapret>
}
    80002daa:	60e2                	ld	ra,24(sp)
    80002dac:	6442                	ld	s0,16(sp)
    80002dae:	64a2                	ld	s1,8(sp)
    80002db0:	6902                	ld	s2,0(sp)
    80002db2:	6105                	addi	sp,sp,32
    80002db4:	8082                	ret
    panic("usertrap: not from user mode");
    80002db6:	00005517          	auipc	a0,0x5
    80002dba:	66250513          	addi	a0,a0,1634 # 80008418 <states.0+0x58>
    80002dbe:	ffffd097          	auipc	ra,0xffffd
    80002dc2:	76c080e7          	jalr	1900(ra) # 8000052a <panic>
      exit(-1);
    80002dc6:	557d                	li	a0,-1
    80002dc8:	fffff097          	auipc	ra,0xfffff
    80002dcc:	692080e7          	jalr	1682(ra) # 8000245a <exit>
    80002dd0:	bf4d                	j	80002d82 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002dd2:	00000097          	auipc	ra,0x0
    80002dd6:	ecc080e7          	jalr	-308(ra) # 80002c9e <devintr>
    80002dda:	892a                	mv	s2,a0
    80002ddc:	c501                	beqz	a0,80002de4 <usertrap+0xa4>
  if(p->killed)
    80002dde:	549c                	lw	a5,40(s1)
    80002de0:	c3a1                	beqz	a5,80002e20 <usertrap+0xe0>
    80002de2:	a815                	j	80002e16 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002de4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002de8:	5890                	lw	a2,48(s1)
    80002dea:	00005517          	auipc	a0,0x5
    80002dee:	64e50513          	addi	a0,a0,1614 # 80008438 <states.0+0x78>
    80002df2:	ffffd097          	auipc	ra,0xffffd
    80002df6:	782080e7          	jalr	1922(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002dfa:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002dfe:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e02:	00005517          	auipc	a0,0x5
    80002e06:	66650513          	addi	a0,a0,1638 # 80008468 <states.0+0xa8>
    80002e0a:	ffffd097          	auipc	ra,0xffffd
    80002e0e:	76a080e7          	jalr	1898(ra) # 80000574 <printf>
    p->killed = 1;
    80002e12:	4785                	li	a5,1
    80002e14:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002e16:	557d                	li	a0,-1
    80002e18:	fffff097          	auipc	ra,0xfffff
    80002e1c:	642080e7          	jalr	1602(ra) # 8000245a <exit>
  if(which_dev == 2)
    80002e20:	4789                	li	a5,2
    80002e22:	f8f910e3          	bne	s2,a5,80002da2 <usertrap+0x62>
    yield();
    80002e26:	fffff097          	auipc	ra,0xfffff
    80002e2a:	334080e7          	jalr	820(ra) # 8000215a <yield>
    80002e2e:	bf95                	j	80002da2 <usertrap+0x62>
  int which_dev = 0;
    80002e30:	4901                	li	s2,0
    80002e32:	b7d5                	j	80002e16 <usertrap+0xd6>

0000000080002e34 <kerneltrap>:
{
    80002e34:	7179                	addi	sp,sp,-48
    80002e36:	f406                	sd	ra,40(sp)
    80002e38:	f022                	sd	s0,32(sp)
    80002e3a:	ec26                	sd	s1,24(sp)
    80002e3c:	e84a                	sd	s2,16(sp)
    80002e3e:	e44e                	sd	s3,8(sp)
    80002e40:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e42:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e46:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e4a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002e4e:	1004f793          	andi	a5,s1,256
    80002e52:	cb85                	beqz	a5,80002e82 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e54:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002e58:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002e5a:	ef85                	bnez	a5,80002e92 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002e5c:	00000097          	auipc	ra,0x0
    80002e60:	e42080e7          	jalr	-446(ra) # 80002c9e <devintr>
    80002e64:	cd1d                	beqz	a0,80002ea2 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e66:	4789                	li	a5,2
    80002e68:	06f50a63          	beq	a0,a5,80002edc <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002e6c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e70:	10049073          	csrw	sstatus,s1
}
    80002e74:	70a2                	ld	ra,40(sp)
    80002e76:	7402                	ld	s0,32(sp)
    80002e78:	64e2                	ld	s1,24(sp)
    80002e7a:	6942                	ld	s2,16(sp)
    80002e7c:	69a2                	ld	s3,8(sp)
    80002e7e:	6145                	addi	sp,sp,48
    80002e80:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002e82:	00005517          	auipc	a0,0x5
    80002e86:	60650513          	addi	a0,a0,1542 # 80008488 <states.0+0xc8>
    80002e8a:	ffffd097          	auipc	ra,0xffffd
    80002e8e:	6a0080e7          	jalr	1696(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    80002e92:	00005517          	auipc	a0,0x5
    80002e96:	61e50513          	addi	a0,a0,1566 # 800084b0 <states.0+0xf0>
    80002e9a:	ffffd097          	auipc	ra,0xffffd
    80002e9e:	690080e7          	jalr	1680(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    80002ea2:	85ce                	mv	a1,s3
    80002ea4:	00005517          	auipc	a0,0x5
    80002ea8:	62c50513          	addi	a0,a0,1580 # 800084d0 <states.0+0x110>
    80002eac:	ffffd097          	auipc	ra,0xffffd
    80002eb0:	6c8080e7          	jalr	1736(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002eb4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002eb8:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ebc:	00005517          	auipc	a0,0x5
    80002ec0:	62450513          	addi	a0,a0,1572 # 800084e0 <states.0+0x120>
    80002ec4:	ffffd097          	auipc	ra,0xffffd
    80002ec8:	6b0080e7          	jalr	1712(ra) # 80000574 <printf>
    panic("kerneltrap");
    80002ecc:	00005517          	auipc	a0,0x5
    80002ed0:	62c50513          	addi	a0,a0,1580 # 800084f8 <states.0+0x138>
    80002ed4:	ffffd097          	auipc	ra,0xffffd
    80002ed8:	656080e7          	jalr	1622(ra) # 8000052a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002edc:	fffff097          	auipc	ra,0xfffff
    80002ee0:	aba080e7          	jalr	-1350(ra) # 80001996 <myproc>
    80002ee4:	d541                	beqz	a0,80002e6c <kerneltrap+0x38>
    80002ee6:	fffff097          	auipc	ra,0xfffff
    80002eea:	ab0080e7          	jalr	-1360(ra) # 80001996 <myproc>
    80002eee:	4d18                	lw	a4,24(a0)
    80002ef0:	4791                	li	a5,4
    80002ef2:	f6f71de3          	bne	a4,a5,80002e6c <kerneltrap+0x38>
    yield();
    80002ef6:	fffff097          	auipc	ra,0xfffff
    80002efa:	264080e7          	jalr	612(ra) # 8000215a <yield>
    80002efe:	b7bd                	j	80002e6c <kerneltrap+0x38>

0000000080002f00 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002f00:	1101                	addi	sp,sp,-32
    80002f02:	ec06                	sd	ra,24(sp)
    80002f04:	e822                	sd	s0,16(sp)
    80002f06:	e426                	sd	s1,8(sp)
    80002f08:	1000                	addi	s0,sp,32
    80002f0a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002f0c:	fffff097          	auipc	ra,0xfffff
    80002f10:	a8a080e7          	jalr	-1398(ra) # 80001996 <myproc>
  switch (n) {
    80002f14:	4795                	li	a5,5
    80002f16:	0497e163          	bltu	a5,s1,80002f58 <argraw+0x58>
    80002f1a:	048a                	slli	s1,s1,0x2
    80002f1c:	00005717          	auipc	a4,0x5
    80002f20:	6fc70713          	addi	a4,a4,1788 # 80008618 <states.0+0x258>
    80002f24:	94ba                	add	s1,s1,a4
    80002f26:	409c                	lw	a5,0(s1)
    80002f28:	97ba                	add	a5,a5,a4
    80002f2a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002f2c:	7d3c                	ld	a5,120(a0)
    80002f2e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002f30:	60e2                	ld	ra,24(sp)
    80002f32:	6442                	ld	s0,16(sp)
    80002f34:	64a2                	ld	s1,8(sp)
    80002f36:	6105                	addi	sp,sp,32
    80002f38:	8082                	ret
    return p->trapframe->a1;
    80002f3a:	7d3c                	ld	a5,120(a0)
    80002f3c:	7fa8                	ld	a0,120(a5)
    80002f3e:	bfcd                	j	80002f30 <argraw+0x30>
    return p->trapframe->a2;
    80002f40:	7d3c                	ld	a5,120(a0)
    80002f42:	63c8                	ld	a0,128(a5)
    80002f44:	b7f5                	j	80002f30 <argraw+0x30>
    return p->trapframe->a3;
    80002f46:	7d3c                	ld	a5,120(a0)
    80002f48:	67c8                	ld	a0,136(a5)
    80002f4a:	b7dd                	j	80002f30 <argraw+0x30>
    return p->trapframe->a4;
    80002f4c:	7d3c                	ld	a5,120(a0)
    80002f4e:	6bc8                	ld	a0,144(a5)
    80002f50:	b7c5                	j	80002f30 <argraw+0x30>
    return p->trapframe->a5;
    80002f52:	7d3c                	ld	a5,120(a0)
    80002f54:	6fc8                	ld	a0,152(a5)
    80002f56:	bfe9                	j	80002f30 <argraw+0x30>
  panic("argraw");
    80002f58:	00005517          	auipc	a0,0x5
    80002f5c:	5b050513          	addi	a0,a0,1456 # 80008508 <states.0+0x148>
    80002f60:	ffffd097          	auipc	ra,0xffffd
    80002f64:	5ca080e7          	jalr	1482(ra) # 8000052a <panic>

0000000080002f68 <fetchaddr>:
{
    80002f68:	1101                	addi	sp,sp,-32
    80002f6a:	ec06                	sd	ra,24(sp)
    80002f6c:	e822                	sd	s0,16(sp)
    80002f6e:	e426                	sd	s1,8(sp)
    80002f70:	e04a                	sd	s2,0(sp)
    80002f72:	1000                	addi	s0,sp,32
    80002f74:	84aa                	mv	s1,a0
    80002f76:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002f78:	fffff097          	auipc	ra,0xfffff
    80002f7c:	a1e080e7          	jalr	-1506(ra) # 80001996 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002f80:	753c                	ld	a5,104(a0)
    80002f82:	02f4f863          	bgeu	s1,a5,80002fb2 <fetchaddr+0x4a>
    80002f86:	00848713          	addi	a4,s1,8
    80002f8a:	02e7e663          	bltu	a5,a4,80002fb6 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002f8e:	46a1                	li	a3,8
    80002f90:	8626                	mv	a2,s1
    80002f92:	85ca                	mv	a1,s2
    80002f94:	7928                	ld	a0,112(a0)
    80002f96:	ffffe097          	auipc	ra,0xffffe
    80002f9a:	734080e7          	jalr	1844(ra) # 800016ca <copyin>
    80002f9e:	00a03533          	snez	a0,a0
    80002fa2:	40a00533          	neg	a0,a0
}
    80002fa6:	60e2                	ld	ra,24(sp)
    80002fa8:	6442                	ld	s0,16(sp)
    80002faa:	64a2                	ld	s1,8(sp)
    80002fac:	6902                	ld	s2,0(sp)
    80002fae:	6105                	addi	sp,sp,32
    80002fb0:	8082                	ret
    return -1;
    80002fb2:	557d                	li	a0,-1
    80002fb4:	bfcd                	j	80002fa6 <fetchaddr+0x3e>
    80002fb6:	557d                	li	a0,-1
    80002fb8:	b7fd                	j	80002fa6 <fetchaddr+0x3e>

0000000080002fba <fetchstr>:
{
    80002fba:	7179                	addi	sp,sp,-48
    80002fbc:	f406                	sd	ra,40(sp)
    80002fbe:	f022                	sd	s0,32(sp)
    80002fc0:	ec26                	sd	s1,24(sp)
    80002fc2:	e84a                	sd	s2,16(sp)
    80002fc4:	e44e                	sd	s3,8(sp)
    80002fc6:	1800                	addi	s0,sp,48
    80002fc8:	892a                	mv	s2,a0
    80002fca:	84ae                	mv	s1,a1
    80002fcc:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002fce:	fffff097          	auipc	ra,0xfffff
    80002fd2:	9c8080e7          	jalr	-1592(ra) # 80001996 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002fd6:	86ce                	mv	a3,s3
    80002fd8:	864a                	mv	a2,s2
    80002fda:	85a6                	mv	a1,s1
    80002fdc:	7928                	ld	a0,112(a0)
    80002fde:	ffffe097          	auipc	ra,0xffffe
    80002fe2:	77a080e7          	jalr	1914(ra) # 80001758 <copyinstr>
  if(err < 0)
    80002fe6:	00054763          	bltz	a0,80002ff4 <fetchstr+0x3a>
  return strlen(buf);
    80002fea:	8526                	mv	a0,s1
    80002fec:	ffffe097          	auipc	ra,0xffffe
    80002ff0:	e56080e7          	jalr	-426(ra) # 80000e42 <strlen>
}
    80002ff4:	70a2                	ld	ra,40(sp)
    80002ff6:	7402                	ld	s0,32(sp)
    80002ff8:	64e2                	ld	s1,24(sp)
    80002ffa:	6942                	ld	s2,16(sp)
    80002ffc:	69a2                	ld	s3,8(sp)
    80002ffe:	6145                	addi	sp,sp,48
    80003000:	8082                	ret

0000000080003002 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003002:	1101                	addi	sp,sp,-32
    80003004:	ec06                	sd	ra,24(sp)
    80003006:	e822                	sd	s0,16(sp)
    80003008:	e426                	sd	s1,8(sp)
    8000300a:	1000                	addi	s0,sp,32
    8000300c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000300e:	00000097          	auipc	ra,0x0
    80003012:	ef2080e7          	jalr	-270(ra) # 80002f00 <argraw>
    80003016:	c088                	sw	a0,0(s1)
  return 0;
}
    80003018:	4501                	li	a0,0
    8000301a:	60e2                	ld	ra,24(sp)
    8000301c:	6442                	ld	s0,16(sp)
    8000301e:	64a2                	ld	s1,8(sp)
    80003020:	6105                	addi	sp,sp,32
    80003022:	8082                	ret

0000000080003024 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003024:	1101                	addi	sp,sp,-32
    80003026:	ec06                	sd	ra,24(sp)
    80003028:	e822                	sd	s0,16(sp)
    8000302a:	e426                	sd	s1,8(sp)
    8000302c:	1000                	addi	s0,sp,32
    8000302e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003030:	00000097          	auipc	ra,0x0
    80003034:	ed0080e7          	jalr	-304(ra) # 80002f00 <argraw>
    80003038:	e088                	sd	a0,0(s1)
  return 0;
}
    8000303a:	4501                	li	a0,0
    8000303c:	60e2                	ld	ra,24(sp)
    8000303e:	6442                	ld	s0,16(sp)
    80003040:	64a2                	ld	s1,8(sp)
    80003042:	6105                	addi	sp,sp,32
    80003044:	8082                	ret

0000000080003046 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003046:	1101                	addi	sp,sp,-32
    80003048:	ec06                	sd	ra,24(sp)
    8000304a:	e822                	sd	s0,16(sp)
    8000304c:	e426                	sd	s1,8(sp)
    8000304e:	e04a                	sd	s2,0(sp)
    80003050:	1000                	addi	s0,sp,32
    80003052:	84ae                	mv	s1,a1
    80003054:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003056:	00000097          	auipc	ra,0x0
    8000305a:	eaa080e7          	jalr	-342(ra) # 80002f00 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    8000305e:	864a                	mv	a2,s2
    80003060:	85a6                	mv	a1,s1
    80003062:	00000097          	auipc	ra,0x0
    80003066:	f58080e7          	jalr	-168(ra) # 80002fba <fetchstr>
}
    8000306a:	60e2                	ld	ra,24(sp)
    8000306c:	6442                	ld	s0,16(sp)
    8000306e:	64a2                	ld	s1,8(sp)
    80003070:	6902                	ld	s2,0(sp)
    80003072:	6105                	addi	sp,sp,32
    80003074:	8082                	ret

0000000080003076 <syscall>:
[SYS_wait_stat] "wait_stat" };

// modified
void
syscall(void)
{
    80003076:	7139                	addi	sp,sp,-64
    80003078:	fc06                	sd	ra,56(sp)
    8000307a:	f822                	sd	s0,48(sp)
    8000307c:	f426                	sd	s1,40(sp)
    8000307e:	f04a                	sd	s2,32(sp)
    80003080:	ec4e                	sd	s3,24(sp)
    80003082:	e852                	sd	s4,16(sp)
    80003084:	e456                	sd	s5,8(sp)
    80003086:	0080                	addi	s0,sp,64
  int num;
  struct proc *p = myproc();
    80003088:	fffff097          	auipc	ra,0xfffff
    8000308c:	90e080e7          	jalr	-1778(ra) # 80001996 <myproc>
    80003090:	84aa                	mv	s1,a0
  num = p->trapframe->a7;
    80003092:	07853903          	ld	s2,120(a0)
    80003096:	0a892983          	lw	s3,168(s2)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000309a:	fff9871b          	addiw	a4,s3,-1
    8000309e:	47d9                	li	a5,22
    800030a0:	08e7ed63          	bltu	a5,a4,8000313a <syscall+0xc4>
    800030a4:	00399713          	slli	a4,s3,0x3
    800030a8:	00005797          	auipc	a5,0x5
    800030ac:	58878793          	addi	a5,a5,1416 # 80008630 <syscalls>
    800030b0:	97ba                	add	a5,a5,a4
    800030b2:	639c                	ld	a5,0(a5)
    800030b4:	c3d9                	beqz	a5,8000313a <syscall+0xc4>
    int arguments =p->trapframe->a0;
    800030b6:	07093a83          	ld	s5,112(s2)
    p->trapframe->a0 = syscalls[num]();
    800030ba:	9782                	jalr	a5
    800030bc:	06a93823          	sd	a0,112(s2)
    if ((p->maskid) > 0 ) { //trace flag is app
    800030c0:	58dc                	lw	a5,52(s1)
    800030c2:	08f05b63          	blez	a5,80003158 <syscall+0xe2>
      if (((1<<num) & (p->maskid)) == (1<<num)){ //current systemcall need tracing
    800030c6:	4705                	li	a4,1
    800030c8:	0137173b          	sllw	a4,a4,s3
    800030cc:	8ff9                	and	a5,a5,a4
    800030ce:	08f71563          	bne	a4,a5,80003158 <syscall+0xe2>
        if ((num == SYS_fork) || (num == SYS_kill) || (num == SYS_sbrk)){ //print arguments
    800030d2:	47b1                	li	a5,12
    800030d4:	0137e963          	bltu	a5,s3,800030e6 <syscall+0x70>
    800030d8:	6785                	lui	a5,0x1
    800030da:	04278793          	addi	a5,a5,66 # 1042 <_entry-0x7fffefbe>
    800030de:	0137d7b3          	srl	a5,a5,s3
    800030e2:	8b85                	andi	a5,a5,1
    800030e4:	e78d                	bnez	a5,8000310e <syscall+0x98>
          printf("%d: syscall %s %d-> %d\n",p->pid,syscallsnames[num], arguments ,p->trapframe->a0);
        }
        else{ //without arguments 
          printf("%d: syscall %s -> %d\n",p->pid,syscallsnames[num], p->trapframe->a0 );
    800030e6:	7cb8                	ld	a4,120(s1)
    800030e8:	098e                	slli	s3,s3,0x3
    800030ea:	00006797          	auipc	a5,0x6
    800030ee:	99e78793          	addi	a5,a5,-1634 # 80008a88 <syscallsnames>
    800030f2:	99be                	add	s3,s3,a5
    800030f4:	7b34                	ld	a3,112(a4)
    800030f6:	0009b603          	ld	a2,0(s3)
    800030fa:	588c                	lw	a1,48(s1)
    800030fc:	00005517          	auipc	a0,0x5
    80003100:	42c50513          	addi	a0,a0,1068 # 80008528 <states.0+0x168>
    80003104:	ffffd097          	auipc	ra,0xffffd
    80003108:	470080e7          	jalr	1136(ra) # 80000574 <printf>
    8000310c:	a0b1                	j	80003158 <syscall+0xe2>
          printf("%d: syscall %s %d-> %d\n",p->pid,syscallsnames[num], arguments ,p->trapframe->a0);
    8000310e:	7cb8                	ld	a4,120(s1)
    80003110:	098e                	slli	s3,s3,0x3
    80003112:	00006797          	auipc	a5,0x6
    80003116:	97678793          	addi	a5,a5,-1674 # 80008a88 <syscallsnames>
    8000311a:	99be                	add	s3,s3,a5
    8000311c:	7b38                	ld	a4,112(a4)
    8000311e:	000a869b          	sext.w	a3,s5
    80003122:	0009b603          	ld	a2,0(s3)
    80003126:	588c                	lw	a1,48(s1)
    80003128:	00005517          	auipc	a0,0x5
    8000312c:	3e850513          	addi	a0,a0,1000 # 80008510 <states.0+0x150>
    80003130:	ffffd097          	auipc	ra,0xffffd
    80003134:	444080e7          	jalr	1092(ra) # 80000574 <printf>
    80003138:	a005                	j	80003158 <syscall+0xe2>
        }
      }
    }
  } else { 
    printf("%d %s: unknown sys call %d\n",p->pid, p->name, num);
    8000313a:	86ce                	mv	a3,s3
    8000313c:	17848613          	addi	a2,s1,376
    80003140:	588c                	lw	a1,48(s1)
    80003142:	00005517          	auipc	a0,0x5
    80003146:	3fe50513          	addi	a0,a0,1022 # 80008540 <states.0+0x180>
    8000314a:	ffffd097          	auipc	ra,0xffffd
    8000314e:	42a080e7          	jalr	1066(ra) # 80000574 <printf>
    p->trapframe->a0 = -1;
    80003152:	7cbc                	ld	a5,120(s1)
    80003154:	577d                	li	a4,-1
    80003156:	fbb8                	sd	a4,112(a5)
  }
}
    80003158:	70e2                	ld	ra,56(sp)
    8000315a:	7442                	ld	s0,48(sp)
    8000315c:	74a2                	ld	s1,40(sp)
    8000315e:	7902                	ld	s2,32(sp)
    80003160:	69e2                	ld	s3,24(sp)
    80003162:	6a42                	ld	s4,16(sp)
    80003164:	6aa2                	ld	s5,8(sp)
    80003166:	6121                	addi	sp,sp,64
    80003168:	8082                	ret

000000008000316a <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    8000316a:	1101                	addi	sp,sp,-32
    8000316c:	ec06                	sd	ra,24(sp)
    8000316e:	e822                	sd	s0,16(sp)
    80003170:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003172:	fec40593          	addi	a1,s0,-20
    80003176:	4501                	li	a0,0
    80003178:	00000097          	auipc	ra,0x0
    8000317c:	e8a080e7          	jalr	-374(ra) # 80003002 <argint>
    return -1;
    80003180:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003182:	00054963          	bltz	a0,80003194 <sys_exit+0x2a>
  exit(n);
    80003186:	fec42503          	lw	a0,-20(s0)
    8000318a:	fffff097          	auipc	ra,0xfffff
    8000318e:	2d0080e7          	jalr	720(ra) # 8000245a <exit>
  return 0;  // not reached
    80003192:	4781                	li	a5,0
}
    80003194:	853e                	mv	a0,a5
    80003196:	60e2                	ld	ra,24(sp)
    80003198:	6442                	ld	s0,16(sp)
    8000319a:	6105                	addi	sp,sp,32
    8000319c:	8082                	ret

000000008000319e <sys_getpid>:

uint64
sys_getpid(void)
{
    8000319e:	1141                	addi	sp,sp,-16
    800031a0:	e406                	sd	ra,8(sp)
    800031a2:	e022                	sd	s0,0(sp)
    800031a4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800031a6:	ffffe097          	auipc	ra,0xffffe
    800031aa:	7f0080e7          	jalr	2032(ra) # 80001996 <myproc>
}
    800031ae:	5908                	lw	a0,48(a0)
    800031b0:	60a2                	ld	ra,8(sp)
    800031b2:	6402                	ld	s0,0(sp)
    800031b4:	0141                	addi	sp,sp,16
    800031b6:	8082                	ret

00000000800031b8 <sys_fork>:

uint64
sys_fork(void)
{
    800031b8:	1141                	addi	sp,sp,-16
    800031ba:	e406                	sd	ra,8(sp)
    800031bc:	e022                	sd	s0,0(sp)
    800031be:	0800                	addi	s0,sp,16
  return fork();
    800031c0:	fffff097          	auipc	ra,0xfffff
    800031c4:	c08080e7          	jalr	-1016(ra) # 80001dc8 <fork>
}
    800031c8:	60a2                	ld	ra,8(sp)
    800031ca:	6402                	ld	s0,0(sp)
    800031cc:	0141                	addi	sp,sp,16
    800031ce:	8082                	ret

00000000800031d0 <sys_wait>:

uint64
sys_wait(void)
{
    800031d0:	1101                	addi	sp,sp,-32
    800031d2:	ec06                	sd	ra,24(sp)
    800031d4:	e822                	sd	s0,16(sp)
    800031d6:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    800031d8:	fe840593          	addi	a1,s0,-24
    800031dc:	4501                	li	a0,0
    800031de:	00000097          	auipc	ra,0x0
    800031e2:	e46080e7          	jalr	-442(ra) # 80003024 <argaddr>
    800031e6:	87aa                	mv	a5,a0
    return -1;
    800031e8:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    800031ea:	0007c863          	bltz	a5,800031fa <sys_wait+0x2a>
  return wait(p);
    800031ee:	fe843503          	ld	a0,-24(s0)
    800031f2:	fffff097          	auipc	ra,0xfffff
    800031f6:	038080e7          	jalr	56(ra) # 8000222a <wait>
}
    800031fa:	60e2                	ld	ra,24(sp)
    800031fc:	6442                	ld	s0,16(sp)
    800031fe:	6105                	addi	sp,sp,32
    80003200:	8082                	ret

0000000080003202 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003202:	7179                	addi	sp,sp,-48
    80003204:	f406                	sd	ra,40(sp)
    80003206:	f022                	sd	s0,32(sp)
    80003208:	ec26                	sd	s1,24(sp)
    8000320a:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    8000320c:	fdc40593          	addi	a1,s0,-36
    80003210:	4501                	li	a0,0
    80003212:	00000097          	auipc	ra,0x0
    80003216:	df0080e7          	jalr	-528(ra) # 80003002 <argint>
    return -1;
    8000321a:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    8000321c:	00054f63          	bltz	a0,8000323a <sys_sbrk+0x38>
  addr = myproc()->sz;
    80003220:	ffffe097          	auipc	ra,0xffffe
    80003224:	776080e7          	jalr	1910(ra) # 80001996 <myproc>
    80003228:	5524                	lw	s1,104(a0)
  if(growproc(n) < 0)
    8000322a:	fdc42503          	lw	a0,-36(s0)
    8000322e:	fffff097          	auipc	ra,0xfffff
    80003232:	b26080e7          	jalr	-1242(ra) # 80001d54 <growproc>
    80003236:	00054863          	bltz	a0,80003246 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    8000323a:	8526                	mv	a0,s1
    8000323c:	70a2                	ld	ra,40(sp)
    8000323e:	7402                	ld	s0,32(sp)
    80003240:	64e2                	ld	s1,24(sp)
    80003242:	6145                	addi	sp,sp,48
    80003244:	8082                	ret
    return -1;
    80003246:	54fd                	li	s1,-1
    80003248:	bfcd                	j	8000323a <sys_sbrk+0x38>

000000008000324a <sys_sleep>:

uint64
sys_sleep(void)
{
    8000324a:	7139                	addi	sp,sp,-64
    8000324c:	fc06                	sd	ra,56(sp)
    8000324e:	f822                	sd	s0,48(sp)
    80003250:	f426                	sd	s1,40(sp)
    80003252:	f04a                	sd	s2,32(sp)
    80003254:	ec4e                	sd	s3,24(sp)
    80003256:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003258:	fcc40593          	addi	a1,s0,-52
    8000325c:	4501                	li	a0,0
    8000325e:	00000097          	auipc	ra,0x0
    80003262:	da4080e7          	jalr	-604(ra) # 80003002 <argint>
    return -1;
    80003266:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003268:	06054563          	bltz	a0,800032d2 <sys_sleep+0x88>
  acquire(&tickslock);
    8000326c:	00014517          	auipc	a0,0x14
    80003270:	67c50513          	addi	a0,a0,1660 # 800178e8 <tickslock>
    80003274:	ffffe097          	auipc	ra,0xffffe
    80003278:	94e080e7          	jalr	-1714(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    8000327c:	00006917          	auipc	s2,0x6
    80003280:	db492903          	lw	s2,-588(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80003284:	fcc42783          	lw	a5,-52(s0)
    80003288:	cf85                	beqz	a5,800032c0 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000328a:	00014997          	auipc	s3,0x14
    8000328e:	65e98993          	addi	s3,s3,1630 # 800178e8 <tickslock>
    80003292:	00006497          	auipc	s1,0x6
    80003296:	d9e48493          	addi	s1,s1,-610 # 80009030 <ticks>
    if(myproc()->killed){
    8000329a:	ffffe097          	auipc	ra,0xffffe
    8000329e:	6fc080e7          	jalr	1788(ra) # 80001996 <myproc>
    800032a2:	551c                	lw	a5,40(a0)
    800032a4:	ef9d                	bnez	a5,800032e2 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    800032a6:	85ce                	mv	a1,s3
    800032a8:	8526                	mv	a0,s1
    800032aa:	fffff097          	auipc	ra,0xfffff
    800032ae:	f1c080e7          	jalr	-228(ra) # 800021c6 <sleep>
  while(ticks - ticks0 < n){
    800032b2:	409c                	lw	a5,0(s1)
    800032b4:	412787bb          	subw	a5,a5,s2
    800032b8:	fcc42703          	lw	a4,-52(s0)
    800032bc:	fce7efe3          	bltu	a5,a4,8000329a <sys_sleep+0x50>
  }
  release(&tickslock);
    800032c0:	00014517          	auipc	a0,0x14
    800032c4:	62850513          	addi	a0,a0,1576 # 800178e8 <tickslock>
    800032c8:	ffffe097          	auipc	ra,0xffffe
    800032cc:	9ae080e7          	jalr	-1618(ra) # 80000c76 <release>
  return 0;
    800032d0:	4781                	li	a5,0
}
    800032d2:	853e                	mv	a0,a5
    800032d4:	70e2                	ld	ra,56(sp)
    800032d6:	7442                	ld	s0,48(sp)
    800032d8:	74a2                	ld	s1,40(sp)
    800032da:	7902                	ld	s2,32(sp)
    800032dc:	69e2                	ld	s3,24(sp)
    800032de:	6121                	addi	sp,sp,64
    800032e0:	8082                	ret
      release(&tickslock);
    800032e2:	00014517          	auipc	a0,0x14
    800032e6:	60650513          	addi	a0,a0,1542 # 800178e8 <tickslock>
    800032ea:	ffffe097          	auipc	ra,0xffffe
    800032ee:	98c080e7          	jalr	-1652(ra) # 80000c76 <release>
      return -1;
    800032f2:	57fd                	li	a5,-1
    800032f4:	bff9                	j	800032d2 <sys_sleep+0x88>

00000000800032f6 <sys_kill>:

uint64
sys_kill(void)
{
    800032f6:	1101                	addi	sp,sp,-32
    800032f8:	ec06                	sd	ra,24(sp)
    800032fa:	e822                	sd	s0,16(sp)
    800032fc:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800032fe:	fec40593          	addi	a1,s0,-20
    80003302:	4501                	li	a0,0
    80003304:	00000097          	auipc	ra,0x0
    80003308:	cfe080e7          	jalr	-770(ra) # 80003002 <argint>
    8000330c:	87aa                	mv	a5,a0
    return -1;
    8000330e:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003310:	0007c863          	bltz	a5,80003320 <sys_kill+0x2a>
  return kill(pid);
    80003314:	fec42503          	lw	a0,-20(s0)
    80003318:	fffff097          	auipc	ra,0xfffff
    8000331c:	224080e7          	jalr	548(ra) # 8000253c <kill>
}
    80003320:	60e2                	ld	ra,24(sp)
    80003322:	6442                	ld	s0,16(sp)
    80003324:	6105                	addi	sp,sp,32
    80003326:	8082                	ret

0000000080003328 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003328:	1101                	addi	sp,sp,-32
    8000332a:	ec06                	sd	ra,24(sp)
    8000332c:	e822                	sd	s0,16(sp)
    8000332e:	e426                	sd	s1,8(sp)
    80003330:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003332:	00014517          	auipc	a0,0x14
    80003336:	5b650513          	addi	a0,a0,1462 # 800178e8 <tickslock>
    8000333a:	ffffe097          	auipc	ra,0xffffe
    8000333e:	888080e7          	jalr	-1912(ra) # 80000bc2 <acquire>
  xticks = ticks;
    80003342:	00006497          	auipc	s1,0x6
    80003346:	cee4a483          	lw	s1,-786(s1) # 80009030 <ticks>
  release(&tickslock);
    8000334a:	00014517          	auipc	a0,0x14
    8000334e:	59e50513          	addi	a0,a0,1438 # 800178e8 <tickslock>
    80003352:	ffffe097          	auipc	ra,0xffffe
    80003356:	924080e7          	jalr	-1756(ra) # 80000c76 <release>
  return xticks;
}
    8000335a:	02049513          	slli	a0,s1,0x20
    8000335e:	9101                	srli	a0,a0,0x20
    80003360:	60e2                	ld	ra,24(sp)
    80003362:	6442                	ld	s0,16(sp)
    80003364:	64a2                	ld	s1,8(sp)
    80003366:	6105                	addi	sp,sp,32
    80003368:	8082                	ret

000000008000336a <sys_trace>:

// modified
uint64
sys_trace(void)
{
    8000336a:	1101                	addi	sp,sp,-32
    8000336c:	ec06                	sd	ra,24(sp)
    8000336e:	e822                	sd	s0,16(sp)
    80003370:	1000                	addi	s0,sp,32
  int maskid, pid;
  if (argint(0, &maskid) < 0)
    80003372:	fec40593          	addi	a1,s0,-20
    80003376:	4501                	li	a0,0
    80003378:	00000097          	auipc	ra,0x0
    8000337c:	c8a080e7          	jalr	-886(ra) # 80003002 <argint>
    return -1;
    80003380:	57fd                	li	a5,-1
  if (argint(0, &maskid) < 0)
    80003382:	02054563          	bltz	a0,800033ac <sys_trace+0x42>
  if (argint(1, &pid) < 0)
    80003386:	fe840593          	addi	a1,s0,-24
    8000338a:	4505                	li	a0,1
    8000338c:	00000097          	auipc	ra,0x0
    80003390:	c76080e7          	jalr	-906(ra) # 80003002 <argint>
    return -1;
    80003394:	57fd                	li	a5,-1
  if (argint(1, &pid) < 0)
    80003396:	00054b63          	bltz	a0,800033ac <sys_trace+0x42>
  trace(maskid,pid);
    8000339a:	fe842583          	lw	a1,-24(s0)
    8000339e:	fec42503          	lw	a0,-20(s0)
    800033a2:	fffff097          	auipc	ra,0xfffff
    800033a6:	394080e7          	jalr	916(ra) # 80002736 <trace>
  return 0;
    800033aa:	4781                	li	a5,0
}
    800033ac:	853e                	mv	a0,a5
    800033ae:	60e2                	ld	ra,24(sp)
    800033b0:	6442                	ld	s0,16(sp)
    800033b2:	6105                	addi	sp,sp,32
    800033b4:	8082                	ret

00000000800033b6 <sys_wait_stat>:

// modified
uint64
sys_wait_stat(void)
{
    800033b6:	1101                	addi	sp,sp,-32
    800033b8:	ec06                	sd	ra,24(sp)
    800033ba:	e822                	sd	s0,16(sp)
    800033bc:	1000                	addi	s0,sp,32
  int* status;
  struct perf* performance;

  if(argint(0, (void*)&status) < 0){
    800033be:	fe840593          	addi	a1,s0,-24
    800033c2:	4501                	li	a0,0
    800033c4:	00000097          	auipc	ra,0x0
    800033c8:	c3e080e7          	jalr	-962(ra) # 80003002 <argint>
    800033cc:	02054763          	bltz	a0,800033fa <sys_wait_stat+0x44>
    printf("\nIts got to sysproc.c line 3");
    return -1;
  }
  if(argaddr(1, (void*)&performance) < 0){
    800033d0:	fe040593          	addi	a1,s0,-32
    800033d4:	4505                	li	a0,1
    800033d6:	00000097          	auipc	ra,0x0
    800033da:	c4e080e7          	jalr	-946(ra) # 80003024 <argaddr>
    800033de:	02054863          	bltz	a0,8000340e <sys_wait_stat+0x58>
    printf("\nIts got to sysproc.c line 4");
    return -1;
  }
  return wait_stat(status,performance);
    800033e2:	fe043583          	ld	a1,-32(s0)
    800033e6:	fe843503          	ld	a0,-24(s0)
    800033ea:	fffff097          	auipc	ra,0xfffff
    800033ee:	3b6080e7          	jalr	950(ra) # 800027a0 <wait_stat>
    800033f2:	60e2                	ld	ra,24(sp)
    800033f4:	6442                	ld	s0,16(sp)
    800033f6:	6105                	addi	sp,sp,32
    800033f8:	8082                	ret
    printf("\nIts got to sysproc.c line 3");
    800033fa:	00005517          	auipc	a0,0x5
    800033fe:	2f650513          	addi	a0,a0,758 # 800086f0 <syscalls+0xc0>
    80003402:	ffffd097          	auipc	ra,0xffffd
    80003406:	172080e7          	jalr	370(ra) # 80000574 <printf>
    return -1;
    8000340a:	557d                	li	a0,-1
    8000340c:	b7dd                	j	800033f2 <sys_wait_stat+0x3c>
    printf("\nIts got to sysproc.c line 4");
    8000340e:	00005517          	auipc	a0,0x5
    80003412:	30250513          	addi	a0,a0,770 # 80008710 <syscalls+0xe0>
    80003416:	ffffd097          	auipc	ra,0xffffd
    8000341a:	15e080e7          	jalr	350(ra) # 80000574 <printf>
    return -1;
    8000341e:	557d                	li	a0,-1
    80003420:	bfc9                	j	800033f2 <sys_wait_stat+0x3c>

0000000080003422 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003422:	7179                	addi	sp,sp,-48
    80003424:	f406                	sd	ra,40(sp)
    80003426:	f022                	sd	s0,32(sp)
    80003428:	ec26                	sd	s1,24(sp)
    8000342a:	e84a                	sd	s2,16(sp)
    8000342c:	e44e                	sd	s3,8(sp)
    8000342e:	e052                	sd	s4,0(sp)
    80003430:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003432:	00005597          	auipc	a1,0x5
    80003436:	2fe58593          	addi	a1,a1,766 # 80008730 <syscalls+0x100>
    8000343a:	00014517          	auipc	a0,0x14
    8000343e:	4c650513          	addi	a0,a0,1222 # 80017900 <bcache>
    80003442:	ffffd097          	auipc	ra,0xffffd
    80003446:	6f0080e7          	jalr	1776(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000344a:	0001c797          	auipc	a5,0x1c
    8000344e:	4b678793          	addi	a5,a5,1206 # 8001f900 <bcache+0x8000>
    80003452:	0001c717          	auipc	a4,0x1c
    80003456:	71670713          	addi	a4,a4,1814 # 8001fb68 <bcache+0x8268>
    8000345a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000345e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003462:	00014497          	auipc	s1,0x14
    80003466:	4b648493          	addi	s1,s1,1206 # 80017918 <bcache+0x18>
    b->next = bcache.head.next;
    8000346a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000346c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000346e:	00005a17          	auipc	s4,0x5
    80003472:	2caa0a13          	addi	s4,s4,714 # 80008738 <syscalls+0x108>
    b->next = bcache.head.next;
    80003476:	2b893783          	ld	a5,696(s2)
    8000347a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000347c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003480:	85d2                	mv	a1,s4
    80003482:	01048513          	addi	a0,s1,16
    80003486:	00001097          	auipc	ra,0x1
    8000348a:	4c2080e7          	jalr	1218(ra) # 80004948 <initsleeplock>
    bcache.head.next->prev = b;
    8000348e:	2b893783          	ld	a5,696(s2)
    80003492:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003494:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003498:	45848493          	addi	s1,s1,1112
    8000349c:	fd349de3          	bne	s1,s3,80003476 <binit+0x54>
  }
}
    800034a0:	70a2                	ld	ra,40(sp)
    800034a2:	7402                	ld	s0,32(sp)
    800034a4:	64e2                	ld	s1,24(sp)
    800034a6:	6942                	ld	s2,16(sp)
    800034a8:	69a2                	ld	s3,8(sp)
    800034aa:	6a02                	ld	s4,0(sp)
    800034ac:	6145                	addi	sp,sp,48
    800034ae:	8082                	ret

00000000800034b0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800034b0:	7179                	addi	sp,sp,-48
    800034b2:	f406                	sd	ra,40(sp)
    800034b4:	f022                	sd	s0,32(sp)
    800034b6:	ec26                	sd	s1,24(sp)
    800034b8:	e84a                	sd	s2,16(sp)
    800034ba:	e44e                	sd	s3,8(sp)
    800034bc:	1800                	addi	s0,sp,48
    800034be:	892a                	mv	s2,a0
    800034c0:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800034c2:	00014517          	auipc	a0,0x14
    800034c6:	43e50513          	addi	a0,a0,1086 # 80017900 <bcache>
    800034ca:	ffffd097          	auipc	ra,0xffffd
    800034ce:	6f8080e7          	jalr	1784(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800034d2:	0001c497          	auipc	s1,0x1c
    800034d6:	6e64b483          	ld	s1,1766(s1) # 8001fbb8 <bcache+0x82b8>
    800034da:	0001c797          	auipc	a5,0x1c
    800034de:	68e78793          	addi	a5,a5,1678 # 8001fb68 <bcache+0x8268>
    800034e2:	02f48f63          	beq	s1,a5,80003520 <bread+0x70>
    800034e6:	873e                	mv	a4,a5
    800034e8:	a021                	j	800034f0 <bread+0x40>
    800034ea:	68a4                	ld	s1,80(s1)
    800034ec:	02e48a63          	beq	s1,a4,80003520 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800034f0:	449c                	lw	a5,8(s1)
    800034f2:	ff279ce3          	bne	a5,s2,800034ea <bread+0x3a>
    800034f6:	44dc                	lw	a5,12(s1)
    800034f8:	ff3799e3          	bne	a5,s3,800034ea <bread+0x3a>
      b->refcnt++;
    800034fc:	40bc                	lw	a5,64(s1)
    800034fe:	2785                	addiw	a5,a5,1
    80003500:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003502:	00014517          	auipc	a0,0x14
    80003506:	3fe50513          	addi	a0,a0,1022 # 80017900 <bcache>
    8000350a:	ffffd097          	auipc	ra,0xffffd
    8000350e:	76c080e7          	jalr	1900(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003512:	01048513          	addi	a0,s1,16
    80003516:	00001097          	auipc	ra,0x1
    8000351a:	46c080e7          	jalr	1132(ra) # 80004982 <acquiresleep>
      return b;
    8000351e:	a8b9                	j	8000357c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003520:	0001c497          	auipc	s1,0x1c
    80003524:	6904b483          	ld	s1,1680(s1) # 8001fbb0 <bcache+0x82b0>
    80003528:	0001c797          	auipc	a5,0x1c
    8000352c:	64078793          	addi	a5,a5,1600 # 8001fb68 <bcache+0x8268>
    80003530:	00f48863          	beq	s1,a5,80003540 <bread+0x90>
    80003534:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003536:	40bc                	lw	a5,64(s1)
    80003538:	cf81                	beqz	a5,80003550 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000353a:	64a4                	ld	s1,72(s1)
    8000353c:	fee49de3          	bne	s1,a4,80003536 <bread+0x86>
  panic("bget: no buffers");
    80003540:	00005517          	auipc	a0,0x5
    80003544:	20050513          	addi	a0,a0,512 # 80008740 <syscalls+0x110>
    80003548:	ffffd097          	auipc	ra,0xffffd
    8000354c:	fe2080e7          	jalr	-30(ra) # 8000052a <panic>
      b->dev = dev;
    80003550:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003554:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003558:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000355c:	4785                	li	a5,1
    8000355e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003560:	00014517          	auipc	a0,0x14
    80003564:	3a050513          	addi	a0,a0,928 # 80017900 <bcache>
    80003568:	ffffd097          	auipc	ra,0xffffd
    8000356c:	70e080e7          	jalr	1806(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003570:	01048513          	addi	a0,s1,16
    80003574:	00001097          	auipc	ra,0x1
    80003578:	40e080e7          	jalr	1038(ra) # 80004982 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000357c:	409c                	lw	a5,0(s1)
    8000357e:	cb89                	beqz	a5,80003590 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003580:	8526                	mv	a0,s1
    80003582:	70a2                	ld	ra,40(sp)
    80003584:	7402                	ld	s0,32(sp)
    80003586:	64e2                	ld	s1,24(sp)
    80003588:	6942                	ld	s2,16(sp)
    8000358a:	69a2                	ld	s3,8(sp)
    8000358c:	6145                	addi	sp,sp,48
    8000358e:	8082                	ret
    virtio_disk_rw(b, 0);
    80003590:	4581                	li	a1,0
    80003592:	8526                	mv	a0,s1
    80003594:	00003097          	auipc	ra,0x3
    80003598:	f22080e7          	jalr	-222(ra) # 800064b6 <virtio_disk_rw>
    b->valid = 1;
    8000359c:	4785                	li	a5,1
    8000359e:	c09c                	sw	a5,0(s1)
  return b;
    800035a0:	b7c5                	j	80003580 <bread+0xd0>

00000000800035a2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800035a2:	1101                	addi	sp,sp,-32
    800035a4:	ec06                	sd	ra,24(sp)
    800035a6:	e822                	sd	s0,16(sp)
    800035a8:	e426                	sd	s1,8(sp)
    800035aa:	1000                	addi	s0,sp,32
    800035ac:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035ae:	0541                	addi	a0,a0,16
    800035b0:	00001097          	auipc	ra,0x1
    800035b4:	46c080e7          	jalr	1132(ra) # 80004a1c <holdingsleep>
    800035b8:	cd01                	beqz	a0,800035d0 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800035ba:	4585                	li	a1,1
    800035bc:	8526                	mv	a0,s1
    800035be:	00003097          	auipc	ra,0x3
    800035c2:	ef8080e7          	jalr	-264(ra) # 800064b6 <virtio_disk_rw>
}
    800035c6:	60e2                	ld	ra,24(sp)
    800035c8:	6442                	ld	s0,16(sp)
    800035ca:	64a2                	ld	s1,8(sp)
    800035cc:	6105                	addi	sp,sp,32
    800035ce:	8082                	ret
    panic("bwrite");
    800035d0:	00005517          	auipc	a0,0x5
    800035d4:	18850513          	addi	a0,a0,392 # 80008758 <syscalls+0x128>
    800035d8:	ffffd097          	auipc	ra,0xffffd
    800035dc:	f52080e7          	jalr	-174(ra) # 8000052a <panic>

00000000800035e0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800035e0:	1101                	addi	sp,sp,-32
    800035e2:	ec06                	sd	ra,24(sp)
    800035e4:	e822                	sd	s0,16(sp)
    800035e6:	e426                	sd	s1,8(sp)
    800035e8:	e04a                	sd	s2,0(sp)
    800035ea:	1000                	addi	s0,sp,32
    800035ec:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035ee:	01050913          	addi	s2,a0,16
    800035f2:	854a                	mv	a0,s2
    800035f4:	00001097          	auipc	ra,0x1
    800035f8:	428080e7          	jalr	1064(ra) # 80004a1c <holdingsleep>
    800035fc:	c92d                	beqz	a0,8000366e <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800035fe:	854a                	mv	a0,s2
    80003600:	00001097          	auipc	ra,0x1
    80003604:	3d8080e7          	jalr	984(ra) # 800049d8 <releasesleep>

  acquire(&bcache.lock);
    80003608:	00014517          	auipc	a0,0x14
    8000360c:	2f850513          	addi	a0,a0,760 # 80017900 <bcache>
    80003610:	ffffd097          	auipc	ra,0xffffd
    80003614:	5b2080e7          	jalr	1458(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003618:	40bc                	lw	a5,64(s1)
    8000361a:	37fd                	addiw	a5,a5,-1
    8000361c:	0007871b          	sext.w	a4,a5
    80003620:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003622:	eb05                	bnez	a4,80003652 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003624:	68bc                	ld	a5,80(s1)
    80003626:	64b8                	ld	a4,72(s1)
    80003628:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000362a:	64bc                	ld	a5,72(s1)
    8000362c:	68b8                	ld	a4,80(s1)
    8000362e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003630:	0001c797          	auipc	a5,0x1c
    80003634:	2d078793          	addi	a5,a5,720 # 8001f900 <bcache+0x8000>
    80003638:	2b87b703          	ld	a4,696(a5)
    8000363c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000363e:	0001c717          	auipc	a4,0x1c
    80003642:	52a70713          	addi	a4,a4,1322 # 8001fb68 <bcache+0x8268>
    80003646:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003648:	2b87b703          	ld	a4,696(a5)
    8000364c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000364e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003652:	00014517          	auipc	a0,0x14
    80003656:	2ae50513          	addi	a0,a0,686 # 80017900 <bcache>
    8000365a:	ffffd097          	auipc	ra,0xffffd
    8000365e:	61c080e7          	jalr	1564(ra) # 80000c76 <release>
}
    80003662:	60e2                	ld	ra,24(sp)
    80003664:	6442                	ld	s0,16(sp)
    80003666:	64a2                	ld	s1,8(sp)
    80003668:	6902                	ld	s2,0(sp)
    8000366a:	6105                	addi	sp,sp,32
    8000366c:	8082                	ret
    panic("brelse");
    8000366e:	00005517          	auipc	a0,0x5
    80003672:	0f250513          	addi	a0,a0,242 # 80008760 <syscalls+0x130>
    80003676:	ffffd097          	auipc	ra,0xffffd
    8000367a:	eb4080e7          	jalr	-332(ra) # 8000052a <panic>

000000008000367e <bpin>:

void
bpin(struct buf *b) {
    8000367e:	1101                	addi	sp,sp,-32
    80003680:	ec06                	sd	ra,24(sp)
    80003682:	e822                	sd	s0,16(sp)
    80003684:	e426                	sd	s1,8(sp)
    80003686:	1000                	addi	s0,sp,32
    80003688:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000368a:	00014517          	auipc	a0,0x14
    8000368e:	27650513          	addi	a0,a0,630 # 80017900 <bcache>
    80003692:	ffffd097          	auipc	ra,0xffffd
    80003696:	530080e7          	jalr	1328(ra) # 80000bc2 <acquire>
  b->refcnt++;
    8000369a:	40bc                	lw	a5,64(s1)
    8000369c:	2785                	addiw	a5,a5,1
    8000369e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036a0:	00014517          	auipc	a0,0x14
    800036a4:	26050513          	addi	a0,a0,608 # 80017900 <bcache>
    800036a8:	ffffd097          	auipc	ra,0xffffd
    800036ac:	5ce080e7          	jalr	1486(ra) # 80000c76 <release>
}
    800036b0:	60e2                	ld	ra,24(sp)
    800036b2:	6442                	ld	s0,16(sp)
    800036b4:	64a2                	ld	s1,8(sp)
    800036b6:	6105                	addi	sp,sp,32
    800036b8:	8082                	ret

00000000800036ba <bunpin>:

void
bunpin(struct buf *b) {
    800036ba:	1101                	addi	sp,sp,-32
    800036bc:	ec06                	sd	ra,24(sp)
    800036be:	e822                	sd	s0,16(sp)
    800036c0:	e426                	sd	s1,8(sp)
    800036c2:	1000                	addi	s0,sp,32
    800036c4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036c6:	00014517          	auipc	a0,0x14
    800036ca:	23a50513          	addi	a0,a0,570 # 80017900 <bcache>
    800036ce:	ffffd097          	auipc	ra,0xffffd
    800036d2:	4f4080e7          	jalr	1268(ra) # 80000bc2 <acquire>
  b->refcnt--;
    800036d6:	40bc                	lw	a5,64(s1)
    800036d8:	37fd                	addiw	a5,a5,-1
    800036da:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036dc:	00014517          	auipc	a0,0x14
    800036e0:	22450513          	addi	a0,a0,548 # 80017900 <bcache>
    800036e4:	ffffd097          	auipc	ra,0xffffd
    800036e8:	592080e7          	jalr	1426(ra) # 80000c76 <release>
}
    800036ec:	60e2                	ld	ra,24(sp)
    800036ee:	6442                	ld	s0,16(sp)
    800036f0:	64a2                	ld	s1,8(sp)
    800036f2:	6105                	addi	sp,sp,32
    800036f4:	8082                	ret

00000000800036f6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800036f6:	1101                	addi	sp,sp,-32
    800036f8:	ec06                	sd	ra,24(sp)
    800036fa:	e822                	sd	s0,16(sp)
    800036fc:	e426                	sd	s1,8(sp)
    800036fe:	e04a                	sd	s2,0(sp)
    80003700:	1000                	addi	s0,sp,32
    80003702:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003704:	00d5d59b          	srliw	a1,a1,0xd
    80003708:	0001d797          	auipc	a5,0x1d
    8000370c:	8d47a783          	lw	a5,-1836(a5) # 8001ffdc <sb+0x1c>
    80003710:	9dbd                	addw	a1,a1,a5
    80003712:	00000097          	auipc	ra,0x0
    80003716:	d9e080e7          	jalr	-610(ra) # 800034b0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000371a:	0074f713          	andi	a4,s1,7
    8000371e:	4785                	li	a5,1
    80003720:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003724:	14ce                	slli	s1,s1,0x33
    80003726:	90d9                	srli	s1,s1,0x36
    80003728:	00950733          	add	a4,a0,s1
    8000372c:	05874703          	lbu	a4,88(a4)
    80003730:	00e7f6b3          	and	a3,a5,a4
    80003734:	c69d                	beqz	a3,80003762 <bfree+0x6c>
    80003736:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003738:	94aa                	add	s1,s1,a0
    8000373a:	fff7c793          	not	a5,a5
    8000373e:	8ff9                	and	a5,a5,a4
    80003740:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003744:	00001097          	auipc	ra,0x1
    80003748:	11e080e7          	jalr	286(ra) # 80004862 <log_write>
  brelse(bp);
    8000374c:	854a                	mv	a0,s2
    8000374e:	00000097          	auipc	ra,0x0
    80003752:	e92080e7          	jalr	-366(ra) # 800035e0 <brelse>
}
    80003756:	60e2                	ld	ra,24(sp)
    80003758:	6442                	ld	s0,16(sp)
    8000375a:	64a2                	ld	s1,8(sp)
    8000375c:	6902                	ld	s2,0(sp)
    8000375e:	6105                	addi	sp,sp,32
    80003760:	8082                	ret
    panic("freeing free block");
    80003762:	00005517          	auipc	a0,0x5
    80003766:	00650513          	addi	a0,a0,6 # 80008768 <syscalls+0x138>
    8000376a:	ffffd097          	auipc	ra,0xffffd
    8000376e:	dc0080e7          	jalr	-576(ra) # 8000052a <panic>

0000000080003772 <balloc>:
{
    80003772:	711d                	addi	sp,sp,-96
    80003774:	ec86                	sd	ra,88(sp)
    80003776:	e8a2                	sd	s0,80(sp)
    80003778:	e4a6                	sd	s1,72(sp)
    8000377a:	e0ca                	sd	s2,64(sp)
    8000377c:	fc4e                	sd	s3,56(sp)
    8000377e:	f852                	sd	s4,48(sp)
    80003780:	f456                	sd	s5,40(sp)
    80003782:	f05a                	sd	s6,32(sp)
    80003784:	ec5e                	sd	s7,24(sp)
    80003786:	e862                	sd	s8,16(sp)
    80003788:	e466                	sd	s9,8(sp)
    8000378a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000378c:	0001d797          	auipc	a5,0x1d
    80003790:	8387a783          	lw	a5,-1992(a5) # 8001ffc4 <sb+0x4>
    80003794:	cbd1                	beqz	a5,80003828 <balloc+0xb6>
    80003796:	8baa                	mv	s7,a0
    80003798:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000379a:	0001db17          	auipc	s6,0x1d
    8000379e:	826b0b13          	addi	s6,s6,-2010 # 8001ffc0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037a2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800037a4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037a6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800037a8:	6c89                	lui	s9,0x2
    800037aa:	a831                	j	800037c6 <balloc+0x54>
    brelse(bp);
    800037ac:	854a                	mv	a0,s2
    800037ae:	00000097          	auipc	ra,0x0
    800037b2:	e32080e7          	jalr	-462(ra) # 800035e0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800037b6:	015c87bb          	addw	a5,s9,s5
    800037ba:	00078a9b          	sext.w	s5,a5
    800037be:	004b2703          	lw	a4,4(s6)
    800037c2:	06eaf363          	bgeu	s5,a4,80003828 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800037c6:	41fad79b          	sraiw	a5,s5,0x1f
    800037ca:	0137d79b          	srliw	a5,a5,0x13
    800037ce:	015787bb          	addw	a5,a5,s5
    800037d2:	40d7d79b          	sraiw	a5,a5,0xd
    800037d6:	01cb2583          	lw	a1,28(s6)
    800037da:	9dbd                	addw	a1,a1,a5
    800037dc:	855e                	mv	a0,s7
    800037de:	00000097          	auipc	ra,0x0
    800037e2:	cd2080e7          	jalr	-814(ra) # 800034b0 <bread>
    800037e6:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037e8:	004b2503          	lw	a0,4(s6)
    800037ec:	000a849b          	sext.w	s1,s5
    800037f0:	8662                	mv	a2,s8
    800037f2:	faa4fde3          	bgeu	s1,a0,800037ac <balloc+0x3a>
      m = 1 << (bi % 8);
    800037f6:	41f6579b          	sraiw	a5,a2,0x1f
    800037fa:	01d7d69b          	srliw	a3,a5,0x1d
    800037fe:	00c6873b          	addw	a4,a3,a2
    80003802:	00777793          	andi	a5,a4,7
    80003806:	9f95                	subw	a5,a5,a3
    80003808:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000380c:	4037571b          	sraiw	a4,a4,0x3
    80003810:	00e906b3          	add	a3,s2,a4
    80003814:	0586c683          	lbu	a3,88(a3)
    80003818:	00d7f5b3          	and	a1,a5,a3
    8000381c:	cd91                	beqz	a1,80003838 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000381e:	2605                	addiw	a2,a2,1
    80003820:	2485                	addiw	s1,s1,1
    80003822:	fd4618e3          	bne	a2,s4,800037f2 <balloc+0x80>
    80003826:	b759                	j	800037ac <balloc+0x3a>
  panic("balloc: out of blocks");
    80003828:	00005517          	auipc	a0,0x5
    8000382c:	f5850513          	addi	a0,a0,-168 # 80008780 <syscalls+0x150>
    80003830:	ffffd097          	auipc	ra,0xffffd
    80003834:	cfa080e7          	jalr	-774(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003838:	974a                	add	a4,a4,s2
    8000383a:	8fd5                	or	a5,a5,a3
    8000383c:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003840:	854a                	mv	a0,s2
    80003842:	00001097          	auipc	ra,0x1
    80003846:	020080e7          	jalr	32(ra) # 80004862 <log_write>
        brelse(bp);
    8000384a:	854a                	mv	a0,s2
    8000384c:	00000097          	auipc	ra,0x0
    80003850:	d94080e7          	jalr	-620(ra) # 800035e0 <brelse>
  bp = bread(dev, bno);
    80003854:	85a6                	mv	a1,s1
    80003856:	855e                	mv	a0,s7
    80003858:	00000097          	auipc	ra,0x0
    8000385c:	c58080e7          	jalr	-936(ra) # 800034b0 <bread>
    80003860:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003862:	40000613          	li	a2,1024
    80003866:	4581                	li	a1,0
    80003868:	05850513          	addi	a0,a0,88
    8000386c:	ffffd097          	auipc	ra,0xffffd
    80003870:	452080e7          	jalr	1106(ra) # 80000cbe <memset>
  log_write(bp);
    80003874:	854a                	mv	a0,s2
    80003876:	00001097          	auipc	ra,0x1
    8000387a:	fec080e7          	jalr	-20(ra) # 80004862 <log_write>
  brelse(bp);
    8000387e:	854a                	mv	a0,s2
    80003880:	00000097          	auipc	ra,0x0
    80003884:	d60080e7          	jalr	-672(ra) # 800035e0 <brelse>
}
    80003888:	8526                	mv	a0,s1
    8000388a:	60e6                	ld	ra,88(sp)
    8000388c:	6446                	ld	s0,80(sp)
    8000388e:	64a6                	ld	s1,72(sp)
    80003890:	6906                	ld	s2,64(sp)
    80003892:	79e2                	ld	s3,56(sp)
    80003894:	7a42                	ld	s4,48(sp)
    80003896:	7aa2                	ld	s5,40(sp)
    80003898:	7b02                	ld	s6,32(sp)
    8000389a:	6be2                	ld	s7,24(sp)
    8000389c:	6c42                	ld	s8,16(sp)
    8000389e:	6ca2                	ld	s9,8(sp)
    800038a0:	6125                	addi	sp,sp,96
    800038a2:	8082                	ret

00000000800038a4 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800038a4:	7179                	addi	sp,sp,-48
    800038a6:	f406                	sd	ra,40(sp)
    800038a8:	f022                	sd	s0,32(sp)
    800038aa:	ec26                	sd	s1,24(sp)
    800038ac:	e84a                	sd	s2,16(sp)
    800038ae:	e44e                	sd	s3,8(sp)
    800038b0:	e052                	sd	s4,0(sp)
    800038b2:	1800                	addi	s0,sp,48
    800038b4:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800038b6:	47ad                	li	a5,11
    800038b8:	04b7fe63          	bgeu	a5,a1,80003914 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800038bc:	ff45849b          	addiw	s1,a1,-12
    800038c0:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800038c4:	0ff00793          	li	a5,255
    800038c8:	0ae7e463          	bltu	a5,a4,80003970 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800038cc:	08052583          	lw	a1,128(a0)
    800038d0:	c5b5                	beqz	a1,8000393c <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800038d2:	00092503          	lw	a0,0(s2)
    800038d6:	00000097          	auipc	ra,0x0
    800038da:	bda080e7          	jalr	-1062(ra) # 800034b0 <bread>
    800038de:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800038e0:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800038e4:	02049713          	slli	a4,s1,0x20
    800038e8:	01e75593          	srli	a1,a4,0x1e
    800038ec:	00b784b3          	add	s1,a5,a1
    800038f0:	0004a983          	lw	s3,0(s1)
    800038f4:	04098e63          	beqz	s3,80003950 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800038f8:	8552                	mv	a0,s4
    800038fa:	00000097          	auipc	ra,0x0
    800038fe:	ce6080e7          	jalr	-794(ra) # 800035e0 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003902:	854e                	mv	a0,s3
    80003904:	70a2                	ld	ra,40(sp)
    80003906:	7402                	ld	s0,32(sp)
    80003908:	64e2                	ld	s1,24(sp)
    8000390a:	6942                	ld	s2,16(sp)
    8000390c:	69a2                	ld	s3,8(sp)
    8000390e:	6a02                	ld	s4,0(sp)
    80003910:	6145                	addi	sp,sp,48
    80003912:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003914:	02059793          	slli	a5,a1,0x20
    80003918:	01e7d593          	srli	a1,a5,0x1e
    8000391c:	00b504b3          	add	s1,a0,a1
    80003920:	0504a983          	lw	s3,80(s1)
    80003924:	fc099fe3          	bnez	s3,80003902 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003928:	4108                	lw	a0,0(a0)
    8000392a:	00000097          	auipc	ra,0x0
    8000392e:	e48080e7          	jalr	-440(ra) # 80003772 <balloc>
    80003932:	0005099b          	sext.w	s3,a0
    80003936:	0534a823          	sw	s3,80(s1)
    8000393a:	b7e1                	j	80003902 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000393c:	4108                	lw	a0,0(a0)
    8000393e:	00000097          	auipc	ra,0x0
    80003942:	e34080e7          	jalr	-460(ra) # 80003772 <balloc>
    80003946:	0005059b          	sext.w	a1,a0
    8000394a:	08b92023          	sw	a1,128(s2)
    8000394e:	b751                	j	800038d2 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003950:	00092503          	lw	a0,0(s2)
    80003954:	00000097          	auipc	ra,0x0
    80003958:	e1e080e7          	jalr	-482(ra) # 80003772 <balloc>
    8000395c:	0005099b          	sext.w	s3,a0
    80003960:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003964:	8552                	mv	a0,s4
    80003966:	00001097          	auipc	ra,0x1
    8000396a:	efc080e7          	jalr	-260(ra) # 80004862 <log_write>
    8000396e:	b769                	j	800038f8 <bmap+0x54>
  panic("bmap: out of range");
    80003970:	00005517          	auipc	a0,0x5
    80003974:	e2850513          	addi	a0,a0,-472 # 80008798 <syscalls+0x168>
    80003978:	ffffd097          	auipc	ra,0xffffd
    8000397c:	bb2080e7          	jalr	-1102(ra) # 8000052a <panic>

0000000080003980 <iget>:
{
    80003980:	7179                	addi	sp,sp,-48
    80003982:	f406                	sd	ra,40(sp)
    80003984:	f022                	sd	s0,32(sp)
    80003986:	ec26                	sd	s1,24(sp)
    80003988:	e84a                	sd	s2,16(sp)
    8000398a:	e44e                	sd	s3,8(sp)
    8000398c:	e052                	sd	s4,0(sp)
    8000398e:	1800                	addi	s0,sp,48
    80003990:	89aa                	mv	s3,a0
    80003992:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003994:	0001c517          	auipc	a0,0x1c
    80003998:	64c50513          	addi	a0,a0,1612 # 8001ffe0 <itable>
    8000399c:	ffffd097          	auipc	ra,0xffffd
    800039a0:	226080e7          	jalr	550(ra) # 80000bc2 <acquire>
  empty = 0;
    800039a4:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800039a6:	0001c497          	auipc	s1,0x1c
    800039aa:	65248493          	addi	s1,s1,1618 # 8001fff8 <itable+0x18>
    800039ae:	0001e697          	auipc	a3,0x1e
    800039b2:	0da68693          	addi	a3,a3,218 # 80021a88 <log>
    800039b6:	a039                	j	800039c4 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800039b8:	02090b63          	beqz	s2,800039ee <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800039bc:	08848493          	addi	s1,s1,136
    800039c0:	02d48a63          	beq	s1,a3,800039f4 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800039c4:	449c                	lw	a5,8(s1)
    800039c6:	fef059e3          	blez	a5,800039b8 <iget+0x38>
    800039ca:	4098                	lw	a4,0(s1)
    800039cc:	ff3716e3          	bne	a4,s3,800039b8 <iget+0x38>
    800039d0:	40d8                	lw	a4,4(s1)
    800039d2:	ff4713e3          	bne	a4,s4,800039b8 <iget+0x38>
      ip->ref++;
    800039d6:	2785                	addiw	a5,a5,1
    800039d8:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800039da:	0001c517          	auipc	a0,0x1c
    800039de:	60650513          	addi	a0,a0,1542 # 8001ffe0 <itable>
    800039e2:	ffffd097          	auipc	ra,0xffffd
    800039e6:	294080e7          	jalr	660(ra) # 80000c76 <release>
      return ip;
    800039ea:	8926                	mv	s2,s1
    800039ec:	a03d                	j	80003a1a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800039ee:	f7f9                	bnez	a5,800039bc <iget+0x3c>
    800039f0:	8926                	mv	s2,s1
    800039f2:	b7e9                	j	800039bc <iget+0x3c>
  if(empty == 0)
    800039f4:	02090c63          	beqz	s2,80003a2c <iget+0xac>
  ip->dev = dev;
    800039f8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800039fc:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003a00:	4785                	li	a5,1
    80003a02:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003a06:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003a0a:	0001c517          	auipc	a0,0x1c
    80003a0e:	5d650513          	addi	a0,a0,1494 # 8001ffe0 <itable>
    80003a12:	ffffd097          	auipc	ra,0xffffd
    80003a16:	264080e7          	jalr	612(ra) # 80000c76 <release>
}
    80003a1a:	854a                	mv	a0,s2
    80003a1c:	70a2                	ld	ra,40(sp)
    80003a1e:	7402                	ld	s0,32(sp)
    80003a20:	64e2                	ld	s1,24(sp)
    80003a22:	6942                	ld	s2,16(sp)
    80003a24:	69a2                	ld	s3,8(sp)
    80003a26:	6a02                	ld	s4,0(sp)
    80003a28:	6145                	addi	sp,sp,48
    80003a2a:	8082                	ret
    panic("iget: no inodes");
    80003a2c:	00005517          	auipc	a0,0x5
    80003a30:	d8450513          	addi	a0,a0,-636 # 800087b0 <syscalls+0x180>
    80003a34:	ffffd097          	auipc	ra,0xffffd
    80003a38:	af6080e7          	jalr	-1290(ra) # 8000052a <panic>

0000000080003a3c <fsinit>:
fsinit(int dev) {
    80003a3c:	7179                	addi	sp,sp,-48
    80003a3e:	f406                	sd	ra,40(sp)
    80003a40:	f022                	sd	s0,32(sp)
    80003a42:	ec26                	sd	s1,24(sp)
    80003a44:	e84a                	sd	s2,16(sp)
    80003a46:	e44e                	sd	s3,8(sp)
    80003a48:	1800                	addi	s0,sp,48
    80003a4a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a4c:	4585                	li	a1,1
    80003a4e:	00000097          	auipc	ra,0x0
    80003a52:	a62080e7          	jalr	-1438(ra) # 800034b0 <bread>
    80003a56:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003a58:	0001c997          	auipc	s3,0x1c
    80003a5c:	56898993          	addi	s3,s3,1384 # 8001ffc0 <sb>
    80003a60:	02000613          	li	a2,32
    80003a64:	05850593          	addi	a1,a0,88
    80003a68:	854e                	mv	a0,s3
    80003a6a:	ffffd097          	auipc	ra,0xffffd
    80003a6e:	2b0080e7          	jalr	688(ra) # 80000d1a <memmove>
  brelse(bp);
    80003a72:	8526                	mv	a0,s1
    80003a74:	00000097          	auipc	ra,0x0
    80003a78:	b6c080e7          	jalr	-1172(ra) # 800035e0 <brelse>
  if(sb.magic != FSMAGIC)
    80003a7c:	0009a703          	lw	a4,0(s3)
    80003a80:	102037b7          	lui	a5,0x10203
    80003a84:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003a88:	02f71263          	bne	a4,a5,80003aac <fsinit+0x70>
  initlog(dev, &sb);
    80003a8c:	0001c597          	auipc	a1,0x1c
    80003a90:	53458593          	addi	a1,a1,1332 # 8001ffc0 <sb>
    80003a94:	854a                	mv	a0,s2
    80003a96:	00001097          	auipc	ra,0x1
    80003a9a:	b4e080e7          	jalr	-1202(ra) # 800045e4 <initlog>
}
    80003a9e:	70a2                	ld	ra,40(sp)
    80003aa0:	7402                	ld	s0,32(sp)
    80003aa2:	64e2                	ld	s1,24(sp)
    80003aa4:	6942                	ld	s2,16(sp)
    80003aa6:	69a2                	ld	s3,8(sp)
    80003aa8:	6145                	addi	sp,sp,48
    80003aaa:	8082                	ret
    panic("invalid file system");
    80003aac:	00005517          	auipc	a0,0x5
    80003ab0:	d1450513          	addi	a0,a0,-748 # 800087c0 <syscalls+0x190>
    80003ab4:	ffffd097          	auipc	ra,0xffffd
    80003ab8:	a76080e7          	jalr	-1418(ra) # 8000052a <panic>

0000000080003abc <iinit>:
{
    80003abc:	7179                	addi	sp,sp,-48
    80003abe:	f406                	sd	ra,40(sp)
    80003ac0:	f022                	sd	s0,32(sp)
    80003ac2:	ec26                	sd	s1,24(sp)
    80003ac4:	e84a                	sd	s2,16(sp)
    80003ac6:	e44e                	sd	s3,8(sp)
    80003ac8:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003aca:	00005597          	auipc	a1,0x5
    80003ace:	d0e58593          	addi	a1,a1,-754 # 800087d8 <syscalls+0x1a8>
    80003ad2:	0001c517          	auipc	a0,0x1c
    80003ad6:	50e50513          	addi	a0,a0,1294 # 8001ffe0 <itable>
    80003ada:	ffffd097          	auipc	ra,0xffffd
    80003ade:	058080e7          	jalr	88(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003ae2:	0001c497          	auipc	s1,0x1c
    80003ae6:	52648493          	addi	s1,s1,1318 # 80020008 <itable+0x28>
    80003aea:	0001e997          	auipc	s3,0x1e
    80003aee:	fae98993          	addi	s3,s3,-82 # 80021a98 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003af2:	00005917          	auipc	s2,0x5
    80003af6:	cee90913          	addi	s2,s2,-786 # 800087e0 <syscalls+0x1b0>
    80003afa:	85ca                	mv	a1,s2
    80003afc:	8526                	mv	a0,s1
    80003afe:	00001097          	auipc	ra,0x1
    80003b02:	e4a080e7          	jalr	-438(ra) # 80004948 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003b06:	08848493          	addi	s1,s1,136
    80003b0a:	ff3498e3          	bne	s1,s3,80003afa <iinit+0x3e>
}
    80003b0e:	70a2                	ld	ra,40(sp)
    80003b10:	7402                	ld	s0,32(sp)
    80003b12:	64e2                	ld	s1,24(sp)
    80003b14:	6942                	ld	s2,16(sp)
    80003b16:	69a2                	ld	s3,8(sp)
    80003b18:	6145                	addi	sp,sp,48
    80003b1a:	8082                	ret

0000000080003b1c <ialloc>:
{
    80003b1c:	715d                	addi	sp,sp,-80
    80003b1e:	e486                	sd	ra,72(sp)
    80003b20:	e0a2                	sd	s0,64(sp)
    80003b22:	fc26                	sd	s1,56(sp)
    80003b24:	f84a                	sd	s2,48(sp)
    80003b26:	f44e                	sd	s3,40(sp)
    80003b28:	f052                	sd	s4,32(sp)
    80003b2a:	ec56                	sd	s5,24(sp)
    80003b2c:	e85a                	sd	s6,16(sp)
    80003b2e:	e45e                	sd	s7,8(sp)
    80003b30:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b32:	0001c717          	auipc	a4,0x1c
    80003b36:	49a72703          	lw	a4,1178(a4) # 8001ffcc <sb+0xc>
    80003b3a:	4785                	li	a5,1
    80003b3c:	04e7fa63          	bgeu	a5,a4,80003b90 <ialloc+0x74>
    80003b40:	8aaa                	mv	s5,a0
    80003b42:	8bae                	mv	s7,a1
    80003b44:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003b46:	0001ca17          	auipc	s4,0x1c
    80003b4a:	47aa0a13          	addi	s4,s4,1146 # 8001ffc0 <sb>
    80003b4e:	00048b1b          	sext.w	s6,s1
    80003b52:	0044d793          	srli	a5,s1,0x4
    80003b56:	018a2583          	lw	a1,24(s4)
    80003b5a:	9dbd                	addw	a1,a1,a5
    80003b5c:	8556                	mv	a0,s5
    80003b5e:	00000097          	auipc	ra,0x0
    80003b62:	952080e7          	jalr	-1710(ra) # 800034b0 <bread>
    80003b66:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003b68:	05850993          	addi	s3,a0,88
    80003b6c:	00f4f793          	andi	a5,s1,15
    80003b70:	079a                	slli	a5,a5,0x6
    80003b72:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003b74:	00099783          	lh	a5,0(s3)
    80003b78:	c785                	beqz	a5,80003ba0 <ialloc+0x84>
    brelse(bp);
    80003b7a:	00000097          	auipc	ra,0x0
    80003b7e:	a66080e7          	jalr	-1434(ra) # 800035e0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b82:	0485                	addi	s1,s1,1
    80003b84:	00ca2703          	lw	a4,12(s4)
    80003b88:	0004879b          	sext.w	a5,s1
    80003b8c:	fce7e1e3          	bltu	a5,a4,80003b4e <ialloc+0x32>
  panic("ialloc: no inodes");
    80003b90:	00005517          	auipc	a0,0x5
    80003b94:	c5850513          	addi	a0,a0,-936 # 800087e8 <syscalls+0x1b8>
    80003b98:	ffffd097          	auipc	ra,0xffffd
    80003b9c:	992080e7          	jalr	-1646(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    80003ba0:	04000613          	li	a2,64
    80003ba4:	4581                	li	a1,0
    80003ba6:	854e                	mv	a0,s3
    80003ba8:	ffffd097          	auipc	ra,0xffffd
    80003bac:	116080e7          	jalr	278(ra) # 80000cbe <memset>
      dip->type = type;
    80003bb0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003bb4:	854a                	mv	a0,s2
    80003bb6:	00001097          	auipc	ra,0x1
    80003bba:	cac080e7          	jalr	-852(ra) # 80004862 <log_write>
      brelse(bp);
    80003bbe:	854a                	mv	a0,s2
    80003bc0:	00000097          	auipc	ra,0x0
    80003bc4:	a20080e7          	jalr	-1504(ra) # 800035e0 <brelse>
      return iget(dev, inum);
    80003bc8:	85da                	mv	a1,s6
    80003bca:	8556                	mv	a0,s5
    80003bcc:	00000097          	auipc	ra,0x0
    80003bd0:	db4080e7          	jalr	-588(ra) # 80003980 <iget>
}
    80003bd4:	60a6                	ld	ra,72(sp)
    80003bd6:	6406                	ld	s0,64(sp)
    80003bd8:	74e2                	ld	s1,56(sp)
    80003bda:	7942                	ld	s2,48(sp)
    80003bdc:	79a2                	ld	s3,40(sp)
    80003bde:	7a02                	ld	s4,32(sp)
    80003be0:	6ae2                	ld	s5,24(sp)
    80003be2:	6b42                	ld	s6,16(sp)
    80003be4:	6ba2                	ld	s7,8(sp)
    80003be6:	6161                	addi	sp,sp,80
    80003be8:	8082                	ret

0000000080003bea <iupdate>:
{
    80003bea:	1101                	addi	sp,sp,-32
    80003bec:	ec06                	sd	ra,24(sp)
    80003bee:	e822                	sd	s0,16(sp)
    80003bf0:	e426                	sd	s1,8(sp)
    80003bf2:	e04a                	sd	s2,0(sp)
    80003bf4:	1000                	addi	s0,sp,32
    80003bf6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003bf8:	415c                	lw	a5,4(a0)
    80003bfa:	0047d79b          	srliw	a5,a5,0x4
    80003bfe:	0001c597          	auipc	a1,0x1c
    80003c02:	3da5a583          	lw	a1,986(a1) # 8001ffd8 <sb+0x18>
    80003c06:	9dbd                	addw	a1,a1,a5
    80003c08:	4108                	lw	a0,0(a0)
    80003c0a:	00000097          	auipc	ra,0x0
    80003c0e:	8a6080e7          	jalr	-1882(ra) # 800034b0 <bread>
    80003c12:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c14:	05850793          	addi	a5,a0,88
    80003c18:	40c8                	lw	a0,4(s1)
    80003c1a:	893d                	andi	a0,a0,15
    80003c1c:	051a                	slli	a0,a0,0x6
    80003c1e:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003c20:	04449703          	lh	a4,68(s1)
    80003c24:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003c28:	04649703          	lh	a4,70(s1)
    80003c2c:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003c30:	04849703          	lh	a4,72(s1)
    80003c34:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003c38:	04a49703          	lh	a4,74(s1)
    80003c3c:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003c40:	44f8                	lw	a4,76(s1)
    80003c42:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003c44:	03400613          	li	a2,52
    80003c48:	05048593          	addi	a1,s1,80
    80003c4c:	0531                	addi	a0,a0,12
    80003c4e:	ffffd097          	auipc	ra,0xffffd
    80003c52:	0cc080e7          	jalr	204(ra) # 80000d1a <memmove>
  log_write(bp);
    80003c56:	854a                	mv	a0,s2
    80003c58:	00001097          	auipc	ra,0x1
    80003c5c:	c0a080e7          	jalr	-1014(ra) # 80004862 <log_write>
  brelse(bp);
    80003c60:	854a                	mv	a0,s2
    80003c62:	00000097          	auipc	ra,0x0
    80003c66:	97e080e7          	jalr	-1666(ra) # 800035e0 <brelse>
}
    80003c6a:	60e2                	ld	ra,24(sp)
    80003c6c:	6442                	ld	s0,16(sp)
    80003c6e:	64a2                	ld	s1,8(sp)
    80003c70:	6902                	ld	s2,0(sp)
    80003c72:	6105                	addi	sp,sp,32
    80003c74:	8082                	ret

0000000080003c76 <idup>:
{
    80003c76:	1101                	addi	sp,sp,-32
    80003c78:	ec06                	sd	ra,24(sp)
    80003c7a:	e822                	sd	s0,16(sp)
    80003c7c:	e426                	sd	s1,8(sp)
    80003c7e:	1000                	addi	s0,sp,32
    80003c80:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c82:	0001c517          	auipc	a0,0x1c
    80003c86:	35e50513          	addi	a0,a0,862 # 8001ffe0 <itable>
    80003c8a:	ffffd097          	auipc	ra,0xffffd
    80003c8e:	f38080e7          	jalr	-200(ra) # 80000bc2 <acquire>
  ip->ref++;
    80003c92:	449c                	lw	a5,8(s1)
    80003c94:	2785                	addiw	a5,a5,1
    80003c96:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c98:	0001c517          	auipc	a0,0x1c
    80003c9c:	34850513          	addi	a0,a0,840 # 8001ffe0 <itable>
    80003ca0:	ffffd097          	auipc	ra,0xffffd
    80003ca4:	fd6080e7          	jalr	-42(ra) # 80000c76 <release>
}
    80003ca8:	8526                	mv	a0,s1
    80003caa:	60e2                	ld	ra,24(sp)
    80003cac:	6442                	ld	s0,16(sp)
    80003cae:	64a2                	ld	s1,8(sp)
    80003cb0:	6105                	addi	sp,sp,32
    80003cb2:	8082                	ret

0000000080003cb4 <ilock>:
{
    80003cb4:	1101                	addi	sp,sp,-32
    80003cb6:	ec06                	sd	ra,24(sp)
    80003cb8:	e822                	sd	s0,16(sp)
    80003cba:	e426                	sd	s1,8(sp)
    80003cbc:	e04a                	sd	s2,0(sp)
    80003cbe:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003cc0:	c115                	beqz	a0,80003ce4 <ilock+0x30>
    80003cc2:	84aa                	mv	s1,a0
    80003cc4:	451c                	lw	a5,8(a0)
    80003cc6:	00f05f63          	blez	a5,80003ce4 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003cca:	0541                	addi	a0,a0,16
    80003ccc:	00001097          	auipc	ra,0x1
    80003cd0:	cb6080e7          	jalr	-842(ra) # 80004982 <acquiresleep>
  if(ip->valid == 0){
    80003cd4:	40bc                	lw	a5,64(s1)
    80003cd6:	cf99                	beqz	a5,80003cf4 <ilock+0x40>
}
    80003cd8:	60e2                	ld	ra,24(sp)
    80003cda:	6442                	ld	s0,16(sp)
    80003cdc:	64a2                	ld	s1,8(sp)
    80003cde:	6902                	ld	s2,0(sp)
    80003ce0:	6105                	addi	sp,sp,32
    80003ce2:	8082                	ret
    panic("ilock");
    80003ce4:	00005517          	auipc	a0,0x5
    80003ce8:	b1c50513          	addi	a0,a0,-1252 # 80008800 <syscalls+0x1d0>
    80003cec:	ffffd097          	auipc	ra,0xffffd
    80003cf0:	83e080e7          	jalr	-1986(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003cf4:	40dc                	lw	a5,4(s1)
    80003cf6:	0047d79b          	srliw	a5,a5,0x4
    80003cfa:	0001c597          	auipc	a1,0x1c
    80003cfe:	2de5a583          	lw	a1,734(a1) # 8001ffd8 <sb+0x18>
    80003d02:	9dbd                	addw	a1,a1,a5
    80003d04:	4088                	lw	a0,0(s1)
    80003d06:	fffff097          	auipc	ra,0xfffff
    80003d0a:	7aa080e7          	jalr	1962(ra) # 800034b0 <bread>
    80003d0e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d10:	05850593          	addi	a1,a0,88
    80003d14:	40dc                	lw	a5,4(s1)
    80003d16:	8bbd                	andi	a5,a5,15
    80003d18:	079a                	slli	a5,a5,0x6
    80003d1a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003d1c:	00059783          	lh	a5,0(a1)
    80003d20:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003d24:	00259783          	lh	a5,2(a1)
    80003d28:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003d2c:	00459783          	lh	a5,4(a1)
    80003d30:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003d34:	00659783          	lh	a5,6(a1)
    80003d38:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003d3c:	459c                	lw	a5,8(a1)
    80003d3e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003d40:	03400613          	li	a2,52
    80003d44:	05b1                	addi	a1,a1,12
    80003d46:	05048513          	addi	a0,s1,80
    80003d4a:	ffffd097          	auipc	ra,0xffffd
    80003d4e:	fd0080e7          	jalr	-48(ra) # 80000d1a <memmove>
    brelse(bp);
    80003d52:	854a                	mv	a0,s2
    80003d54:	00000097          	auipc	ra,0x0
    80003d58:	88c080e7          	jalr	-1908(ra) # 800035e0 <brelse>
    ip->valid = 1;
    80003d5c:	4785                	li	a5,1
    80003d5e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003d60:	04449783          	lh	a5,68(s1)
    80003d64:	fbb5                	bnez	a5,80003cd8 <ilock+0x24>
      panic("ilock: no type");
    80003d66:	00005517          	auipc	a0,0x5
    80003d6a:	aa250513          	addi	a0,a0,-1374 # 80008808 <syscalls+0x1d8>
    80003d6e:	ffffc097          	auipc	ra,0xffffc
    80003d72:	7bc080e7          	jalr	1980(ra) # 8000052a <panic>

0000000080003d76 <iunlock>:
{
    80003d76:	1101                	addi	sp,sp,-32
    80003d78:	ec06                	sd	ra,24(sp)
    80003d7a:	e822                	sd	s0,16(sp)
    80003d7c:	e426                	sd	s1,8(sp)
    80003d7e:	e04a                	sd	s2,0(sp)
    80003d80:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003d82:	c905                	beqz	a0,80003db2 <iunlock+0x3c>
    80003d84:	84aa                	mv	s1,a0
    80003d86:	01050913          	addi	s2,a0,16
    80003d8a:	854a                	mv	a0,s2
    80003d8c:	00001097          	auipc	ra,0x1
    80003d90:	c90080e7          	jalr	-880(ra) # 80004a1c <holdingsleep>
    80003d94:	cd19                	beqz	a0,80003db2 <iunlock+0x3c>
    80003d96:	449c                	lw	a5,8(s1)
    80003d98:	00f05d63          	blez	a5,80003db2 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003d9c:	854a                	mv	a0,s2
    80003d9e:	00001097          	auipc	ra,0x1
    80003da2:	c3a080e7          	jalr	-966(ra) # 800049d8 <releasesleep>
}
    80003da6:	60e2                	ld	ra,24(sp)
    80003da8:	6442                	ld	s0,16(sp)
    80003daa:	64a2                	ld	s1,8(sp)
    80003dac:	6902                	ld	s2,0(sp)
    80003dae:	6105                	addi	sp,sp,32
    80003db0:	8082                	ret
    panic("iunlock");
    80003db2:	00005517          	auipc	a0,0x5
    80003db6:	a6650513          	addi	a0,a0,-1434 # 80008818 <syscalls+0x1e8>
    80003dba:	ffffc097          	auipc	ra,0xffffc
    80003dbe:	770080e7          	jalr	1904(ra) # 8000052a <panic>

0000000080003dc2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003dc2:	7179                	addi	sp,sp,-48
    80003dc4:	f406                	sd	ra,40(sp)
    80003dc6:	f022                	sd	s0,32(sp)
    80003dc8:	ec26                	sd	s1,24(sp)
    80003dca:	e84a                	sd	s2,16(sp)
    80003dcc:	e44e                	sd	s3,8(sp)
    80003dce:	e052                	sd	s4,0(sp)
    80003dd0:	1800                	addi	s0,sp,48
    80003dd2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003dd4:	05050493          	addi	s1,a0,80
    80003dd8:	08050913          	addi	s2,a0,128
    80003ddc:	a021                	j	80003de4 <itrunc+0x22>
    80003dde:	0491                	addi	s1,s1,4
    80003de0:	01248d63          	beq	s1,s2,80003dfa <itrunc+0x38>
    if(ip->addrs[i]){
    80003de4:	408c                	lw	a1,0(s1)
    80003de6:	dde5                	beqz	a1,80003dde <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003de8:	0009a503          	lw	a0,0(s3)
    80003dec:	00000097          	auipc	ra,0x0
    80003df0:	90a080e7          	jalr	-1782(ra) # 800036f6 <bfree>
      ip->addrs[i] = 0;
    80003df4:	0004a023          	sw	zero,0(s1)
    80003df8:	b7dd                	j	80003dde <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003dfa:	0809a583          	lw	a1,128(s3)
    80003dfe:	e185                	bnez	a1,80003e1e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003e00:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003e04:	854e                	mv	a0,s3
    80003e06:	00000097          	auipc	ra,0x0
    80003e0a:	de4080e7          	jalr	-540(ra) # 80003bea <iupdate>
}
    80003e0e:	70a2                	ld	ra,40(sp)
    80003e10:	7402                	ld	s0,32(sp)
    80003e12:	64e2                	ld	s1,24(sp)
    80003e14:	6942                	ld	s2,16(sp)
    80003e16:	69a2                	ld	s3,8(sp)
    80003e18:	6a02                	ld	s4,0(sp)
    80003e1a:	6145                	addi	sp,sp,48
    80003e1c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003e1e:	0009a503          	lw	a0,0(s3)
    80003e22:	fffff097          	auipc	ra,0xfffff
    80003e26:	68e080e7          	jalr	1678(ra) # 800034b0 <bread>
    80003e2a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003e2c:	05850493          	addi	s1,a0,88
    80003e30:	45850913          	addi	s2,a0,1112
    80003e34:	a021                	j	80003e3c <itrunc+0x7a>
    80003e36:	0491                	addi	s1,s1,4
    80003e38:	01248b63          	beq	s1,s2,80003e4e <itrunc+0x8c>
      if(a[j])
    80003e3c:	408c                	lw	a1,0(s1)
    80003e3e:	dde5                	beqz	a1,80003e36 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003e40:	0009a503          	lw	a0,0(s3)
    80003e44:	00000097          	auipc	ra,0x0
    80003e48:	8b2080e7          	jalr	-1870(ra) # 800036f6 <bfree>
    80003e4c:	b7ed                	j	80003e36 <itrunc+0x74>
    brelse(bp);
    80003e4e:	8552                	mv	a0,s4
    80003e50:	fffff097          	auipc	ra,0xfffff
    80003e54:	790080e7          	jalr	1936(ra) # 800035e0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003e58:	0809a583          	lw	a1,128(s3)
    80003e5c:	0009a503          	lw	a0,0(s3)
    80003e60:	00000097          	auipc	ra,0x0
    80003e64:	896080e7          	jalr	-1898(ra) # 800036f6 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003e68:	0809a023          	sw	zero,128(s3)
    80003e6c:	bf51                	j	80003e00 <itrunc+0x3e>

0000000080003e6e <iput>:
{
    80003e6e:	1101                	addi	sp,sp,-32
    80003e70:	ec06                	sd	ra,24(sp)
    80003e72:	e822                	sd	s0,16(sp)
    80003e74:	e426                	sd	s1,8(sp)
    80003e76:	e04a                	sd	s2,0(sp)
    80003e78:	1000                	addi	s0,sp,32
    80003e7a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e7c:	0001c517          	auipc	a0,0x1c
    80003e80:	16450513          	addi	a0,a0,356 # 8001ffe0 <itable>
    80003e84:	ffffd097          	auipc	ra,0xffffd
    80003e88:	d3e080e7          	jalr	-706(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e8c:	4498                	lw	a4,8(s1)
    80003e8e:	4785                	li	a5,1
    80003e90:	02f70363          	beq	a4,a5,80003eb6 <iput+0x48>
  ip->ref--;
    80003e94:	449c                	lw	a5,8(s1)
    80003e96:	37fd                	addiw	a5,a5,-1
    80003e98:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e9a:	0001c517          	auipc	a0,0x1c
    80003e9e:	14650513          	addi	a0,a0,326 # 8001ffe0 <itable>
    80003ea2:	ffffd097          	auipc	ra,0xffffd
    80003ea6:	dd4080e7          	jalr	-556(ra) # 80000c76 <release>
}
    80003eaa:	60e2                	ld	ra,24(sp)
    80003eac:	6442                	ld	s0,16(sp)
    80003eae:	64a2                	ld	s1,8(sp)
    80003eb0:	6902                	ld	s2,0(sp)
    80003eb2:	6105                	addi	sp,sp,32
    80003eb4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003eb6:	40bc                	lw	a5,64(s1)
    80003eb8:	dff1                	beqz	a5,80003e94 <iput+0x26>
    80003eba:	04a49783          	lh	a5,74(s1)
    80003ebe:	fbf9                	bnez	a5,80003e94 <iput+0x26>
    acquiresleep(&ip->lock);
    80003ec0:	01048913          	addi	s2,s1,16
    80003ec4:	854a                	mv	a0,s2
    80003ec6:	00001097          	auipc	ra,0x1
    80003eca:	abc080e7          	jalr	-1348(ra) # 80004982 <acquiresleep>
    release(&itable.lock);
    80003ece:	0001c517          	auipc	a0,0x1c
    80003ed2:	11250513          	addi	a0,a0,274 # 8001ffe0 <itable>
    80003ed6:	ffffd097          	auipc	ra,0xffffd
    80003eda:	da0080e7          	jalr	-608(ra) # 80000c76 <release>
    itrunc(ip);
    80003ede:	8526                	mv	a0,s1
    80003ee0:	00000097          	auipc	ra,0x0
    80003ee4:	ee2080e7          	jalr	-286(ra) # 80003dc2 <itrunc>
    ip->type = 0;
    80003ee8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003eec:	8526                	mv	a0,s1
    80003eee:	00000097          	auipc	ra,0x0
    80003ef2:	cfc080e7          	jalr	-772(ra) # 80003bea <iupdate>
    ip->valid = 0;
    80003ef6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003efa:	854a                	mv	a0,s2
    80003efc:	00001097          	auipc	ra,0x1
    80003f00:	adc080e7          	jalr	-1316(ra) # 800049d8 <releasesleep>
    acquire(&itable.lock);
    80003f04:	0001c517          	auipc	a0,0x1c
    80003f08:	0dc50513          	addi	a0,a0,220 # 8001ffe0 <itable>
    80003f0c:	ffffd097          	auipc	ra,0xffffd
    80003f10:	cb6080e7          	jalr	-842(ra) # 80000bc2 <acquire>
    80003f14:	b741                	j	80003e94 <iput+0x26>

0000000080003f16 <iunlockput>:
{
    80003f16:	1101                	addi	sp,sp,-32
    80003f18:	ec06                	sd	ra,24(sp)
    80003f1a:	e822                	sd	s0,16(sp)
    80003f1c:	e426                	sd	s1,8(sp)
    80003f1e:	1000                	addi	s0,sp,32
    80003f20:	84aa                	mv	s1,a0
  iunlock(ip);
    80003f22:	00000097          	auipc	ra,0x0
    80003f26:	e54080e7          	jalr	-428(ra) # 80003d76 <iunlock>
  iput(ip);
    80003f2a:	8526                	mv	a0,s1
    80003f2c:	00000097          	auipc	ra,0x0
    80003f30:	f42080e7          	jalr	-190(ra) # 80003e6e <iput>
}
    80003f34:	60e2                	ld	ra,24(sp)
    80003f36:	6442                	ld	s0,16(sp)
    80003f38:	64a2                	ld	s1,8(sp)
    80003f3a:	6105                	addi	sp,sp,32
    80003f3c:	8082                	ret

0000000080003f3e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003f3e:	1141                	addi	sp,sp,-16
    80003f40:	e422                	sd	s0,8(sp)
    80003f42:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f44:	411c                	lw	a5,0(a0)
    80003f46:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003f48:	415c                	lw	a5,4(a0)
    80003f4a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003f4c:	04451783          	lh	a5,68(a0)
    80003f50:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003f54:	04a51783          	lh	a5,74(a0)
    80003f58:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003f5c:	04c56783          	lwu	a5,76(a0)
    80003f60:	e99c                	sd	a5,16(a1)
}
    80003f62:	6422                	ld	s0,8(sp)
    80003f64:	0141                	addi	sp,sp,16
    80003f66:	8082                	ret

0000000080003f68 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f68:	457c                	lw	a5,76(a0)
    80003f6a:	0ed7e963          	bltu	a5,a3,8000405c <readi+0xf4>
{
    80003f6e:	7159                	addi	sp,sp,-112
    80003f70:	f486                	sd	ra,104(sp)
    80003f72:	f0a2                	sd	s0,96(sp)
    80003f74:	eca6                	sd	s1,88(sp)
    80003f76:	e8ca                	sd	s2,80(sp)
    80003f78:	e4ce                	sd	s3,72(sp)
    80003f7a:	e0d2                	sd	s4,64(sp)
    80003f7c:	fc56                	sd	s5,56(sp)
    80003f7e:	f85a                	sd	s6,48(sp)
    80003f80:	f45e                	sd	s7,40(sp)
    80003f82:	f062                	sd	s8,32(sp)
    80003f84:	ec66                	sd	s9,24(sp)
    80003f86:	e86a                	sd	s10,16(sp)
    80003f88:	e46e                	sd	s11,8(sp)
    80003f8a:	1880                	addi	s0,sp,112
    80003f8c:	8baa                	mv	s7,a0
    80003f8e:	8c2e                	mv	s8,a1
    80003f90:	8ab2                	mv	s5,a2
    80003f92:	84b6                	mv	s1,a3
    80003f94:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f96:	9f35                	addw	a4,a4,a3
    return 0;
    80003f98:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003f9a:	0ad76063          	bltu	a4,a3,8000403a <readi+0xd2>
  if(off + n > ip->size)
    80003f9e:	00e7f463          	bgeu	a5,a4,80003fa6 <readi+0x3e>
    n = ip->size - off;
    80003fa2:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fa6:	0a0b0963          	beqz	s6,80004058 <readi+0xf0>
    80003faa:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fac:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003fb0:	5cfd                	li	s9,-1
    80003fb2:	a82d                	j	80003fec <readi+0x84>
    80003fb4:	020a1d93          	slli	s11,s4,0x20
    80003fb8:	020ddd93          	srli	s11,s11,0x20
    80003fbc:	05890793          	addi	a5,s2,88
    80003fc0:	86ee                	mv	a3,s11
    80003fc2:	963e                	add	a2,a2,a5
    80003fc4:	85d6                	mv	a1,s5
    80003fc6:	8562                	mv	a0,s8
    80003fc8:	ffffe097          	auipc	ra,0xffffe
    80003fcc:	612080e7          	jalr	1554(ra) # 800025da <either_copyout>
    80003fd0:	05950d63          	beq	a0,s9,8000402a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003fd4:	854a                	mv	a0,s2
    80003fd6:	fffff097          	auipc	ra,0xfffff
    80003fda:	60a080e7          	jalr	1546(ra) # 800035e0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fde:	013a09bb          	addw	s3,s4,s3
    80003fe2:	009a04bb          	addw	s1,s4,s1
    80003fe6:	9aee                	add	s5,s5,s11
    80003fe8:	0569f763          	bgeu	s3,s6,80004036 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003fec:	000ba903          	lw	s2,0(s7)
    80003ff0:	00a4d59b          	srliw	a1,s1,0xa
    80003ff4:	855e                	mv	a0,s7
    80003ff6:	00000097          	auipc	ra,0x0
    80003ffa:	8ae080e7          	jalr	-1874(ra) # 800038a4 <bmap>
    80003ffe:	0005059b          	sext.w	a1,a0
    80004002:	854a                	mv	a0,s2
    80004004:	fffff097          	auipc	ra,0xfffff
    80004008:	4ac080e7          	jalr	1196(ra) # 800034b0 <bread>
    8000400c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000400e:	3ff4f613          	andi	a2,s1,1023
    80004012:	40cd07bb          	subw	a5,s10,a2
    80004016:	413b073b          	subw	a4,s6,s3
    8000401a:	8a3e                	mv	s4,a5
    8000401c:	2781                	sext.w	a5,a5
    8000401e:	0007069b          	sext.w	a3,a4
    80004022:	f8f6f9e3          	bgeu	a3,a5,80003fb4 <readi+0x4c>
    80004026:	8a3a                	mv	s4,a4
    80004028:	b771                	j	80003fb4 <readi+0x4c>
      brelse(bp);
    8000402a:	854a                	mv	a0,s2
    8000402c:	fffff097          	auipc	ra,0xfffff
    80004030:	5b4080e7          	jalr	1460(ra) # 800035e0 <brelse>
      tot = -1;
    80004034:	59fd                	li	s3,-1
  }
  return tot;
    80004036:	0009851b          	sext.w	a0,s3
}
    8000403a:	70a6                	ld	ra,104(sp)
    8000403c:	7406                	ld	s0,96(sp)
    8000403e:	64e6                	ld	s1,88(sp)
    80004040:	6946                	ld	s2,80(sp)
    80004042:	69a6                	ld	s3,72(sp)
    80004044:	6a06                	ld	s4,64(sp)
    80004046:	7ae2                	ld	s5,56(sp)
    80004048:	7b42                	ld	s6,48(sp)
    8000404a:	7ba2                	ld	s7,40(sp)
    8000404c:	7c02                	ld	s8,32(sp)
    8000404e:	6ce2                	ld	s9,24(sp)
    80004050:	6d42                	ld	s10,16(sp)
    80004052:	6da2                	ld	s11,8(sp)
    80004054:	6165                	addi	sp,sp,112
    80004056:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004058:	89da                	mv	s3,s6
    8000405a:	bff1                	j	80004036 <readi+0xce>
    return 0;
    8000405c:	4501                	li	a0,0
}
    8000405e:	8082                	ret

0000000080004060 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004060:	457c                	lw	a5,76(a0)
    80004062:	10d7e863          	bltu	a5,a3,80004172 <writei+0x112>
{
    80004066:	7159                	addi	sp,sp,-112
    80004068:	f486                	sd	ra,104(sp)
    8000406a:	f0a2                	sd	s0,96(sp)
    8000406c:	eca6                	sd	s1,88(sp)
    8000406e:	e8ca                	sd	s2,80(sp)
    80004070:	e4ce                	sd	s3,72(sp)
    80004072:	e0d2                	sd	s4,64(sp)
    80004074:	fc56                	sd	s5,56(sp)
    80004076:	f85a                	sd	s6,48(sp)
    80004078:	f45e                	sd	s7,40(sp)
    8000407a:	f062                	sd	s8,32(sp)
    8000407c:	ec66                	sd	s9,24(sp)
    8000407e:	e86a                	sd	s10,16(sp)
    80004080:	e46e                	sd	s11,8(sp)
    80004082:	1880                	addi	s0,sp,112
    80004084:	8b2a                	mv	s6,a0
    80004086:	8c2e                	mv	s8,a1
    80004088:	8ab2                	mv	s5,a2
    8000408a:	8936                	mv	s2,a3
    8000408c:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    8000408e:	00e687bb          	addw	a5,a3,a4
    80004092:	0ed7e263          	bltu	a5,a3,80004176 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004096:	00043737          	lui	a4,0x43
    8000409a:	0ef76063          	bltu	a4,a5,8000417a <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000409e:	0c0b8863          	beqz	s7,8000416e <writei+0x10e>
    800040a2:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800040a4:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800040a8:	5cfd                	li	s9,-1
    800040aa:	a091                	j	800040ee <writei+0x8e>
    800040ac:	02099d93          	slli	s11,s3,0x20
    800040b0:	020ddd93          	srli	s11,s11,0x20
    800040b4:	05848793          	addi	a5,s1,88
    800040b8:	86ee                	mv	a3,s11
    800040ba:	8656                	mv	a2,s5
    800040bc:	85e2                	mv	a1,s8
    800040be:	953e                	add	a0,a0,a5
    800040c0:	ffffe097          	auipc	ra,0xffffe
    800040c4:	570080e7          	jalr	1392(ra) # 80002630 <either_copyin>
    800040c8:	07950263          	beq	a0,s9,8000412c <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800040cc:	8526                	mv	a0,s1
    800040ce:	00000097          	auipc	ra,0x0
    800040d2:	794080e7          	jalr	1940(ra) # 80004862 <log_write>
    brelse(bp);
    800040d6:	8526                	mv	a0,s1
    800040d8:	fffff097          	auipc	ra,0xfffff
    800040dc:	508080e7          	jalr	1288(ra) # 800035e0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040e0:	01498a3b          	addw	s4,s3,s4
    800040e4:	0129893b          	addw	s2,s3,s2
    800040e8:	9aee                	add	s5,s5,s11
    800040ea:	057a7663          	bgeu	s4,s7,80004136 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800040ee:	000b2483          	lw	s1,0(s6)
    800040f2:	00a9559b          	srliw	a1,s2,0xa
    800040f6:	855a                	mv	a0,s6
    800040f8:	fffff097          	auipc	ra,0xfffff
    800040fc:	7ac080e7          	jalr	1964(ra) # 800038a4 <bmap>
    80004100:	0005059b          	sext.w	a1,a0
    80004104:	8526                	mv	a0,s1
    80004106:	fffff097          	auipc	ra,0xfffff
    8000410a:	3aa080e7          	jalr	938(ra) # 800034b0 <bread>
    8000410e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004110:	3ff97513          	andi	a0,s2,1023
    80004114:	40ad07bb          	subw	a5,s10,a0
    80004118:	414b873b          	subw	a4,s7,s4
    8000411c:	89be                	mv	s3,a5
    8000411e:	2781                	sext.w	a5,a5
    80004120:	0007069b          	sext.w	a3,a4
    80004124:	f8f6f4e3          	bgeu	a3,a5,800040ac <writei+0x4c>
    80004128:	89ba                	mv	s3,a4
    8000412a:	b749                	j	800040ac <writei+0x4c>
      brelse(bp);
    8000412c:	8526                	mv	a0,s1
    8000412e:	fffff097          	auipc	ra,0xfffff
    80004132:	4b2080e7          	jalr	1202(ra) # 800035e0 <brelse>
  }

  if(off > ip->size)
    80004136:	04cb2783          	lw	a5,76(s6)
    8000413a:	0127f463          	bgeu	a5,s2,80004142 <writei+0xe2>
    ip->size = off;
    8000413e:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004142:	855a                	mv	a0,s6
    80004144:	00000097          	auipc	ra,0x0
    80004148:	aa6080e7          	jalr	-1370(ra) # 80003bea <iupdate>

  return tot;
    8000414c:	000a051b          	sext.w	a0,s4
}
    80004150:	70a6                	ld	ra,104(sp)
    80004152:	7406                	ld	s0,96(sp)
    80004154:	64e6                	ld	s1,88(sp)
    80004156:	6946                	ld	s2,80(sp)
    80004158:	69a6                	ld	s3,72(sp)
    8000415a:	6a06                	ld	s4,64(sp)
    8000415c:	7ae2                	ld	s5,56(sp)
    8000415e:	7b42                	ld	s6,48(sp)
    80004160:	7ba2                	ld	s7,40(sp)
    80004162:	7c02                	ld	s8,32(sp)
    80004164:	6ce2                	ld	s9,24(sp)
    80004166:	6d42                	ld	s10,16(sp)
    80004168:	6da2                	ld	s11,8(sp)
    8000416a:	6165                	addi	sp,sp,112
    8000416c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000416e:	8a5e                	mv	s4,s7
    80004170:	bfc9                	j	80004142 <writei+0xe2>
    return -1;
    80004172:	557d                	li	a0,-1
}
    80004174:	8082                	ret
    return -1;
    80004176:	557d                	li	a0,-1
    80004178:	bfe1                	j	80004150 <writei+0xf0>
    return -1;
    8000417a:	557d                	li	a0,-1
    8000417c:	bfd1                	j	80004150 <writei+0xf0>

000000008000417e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000417e:	1141                	addi	sp,sp,-16
    80004180:	e406                	sd	ra,8(sp)
    80004182:	e022                	sd	s0,0(sp)
    80004184:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004186:	4639                	li	a2,14
    80004188:	ffffd097          	auipc	ra,0xffffd
    8000418c:	c0e080e7          	jalr	-1010(ra) # 80000d96 <strncmp>
}
    80004190:	60a2                	ld	ra,8(sp)
    80004192:	6402                	ld	s0,0(sp)
    80004194:	0141                	addi	sp,sp,16
    80004196:	8082                	ret

0000000080004198 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004198:	7139                	addi	sp,sp,-64
    8000419a:	fc06                	sd	ra,56(sp)
    8000419c:	f822                	sd	s0,48(sp)
    8000419e:	f426                	sd	s1,40(sp)
    800041a0:	f04a                	sd	s2,32(sp)
    800041a2:	ec4e                	sd	s3,24(sp)
    800041a4:	e852                	sd	s4,16(sp)
    800041a6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800041a8:	04451703          	lh	a4,68(a0)
    800041ac:	4785                	li	a5,1
    800041ae:	00f71a63          	bne	a4,a5,800041c2 <dirlookup+0x2a>
    800041b2:	892a                	mv	s2,a0
    800041b4:	89ae                	mv	s3,a1
    800041b6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800041b8:	457c                	lw	a5,76(a0)
    800041ba:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800041bc:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041be:	e79d                	bnez	a5,800041ec <dirlookup+0x54>
    800041c0:	a8a5                	j	80004238 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800041c2:	00004517          	auipc	a0,0x4
    800041c6:	65e50513          	addi	a0,a0,1630 # 80008820 <syscalls+0x1f0>
    800041ca:	ffffc097          	auipc	ra,0xffffc
    800041ce:	360080e7          	jalr	864(ra) # 8000052a <panic>
      panic("dirlookup read");
    800041d2:	00004517          	auipc	a0,0x4
    800041d6:	66650513          	addi	a0,a0,1638 # 80008838 <syscalls+0x208>
    800041da:	ffffc097          	auipc	ra,0xffffc
    800041de:	350080e7          	jalr	848(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041e2:	24c1                	addiw	s1,s1,16
    800041e4:	04c92783          	lw	a5,76(s2)
    800041e8:	04f4f763          	bgeu	s1,a5,80004236 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041ec:	4741                	li	a4,16
    800041ee:	86a6                	mv	a3,s1
    800041f0:	fc040613          	addi	a2,s0,-64
    800041f4:	4581                	li	a1,0
    800041f6:	854a                	mv	a0,s2
    800041f8:	00000097          	auipc	ra,0x0
    800041fc:	d70080e7          	jalr	-656(ra) # 80003f68 <readi>
    80004200:	47c1                	li	a5,16
    80004202:	fcf518e3          	bne	a0,a5,800041d2 <dirlookup+0x3a>
    if(de.inum == 0)
    80004206:	fc045783          	lhu	a5,-64(s0)
    8000420a:	dfe1                	beqz	a5,800041e2 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000420c:	fc240593          	addi	a1,s0,-62
    80004210:	854e                	mv	a0,s3
    80004212:	00000097          	auipc	ra,0x0
    80004216:	f6c080e7          	jalr	-148(ra) # 8000417e <namecmp>
    8000421a:	f561                	bnez	a0,800041e2 <dirlookup+0x4a>
      if(poff)
    8000421c:	000a0463          	beqz	s4,80004224 <dirlookup+0x8c>
        *poff = off;
    80004220:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004224:	fc045583          	lhu	a1,-64(s0)
    80004228:	00092503          	lw	a0,0(s2)
    8000422c:	fffff097          	auipc	ra,0xfffff
    80004230:	754080e7          	jalr	1876(ra) # 80003980 <iget>
    80004234:	a011                	j	80004238 <dirlookup+0xa0>
  return 0;
    80004236:	4501                	li	a0,0
}
    80004238:	70e2                	ld	ra,56(sp)
    8000423a:	7442                	ld	s0,48(sp)
    8000423c:	74a2                	ld	s1,40(sp)
    8000423e:	7902                	ld	s2,32(sp)
    80004240:	69e2                	ld	s3,24(sp)
    80004242:	6a42                	ld	s4,16(sp)
    80004244:	6121                	addi	sp,sp,64
    80004246:	8082                	ret

0000000080004248 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004248:	711d                	addi	sp,sp,-96
    8000424a:	ec86                	sd	ra,88(sp)
    8000424c:	e8a2                	sd	s0,80(sp)
    8000424e:	e4a6                	sd	s1,72(sp)
    80004250:	e0ca                	sd	s2,64(sp)
    80004252:	fc4e                	sd	s3,56(sp)
    80004254:	f852                	sd	s4,48(sp)
    80004256:	f456                	sd	s5,40(sp)
    80004258:	f05a                	sd	s6,32(sp)
    8000425a:	ec5e                	sd	s7,24(sp)
    8000425c:	e862                	sd	s8,16(sp)
    8000425e:	e466                	sd	s9,8(sp)
    80004260:	1080                	addi	s0,sp,96
    80004262:	84aa                	mv	s1,a0
    80004264:	8aae                	mv	s5,a1
    80004266:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004268:	00054703          	lbu	a4,0(a0)
    8000426c:	02f00793          	li	a5,47
    80004270:	02f70363          	beq	a4,a5,80004296 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004274:	ffffd097          	auipc	ra,0xffffd
    80004278:	722080e7          	jalr	1826(ra) # 80001996 <myproc>
    8000427c:	17053503          	ld	a0,368(a0)
    80004280:	00000097          	auipc	ra,0x0
    80004284:	9f6080e7          	jalr	-1546(ra) # 80003c76 <idup>
    80004288:	89aa                	mv	s3,a0
  while(*path == '/')
    8000428a:	02f00913          	li	s2,47
  len = path - s;
    8000428e:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004290:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004292:	4b85                	li	s7,1
    80004294:	a865                	j	8000434c <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004296:	4585                	li	a1,1
    80004298:	4505                	li	a0,1
    8000429a:	fffff097          	auipc	ra,0xfffff
    8000429e:	6e6080e7          	jalr	1766(ra) # 80003980 <iget>
    800042a2:	89aa                	mv	s3,a0
    800042a4:	b7dd                	j	8000428a <namex+0x42>
      iunlockput(ip);
    800042a6:	854e                	mv	a0,s3
    800042a8:	00000097          	auipc	ra,0x0
    800042ac:	c6e080e7          	jalr	-914(ra) # 80003f16 <iunlockput>
      return 0;
    800042b0:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800042b2:	854e                	mv	a0,s3
    800042b4:	60e6                	ld	ra,88(sp)
    800042b6:	6446                	ld	s0,80(sp)
    800042b8:	64a6                	ld	s1,72(sp)
    800042ba:	6906                	ld	s2,64(sp)
    800042bc:	79e2                	ld	s3,56(sp)
    800042be:	7a42                	ld	s4,48(sp)
    800042c0:	7aa2                	ld	s5,40(sp)
    800042c2:	7b02                	ld	s6,32(sp)
    800042c4:	6be2                	ld	s7,24(sp)
    800042c6:	6c42                	ld	s8,16(sp)
    800042c8:	6ca2                	ld	s9,8(sp)
    800042ca:	6125                	addi	sp,sp,96
    800042cc:	8082                	ret
      iunlock(ip);
    800042ce:	854e                	mv	a0,s3
    800042d0:	00000097          	auipc	ra,0x0
    800042d4:	aa6080e7          	jalr	-1370(ra) # 80003d76 <iunlock>
      return ip;
    800042d8:	bfe9                	j	800042b2 <namex+0x6a>
      iunlockput(ip);
    800042da:	854e                	mv	a0,s3
    800042dc:	00000097          	auipc	ra,0x0
    800042e0:	c3a080e7          	jalr	-966(ra) # 80003f16 <iunlockput>
      return 0;
    800042e4:	89e6                	mv	s3,s9
    800042e6:	b7f1                	j	800042b2 <namex+0x6a>
  len = path - s;
    800042e8:	40b48633          	sub	a2,s1,a1
    800042ec:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800042f0:	099c5463          	bge	s8,s9,80004378 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800042f4:	4639                	li	a2,14
    800042f6:	8552                	mv	a0,s4
    800042f8:	ffffd097          	auipc	ra,0xffffd
    800042fc:	a22080e7          	jalr	-1502(ra) # 80000d1a <memmove>
  while(*path == '/')
    80004300:	0004c783          	lbu	a5,0(s1)
    80004304:	01279763          	bne	a5,s2,80004312 <namex+0xca>
    path++;
    80004308:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000430a:	0004c783          	lbu	a5,0(s1)
    8000430e:	ff278de3          	beq	a5,s2,80004308 <namex+0xc0>
    ilock(ip);
    80004312:	854e                	mv	a0,s3
    80004314:	00000097          	auipc	ra,0x0
    80004318:	9a0080e7          	jalr	-1632(ra) # 80003cb4 <ilock>
    if(ip->type != T_DIR){
    8000431c:	04499783          	lh	a5,68(s3)
    80004320:	f97793e3          	bne	a5,s7,800042a6 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004324:	000a8563          	beqz	s5,8000432e <namex+0xe6>
    80004328:	0004c783          	lbu	a5,0(s1)
    8000432c:	d3cd                	beqz	a5,800042ce <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000432e:	865a                	mv	a2,s6
    80004330:	85d2                	mv	a1,s4
    80004332:	854e                	mv	a0,s3
    80004334:	00000097          	auipc	ra,0x0
    80004338:	e64080e7          	jalr	-412(ra) # 80004198 <dirlookup>
    8000433c:	8caa                	mv	s9,a0
    8000433e:	dd51                	beqz	a0,800042da <namex+0x92>
    iunlockput(ip);
    80004340:	854e                	mv	a0,s3
    80004342:	00000097          	auipc	ra,0x0
    80004346:	bd4080e7          	jalr	-1068(ra) # 80003f16 <iunlockput>
    ip = next;
    8000434a:	89e6                	mv	s3,s9
  while(*path == '/')
    8000434c:	0004c783          	lbu	a5,0(s1)
    80004350:	05279763          	bne	a5,s2,8000439e <namex+0x156>
    path++;
    80004354:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004356:	0004c783          	lbu	a5,0(s1)
    8000435a:	ff278de3          	beq	a5,s2,80004354 <namex+0x10c>
  if(*path == 0)
    8000435e:	c79d                	beqz	a5,8000438c <namex+0x144>
    path++;
    80004360:	85a6                	mv	a1,s1
  len = path - s;
    80004362:	8cda                	mv	s9,s6
    80004364:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004366:	01278963          	beq	a5,s2,80004378 <namex+0x130>
    8000436a:	dfbd                	beqz	a5,800042e8 <namex+0xa0>
    path++;
    8000436c:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000436e:	0004c783          	lbu	a5,0(s1)
    80004372:	ff279ce3          	bne	a5,s2,8000436a <namex+0x122>
    80004376:	bf8d                	j	800042e8 <namex+0xa0>
    memmove(name, s, len);
    80004378:	2601                	sext.w	a2,a2
    8000437a:	8552                	mv	a0,s4
    8000437c:	ffffd097          	auipc	ra,0xffffd
    80004380:	99e080e7          	jalr	-1634(ra) # 80000d1a <memmove>
    name[len] = 0;
    80004384:	9cd2                	add	s9,s9,s4
    80004386:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000438a:	bf9d                	j	80004300 <namex+0xb8>
  if(nameiparent){
    8000438c:	f20a83e3          	beqz	s5,800042b2 <namex+0x6a>
    iput(ip);
    80004390:	854e                	mv	a0,s3
    80004392:	00000097          	auipc	ra,0x0
    80004396:	adc080e7          	jalr	-1316(ra) # 80003e6e <iput>
    return 0;
    8000439a:	4981                	li	s3,0
    8000439c:	bf19                	j	800042b2 <namex+0x6a>
  if(*path == 0)
    8000439e:	d7fd                	beqz	a5,8000438c <namex+0x144>
  while(*path != '/' && *path != 0)
    800043a0:	0004c783          	lbu	a5,0(s1)
    800043a4:	85a6                	mv	a1,s1
    800043a6:	b7d1                	j	8000436a <namex+0x122>

00000000800043a8 <dirlink>:
{
    800043a8:	7139                	addi	sp,sp,-64
    800043aa:	fc06                	sd	ra,56(sp)
    800043ac:	f822                	sd	s0,48(sp)
    800043ae:	f426                	sd	s1,40(sp)
    800043b0:	f04a                	sd	s2,32(sp)
    800043b2:	ec4e                	sd	s3,24(sp)
    800043b4:	e852                	sd	s4,16(sp)
    800043b6:	0080                	addi	s0,sp,64
    800043b8:	892a                	mv	s2,a0
    800043ba:	8a2e                	mv	s4,a1
    800043bc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800043be:	4601                	li	a2,0
    800043c0:	00000097          	auipc	ra,0x0
    800043c4:	dd8080e7          	jalr	-552(ra) # 80004198 <dirlookup>
    800043c8:	e93d                	bnez	a0,8000443e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043ca:	04c92483          	lw	s1,76(s2)
    800043ce:	c49d                	beqz	s1,800043fc <dirlink+0x54>
    800043d0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043d2:	4741                	li	a4,16
    800043d4:	86a6                	mv	a3,s1
    800043d6:	fc040613          	addi	a2,s0,-64
    800043da:	4581                	li	a1,0
    800043dc:	854a                	mv	a0,s2
    800043de:	00000097          	auipc	ra,0x0
    800043e2:	b8a080e7          	jalr	-1142(ra) # 80003f68 <readi>
    800043e6:	47c1                	li	a5,16
    800043e8:	06f51163          	bne	a0,a5,8000444a <dirlink+0xa2>
    if(de.inum == 0)
    800043ec:	fc045783          	lhu	a5,-64(s0)
    800043f0:	c791                	beqz	a5,800043fc <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043f2:	24c1                	addiw	s1,s1,16
    800043f4:	04c92783          	lw	a5,76(s2)
    800043f8:	fcf4ede3          	bltu	s1,a5,800043d2 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800043fc:	4639                	li	a2,14
    800043fe:	85d2                	mv	a1,s4
    80004400:	fc240513          	addi	a0,s0,-62
    80004404:	ffffd097          	auipc	ra,0xffffd
    80004408:	9ce080e7          	jalr	-1586(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    8000440c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004410:	4741                	li	a4,16
    80004412:	86a6                	mv	a3,s1
    80004414:	fc040613          	addi	a2,s0,-64
    80004418:	4581                	li	a1,0
    8000441a:	854a                	mv	a0,s2
    8000441c:	00000097          	auipc	ra,0x0
    80004420:	c44080e7          	jalr	-956(ra) # 80004060 <writei>
    80004424:	872a                	mv	a4,a0
    80004426:	47c1                	li	a5,16
  return 0;
    80004428:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000442a:	02f71863          	bne	a4,a5,8000445a <dirlink+0xb2>
}
    8000442e:	70e2                	ld	ra,56(sp)
    80004430:	7442                	ld	s0,48(sp)
    80004432:	74a2                	ld	s1,40(sp)
    80004434:	7902                	ld	s2,32(sp)
    80004436:	69e2                	ld	s3,24(sp)
    80004438:	6a42                	ld	s4,16(sp)
    8000443a:	6121                	addi	sp,sp,64
    8000443c:	8082                	ret
    iput(ip);
    8000443e:	00000097          	auipc	ra,0x0
    80004442:	a30080e7          	jalr	-1488(ra) # 80003e6e <iput>
    return -1;
    80004446:	557d                	li	a0,-1
    80004448:	b7dd                	j	8000442e <dirlink+0x86>
      panic("dirlink read");
    8000444a:	00004517          	auipc	a0,0x4
    8000444e:	3fe50513          	addi	a0,a0,1022 # 80008848 <syscalls+0x218>
    80004452:	ffffc097          	auipc	ra,0xffffc
    80004456:	0d8080e7          	jalr	216(ra) # 8000052a <panic>
    panic("dirlink");
    8000445a:	00004517          	auipc	a0,0x4
    8000445e:	4f650513          	addi	a0,a0,1270 # 80008950 <syscalls+0x320>
    80004462:	ffffc097          	auipc	ra,0xffffc
    80004466:	0c8080e7          	jalr	200(ra) # 8000052a <panic>

000000008000446a <namei>:

struct inode*
namei(char *path)
{
    8000446a:	1101                	addi	sp,sp,-32
    8000446c:	ec06                	sd	ra,24(sp)
    8000446e:	e822                	sd	s0,16(sp)
    80004470:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004472:	fe040613          	addi	a2,s0,-32
    80004476:	4581                	li	a1,0
    80004478:	00000097          	auipc	ra,0x0
    8000447c:	dd0080e7          	jalr	-560(ra) # 80004248 <namex>
}
    80004480:	60e2                	ld	ra,24(sp)
    80004482:	6442                	ld	s0,16(sp)
    80004484:	6105                	addi	sp,sp,32
    80004486:	8082                	ret

0000000080004488 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004488:	1141                	addi	sp,sp,-16
    8000448a:	e406                	sd	ra,8(sp)
    8000448c:	e022                	sd	s0,0(sp)
    8000448e:	0800                	addi	s0,sp,16
    80004490:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004492:	4585                	li	a1,1
    80004494:	00000097          	auipc	ra,0x0
    80004498:	db4080e7          	jalr	-588(ra) # 80004248 <namex>
}
    8000449c:	60a2                	ld	ra,8(sp)
    8000449e:	6402                	ld	s0,0(sp)
    800044a0:	0141                	addi	sp,sp,16
    800044a2:	8082                	ret

00000000800044a4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800044a4:	1101                	addi	sp,sp,-32
    800044a6:	ec06                	sd	ra,24(sp)
    800044a8:	e822                	sd	s0,16(sp)
    800044aa:	e426                	sd	s1,8(sp)
    800044ac:	e04a                	sd	s2,0(sp)
    800044ae:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800044b0:	0001d917          	auipc	s2,0x1d
    800044b4:	5d890913          	addi	s2,s2,1496 # 80021a88 <log>
    800044b8:	01892583          	lw	a1,24(s2)
    800044bc:	02892503          	lw	a0,40(s2)
    800044c0:	fffff097          	auipc	ra,0xfffff
    800044c4:	ff0080e7          	jalr	-16(ra) # 800034b0 <bread>
    800044c8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800044ca:	02c92683          	lw	a3,44(s2)
    800044ce:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800044d0:	02d05863          	blez	a3,80004500 <write_head+0x5c>
    800044d4:	0001d797          	auipc	a5,0x1d
    800044d8:	5e478793          	addi	a5,a5,1508 # 80021ab8 <log+0x30>
    800044dc:	05c50713          	addi	a4,a0,92
    800044e0:	36fd                	addiw	a3,a3,-1
    800044e2:	02069613          	slli	a2,a3,0x20
    800044e6:	01e65693          	srli	a3,a2,0x1e
    800044ea:	0001d617          	auipc	a2,0x1d
    800044ee:	5d260613          	addi	a2,a2,1490 # 80021abc <log+0x34>
    800044f2:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800044f4:	4390                	lw	a2,0(a5)
    800044f6:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800044f8:	0791                	addi	a5,a5,4
    800044fa:	0711                	addi	a4,a4,4
    800044fc:	fed79ce3          	bne	a5,a3,800044f4 <write_head+0x50>
  }
  bwrite(buf);
    80004500:	8526                	mv	a0,s1
    80004502:	fffff097          	auipc	ra,0xfffff
    80004506:	0a0080e7          	jalr	160(ra) # 800035a2 <bwrite>
  brelse(buf);
    8000450a:	8526                	mv	a0,s1
    8000450c:	fffff097          	auipc	ra,0xfffff
    80004510:	0d4080e7          	jalr	212(ra) # 800035e0 <brelse>
}
    80004514:	60e2                	ld	ra,24(sp)
    80004516:	6442                	ld	s0,16(sp)
    80004518:	64a2                	ld	s1,8(sp)
    8000451a:	6902                	ld	s2,0(sp)
    8000451c:	6105                	addi	sp,sp,32
    8000451e:	8082                	ret

0000000080004520 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004520:	0001d797          	auipc	a5,0x1d
    80004524:	5947a783          	lw	a5,1428(a5) # 80021ab4 <log+0x2c>
    80004528:	0af05d63          	blez	a5,800045e2 <install_trans+0xc2>
{
    8000452c:	7139                	addi	sp,sp,-64
    8000452e:	fc06                	sd	ra,56(sp)
    80004530:	f822                	sd	s0,48(sp)
    80004532:	f426                	sd	s1,40(sp)
    80004534:	f04a                	sd	s2,32(sp)
    80004536:	ec4e                	sd	s3,24(sp)
    80004538:	e852                	sd	s4,16(sp)
    8000453a:	e456                	sd	s5,8(sp)
    8000453c:	e05a                	sd	s6,0(sp)
    8000453e:	0080                	addi	s0,sp,64
    80004540:	8b2a                	mv	s6,a0
    80004542:	0001da97          	auipc	s5,0x1d
    80004546:	576a8a93          	addi	s5,s5,1398 # 80021ab8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000454a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000454c:	0001d997          	auipc	s3,0x1d
    80004550:	53c98993          	addi	s3,s3,1340 # 80021a88 <log>
    80004554:	a00d                	j	80004576 <install_trans+0x56>
    brelse(lbuf);
    80004556:	854a                	mv	a0,s2
    80004558:	fffff097          	auipc	ra,0xfffff
    8000455c:	088080e7          	jalr	136(ra) # 800035e0 <brelse>
    brelse(dbuf);
    80004560:	8526                	mv	a0,s1
    80004562:	fffff097          	auipc	ra,0xfffff
    80004566:	07e080e7          	jalr	126(ra) # 800035e0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000456a:	2a05                	addiw	s4,s4,1
    8000456c:	0a91                	addi	s5,s5,4
    8000456e:	02c9a783          	lw	a5,44(s3)
    80004572:	04fa5e63          	bge	s4,a5,800045ce <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004576:	0189a583          	lw	a1,24(s3)
    8000457a:	014585bb          	addw	a1,a1,s4
    8000457e:	2585                	addiw	a1,a1,1
    80004580:	0289a503          	lw	a0,40(s3)
    80004584:	fffff097          	auipc	ra,0xfffff
    80004588:	f2c080e7          	jalr	-212(ra) # 800034b0 <bread>
    8000458c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000458e:	000aa583          	lw	a1,0(s5)
    80004592:	0289a503          	lw	a0,40(s3)
    80004596:	fffff097          	auipc	ra,0xfffff
    8000459a:	f1a080e7          	jalr	-230(ra) # 800034b0 <bread>
    8000459e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800045a0:	40000613          	li	a2,1024
    800045a4:	05890593          	addi	a1,s2,88
    800045a8:	05850513          	addi	a0,a0,88
    800045ac:	ffffc097          	auipc	ra,0xffffc
    800045b0:	76e080e7          	jalr	1902(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    800045b4:	8526                	mv	a0,s1
    800045b6:	fffff097          	auipc	ra,0xfffff
    800045ba:	fec080e7          	jalr	-20(ra) # 800035a2 <bwrite>
    if(recovering == 0)
    800045be:	f80b1ce3          	bnez	s6,80004556 <install_trans+0x36>
      bunpin(dbuf);
    800045c2:	8526                	mv	a0,s1
    800045c4:	fffff097          	auipc	ra,0xfffff
    800045c8:	0f6080e7          	jalr	246(ra) # 800036ba <bunpin>
    800045cc:	b769                	j	80004556 <install_trans+0x36>
}
    800045ce:	70e2                	ld	ra,56(sp)
    800045d0:	7442                	ld	s0,48(sp)
    800045d2:	74a2                	ld	s1,40(sp)
    800045d4:	7902                	ld	s2,32(sp)
    800045d6:	69e2                	ld	s3,24(sp)
    800045d8:	6a42                	ld	s4,16(sp)
    800045da:	6aa2                	ld	s5,8(sp)
    800045dc:	6b02                	ld	s6,0(sp)
    800045de:	6121                	addi	sp,sp,64
    800045e0:	8082                	ret
    800045e2:	8082                	ret

00000000800045e4 <initlog>:
{
    800045e4:	7179                	addi	sp,sp,-48
    800045e6:	f406                	sd	ra,40(sp)
    800045e8:	f022                	sd	s0,32(sp)
    800045ea:	ec26                	sd	s1,24(sp)
    800045ec:	e84a                	sd	s2,16(sp)
    800045ee:	e44e                	sd	s3,8(sp)
    800045f0:	1800                	addi	s0,sp,48
    800045f2:	892a                	mv	s2,a0
    800045f4:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800045f6:	0001d497          	auipc	s1,0x1d
    800045fa:	49248493          	addi	s1,s1,1170 # 80021a88 <log>
    800045fe:	00004597          	auipc	a1,0x4
    80004602:	25a58593          	addi	a1,a1,602 # 80008858 <syscalls+0x228>
    80004606:	8526                	mv	a0,s1
    80004608:	ffffc097          	auipc	ra,0xffffc
    8000460c:	52a080e7          	jalr	1322(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    80004610:	0149a583          	lw	a1,20(s3)
    80004614:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004616:	0109a783          	lw	a5,16(s3)
    8000461a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000461c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004620:	854a                	mv	a0,s2
    80004622:	fffff097          	auipc	ra,0xfffff
    80004626:	e8e080e7          	jalr	-370(ra) # 800034b0 <bread>
  log.lh.n = lh->n;
    8000462a:	4d34                	lw	a3,88(a0)
    8000462c:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000462e:	02d05663          	blez	a3,8000465a <initlog+0x76>
    80004632:	05c50793          	addi	a5,a0,92
    80004636:	0001d717          	auipc	a4,0x1d
    8000463a:	48270713          	addi	a4,a4,1154 # 80021ab8 <log+0x30>
    8000463e:	36fd                	addiw	a3,a3,-1
    80004640:	02069613          	slli	a2,a3,0x20
    80004644:	01e65693          	srli	a3,a2,0x1e
    80004648:	06050613          	addi	a2,a0,96
    8000464c:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000464e:	4390                	lw	a2,0(a5)
    80004650:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004652:	0791                	addi	a5,a5,4
    80004654:	0711                	addi	a4,a4,4
    80004656:	fed79ce3          	bne	a5,a3,8000464e <initlog+0x6a>
  brelse(buf);
    8000465a:	fffff097          	auipc	ra,0xfffff
    8000465e:	f86080e7          	jalr	-122(ra) # 800035e0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004662:	4505                	li	a0,1
    80004664:	00000097          	auipc	ra,0x0
    80004668:	ebc080e7          	jalr	-324(ra) # 80004520 <install_trans>
  log.lh.n = 0;
    8000466c:	0001d797          	auipc	a5,0x1d
    80004670:	4407a423          	sw	zero,1096(a5) # 80021ab4 <log+0x2c>
  write_head(); // clear the log
    80004674:	00000097          	auipc	ra,0x0
    80004678:	e30080e7          	jalr	-464(ra) # 800044a4 <write_head>
}
    8000467c:	70a2                	ld	ra,40(sp)
    8000467e:	7402                	ld	s0,32(sp)
    80004680:	64e2                	ld	s1,24(sp)
    80004682:	6942                	ld	s2,16(sp)
    80004684:	69a2                	ld	s3,8(sp)
    80004686:	6145                	addi	sp,sp,48
    80004688:	8082                	ret

000000008000468a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000468a:	1101                	addi	sp,sp,-32
    8000468c:	ec06                	sd	ra,24(sp)
    8000468e:	e822                	sd	s0,16(sp)
    80004690:	e426                	sd	s1,8(sp)
    80004692:	e04a                	sd	s2,0(sp)
    80004694:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004696:	0001d517          	auipc	a0,0x1d
    8000469a:	3f250513          	addi	a0,a0,1010 # 80021a88 <log>
    8000469e:	ffffc097          	auipc	ra,0xffffc
    800046a2:	524080e7          	jalr	1316(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    800046a6:	0001d497          	auipc	s1,0x1d
    800046aa:	3e248493          	addi	s1,s1,994 # 80021a88 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046ae:	4979                	li	s2,30
    800046b0:	a039                	j	800046be <begin_op+0x34>
      sleep(&log, &log.lock);
    800046b2:	85a6                	mv	a1,s1
    800046b4:	8526                	mv	a0,s1
    800046b6:	ffffe097          	auipc	ra,0xffffe
    800046ba:	b10080e7          	jalr	-1264(ra) # 800021c6 <sleep>
    if(log.committing){
    800046be:	50dc                	lw	a5,36(s1)
    800046c0:	fbed                	bnez	a5,800046b2 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046c2:	509c                	lw	a5,32(s1)
    800046c4:	0017871b          	addiw	a4,a5,1
    800046c8:	0007069b          	sext.w	a3,a4
    800046cc:	0027179b          	slliw	a5,a4,0x2
    800046d0:	9fb9                	addw	a5,a5,a4
    800046d2:	0017979b          	slliw	a5,a5,0x1
    800046d6:	54d8                	lw	a4,44(s1)
    800046d8:	9fb9                	addw	a5,a5,a4
    800046da:	00f95963          	bge	s2,a5,800046ec <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800046de:	85a6                	mv	a1,s1
    800046e0:	8526                	mv	a0,s1
    800046e2:	ffffe097          	auipc	ra,0xffffe
    800046e6:	ae4080e7          	jalr	-1308(ra) # 800021c6 <sleep>
    800046ea:	bfd1                	j	800046be <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800046ec:	0001d517          	auipc	a0,0x1d
    800046f0:	39c50513          	addi	a0,a0,924 # 80021a88 <log>
    800046f4:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800046f6:	ffffc097          	auipc	ra,0xffffc
    800046fa:	580080e7          	jalr	1408(ra) # 80000c76 <release>
      break;
    }
  }
}
    800046fe:	60e2                	ld	ra,24(sp)
    80004700:	6442                	ld	s0,16(sp)
    80004702:	64a2                	ld	s1,8(sp)
    80004704:	6902                	ld	s2,0(sp)
    80004706:	6105                	addi	sp,sp,32
    80004708:	8082                	ret

000000008000470a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000470a:	7139                	addi	sp,sp,-64
    8000470c:	fc06                	sd	ra,56(sp)
    8000470e:	f822                	sd	s0,48(sp)
    80004710:	f426                	sd	s1,40(sp)
    80004712:	f04a                	sd	s2,32(sp)
    80004714:	ec4e                	sd	s3,24(sp)
    80004716:	e852                	sd	s4,16(sp)
    80004718:	e456                	sd	s5,8(sp)
    8000471a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000471c:	0001d497          	auipc	s1,0x1d
    80004720:	36c48493          	addi	s1,s1,876 # 80021a88 <log>
    80004724:	8526                	mv	a0,s1
    80004726:	ffffc097          	auipc	ra,0xffffc
    8000472a:	49c080e7          	jalr	1180(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    8000472e:	509c                	lw	a5,32(s1)
    80004730:	37fd                	addiw	a5,a5,-1
    80004732:	0007891b          	sext.w	s2,a5
    80004736:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004738:	50dc                	lw	a5,36(s1)
    8000473a:	e7b9                	bnez	a5,80004788 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000473c:	04091e63          	bnez	s2,80004798 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004740:	0001d497          	auipc	s1,0x1d
    80004744:	34848493          	addi	s1,s1,840 # 80021a88 <log>
    80004748:	4785                	li	a5,1
    8000474a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000474c:	8526                	mv	a0,s1
    8000474e:	ffffc097          	auipc	ra,0xffffc
    80004752:	528080e7          	jalr	1320(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004756:	54dc                	lw	a5,44(s1)
    80004758:	06f04763          	bgtz	a5,800047c6 <end_op+0xbc>
    acquire(&log.lock);
    8000475c:	0001d497          	auipc	s1,0x1d
    80004760:	32c48493          	addi	s1,s1,812 # 80021a88 <log>
    80004764:	8526                	mv	a0,s1
    80004766:	ffffc097          	auipc	ra,0xffffc
    8000476a:	45c080e7          	jalr	1116(ra) # 80000bc2 <acquire>
    log.committing = 0;
    8000476e:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004772:	8526                	mv	a0,s1
    80004774:	ffffe097          	auipc	ra,0xffffe
    80004778:	bde080e7          	jalr	-1058(ra) # 80002352 <wakeup>
    release(&log.lock);
    8000477c:	8526                	mv	a0,s1
    8000477e:	ffffc097          	auipc	ra,0xffffc
    80004782:	4f8080e7          	jalr	1272(ra) # 80000c76 <release>
}
    80004786:	a03d                	j	800047b4 <end_op+0xaa>
    panic("log.committing");
    80004788:	00004517          	auipc	a0,0x4
    8000478c:	0d850513          	addi	a0,a0,216 # 80008860 <syscalls+0x230>
    80004790:	ffffc097          	auipc	ra,0xffffc
    80004794:	d9a080e7          	jalr	-614(ra) # 8000052a <panic>
    wakeup(&log);
    80004798:	0001d497          	auipc	s1,0x1d
    8000479c:	2f048493          	addi	s1,s1,752 # 80021a88 <log>
    800047a0:	8526                	mv	a0,s1
    800047a2:	ffffe097          	auipc	ra,0xffffe
    800047a6:	bb0080e7          	jalr	-1104(ra) # 80002352 <wakeup>
  release(&log.lock);
    800047aa:	8526                	mv	a0,s1
    800047ac:	ffffc097          	auipc	ra,0xffffc
    800047b0:	4ca080e7          	jalr	1226(ra) # 80000c76 <release>
}
    800047b4:	70e2                	ld	ra,56(sp)
    800047b6:	7442                	ld	s0,48(sp)
    800047b8:	74a2                	ld	s1,40(sp)
    800047ba:	7902                	ld	s2,32(sp)
    800047bc:	69e2                	ld	s3,24(sp)
    800047be:	6a42                	ld	s4,16(sp)
    800047c0:	6aa2                	ld	s5,8(sp)
    800047c2:	6121                	addi	sp,sp,64
    800047c4:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800047c6:	0001da97          	auipc	s5,0x1d
    800047ca:	2f2a8a93          	addi	s5,s5,754 # 80021ab8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800047ce:	0001da17          	auipc	s4,0x1d
    800047d2:	2baa0a13          	addi	s4,s4,698 # 80021a88 <log>
    800047d6:	018a2583          	lw	a1,24(s4)
    800047da:	012585bb          	addw	a1,a1,s2
    800047de:	2585                	addiw	a1,a1,1
    800047e0:	028a2503          	lw	a0,40(s4)
    800047e4:	fffff097          	auipc	ra,0xfffff
    800047e8:	ccc080e7          	jalr	-820(ra) # 800034b0 <bread>
    800047ec:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800047ee:	000aa583          	lw	a1,0(s5)
    800047f2:	028a2503          	lw	a0,40(s4)
    800047f6:	fffff097          	auipc	ra,0xfffff
    800047fa:	cba080e7          	jalr	-838(ra) # 800034b0 <bread>
    800047fe:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004800:	40000613          	li	a2,1024
    80004804:	05850593          	addi	a1,a0,88
    80004808:	05848513          	addi	a0,s1,88
    8000480c:	ffffc097          	auipc	ra,0xffffc
    80004810:	50e080e7          	jalr	1294(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    80004814:	8526                	mv	a0,s1
    80004816:	fffff097          	auipc	ra,0xfffff
    8000481a:	d8c080e7          	jalr	-628(ra) # 800035a2 <bwrite>
    brelse(from);
    8000481e:	854e                	mv	a0,s3
    80004820:	fffff097          	auipc	ra,0xfffff
    80004824:	dc0080e7          	jalr	-576(ra) # 800035e0 <brelse>
    brelse(to);
    80004828:	8526                	mv	a0,s1
    8000482a:	fffff097          	auipc	ra,0xfffff
    8000482e:	db6080e7          	jalr	-586(ra) # 800035e0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004832:	2905                	addiw	s2,s2,1
    80004834:	0a91                	addi	s5,s5,4
    80004836:	02ca2783          	lw	a5,44(s4)
    8000483a:	f8f94ee3          	blt	s2,a5,800047d6 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000483e:	00000097          	auipc	ra,0x0
    80004842:	c66080e7          	jalr	-922(ra) # 800044a4 <write_head>
    install_trans(0); // Now install writes to home locations
    80004846:	4501                	li	a0,0
    80004848:	00000097          	auipc	ra,0x0
    8000484c:	cd8080e7          	jalr	-808(ra) # 80004520 <install_trans>
    log.lh.n = 0;
    80004850:	0001d797          	auipc	a5,0x1d
    80004854:	2607a223          	sw	zero,612(a5) # 80021ab4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004858:	00000097          	auipc	ra,0x0
    8000485c:	c4c080e7          	jalr	-948(ra) # 800044a4 <write_head>
    80004860:	bdf5                	j	8000475c <end_op+0x52>

0000000080004862 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004862:	1101                	addi	sp,sp,-32
    80004864:	ec06                	sd	ra,24(sp)
    80004866:	e822                	sd	s0,16(sp)
    80004868:	e426                	sd	s1,8(sp)
    8000486a:	e04a                	sd	s2,0(sp)
    8000486c:	1000                	addi	s0,sp,32
    8000486e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004870:	0001d917          	auipc	s2,0x1d
    80004874:	21890913          	addi	s2,s2,536 # 80021a88 <log>
    80004878:	854a                	mv	a0,s2
    8000487a:	ffffc097          	auipc	ra,0xffffc
    8000487e:	348080e7          	jalr	840(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004882:	02c92603          	lw	a2,44(s2)
    80004886:	47f5                	li	a5,29
    80004888:	06c7c563          	blt	a5,a2,800048f2 <log_write+0x90>
    8000488c:	0001d797          	auipc	a5,0x1d
    80004890:	2187a783          	lw	a5,536(a5) # 80021aa4 <log+0x1c>
    80004894:	37fd                	addiw	a5,a5,-1
    80004896:	04f65e63          	bge	a2,a5,800048f2 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000489a:	0001d797          	auipc	a5,0x1d
    8000489e:	20e7a783          	lw	a5,526(a5) # 80021aa8 <log+0x20>
    800048a2:	06f05063          	blez	a5,80004902 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800048a6:	4781                	li	a5,0
    800048a8:	06c05563          	blez	a2,80004912 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800048ac:	44cc                	lw	a1,12(s1)
    800048ae:	0001d717          	auipc	a4,0x1d
    800048b2:	20a70713          	addi	a4,a4,522 # 80021ab8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800048b6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800048b8:	4314                	lw	a3,0(a4)
    800048ba:	04b68c63          	beq	a3,a1,80004912 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800048be:	2785                	addiw	a5,a5,1
    800048c0:	0711                	addi	a4,a4,4
    800048c2:	fef61be3          	bne	a2,a5,800048b8 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800048c6:	0621                	addi	a2,a2,8
    800048c8:	060a                	slli	a2,a2,0x2
    800048ca:	0001d797          	auipc	a5,0x1d
    800048ce:	1be78793          	addi	a5,a5,446 # 80021a88 <log>
    800048d2:	963e                	add	a2,a2,a5
    800048d4:	44dc                	lw	a5,12(s1)
    800048d6:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800048d8:	8526                	mv	a0,s1
    800048da:	fffff097          	auipc	ra,0xfffff
    800048de:	da4080e7          	jalr	-604(ra) # 8000367e <bpin>
    log.lh.n++;
    800048e2:	0001d717          	auipc	a4,0x1d
    800048e6:	1a670713          	addi	a4,a4,422 # 80021a88 <log>
    800048ea:	575c                	lw	a5,44(a4)
    800048ec:	2785                	addiw	a5,a5,1
    800048ee:	d75c                	sw	a5,44(a4)
    800048f0:	a835                	j	8000492c <log_write+0xca>
    panic("too big a transaction");
    800048f2:	00004517          	auipc	a0,0x4
    800048f6:	f7e50513          	addi	a0,a0,-130 # 80008870 <syscalls+0x240>
    800048fa:	ffffc097          	auipc	ra,0xffffc
    800048fe:	c30080e7          	jalr	-976(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    80004902:	00004517          	auipc	a0,0x4
    80004906:	f8650513          	addi	a0,a0,-122 # 80008888 <syscalls+0x258>
    8000490a:	ffffc097          	auipc	ra,0xffffc
    8000490e:	c20080e7          	jalr	-992(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80004912:	00878713          	addi	a4,a5,8
    80004916:	00271693          	slli	a3,a4,0x2
    8000491a:	0001d717          	auipc	a4,0x1d
    8000491e:	16e70713          	addi	a4,a4,366 # 80021a88 <log>
    80004922:	9736                	add	a4,a4,a3
    80004924:	44d4                	lw	a3,12(s1)
    80004926:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004928:	faf608e3          	beq	a2,a5,800048d8 <log_write+0x76>
  }
  release(&log.lock);
    8000492c:	0001d517          	auipc	a0,0x1d
    80004930:	15c50513          	addi	a0,a0,348 # 80021a88 <log>
    80004934:	ffffc097          	auipc	ra,0xffffc
    80004938:	342080e7          	jalr	834(ra) # 80000c76 <release>
}
    8000493c:	60e2                	ld	ra,24(sp)
    8000493e:	6442                	ld	s0,16(sp)
    80004940:	64a2                	ld	s1,8(sp)
    80004942:	6902                	ld	s2,0(sp)
    80004944:	6105                	addi	sp,sp,32
    80004946:	8082                	ret

0000000080004948 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004948:	1101                	addi	sp,sp,-32
    8000494a:	ec06                	sd	ra,24(sp)
    8000494c:	e822                	sd	s0,16(sp)
    8000494e:	e426                	sd	s1,8(sp)
    80004950:	e04a                	sd	s2,0(sp)
    80004952:	1000                	addi	s0,sp,32
    80004954:	84aa                	mv	s1,a0
    80004956:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004958:	00004597          	auipc	a1,0x4
    8000495c:	f5058593          	addi	a1,a1,-176 # 800088a8 <syscalls+0x278>
    80004960:	0521                	addi	a0,a0,8
    80004962:	ffffc097          	auipc	ra,0xffffc
    80004966:	1d0080e7          	jalr	464(ra) # 80000b32 <initlock>
  lk->name = name;
    8000496a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000496e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004972:	0204a423          	sw	zero,40(s1)
}
    80004976:	60e2                	ld	ra,24(sp)
    80004978:	6442                	ld	s0,16(sp)
    8000497a:	64a2                	ld	s1,8(sp)
    8000497c:	6902                	ld	s2,0(sp)
    8000497e:	6105                	addi	sp,sp,32
    80004980:	8082                	ret

0000000080004982 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004982:	1101                	addi	sp,sp,-32
    80004984:	ec06                	sd	ra,24(sp)
    80004986:	e822                	sd	s0,16(sp)
    80004988:	e426                	sd	s1,8(sp)
    8000498a:	e04a                	sd	s2,0(sp)
    8000498c:	1000                	addi	s0,sp,32
    8000498e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004990:	00850913          	addi	s2,a0,8
    80004994:	854a                	mv	a0,s2
    80004996:	ffffc097          	auipc	ra,0xffffc
    8000499a:	22c080e7          	jalr	556(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    8000499e:	409c                	lw	a5,0(s1)
    800049a0:	cb89                	beqz	a5,800049b2 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800049a2:	85ca                	mv	a1,s2
    800049a4:	8526                	mv	a0,s1
    800049a6:	ffffe097          	auipc	ra,0xffffe
    800049aa:	820080e7          	jalr	-2016(ra) # 800021c6 <sleep>
  while (lk->locked) {
    800049ae:	409c                	lw	a5,0(s1)
    800049b0:	fbed                	bnez	a5,800049a2 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800049b2:	4785                	li	a5,1
    800049b4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800049b6:	ffffd097          	auipc	ra,0xffffd
    800049ba:	fe0080e7          	jalr	-32(ra) # 80001996 <myproc>
    800049be:	591c                	lw	a5,48(a0)
    800049c0:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800049c2:	854a                	mv	a0,s2
    800049c4:	ffffc097          	auipc	ra,0xffffc
    800049c8:	2b2080e7          	jalr	690(ra) # 80000c76 <release>
}
    800049cc:	60e2                	ld	ra,24(sp)
    800049ce:	6442                	ld	s0,16(sp)
    800049d0:	64a2                	ld	s1,8(sp)
    800049d2:	6902                	ld	s2,0(sp)
    800049d4:	6105                	addi	sp,sp,32
    800049d6:	8082                	ret

00000000800049d8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800049d8:	1101                	addi	sp,sp,-32
    800049da:	ec06                	sd	ra,24(sp)
    800049dc:	e822                	sd	s0,16(sp)
    800049de:	e426                	sd	s1,8(sp)
    800049e0:	e04a                	sd	s2,0(sp)
    800049e2:	1000                	addi	s0,sp,32
    800049e4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800049e6:	00850913          	addi	s2,a0,8
    800049ea:	854a                	mv	a0,s2
    800049ec:	ffffc097          	auipc	ra,0xffffc
    800049f0:	1d6080e7          	jalr	470(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    800049f4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800049f8:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800049fc:	8526                	mv	a0,s1
    800049fe:	ffffe097          	auipc	ra,0xffffe
    80004a02:	954080e7          	jalr	-1708(ra) # 80002352 <wakeup>
  release(&lk->lk);
    80004a06:	854a                	mv	a0,s2
    80004a08:	ffffc097          	auipc	ra,0xffffc
    80004a0c:	26e080e7          	jalr	622(ra) # 80000c76 <release>
}
    80004a10:	60e2                	ld	ra,24(sp)
    80004a12:	6442                	ld	s0,16(sp)
    80004a14:	64a2                	ld	s1,8(sp)
    80004a16:	6902                	ld	s2,0(sp)
    80004a18:	6105                	addi	sp,sp,32
    80004a1a:	8082                	ret

0000000080004a1c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004a1c:	7179                	addi	sp,sp,-48
    80004a1e:	f406                	sd	ra,40(sp)
    80004a20:	f022                	sd	s0,32(sp)
    80004a22:	ec26                	sd	s1,24(sp)
    80004a24:	e84a                	sd	s2,16(sp)
    80004a26:	e44e                	sd	s3,8(sp)
    80004a28:	1800                	addi	s0,sp,48
    80004a2a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004a2c:	00850913          	addi	s2,a0,8
    80004a30:	854a                	mv	a0,s2
    80004a32:	ffffc097          	auipc	ra,0xffffc
    80004a36:	190080e7          	jalr	400(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a3a:	409c                	lw	a5,0(s1)
    80004a3c:	ef99                	bnez	a5,80004a5a <holdingsleep+0x3e>
    80004a3e:	4481                	li	s1,0
  release(&lk->lk);
    80004a40:	854a                	mv	a0,s2
    80004a42:	ffffc097          	auipc	ra,0xffffc
    80004a46:	234080e7          	jalr	564(ra) # 80000c76 <release>
  return r;
}
    80004a4a:	8526                	mv	a0,s1
    80004a4c:	70a2                	ld	ra,40(sp)
    80004a4e:	7402                	ld	s0,32(sp)
    80004a50:	64e2                	ld	s1,24(sp)
    80004a52:	6942                	ld	s2,16(sp)
    80004a54:	69a2                	ld	s3,8(sp)
    80004a56:	6145                	addi	sp,sp,48
    80004a58:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a5a:	0284a983          	lw	s3,40(s1)
    80004a5e:	ffffd097          	auipc	ra,0xffffd
    80004a62:	f38080e7          	jalr	-200(ra) # 80001996 <myproc>
    80004a66:	5904                	lw	s1,48(a0)
    80004a68:	413484b3          	sub	s1,s1,s3
    80004a6c:	0014b493          	seqz	s1,s1
    80004a70:	bfc1                	j	80004a40 <holdingsleep+0x24>

0000000080004a72 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004a72:	1141                	addi	sp,sp,-16
    80004a74:	e406                	sd	ra,8(sp)
    80004a76:	e022                	sd	s0,0(sp)
    80004a78:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004a7a:	00004597          	auipc	a1,0x4
    80004a7e:	e3e58593          	addi	a1,a1,-450 # 800088b8 <syscalls+0x288>
    80004a82:	0001d517          	auipc	a0,0x1d
    80004a86:	14e50513          	addi	a0,a0,334 # 80021bd0 <ftable>
    80004a8a:	ffffc097          	auipc	ra,0xffffc
    80004a8e:	0a8080e7          	jalr	168(ra) # 80000b32 <initlock>
}
    80004a92:	60a2                	ld	ra,8(sp)
    80004a94:	6402                	ld	s0,0(sp)
    80004a96:	0141                	addi	sp,sp,16
    80004a98:	8082                	ret

0000000080004a9a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004a9a:	1101                	addi	sp,sp,-32
    80004a9c:	ec06                	sd	ra,24(sp)
    80004a9e:	e822                	sd	s0,16(sp)
    80004aa0:	e426                	sd	s1,8(sp)
    80004aa2:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004aa4:	0001d517          	auipc	a0,0x1d
    80004aa8:	12c50513          	addi	a0,a0,300 # 80021bd0 <ftable>
    80004aac:	ffffc097          	auipc	ra,0xffffc
    80004ab0:	116080e7          	jalr	278(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004ab4:	0001d497          	auipc	s1,0x1d
    80004ab8:	13448493          	addi	s1,s1,308 # 80021be8 <ftable+0x18>
    80004abc:	0001e717          	auipc	a4,0x1e
    80004ac0:	0cc70713          	addi	a4,a4,204 # 80022b88 <ftable+0xfb8>
    if(f->ref == 0){
    80004ac4:	40dc                	lw	a5,4(s1)
    80004ac6:	cf99                	beqz	a5,80004ae4 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004ac8:	02848493          	addi	s1,s1,40
    80004acc:	fee49ce3          	bne	s1,a4,80004ac4 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004ad0:	0001d517          	auipc	a0,0x1d
    80004ad4:	10050513          	addi	a0,a0,256 # 80021bd0 <ftable>
    80004ad8:	ffffc097          	auipc	ra,0xffffc
    80004adc:	19e080e7          	jalr	414(ra) # 80000c76 <release>
  return 0;
    80004ae0:	4481                	li	s1,0
    80004ae2:	a819                	j	80004af8 <filealloc+0x5e>
      f->ref = 1;
    80004ae4:	4785                	li	a5,1
    80004ae6:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004ae8:	0001d517          	auipc	a0,0x1d
    80004aec:	0e850513          	addi	a0,a0,232 # 80021bd0 <ftable>
    80004af0:	ffffc097          	auipc	ra,0xffffc
    80004af4:	186080e7          	jalr	390(ra) # 80000c76 <release>
}
    80004af8:	8526                	mv	a0,s1
    80004afa:	60e2                	ld	ra,24(sp)
    80004afc:	6442                	ld	s0,16(sp)
    80004afe:	64a2                	ld	s1,8(sp)
    80004b00:	6105                	addi	sp,sp,32
    80004b02:	8082                	ret

0000000080004b04 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004b04:	1101                	addi	sp,sp,-32
    80004b06:	ec06                	sd	ra,24(sp)
    80004b08:	e822                	sd	s0,16(sp)
    80004b0a:	e426                	sd	s1,8(sp)
    80004b0c:	1000                	addi	s0,sp,32
    80004b0e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004b10:	0001d517          	auipc	a0,0x1d
    80004b14:	0c050513          	addi	a0,a0,192 # 80021bd0 <ftable>
    80004b18:	ffffc097          	auipc	ra,0xffffc
    80004b1c:	0aa080e7          	jalr	170(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004b20:	40dc                	lw	a5,4(s1)
    80004b22:	02f05263          	blez	a5,80004b46 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004b26:	2785                	addiw	a5,a5,1
    80004b28:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004b2a:	0001d517          	auipc	a0,0x1d
    80004b2e:	0a650513          	addi	a0,a0,166 # 80021bd0 <ftable>
    80004b32:	ffffc097          	auipc	ra,0xffffc
    80004b36:	144080e7          	jalr	324(ra) # 80000c76 <release>
  return f;
}
    80004b3a:	8526                	mv	a0,s1
    80004b3c:	60e2                	ld	ra,24(sp)
    80004b3e:	6442                	ld	s0,16(sp)
    80004b40:	64a2                	ld	s1,8(sp)
    80004b42:	6105                	addi	sp,sp,32
    80004b44:	8082                	ret
    panic("filedup");
    80004b46:	00004517          	auipc	a0,0x4
    80004b4a:	d7a50513          	addi	a0,a0,-646 # 800088c0 <syscalls+0x290>
    80004b4e:	ffffc097          	auipc	ra,0xffffc
    80004b52:	9dc080e7          	jalr	-1572(ra) # 8000052a <panic>

0000000080004b56 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004b56:	7139                	addi	sp,sp,-64
    80004b58:	fc06                	sd	ra,56(sp)
    80004b5a:	f822                	sd	s0,48(sp)
    80004b5c:	f426                	sd	s1,40(sp)
    80004b5e:	f04a                	sd	s2,32(sp)
    80004b60:	ec4e                	sd	s3,24(sp)
    80004b62:	e852                	sd	s4,16(sp)
    80004b64:	e456                	sd	s5,8(sp)
    80004b66:	0080                	addi	s0,sp,64
    80004b68:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004b6a:	0001d517          	auipc	a0,0x1d
    80004b6e:	06650513          	addi	a0,a0,102 # 80021bd0 <ftable>
    80004b72:	ffffc097          	auipc	ra,0xffffc
    80004b76:	050080e7          	jalr	80(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004b7a:	40dc                	lw	a5,4(s1)
    80004b7c:	06f05163          	blez	a5,80004bde <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004b80:	37fd                	addiw	a5,a5,-1
    80004b82:	0007871b          	sext.w	a4,a5
    80004b86:	c0dc                	sw	a5,4(s1)
    80004b88:	06e04363          	bgtz	a4,80004bee <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004b8c:	0004a903          	lw	s2,0(s1)
    80004b90:	0094ca83          	lbu	s5,9(s1)
    80004b94:	0104ba03          	ld	s4,16(s1)
    80004b98:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004b9c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004ba0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004ba4:	0001d517          	auipc	a0,0x1d
    80004ba8:	02c50513          	addi	a0,a0,44 # 80021bd0 <ftable>
    80004bac:	ffffc097          	auipc	ra,0xffffc
    80004bb0:	0ca080e7          	jalr	202(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    80004bb4:	4785                	li	a5,1
    80004bb6:	04f90d63          	beq	s2,a5,80004c10 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004bba:	3979                	addiw	s2,s2,-2
    80004bbc:	4785                	li	a5,1
    80004bbe:	0527e063          	bltu	a5,s2,80004bfe <fileclose+0xa8>
    begin_op();
    80004bc2:	00000097          	auipc	ra,0x0
    80004bc6:	ac8080e7          	jalr	-1336(ra) # 8000468a <begin_op>
    iput(ff.ip);
    80004bca:	854e                	mv	a0,s3
    80004bcc:	fffff097          	auipc	ra,0xfffff
    80004bd0:	2a2080e7          	jalr	674(ra) # 80003e6e <iput>
    end_op();
    80004bd4:	00000097          	auipc	ra,0x0
    80004bd8:	b36080e7          	jalr	-1226(ra) # 8000470a <end_op>
    80004bdc:	a00d                	j	80004bfe <fileclose+0xa8>
    panic("fileclose");
    80004bde:	00004517          	auipc	a0,0x4
    80004be2:	cea50513          	addi	a0,a0,-790 # 800088c8 <syscalls+0x298>
    80004be6:	ffffc097          	auipc	ra,0xffffc
    80004bea:	944080e7          	jalr	-1724(ra) # 8000052a <panic>
    release(&ftable.lock);
    80004bee:	0001d517          	auipc	a0,0x1d
    80004bf2:	fe250513          	addi	a0,a0,-30 # 80021bd0 <ftable>
    80004bf6:	ffffc097          	auipc	ra,0xffffc
    80004bfa:	080080e7          	jalr	128(ra) # 80000c76 <release>
  }
}
    80004bfe:	70e2                	ld	ra,56(sp)
    80004c00:	7442                	ld	s0,48(sp)
    80004c02:	74a2                	ld	s1,40(sp)
    80004c04:	7902                	ld	s2,32(sp)
    80004c06:	69e2                	ld	s3,24(sp)
    80004c08:	6a42                	ld	s4,16(sp)
    80004c0a:	6aa2                	ld	s5,8(sp)
    80004c0c:	6121                	addi	sp,sp,64
    80004c0e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004c10:	85d6                	mv	a1,s5
    80004c12:	8552                	mv	a0,s4
    80004c14:	00000097          	auipc	ra,0x0
    80004c18:	34c080e7          	jalr	844(ra) # 80004f60 <pipeclose>
    80004c1c:	b7cd                	j	80004bfe <fileclose+0xa8>

0000000080004c1e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004c1e:	715d                	addi	sp,sp,-80
    80004c20:	e486                	sd	ra,72(sp)
    80004c22:	e0a2                	sd	s0,64(sp)
    80004c24:	fc26                	sd	s1,56(sp)
    80004c26:	f84a                	sd	s2,48(sp)
    80004c28:	f44e                	sd	s3,40(sp)
    80004c2a:	0880                	addi	s0,sp,80
    80004c2c:	84aa                	mv	s1,a0
    80004c2e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004c30:	ffffd097          	auipc	ra,0xffffd
    80004c34:	d66080e7          	jalr	-666(ra) # 80001996 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004c38:	409c                	lw	a5,0(s1)
    80004c3a:	37f9                	addiw	a5,a5,-2
    80004c3c:	4705                	li	a4,1
    80004c3e:	04f76763          	bltu	a4,a5,80004c8c <filestat+0x6e>
    80004c42:	892a                	mv	s2,a0
    ilock(f->ip);
    80004c44:	6c88                	ld	a0,24(s1)
    80004c46:	fffff097          	auipc	ra,0xfffff
    80004c4a:	06e080e7          	jalr	110(ra) # 80003cb4 <ilock>
    stati(f->ip, &st);
    80004c4e:	fb840593          	addi	a1,s0,-72
    80004c52:	6c88                	ld	a0,24(s1)
    80004c54:	fffff097          	auipc	ra,0xfffff
    80004c58:	2ea080e7          	jalr	746(ra) # 80003f3e <stati>
    iunlock(f->ip);
    80004c5c:	6c88                	ld	a0,24(s1)
    80004c5e:	fffff097          	auipc	ra,0xfffff
    80004c62:	118080e7          	jalr	280(ra) # 80003d76 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004c66:	46e1                	li	a3,24
    80004c68:	fb840613          	addi	a2,s0,-72
    80004c6c:	85ce                	mv	a1,s3
    80004c6e:	07093503          	ld	a0,112(s2)
    80004c72:	ffffd097          	auipc	ra,0xffffd
    80004c76:	9cc080e7          	jalr	-1588(ra) # 8000163e <copyout>
    80004c7a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004c7e:	60a6                	ld	ra,72(sp)
    80004c80:	6406                	ld	s0,64(sp)
    80004c82:	74e2                	ld	s1,56(sp)
    80004c84:	7942                	ld	s2,48(sp)
    80004c86:	79a2                	ld	s3,40(sp)
    80004c88:	6161                	addi	sp,sp,80
    80004c8a:	8082                	ret
  return -1;
    80004c8c:	557d                	li	a0,-1
    80004c8e:	bfc5                	j	80004c7e <filestat+0x60>

0000000080004c90 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004c90:	7179                	addi	sp,sp,-48
    80004c92:	f406                	sd	ra,40(sp)
    80004c94:	f022                	sd	s0,32(sp)
    80004c96:	ec26                	sd	s1,24(sp)
    80004c98:	e84a                	sd	s2,16(sp)
    80004c9a:	e44e                	sd	s3,8(sp)
    80004c9c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004c9e:	00854783          	lbu	a5,8(a0)
    80004ca2:	c3d5                	beqz	a5,80004d46 <fileread+0xb6>
    80004ca4:	84aa                	mv	s1,a0
    80004ca6:	89ae                	mv	s3,a1
    80004ca8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004caa:	411c                	lw	a5,0(a0)
    80004cac:	4705                	li	a4,1
    80004cae:	04e78963          	beq	a5,a4,80004d00 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004cb2:	470d                	li	a4,3
    80004cb4:	04e78d63          	beq	a5,a4,80004d0e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004cb8:	4709                	li	a4,2
    80004cba:	06e79e63          	bne	a5,a4,80004d36 <fileread+0xa6>
    ilock(f->ip);
    80004cbe:	6d08                	ld	a0,24(a0)
    80004cc0:	fffff097          	auipc	ra,0xfffff
    80004cc4:	ff4080e7          	jalr	-12(ra) # 80003cb4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004cc8:	874a                	mv	a4,s2
    80004cca:	5094                	lw	a3,32(s1)
    80004ccc:	864e                	mv	a2,s3
    80004cce:	4585                	li	a1,1
    80004cd0:	6c88                	ld	a0,24(s1)
    80004cd2:	fffff097          	auipc	ra,0xfffff
    80004cd6:	296080e7          	jalr	662(ra) # 80003f68 <readi>
    80004cda:	892a                	mv	s2,a0
    80004cdc:	00a05563          	blez	a0,80004ce6 <fileread+0x56>
      f->off += r;
    80004ce0:	509c                	lw	a5,32(s1)
    80004ce2:	9fa9                	addw	a5,a5,a0
    80004ce4:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004ce6:	6c88                	ld	a0,24(s1)
    80004ce8:	fffff097          	auipc	ra,0xfffff
    80004cec:	08e080e7          	jalr	142(ra) # 80003d76 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004cf0:	854a                	mv	a0,s2
    80004cf2:	70a2                	ld	ra,40(sp)
    80004cf4:	7402                	ld	s0,32(sp)
    80004cf6:	64e2                	ld	s1,24(sp)
    80004cf8:	6942                	ld	s2,16(sp)
    80004cfa:	69a2                	ld	s3,8(sp)
    80004cfc:	6145                	addi	sp,sp,48
    80004cfe:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004d00:	6908                	ld	a0,16(a0)
    80004d02:	00000097          	auipc	ra,0x0
    80004d06:	3c0080e7          	jalr	960(ra) # 800050c2 <piperead>
    80004d0a:	892a                	mv	s2,a0
    80004d0c:	b7d5                	j	80004cf0 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004d0e:	02451783          	lh	a5,36(a0)
    80004d12:	03079693          	slli	a3,a5,0x30
    80004d16:	92c1                	srli	a3,a3,0x30
    80004d18:	4725                	li	a4,9
    80004d1a:	02d76863          	bltu	a4,a3,80004d4a <fileread+0xba>
    80004d1e:	0792                	slli	a5,a5,0x4
    80004d20:	0001d717          	auipc	a4,0x1d
    80004d24:	e1070713          	addi	a4,a4,-496 # 80021b30 <devsw>
    80004d28:	97ba                	add	a5,a5,a4
    80004d2a:	639c                	ld	a5,0(a5)
    80004d2c:	c38d                	beqz	a5,80004d4e <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004d2e:	4505                	li	a0,1
    80004d30:	9782                	jalr	a5
    80004d32:	892a                	mv	s2,a0
    80004d34:	bf75                	j	80004cf0 <fileread+0x60>
    panic("fileread");
    80004d36:	00004517          	auipc	a0,0x4
    80004d3a:	ba250513          	addi	a0,a0,-1118 # 800088d8 <syscalls+0x2a8>
    80004d3e:	ffffb097          	auipc	ra,0xffffb
    80004d42:	7ec080e7          	jalr	2028(ra) # 8000052a <panic>
    return -1;
    80004d46:	597d                	li	s2,-1
    80004d48:	b765                	j	80004cf0 <fileread+0x60>
      return -1;
    80004d4a:	597d                	li	s2,-1
    80004d4c:	b755                	j	80004cf0 <fileread+0x60>
    80004d4e:	597d                	li	s2,-1
    80004d50:	b745                	j	80004cf0 <fileread+0x60>

0000000080004d52 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004d52:	715d                	addi	sp,sp,-80
    80004d54:	e486                	sd	ra,72(sp)
    80004d56:	e0a2                	sd	s0,64(sp)
    80004d58:	fc26                	sd	s1,56(sp)
    80004d5a:	f84a                	sd	s2,48(sp)
    80004d5c:	f44e                	sd	s3,40(sp)
    80004d5e:	f052                	sd	s4,32(sp)
    80004d60:	ec56                	sd	s5,24(sp)
    80004d62:	e85a                	sd	s6,16(sp)
    80004d64:	e45e                	sd	s7,8(sp)
    80004d66:	e062                	sd	s8,0(sp)
    80004d68:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004d6a:	00954783          	lbu	a5,9(a0)
    80004d6e:	10078663          	beqz	a5,80004e7a <filewrite+0x128>
    80004d72:	892a                	mv	s2,a0
    80004d74:	8aae                	mv	s5,a1
    80004d76:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d78:	411c                	lw	a5,0(a0)
    80004d7a:	4705                	li	a4,1
    80004d7c:	02e78263          	beq	a5,a4,80004da0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d80:	470d                	li	a4,3
    80004d82:	02e78663          	beq	a5,a4,80004dae <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d86:	4709                	li	a4,2
    80004d88:	0ee79163          	bne	a5,a4,80004e6a <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004d8c:	0ac05d63          	blez	a2,80004e46 <filewrite+0xf4>
    int i = 0;
    80004d90:	4981                	li	s3,0
    80004d92:	6b05                	lui	s6,0x1
    80004d94:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004d98:	6b85                	lui	s7,0x1
    80004d9a:	c00b8b9b          	addiw	s7,s7,-1024
    80004d9e:	a861                	j	80004e36 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004da0:	6908                	ld	a0,16(a0)
    80004da2:	00000097          	auipc	ra,0x0
    80004da6:	22e080e7          	jalr	558(ra) # 80004fd0 <pipewrite>
    80004daa:	8a2a                	mv	s4,a0
    80004dac:	a045                	j	80004e4c <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004dae:	02451783          	lh	a5,36(a0)
    80004db2:	03079693          	slli	a3,a5,0x30
    80004db6:	92c1                	srli	a3,a3,0x30
    80004db8:	4725                	li	a4,9
    80004dba:	0cd76263          	bltu	a4,a3,80004e7e <filewrite+0x12c>
    80004dbe:	0792                	slli	a5,a5,0x4
    80004dc0:	0001d717          	auipc	a4,0x1d
    80004dc4:	d7070713          	addi	a4,a4,-656 # 80021b30 <devsw>
    80004dc8:	97ba                	add	a5,a5,a4
    80004dca:	679c                	ld	a5,8(a5)
    80004dcc:	cbdd                	beqz	a5,80004e82 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004dce:	4505                	li	a0,1
    80004dd0:	9782                	jalr	a5
    80004dd2:	8a2a                	mv	s4,a0
    80004dd4:	a8a5                	j	80004e4c <filewrite+0xfa>
    80004dd6:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004dda:	00000097          	auipc	ra,0x0
    80004dde:	8b0080e7          	jalr	-1872(ra) # 8000468a <begin_op>
      ilock(f->ip);
    80004de2:	01893503          	ld	a0,24(s2)
    80004de6:	fffff097          	auipc	ra,0xfffff
    80004dea:	ece080e7          	jalr	-306(ra) # 80003cb4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004dee:	8762                	mv	a4,s8
    80004df0:	02092683          	lw	a3,32(s2)
    80004df4:	01598633          	add	a2,s3,s5
    80004df8:	4585                	li	a1,1
    80004dfa:	01893503          	ld	a0,24(s2)
    80004dfe:	fffff097          	auipc	ra,0xfffff
    80004e02:	262080e7          	jalr	610(ra) # 80004060 <writei>
    80004e06:	84aa                	mv	s1,a0
    80004e08:	00a05763          	blez	a0,80004e16 <filewrite+0xc4>
        f->off += r;
    80004e0c:	02092783          	lw	a5,32(s2)
    80004e10:	9fa9                	addw	a5,a5,a0
    80004e12:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004e16:	01893503          	ld	a0,24(s2)
    80004e1a:	fffff097          	auipc	ra,0xfffff
    80004e1e:	f5c080e7          	jalr	-164(ra) # 80003d76 <iunlock>
      end_op();
    80004e22:	00000097          	auipc	ra,0x0
    80004e26:	8e8080e7          	jalr	-1816(ra) # 8000470a <end_op>

      if(r != n1){
    80004e2a:	009c1f63          	bne	s8,s1,80004e48 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004e2e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004e32:	0149db63          	bge	s3,s4,80004e48 <filewrite+0xf6>
      int n1 = n - i;
    80004e36:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004e3a:	84be                	mv	s1,a5
    80004e3c:	2781                	sext.w	a5,a5
    80004e3e:	f8fb5ce3          	bge	s6,a5,80004dd6 <filewrite+0x84>
    80004e42:	84de                	mv	s1,s7
    80004e44:	bf49                	j	80004dd6 <filewrite+0x84>
    int i = 0;
    80004e46:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004e48:	013a1f63          	bne	s4,s3,80004e66 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004e4c:	8552                	mv	a0,s4
    80004e4e:	60a6                	ld	ra,72(sp)
    80004e50:	6406                	ld	s0,64(sp)
    80004e52:	74e2                	ld	s1,56(sp)
    80004e54:	7942                	ld	s2,48(sp)
    80004e56:	79a2                	ld	s3,40(sp)
    80004e58:	7a02                	ld	s4,32(sp)
    80004e5a:	6ae2                	ld	s5,24(sp)
    80004e5c:	6b42                	ld	s6,16(sp)
    80004e5e:	6ba2                	ld	s7,8(sp)
    80004e60:	6c02                	ld	s8,0(sp)
    80004e62:	6161                	addi	sp,sp,80
    80004e64:	8082                	ret
    ret = (i == n ? n : -1);
    80004e66:	5a7d                	li	s4,-1
    80004e68:	b7d5                	j	80004e4c <filewrite+0xfa>
    panic("filewrite");
    80004e6a:	00004517          	auipc	a0,0x4
    80004e6e:	a7e50513          	addi	a0,a0,-1410 # 800088e8 <syscalls+0x2b8>
    80004e72:	ffffb097          	auipc	ra,0xffffb
    80004e76:	6b8080e7          	jalr	1720(ra) # 8000052a <panic>
    return -1;
    80004e7a:	5a7d                	li	s4,-1
    80004e7c:	bfc1                	j	80004e4c <filewrite+0xfa>
      return -1;
    80004e7e:	5a7d                	li	s4,-1
    80004e80:	b7f1                	j	80004e4c <filewrite+0xfa>
    80004e82:	5a7d                	li	s4,-1
    80004e84:	b7e1                	j	80004e4c <filewrite+0xfa>

0000000080004e86 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004e86:	7179                	addi	sp,sp,-48
    80004e88:	f406                	sd	ra,40(sp)
    80004e8a:	f022                	sd	s0,32(sp)
    80004e8c:	ec26                	sd	s1,24(sp)
    80004e8e:	e84a                	sd	s2,16(sp)
    80004e90:	e44e                	sd	s3,8(sp)
    80004e92:	e052                	sd	s4,0(sp)
    80004e94:	1800                	addi	s0,sp,48
    80004e96:	84aa                	mv	s1,a0
    80004e98:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004e9a:	0005b023          	sd	zero,0(a1)
    80004e9e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004ea2:	00000097          	auipc	ra,0x0
    80004ea6:	bf8080e7          	jalr	-1032(ra) # 80004a9a <filealloc>
    80004eaa:	e088                	sd	a0,0(s1)
    80004eac:	c551                	beqz	a0,80004f38 <pipealloc+0xb2>
    80004eae:	00000097          	auipc	ra,0x0
    80004eb2:	bec080e7          	jalr	-1044(ra) # 80004a9a <filealloc>
    80004eb6:	00aa3023          	sd	a0,0(s4)
    80004eba:	c92d                	beqz	a0,80004f2c <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004ebc:	ffffc097          	auipc	ra,0xffffc
    80004ec0:	c16080e7          	jalr	-1002(ra) # 80000ad2 <kalloc>
    80004ec4:	892a                	mv	s2,a0
    80004ec6:	c125                	beqz	a0,80004f26 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004ec8:	4985                	li	s3,1
    80004eca:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004ece:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004ed2:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004ed6:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004eda:	00003597          	auipc	a1,0x3
    80004ede:	69e58593          	addi	a1,a1,1694 # 80008578 <states.0+0x1b8>
    80004ee2:	ffffc097          	auipc	ra,0xffffc
    80004ee6:	c50080e7          	jalr	-944(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    80004eea:	609c                	ld	a5,0(s1)
    80004eec:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004ef0:	609c                	ld	a5,0(s1)
    80004ef2:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004ef6:	609c                	ld	a5,0(s1)
    80004ef8:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004efc:	609c                	ld	a5,0(s1)
    80004efe:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004f02:	000a3783          	ld	a5,0(s4)
    80004f06:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004f0a:	000a3783          	ld	a5,0(s4)
    80004f0e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004f12:	000a3783          	ld	a5,0(s4)
    80004f16:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004f1a:	000a3783          	ld	a5,0(s4)
    80004f1e:	0127b823          	sd	s2,16(a5)
  return 0;
    80004f22:	4501                	li	a0,0
    80004f24:	a025                	j	80004f4c <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004f26:	6088                	ld	a0,0(s1)
    80004f28:	e501                	bnez	a0,80004f30 <pipealloc+0xaa>
    80004f2a:	a039                	j	80004f38 <pipealloc+0xb2>
    80004f2c:	6088                	ld	a0,0(s1)
    80004f2e:	c51d                	beqz	a0,80004f5c <pipealloc+0xd6>
    fileclose(*f0);
    80004f30:	00000097          	auipc	ra,0x0
    80004f34:	c26080e7          	jalr	-986(ra) # 80004b56 <fileclose>
  if(*f1)
    80004f38:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004f3c:	557d                	li	a0,-1
  if(*f1)
    80004f3e:	c799                	beqz	a5,80004f4c <pipealloc+0xc6>
    fileclose(*f1);
    80004f40:	853e                	mv	a0,a5
    80004f42:	00000097          	auipc	ra,0x0
    80004f46:	c14080e7          	jalr	-1004(ra) # 80004b56 <fileclose>
  return -1;
    80004f4a:	557d                	li	a0,-1
}
    80004f4c:	70a2                	ld	ra,40(sp)
    80004f4e:	7402                	ld	s0,32(sp)
    80004f50:	64e2                	ld	s1,24(sp)
    80004f52:	6942                	ld	s2,16(sp)
    80004f54:	69a2                	ld	s3,8(sp)
    80004f56:	6a02                	ld	s4,0(sp)
    80004f58:	6145                	addi	sp,sp,48
    80004f5a:	8082                	ret
  return -1;
    80004f5c:	557d                	li	a0,-1
    80004f5e:	b7fd                	j	80004f4c <pipealloc+0xc6>

0000000080004f60 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004f60:	1101                	addi	sp,sp,-32
    80004f62:	ec06                	sd	ra,24(sp)
    80004f64:	e822                	sd	s0,16(sp)
    80004f66:	e426                	sd	s1,8(sp)
    80004f68:	e04a                	sd	s2,0(sp)
    80004f6a:	1000                	addi	s0,sp,32
    80004f6c:	84aa                	mv	s1,a0
    80004f6e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004f70:	ffffc097          	auipc	ra,0xffffc
    80004f74:	c52080e7          	jalr	-942(ra) # 80000bc2 <acquire>
  if(writable){
    80004f78:	02090d63          	beqz	s2,80004fb2 <pipeclose+0x52>
    pi->writeopen = 0;
    80004f7c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004f80:	21848513          	addi	a0,s1,536
    80004f84:	ffffd097          	auipc	ra,0xffffd
    80004f88:	3ce080e7          	jalr	974(ra) # 80002352 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004f8c:	2204b783          	ld	a5,544(s1)
    80004f90:	eb95                	bnez	a5,80004fc4 <pipeclose+0x64>
    release(&pi->lock);
    80004f92:	8526                	mv	a0,s1
    80004f94:	ffffc097          	auipc	ra,0xffffc
    80004f98:	ce2080e7          	jalr	-798(ra) # 80000c76 <release>
    kfree((char*)pi);
    80004f9c:	8526                	mv	a0,s1
    80004f9e:	ffffc097          	auipc	ra,0xffffc
    80004fa2:	a38080e7          	jalr	-1480(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    80004fa6:	60e2                	ld	ra,24(sp)
    80004fa8:	6442                	ld	s0,16(sp)
    80004faa:	64a2                	ld	s1,8(sp)
    80004fac:	6902                	ld	s2,0(sp)
    80004fae:	6105                	addi	sp,sp,32
    80004fb0:	8082                	ret
    pi->readopen = 0;
    80004fb2:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004fb6:	21c48513          	addi	a0,s1,540
    80004fba:	ffffd097          	auipc	ra,0xffffd
    80004fbe:	398080e7          	jalr	920(ra) # 80002352 <wakeup>
    80004fc2:	b7e9                	j	80004f8c <pipeclose+0x2c>
    release(&pi->lock);
    80004fc4:	8526                	mv	a0,s1
    80004fc6:	ffffc097          	auipc	ra,0xffffc
    80004fca:	cb0080e7          	jalr	-848(ra) # 80000c76 <release>
}
    80004fce:	bfe1                	j	80004fa6 <pipeclose+0x46>

0000000080004fd0 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004fd0:	711d                	addi	sp,sp,-96
    80004fd2:	ec86                	sd	ra,88(sp)
    80004fd4:	e8a2                	sd	s0,80(sp)
    80004fd6:	e4a6                	sd	s1,72(sp)
    80004fd8:	e0ca                	sd	s2,64(sp)
    80004fda:	fc4e                	sd	s3,56(sp)
    80004fdc:	f852                	sd	s4,48(sp)
    80004fde:	f456                	sd	s5,40(sp)
    80004fe0:	f05a                	sd	s6,32(sp)
    80004fe2:	ec5e                	sd	s7,24(sp)
    80004fe4:	e862                	sd	s8,16(sp)
    80004fe6:	1080                	addi	s0,sp,96
    80004fe8:	84aa                	mv	s1,a0
    80004fea:	8aae                	mv	s5,a1
    80004fec:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004fee:	ffffd097          	auipc	ra,0xffffd
    80004ff2:	9a8080e7          	jalr	-1624(ra) # 80001996 <myproc>
    80004ff6:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004ff8:	8526                	mv	a0,s1
    80004ffa:	ffffc097          	auipc	ra,0xffffc
    80004ffe:	bc8080e7          	jalr	-1080(ra) # 80000bc2 <acquire>
  while(i < n){
    80005002:	0b405363          	blez	s4,800050a8 <pipewrite+0xd8>
  int i = 0;
    80005006:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005008:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000500a:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000500e:	21c48b93          	addi	s7,s1,540
    80005012:	a089                	j	80005054 <pipewrite+0x84>
      release(&pi->lock);
    80005014:	8526                	mv	a0,s1
    80005016:	ffffc097          	auipc	ra,0xffffc
    8000501a:	c60080e7          	jalr	-928(ra) # 80000c76 <release>
      return -1;
    8000501e:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005020:	854a                	mv	a0,s2
    80005022:	60e6                	ld	ra,88(sp)
    80005024:	6446                	ld	s0,80(sp)
    80005026:	64a6                	ld	s1,72(sp)
    80005028:	6906                	ld	s2,64(sp)
    8000502a:	79e2                	ld	s3,56(sp)
    8000502c:	7a42                	ld	s4,48(sp)
    8000502e:	7aa2                	ld	s5,40(sp)
    80005030:	7b02                	ld	s6,32(sp)
    80005032:	6be2                	ld	s7,24(sp)
    80005034:	6c42                	ld	s8,16(sp)
    80005036:	6125                	addi	sp,sp,96
    80005038:	8082                	ret
      wakeup(&pi->nread);
    8000503a:	8562                	mv	a0,s8
    8000503c:	ffffd097          	auipc	ra,0xffffd
    80005040:	316080e7          	jalr	790(ra) # 80002352 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005044:	85a6                	mv	a1,s1
    80005046:	855e                	mv	a0,s7
    80005048:	ffffd097          	auipc	ra,0xffffd
    8000504c:	17e080e7          	jalr	382(ra) # 800021c6 <sleep>
  while(i < n){
    80005050:	05495d63          	bge	s2,s4,800050aa <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80005054:	2204a783          	lw	a5,544(s1)
    80005058:	dfd5                	beqz	a5,80005014 <pipewrite+0x44>
    8000505a:	0289a783          	lw	a5,40(s3)
    8000505e:	fbdd                	bnez	a5,80005014 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005060:	2184a783          	lw	a5,536(s1)
    80005064:	21c4a703          	lw	a4,540(s1)
    80005068:	2007879b          	addiw	a5,a5,512
    8000506c:	fcf707e3          	beq	a4,a5,8000503a <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005070:	4685                	li	a3,1
    80005072:	01590633          	add	a2,s2,s5
    80005076:	faf40593          	addi	a1,s0,-81
    8000507a:	0709b503          	ld	a0,112(s3)
    8000507e:	ffffc097          	auipc	ra,0xffffc
    80005082:	64c080e7          	jalr	1612(ra) # 800016ca <copyin>
    80005086:	03650263          	beq	a0,s6,800050aa <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000508a:	21c4a783          	lw	a5,540(s1)
    8000508e:	0017871b          	addiw	a4,a5,1
    80005092:	20e4ae23          	sw	a4,540(s1)
    80005096:	1ff7f793          	andi	a5,a5,511
    8000509a:	97a6                	add	a5,a5,s1
    8000509c:	faf44703          	lbu	a4,-81(s0)
    800050a0:	00e78c23          	sb	a4,24(a5)
      i++;
    800050a4:	2905                	addiw	s2,s2,1
    800050a6:	b76d                	j	80005050 <pipewrite+0x80>
  int i = 0;
    800050a8:	4901                	li	s2,0
  wakeup(&pi->nread);
    800050aa:	21848513          	addi	a0,s1,536
    800050ae:	ffffd097          	auipc	ra,0xffffd
    800050b2:	2a4080e7          	jalr	676(ra) # 80002352 <wakeup>
  release(&pi->lock);
    800050b6:	8526                	mv	a0,s1
    800050b8:	ffffc097          	auipc	ra,0xffffc
    800050bc:	bbe080e7          	jalr	-1090(ra) # 80000c76 <release>
  return i;
    800050c0:	b785                	j	80005020 <pipewrite+0x50>

00000000800050c2 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800050c2:	715d                	addi	sp,sp,-80
    800050c4:	e486                	sd	ra,72(sp)
    800050c6:	e0a2                	sd	s0,64(sp)
    800050c8:	fc26                	sd	s1,56(sp)
    800050ca:	f84a                	sd	s2,48(sp)
    800050cc:	f44e                	sd	s3,40(sp)
    800050ce:	f052                	sd	s4,32(sp)
    800050d0:	ec56                	sd	s5,24(sp)
    800050d2:	e85a                	sd	s6,16(sp)
    800050d4:	0880                	addi	s0,sp,80
    800050d6:	84aa                	mv	s1,a0
    800050d8:	892e                	mv	s2,a1
    800050da:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800050dc:	ffffd097          	auipc	ra,0xffffd
    800050e0:	8ba080e7          	jalr	-1862(ra) # 80001996 <myproc>
    800050e4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800050e6:	8526                	mv	a0,s1
    800050e8:	ffffc097          	auipc	ra,0xffffc
    800050ec:	ada080e7          	jalr	-1318(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050f0:	2184a703          	lw	a4,536(s1)
    800050f4:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800050f8:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050fc:	02f71463          	bne	a4,a5,80005124 <piperead+0x62>
    80005100:	2244a783          	lw	a5,548(s1)
    80005104:	c385                	beqz	a5,80005124 <piperead+0x62>
    if(pr->killed){
    80005106:	028a2783          	lw	a5,40(s4)
    8000510a:	ebc1                	bnez	a5,8000519a <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000510c:	85a6                	mv	a1,s1
    8000510e:	854e                	mv	a0,s3
    80005110:	ffffd097          	auipc	ra,0xffffd
    80005114:	0b6080e7          	jalr	182(ra) # 800021c6 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005118:	2184a703          	lw	a4,536(s1)
    8000511c:	21c4a783          	lw	a5,540(s1)
    80005120:	fef700e3          	beq	a4,a5,80005100 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005124:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005126:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005128:	05505363          	blez	s5,8000516e <piperead+0xac>
    if(pi->nread == pi->nwrite)
    8000512c:	2184a783          	lw	a5,536(s1)
    80005130:	21c4a703          	lw	a4,540(s1)
    80005134:	02f70d63          	beq	a4,a5,8000516e <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005138:	0017871b          	addiw	a4,a5,1
    8000513c:	20e4ac23          	sw	a4,536(s1)
    80005140:	1ff7f793          	andi	a5,a5,511
    80005144:	97a6                	add	a5,a5,s1
    80005146:	0187c783          	lbu	a5,24(a5)
    8000514a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000514e:	4685                	li	a3,1
    80005150:	fbf40613          	addi	a2,s0,-65
    80005154:	85ca                	mv	a1,s2
    80005156:	070a3503          	ld	a0,112(s4)
    8000515a:	ffffc097          	auipc	ra,0xffffc
    8000515e:	4e4080e7          	jalr	1252(ra) # 8000163e <copyout>
    80005162:	01650663          	beq	a0,s6,8000516e <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005166:	2985                	addiw	s3,s3,1
    80005168:	0905                	addi	s2,s2,1
    8000516a:	fd3a91e3          	bne	s5,s3,8000512c <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000516e:	21c48513          	addi	a0,s1,540
    80005172:	ffffd097          	auipc	ra,0xffffd
    80005176:	1e0080e7          	jalr	480(ra) # 80002352 <wakeup>
  release(&pi->lock);
    8000517a:	8526                	mv	a0,s1
    8000517c:	ffffc097          	auipc	ra,0xffffc
    80005180:	afa080e7          	jalr	-1286(ra) # 80000c76 <release>
  return i;
}
    80005184:	854e                	mv	a0,s3
    80005186:	60a6                	ld	ra,72(sp)
    80005188:	6406                	ld	s0,64(sp)
    8000518a:	74e2                	ld	s1,56(sp)
    8000518c:	7942                	ld	s2,48(sp)
    8000518e:	79a2                	ld	s3,40(sp)
    80005190:	7a02                	ld	s4,32(sp)
    80005192:	6ae2                	ld	s5,24(sp)
    80005194:	6b42                	ld	s6,16(sp)
    80005196:	6161                	addi	sp,sp,80
    80005198:	8082                	ret
      release(&pi->lock);
    8000519a:	8526                	mv	a0,s1
    8000519c:	ffffc097          	auipc	ra,0xffffc
    800051a0:	ada080e7          	jalr	-1318(ra) # 80000c76 <release>
      return -1;
    800051a4:	59fd                	li	s3,-1
    800051a6:	bff9                	j	80005184 <piperead+0xc2>

00000000800051a8 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    800051a8:	de010113          	addi	sp,sp,-544
    800051ac:	20113c23          	sd	ra,536(sp)
    800051b0:	20813823          	sd	s0,528(sp)
    800051b4:	20913423          	sd	s1,520(sp)
    800051b8:	21213023          	sd	s2,512(sp)
    800051bc:	ffce                	sd	s3,504(sp)
    800051be:	fbd2                	sd	s4,496(sp)
    800051c0:	f7d6                	sd	s5,488(sp)
    800051c2:	f3da                	sd	s6,480(sp)
    800051c4:	efde                	sd	s7,472(sp)
    800051c6:	ebe2                	sd	s8,464(sp)
    800051c8:	e7e6                	sd	s9,456(sp)
    800051ca:	e3ea                	sd	s10,448(sp)
    800051cc:	ff6e                	sd	s11,440(sp)
    800051ce:	1400                	addi	s0,sp,544
    800051d0:	892a                	mv	s2,a0
    800051d2:	dea43423          	sd	a0,-536(s0)
    800051d6:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800051da:	ffffc097          	auipc	ra,0xffffc
    800051de:	7bc080e7          	jalr	1980(ra) # 80001996 <myproc>
    800051e2:	84aa                	mv	s1,a0

  begin_op();
    800051e4:	fffff097          	auipc	ra,0xfffff
    800051e8:	4a6080e7          	jalr	1190(ra) # 8000468a <begin_op>

  if((ip = namei(path)) == 0){
    800051ec:	854a                	mv	a0,s2
    800051ee:	fffff097          	auipc	ra,0xfffff
    800051f2:	27c080e7          	jalr	636(ra) # 8000446a <namei>
    800051f6:	c93d                	beqz	a0,8000526c <exec+0xc4>
    800051f8:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800051fa:	fffff097          	auipc	ra,0xfffff
    800051fe:	aba080e7          	jalr	-1350(ra) # 80003cb4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005202:	04000713          	li	a4,64
    80005206:	4681                	li	a3,0
    80005208:	e4840613          	addi	a2,s0,-440
    8000520c:	4581                	li	a1,0
    8000520e:	8556                	mv	a0,s5
    80005210:	fffff097          	auipc	ra,0xfffff
    80005214:	d58080e7          	jalr	-680(ra) # 80003f68 <readi>
    80005218:	04000793          	li	a5,64
    8000521c:	00f51a63          	bne	a0,a5,80005230 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005220:	e4842703          	lw	a4,-440(s0)
    80005224:	464c47b7          	lui	a5,0x464c4
    80005228:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000522c:	04f70663          	beq	a4,a5,80005278 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005230:	8556                	mv	a0,s5
    80005232:	fffff097          	auipc	ra,0xfffff
    80005236:	ce4080e7          	jalr	-796(ra) # 80003f16 <iunlockput>
    end_op();
    8000523a:	fffff097          	auipc	ra,0xfffff
    8000523e:	4d0080e7          	jalr	1232(ra) # 8000470a <end_op>
  }
  return -1;
    80005242:	557d                	li	a0,-1
}
    80005244:	21813083          	ld	ra,536(sp)
    80005248:	21013403          	ld	s0,528(sp)
    8000524c:	20813483          	ld	s1,520(sp)
    80005250:	20013903          	ld	s2,512(sp)
    80005254:	79fe                	ld	s3,504(sp)
    80005256:	7a5e                	ld	s4,496(sp)
    80005258:	7abe                	ld	s5,488(sp)
    8000525a:	7b1e                	ld	s6,480(sp)
    8000525c:	6bfe                	ld	s7,472(sp)
    8000525e:	6c5e                	ld	s8,464(sp)
    80005260:	6cbe                	ld	s9,456(sp)
    80005262:	6d1e                	ld	s10,448(sp)
    80005264:	7dfa                	ld	s11,440(sp)
    80005266:	22010113          	addi	sp,sp,544
    8000526a:	8082                	ret
    end_op();
    8000526c:	fffff097          	auipc	ra,0xfffff
    80005270:	49e080e7          	jalr	1182(ra) # 8000470a <end_op>
    return -1;
    80005274:	557d                	li	a0,-1
    80005276:	b7f9                	j	80005244 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005278:	8526                	mv	a0,s1
    8000527a:	ffffc097          	auipc	ra,0xffffc
    8000527e:	7e0080e7          	jalr	2016(ra) # 80001a5a <proc_pagetable>
    80005282:	8b2a                	mv	s6,a0
    80005284:	d555                	beqz	a0,80005230 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005286:	e6842783          	lw	a5,-408(s0)
    8000528a:	e8045703          	lhu	a4,-384(s0)
    8000528e:	c735                	beqz	a4,800052fa <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005290:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005292:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005296:	6a05                	lui	s4,0x1
    80005298:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000529c:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    800052a0:	6d85                	lui	s11,0x1
    800052a2:	7d7d                	lui	s10,0xfffff
    800052a4:	ac1d                	j	800054da <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800052a6:	00003517          	auipc	a0,0x3
    800052aa:	65250513          	addi	a0,a0,1618 # 800088f8 <syscalls+0x2c8>
    800052ae:	ffffb097          	auipc	ra,0xffffb
    800052b2:	27c080e7          	jalr	636(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800052b6:	874a                	mv	a4,s2
    800052b8:	009c86bb          	addw	a3,s9,s1
    800052bc:	4581                	li	a1,0
    800052be:	8556                	mv	a0,s5
    800052c0:	fffff097          	auipc	ra,0xfffff
    800052c4:	ca8080e7          	jalr	-856(ra) # 80003f68 <readi>
    800052c8:	2501                	sext.w	a0,a0
    800052ca:	1aa91863          	bne	s2,a0,8000547a <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    800052ce:	009d84bb          	addw	s1,s11,s1
    800052d2:	013d09bb          	addw	s3,s10,s3
    800052d6:	1f74f263          	bgeu	s1,s7,800054ba <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    800052da:	02049593          	slli	a1,s1,0x20
    800052de:	9181                	srli	a1,a1,0x20
    800052e0:	95e2                	add	a1,a1,s8
    800052e2:	855a                	mv	a0,s6
    800052e4:	ffffc097          	auipc	ra,0xffffc
    800052e8:	d68080e7          	jalr	-664(ra) # 8000104c <walkaddr>
    800052ec:	862a                	mv	a2,a0
    if(pa == 0)
    800052ee:	dd45                	beqz	a0,800052a6 <exec+0xfe>
      n = PGSIZE;
    800052f0:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800052f2:	fd49f2e3          	bgeu	s3,s4,800052b6 <exec+0x10e>
      n = sz - i;
    800052f6:	894e                	mv	s2,s3
    800052f8:	bf7d                	j	800052b6 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800052fa:	4481                	li	s1,0
  iunlockput(ip);
    800052fc:	8556                	mv	a0,s5
    800052fe:	fffff097          	auipc	ra,0xfffff
    80005302:	c18080e7          	jalr	-1000(ra) # 80003f16 <iunlockput>
  end_op();
    80005306:	fffff097          	auipc	ra,0xfffff
    8000530a:	404080e7          	jalr	1028(ra) # 8000470a <end_op>
  p = myproc();
    8000530e:	ffffc097          	auipc	ra,0xffffc
    80005312:	688080e7          	jalr	1672(ra) # 80001996 <myproc>
    80005316:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005318:	06853d03          	ld	s10,104(a0)
  sz = PGROUNDUP(sz);
    8000531c:	6785                	lui	a5,0x1
    8000531e:	17fd                	addi	a5,a5,-1
    80005320:	94be                	add	s1,s1,a5
    80005322:	77fd                	lui	a5,0xfffff
    80005324:	8fe5                	and	a5,a5,s1
    80005326:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000532a:	6609                	lui	a2,0x2
    8000532c:	963e                	add	a2,a2,a5
    8000532e:	85be                	mv	a1,a5
    80005330:	855a                	mv	a0,s6
    80005332:	ffffc097          	auipc	ra,0xffffc
    80005336:	0bc080e7          	jalr	188(ra) # 800013ee <uvmalloc>
    8000533a:	8c2a                	mv	s8,a0
  ip = 0;
    8000533c:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000533e:	12050e63          	beqz	a0,8000547a <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005342:	75f9                	lui	a1,0xffffe
    80005344:	95aa                	add	a1,a1,a0
    80005346:	855a                	mv	a0,s6
    80005348:	ffffc097          	auipc	ra,0xffffc
    8000534c:	2c4080e7          	jalr	708(ra) # 8000160c <uvmclear>
  stackbase = sp - PGSIZE;
    80005350:	7afd                	lui	s5,0xfffff
    80005352:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005354:	df043783          	ld	a5,-528(s0)
    80005358:	6388                	ld	a0,0(a5)
    8000535a:	c925                	beqz	a0,800053ca <exec+0x222>
    8000535c:	e8840993          	addi	s3,s0,-376
    80005360:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005364:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005366:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005368:	ffffc097          	auipc	ra,0xffffc
    8000536c:	ada080e7          	jalr	-1318(ra) # 80000e42 <strlen>
    80005370:	0015079b          	addiw	a5,a0,1
    80005374:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005378:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000537c:	13596363          	bltu	s2,s5,800054a2 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005380:	df043d83          	ld	s11,-528(s0)
    80005384:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005388:	8552                	mv	a0,s4
    8000538a:	ffffc097          	auipc	ra,0xffffc
    8000538e:	ab8080e7          	jalr	-1352(ra) # 80000e42 <strlen>
    80005392:	0015069b          	addiw	a3,a0,1
    80005396:	8652                	mv	a2,s4
    80005398:	85ca                	mv	a1,s2
    8000539a:	855a                	mv	a0,s6
    8000539c:	ffffc097          	auipc	ra,0xffffc
    800053a0:	2a2080e7          	jalr	674(ra) # 8000163e <copyout>
    800053a4:	10054363          	bltz	a0,800054aa <exec+0x302>
    ustack[argc] = sp;
    800053a8:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800053ac:	0485                	addi	s1,s1,1
    800053ae:	008d8793          	addi	a5,s11,8
    800053b2:	def43823          	sd	a5,-528(s0)
    800053b6:	008db503          	ld	a0,8(s11)
    800053ba:	c911                	beqz	a0,800053ce <exec+0x226>
    if(argc >= MAXARG)
    800053bc:	09a1                	addi	s3,s3,8
    800053be:	fb3c95e3          	bne	s9,s3,80005368 <exec+0x1c0>
  sz = sz1;
    800053c2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053c6:	4a81                	li	s5,0
    800053c8:	a84d                	j	8000547a <exec+0x2d2>
  sp = sz;
    800053ca:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800053cc:	4481                	li	s1,0
  ustack[argc] = 0;
    800053ce:	00349793          	slli	a5,s1,0x3
    800053d2:	f9040713          	addi	a4,s0,-112
    800053d6:	97ba                	add	a5,a5,a4
    800053d8:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd8ef8>
  sp -= (argc+1) * sizeof(uint64);
    800053dc:	00148693          	addi	a3,s1,1
    800053e0:	068e                	slli	a3,a3,0x3
    800053e2:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800053e6:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800053ea:	01597663          	bgeu	s2,s5,800053f6 <exec+0x24e>
  sz = sz1;
    800053ee:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053f2:	4a81                	li	s5,0
    800053f4:	a059                	j	8000547a <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800053f6:	e8840613          	addi	a2,s0,-376
    800053fa:	85ca                	mv	a1,s2
    800053fc:	855a                	mv	a0,s6
    800053fe:	ffffc097          	auipc	ra,0xffffc
    80005402:	240080e7          	jalr	576(ra) # 8000163e <copyout>
    80005406:	0a054663          	bltz	a0,800054b2 <exec+0x30a>
  p->trapframe->a1 = sp;
    8000540a:	078bb783          	ld	a5,120(s7) # 1078 <_entry-0x7fffef88>
    8000540e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005412:	de843783          	ld	a5,-536(s0)
    80005416:	0007c703          	lbu	a4,0(a5)
    8000541a:	cf11                	beqz	a4,80005436 <exec+0x28e>
    8000541c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000541e:	02f00693          	li	a3,47
    80005422:	a039                	j	80005430 <exec+0x288>
      last = s+1;
    80005424:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005428:	0785                	addi	a5,a5,1
    8000542a:	fff7c703          	lbu	a4,-1(a5)
    8000542e:	c701                	beqz	a4,80005436 <exec+0x28e>
    if(*s == '/')
    80005430:	fed71ce3          	bne	a4,a3,80005428 <exec+0x280>
    80005434:	bfc5                	j	80005424 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80005436:	4641                	li	a2,16
    80005438:	de843583          	ld	a1,-536(s0)
    8000543c:	178b8513          	addi	a0,s7,376
    80005440:	ffffc097          	auipc	ra,0xffffc
    80005444:	9d0080e7          	jalr	-1584(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    80005448:	070bb503          	ld	a0,112(s7)
  p->pagetable = pagetable;
    8000544c:	076bb823          	sd	s6,112(s7)
  p->sz = sz;
    80005450:	078bb423          	sd	s8,104(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005454:	078bb783          	ld	a5,120(s7)
    80005458:	e6043703          	ld	a4,-416(s0)
    8000545c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000545e:	078bb783          	ld	a5,120(s7)
    80005462:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005466:	85ea                	mv	a1,s10
    80005468:	ffffc097          	auipc	ra,0xffffc
    8000546c:	68e080e7          	jalr	1678(ra) # 80001af6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005470:	0004851b          	sext.w	a0,s1
    80005474:	bbc1                	j	80005244 <exec+0x9c>
    80005476:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000547a:	df843583          	ld	a1,-520(s0)
    8000547e:	855a                	mv	a0,s6
    80005480:	ffffc097          	auipc	ra,0xffffc
    80005484:	676080e7          	jalr	1654(ra) # 80001af6 <proc_freepagetable>
  if(ip){
    80005488:	da0a94e3          	bnez	s5,80005230 <exec+0x88>
  return -1;
    8000548c:	557d                	li	a0,-1
    8000548e:	bb5d                	j	80005244 <exec+0x9c>
    80005490:	de943c23          	sd	s1,-520(s0)
    80005494:	b7dd                	j	8000547a <exec+0x2d2>
    80005496:	de943c23          	sd	s1,-520(s0)
    8000549a:	b7c5                	j	8000547a <exec+0x2d2>
    8000549c:	de943c23          	sd	s1,-520(s0)
    800054a0:	bfe9                	j	8000547a <exec+0x2d2>
  sz = sz1;
    800054a2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800054a6:	4a81                	li	s5,0
    800054a8:	bfc9                	j	8000547a <exec+0x2d2>
  sz = sz1;
    800054aa:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800054ae:	4a81                	li	s5,0
    800054b0:	b7e9                	j	8000547a <exec+0x2d2>
  sz = sz1;
    800054b2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800054b6:	4a81                	li	s5,0
    800054b8:	b7c9                	j	8000547a <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800054ba:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800054be:	e0843783          	ld	a5,-504(s0)
    800054c2:	0017869b          	addiw	a3,a5,1
    800054c6:	e0d43423          	sd	a3,-504(s0)
    800054ca:	e0043783          	ld	a5,-512(s0)
    800054ce:	0387879b          	addiw	a5,a5,56
    800054d2:	e8045703          	lhu	a4,-384(s0)
    800054d6:	e2e6d3e3          	bge	a3,a4,800052fc <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800054da:	2781                	sext.w	a5,a5
    800054dc:	e0f43023          	sd	a5,-512(s0)
    800054e0:	03800713          	li	a4,56
    800054e4:	86be                	mv	a3,a5
    800054e6:	e1040613          	addi	a2,s0,-496
    800054ea:	4581                	li	a1,0
    800054ec:	8556                	mv	a0,s5
    800054ee:	fffff097          	auipc	ra,0xfffff
    800054f2:	a7a080e7          	jalr	-1414(ra) # 80003f68 <readi>
    800054f6:	03800793          	li	a5,56
    800054fa:	f6f51ee3          	bne	a0,a5,80005476 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    800054fe:	e1042783          	lw	a5,-496(s0)
    80005502:	4705                	li	a4,1
    80005504:	fae79de3          	bne	a5,a4,800054be <exec+0x316>
    if(ph.memsz < ph.filesz)
    80005508:	e3843603          	ld	a2,-456(s0)
    8000550c:	e3043783          	ld	a5,-464(s0)
    80005510:	f8f660e3          	bltu	a2,a5,80005490 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005514:	e2043783          	ld	a5,-480(s0)
    80005518:	963e                	add	a2,a2,a5
    8000551a:	f6f66ee3          	bltu	a2,a5,80005496 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000551e:	85a6                	mv	a1,s1
    80005520:	855a                	mv	a0,s6
    80005522:	ffffc097          	auipc	ra,0xffffc
    80005526:	ecc080e7          	jalr	-308(ra) # 800013ee <uvmalloc>
    8000552a:	dea43c23          	sd	a0,-520(s0)
    8000552e:	d53d                	beqz	a0,8000549c <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    80005530:	e2043c03          	ld	s8,-480(s0)
    80005534:	de043783          	ld	a5,-544(s0)
    80005538:	00fc77b3          	and	a5,s8,a5
    8000553c:	ff9d                	bnez	a5,8000547a <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000553e:	e1842c83          	lw	s9,-488(s0)
    80005542:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005546:	f60b8ae3          	beqz	s7,800054ba <exec+0x312>
    8000554a:	89de                	mv	s3,s7
    8000554c:	4481                	li	s1,0
    8000554e:	b371                	j	800052da <exec+0x132>

0000000080005550 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005550:	7179                	addi	sp,sp,-48
    80005552:	f406                	sd	ra,40(sp)
    80005554:	f022                	sd	s0,32(sp)
    80005556:	ec26                	sd	s1,24(sp)
    80005558:	e84a                	sd	s2,16(sp)
    8000555a:	1800                	addi	s0,sp,48
    8000555c:	892e                	mv	s2,a1
    8000555e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005560:	fdc40593          	addi	a1,s0,-36
    80005564:	ffffe097          	auipc	ra,0xffffe
    80005568:	a9e080e7          	jalr	-1378(ra) # 80003002 <argint>
    8000556c:	04054063          	bltz	a0,800055ac <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005570:	fdc42703          	lw	a4,-36(s0)
    80005574:	47bd                	li	a5,15
    80005576:	02e7ed63          	bltu	a5,a4,800055b0 <argfd+0x60>
    8000557a:	ffffc097          	auipc	ra,0xffffc
    8000557e:	41c080e7          	jalr	1052(ra) # 80001996 <myproc>
    80005582:	fdc42703          	lw	a4,-36(s0)
    80005586:	01e70793          	addi	a5,a4,30
    8000558a:	078e                	slli	a5,a5,0x3
    8000558c:	953e                	add	a0,a0,a5
    8000558e:	611c                	ld	a5,0(a0)
    80005590:	c395                	beqz	a5,800055b4 <argfd+0x64>
    return -1;
  if(pfd)
    80005592:	00090463          	beqz	s2,8000559a <argfd+0x4a>
    *pfd = fd;
    80005596:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000559a:	4501                	li	a0,0
  if(pf)
    8000559c:	c091                	beqz	s1,800055a0 <argfd+0x50>
    *pf = f;
    8000559e:	e09c                	sd	a5,0(s1)
}
    800055a0:	70a2                	ld	ra,40(sp)
    800055a2:	7402                	ld	s0,32(sp)
    800055a4:	64e2                	ld	s1,24(sp)
    800055a6:	6942                	ld	s2,16(sp)
    800055a8:	6145                	addi	sp,sp,48
    800055aa:	8082                	ret
    return -1;
    800055ac:	557d                	li	a0,-1
    800055ae:	bfcd                	j	800055a0 <argfd+0x50>
    return -1;
    800055b0:	557d                	li	a0,-1
    800055b2:	b7fd                	j	800055a0 <argfd+0x50>
    800055b4:	557d                	li	a0,-1
    800055b6:	b7ed                	j	800055a0 <argfd+0x50>

00000000800055b8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800055b8:	1101                	addi	sp,sp,-32
    800055ba:	ec06                	sd	ra,24(sp)
    800055bc:	e822                	sd	s0,16(sp)
    800055be:	e426                	sd	s1,8(sp)
    800055c0:	1000                	addi	s0,sp,32
    800055c2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800055c4:	ffffc097          	auipc	ra,0xffffc
    800055c8:	3d2080e7          	jalr	978(ra) # 80001996 <myproc>
    800055cc:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800055ce:	0f050793          	addi	a5,a0,240
    800055d2:	4501                	li	a0,0
    800055d4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800055d6:	6398                	ld	a4,0(a5)
    800055d8:	cb19                	beqz	a4,800055ee <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800055da:	2505                	addiw	a0,a0,1
    800055dc:	07a1                	addi	a5,a5,8
    800055de:	fed51ce3          	bne	a0,a3,800055d6 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800055e2:	557d                	li	a0,-1
}
    800055e4:	60e2                	ld	ra,24(sp)
    800055e6:	6442                	ld	s0,16(sp)
    800055e8:	64a2                	ld	s1,8(sp)
    800055ea:	6105                	addi	sp,sp,32
    800055ec:	8082                	ret
      p->ofile[fd] = f;
    800055ee:	01e50793          	addi	a5,a0,30
    800055f2:	078e                	slli	a5,a5,0x3
    800055f4:	963e                	add	a2,a2,a5
    800055f6:	e204                	sd	s1,0(a2)
      return fd;
    800055f8:	b7f5                	j	800055e4 <fdalloc+0x2c>

00000000800055fa <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800055fa:	715d                	addi	sp,sp,-80
    800055fc:	e486                	sd	ra,72(sp)
    800055fe:	e0a2                	sd	s0,64(sp)
    80005600:	fc26                	sd	s1,56(sp)
    80005602:	f84a                	sd	s2,48(sp)
    80005604:	f44e                	sd	s3,40(sp)
    80005606:	f052                	sd	s4,32(sp)
    80005608:	ec56                	sd	s5,24(sp)
    8000560a:	0880                	addi	s0,sp,80
    8000560c:	89ae                	mv	s3,a1
    8000560e:	8ab2                	mv	s5,a2
    80005610:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005612:	fb040593          	addi	a1,s0,-80
    80005616:	fffff097          	auipc	ra,0xfffff
    8000561a:	e72080e7          	jalr	-398(ra) # 80004488 <nameiparent>
    8000561e:	892a                	mv	s2,a0
    80005620:	12050e63          	beqz	a0,8000575c <create+0x162>
    return 0;

  ilock(dp);
    80005624:	ffffe097          	auipc	ra,0xffffe
    80005628:	690080e7          	jalr	1680(ra) # 80003cb4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000562c:	4601                	li	a2,0
    8000562e:	fb040593          	addi	a1,s0,-80
    80005632:	854a                	mv	a0,s2
    80005634:	fffff097          	auipc	ra,0xfffff
    80005638:	b64080e7          	jalr	-1180(ra) # 80004198 <dirlookup>
    8000563c:	84aa                	mv	s1,a0
    8000563e:	c921                	beqz	a0,8000568e <create+0x94>
    iunlockput(dp);
    80005640:	854a                	mv	a0,s2
    80005642:	fffff097          	auipc	ra,0xfffff
    80005646:	8d4080e7          	jalr	-1836(ra) # 80003f16 <iunlockput>
    ilock(ip);
    8000564a:	8526                	mv	a0,s1
    8000564c:	ffffe097          	auipc	ra,0xffffe
    80005650:	668080e7          	jalr	1640(ra) # 80003cb4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005654:	2981                	sext.w	s3,s3
    80005656:	4789                	li	a5,2
    80005658:	02f99463          	bne	s3,a5,80005680 <create+0x86>
    8000565c:	0444d783          	lhu	a5,68(s1)
    80005660:	37f9                	addiw	a5,a5,-2
    80005662:	17c2                	slli	a5,a5,0x30
    80005664:	93c1                	srli	a5,a5,0x30
    80005666:	4705                	li	a4,1
    80005668:	00f76c63          	bltu	a4,a5,80005680 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000566c:	8526                	mv	a0,s1
    8000566e:	60a6                	ld	ra,72(sp)
    80005670:	6406                	ld	s0,64(sp)
    80005672:	74e2                	ld	s1,56(sp)
    80005674:	7942                	ld	s2,48(sp)
    80005676:	79a2                	ld	s3,40(sp)
    80005678:	7a02                	ld	s4,32(sp)
    8000567a:	6ae2                	ld	s5,24(sp)
    8000567c:	6161                	addi	sp,sp,80
    8000567e:	8082                	ret
    iunlockput(ip);
    80005680:	8526                	mv	a0,s1
    80005682:	fffff097          	auipc	ra,0xfffff
    80005686:	894080e7          	jalr	-1900(ra) # 80003f16 <iunlockput>
    return 0;
    8000568a:	4481                	li	s1,0
    8000568c:	b7c5                	j	8000566c <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000568e:	85ce                	mv	a1,s3
    80005690:	00092503          	lw	a0,0(s2)
    80005694:	ffffe097          	auipc	ra,0xffffe
    80005698:	488080e7          	jalr	1160(ra) # 80003b1c <ialloc>
    8000569c:	84aa                	mv	s1,a0
    8000569e:	c521                	beqz	a0,800056e6 <create+0xec>
  ilock(ip);
    800056a0:	ffffe097          	auipc	ra,0xffffe
    800056a4:	614080e7          	jalr	1556(ra) # 80003cb4 <ilock>
  ip->major = major;
    800056a8:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800056ac:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800056b0:	4a05                	li	s4,1
    800056b2:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800056b6:	8526                	mv	a0,s1
    800056b8:	ffffe097          	auipc	ra,0xffffe
    800056bc:	532080e7          	jalr	1330(ra) # 80003bea <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800056c0:	2981                	sext.w	s3,s3
    800056c2:	03498a63          	beq	s3,s4,800056f6 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800056c6:	40d0                	lw	a2,4(s1)
    800056c8:	fb040593          	addi	a1,s0,-80
    800056cc:	854a                	mv	a0,s2
    800056ce:	fffff097          	auipc	ra,0xfffff
    800056d2:	cda080e7          	jalr	-806(ra) # 800043a8 <dirlink>
    800056d6:	06054b63          	bltz	a0,8000574c <create+0x152>
  iunlockput(dp);
    800056da:	854a                	mv	a0,s2
    800056dc:	fffff097          	auipc	ra,0xfffff
    800056e0:	83a080e7          	jalr	-1990(ra) # 80003f16 <iunlockput>
  return ip;
    800056e4:	b761                	j	8000566c <create+0x72>
    panic("create: ialloc");
    800056e6:	00003517          	auipc	a0,0x3
    800056ea:	23250513          	addi	a0,a0,562 # 80008918 <syscalls+0x2e8>
    800056ee:	ffffb097          	auipc	ra,0xffffb
    800056f2:	e3c080e7          	jalr	-452(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    800056f6:	04a95783          	lhu	a5,74(s2)
    800056fa:	2785                	addiw	a5,a5,1
    800056fc:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005700:	854a                	mv	a0,s2
    80005702:	ffffe097          	auipc	ra,0xffffe
    80005706:	4e8080e7          	jalr	1256(ra) # 80003bea <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000570a:	40d0                	lw	a2,4(s1)
    8000570c:	00003597          	auipc	a1,0x3
    80005710:	21c58593          	addi	a1,a1,540 # 80008928 <syscalls+0x2f8>
    80005714:	8526                	mv	a0,s1
    80005716:	fffff097          	auipc	ra,0xfffff
    8000571a:	c92080e7          	jalr	-878(ra) # 800043a8 <dirlink>
    8000571e:	00054f63          	bltz	a0,8000573c <create+0x142>
    80005722:	00492603          	lw	a2,4(s2)
    80005726:	00003597          	auipc	a1,0x3
    8000572a:	20a58593          	addi	a1,a1,522 # 80008930 <syscalls+0x300>
    8000572e:	8526                	mv	a0,s1
    80005730:	fffff097          	auipc	ra,0xfffff
    80005734:	c78080e7          	jalr	-904(ra) # 800043a8 <dirlink>
    80005738:	f80557e3          	bgez	a0,800056c6 <create+0xcc>
      panic("create dots");
    8000573c:	00003517          	auipc	a0,0x3
    80005740:	1fc50513          	addi	a0,a0,508 # 80008938 <syscalls+0x308>
    80005744:	ffffb097          	auipc	ra,0xffffb
    80005748:	de6080e7          	jalr	-538(ra) # 8000052a <panic>
    panic("create: dirlink");
    8000574c:	00003517          	auipc	a0,0x3
    80005750:	1fc50513          	addi	a0,a0,508 # 80008948 <syscalls+0x318>
    80005754:	ffffb097          	auipc	ra,0xffffb
    80005758:	dd6080e7          	jalr	-554(ra) # 8000052a <panic>
    return 0;
    8000575c:	84aa                	mv	s1,a0
    8000575e:	b739                	j	8000566c <create+0x72>

0000000080005760 <sys_dup>:
{
    80005760:	7179                	addi	sp,sp,-48
    80005762:	f406                	sd	ra,40(sp)
    80005764:	f022                	sd	s0,32(sp)
    80005766:	ec26                	sd	s1,24(sp)
    80005768:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000576a:	fd840613          	addi	a2,s0,-40
    8000576e:	4581                	li	a1,0
    80005770:	4501                	li	a0,0
    80005772:	00000097          	auipc	ra,0x0
    80005776:	dde080e7          	jalr	-546(ra) # 80005550 <argfd>
    return -1;
    8000577a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000577c:	02054363          	bltz	a0,800057a2 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005780:	fd843503          	ld	a0,-40(s0)
    80005784:	00000097          	auipc	ra,0x0
    80005788:	e34080e7          	jalr	-460(ra) # 800055b8 <fdalloc>
    8000578c:	84aa                	mv	s1,a0
    return -1;
    8000578e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005790:	00054963          	bltz	a0,800057a2 <sys_dup+0x42>
  filedup(f);
    80005794:	fd843503          	ld	a0,-40(s0)
    80005798:	fffff097          	auipc	ra,0xfffff
    8000579c:	36c080e7          	jalr	876(ra) # 80004b04 <filedup>
  return fd;
    800057a0:	87a6                	mv	a5,s1
}
    800057a2:	853e                	mv	a0,a5
    800057a4:	70a2                	ld	ra,40(sp)
    800057a6:	7402                	ld	s0,32(sp)
    800057a8:	64e2                	ld	s1,24(sp)
    800057aa:	6145                	addi	sp,sp,48
    800057ac:	8082                	ret

00000000800057ae <sys_read>:
{
    800057ae:	7179                	addi	sp,sp,-48
    800057b0:	f406                	sd	ra,40(sp)
    800057b2:	f022                	sd	s0,32(sp)
    800057b4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057b6:	fe840613          	addi	a2,s0,-24
    800057ba:	4581                	li	a1,0
    800057bc:	4501                	li	a0,0
    800057be:	00000097          	auipc	ra,0x0
    800057c2:	d92080e7          	jalr	-622(ra) # 80005550 <argfd>
    return -1;
    800057c6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057c8:	04054163          	bltz	a0,8000580a <sys_read+0x5c>
    800057cc:	fe440593          	addi	a1,s0,-28
    800057d0:	4509                	li	a0,2
    800057d2:	ffffe097          	auipc	ra,0xffffe
    800057d6:	830080e7          	jalr	-2000(ra) # 80003002 <argint>
    return -1;
    800057da:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057dc:	02054763          	bltz	a0,8000580a <sys_read+0x5c>
    800057e0:	fd840593          	addi	a1,s0,-40
    800057e4:	4505                	li	a0,1
    800057e6:	ffffe097          	auipc	ra,0xffffe
    800057ea:	83e080e7          	jalr	-1986(ra) # 80003024 <argaddr>
    return -1;
    800057ee:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057f0:	00054d63          	bltz	a0,8000580a <sys_read+0x5c>
  return fileread(f, p, n);
    800057f4:	fe442603          	lw	a2,-28(s0)
    800057f8:	fd843583          	ld	a1,-40(s0)
    800057fc:	fe843503          	ld	a0,-24(s0)
    80005800:	fffff097          	auipc	ra,0xfffff
    80005804:	490080e7          	jalr	1168(ra) # 80004c90 <fileread>
    80005808:	87aa                	mv	a5,a0
}
    8000580a:	853e                	mv	a0,a5
    8000580c:	70a2                	ld	ra,40(sp)
    8000580e:	7402                	ld	s0,32(sp)
    80005810:	6145                	addi	sp,sp,48
    80005812:	8082                	ret

0000000080005814 <sys_write>:
{
    80005814:	7179                	addi	sp,sp,-48
    80005816:	f406                	sd	ra,40(sp)
    80005818:	f022                	sd	s0,32(sp)
    8000581a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000581c:	fe840613          	addi	a2,s0,-24
    80005820:	4581                	li	a1,0
    80005822:	4501                	li	a0,0
    80005824:	00000097          	auipc	ra,0x0
    80005828:	d2c080e7          	jalr	-724(ra) # 80005550 <argfd>
    return -1;
    8000582c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000582e:	04054163          	bltz	a0,80005870 <sys_write+0x5c>
    80005832:	fe440593          	addi	a1,s0,-28
    80005836:	4509                	li	a0,2
    80005838:	ffffd097          	auipc	ra,0xffffd
    8000583c:	7ca080e7          	jalr	1994(ra) # 80003002 <argint>
    return -1;
    80005840:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005842:	02054763          	bltz	a0,80005870 <sys_write+0x5c>
    80005846:	fd840593          	addi	a1,s0,-40
    8000584a:	4505                	li	a0,1
    8000584c:	ffffd097          	auipc	ra,0xffffd
    80005850:	7d8080e7          	jalr	2008(ra) # 80003024 <argaddr>
    return -1;
    80005854:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005856:	00054d63          	bltz	a0,80005870 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000585a:	fe442603          	lw	a2,-28(s0)
    8000585e:	fd843583          	ld	a1,-40(s0)
    80005862:	fe843503          	ld	a0,-24(s0)
    80005866:	fffff097          	auipc	ra,0xfffff
    8000586a:	4ec080e7          	jalr	1260(ra) # 80004d52 <filewrite>
    8000586e:	87aa                	mv	a5,a0
}
    80005870:	853e                	mv	a0,a5
    80005872:	70a2                	ld	ra,40(sp)
    80005874:	7402                	ld	s0,32(sp)
    80005876:	6145                	addi	sp,sp,48
    80005878:	8082                	ret

000000008000587a <sys_close>:
{
    8000587a:	1101                	addi	sp,sp,-32
    8000587c:	ec06                	sd	ra,24(sp)
    8000587e:	e822                	sd	s0,16(sp)
    80005880:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005882:	fe040613          	addi	a2,s0,-32
    80005886:	fec40593          	addi	a1,s0,-20
    8000588a:	4501                	li	a0,0
    8000588c:	00000097          	auipc	ra,0x0
    80005890:	cc4080e7          	jalr	-828(ra) # 80005550 <argfd>
    return -1;
    80005894:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005896:	02054463          	bltz	a0,800058be <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000589a:	ffffc097          	auipc	ra,0xffffc
    8000589e:	0fc080e7          	jalr	252(ra) # 80001996 <myproc>
    800058a2:	fec42783          	lw	a5,-20(s0)
    800058a6:	07f9                	addi	a5,a5,30
    800058a8:	078e                	slli	a5,a5,0x3
    800058aa:	97aa                	add	a5,a5,a0
    800058ac:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800058b0:	fe043503          	ld	a0,-32(s0)
    800058b4:	fffff097          	auipc	ra,0xfffff
    800058b8:	2a2080e7          	jalr	674(ra) # 80004b56 <fileclose>
  return 0;
    800058bc:	4781                	li	a5,0
}
    800058be:	853e                	mv	a0,a5
    800058c0:	60e2                	ld	ra,24(sp)
    800058c2:	6442                	ld	s0,16(sp)
    800058c4:	6105                	addi	sp,sp,32
    800058c6:	8082                	ret

00000000800058c8 <sys_fstat>:
{
    800058c8:	1101                	addi	sp,sp,-32
    800058ca:	ec06                	sd	ra,24(sp)
    800058cc:	e822                	sd	s0,16(sp)
    800058ce:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800058d0:	fe840613          	addi	a2,s0,-24
    800058d4:	4581                	li	a1,0
    800058d6:	4501                	li	a0,0
    800058d8:	00000097          	auipc	ra,0x0
    800058dc:	c78080e7          	jalr	-904(ra) # 80005550 <argfd>
    return -1;
    800058e0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800058e2:	02054563          	bltz	a0,8000590c <sys_fstat+0x44>
    800058e6:	fe040593          	addi	a1,s0,-32
    800058ea:	4505                	li	a0,1
    800058ec:	ffffd097          	auipc	ra,0xffffd
    800058f0:	738080e7          	jalr	1848(ra) # 80003024 <argaddr>
    return -1;
    800058f4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800058f6:	00054b63          	bltz	a0,8000590c <sys_fstat+0x44>
  return filestat(f, st);
    800058fa:	fe043583          	ld	a1,-32(s0)
    800058fe:	fe843503          	ld	a0,-24(s0)
    80005902:	fffff097          	auipc	ra,0xfffff
    80005906:	31c080e7          	jalr	796(ra) # 80004c1e <filestat>
    8000590a:	87aa                	mv	a5,a0
}
    8000590c:	853e                	mv	a0,a5
    8000590e:	60e2                	ld	ra,24(sp)
    80005910:	6442                	ld	s0,16(sp)
    80005912:	6105                	addi	sp,sp,32
    80005914:	8082                	ret

0000000080005916 <sys_link>:
{
    80005916:	7169                	addi	sp,sp,-304
    80005918:	f606                	sd	ra,296(sp)
    8000591a:	f222                	sd	s0,288(sp)
    8000591c:	ee26                	sd	s1,280(sp)
    8000591e:	ea4a                	sd	s2,272(sp)
    80005920:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005922:	08000613          	li	a2,128
    80005926:	ed040593          	addi	a1,s0,-304
    8000592a:	4501                	li	a0,0
    8000592c:	ffffd097          	auipc	ra,0xffffd
    80005930:	71a080e7          	jalr	1818(ra) # 80003046 <argstr>
    return -1;
    80005934:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005936:	10054e63          	bltz	a0,80005a52 <sys_link+0x13c>
    8000593a:	08000613          	li	a2,128
    8000593e:	f5040593          	addi	a1,s0,-176
    80005942:	4505                	li	a0,1
    80005944:	ffffd097          	auipc	ra,0xffffd
    80005948:	702080e7          	jalr	1794(ra) # 80003046 <argstr>
    return -1;
    8000594c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000594e:	10054263          	bltz	a0,80005a52 <sys_link+0x13c>
  begin_op();
    80005952:	fffff097          	auipc	ra,0xfffff
    80005956:	d38080e7          	jalr	-712(ra) # 8000468a <begin_op>
  if((ip = namei(old)) == 0){
    8000595a:	ed040513          	addi	a0,s0,-304
    8000595e:	fffff097          	auipc	ra,0xfffff
    80005962:	b0c080e7          	jalr	-1268(ra) # 8000446a <namei>
    80005966:	84aa                	mv	s1,a0
    80005968:	c551                	beqz	a0,800059f4 <sys_link+0xde>
  ilock(ip);
    8000596a:	ffffe097          	auipc	ra,0xffffe
    8000596e:	34a080e7          	jalr	842(ra) # 80003cb4 <ilock>
  if(ip->type == T_DIR){
    80005972:	04449703          	lh	a4,68(s1)
    80005976:	4785                	li	a5,1
    80005978:	08f70463          	beq	a4,a5,80005a00 <sys_link+0xea>
  ip->nlink++;
    8000597c:	04a4d783          	lhu	a5,74(s1)
    80005980:	2785                	addiw	a5,a5,1
    80005982:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005986:	8526                	mv	a0,s1
    80005988:	ffffe097          	auipc	ra,0xffffe
    8000598c:	262080e7          	jalr	610(ra) # 80003bea <iupdate>
  iunlock(ip);
    80005990:	8526                	mv	a0,s1
    80005992:	ffffe097          	auipc	ra,0xffffe
    80005996:	3e4080e7          	jalr	996(ra) # 80003d76 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000599a:	fd040593          	addi	a1,s0,-48
    8000599e:	f5040513          	addi	a0,s0,-176
    800059a2:	fffff097          	auipc	ra,0xfffff
    800059a6:	ae6080e7          	jalr	-1306(ra) # 80004488 <nameiparent>
    800059aa:	892a                	mv	s2,a0
    800059ac:	c935                	beqz	a0,80005a20 <sys_link+0x10a>
  ilock(dp);
    800059ae:	ffffe097          	auipc	ra,0xffffe
    800059b2:	306080e7          	jalr	774(ra) # 80003cb4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800059b6:	00092703          	lw	a4,0(s2)
    800059ba:	409c                	lw	a5,0(s1)
    800059bc:	04f71d63          	bne	a4,a5,80005a16 <sys_link+0x100>
    800059c0:	40d0                	lw	a2,4(s1)
    800059c2:	fd040593          	addi	a1,s0,-48
    800059c6:	854a                	mv	a0,s2
    800059c8:	fffff097          	auipc	ra,0xfffff
    800059cc:	9e0080e7          	jalr	-1568(ra) # 800043a8 <dirlink>
    800059d0:	04054363          	bltz	a0,80005a16 <sys_link+0x100>
  iunlockput(dp);
    800059d4:	854a                	mv	a0,s2
    800059d6:	ffffe097          	auipc	ra,0xffffe
    800059da:	540080e7          	jalr	1344(ra) # 80003f16 <iunlockput>
  iput(ip);
    800059de:	8526                	mv	a0,s1
    800059e0:	ffffe097          	auipc	ra,0xffffe
    800059e4:	48e080e7          	jalr	1166(ra) # 80003e6e <iput>
  end_op();
    800059e8:	fffff097          	auipc	ra,0xfffff
    800059ec:	d22080e7          	jalr	-734(ra) # 8000470a <end_op>
  return 0;
    800059f0:	4781                	li	a5,0
    800059f2:	a085                	j	80005a52 <sys_link+0x13c>
    end_op();
    800059f4:	fffff097          	auipc	ra,0xfffff
    800059f8:	d16080e7          	jalr	-746(ra) # 8000470a <end_op>
    return -1;
    800059fc:	57fd                	li	a5,-1
    800059fe:	a891                	j	80005a52 <sys_link+0x13c>
    iunlockput(ip);
    80005a00:	8526                	mv	a0,s1
    80005a02:	ffffe097          	auipc	ra,0xffffe
    80005a06:	514080e7          	jalr	1300(ra) # 80003f16 <iunlockput>
    end_op();
    80005a0a:	fffff097          	auipc	ra,0xfffff
    80005a0e:	d00080e7          	jalr	-768(ra) # 8000470a <end_op>
    return -1;
    80005a12:	57fd                	li	a5,-1
    80005a14:	a83d                	j	80005a52 <sys_link+0x13c>
    iunlockput(dp);
    80005a16:	854a                	mv	a0,s2
    80005a18:	ffffe097          	auipc	ra,0xffffe
    80005a1c:	4fe080e7          	jalr	1278(ra) # 80003f16 <iunlockput>
  ilock(ip);
    80005a20:	8526                	mv	a0,s1
    80005a22:	ffffe097          	auipc	ra,0xffffe
    80005a26:	292080e7          	jalr	658(ra) # 80003cb4 <ilock>
  ip->nlink--;
    80005a2a:	04a4d783          	lhu	a5,74(s1)
    80005a2e:	37fd                	addiw	a5,a5,-1
    80005a30:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a34:	8526                	mv	a0,s1
    80005a36:	ffffe097          	auipc	ra,0xffffe
    80005a3a:	1b4080e7          	jalr	436(ra) # 80003bea <iupdate>
  iunlockput(ip);
    80005a3e:	8526                	mv	a0,s1
    80005a40:	ffffe097          	auipc	ra,0xffffe
    80005a44:	4d6080e7          	jalr	1238(ra) # 80003f16 <iunlockput>
  end_op();
    80005a48:	fffff097          	auipc	ra,0xfffff
    80005a4c:	cc2080e7          	jalr	-830(ra) # 8000470a <end_op>
  return -1;
    80005a50:	57fd                	li	a5,-1
}
    80005a52:	853e                	mv	a0,a5
    80005a54:	70b2                	ld	ra,296(sp)
    80005a56:	7412                	ld	s0,288(sp)
    80005a58:	64f2                	ld	s1,280(sp)
    80005a5a:	6952                	ld	s2,272(sp)
    80005a5c:	6155                	addi	sp,sp,304
    80005a5e:	8082                	ret

0000000080005a60 <sys_unlink>:
{
    80005a60:	7151                	addi	sp,sp,-240
    80005a62:	f586                	sd	ra,232(sp)
    80005a64:	f1a2                	sd	s0,224(sp)
    80005a66:	eda6                	sd	s1,216(sp)
    80005a68:	e9ca                	sd	s2,208(sp)
    80005a6a:	e5ce                	sd	s3,200(sp)
    80005a6c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005a6e:	08000613          	li	a2,128
    80005a72:	f3040593          	addi	a1,s0,-208
    80005a76:	4501                	li	a0,0
    80005a78:	ffffd097          	auipc	ra,0xffffd
    80005a7c:	5ce080e7          	jalr	1486(ra) # 80003046 <argstr>
    80005a80:	18054163          	bltz	a0,80005c02 <sys_unlink+0x1a2>
  begin_op();
    80005a84:	fffff097          	auipc	ra,0xfffff
    80005a88:	c06080e7          	jalr	-1018(ra) # 8000468a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005a8c:	fb040593          	addi	a1,s0,-80
    80005a90:	f3040513          	addi	a0,s0,-208
    80005a94:	fffff097          	auipc	ra,0xfffff
    80005a98:	9f4080e7          	jalr	-1548(ra) # 80004488 <nameiparent>
    80005a9c:	84aa                	mv	s1,a0
    80005a9e:	c979                	beqz	a0,80005b74 <sys_unlink+0x114>
  ilock(dp);
    80005aa0:	ffffe097          	auipc	ra,0xffffe
    80005aa4:	214080e7          	jalr	532(ra) # 80003cb4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005aa8:	00003597          	auipc	a1,0x3
    80005aac:	e8058593          	addi	a1,a1,-384 # 80008928 <syscalls+0x2f8>
    80005ab0:	fb040513          	addi	a0,s0,-80
    80005ab4:	ffffe097          	auipc	ra,0xffffe
    80005ab8:	6ca080e7          	jalr	1738(ra) # 8000417e <namecmp>
    80005abc:	14050a63          	beqz	a0,80005c10 <sys_unlink+0x1b0>
    80005ac0:	00003597          	auipc	a1,0x3
    80005ac4:	e7058593          	addi	a1,a1,-400 # 80008930 <syscalls+0x300>
    80005ac8:	fb040513          	addi	a0,s0,-80
    80005acc:	ffffe097          	auipc	ra,0xffffe
    80005ad0:	6b2080e7          	jalr	1714(ra) # 8000417e <namecmp>
    80005ad4:	12050e63          	beqz	a0,80005c10 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005ad8:	f2c40613          	addi	a2,s0,-212
    80005adc:	fb040593          	addi	a1,s0,-80
    80005ae0:	8526                	mv	a0,s1
    80005ae2:	ffffe097          	auipc	ra,0xffffe
    80005ae6:	6b6080e7          	jalr	1718(ra) # 80004198 <dirlookup>
    80005aea:	892a                	mv	s2,a0
    80005aec:	12050263          	beqz	a0,80005c10 <sys_unlink+0x1b0>
  ilock(ip);
    80005af0:	ffffe097          	auipc	ra,0xffffe
    80005af4:	1c4080e7          	jalr	452(ra) # 80003cb4 <ilock>
  if(ip->nlink < 1)
    80005af8:	04a91783          	lh	a5,74(s2)
    80005afc:	08f05263          	blez	a5,80005b80 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005b00:	04491703          	lh	a4,68(s2)
    80005b04:	4785                	li	a5,1
    80005b06:	08f70563          	beq	a4,a5,80005b90 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005b0a:	4641                	li	a2,16
    80005b0c:	4581                	li	a1,0
    80005b0e:	fc040513          	addi	a0,s0,-64
    80005b12:	ffffb097          	auipc	ra,0xffffb
    80005b16:	1ac080e7          	jalr	428(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b1a:	4741                	li	a4,16
    80005b1c:	f2c42683          	lw	a3,-212(s0)
    80005b20:	fc040613          	addi	a2,s0,-64
    80005b24:	4581                	li	a1,0
    80005b26:	8526                	mv	a0,s1
    80005b28:	ffffe097          	auipc	ra,0xffffe
    80005b2c:	538080e7          	jalr	1336(ra) # 80004060 <writei>
    80005b30:	47c1                	li	a5,16
    80005b32:	0af51563          	bne	a0,a5,80005bdc <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005b36:	04491703          	lh	a4,68(s2)
    80005b3a:	4785                	li	a5,1
    80005b3c:	0af70863          	beq	a4,a5,80005bec <sys_unlink+0x18c>
  iunlockput(dp);
    80005b40:	8526                	mv	a0,s1
    80005b42:	ffffe097          	auipc	ra,0xffffe
    80005b46:	3d4080e7          	jalr	980(ra) # 80003f16 <iunlockput>
  ip->nlink--;
    80005b4a:	04a95783          	lhu	a5,74(s2)
    80005b4e:	37fd                	addiw	a5,a5,-1
    80005b50:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005b54:	854a                	mv	a0,s2
    80005b56:	ffffe097          	auipc	ra,0xffffe
    80005b5a:	094080e7          	jalr	148(ra) # 80003bea <iupdate>
  iunlockput(ip);
    80005b5e:	854a                	mv	a0,s2
    80005b60:	ffffe097          	auipc	ra,0xffffe
    80005b64:	3b6080e7          	jalr	950(ra) # 80003f16 <iunlockput>
  end_op();
    80005b68:	fffff097          	auipc	ra,0xfffff
    80005b6c:	ba2080e7          	jalr	-1118(ra) # 8000470a <end_op>
  return 0;
    80005b70:	4501                	li	a0,0
    80005b72:	a84d                	j	80005c24 <sys_unlink+0x1c4>
    end_op();
    80005b74:	fffff097          	auipc	ra,0xfffff
    80005b78:	b96080e7          	jalr	-1130(ra) # 8000470a <end_op>
    return -1;
    80005b7c:	557d                	li	a0,-1
    80005b7e:	a05d                	j	80005c24 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005b80:	00003517          	auipc	a0,0x3
    80005b84:	dd850513          	addi	a0,a0,-552 # 80008958 <syscalls+0x328>
    80005b88:	ffffb097          	auipc	ra,0xffffb
    80005b8c:	9a2080e7          	jalr	-1630(ra) # 8000052a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b90:	04c92703          	lw	a4,76(s2)
    80005b94:	02000793          	li	a5,32
    80005b98:	f6e7f9e3          	bgeu	a5,a4,80005b0a <sys_unlink+0xaa>
    80005b9c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005ba0:	4741                	li	a4,16
    80005ba2:	86ce                	mv	a3,s3
    80005ba4:	f1840613          	addi	a2,s0,-232
    80005ba8:	4581                	li	a1,0
    80005baa:	854a                	mv	a0,s2
    80005bac:	ffffe097          	auipc	ra,0xffffe
    80005bb0:	3bc080e7          	jalr	956(ra) # 80003f68 <readi>
    80005bb4:	47c1                	li	a5,16
    80005bb6:	00f51b63          	bne	a0,a5,80005bcc <sys_unlink+0x16c>
    if(de.inum != 0)
    80005bba:	f1845783          	lhu	a5,-232(s0)
    80005bbe:	e7a1                	bnez	a5,80005c06 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005bc0:	29c1                	addiw	s3,s3,16
    80005bc2:	04c92783          	lw	a5,76(s2)
    80005bc6:	fcf9ede3          	bltu	s3,a5,80005ba0 <sys_unlink+0x140>
    80005bca:	b781                	j	80005b0a <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005bcc:	00003517          	auipc	a0,0x3
    80005bd0:	da450513          	addi	a0,a0,-604 # 80008970 <syscalls+0x340>
    80005bd4:	ffffb097          	auipc	ra,0xffffb
    80005bd8:	956080e7          	jalr	-1706(ra) # 8000052a <panic>
    panic("unlink: writei");
    80005bdc:	00003517          	auipc	a0,0x3
    80005be0:	dac50513          	addi	a0,a0,-596 # 80008988 <syscalls+0x358>
    80005be4:	ffffb097          	auipc	ra,0xffffb
    80005be8:	946080e7          	jalr	-1722(ra) # 8000052a <panic>
    dp->nlink--;
    80005bec:	04a4d783          	lhu	a5,74(s1)
    80005bf0:	37fd                	addiw	a5,a5,-1
    80005bf2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005bf6:	8526                	mv	a0,s1
    80005bf8:	ffffe097          	auipc	ra,0xffffe
    80005bfc:	ff2080e7          	jalr	-14(ra) # 80003bea <iupdate>
    80005c00:	b781                	j	80005b40 <sys_unlink+0xe0>
    return -1;
    80005c02:	557d                	li	a0,-1
    80005c04:	a005                	j	80005c24 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005c06:	854a                	mv	a0,s2
    80005c08:	ffffe097          	auipc	ra,0xffffe
    80005c0c:	30e080e7          	jalr	782(ra) # 80003f16 <iunlockput>
  iunlockput(dp);
    80005c10:	8526                	mv	a0,s1
    80005c12:	ffffe097          	auipc	ra,0xffffe
    80005c16:	304080e7          	jalr	772(ra) # 80003f16 <iunlockput>
  end_op();
    80005c1a:	fffff097          	auipc	ra,0xfffff
    80005c1e:	af0080e7          	jalr	-1296(ra) # 8000470a <end_op>
  return -1;
    80005c22:	557d                	li	a0,-1
}
    80005c24:	70ae                	ld	ra,232(sp)
    80005c26:	740e                	ld	s0,224(sp)
    80005c28:	64ee                	ld	s1,216(sp)
    80005c2a:	694e                	ld	s2,208(sp)
    80005c2c:	69ae                	ld	s3,200(sp)
    80005c2e:	616d                	addi	sp,sp,240
    80005c30:	8082                	ret

0000000080005c32 <sys_open>:

uint64
sys_open(void)
{
    80005c32:	7131                	addi	sp,sp,-192
    80005c34:	fd06                	sd	ra,184(sp)
    80005c36:	f922                	sd	s0,176(sp)
    80005c38:	f526                	sd	s1,168(sp)
    80005c3a:	f14a                	sd	s2,160(sp)
    80005c3c:	ed4e                	sd	s3,152(sp)
    80005c3e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005c40:	08000613          	li	a2,128
    80005c44:	f5040593          	addi	a1,s0,-176
    80005c48:	4501                	li	a0,0
    80005c4a:	ffffd097          	auipc	ra,0xffffd
    80005c4e:	3fc080e7          	jalr	1020(ra) # 80003046 <argstr>
    return -1;
    80005c52:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005c54:	0c054163          	bltz	a0,80005d16 <sys_open+0xe4>
    80005c58:	f4c40593          	addi	a1,s0,-180
    80005c5c:	4505                	li	a0,1
    80005c5e:	ffffd097          	auipc	ra,0xffffd
    80005c62:	3a4080e7          	jalr	932(ra) # 80003002 <argint>
    80005c66:	0a054863          	bltz	a0,80005d16 <sys_open+0xe4>

  begin_op();
    80005c6a:	fffff097          	auipc	ra,0xfffff
    80005c6e:	a20080e7          	jalr	-1504(ra) # 8000468a <begin_op>

  if(omode & O_CREATE){
    80005c72:	f4c42783          	lw	a5,-180(s0)
    80005c76:	2007f793          	andi	a5,a5,512
    80005c7a:	cbdd                	beqz	a5,80005d30 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005c7c:	4681                	li	a3,0
    80005c7e:	4601                	li	a2,0
    80005c80:	4589                	li	a1,2
    80005c82:	f5040513          	addi	a0,s0,-176
    80005c86:	00000097          	auipc	ra,0x0
    80005c8a:	974080e7          	jalr	-1676(ra) # 800055fa <create>
    80005c8e:	892a                	mv	s2,a0
    if(ip == 0){
    80005c90:	c959                	beqz	a0,80005d26 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005c92:	04491703          	lh	a4,68(s2)
    80005c96:	478d                	li	a5,3
    80005c98:	00f71763          	bne	a4,a5,80005ca6 <sys_open+0x74>
    80005c9c:	04695703          	lhu	a4,70(s2)
    80005ca0:	47a5                	li	a5,9
    80005ca2:	0ce7ec63          	bltu	a5,a4,80005d7a <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005ca6:	fffff097          	auipc	ra,0xfffff
    80005caa:	df4080e7          	jalr	-524(ra) # 80004a9a <filealloc>
    80005cae:	89aa                	mv	s3,a0
    80005cb0:	10050263          	beqz	a0,80005db4 <sys_open+0x182>
    80005cb4:	00000097          	auipc	ra,0x0
    80005cb8:	904080e7          	jalr	-1788(ra) # 800055b8 <fdalloc>
    80005cbc:	84aa                	mv	s1,a0
    80005cbe:	0e054663          	bltz	a0,80005daa <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005cc2:	04491703          	lh	a4,68(s2)
    80005cc6:	478d                	li	a5,3
    80005cc8:	0cf70463          	beq	a4,a5,80005d90 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005ccc:	4789                	li	a5,2
    80005cce:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005cd2:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005cd6:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005cda:	f4c42783          	lw	a5,-180(s0)
    80005cde:	0017c713          	xori	a4,a5,1
    80005ce2:	8b05                	andi	a4,a4,1
    80005ce4:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005ce8:	0037f713          	andi	a4,a5,3
    80005cec:	00e03733          	snez	a4,a4
    80005cf0:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005cf4:	4007f793          	andi	a5,a5,1024
    80005cf8:	c791                	beqz	a5,80005d04 <sys_open+0xd2>
    80005cfa:	04491703          	lh	a4,68(s2)
    80005cfe:	4789                	li	a5,2
    80005d00:	08f70f63          	beq	a4,a5,80005d9e <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005d04:	854a                	mv	a0,s2
    80005d06:	ffffe097          	auipc	ra,0xffffe
    80005d0a:	070080e7          	jalr	112(ra) # 80003d76 <iunlock>
  end_op();
    80005d0e:	fffff097          	auipc	ra,0xfffff
    80005d12:	9fc080e7          	jalr	-1540(ra) # 8000470a <end_op>

  return fd;
}
    80005d16:	8526                	mv	a0,s1
    80005d18:	70ea                	ld	ra,184(sp)
    80005d1a:	744a                	ld	s0,176(sp)
    80005d1c:	74aa                	ld	s1,168(sp)
    80005d1e:	790a                	ld	s2,160(sp)
    80005d20:	69ea                	ld	s3,152(sp)
    80005d22:	6129                	addi	sp,sp,192
    80005d24:	8082                	ret
      end_op();
    80005d26:	fffff097          	auipc	ra,0xfffff
    80005d2a:	9e4080e7          	jalr	-1564(ra) # 8000470a <end_op>
      return -1;
    80005d2e:	b7e5                	j	80005d16 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005d30:	f5040513          	addi	a0,s0,-176
    80005d34:	ffffe097          	auipc	ra,0xffffe
    80005d38:	736080e7          	jalr	1846(ra) # 8000446a <namei>
    80005d3c:	892a                	mv	s2,a0
    80005d3e:	c905                	beqz	a0,80005d6e <sys_open+0x13c>
    ilock(ip);
    80005d40:	ffffe097          	auipc	ra,0xffffe
    80005d44:	f74080e7          	jalr	-140(ra) # 80003cb4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005d48:	04491703          	lh	a4,68(s2)
    80005d4c:	4785                	li	a5,1
    80005d4e:	f4f712e3          	bne	a4,a5,80005c92 <sys_open+0x60>
    80005d52:	f4c42783          	lw	a5,-180(s0)
    80005d56:	dba1                	beqz	a5,80005ca6 <sys_open+0x74>
      iunlockput(ip);
    80005d58:	854a                	mv	a0,s2
    80005d5a:	ffffe097          	auipc	ra,0xffffe
    80005d5e:	1bc080e7          	jalr	444(ra) # 80003f16 <iunlockput>
      end_op();
    80005d62:	fffff097          	auipc	ra,0xfffff
    80005d66:	9a8080e7          	jalr	-1624(ra) # 8000470a <end_op>
      return -1;
    80005d6a:	54fd                	li	s1,-1
    80005d6c:	b76d                	j	80005d16 <sys_open+0xe4>
      end_op();
    80005d6e:	fffff097          	auipc	ra,0xfffff
    80005d72:	99c080e7          	jalr	-1636(ra) # 8000470a <end_op>
      return -1;
    80005d76:	54fd                	li	s1,-1
    80005d78:	bf79                	j	80005d16 <sys_open+0xe4>
    iunlockput(ip);
    80005d7a:	854a                	mv	a0,s2
    80005d7c:	ffffe097          	auipc	ra,0xffffe
    80005d80:	19a080e7          	jalr	410(ra) # 80003f16 <iunlockput>
    end_op();
    80005d84:	fffff097          	auipc	ra,0xfffff
    80005d88:	986080e7          	jalr	-1658(ra) # 8000470a <end_op>
    return -1;
    80005d8c:	54fd                	li	s1,-1
    80005d8e:	b761                	j	80005d16 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005d90:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005d94:	04691783          	lh	a5,70(s2)
    80005d98:	02f99223          	sh	a5,36(s3)
    80005d9c:	bf2d                	j	80005cd6 <sys_open+0xa4>
    itrunc(ip);
    80005d9e:	854a                	mv	a0,s2
    80005da0:	ffffe097          	auipc	ra,0xffffe
    80005da4:	022080e7          	jalr	34(ra) # 80003dc2 <itrunc>
    80005da8:	bfb1                	j	80005d04 <sys_open+0xd2>
      fileclose(f);
    80005daa:	854e                	mv	a0,s3
    80005dac:	fffff097          	auipc	ra,0xfffff
    80005db0:	daa080e7          	jalr	-598(ra) # 80004b56 <fileclose>
    iunlockput(ip);
    80005db4:	854a                	mv	a0,s2
    80005db6:	ffffe097          	auipc	ra,0xffffe
    80005dba:	160080e7          	jalr	352(ra) # 80003f16 <iunlockput>
    end_op();
    80005dbe:	fffff097          	auipc	ra,0xfffff
    80005dc2:	94c080e7          	jalr	-1716(ra) # 8000470a <end_op>
    return -1;
    80005dc6:	54fd                	li	s1,-1
    80005dc8:	b7b9                	j	80005d16 <sys_open+0xe4>

0000000080005dca <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005dca:	7175                	addi	sp,sp,-144
    80005dcc:	e506                	sd	ra,136(sp)
    80005dce:	e122                	sd	s0,128(sp)
    80005dd0:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005dd2:	fffff097          	auipc	ra,0xfffff
    80005dd6:	8b8080e7          	jalr	-1864(ra) # 8000468a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005dda:	08000613          	li	a2,128
    80005dde:	f7040593          	addi	a1,s0,-144
    80005de2:	4501                	li	a0,0
    80005de4:	ffffd097          	auipc	ra,0xffffd
    80005de8:	262080e7          	jalr	610(ra) # 80003046 <argstr>
    80005dec:	02054963          	bltz	a0,80005e1e <sys_mkdir+0x54>
    80005df0:	4681                	li	a3,0
    80005df2:	4601                	li	a2,0
    80005df4:	4585                	li	a1,1
    80005df6:	f7040513          	addi	a0,s0,-144
    80005dfa:	00000097          	auipc	ra,0x0
    80005dfe:	800080e7          	jalr	-2048(ra) # 800055fa <create>
    80005e02:	cd11                	beqz	a0,80005e1e <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e04:	ffffe097          	auipc	ra,0xffffe
    80005e08:	112080e7          	jalr	274(ra) # 80003f16 <iunlockput>
  end_op();
    80005e0c:	fffff097          	auipc	ra,0xfffff
    80005e10:	8fe080e7          	jalr	-1794(ra) # 8000470a <end_op>
  return 0;
    80005e14:	4501                	li	a0,0
}
    80005e16:	60aa                	ld	ra,136(sp)
    80005e18:	640a                	ld	s0,128(sp)
    80005e1a:	6149                	addi	sp,sp,144
    80005e1c:	8082                	ret
    end_op();
    80005e1e:	fffff097          	auipc	ra,0xfffff
    80005e22:	8ec080e7          	jalr	-1812(ra) # 8000470a <end_op>
    return -1;
    80005e26:	557d                	li	a0,-1
    80005e28:	b7fd                	j	80005e16 <sys_mkdir+0x4c>

0000000080005e2a <sys_mknod>:

uint64
sys_mknod(void)
{
    80005e2a:	7135                	addi	sp,sp,-160
    80005e2c:	ed06                	sd	ra,152(sp)
    80005e2e:	e922                	sd	s0,144(sp)
    80005e30:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005e32:	fffff097          	auipc	ra,0xfffff
    80005e36:	858080e7          	jalr	-1960(ra) # 8000468a <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e3a:	08000613          	li	a2,128
    80005e3e:	f7040593          	addi	a1,s0,-144
    80005e42:	4501                	li	a0,0
    80005e44:	ffffd097          	auipc	ra,0xffffd
    80005e48:	202080e7          	jalr	514(ra) # 80003046 <argstr>
    80005e4c:	04054a63          	bltz	a0,80005ea0 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005e50:	f6c40593          	addi	a1,s0,-148
    80005e54:	4505                	li	a0,1
    80005e56:	ffffd097          	auipc	ra,0xffffd
    80005e5a:	1ac080e7          	jalr	428(ra) # 80003002 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e5e:	04054163          	bltz	a0,80005ea0 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005e62:	f6840593          	addi	a1,s0,-152
    80005e66:	4509                	li	a0,2
    80005e68:	ffffd097          	auipc	ra,0xffffd
    80005e6c:	19a080e7          	jalr	410(ra) # 80003002 <argint>
     argint(1, &major) < 0 ||
    80005e70:	02054863          	bltz	a0,80005ea0 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005e74:	f6841683          	lh	a3,-152(s0)
    80005e78:	f6c41603          	lh	a2,-148(s0)
    80005e7c:	458d                	li	a1,3
    80005e7e:	f7040513          	addi	a0,s0,-144
    80005e82:	fffff097          	auipc	ra,0xfffff
    80005e86:	778080e7          	jalr	1912(ra) # 800055fa <create>
     argint(2, &minor) < 0 ||
    80005e8a:	c919                	beqz	a0,80005ea0 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e8c:	ffffe097          	auipc	ra,0xffffe
    80005e90:	08a080e7          	jalr	138(ra) # 80003f16 <iunlockput>
  end_op();
    80005e94:	fffff097          	auipc	ra,0xfffff
    80005e98:	876080e7          	jalr	-1930(ra) # 8000470a <end_op>
  return 0;
    80005e9c:	4501                	li	a0,0
    80005e9e:	a031                	j	80005eaa <sys_mknod+0x80>
    end_op();
    80005ea0:	fffff097          	auipc	ra,0xfffff
    80005ea4:	86a080e7          	jalr	-1942(ra) # 8000470a <end_op>
    return -1;
    80005ea8:	557d                	li	a0,-1
}
    80005eaa:	60ea                	ld	ra,152(sp)
    80005eac:	644a                	ld	s0,144(sp)
    80005eae:	610d                	addi	sp,sp,160
    80005eb0:	8082                	ret

0000000080005eb2 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005eb2:	7135                	addi	sp,sp,-160
    80005eb4:	ed06                	sd	ra,152(sp)
    80005eb6:	e922                	sd	s0,144(sp)
    80005eb8:	e526                	sd	s1,136(sp)
    80005eba:	e14a                	sd	s2,128(sp)
    80005ebc:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005ebe:	ffffc097          	auipc	ra,0xffffc
    80005ec2:	ad8080e7          	jalr	-1320(ra) # 80001996 <myproc>
    80005ec6:	892a                	mv	s2,a0
  
  begin_op();
    80005ec8:	ffffe097          	auipc	ra,0xffffe
    80005ecc:	7c2080e7          	jalr	1986(ra) # 8000468a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005ed0:	08000613          	li	a2,128
    80005ed4:	f6040593          	addi	a1,s0,-160
    80005ed8:	4501                	li	a0,0
    80005eda:	ffffd097          	auipc	ra,0xffffd
    80005ede:	16c080e7          	jalr	364(ra) # 80003046 <argstr>
    80005ee2:	04054b63          	bltz	a0,80005f38 <sys_chdir+0x86>
    80005ee6:	f6040513          	addi	a0,s0,-160
    80005eea:	ffffe097          	auipc	ra,0xffffe
    80005eee:	580080e7          	jalr	1408(ra) # 8000446a <namei>
    80005ef2:	84aa                	mv	s1,a0
    80005ef4:	c131                	beqz	a0,80005f38 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005ef6:	ffffe097          	auipc	ra,0xffffe
    80005efa:	dbe080e7          	jalr	-578(ra) # 80003cb4 <ilock>
  if(ip->type != T_DIR){
    80005efe:	04449703          	lh	a4,68(s1)
    80005f02:	4785                	li	a5,1
    80005f04:	04f71063          	bne	a4,a5,80005f44 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005f08:	8526                	mv	a0,s1
    80005f0a:	ffffe097          	auipc	ra,0xffffe
    80005f0e:	e6c080e7          	jalr	-404(ra) # 80003d76 <iunlock>
  iput(p->cwd);
    80005f12:	17093503          	ld	a0,368(s2)
    80005f16:	ffffe097          	auipc	ra,0xffffe
    80005f1a:	f58080e7          	jalr	-168(ra) # 80003e6e <iput>
  end_op();
    80005f1e:	ffffe097          	auipc	ra,0xffffe
    80005f22:	7ec080e7          	jalr	2028(ra) # 8000470a <end_op>
  p->cwd = ip;
    80005f26:	16993823          	sd	s1,368(s2)
  return 0;
    80005f2a:	4501                	li	a0,0
}
    80005f2c:	60ea                	ld	ra,152(sp)
    80005f2e:	644a                	ld	s0,144(sp)
    80005f30:	64aa                	ld	s1,136(sp)
    80005f32:	690a                	ld	s2,128(sp)
    80005f34:	610d                	addi	sp,sp,160
    80005f36:	8082                	ret
    end_op();
    80005f38:	ffffe097          	auipc	ra,0xffffe
    80005f3c:	7d2080e7          	jalr	2002(ra) # 8000470a <end_op>
    return -1;
    80005f40:	557d                	li	a0,-1
    80005f42:	b7ed                	j	80005f2c <sys_chdir+0x7a>
    iunlockput(ip);
    80005f44:	8526                	mv	a0,s1
    80005f46:	ffffe097          	auipc	ra,0xffffe
    80005f4a:	fd0080e7          	jalr	-48(ra) # 80003f16 <iunlockput>
    end_op();
    80005f4e:	ffffe097          	auipc	ra,0xffffe
    80005f52:	7bc080e7          	jalr	1980(ra) # 8000470a <end_op>
    return -1;
    80005f56:	557d                	li	a0,-1
    80005f58:	bfd1                	j	80005f2c <sys_chdir+0x7a>

0000000080005f5a <sys_exec>:

uint64
sys_exec(void)
{
    80005f5a:	7145                	addi	sp,sp,-464
    80005f5c:	e786                	sd	ra,456(sp)
    80005f5e:	e3a2                	sd	s0,448(sp)
    80005f60:	ff26                	sd	s1,440(sp)
    80005f62:	fb4a                	sd	s2,432(sp)
    80005f64:	f74e                	sd	s3,424(sp)
    80005f66:	f352                	sd	s4,416(sp)
    80005f68:	ef56                	sd	s5,408(sp)
    80005f6a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005f6c:	08000613          	li	a2,128
    80005f70:	f4040593          	addi	a1,s0,-192
    80005f74:	4501                	li	a0,0
    80005f76:	ffffd097          	auipc	ra,0xffffd
    80005f7a:	0d0080e7          	jalr	208(ra) # 80003046 <argstr>
    return -1;
    80005f7e:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005f80:	0c054a63          	bltz	a0,80006054 <sys_exec+0xfa>
    80005f84:	e3840593          	addi	a1,s0,-456
    80005f88:	4505                	li	a0,1
    80005f8a:	ffffd097          	auipc	ra,0xffffd
    80005f8e:	09a080e7          	jalr	154(ra) # 80003024 <argaddr>
    80005f92:	0c054163          	bltz	a0,80006054 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005f96:	10000613          	li	a2,256
    80005f9a:	4581                	li	a1,0
    80005f9c:	e4040513          	addi	a0,s0,-448
    80005fa0:	ffffb097          	auipc	ra,0xffffb
    80005fa4:	d1e080e7          	jalr	-738(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005fa8:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005fac:	89a6                	mv	s3,s1
    80005fae:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005fb0:	02000a13          	li	s4,32
    80005fb4:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005fb8:	00391793          	slli	a5,s2,0x3
    80005fbc:	e3040593          	addi	a1,s0,-464
    80005fc0:	e3843503          	ld	a0,-456(s0)
    80005fc4:	953e                	add	a0,a0,a5
    80005fc6:	ffffd097          	auipc	ra,0xffffd
    80005fca:	fa2080e7          	jalr	-94(ra) # 80002f68 <fetchaddr>
    80005fce:	02054a63          	bltz	a0,80006002 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005fd2:	e3043783          	ld	a5,-464(s0)
    80005fd6:	c3b9                	beqz	a5,8000601c <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005fd8:	ffffb097          	auipc	ra,0xffffb
    80005fdc:	afa080e7          	jalr	-1286(ra) # 80000ad2 <kalloc>
    80005fe0:	85aa                	mv	a1,a0
    80005fe2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005fe6:	cd11                	beqz	a0,80006002 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005fe8:	6605                	lui	a2,0x1
    80005fea:	e3043503          	ld	a0,-464(s0)
    80005fee:	ffffd097          	auipc	ra,0xffffd
    80005ff2:	fcc080e7          	jalr	-52(ra) # 80002fba <fetchstr>
    80005ff6:	00054663          	bltz	a0,80006002 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005ffa:	0905                	addi	s2,s2,1
    80005ffc:	09a1                	addi	s3,s3,8
    80005ffe:	fb491be3          	bne	s2,s4,80005fb4 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006002:	10048913          	addi	s2,s1,256
    80006006:	6088                	ld	a0,0(s1)
    80006008:	c529                	beqz	a0,80006052 <sys_exec+0xf8>
    kfree(argv[i]);
    8000600a:	ffffb097          	auipc	ra,0xffffb
    8000600e:	9cc080e7          	jalr	-1588(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006012:	04a1                	addi	s1,s1,8
    80006014:	ff2499e3          	bne	s1,s2,80006006 <sys_exec+0xac>
  return -1;
    80006018:	597d                	li	s2,-1
    8000601a:	a82d                	j	80006054 <sys_exec+0xfa>
      argv[i] = 0;
    8000601c:	0a8e                	slli	s5,s5,0x3
    8000601e:	fc040793          	addi	a5,s0,-64
    80006022:	9abe                	add	s5,s5,a5
    80006024:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd8e80>
  int ret = exec(path, argv);
    80006028:	e4040593          	addi	a1,s0,-448
    8000602c:	f4040513          	addi	a0,s0,-192
    80006030:	fffff097          	auipc	ra,0xfffff
    80006034:	178080e7          	jalr	376(ra) # 800051a8 <exec>
    80006038:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000603a:	10048993          	addi	s3,s1,256
    8000603e:	6088                	ld	a0,0(s1)
    80006040:	c911                	beqz	a0,80006054 <sys_exec+0xfa>
    kfree(argv[i]);
    80006042:	ffffb097          	auipc	ra,0xffffb
    80006046:	994080e7          	jalr	-1644(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000604a:	04a1                	addi	s1,s1,8
    8000604c:	ff3499e3          	bne	s1,s3,8000603e <sys_exec+0xe4>
    80006050:	a011                	j	80006054 <sys_exec+0xfa>
  return -1;
    80006052:	597d                	li	s2,-1
}
    80006054:	854a                	mv	a0,s2
    80006056:	60be                	ld	ra,456(sp)
    80006058:	641e                	ld	s0,448(sp)
    8000605a:	74fa                	ld	s1,440(sp)
    8000605c:	795a                	ld	s2,432(sp)
    8000605e:	79ba                	ld	s3,424(sp)
    80006060:	7a1a                	ld	s4,416(sp)
    80006062:	6afa                	ld	s5,408(sp)
    80006064:	6179                	addi	sp,sp,464
    80006066:	8082                	ret

0000000080006068 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006068:	7139                	addi	sp,sp,-64
    8000606a:	fc06                	sd	ra,56(sp)
    8000606c:	f822                	sd	s0,48(sp)
    8000606e:	f426                	sd	s1,40(sp)
    80006070:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006072:	ffffc097          	auipc	ra,0xffffc
    80006076:	924080e7          	jalr	-1756(ra) # 80001996 <myproc>
    8000607a:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    8000607c:	fd840593          	addi	a1,s0,-40
    80006080:	4501                	li	a0,0
    80006082:	ffffd097          	auipc	ra,0xffffd
    80006086:	fa2080e7          	jalr	-94(ra) # 80003024 <argaddr>
    return -1;
    8000608a:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    8000608c:	0e054063          	bltz	a0,8000616c <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006090:	fc840593          	addi	a1,s0,-56
    80006094:	fd040513          	addi	a0,s0,-48
    80006098:	fffff097          	auipc	ra,0xfffff
    8000609c:	dee080e7          	jalr	-530(ra) # 80004e86 <pipealloc>
    return -1;
    800060a0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800060a2:	0c054563          	bltz	a0,8000616c <sys_pipe+0x104>
  fd0 = -1;
    800060a6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800060aa:	fd043503          	ld	a0,-48(s0)
    800060ae:	fffff097          	auipc	ra,0xfffff
    800060b2:	50a080e7          	jalr	1290(ra) # 800055b8 <fdalloc>
    800060b6:	fca42223          	sw	a0,-60(s0)
    800060ba:	08054c63          	bltz	a0,80006152 <sys_pipe+0xea>
    800060be:	fc843503          	ld	a0,-56(s0)
    800060c2:	fffff097          	auipc	ra,0xfffff
    800060c6:	4f6080e7          	jalr	1270(ra) # 800055b8 <fdalloc>
    800060ca:	fca42023          	sw	a0,-64(s0)
    800060ce:	06054863          	bltz	a0,8000613e <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800060d2:	4691                	li	a3,4
    800060d4:	fc440613          	addi	a2,s0,-60
    800060d8:	fd843583          	ld	a1,-40(s0)
    800060dc:	78a8                	ld	a0,112(s1)
    800060de:	ffffb097          	auipc	ra,0xffffb
    800060e2:	560080e7          	jalr	1376(ra) # 8000163e <copyout>
    800060e6:	02054063          	bltz	a0,80006106 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800060ea:	4691                	li	a3,4
    800060ec:	fc040613          	addi	a2,s0,-64
    800060f0:	fd843583          	ld	a1,-40(s0)
    800060f4:	0591                	addi	a1,a1,4
    800060f6:	78a8                	ld	a0,112(s1)
    800060f8:	ffffb097          	auipc	ra,0xffffb
    800060fc:	546080e7          	jalr	1350(ra) # 8000163e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006100:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006102:	06055563          	bgez	a0,8000616c <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006106:	fc442783          	lw	a5,-60(s0)
    8000610a:	07f9                	addi	a5,a5,30
    8000610c:	078e                	slli	a5,a5,0x3
    8000610e:	97a6                	add	a5,a5,s1
    80006110:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006114:	fc042503          	lw	a0,-64(s0)
    80006118:	0579                	addi	a0,a0,30
    8000611a:	050e                	slli	a0,a0,0x3
    8000611c:	9526                	add	a0,a0,s1
    8000611e:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006122:	fd043503          	ld	a0,-48(s0)
    80006126:	fffff097          	auipc	ra,0xfffff
    8000612a:	a30080e7          	jalr	-1488(ra) # 80004b56 <fileclose>
    fileclose(wf);
    8000612e:	fc843503          	ld	a0,-56(s0)
    80006132:	fffff097          	auipc	ra,0xfffff
    80006136:	a24080e7          	jalr	-1500(ra) # 80004b56 <fileclose>
    return -1;
    8000613a:	57fd                	li	a5,-1
    8000613c:	a805                	j	8000616c <sys_pipe+0x104>
    if(fd0 >= 0)
    8000613e:	fc442783          	lw	a5,-60(s0)
    80006142:	0007c863          	bltz	a5,80006152 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006146:	01e78513          	addi	a0,a5,30
    8000614a:	050e                	slli	a0,a0,0x3
    8000614c:	9526                	add	a0,a0,s1
    8000614e:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006152:	fd043503          	ld	a0,-48(s0)
    80006156:	fffff097          	auipc	ra,0xfffff
    8000615a:	a00080e7          	jalr	-1536(ra) # 80004b56 <fileclose>
    fileclose(wf);
    8000615e:	fc843503          	ld	a0,-56(s0)
    80006162:	fffff097          	auipc	ra,0xfffff
    80006166:	9f4080e7          	jalr	-1548(ra) # 80004b56 <fileclose>
    return -1;
    8000616a:	57fd                	li	a5,-1
}
    8000616c:	853e                	mv	a0,a5
    8000616e:	70e2                	ld	ra,56(sp)
    80006170:	7442                	ld	s0,48(sp)
    80006172:	74a2                	ld	s1,40(sp)
    80006174:	6121                	addi	sp,sp,64
    80006176:	8082                	ret
	...

0000000080006180 <kernelvec>:
    80006180:	7111                	addi	sp,sp,-256
    80006182:	e006                	sd	ra,0(sp)
    80006184:	e40a                	sd	sp,8(sp)
    80006186:	e80e                	sd	gp,16(sp)
    80006188:	ec12                	sd	tp,24(sp)
    8000618a:	f016                	sd	t0,32(sp)
    8000618c:	f41a                	sd	t1,40(sp)
    8000618e:	f81e                	sd	t2,48(sp)
    80006190:	fc22                	sd	s0,56(sp)
    80006192:	e0a6                	sd	s1,64(sp)
    80006194:	e4aa                	sd	a0,72(sp)
    80006196:	e8ae                	sd	a1,80(sp)
    80006198:	ecb2                	sd	a2,88(sp)
    8000619a:	f0b6                	sd	a3,96(sp)
    8000619c:	f4ba                	sd	a4,104(sp)
    8000619e:	f8be                	sd	a5,112(sp)
    800061a0:	fcc2                	sd	a6,120(sp)
    800061a2:	e146                	sd	a7,128(sp)
    800061a4:	e54a                	sd	s2,136(sp)
    800061a6:	e94e                	sd	s3,144(sp)
    800061a8:	ed52                	sd	s4,152(sp)
    800061aa:	f156                	sd	s5,160(sp)
    800061ac:	f55a                	sd	s6,168(sp)
    800061ae:	f95e                	sd	s7,176(sp)
    800061b0:	fd62                	sd	s8,184(sp)
    800061b2:	e1e6                	sd	s9,192(sp)
    800061b4:	e5ea                	sd	s10,200(sp)
    800061b6:	e9ee                	sd	s11,208(sp)
    800061b8:	edf2                	sd	t3,216(sp)
    800061ba:	f1f6                	sd	t4,224(sp)
    800061bc:	f5fa                	sd	t5,232(sp)
    800061be:	f9fe                	sd	t6,240(sp)
    800061c0:	c75fc0ef          	jal	ra,80002e34 <kerneltrap>
    800061c4:	6082                	ld	ra,0(sp)
    800061c6:	6122                	ld	sp,8(sp)
    800061c8:	61c2                	ld	gp,16(sp)
    800061ca:	7282                	ld	t0,32(sp)
    800061cc:	7322                	ld	t1,40(sp)
    800061ce:	73c2                	ld	t2,48(sp)
    800061d0:	7462                	ld	s0,56(sp)
    800061d2:	6486                	ld	s1,64(sp)
    800061d4:	6526                	ld	a0,72(sp)
    800061d6:	65c6                	ld	a1,80(sp)
    800061d8:	6666                	ld	a2,88(sp)
    800061da:	7686                	ld	a3,96(sp)
    800061dc:	7726                	ld	a4,104(sp)
    800061de:	77c6                	ld	a5,112(sp)
    800061e0:	7866                	ld	a6,120(sp)
    800061e2:	688a                	ld	a7,128(sp)
    800061e4:	692a                	ld	s2,136(sp)
    800061e6:	69ca                	ld	s3,144(sp)
    800061e8:	6a6a                	ld	s4,152(sp)
    800061ea:	7a8a                	ld	s5,160(sp)
    800061ec:	7b2a                	ld	s6,168(sp)
    800061ee:	7bca                	ld	s7,176(sp)
    800061f0:	7c6a                	ld	s8,184(sp)
    800061f2:	6c8e                	ld	s9,192(sp)
    800061f4:	6d2e                	ld	s10,200(sp)
    800061f6:	6dce                	ld	s11,208(sp)
    800061f8:	6e6e                	ld	t3,216(sp)
    800061fa:	7e8e                	ld	t4,224(sp)
    800061fc:	7f2e                	ld	t5,232(sp)
    800061fe:	7fce                	ld	t6,240(sp)
    80006200:	6111                	addi	sp,sp,256
    80006202:	10200073          	sret
    80006206:	00000013          	nop
    8000620a:	00000013          	nop
    8000620e:	0001                	nop

0000000080006210 <timervec>:
    80006210:	34051573          	csrrw	a0,mscratch,a0
    80006214:	e10c                	sd	a1,0(a0)
    80006216:	e510                	sd	a2,8(a0)
    80006218:	e914                	sd	a3,16(a0)
    8000621a:	6d0c                	ld	a1,24(a0)
    8000621c:	7110                	ld	a2,32(a0)
    8000621e:	6194                	ld	a3,0(a1)
    80006220:	96b2                	add	a3,a3,a2
    80006222:	e194                	sd	a3,0(a1)
    80006224:	4589                	li	a1,2
    80006226:	14459073          	csrw	sip,a1
    8000622a:	6914                	ld	a3,16(a0)
    8000622c:	6510                	ld	a2,8(a0)
    8000622e:	610c                	ld	a1,0(a0)
    80006230:	34051573          	csrrw	a0,mscratch,a0
    80006234:	30200073          	mret
	...

000000008000623a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000623a:	1141                	addi	sp,sp,-16
    8000623c:	e422                	sd	s0,8(sp)
    8000623e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006240:	0c0007b7          	lui	a5,0xc000
    80006244:	4705                	li	a4,1
    80006246:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006248:	c3d8                	sw	a4,4(a5)
}
    8000624a:	6422                	ld	s0,8(sp)
    8000624c:	0141                	addi	sp,sp,16
    8000624e:	8082                	ret

0000000080006250 <plicinithart>:

void
plicinithart(void)
{
    80006250:	1141                	addi	sp,sp,-16
    80006252:	e406                	sd	ra,8(sp)
    80006254:	e022                	sd	s0,0(sp)
    80006256:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006258:	ffffb097          	auipc	ra,0xffffb
    8000625c:	712080e7          	jalr	1810(ra) # 8000196a <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006260:	0085171b          	slliw	a4,a0,0x8
    80006264:	0c0027b7          	lui	a5,0xc002
    80006268:	97ba                	add	a5,a5,a4
    8000626a:	40200713          	li	a4,1026
    8000626e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006272:	00d5151b          	slliw	a0,a0,0xd
    80006276:	0c2017b7          	lui	a5,0xc201
    8000627a:	953e                	add	a0,a0,a5
    8000627c:	00052023          	sw	zero,0(a0)
}
    80006280:	60a2                	ld	ra,8(sp)
    80006282:	6402                	ld	s0,0(sp)
    80006284:	0141                	addi	sp,sp,16
    80006286:	8082                	ret

0000000080006288 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006288:	1141                	addi	sp,sp,-16
    8000628a:	e406                	sd	ra,8(sp)
    8000628c:	e022                	sd	s0,0(sp)
    8000628e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006290:	ffffb097          	auipc	ra,0xffffb
    80006294:	6da080e7          	jalr	1754(ra) # 8000196a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006298:	00d5179b          	slliw	a5,a0,0xd
    8000629c:	0c201537          	lui	a0,0xc201
    800062a0:	953e                	add	a0,a0,a5
  return irq;
}
    800062a2:	4148                	lw	a0,4(a0)
    800062a4:	60a2                	ld	ra,8(sp)
    800062a6:	6402                	ld	s0,0(sp)
    800062a8:	0141                	addi	sp,sp,16
    800062aa:	8082                	ret

00000000800062ac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800062ac:	1101                	addi	sp,sp,-32
    800062ae:	ec06                	sd	ra,24(sp)
    800062b0:	e822                	sd	s0,16(sp)
    800062b2:	e426                	sd	s1,8(sp)
    800062b4:	1000                	addi	s0,sp,32
    800062b6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800062b8:	ffffb097          	auipc	ra,0xffffb
    800062bc:	6b2080e7          	jalr	1714(ra) # 8000196a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800062c0:	00d5151b          	slliw	a0,a0,0xd
    800062c4:	0c2017b7          	lui	a5,0xc201
    800062c8:	97aa                	add	a5,a5,a0
    800062ca:	c3c4                	sw	s1,4(a5)
}
    800062cc:	60e2                	ld	ra,24(sp)
    800062ce:	6442                	ld	s0,16(sp)
    800062d0:	64a2                	ld	s1,8(sp)
    800062d2:	6105                	addi	sp,sp,32
    800062d4:	8082                	ret

00000000800062d6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800062d6:	1141                	addi	sp,sp,-16
    800062d8:	e406                	sd	ra,8(sp)
    800062da:	e022                	sd	s0,0(sp)
    800062dc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800062de:	479d                	li	a5,7
    800062e0:	06a7c963          	blt	a5,a0,80006352 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    800062e4:	0001d797          	auipc	a5,0x1d
    800062e8:	d1c78793          	addi	a5,a5,-740 # 80023000 <disk>
    800062ec:	00a78733          	add	a4,a5,a0
    800062f0:	6789                	lui	a5,0x2
    800062f2:	97ba                	add	a5,a5,a4
    800062f4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800062f8:	e7ad                	bnez	a5,80006362 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800062fa:	00451793          	slli	a5,a0,0x4
    800062fe:	0001f717          	auipc	a4,0x1f
    80006302:	d0270713          	addi	a4,a4,-766 # 80025000 <disk+0x2000>
    80006306:	6314                	ld	a3,0(a4)
    80006308:	96be                	add	a3,a3,a5
    8000630a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000630e:	6314                	ld	a3,0(a4)
    80006310:	96be                	add	a3,a3,a5
    80006312:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006316:	6314                	ld	a3,0(a4)
    80006318:	96be                	add	a3,a3,a5
    8000631a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000631e:	6318                	ld	a4,0(a4)
    80006320:	97ba                	add	a5,a5,a4
    80006322:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006326:	0001d797          	auipc	a5,0x1d
    8000632a:	cda78793          	addi	a5,a5,-806 # 80023000 <disk>
    8000632e:	97aa                	add	a5,a5,a0
    80006330:	6509                	lui	a0,0x2
    80006332:	953e                	add	a0,a0,a5
    80006334:	4785                	li	a5,1
    80006336:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000633a:	0001f517          	auipc	a0,0x1f
    8000633e:	cde50513          	addi	a0,a0,-802 # 80025018 <disk+0x2018>
    80006342:	ffffc097          	auipc	ra,0xffffc
    80006346:	010080e7          	jalr	16(ra) # 80002352 <wakeup>
}
    8000634a:	60a2                	ld	ra,8(sp)
    8000634c:	6402                	ld	s0,0(sp)
    8000634e:	0141                	addi	sp,sp,16
    80006350:	8082                	ret
    panic("free_desc 1");
    80006352:	00002517          	auipc	a0,0x2
    80006356:	64650513          	addi	a0,a0,1606 # 80008998 <syscalls+0x368>
    8000635a:	ffffa097          	auipc	ra,0xffffa
    8000635e:	1d0080e7          	jalr	464(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006362:	00002517          	auipc	a0,0x2
    80006366:	64650513          	addi	a0,a0,1606 # 800089a8 <syscalls+0x378>
    8000636a:	ffffa097          	auipc	ra,0xffffa
    8000636e:	1c0080e7          	jalr	448(ra) # 8000052a <panic>

0000000080006372 <virtio_disk_init>:
{
    80006372:	1101                	addi	sp,sp,-32
    80006374:	ec06                	sd	ra,24(sp)
    80006376:	e822                	sd	s0,16(sp)
    80006378:	e426                	sd	s1,8(sp)
    8000637a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000637c:	00002597          	auipc	a1,0x2
    80006380:	63c58593          	addi	a1,a1,1596 # 800089b8 <syscalls+0x388>
    80006384:	0001f517          	auipc	a0,0x1f
    80006388:	da450513          	addi	a0,a0,-604 # 80025128 <disk+0x2128>
    8000638c:	ffffa097          	auipc	ra,0xffffa
    80006390:	7a6080e7          	jalr	1958(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006394:	100017b7          	lui	a5,0x10001
    80006398:	4398                	lw	a4,0(a5)
    8000639a:	2701                	sext.w	a4,a4
    8000639c:	747277b7          	lui	a5,0x74727
    800063a0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800063a4:	0ef71163          	bne	a4,a5,80006486 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800063a8:	100017b7          	lui	a5,0x10001
    800063ac:	43dc                	lw	a5,4(a5)
    800063ae:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063b0:	4705                	li	a4,1
    800063b2:	0ce79a63          	bne	a5,a4,80006486 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063b6:	100017b7          	lui	a5,0x10001
    800063ba:	479c                	lw	a5,8(a5)
    800063bc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800063be:	4709                	li	a4,2
    800063c0:	0ce79363          	bne	a5,a4,80006486 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800063c4:	100017b7          	lui	a5,0x10001
    800063c8:	47d8                	lw	a4,12(a5)
    800063ca:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063cc:	554d47b7          	lui	a5,0x554d4
    800063d0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800063d4:	0af71963          	bne	a4,a5,80006486 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800063d8:	100017b7          	lui	a5,0x10001
    800063dc:	4705                	li	a4,1
    800063de:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063e0:	470d                	li	a4,3
    800063e2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800063e4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800063e6:	c7ffe737          	lui	a4,0xc7ffe
    800063ea:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    800063ee:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800063f0:	2701                	sext.w	a4,a4
    800063f2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063f4:	472d                	li	a4,11
    800063f6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063f8:	473d                	li	a4,15
    800063fa:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800063fc:	6705                	lui	a4,0x1
    800063fe:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006400:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006404:	5bdc                	lw	a5,52(a5)
    80006406:	2781                	sext.w	a5,a5
  if(max == 0)
    80006408:	c7d9                	beqz	a5,80006496 <virtio_disk_init+0x124>
  if(max < NUM)
    8000640a:	471d                	li	a4,7
    8000640c:	08f77d63          	bgeu	a4,a5,800064a6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006410:	100014b7          	lui	s1,0x10001
    80006414:	47a1                	li	a5,8
    80006416:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006418:	6609                	lui	a2,0x2
    8000641a:	4581                	li	a1,0
    8000641c:	0001d517          	auipc	a0,0x1d
    80006420:	be450513          	addi	a0,a0,-1052 # 80023000 <disk>
    80006424:	ffffb097          	auipc	ra,0xffffb
    80006428:	89a080e7          	jalr	-1894(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000642c:	0001d717          	auipc	a4,0x1d
    80006430:	bd470713          	addi	a4,a4,-1068 # 80023000 <disk>
    80006434:	00c75793          	srli	a5,a4,0xc
    80006438:	2781                	sext.w	a5,a5
    8000643a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000643c:	0001f797          	auipc	a5,0x1f
    80006440:	bc478793          	addi	a5,a5,-1084 # 80025000 <disk+0x2000>
    80006444:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006446:	0001d717          	auipc	a4,0x1d
    8000644a:	c3a70713          	addi	a4,a4,-966 # 80023080 <disk+0x80>
    8000644e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006450:	0001e717          	auipc	a4,0x1e
    80006454:	bb070713          	addi	a4,a4,-1104 # 80024000 <disk+0x1000>
    80006458:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000645a:	4705                	li	a4,1
    8000645c:	00e78c23          	sb	a4,24(a5)
    80006460:	00e78ca3          	sb	a4,25(a5)
    80006464:	00e78d23          	sb	a4,26(a5)
    80006468:	00e78da3          	sb	a4,27(a5)
    8000646c:	00e78e23          	sb	a4,28(a5)
    80006470:	00e78ea3          	sb	a4,29(a5)
    80006474:	00e78f23          	sb	a4,30(a5)
    80006478:	00e78fa3          	sb	a4,31(a5)
}
    8000647c:	60e2                	ld	ra,24(sp)
    8000647e:	6442                	ld	s0,16(sp)
    80006480:	64a2                	ld	s1,8(sp)
    80006482:	6105                	addi	sp,sp,32
    80006484:	8082                	ret
    panic("could not find virtio disk");
    80006486:	00002517          	auipc	a0,0x2
    8000648a:	54250513          	addi	a0,a0,1346 # 800089c8 <syscalls+0x398>
    8000648e:	ffffa097          	auipc	ra,0xffffa
    80006492:	09c080e7          	jalr	156(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    80006496:	00002517          	auipc	a0,0x2
    8000649a:	55250513          	addi	a0,a0,1362 # 800089e8 <syscalls+0x3b8>
    8000649e:	ffffa097          	auipc	ra,0xffffa
    800064a2:	08c080e7          	jalr	140(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    800064a6:	00002517          	auipc	a0,0x2
    800064aa:	56250513          	addi	a0,a0,1378 # 80008a08 <syscalls+0x3d8>
    800064ae:	ffffa097          	auipc	ra,0xffffa
    800064b2:	07c080e7          	jalr	124(ra) # 8000052a <panic>

00000000800064b6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800064b6:	7119                	addi	sp,sp,-128
    800064b8:	fc86                	sd	ra,120(sp)
    800064ba:	f8a2                	sd	s0,112(sp)
    800064bc:	f4a6                	sd	s1,104(sp)
    800064be:	f0ca                	sd	s2,96(sp)
    800064c0:	ecce                	sd	s3,88(sp)
    800064c2:	e8d2                	sd	s4,80(sp)
    800064c4:	e4d6                	sd	s5,72(sp)
    800064c6:	e0da                	sd	s6,64(sp)
    800064c8:	fc5e                	sd	s7,56(sp)
    800064ca:	f862                	sd	s8,48(sp)
    800064cc:	f466                	sd	s9,40(sp)
    800064ce:	f06a                	sd	s10,32(sp)
    800064d0:	ec6e                	sd	s11,24(sp)
    800064d2:	0100                	addi	s0,sp,128
    800064d4:	8aaa                	mv	s5,a0
    800064d6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800064d8:	00c52c83          	lw	s9,12(a0)
    800064dc:	001c9c9b          	slliw	s9,s9,0x1
    800064e0:	1c82                	slli	s9,s9,0x20
    800064e2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800064e6:	0001f517          	auipc	a0,0x1f
    800064ea:	c4250513          	addi	a0,a0,-958 # 80025128 <disk+0x2128>
    800064ee:	ffffa097          	auipc	ra,0xffffa
    800064f2:	6d4080e7          	jalr	1748(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    800064f6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800064f8:	44a1                	li	s1,8
      disk.free[i] = 0;
    800064fa:	0001dc17          	auipc	s8,0x1d
    800064fe:	b06c0c13          	addi	s8,s8,-1274 # 80023000 <disk>
    80006502:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006504:	4b0d                	li	s6,3
    80006506:	a0ad                	j	80006570 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006508:	00fc0733          	add	a4,s8,a5
    8000650c:	975e                	add	a4,a4,s7
    8000650e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006512:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006514:	0207c563          	bltz	a5,8000653e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006518:	2905                	addiw	s2,s2,1
    8000651a:	0611                	addi	a2,a2,4
    8000651c:	19690d63          	beq	s2,s6,800066b6 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006520:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006522:	0001f717          	auipc	a4,0x1f
    80006526:	af670713          	addi	a4,a4,-1290 # 80025018 <disk+0x2018>
    8000652a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000652c:	00074683          	lbu	a3,0(a4)
    80006530:	fee1                	bnez	a3,80006508 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006532:	2785                	addiw	a5,a5,1
    80006534:	0705                	addi	a4,a4,1
    80006536:	fe979be3          	bne	a5,s1,8000652c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000653a:	57fd                	li	a5,-1
    8000653c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000653e:	01205d63          	blez	s2,80006558 <virtio_disk_rw+0xa2>
    80006542:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006544:	000a2503          	lw	a0,0(s4)
    80006548:	00000097          	auipc	ra,0x0
    8000654c:	d8e080e7          	jalr	-626(ra) # 800062d6 <free_desc>
      for(int j = 0; j < i; j++)
    80006550:	2d85                	addiw	s11,s11,1
    80006552:	0a11                	addi	s4,s4,4
    80006554:	ffb918e3          	bne	s2,s11,80006544 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006558:	0001f597          	auipc	a1,0x1f
    8000655c:	bd058593          	addi	a1,a1,-1072 # 80025128 <disk+0x2128>
    80006560:	0001f517          	auipc	a0,0x1f
    80006564:	ab850513          	addi	a0,a0,-1352 # 80025018 <disk+0x2018>
    80006568:	ffffc097          	auipc	ra,0xffffc
    8000656c:	c5e080e7          	jalr	-930(ra) # 800021c6 <sleep>
  for(int i = 0; i < 3; i++){
    80006570:	f8040a13          	addi	s4,s0,-128
{
    80006574:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006576:	894e                	mv	s2,s3
    80006578:	b765                	j	80006520 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000657a:	0001f697          	auipc	a3,0x1f
    8000657e:	a866b683          	ld	a3,-1402(a3) # 80025000 <disk+0x2000>
    80006582:	96ba                	add	a3,a3,a4
    80006584:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006588:	0001d817          	auipc	a6,0x1d
    8000658c:	a7880813          	addi	a6,a6,-1416 # 80023000 <disk>
    80006590:	0001f697          	auipc	a3,0x1f
    80006594:	a7068693          	addi	a3,a3,-1424 # 80025000 <disk+0x2000>
    80006598:	6290                	ld	a2,0(a3)
    8000659a:	963a                	add	a2,a2,a4
    8000659c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800065a0:	0015e593          	ori	a1,a1,1
    800065a4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800065a8:	f8842603          	lw	a2,-120(s0)
    800065ac:	628c                	ld	a1,0(a3)
    800065ae:	972e                	add	a4,a4,a1
    800065b0:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800065b4:	20050593          	addi	a1,a0,512
    800065b8:	0592                	slli	a1,a1,0x4
    800065ba:	95c2                	add	a1,a1,a6
    800065bc:	577d                	li	a4,-1
    800065be:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800065c2:	00461713          	slli	a4,a2,0x4
    800065c6:	6290                	ld	a2,0(a3)
    800065c8:	963a                	add	a2,a2,a4
    800065ca:	03078793          	addi	a5,a5,48
    800065ce:	97c2                	add	a5,a5,a6
    800065d0:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    800065d2:	629c                	ld	a5,0(a3)
    800065d4:	97ba                	add	a5,a5,a4
    800065d6:	4605                	li	a2,1
    800065d8:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800065da:	629c                	ld	a5,0(a3)
    800065dc:	97ba                	add	a5,a5,a4
    800065de:	4809                	li	a6,2
    800065e0:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800065e4:	629c                	ld	a5,0(a3)
    800065e6:	973e                	add	a4,a4,a5
    800065e8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800065ec:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800065f0:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800065f4:	6698                	ld	a4,8(a3)
    800065f6:	00275783          	lhu	a5,2(a4)
    800065fa:	8b9d                	andi	a5,a5,7
    800065fc:	0786                	slli	a5,a5,0x1
    800065fe:	97ba                	add	a5,a5,a4
    80006600:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006604:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006608:	6698                	ld	a4,8(a3)
    8000660a:	00275783          	lhu	a5,2(a4)
    8000660e:	2785                	addiw	a5,a5,1
    80006610:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006614:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006618:	100017b7          	lui	a5,0x10001
    8000661c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006620:	004aa783          	lw	a5,4(s5)
    80006624:	02c79163          	bne	a5,a2,80006646 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006628:	0001f917          	auipc	s2,0x1f
    8000662c:	b0090913          	addi	s2,s2,-1280 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    80006630:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006632:	85ca                	mv	a1,s2
    80006634:	8556                	mv	a0,s5
    80006636:	ffffc097          	auipc	ra,0xffffc
    8000663a:	b90080e7          	jalr	-1136(ra) # 800021c6 <sleep>
  while(b->disk == 1) {
    8000663e:	004aa783          	lw	a5,4(s5)
    80006642:	fe9788e3          	beq	a5,s1,80006632 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006646:	f8042903          	lw	s2,-128(s0)
    8000664a:	20090793          	addi	a5,s2,512
    8000664e:	00479713          	slli	a4,a5,0x4
    80006652:	0001d797          	auipc	a5,0x1d
    80006656:	9ae78793          	addi	a5,a5,-1618 # 80023000 <disk>
    8000665a:	97ba                	add	a5,a5,a4
    8000665c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006660:	0001f997          	auipc	s3,0x1f
    80006664:	9a098993          	addi	s3,s3,-1632 # 80025000 <disk+0x2000>
    80006668:	00491713          	slli	a4,s2,0x4
    8000666c:	0009b783          	ld	a5,0(s3)
    80006670:	97ba                	add	a5,a5,a4
    80006672:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006676:	854a                	mv	a0,s2
    80006678:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000667c:	00000097          	auipc	ra,0x0
    80006680:	c5a080e7          	jalr	-934(ra) # 800062d6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006684:	8885                	andi	s1,s1,1
    80006686:	f0ed                	bnez	s1,80006668 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006688:	0001f517          	auipc	a0,0x1f
    8000668c:	aa050513          	addi	a0,a0,-1376 # 80025128 <disk+0x2128>
    80006690:	ffffa097          	auipc	ra,0xffffa
    80006694:	5e6080e7          	jalr	1510(ra) # 80000c76 <release>
}
    80006698:	70e6                	ld	ra,120(sp)
    8000669a:	7446                	ld	s0,112(sp)
    8000669c:	74a6                	ld	s1,104(sp)
    8000669e:	7906                	ld	s2,96(sp)
    800066a0:	69e6                	ld	s3,88(sp)
    800066a2:	6a46                	ld	s4,80(sp)
    800066a4:	6aa6                	ld	s5,72(sp)
    800066a6:	6b06                	ld	s6,64(sp)
    800066a8:	7be2                	ld	s7,56(sp)
    800066aa:	7c42                	ld	s8,48(sp)
    800066ac:	7ca2                	ld	s9,40(sp)
    800066ae:	7d02                	ld	s10,32(sp)
    800066b0:	6de2                	ld	s11,24(sp)
    800066b2:	6109                	addi	sp,sp,128
    800066b4:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800066b6:	f8042503          	lw	a0,-128(s0)
    800066ba:	20050793          	addi	a5,a0,512
    800066be:	0792                	slli	a5,a5,0x4
  if(write)
    800066c0:	0001d817          	auipc	a6,0x1d
    800066c4:	94080813          	addi	a6,a6,-1728 # 80023000 <disk>
    800066c8:	00f80733          	add	a4,a6,a5
    800066cc:	01a036b3          	snez	a3,s10
    800066d0:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    800066d4:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800066d8:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800066dc:	7679                	lui	a2,0xffffe
    800066de:	963e                	add	a2,a2,a5
    800066e0:	0001f697          	auipc	a3,0x1f
    800066e4:	92068693          	addi	a3,a3,-1760 # 80025000 <disk+0x2000>
    800066e8:	6298                	ld	a4,0(a3)
    800066ea:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800066ec:	0a878593          	addi	a1,a5,168
    800066f0:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    800066f2:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800066f4:	6298                	ld	a4,0(a3)
    800066f6:	9732                	add	a4,a4,a2
    800066f8:	45c1                	li	a1,16
    800066fa:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800066fc:	6298                	ld	a4,0(a3)
    800066fe:	9732                	add	a4,a4,a2
    80006700:	4585                	li	a1,1
    80006702:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006706:	f8442703          	lw	a4,-124(s0)
    8000670a:	628c                	ld	a1,0(a3)
    8000670c:	962e                	add	a2,a2,a1
    8000670e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006712:	0712                	slli	a4,a4,0x4
    80006714:	6290                	ld	a2,0(a3)
    80006716:	963a                	add	a2,a2,a4
    80006718:	058a8593          	addi	a1,s5,88
    8000671c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000671e:	6294                	ld	a3,0(a3)
    80006720:	96ba                	add	a3,a3,a4
    80006722:	40000613          	li	a2,1024
    80006726:	c690                	sw	a2,8(a3)
  if(write)
    80006728:	e40d19e3          	bnez	s10,8000657a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000672c:	0001f697          	auipc	a3,0x1f
    80006730:	8d46b683          	ld	a3,-1836(a3) # 80025000 <disk+0x2000>
    80006734:	96ba                	add	a3,a3,a4
    80006736:	4609                	li	a2,2
    80006738:	00c69623          	sh	a2,12(a3)
    8000673c:	b5b1                	j	80006588 <virtio_disk_rw+0xd2>

000000008000673e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000673e:	1101                	addi	sp,sp,-32
    80006740:	ec06                	sd	ra,24(sp)
    80006742:	e822                	sd	s0,16(sp)
    80006744:	e426                	sd	s1,8(sp)
    80006746:	e04a                	sd	s2,0(sp)
    80006748:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000674a:	0001f517          	auipc	a0,0x1f
    8000674e:	9de50513          	addi	a0,a0,-1570 # 80025128 <disk+0x2128>
    80006752:	ffffa097          	auipc	ra,0xffffa
    80006756:	470080e7          	jalr	1136(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000675a:	10001737          	lui	a4,0x10001
    8000675e:	533c                	lw	a5,96(a4)
    80006760:	8b8d                	andi	a5,a5,3
    80006762:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006764:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006768:	0001f797          	auipc	a5,0x1f
    8000676c:	89878793          	addi	a5,a5,-1896 # 80025000 <disk+0x2000>
    80006770:	6b94                	ld	a3,16(a5)
    80006772:	0207d703          	lhu	a4,32(a5)
    80006776:	0026d783          	lhu	a5,2(a3)
    8000677a:	06f70163          	beq	a4,a5,800067dc <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000677e:	0001d917          	auipc	s2,0x1d
    80006782:	88290913          	addi	s2,s2,-1918 # 80023000 <disk>
    80006786:	0001f497          	auipc	s1,0x1f
    8000678a:	87a48493          	addi	s1,s1,-1926 # 80025000 <disk+0x2000>
    __sync_synchronize();
    8000678e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006792:	6898                	ld	a4,16(s1)
    80006794:	0204d783          	lhu	a5,32(s1)
    80006798:	8b9d                	andi	a5,a5,7
    8000679a:	078e                	slli	a5,a5,0x3
    8000679c:	97ba                	add	a5,a5,a4
    8000679e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800067a0:	20078713          	addi	a4,a5,512
    800067a4:	0712                	slli	a4,a4,0x4
    800067a6:	974a                	add	a4,a4,s2
    800067a8:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800067ac:	e731                	bnez	a4,800067f8 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800067ae:	20078793          	addi	a5,a5,512
    800067b2:	0792                	slli	a5,a5,0x4
    800067b4:	97ca                	add	a5,a5,s2
    800067b6:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800067b8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800067bc:	ffffc097          	auipc	ra,0xffffc
    800067c0:	b96080e7          	jalr	-1130(ra) # 80002352 <wakeup>

    disk.used_idx += 1;
    800067c4:	0204d783          	lhu	a5,32(s1)
    800067c8:	2785                	addiw	a5,a5,1
    800067ca:	17c2                	slli	a5,a5,0x30
    800067cc:	93c1                	srli	a5,a5,0x30
    800067ce:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800067d2:	6898                	ld	a4,16(s1)
    800067d4:	00275703          	lhu	a4,2(a4)
    800067d8:	faf71be3          	bne	a4,a5,8000678e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800067dc:	0001f517          	auipc	a0,0x1f
    800067e0:	94c50513          	addi	a0,a0,-1716 # 80025128 <disk+0x2128>
    800067e4:	ffffa097          	auipc	ra,0xffffa
    800067e8:	492080e7          	jalr	1170(ra) # 80000c76 <release>
}
    800067ec:	60e2                	ld	ra,24(sp)
    800067ee:	6442                	ld	s0,16(sp)
    800067f0:	64a2                	ld	s1,8(sp)
    800067f2:	6902                	ld	s2,0(sp)
    800067f4:	6105                	addi	sp,sp,32
    800067f6:	8082                	ret
      panic("virtio_disk_intr status");
    800067f8:	00002517          	auipc	a0,0x2
    800067fc:	23050513          	addi	a0,a0,560 # 80008a28 <syscalls+0x3f8>
    80006800:	ffffa097          	auipc	ra,0xffffa
    80006804:	d2a080e7          	jalr	-726(ra) # 8000052a <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
