
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <reading_from_fd>:
void panic(char*);
struct cmd *parsecmd(char*);
char* reading_from_fd(int); //NOY&HADAS


char* reading_from_fd(int fd){
       0:	7139                	addi	sp,sp,-64
       2:	fc06                	sd	ra,56(sp)
       4:	f822                	sd	s0,48(sp)
       6:	f426                	sd	s1,40(sp)
       8:	f04a                	sd	s2,32(sp)
       a:	ec4e                	sd	s3,24(sp)
       c:	e852                	sd	s4,16(sp)
       e:	0080                	addi	s0,sp,64
      10:	89aa                	mv	s3,a0
  char* path=malloc(100);
      12:	06400513          	li	a0,100
      16:	00001097          	auipc	ra,0x1
      1a:	3fe080e7          	jalr	1022(ra) # 1414 <malloc>
      1e:	892a                	mv	s2,a0
  memset(path,0,100);
      20:	06400613          	li	a2,100
      24:	4581                	li	a1,0
      26:	00001097          	auipc	ra,0x1
      2a:	d50080e7          	jalr	-688(ra) # d76 <memset>
  char buffer[] = {0,0};
      2e:	fc041423          	sh	zero,-56(s0)
  int read_byte_into_buffer=read(fd,buffer,1);
      32:	4605                	li	a2,1
      34:	fc840593          	addi	a1,s0,-56
      38:	854e                	mv	a0,s3
      3a:	00001097          	auipc	ra,0x1
      3e:	fac080e7          	jalr	-84(ra) # fe6 <read>
  while (read_byte_into_buffer>0){
      42:	08a05063          	blez	a0,c2 <reading_from_fd+0xc2>
      46:	84aa                	mv	s1,a0
    if (strlen(path)>=100){ //extand path array
      48:	06300a13          	li	s4,99
      4c:	a01d                	j	72 <reading_from_fd+0x72>
      memset(new_path,0,100);
      strcpy(new_path,path);
      free(path);
      path=new_path; ///let path point to new_path
    }
    my_strcat(path,buffer);
      4e:	fc840593          	addi	a1,s0,-56
      52:	854a                	mv	a0,s2
      54:	00001097          	auipc	ra,0x1
      58:	f16080e7          	jalr	-234(ra) # f6a <my_strcat>
    read_byte_into_buffer=read(fd,buffer,1);
      5c:	4605                	li	a2,1
      5e:	fc840593          	addi	a1,s0,-56
      62:	854e                	mv	a0,s3
      64:	00001097          	auipc	ra,0x1
      68:	f82080e7          	jalr	-126(ra) # fe6 <read>
      6c:	84aa                	mv	s1,a0
  while (read_byte_into_buffer>0){
      6e:	04a05a63          	blez	a0,c2 <reading_from_fd+0xc2>
    if (strlen(path)>=100){ //extand path array
      72:	854a                	mv	a0,s2
      74:	00001097          	auipc	ra,0x1
      78:	cd8080e7          	jalr	-808(ra) # d4c <strlen>
      7c:	2501                	sext.w	a0,a0
      7e:	fcaa78e3          	bgeu	s4,a0,4e <reading_from_fd+0x4e>
      char* new_path=malloc(strlen(path)+read_byte_into_buffer+1);
      82:	854a                	mv	a0,s2
      84:	00001097          	auipc	ra,0x1
      88:	cc8080e7          	jalr	-824(ra) # d4c <strlen>
      8c:	2485                	addiw	s1,s1,1
      8e:	9d25                	addw	a0,a0,s1
      90:	00001097          	auipc	ra,0x1
      94:	384080e7          	jalr	900(ra) # 1414 <malloc>
      98:	84aa                	mv	s1,a0
      memset(new_path,0,100);
      9a:	06400613          	li	a2,100
      9e:	4581                	li	a1,0
      a0:	00001097          	auipc	ra,0x1
      a4:	cd6080e7          	jalr	-810(ra) # d76 <memset>
      strcpy(new_path,path);
      a8:	85ca                	mv	a1,s2
      aa:	8526                	mv	a0,s1
      ac:	00001097          	auipc	ra,0x1
      b0:	c58080e7          	jalr	-936(ra) # d04 <strcpy>
      free(path);
      b4:	854a                	mv	a0,s2
      b6:	00001097          	auipc	ra,0x1
      ba:	2d6080e7          	jalr	726(ra) # 138c <free>
      path=new_path; ///let path point to new_path
      be:	8926                	mv	s2,s1
      c0:	b779                	j	4e <reading_from_fd+0x4e>
  }

  return path;
}
      c2:	854a                	mv	a0,s2
      c4:	70e2                	ld	ra,56(sp)
      c6:	7442                	ld	s0,48(sp)
      c8:	74a2                	ld	s1,40(sp)
      ca:	7902                	ld	s2,32(sp)
      cc:	69e2                	ld	s3,24(sp)
      ce:	6a42                	ld	s4,16(sp)
      d0:	6121                	addi	sp,sp,64
      d2:	8082                	ret

00000000000000d4 <getcmd>:
  exit(0);
}

int
getcmd(char *buf, int nbuf)
{
      d4:	1101                	addi	sp,sp,-32
      d6:	ec06                	sd	ra,24(sp)
      d8:	e822                	sd	s0,16(sp)
      da:	e426                	sd	s1,8(sp)
      dc:	e04a                	sd	s2,0(sp)
      de:	1000                	addi	s0,sp,32
      e0:	84aa                	mv	s1,a0
      e2:	892e                	mv	s2,a1
  fprintf(2, "$ ");
      e4:	00001597          	auipc	a1,0x1
      e8:	41c58593          	addi	a1,a1,1052 # 1500 <malloc+0xec>
      ec:	4509                	li	a0,2
      ee:	00001097          	auipc	ra,0x1
      f2:	23a080e7          	jalr	570(ra) # 1328 <fprintf>
  memset(buf, 0, nbuf);
      f6:	864a                	mv	a2,s2
      f8:	4581                	li	a1,0
      fa:	8526                	mv	a0,s1
      fc:	00001097          	auipc	ra,0x1
     100:	c7a080e7          	jalr	-902(ra) # d76 <memset>
  gets(buf, nbuf);
     104:	85ca                	mv	a1,s2
     106:	8526                	mv	a0,s1
     108:	00001097          	auipc	ra,0x1
     10c:	cb4080e7          	jalr	-844(ra) # dbc <gets>
  if(buf[0] == 0) // EOF
     110:	0004c503          	lbu	a0,0(s1)
     114:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
     118:	40a00533          	neg	a0,a0
     11c:	60e2                	ld	ra,24(sp)
     11e:	6442                	ld	s0,16(sp)
     120:	64a2                	ld	s1,8(sp)
     122:	6902                	ld	s2,0(sp)
     124:	6105                	addi	sp,sp,32
     126:	8082                	ret

0000000000000128 <panic>:
  exit(0);
}

void
panic(char *s)
{
     128:	1141                	addi	sp,sp,-16
     12a:	e406                	sd	ra,8(sp)
     12c:	e022                	sd	s0,0(sp)
     12e:	0800                	addi	s0,sp,16
     130:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
     132:	00001597          	auipc	a1,0x1
     136:	3d658593          	addi	a1,a1,982 # 1508 <malloc+0xf4>
     13a:	4509                	li	a0,2
     13c:	00001097          	auipc	ra,0x1
     140:	1ec080e7          	jalr	492(ra) # 1328 <fprintf>
  exit(1);
     144:	4505                	li	a0,1
     146:	00001097          	auipc	ra,0x1
     14a:	e88080e7          	jalr	-376(ra) # fce <exit>

000000000000014e <fork1>:
}

int
fork1(void)
{
     14e:	1141                	addi	sp,sp,-16
     150:	e406                	sd	ra,8(sp)
     152:	e022                	sd	s0,0(sp)
     154:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
     156:	00001097          	auipc	ra,0x1
     15a:	e70080e7          	jalr	-400(ra) # fc6 <fork>
  if(pid == -1)
     15e:	57fd                	li	a5,-1
     160:	00f50663          	beq	a0,a5,16c <fork1+0x1e>
    panic("fork");
  return pid;
}
     164:	60a2                	ld	ra,8(sp)
     166:	6402                	ld	s0,0(sp)
     168:	0141                	addi	sp,sp,16
     16a:	8082                	ret
    panic("fork");
     16c:	00001517          	auipc	a0,0x1
     170:	3a450513          	addi	a0,a0,932 # 1510 <malloc+0xfc>
     174:	00000097          	auipc	ra,0x0
     178:	fb4080e7          	jalr	-76(ra) # 128 <panic>

000000000000017c <runcmd>:
void runcmd(struct cmd *cmd){
     17c:	715d                	addi	sp,sp,-80
     17e:	e486                	sd	ra,72(sp)
     180:	e0a2                	sd	s0,64(sp)
     182:	fc26                	sd	s1,56(sp)
     184:	f84a                	sd	s2,48(sp)
     186:	f44e                	sd	s3,40(sp)
     188:	f052                	sd	s4,32(sp)
     18a:	ec56                	sd	s5,24(sp)
     18c:	e85a                	sd	s6,16(sp)
     18e:	0880                	addi	s0,sp,80
  if(cmd == 0)
     190:	c10d                	beqz	a0,1b2 <runcmd+0x36>
     192:	892a                	mv	s2,a0
  switch(cmd->type){
     194:	4118                	lw	a4,0(a0)
     196:	4795                	li	a5,5
     198:	02e7e263          	bltu	a5,a4,1bc <runcmd+0x40>
     19c:	00056783          	lwu	a5,0(a0)
     1a0:	078a                	slli	a5,a5,0x2
     1a2:	00001717          	auipc	a4,0x1
     1a6:	47670713          	addi	a4,a4,1142 # 1618 <malloc+0x204>
     1aa:	97ba                	add	a5,a5,a4
     1ac:	439c                	lw	a5,0(a5)
     1ae:	97ba                	add	a5,a5,a4
     1b0:	8782                	jr	a5
    exit(1);
     1b2:	4505                	li	a0,1
     1b4:	00001097          	auipc	ra,0x1
     1b8:	e1a080e7          	jalr	-486(ra) # fce <exit>
    panic("runcmd");
     1bc:	00001517          	auipc	a0,0x1
     1c0:	35c50513          	addi	a0,a0,860 # 1518 <malloc+0x104>
     1c4:	00000097          	auipc	ra,0x0
     1c8:	f64080e7          	jalr	-156(ra) # 128 <panic>
    if(ecmd->argv[0] == 0) //no arguments in cmd line
     1cc:	651c                	ld	a5,8(a0)
     1ce:	cb85                	beqz	a5,1fe <runcmd+0x82>
    int fd = open("/path",O_RDONLY);
     1d0:	4581                	li	a1,0
     1d2:	00001517          	auipc	a0,0x1
     1d6:	34e50513          	addi	a0,a0,846 # 1520 <malloc+0x10c>
     1da:	00001097          	auipc	ra,0x1
     1de:	e34080e7          	jalr	-460(ra) # 100e <open>
    if(fd == -1){
     1e2:	57fd                	li	a5,-1
     1e4:	02f50263          	beq	a0,a5,208 <runcmd+0x8c>
    char *path=reading_from_fd(fd);
     1e8:	00000097          	auipc	ra,0x0
     1ec:	e18080e7          	jalr	-488(ra) # 0 <reading_from_fd>
     1f0:	84aa                	mv	s1,a0
    while(*path!=0 && *path!='\n'){
     1f2:	4aa9                	li	s5,10
        while(*path!=':'){
     1f4:	03a00a13          	li	s4,58
        exec(new_path, ecmd->argv); 
     1f8:	00890b13          	addi	s6,s2,8
    while(*path!=0 && *path!='\n'){
     1fc:	a091                	j	240 <runcmd+0xc4>
      exit(1);
     1fe:	4505                	li	a0,1
     200:	00001097          	auipc	ra,0x1
     204:	dce080e7          	jalr	-562(ra) # fce <exit>
      fprintf(2, "open %s failed\n", ecmd->argv[0]);
     208:	00893603          	ld	a2,8(s2)
     20c:	00001597          	auipc	a1,0x1
     210:	31c58593          	addi	a1,a1,796 # 1528 <malloc+0x114>
     214:	4509                	li	a0,2
     216:	00001097          	auipc	ra,0x1
     21a:	112080e7          	jalr	274(ra) # 1328 <fprintf>
      exit(1);
     21e:	4505                	li	a0,1
     220:	00001097          	auipc	ra,0x1
     224:	dae080e7          	jalr	-594(ra) # fce <exit>
        char *new_path = my_strcat(word,ecmd->argv[0]);
     228:	00893583          	ld	a1,8(s2)
     22c:	854e                	mv	a0,s3
     22e:	00001097          	auipc	ra,0x1
     232:	d3c080e7          	jalr	-708(ra) # f6a <my_strcat>
        exec(new_path, ecmd->argv); 
     236:	85da                	mv	a1,s6
     238:	00001097          	auipc	ra,0x1
     23c:	dce080e7          	jalr	-562(ra) # 1006 <exec>
    while(*path!=0 && *path!='\n'){
     240:	0004c783          	lbu	a5,0(s1)
     244:	cba1                	beqz	a5,294 <runcmd+0x118>
     246:	05578763          	beq	a5,s5,294 <runcmd+0x118>
        char *word=malloc(100);
     24a:	06400513          	li	a0,100
     24e:	00001097          	auipc	ra,0x1
     252:	1c6080e7          	jalr	454(ra) # 1414 <malloc>
     256:	89aa                	mv	s3,a0
        memset(word,0,100);
     258:	06400613          	li	a2,100
     25c:	4581                	li	a1,0
     25e:	00001097          	auipc	ra,0x1
     262:	b18080e7          	jalr	-1256(ra) # d76 <memset>
        while(*path!=':'){
     266:	0004c783          	lbu	a5,0(s1)
     26a:	fb478fe3          	beq	a5,s4,228 <runcmd+0xac>
          char const_buf[]={0,0};
     26e:	fa041823          	sh	zero,-80(s0)
          const_buf[0]=*path;
     272:	0004c783          	lbu	a5,0(s1)
     276:	faf40823          	sb	a5,-80(s0)
          my_strcat(word, const_buf);
     27a:	fb040593          	addi	a1,s0,-80
     27e:	854e                	mv	a0,s3
     280:	00001097          	auipc	ra,0x1
     284:	cea080e7          	jalr	-790(ra) # f6a <my_strcat>
          path++; 
     288:	0485                	addi	s1,s1,1
        while(*path!=':'){
     28a:	0004c783          	lbu	a5,0(s1)
     28e:	ff4790e3          	bne	a5,s4,26e <runcmd+0xf2>
     292:	bf59                	j	228 <runcmd+0xac>
    exec(ecmd->argv[0], ecmd->argv); 
     294:	00890593          	addi	a1,s2,8
     298:	00893503          	ld	a0,8(s2)
     29c:	00001097          	auipc	ra,0x1
     2a0:	d6a080e7          	jalr	-662(ra) # 1006 <exec>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     2a4:	00893603          	ld	a2,8(s2)
     2a8:	00001597          	auipc	a1,0x1
     2ac:	29058593          	addi	a1,a1,656 # 1538 <malloc+0x124>
     2b0:	4509                	li	a0,2
     2b2:	00001097          	auipc	ra,0x1
     2b6:	076080e7          	jalr	118(ra) # 1328 <fprintf>
    break;
     2ba:	aa99                	j	410 <runcmd+0x294>
    close(rcmd->fd);
     2bc:	5148                	lw	a0,36(a0)
     2be:	00001097          	auipc	ra,0x1
     2c2:	d38080e7          	jalr	-712(ra) # ff6 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     2c6:	02092583          	lw	a1,32(s2)
     2ca:	01093503          	ld	a0,16(s2)
     2ce:	00001097          	auipc	ra,0x1
     2d2:	d40080e7          	jalr	-704(ra) # 100e <open>
     2d6:	00054863          	bltz	a0,2e6 <runcmd+0x16a>
    runcmd(rcmd->cmd);
     2da:	00893503          	ld	a0,8(s2)
     2de:	00000097          	auipc	ra,0x0
     2e2:	e9e080e7          	jalr	-354(ra) # 17c <runcmd>
      fprintf(2, "open %s failed\n", rcmd->file);
     2e6:	01093603          	ld	a2,16(s2)
     2ea:	00001597          	auipc	a1,0x1
     2ee:	23e58593          	addi	a1,a1,574 # 1528 <malloc+0x114>
     2f2:	4509                	li	a0,2
     2f4:	00001097          	auipc	ra,0x1
     2f8:	034080e7          	jalr	52(ra) # 1328 <fprintf>
      exit(1);
     2fc:	4505                	li	a0,1
     2fe:	00001097          	auipc	ra,0x1
     302:	cd0080e7          	jalr	-816(ra) # fce <exit>
    if(fork1() == 0)
     306:	00000097          	auipc	ra,0x0
     30a:	e48080e7          	jalr	-440(ra) # 14e <fork1>
     30e:	cd01                	beqz	a0,326 <runcmd+0x1aa>
    wait(0);
     310:	4501                	li	a0,0
     312:	00001097          	auipc	ra,0x1
     316:	cc4080e7          	jalr	-828(ra) # fd6 <wait>
    runcmd(lcmd->right);
     31a:	01093503          	ld	a0,16(s2)
     31e:	00000097          	auipc	ra,0x0
     322:	e5e080e7          	jalr	-418(ra) # 17c <runcmd>
      runcmd(lcmd->left);
     326:	00893503          	ld	a0,8(s2)
     32a:	00000097          	auipc	ra,0x0
     32e:	e52080e7          	jalr	-430(ra) # 17c <runcmd>
    if(pipe(p) < 0)
     332:	fb840513          	addi	a0,s0,-72
     336:	00001097          	auipc	ra,0x1
     33a:	ca8080e7          	jalr	-856(ra) # fde <pipe>
     33e:	04054363          	bltz	a0,384 <runcmd+0x208>
    if(fork1() == 0){
     342:	00000097          	auipc	ra,0x0
     346:	e0c080e7          	jalr	-500(ra) # 14e <fork1>
     34a:	c529                	beqz	a0,394 <runcmd+0x218>
    if(fork1() == 0){
     34c:	00000097          	auipc	ra,0x0
     350:	e02080e7          	jalr	-510(ra) # 14e <fork1>
     354:	cd2d                	beqz	a0,3ce <runcmd+0x252>
    close(p[0]);
     356:	fb842503          	lw	a0,-72(s0)
     35a:	00001097          	auipc	ra,0x1
     35e:	c9c080e7          	jalr	-868(ra) # ff6 <close>
    close(p[1]);
     362:	fbc42503          	lw	a0,-68(s0)
     366:	00001097          	auipc	ra,0x1
     36a:	c90080e7          	jalr	-880(ra) # ff6 <close>
    wait(0);
     36e:	4501                	li	a0,0
     370:	00001097          	auipc	ra,0x1
     374:	c66080e7          	jalr	-922(ra) # fd6 <wait>
    wait(0);
     378:	4501                	li	a0,0
     37a:	00001097          	auipc	ra,0x1
     37e:	c5c080e7          	jalr	-932(ra) # fd6 <wait>
    break;
     382:	a079                	j	410 <runcmd+0x294>
      panic("pipe");
     384:	00001517          	auipc	a0,0x1
     388:	1c450513          	addi	a0,a0,452 # 1548 <malloc+0x134>
     38c:	00000097          	auipc	ra,0x0
     390:	d9c080e7          	jalr	-612(ra) # 128 <panic>
      close(1);
     394:	4505                	li	a0,1
     396:	00001097          	auipc	ra,0x1
     39a:	c60080e7          	jalr	-928(ra) # ff6 <close>
      dup(p[1]);
     39e:	fbc42503          	lw	a0,-68(s0)
     3a2:	00001097          	auipc	ra,0x1
     3a6:	ca4080e7          	jalr	-860(ra) # 1046 <dup>
      close(p[0]);
     3aa:	fb842503          	lw	a0,-72(s0)
     3ae:	00001097          	auipc	ra,0x1
     3b2:	c48080e7          	jalr	-952(ra) # ff6 <close>
      close(p[1]);
     3b6:	fbc42503          	lw	a0,-68(s0)
     3ba:	00001097          	auipc	ra,0x1
     3be:	c3c080e7          	jalr	-964(ra) # ff6 <close>
      runcmd(pcmd->left);
     3c2:	00893503          	ld	a0,8(s2)
     3c6:	00000097          	auipc	ra,0x0
     3ca:	db6080e7          	jalr	-586(ra) # 17c <runcmd>
      close(0);
     3ce:	00001097          	auipc	ra,0x1
     3d2:	c28080e7          	jalr	-984(ra) # ff6 <close>
      dup(p[0]);
     3d6:	fb842503          	lw	a0,-72(s0)
     3da:	00001097          	auipc	ra,0x1
     3de:	c6c080e7          	jalr	-916(ra) # 1046 <dup>
      close(p[0]);
     3e2:	fb842503          	lw	a0,-72(s0)
     3e6:	00001097          	auipc	ra,0x1
     3ea:	c10080e7          	jalr	-1008(ra) # ff6 <close>
      close(p[1]);
     3ee:	fbc42503          	lw	a0,-68(s0)
     3f2:	00001097          	auipc	ra,0x1
     3f6:	c04080e7          	jalr	-1020(ra) # ff6 <close>
      runcmd(pcmd->right);
     3fa:	01093503          	ld	a0,16(s2)
     3fe:	00000097          	auipc	ra,0x0
     402:	d7e080e7          	jalr	-642(ra) # 17c <runcmd>
    if(fork1() == 0)
     406:	00000097          	auipc	ra,0x0
     40a:	d48080e7          	jalr	-696(ra) # 14e <fork1>
     40e:	c511                	beqz	a0,41a <runcmd+0x29e>
  exit(0);
     410:	4501                	li	a0,0
     412:	00001097          	auipc	ra,0x1
     416:	bbc080e7          	jalr	-1092(ra) # fce <exit>
      runcmd(bcmd->cmd);
     41a:	00893503          	ld	a0,8(s2)
     41e:	00000097          	auipc	ra,0x0
     422:	d5e080e7          	jalr	-674(ra) # 17c <runcmd>

0000000000000426 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     426:	1101                	addi	sp,sp,-32
     428:	ec06                	sd	ra,24(sp)
     42a:	e822                	sd	s0,16(sp)
     42c:	e426                	sd	s1,8(sp)
     42e:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     430:	0a800513          	li	a0,168
     434:	00001097          	auipc	ra,0x1
     438:	fe0080e7          	jalr	-32(ra) # 1414 <malloc>
     43c:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     43e:	0a800613          	li	a2,168
     442:	4581                	li	a1,0
     444:	00001097          	auipc	ra,0x1
     448:	932080e7          	jalr	-1742(ra) # d76 <memset>
  cmd->type = EXEC;
     44c:	4785                	li	a5,1
     44e:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     450:	8526                	mv	a0,s1
     452:	60e2                	ld	ra,24(sp)
     454:	6442                	ld	s0,16(sp)
     456:	64a2                	ld	s1,8(sp)
     458:	6105                	addi	sp,sp,32
     45a:	8082                	ret

000000000000045c <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     45c:	7139                	addi	sp,sp,-64
     45e:	fc06                	sd	ra,56(sp)
     460:	f822                	sd	s0,48(sp)
     462:	f426                	sd	s1,40(sp)
     464:	f04a                	sd	s2,32(sp)
     466:	ec4e                	sd	s3,24(sp)
     468:	e852                	sd	s4,16(sp)
     46a:	e456                	sd	s5,8(sp)
     46c:	e05a                	sd	s6,0(sp)
     46e:	0080                	addi	s0,sp,64
     470:	8b2a                	mv	s6,a0
     472:	8aae                	mv	s5,a1
     474:	8a32                	mv	s4,a2
     476:	89b6                	mv	s3,a3
     478:	893a                	mv	s2,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     47a:	02800513          	li	a0,40
     47e:	00001097          	auipc	ra,0x1
     482:	f96080e7          	jalr	-106(ra) # 1414 <malloc>
     486:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     488:	02800613          	li	a2,40
     48c:	4581                	li	a1,0
     48e:	00001097          	auipc	ra,0x1
     492:	8e8080e7          	jalr	-1816(ra) # d76 <memset>
  cmd->type = REDIR;
     496:	4789                	li	a5,2
     498:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     49a:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     49e:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     4a2:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     4a6:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     4aa:	0324a223          	sw	s2,36(s1)
  return (struct cmd*)cmd;
}
     4ae:	8526                	mv	a0,s1
     4b0:	70e2                	ld	ra,56(sp)
     4b2:	7442                	ld	s0,48(sp)
     4b4:	74a2                	ld	s1,40(sp)
     4b6:	7902                	ld	s2,32(sp)
     4b8:	69e2                	ld	s3,24(sp)
     4ba:	6a42                	ld	s4,16(sp)
     4bc:	6aa2                	ld	s5,8(sp)
     4be:	6b02                	ld	s6,0(sp)
     4c0:	6121                	addi	sp,sp,64
     4c2:	8082                	ret

00000000000004c4 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     4c4:	7179                	addi	sp,sp,-48
     4c6:	f406                	sd	ra,40(sp)
     4c8:	f022                	sd	s0,32(sp)
     4ca:	ec26                	sd	s1,24(sp)
     4cc:	e84a                	sd	s2,16(sp)
     4ce:	e44e                	sd	s3,8(sp)
     4d0:	1800                	addi	s0,sp,48
     4d2:	89aa                	mv	s3,a0
     4d4:	892e                	mv	s2,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4d6:	4561                	li	a0,24
     4d8:	00001097          	auipc	ra,0x1
     4dc:	f3c080e7          	jalr	-196(ra) # 1414 <malloc>
     4e0:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     4e2:	4661                	li	a2,24
     4e4:	4581                	li	a1,0
     4e6:	00001097          	auipc	ra,0x1
     4ea:	890080e7          	jalr	-1904(ra) # d76 <memset>
  cmd->type = PIPE;
     4ee:	478d                	li	a5,3
     4f0:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     4f2:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     4f6:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     4fa:	8526                	mv	a0,s1
     4fc:	70a2                	ld	ra,40(sp)
     4fe:	7402                	ld	s0,32(sp)
     500:	64e2                	ld	s1,24(sp)
     502:	6942                	ld	s2,16(sp)
     504:	69a2                	ld	s3,8(sp)
     506:	6145                	addi	sp,sp,48
     508:	8082                	ret

000000000000050a <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     50a:	7179                	addi	sp,sp,-48
     50c:	f406                	sd	ra,40(sp)
     50e:	f022                	sd	s0,32(sp)
     510:	ec26                	sd	s1,24(sp)
     512:	e84a                	sd	s2,16(sp)
     514:	e44e                	sd	s3,8(sp)
     516:	1800                	addi	s0,sp,48
     518:	89aa                	mv	s3,a0
     51a:	892e                	mv	s2,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     51c:	4561                	li	a0,24
     51e:	00001097          	auipc	ra,0x1
     522:	ef6080e7          	jalr	-266(ra) # 1414 <malloc>
     526:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     528:	4661                	li	a2,24
     52a:	4581                	li	a1,0
     52c:	00001097          	auipc	ra,0x1
     530:	84a080e7          	jalr	-1974(ra) # d76 <memset>
  cmd->type = LIST;
     534:	4791                	li	a5,4
     536:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     538:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     53c:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     540:	8526                	mv	a0,s1
     542:	70a2                	ld	ra,40(sp)
     544:	7402                	ld	s0,32(sp)
     546:	64e2                	ld	s1,24(sp)
     548:	6942                	ld	s2,16(sp)
     54a:	69a2                	ld	s3,8(sp)
     54c:	6145                	addi	sp,sp,48
     54e:	8082                	ret

0000000000000550 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     550:	1101                	addi	sp,sp,-32
     552:	ec06                	sd	ra,24(sp)
     554:	e822                	sd	s0,16(sp)
     556:	e426                	sd	s1,8(sp)
     558:	e04a                	sd	s2,0(sp)
     55a:	1000                	addi	s0,sp,32
     55c:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     55e:	4541                	li	a0,16
     560:	00001097          	auipc	ra,0x1
     564:	eb4080e7          	jalr	-332(ra) # 1414 <malloc>
     568:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     56a:	4641                	li	a2,16
     56c:	4581                	li	a1,0
     56e:	00001097          	auipc	ra,0x1
     572:	808080e7          	jalr	-2040(ra) # d76 <memset>
  cmd->type = BACK;
     576:	4795                	li	a5,5
     578:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     57a:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     57e:	8526                	mv	a0,s1
     580:	60e2                	ld	ra,24(sp)
     582:	6442                	ld	s0,16(sp)
     584:	64a2                	ld	s1,8(sp)
     586:	6902                	ld	s2,0(sp)
     588:	6105                	addi	sp,sp,32
     58a:	8082                	ret

000000000000058c <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     58c:	7139                	addi	sp,sp,-64
     58e:	fc06                	sd	ra,56(sp)
     590:	f822                	sd	s0,48(sp)
     592:	f426                	sd	s1,40(sp)
     594:	f04a                	sd	s2,32(sp)
     596:	ec4e                	sd	s3,24(sp)
     598:	e852                	sd	s4,16(sp)
     59a:	e456                	sd	s5,8(sp)
     59c:	e05a                	sd	s6,0(sp)
     59e:	0080                	addi	s0,sp,64
     5a0:	8a2a                	mv	s4,a0
     5a2:	892e                	mv	s2,a1
     5a4:	8ab2                	mv	s5,a2
     5a6:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     5a8:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     5aa:	00001997          	auipc	s3,0x1
     5ae:	0c698993          	addi	s3,s3,198 # 1670 <whitespace>
     5b2:	00b4fd63          	bgeu	s1,a1,5cc <gettoken+0x40>
     5b6:	0004c583          	lbu	a1,0(s1)
     5ba:	854e                	mv	a0,s3
     5bc:	00000097          	auipc	ra,0x0
     5c0:	7dc080e7          	jalr	2012(ra) # d98 <strchr>
     5c4:	c501                	beqz	a0,5cc <gettoken+0x40>
    s++;
     5c6:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     5c8:	fe9917e3          	bne	s2,s1,5b6 <gettoken+0x2a>
  if(q)
     5cc:	000a8463          	beqz	s5,5d4 <gettoken+0x48>
    *q = s;
     5d0:	009ab023          	sd	s1,0(s5)
  ret = *s;
     5d4:	0004c783          	lbu	a5,0(s1)
     5d8:	00078a9b          	sext.w	s5,a5
  switch(*s){
     5dc:	03c00713          	li	a4,60
     5e0:	06f76563          	bltu	a4,a5,64a <gettoken+0xbe>
     5e4:	03a00713          	li	a4,58
     5e8:	00f76e63          	bltu	a4,a5,604 <gettoken+0x78>
     5ec:	cf89                	beqz	a5,606 <gettoken+0x7a>
     5ee:	02600713          	li	a4,38
     5f2:	00e78963          	beq	a5,a4,604 <gettoken+0x78>
     5f6:	fd87879b          	addiw	a5,a5,-40
     5fa:	0ff7f793          	andi	a5,a5,255
     5fe:	4705                	li	a4,1
     600:	06f76c63          	bltu	a4,a5,678 <gettoken+0xec>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     604:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     606:	000b0463          	beqz	s6,60e <gettoken+0x82>
    *eq = s;
     60a:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     60e:	00001997          	auipc	s3,0x1
     612:	06298993          	addi	s3,s3,98 # 1670 <whitespace>
     616:	0124fd63          	bgeu	s1,s2,630 <gettoken+0xa4>
     61a:	0004c583          	lbu	a1,0(s1)
     61e:	854e                	mv	a0,s3
     620:	00000097          	auipc	ra,0x0
     624:	778080e7          	jalr	1912(ra) # d98 <strchr>
     628:	c501                	beqz	a0,630 <gettoken+0xa4>
    s++;
     62a:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     62c:	fe9917e3          	bne	s2,s1,61a <gettoken+0x8e>
  *ps = s;
     630:	009a3023          	sd	s1,0(s4)
  return ret;
}
     634:	8556                	mv	a0,s5
     636:	70e2                	ld	ra,56(sp)
     638:	7442                	ld	s0,48(sp)
     63a:	74a2                	ld	s1,40(sp)
     63c:	7902                	ld	s2,32(sp)
     63e:	69e2                	ld	s3,24(sp)
     640:	6a42                	ld	s4,16(sp)
     642:	6aa2                	ld	s5,8(sp)
     644:	6b02                	ld	s6,0(sp)
     646:	6121                	addi	sp,sp,64
     648:	8082                	ret
  switch(*s){
     64a:	03e00713          	li	a4,62
     64e:	02e79163          	bne	a5,a4,670 <gettoken+0xe4>
    s++;
     652:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     656:	0014c703          	lbu	a4,1(s1)
     65a:	03e00793          	li	a5,62
      s++;
     65e:	0489                	addi	s1,s1,2
      ret = '+';
     660:	02b00a93          	li	s5,43
    if(*s == '>'){
     664:	faf701e3          	beq	a4,a5,606 <gettoken+0x7a>
    s++;
     668:	84b6                	mv	s1,a3
  ret = *s;
     66a:	03e00a93          	li	s5,62
     66e:	bf61                	j	606 <gettoken+0x7a>
  switch(*s){
     670:	07c00713          	li	a4,124
     674:	f8e788e3          	beq	a5,a4,604 <gettoken+0x78>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     678:	00001997          	auipc	s3,0x1
     67c:	ff898993          	addi	s3,s3,-8 # 1670 <whitespace>
     680:	00001a97          	auipc	s5,0x1
     684:	fe8a8a93          	addi	s5,s5,-24 # 1668 <symbols>
     688:	0324f563          	bgeu	s1,s2,6b2 <gettoken+0x126>
     68c:	0004c583          	lbu	a1,0(s1)
     690:	854e                	mv	a0,s3
     692:	00000097          	auipc	ra,0x0
     696:	706080e7          	jalr	1798(ra) # d98 <strchr>
     69a:	e505                	bnez	a0,6c2 <gettoken+0x136>
     69c:	0004c583          	lbu	a1,0(s1)
     6a0:	8556                	mv	a0,s5
     6a2:	00000097          	auipc	ra,0x0
     6a6:	6f6080e7          	jalr	1782(ra) # d98 <strchr>
     6aa:	e909                	bnez	a0,6bc <gettoken+0x130>
      s++;
     6ac:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     6ae:	fc991fe3          	bne	s2,s1,68c <gettoken+0x100>
  if(eq)
     6b2:	06100a93          	li	s5,97
     6b6:	f40b1ae3          	bnez	s6,60a <gettoken+0x7e>
     6ba:	bf9d                	j	630 <gettoken+0xa4>
    ret = 'a';
     6bc:	06100a93          	li	s5,97
     6c0:	b799                	j	606 <gettoken+0x7a>
     6c2:	06100a93          	li	s5,97
     6c6:	b781                	j	606 <gettoken+0x7a>

00000000000006c8 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     6c8:	7139                	addi	sp,sp,-64
     6ca:	fc06                	sd	ra,56(sp)
     6cc:	f822                	sd	s0,48(sp)
     6ce:	f426                	sd	s1,40(sp)
     6d0:	f04a                	sd	s2,32(sp)
     6d2:	ec4e                	sd	s3,24(sp)
     6d4:	e852                	sd	s4,16(sp)
     6d6:	e456                	sd	s5,8(sp)
     6d8:	0080                	addi	s0,sp,64
     6da:	8a2a                	mv	s4,a0
     6dc:	892e                	mv	s2,a1
     6de:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     6e0:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     6e2:	00001997          	auipc	s3,0x1
     6e6:	f8e98993          	addi	s3,s3,-114 # 1670 <whitespace>
     6ea:	00b4fd63          	bgeu	s1,a1,704 <peek+0x3c>
     6ee:	0004c583          	lbu	a1,0(s1)
     6f2:	854e                	mv	a0,s3
     6f4:	00000097          	auipc	ra,0x0
     6f8:	6a4080e7          	jalr	1700(ra) # d98 <strchr>
     6fc:	c501                	beqz	a0,704 <peek+0x3c>
    s++;
     6fe:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     700:	fe9917e3          	bne	s2,s1,6ee <peek+0x26>
  *ps = s;
     704:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     708:	0004c583          	lbu	a1,0(s1)
     70c:	4501                	li	a0,0
     70e:	e991                	bnez	a1,722 <peek+0x5a>
}
     710:	70e2                	ld	ra,56(sp)
     712:	7442                	ld	s0,48(sp)
     714:	74a2                	ld	s1,40(sp)
     716:	7902                	ld	s2,32(sp)
     718:	69e2                	ld	s3,24(sp)
     71a:	6a42                	ld	s4,16(sp)
     71c:	6aa2                	ld	s5,8(sp)
     71e:	6121                	addi	sp,sp,64
     720:	8082                	ret
  return *s && strchr(toks, *s);
     722:	8556                	mv	a0,s5
     724:	00000097          	auipc	ra,0x0
     728:	674080e7          	jalr	1652(ra) # d98 <strchr>
     72c:	00a03533          	snez	a0,a0
     730:	b7c5                	j	710 <peek+0x48>

0000000000000732 <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     732:	7159                	addi	sp,sp,-112
     734:	f486                	sd	ra,104(sp)
     736:	f0a2                	sd	s0,96(sp)
     738:	eca6                	sd	s1,88(sp)
     73a:	e8ca                	sd	s2,80(sp)
     73c:	e4ce                	sd	s3,72(sp)
     73e:	e0d2                	sd	s4,64(sp)
     740:	fc56                	sd	s5,56(sp)
     742:	f85a                	sd	s6,48(sp)
     744:	f45e                	sd	s7,40(sp)
     746:	f062                	sd	s8,32(sp)
     748:	ec66                	sd	s9,24(sp)
     74a:	1880                	addi	s0,sp,112
     74c:	8a2a                	mv	s4,a0
     74e:	89ae                	mv	s3,a1
     750:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     752:	00001b97          	auipc	s7,0x1
     756:	e1eb8b93          	addi	s7,s7,-482 # 1570 <malloc+0x15c>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     75a:	06100c13          	li	s8,97
      panic("missing file for redirection");
    switch(tok){
     75e:	03c00c93          	li	s9,60
  while(peek(ps, es, "<>")){
     762:	a02d                	j	78c <parseredirs+0x5a>
      panic("missing file for redirection");
     764:	00001517          	auipc	a0,0x1
     768:	dec50513          	addi	a0,a0,-532 # 1550 <malloc+0x13c>
     76c:	00000097          	auipc	ra,0x0
     770:	9bc080e7          	jalr	-1604(ra) # 128 <panic>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     774:	4701                	li	a4,0
     776:	4681                	li	a3,0
     778:	f9043603          	ld	a2,-112(s0)
     77c:	f9843583          	ld	a1,-104(s0)
     780:	8552                	mv	a0,s4
     782:	00000097          	auipc	ra,0x0
     786:	cda080e7          	jalr	-806(ra) # 45c <redircmd>
     78a:	8a2a                	mv	s4,a0
    switch(tok){
     78c:	03e00b13          	li	s6,62
     790:	02b00a93          	li	s5,43
  while(peek(ps, es, "<>")){
     794:	865e                	mv	a2,s7
     796:	85ca                	mv	a1,s2
     798:	854e                	mv	a0,s3
     79a:	00000097          	auipc	ra,0x0
     79e:	f2e080e7          	jalr	-210(ra) # 6c8 <peek>
     7a2:	c925                	beqz	a0,812 <parseredirs+0xe0>
    tok = gettoken(ps, es, 0, 0);
     7a4:	4681                	li	a3,0
     7a6:	4601                	li	a2,0
     7a8:	85ca                	mv	a1,s2
     7aa:	854e                	mv	a0,s3
     7ac:	00000097          	auipc	ra,0x0
     7b0:	de0080e7          	jalr	-544(ra) # 58c <gettoken>
     7b4:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     7b6:	f9040693          	addi	a3,s0,-112
     7ba:	f9840613          	addi	a2,s0,-104
     7be:	85ca                	mv	a1,s2
     7c0:	854e                	mv	a0,s3
     7c2:	00000097          	auipc	ra,0x0
     7c6:	dca080e7          	jalr	-566(ra) # 58c <gettoken>
     7ca:	f9851de3          	bne	a0,s8,764 <parseredirs+0x32>
    switch(tok){
     7ce:	fb9483e3          	beq	s1,s9,774 <parseredirs+0x42>
     7d2:	03648263          	beq	s1,s6,7f6 <parseredirs+0xc4>
     7d6:	fb549fe3          	bne	s1,s5,794 <parseredirs+0x62>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     7da:	4705                	li	a4,1
     7dc:	20100693          	li	a3,513
     7e0:	f9043603          	ld	a2,-112(s0)
     7e4:	f9843583          	ld	a1,-104(s0)
     7e8:	8552                	mv	a0,s4
     7ea:	00000097          	auipc	ra,0x0
     7ee:	c72080e7          	jalr	-910(ra) # 45c <redircmd>
     7f2:	8a2a                	mv	s4,a0
      break;
     7f4:	bf61                	j	78c <parseredirs+0x5a>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     7f6:	4705                	li	a4,1
     7f8:	60100693          	li	a3,1537
     7fc:	f9043603          	ld	a2,-112(s0)
     800:	f9843583          	ld	a1,-104(s0)
     804:	8552                	mv	a0,s4
     806:	00000097          	auipc	ra,0x0
     80a:	c56080e7          	jalr	-938(ra) # 45c <redircmd>
     80e:	8a2a                	mv	s4,a0
      break;
     810:	bfb5                	j	78c <parseredirs+0x5a>
    }
  }
  return cmd;
}
     812:	8552                	mv	a0,s4
     814:	70a6                	ld	ra,104(sp)
     816:	7406                	ld	s0,96(sp)
     818:	64e6                	ld	s1,88(sp)
     81a:	6946                	ld	s2,80(sp)
     81c:	69a6                	ld	s3,72(sp)
     81e:	6a06                	ld	s4,64(sp)
     820:	7ae2                	ld	s5,56(sp)
     822:	7b42                	ld	s6,48(sp)
     824:	7ba2                	ld	s7,40(sp)
     826:	7c02                	ld	s8,32(sp)
     828:	6ce2                	ld	s9,24(sp)
     82a:	6165                	addi	sp,sp,112
     82c:	8082                	ret

000000000000082e <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     82e:	7159                	addi	sp,sp,-112
     830:	f486                	sd	ra,104(sp)
     832:	f0a2                	sd	s0,96(sp)
     834:	eca6                	sd	s1,88(sp)
     836:	e8ca                	sd	s2,80(sp)
     838:	e4ce                	sd	s3,72(sp)
     83a:	e0d2                	sd	s4,64(sp)
     83c:	fc56                	sd	s5,56(sp)
     83e:	f85a                	sd	s6,48(sp)
     840:	f45e                	sd	s7,40(sp)
     842:	f062                	sd	s8,32(sp)
     844:	ec66                	sd	s9,24(sp)
     846:	1880                	addi	s0,sp,112
     848:	8a2a                	mv	s4,a0
     84a:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     84c:	00001617          	auipc	a2,0x1
     850:	d2c60613          	addi	a2,a2,-724 # 1578 <malloc+0x164>
     854:	00000097          	auipc	ra,0x0
     858:	e74080e7          	jalr	-396(ra) # 6c8 <peek>
     85c:	e905                	bnez	a0,88c <parseexec+0x5e>
     85e:	89aa                	mv	s3,a0
    return parseblock(ps, es);

  ret = execcmd();
     860:	00000097          	auipc	ra,0x0
     864:	bc6080e7          	jalr	-1082(ra) # 426 <execcmd>
     868:	8c2a                	mv	s8,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     86a:	8656                	mv	a2,s5
     86c:	85d2                	mv	a1,s4
     86e:	00000097          	auipc	ra,0x0
     872:	ec4080e7          	jalr	-316(ra) # 732 <parseredirs>
     876:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     878:	008c0913          	addi	s2,s8,8
     87c:	00001b17          	auipc	s6,0x1
     880:	d1cb0b13          	addi	s6,s6,-740 # 1598 <malloc+0x184>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
     884:	06100c93          	li	s9,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     888:	4ba9                	li	s7,10
  while(!peek(ps, es, "|)&;")){
     88a:	a0b1                	j	8d6 <parseexec+0xa8>
    return parseblock(ps, es);
     88c:	85d6                	mv	a1,s5
     88e:	8552                	mv	a0,s4
     890:	00000097          	auipc	ra,0x0
     894:	1bc080e7          	jalr	444(ra) # a4c <parseblock>
     898:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     89a:	8526                	mv	a0,s1
     89c:	70a6                	ld	ra,104(sp)
     89e:	7406                	ld	s0,96(sp)
     8a0:	64e6                	ld	s1,88(sp)
     8a2:	6946                	ld	s2,80(sp)
     8a4:	69a6                	ld	s3,72(sp)
     8a6:	6a06                	ld	s4,64(sp)
     8a8:	7ae2                	ld	s5,56(sp)
     8aa:	7b42                	ld	s6,48(sp)
     8ac:	7ba2                	ld	s7,40(sp)
     8ae:	7c02                	ld	s8,32(sp)
     8b0:	6ce2                	ld	s9,24(sp)
     8b2:	6165                	addi	sp,sp,112
     8b4:	8082                	ret
      panic("syntax");
     8b6:	00001517          	auipc	a0,0x1
     8ba:	cca50513          	addi	a0,a0,-822 # 1580 <malloc+0x16c>
     8be:	00000097          	auipc	ra,0x0
     8c2:	86a080e7          	jalr	-1942(ra) # 128 <panic>
    ret = parseredirs(ret, ps, es);
     8c6:	8656                	mv	a2,s5
     8c8:	85d2                	mv	a1,s4
     8ca:	8526                	mv	a0,s1
     8cc:	00000097          	auipc	ra,0x0
     8d0:	e66080e7          	jalr	-410(ra) # 732 <parseredirs>
     8d4:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     8d6:	865a                	mv	a2,s6
     8d8:	85d6                	mv	a1,s5
     8da:	8552                	mv	a0,s4
     8dc:	00000097          	auipc	ra,0x0
     8e0:	dec080e7          	jalr	-532(ra) # 6c8 <peek>
     8e4:	e131                	bnez	a0,928 <parseexec+0xfa>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     8e6:	f9040693          	addi	a3,s0,-112
     8ea:	f9840613          	addi	a2,s0,-104
     8ee:	85d6                	mv	a1,s5
     8f0:	8552                	mv	a0,s4
     8f2:	00000097          	auipc	ra,0x0
     8f6:	c9a080e7          	jalr	-870(ra) # 58c <gettoken>
     8fa:	c51d                	beqz	a0,928 <parseexec+0xfa>
    if(tok != 'a')
     8fc:	fb951de3          	bne	a0,s9,8b6 <parseexec+0x88>
    cmd->argv[argc] = q;
     900:	f9843783          	ld	a5,-104(s0)
     904:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     908:	f9043783          	ld	a5,-112(s0)
     90c:	04f93823          	sd	a5,80(s2)
    argc++;
     910:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     912:	0921                	addi	s2,s2,8
     914:	fb7999e3          	bne	s3,s7,8c6 <parseexec+0x98>
      panic("too many args");
     918:	00001517          	auipc	a0,0x1
     91c:	c7050513          	addi	a0,a0,-912 # 1588 <malloc+0x174>
     920:	00000097          	auipc	ra,0x0
     924:	808080e7          	jalr	-2040(ra) # 128 <panic>
  cmd->argv[argc] = 0;
     928:	098e                	slli	s3,s3,0x3
     92a:	99e2                	add	s3,s3,s8
     92c:	0009b423          	sd	zero,8(s3)
  cmd->eargv[argc] = 0;
     930:	0409bc23          	sd	zero,88(s3)
  return ret;
     934:	b79d                	j	89a <parseexec+0x6c>

0000000000000936 <parsepipe>:
{
     936:	7179                	addi	sp,sp,-48
     938:	f406                	sd	ra,40(sp)
     93a:	f022                	sd	s0,32(sp)
     93c:	ec26                	sd	s1,24(sp)
     93e:	e84a                	sd	s2,16(sp)
     940:	e44e                	sd	s3,8(sp)
     942:	1800                	addi	s0,sp,48
     944:	892a                	mv	s2,a0
     946:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     948:	00000097          	auipc	ra,0x0
     94c:	ee6080e7          	jalr	-282(ra) # 82e <parseexec>
     950:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     952:	00001617          	auipc	a2,0x1
     956:	c4e60613          	addi	a2,a2,-946 # 15a0 <malloc+0x18c>
     95a:	85ce                	mv	a1,s3
     95c:	854a                	mv	a0,s2
     95e:	00000097          	auipc	ra,0x0
     962:	d6a080e7          	jalr	-662(ra) # 6c8 <peek>
     966:	e909                	bnez	a0,978 <parsepipe+0x42>
}
     968:	8526                	mv	a0,s1
     96a:	70a2                	ld	ra,40(sp)
     96c:	7402                	ld	s0,32(sp)
     96e:	64e2                	ld	s1,24(sp)
     970:	6942                	ld	s2,16(sp)
     972:	69a2                	ld	s3,8(sp)
     974:	6145                	addi	sp,sp,48
     976:	8082                	ret
    gettoken(ps, es, 0, 0);
     978:	4681                	li	a3,0
     97a:	4601                	li	a2,0
     97c:	85ce                	mv	a1,s3
     97e:	854a                	mv	a0,s2
     980:	00000097          	auipc	ra,0x0
     984:	c0c080e7          	jalr	-1012(ra) # 58c <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     988:	85ce                	mv	a1,s3
     98a:	854a                	mv	a0,s2
     98c:	00000097          	auipc	ra,0x0
     990:	faa080e7          	jalr	-86(ra) # 936 <parsepipe>
     994:	85aa                	mv	a1,a0
     996:	8526                	mv	a0,s1
     998:	00000097          	auipc	ra,0x0
     99c:	b2c080e7          	jalr	-1236(ra) # 4c4 <pipecmd>
     9a0:	84aa                	mv	s1,a0
  return cmd;
     9a2:	b7d9                	j	968 <parsepipe+0x32>

00000000000009a4 <parseline>:
{
     9a4:	7179                	addi	sp,sp,-48
     9a6:	f406                	sd	ra,40(sp)
     9a8:	f022                	sd	s0,32(sp)
     9aa:	ec26                	sd	s1,24(sp)
     9ac:	e84a                	sd	s2,16(sp)
     9ae:	e44e                	sd	s3,8(sp)
     9b0:	e052                	sd	s4,0(sp)
     9b2:	1800                	addi	s0,sp,48
     9b4:	892a                	mv	s2,a0
     9b6:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     9b8:	00000097          	auipc	ra,0x0
     9bc:	f7e080e7          	jalr	-130(ra) # 936 <parsepipe>
     9c0:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     9c2:	00001a17          	auipc	s4,0x1
     9c6:	be6a0a13          	addi	s4,s4,-1050 # 15a8 <malloc+0x194>
     9ca:	a839                	j	9e8 <parseline+0x44>
    gettoken(ps, es, 0, 0);
     9cc:	4681                	li	a3,0
     9ce:	4601                	li	a2,0
     9d0:	85ce                	mv	a1,s3
     9d2:	854a                	mv	a0,s2
     9d4:	00000097          	auipc	ra,0x0
     9d8:	bb8080e7          	jalr	-1096(ra) # 58c <gettoken>
    cmd = backcmd(cmd);
     9dc:	8526                	mv	a0,s1
     9de:	00000097          	auipc	ra,0x0
     9e2:	b72080e7          	jalr	-1166(ra) # 550 <backcmd>
     9e6:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     9e8:	8652                	mv	a2,s4
     9ea:	85ce                	mv	a1,s3
     9ec:	854a                	mv	a0,s2
     9ee:	00000097          	auipc	ra,0x0
     9f2:	cda080e7          	jalr	-806(ra) # 6c8 <peek>
     9f6:	f979                	bnez	a0,9cc <parseline+0x28>
  if(peek(ps, es, ";")){
     9f8:	00001617          	auipc	a2,0x1
     9fc:	bb860613          	addi	a2,a2,-1096 # 15b0 <malloc+0x19c>
     a00:	85ce                	mv	a1,s3
     a02:	854a                	mv	a0,s2
     a04:	00000097          	auipc	ra,0x0
     a08:	cc4080e7          	jalr	-828(ra) # 6c8 <peek>
     a0c:	e911                	bnez	a0,a20 <parseline+0x7c>
}
     a0e:	8526                	mv	a0,s1
     a10:	70a2                	ld	ra,40(sp)
     a12:	7402                	ld	s0,32(sp)
     a14:	64e2                	ld	s1,24(sp)
     a16:	6942                	ld	s2,16(sp)
     a18:	69a2                	ld	s3,8(sp)
     a1a:	6a02                	ld	s4,0(sp)
     a1c:	6145                	addi	sp,sp,48
     a1e:	8082                	ret
    gettoken(ps, es, 0, 0);
     a20:	4681                	li	a3,0
     a22:	4601                	li	a2,0
     a24:	85ce                	mv	a1,s3
     a26:	854a                	mv	a0,s2
     a28:	00000097          	auipc	ra,0x0
     a2c:	b64080e7          	jalr	-1180(ra) # 58c <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     a30:	85ce                	mv	a1,s3
     a32:	854a                	mv	a0,s2
     a34:	00000097          	auipc	ra,0x0
     a38:	f70080e7          	jalr	-144(ra) # 9a4 <parseline>
     a3c:	85aa                	mv	a1,a0
     a3e:	8526                	mv	a0,s1
     a40:	00000097          	auipc	ra,0x0
     a44:	aca080e7          	jalr	-1334(ra) # 50a <listcmd>
     a48:	84aa                	mv	s1,a0
  return cmd;
     a4a:	b7d1                	j	a0e <parseline+0x6a>

0000000000000a4c <parseblock>:
{
     a4c:	7179                	addi	sp,sp,-48
     a4e:	f406                	sd	ra,40(sp)
     a50:	f022                	sd	s0,32(sp)
     a52:	ec26                	sd	s1,24(sp)
     a54:	e84a                	sd	s2,16(sp)
     a56:	e44e                	sd	s3,8(sp)
     a58:	1800                	addi	s0,sp,48
     a5a:	84aa                	mv	s1,a0
     a5c:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     a5e:	00001617          	auipc	a2,0x1
     a62:	b1a60613          	addi	a2,a2,-1254 # 1578 <malloc+0x164>
     a66:	00000097          	auipc	ra,0x0
     a6a:	c62080e7          	jalr	-926(ra) # 6c8 <peek>
     a6e:	c12d                	beqz	a0,ad0 <parseblock+0x84>
  gettoken(ps, es, 0, 0);
     a70:	4681                	li	a3,0
     a72:	4601                	li	a2,0
     a74:	85ca                	mv	a1,s2
     a76:	8526                	mv	a0,s1
     a78:	00000097          	auipc	ra,0x0
     a7c:	b14080e7          	jalr	-1260(ra) # 58c <gettoken>
  cmd = parseline(ps, es);
     a80:	85ca                	mv	a1,s2
     a82:	8526                	mv	a0,s1
     a84:	00000097          	auipc	ra,0x0
     a88:	f20080e7          	jalr	-224(ra) # 9a4 <parseline>
     a8c:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     a8e:	00001617          	auipc	a2,0x1
     a92:	b3a60613          	addi	a2,a2,-1222 # 15c8 <malloc+0x1b4>
     a96:	85ca                	mv	a1,s2
     a98:	8526                	mv	a0,s1
     a9a:	00000097          	auipc	ra,0x0
     a9e:	c2e080e7          	jalr	-978(ra) # 6c8 <peek>
     aa2:	cd1d                	beqz	a0,ae0 <parseblock+0x94>
  gettoken(ps, es, 0, 0);
     aa4:	4681                	li	a3,0
     aa6:	4601                	li	a2,0
     aa8:	85ca                	mv	a1,s2
     aaa:	8526                	mv	a0,s1
     aac:	00000097          	auipc	ra,0x0
     ab0:	ae0080e7          	jalr	-1312(ra) # 58c <gettoken>
  cmd = parseredirs(cmd, ps, es);
     ab4:	864a                	mv	a2,s2
     ab6:	85a6                	mv	a1,s1
     ab8:	854e                	mv	a0,s3
     aba:	00000097          	auipc	ra,0x0
     abe:	c78080e7          	jalr	-904(ra) # 732 <parseredirs>
}
     ac2:	70a2                	ld	ra,40(sp)
     ac4:	7402                	ld	s0,32(sp)
     ac6:	64e2                	ld	s1,24(sp)
     ac8:	6942                	ld	s2,16(sp)
     aca:	69a2                	ld	s3,8(sp)
     acc:	6145                	addi	sp,sp,48
     ace:	8082                	ret
    panic("parseblock");
     ad0:	00001517          	auipc	a0,0x1
     ad4:	ae850513          	addi	a0,a0,-1304 # 15b8 <malloc+0x1a4>
     ad8:	fffff097          	auipc	ra,0xfffff
     adc:	650080e7          	jalr	1616(ra) # 128 <panic>
    panic("syntax - missing )");
     ae0:	00001517          	auipc	a0,0x1
     ae4:	af050513          	addi	a0,a0,-1296 # 15d0 <malloc+0x1bc>
     ae8:	fffff097          	auipc	ra,0xfffff
     aec:	640080e7          	jalr	1600(ra) # 128 <panic>

0000000000000af0 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     af0:	1101                	addi	sp,sp,-32
     af2:	ec06                	sd	ra,24(sp)
     af4:	e822                	sd	s0,16(sp)
     af6:	e426                	sd	s1,8(sp)
     af8:	1000                	addi	s0,sp,32
     afa:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     afc:	c521                	beqz	a0,b44 <nulterminate+0x54>
    return 0;

  switch(cmd->type){
     afe:	4118                	lw	a4,0(a0)
     b00:	4795                	li	a5,5
     b02:	04e7e163          	bltu	a5,a4,b44 <nulterminate+0x54>
     b06:	00056783          	lwu	a5,0(a0)
     b0a:	078a                	slli	a5,a5,0x2
     b0c:	00001717          	auipc	a4,0x1
     b10:	b2470713          	addi	a4,a4,-1244 # 1630 <malloc+0x21c>
     b14:	97ba                	add	a5,a5,a4
     b16:	439c                	lw	a5,0(a5)
     b18:	97ba                	add	a5,a5,a4
     b1a:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     b1c:	651c                	ld	a5,8(a0)
     b1e:	c39d                	beqz	a5,b44 <nulterminate+0x54>
     b20:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     b24:	67b8                	ld	a4,72(a5)
     b26:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     b2a:	07a1                	addi	a5,a5,8
     b2c:	ff87b703          	ld	a4,-8(a5)
     b30:	fb75                	bnez	a4,b24 <nulterminate+0x34>
     b32:	a809                	j	b44 <nulterminate+0x54>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     b34:	6508                	ld	a0,8(a0)
     b36:	00000097          	auipc	ra,0x0
     b3a:	fba080e7          	jalr	-70(ra) # af0 <nulterminate>
    *rcmd->efile = 0;
     b3e:	6c9c                	ld	a5,24(s1)
     b40:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     b44:	8526                	mv	a0,s1
     b46:	60e2                	ld	ra,24(sp)
     b48:	6442                	ld	s0,16(sp)
     b4a:	64a2                	ld	s1,8(sp)
     b4c:	6105                	addi	sp,sp,32
     b4e:	8082                	ret
    nulterminate(pcmd->left);
     b50:	6508                	ld	a0,8(a0)
     b52:	00000097          	auipc	ra,0x0
     b56:	f9e080e7          	jalr	-98(ra) # af0 <nulterminate>
    nulterminate(pcmd->right);
     b5a:	6888                	ld	a0,16(s1)
     b5c:	00000097          	auipc	ra,0x0
     b60:	f94080e7          	jalr	-108(ra) # af0 <nulterminate>
    break;
     b64:	b7c5                	j	b44 <nulterminate+0x54>
    nulterminate(lcmd->left);
     b66:	6508                	ld	a0,8(a0)
     b68:	00000097          	auipc	ra,0x0
     b6c:	f88080e7          	jalr	-120(ra) # af0 <nulterminate>
    nulterminate(lcmd->right);
     b70:	6888                	ld	a0,16(s1)
     b72:	00000097          	auipc	ra,0x0
     b76:	f7e080e7          	jalr	-130(ra) # af0 <nulterminate>
    break;
     b7a:	b7e9                	j	b44 <nulterminate+0x54>
    nulterminate(bcmd->cmd);
     b7c:	6508                	ld	a0,8(a0)
     b7e:	00000097          	auipc	ra,0x0
     b82:	f72080e7          	jalr	-142(ra) # af0 <nulterminate>
    break;
     b86:	bf7d                	j	b44 <nulterminate+0x54>

0000000000000b88 <parsecmd>:
{
     b88:	7179                	addi	sp,sp,-48
     b8a:	f406                	sd	ra,40(sp)
     b8c:	f022                	sd	s0,32(sp)
     b8e:	ec26                	sd	s1,24(sp)
     b90:	e84a                	sd	s2,16(sp)
     b92:	1800                	addi	s0,sp,48
     b94:	fca43c23          	sd	a0,-40(s0)
  es = s + strlen(s);
     b98:	84aa                	mv	s1,a0
     b9a:	00000097          	auipc	ra,0x0
     b9e:	1b2080e7          	jalr	434(ra) # d4c <strlen>
     ba2:	1502                	slli	a0,a0,0x20
     ba4:	9101                	srli	a0,a0,0x20
     ba6:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     ba8:	85a6                	mv	a1,s1
     baa:	fd840513          	addi	a0,s0,-40
     bae:	00000097          	auipc	ra,0x0
     bb2:	df6080e7          	jalr	-522(ra) # 9a4 <parseline>
     bb6:	892a                	mv	s2,a0
  peek(&s, es, "");
     bb8:	00001617          	auipc	a2,0x1
     bbc:	a3060613          	addi	a2,a2,-1488 # 15e8 <malloc+0x1d4>
     bc0:	85a6                	mv	a1,s1
     bc2:	fd840513          	addi	a0,s0,-40
     bc6:	00000097          	auipc	ra,0x0
     bca:	b02080e7          	jalr	-1278(ra) # 6c8 <peek>
  if(s != es){
     bce:	fd843603          	ld	a2,-40(s0)
     bd2:	00961e63          	bne	a2,s1,bee <parsecmd+0x66>
  nulterminate(cmd);
     bd6:	854a                	mv	a0,s2
     bd8:	00000097          	auipc	ra,0x0
     bdc:	f18080e7          	jalr	-232(ra) # af0 <nulterminate>
}
     be0:	854a                	mv	a0,s2
     be2:	70a2                	ld	ra,40(sp)
     be4:	7402                	ld	s0,32(sp)
     be6:	64e2                	ld	s1,24(sp)
     be8:	6942                	ld	s2,16(sp)
     bea:	6145                	addi	sp,sp,48
     bec:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     bee:	00001597          	auipc	a1,0x1
     bf2:	a0258593          	addi	a1,a1,-1534 # 15f0 <malloc+0x1dc>
     bf6:	4509                	li	a0,2
     bf8:	00000097          	auipc	ra,0x0
     bfc:	730080e7          	jalr	1840(ra) # 1328 <fprintf>
    panic("syntax");
     c00:	00001517          	auipc	a0,0x1
     c04:	98050513          	addi	a0,a0,-1664 # 1580 <malloc+0x16c>
     c08:	fffff097          	auipc	ra,0xfffff
     c0c:	520080e7          	jalr	1312(ra) # 128 <panic>

0000000000000c10 <main>:
{
     c10:	7139                	addi	sp,sp,-64
     c12:	fc06                	sd	ra,56(sp)
     c14:	f822                	sd	s0,48(sp)
     c16:	f426                	sd	s1,40(sp)
     c18:	f04a                	sd	s2,32(sp)
     c1a:	ec4e                	sd	s3,24(sp)
     c1c:	e852                	sd	s4,16(sp)
     c1e:	e456                	sd	s5,8(sp)
     c20:	0080                	addi	s0,sp,64
  while((fd = open("console", O_RDWR)) >= 0){
     c22:	00001497          	auipc	s1,0x1
     c26:	9de48493          	addi	s1,s1,-1570 # 1600 <malloc+0x1ec>
     c2a:	4589                	li	a1,2
     c2c:	8526                	mv	a0,s1
     c2e:	00000097          	auipc	ra,0x0
     c32:	3e0080e7          	jalr	992(ra) # 100e <open>
     c36:	00054963          	bltz	a0,c48 <main+0x38>
    if(fd >= 3){
     c3a:	4789                	li	a5,2
     c3c:	fea7d7e3          	bge	a5,a0,c2a <main+0x1a>
      close(fd);
     c40:	00000097          	auipc	ra,0x0
     c44:	3b6080e7          	jalr	950(ra) # ff6 <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     c48:	00001497          	auipc	s1,0x1
     c4c:	a3848493          	addi	s1,s1,-1480 # 1680 <buf.0>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     c50:	06300913          	li	s2,99
     c54:	02000993          	li	s3,32
      if(chdir(buf+3) < 0)
     c58:	00001a17          	auipc	s4,0x1
     c5c:	a2ba0a13          	addi	s4,s4,-1493 # 1683 <buf.0+0x3>
        fprintf(2, "cannot cd %s\n", buf+3);
     c60:	00001a97          	auipc	s5,0x1
     c64:	9a8a8a93          	addi	s5,s5,-1624 # 1608 <malloc+0x1f4>
     c68:	a819                	j	c7e <main+0x6e>
    if(fork1() == 0)
     c6a:	fffff097          	auipc	ra,0xfffff
     c6e:	4e4080e7          	jalr	1252(ra) # 14e <fork1>
     c72:	c925                	beqz	a0,ce2 <main+0xd2>
    wait(0);
     c74:	4501                	li	a0,0
     c76:	00000097          	auipc	ra,0x0
     c7a:	360080e7          	jalr	864(ra) # fd6 <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     c7e:	06400593          	li	a1,100
     c82:	8526                	mv	a0,s1
     c84:	fffff097          	auipc	ra,0xfffff
     c88:	450080e7          	jalr	1104(ra) # d4 <getcmd>
     c8c:	06054763          	bltz	a0,cfa <main+0xea>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     c90:	0004c783          	lbu	a5,0(s1)
     c94:	fd279be3          	bne	a5,s2,c6a <main+0x5a>
     c98:	0014c703          	lbu	a4,1(s1)
     c9c:	06400793          	li	a5,100
     ca0:	fcf715e3          	bne	a4,a5,c6a <main+0x5a>
     ca4:	0024c783          	lbu	a5,2(s1)
     ca8:	fd3791e3          	bne	a5,s3,c6a <main+0x5a>
      buf[strlen(buf)-1] = 0;  // chop \n
     cac:	8526                	mv	a0,s1
     cae:	00000097          	auipc	ra,0x0
     cb2:	09e080e7          	jalr	158(ra) # d4c <strlen>
     cb6:	fff5079b          	addiw	a5,a0,-1
     cba:	1782                	slli	a5,a5,0x20
     cbc:	9381                	srli	a5,a5,0x20
     cbe:	97a6                	add	a5,a5,s1
     cc0:	00078023          	sb	zero,0(a5)
      if(chdir(buf+3) < 0)
     cc4:	8552                	mv	a0,s4
     cc6:	00000097          	auipc	ra,0x0
     cca:	378080e7          	jalr	888(ra) # 103e <chdir>
     cce:	fa0558e3          	bgez	a0,c7e <main+0x6e>
        fprintf(2, "cannot cd %s\n", buf+3);
     cd2:	8652                	mv	a2,s4
     cd4:	85d6                	mv	a1,s5
     cd6:	4509                	li	a0,2
     cd8:	00000097          	auipc	ra,0x0
     cdc:	650080e7          	jalr	1616(ra) # 1328 <fprintf>
     ce0:	bf79                	j	c7e <main+0x6e>
      runcmd(parsecmd(buf));
     ce2:	00001517          	auipc	a0,0x1
     ce6:	99e50513          	addi	a0,a0,-1634 # 1680 <buf.0>
     cea:	00000097          	auipc	ra,0x0
     cee:	e9e080e7          	jalr	-354(ra) # b88 <parsecmd>
     cf2:	fffff097          	auipc	ra,0xfffff
     cf6:	48a080e7          	jalr	1162(ra) # 17c <runcmd>
  exit(0);
     cfa:	4501                	li	a0,0
     cfc:	00000097          	auipc	ra,0x0
     d00:	2d2080e7          	jalr	722(ra) # fce <exit>

0000000000000d04 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     d04:	1141                	addi	sp,sp,-16
     d06:	e422                	sd	s0,8(sp)
     d08:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     d0a:	87aa                	mv	a5,a0
     d0c:	0585                	addi	a1,a1,1
     d0e:	0785                	addi	a5,a5,1
     d10:	fff5c703          	lbu	a4,-1(a1)
     d14:	fee78fa3          	sb	a4,-1(a5)
     d18:	fb75                	bnez	a4,d0c <strcpy+0x8>
    ;
  return os;
}
     d1a:	6422                	ld	s0,8(sp)
     d1c:	0141                	addi	sp,sp,16
     d1e:	8082                	ret

0000000000000d20 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     d20:	1141                	addi	sp,sp,-16
     d22:	e422                	sd	s0,8(sp)
     d24:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     d26:	00054783          	lbu	a5,0(a0)
     d2a:	cb91                	beqz	a5,d3e <strcmp+0x1e>
     d2c:	0005c703          	lbu	a4,0(a1)
     d30:	00f71763          	bne	a4,a5,d3e <strcmp+0x1e>
    p++, q++;
     d34:	0505                	addi	a0,a0,1
     d36:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     d38:	00054783          	lbu	a5,0(a0)
     d3c:	fbe5                	bnez	a5,d2c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     d3e:	0005c503          	lbu	a0,0(a1)
}
     d42:	40a7853b          	subw	a0,a5,a0
     d46:	6422                	ld	s0,8(sp)
     d48:	0141                	addi	sp,sp,16
     d4a:	8082                	ret

0000000000000d4c <strlen>:

uint
strlen(const char *s)
{
     d4c:	1141                	addi	sp,sp,-16
     d4e:	e422                	sd	s0,8(sp)
     d50:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     d52:	00054783          	lbu	a5,0(a0)
     d56:	cf91                	beqz	a5,d72 <strlen+0x26>
     d58:	0505                	addi	a0,a0,1
     d5a:	87aa                	mv	a5,a0
     d5c:	4685                	li	a3,1
     d5e:	9e89                	subw	a3,a3,a0
     d60:	00f6853b          	addw	a0,a3,a5
     d64:	0785                	addi	a5,a5,1
     d66:	fff7c703          	lbu	a4,-1(a5)
     d6a:	fb7d                	bnez	a4,d60 <strlen+0x14>
    ;
  return n;
}
     d6c:	6422                	ld	s0,8(sp)
     d6e:	0141                	addi	sp,sp,16
     d70:	8082                	ret
  for(n = 0; s[n]; n++)
     d72:	4501                	li	a0,0
     d74:	bfe5                	j	d6c <strlen+0x20>

0000000000000d76 <memset>:

void*
memset(void *dst, int c, uint n)
{
     d76:	1141                	addi	sp,sp,-16
     d78:	e422                	sd	s0,8(sp)
     d7a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     d7c:	ca19                	beqz	a2,d92 <memset+0x1c>
     d7e:	87aa                	mv	a5,a0
     d80:	1602                	slli	a2,a2,0x20
     d82:	9201                	srli	a2,a2,0x20
     d84:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     d88:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     d8c:	0785                	addi	a5,a5,1
     d8e:	fee79de3          	bne	a5,a4,d88 <memset+0x12>
  }
  return dst;
}
     d92:	6422                	ld	s0,8(sp)
     d94:	0141                	addi	sp,sp,16
     d96:	8082                	ret

0000000000000d98 <strchr>:

char*
strchr(const char *s, char c)
{
     d98:	1141                	addi	sp,sp,-16
     d9a:	e422                	sd	s0,8(sp)
     d9c:	0800                	addi	s0,sp,16
  for(; *s; s++)
     d9e:	00054783          	lbu	a5,0(a0)
     da2:	cb99                	beqz	a5,db8 <strchr+0x20>
    if(*s == c)
     da4:	00f58763          	beq	a1,a5,db2 <strchr+0x1a>
  for(; *s; s++)
     da8:	0505                	addi	a0,a0,1
     daa:	00054783          	lbu	a5,0(a0)
     dae:	fbfd                	bnez	a5,da4 <strchr+0xc>
      return (char*)s;
  return 0;
     db0:	4501                	li	a0,0
}
     db2:	6422                	ld	s0,8(sp)
     db4:	0141                	addi	sp,sp,16
     db6:	8082                	ret
  return 0;
     db8:	4501                	li	a0,0
     dba:	bfe5                	j	db2 <strchr+0x1a>

0000000000000dbc <gets>:

char*
gets(char *buf, int max)
{
     dbc:	711d                	addi	sp,sp,-96
     dbe:	ec86                	sd	ra,88(sp)
     dc0:	e8a2                	sd	s0,80(sp)
     dc2:	e4a6                	sd	s1,72(sp)
     dc4:	e0ca                	sd	s2,64(sp)
     dc6:	fc4e                	sd	s3,56(sp)
     dc8:	f852                	sd	s4,48(sp)
     dca:	f456                	sd	s5,40(sp)
     dcc:	f05a                	sd	s6,32(sp)
     dce:	ec5e                	sd	s7,24(sp)
     dd0:	1080                	addi	s0,sp,96
     dd2:	8baa                	mv	s7,a0
     dd4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     dd6:	892a                	mv	s2,a0
     dd8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     dda:	4aa9                	li	s5,10
     ddc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     dde:	89a6                	mv	s3,s1
     de0:	2485                	addiw	s1,s1,1
     de2:	0344d863          	bge	s1,s4,e12 <gets+0x56>
    cc = read(0, &c, 1);
     de6:	4605                	li	a2,1
     de8:	faf40593          	addi	a1,s0,-81
     dec:	4501                	li	a0,0
     dee:	00000097          	auipc	ra,0x0
     df2:	1f8080e7          	jalr	504(ra) # fe6 <read>
    if(cc < 1)
     df6:	00a05e63          	blez	a0,e12 <gets+0x56>
    buf[i++] = c;
     dfa:	faf44783          	lbu	a5,-81(s0)
     dfe:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     e02:	01578763          	beq	a5,s5,e10 <gets+0x54>
     e06:	0905                	addi	s2,s2,1
     e08:	fd679be3          	bne	a5,s6,dde <gets+0x22>
  for(i=0; i+1 < max; ){
     e0c:	89a6                	mv	s3,s1
     e0e:	a011                	j	e12 <gets+0x56>
     e10:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     e12:	99de                	add	s3,s3,s7
     e14:	00098023          	sb	zero,0(s3)
  return buf;
}
     e18:	855e                	mv	a0,s7
     e1a:	60e6                	ld	ra,88(sp)
     e1c:	6446                	ld	s0,80(sp)
     e1e:	64a6                	ld	s1,72(sp)
     e20:	6906                	ld	s2,64(sp)
     e22:	79e2                	ld	s3,56(sp)
     e24:	7a42                	ld	s4,48(sp)
     e26:	7aa2                	ld	s5,40(sp)
     e28:	7b02                	ld	s6,32(sp)
     e2a:	6be2                	ld	s7,24(sp)
     e2c:	6125                	addi	sp,sp,96
     e2e:	8082                	ret

0000000000000e30 <stat>:

int
stat(const char *n, struct stat *st)
{
     e30:	1101                	addi	sp,sp,-32
     e32:	ec06                	sd	ra,24(sp)
     e34:	e822                	sd	s0,16(sp)
     e36:	e426                	sd	s1,8(sp)
     e38:	e04a                	sd	s2,0(sp)
     e3a:	1000                	addi	s0,sp,32
     e3c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     e3e:	4581                	li	a1,0
     e40:	00000097          	auipc	ra,0x0
     e44:	1ce080e7          	jalr	462(ra) # 100e <open>
  if(fd < 0)
     e48:	02054563          	bltz	a0,e72 <stat+0x42>
     e4c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     e4e:	85ca                	mv	a1,s2
     e50:	00000097          	auipc	ra,0x0
     e54:	1d6080e7          	jalr	470(ra) # 1026 <fstat>
     e58:	892a                	mv	s2,a0
  close(fd);
     e5a:	8526                	mv	a0,s1
     e5c:	00000097          	auipc	ra,0x0
     e60:	19a080e7          	jalr	410(ra) # ff6 <close>
  return r;
}
     e64:	854a                	mv	a0,s2
     e66:	60e2                	ld	ra,24(sp)
     e68:	6442                	ld	s0,16(sp)
     e6a:	64a2                	ld	s1,8(sp)
     e6c:	6902                	ld	s2,0(sp)
     e6e:	6105                	addi	sp,sp,32
     e70:	8082                	ret
    return -1;
     e72:	597d                	li	s2,-1
     e74:	bfc5                	j	e64 <stat+0x34>

0000000000000e76 <atoi>:

int
atoi(const char *s)
{
     e76:	1141                	addi	sp,sp,-16
     e78:	e422                	sd	s0,8(sp)
     e7a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     e7c:	00054603          	lbu	a2,0(a0)
     e80:	fd06079b          	addiw	a5,a2,-48
     e84:	0ff7f793          	andi	a5,a5,255
     e88:	4725                	li	a4,9
     e8a:	02f76963          	bltu	a4,a5,ebc <atoi+0x46>
     e8e:	86aa                	mv	a3,a0
  n = 0;
     e90:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     e92:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     e94:	0685                	addi	a3,a3,1
     e96:	0025179b          	slliw	a5,a0,0x2
     e9a:	9fa9                	addw	a5,a5,a0
     e9c:	0017979b          	slliw	a5,a5,0x1
     ea0:	9fb1                	addw	a5,a5,a2
     ea2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     ea6:	0006c603          	lbu	a2,0(a3)
     eaa:	fd06071b          	addiw	a4,a2,-48
     eae:	0ff77713          	andi	a4,a4,255
     eb2:	fee5f1e3          	bgeu	a1,a4,e94 <atoi+0x1e>
  return n;
}
     eb6:	6422                	ld	s0,8(sp)
     eb8:	0141                	addi	sp,sp,16
     eba:	8082                	ret
  n = 0;
     ebc:	4501                	li	a0,0
     ebe:	bfe5                	j	eb6 <atoi+0x40>

0000000000000ec0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     ec0:	1141                	addi	sp,sp,-16
     ec2:	e422                	sd	s0,8(sp)
     ec4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     ec6:	02b57463          	bgeu	a0,a1,eee <memmove+0x2e>
    while(n-- > 0)
     eca:	00c05f63          	blez	a2,ee8 <memmove+0x28>
     ece:	1602                	slli	a2,a2,0x20
     ed0:	9201                	srli	a2,a2,0x20
     ed2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     ed6:	872a                	mv	a4,a0
      *dst++ = *src++;
     ed8:	0585                	addi	a1,a1,1
     eda:	0705                	addi	a4,a4,1
     edc:	fff5c683          	lbu	a3,-1(a1)
     ee0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     ee4:	fee79ae3          	bne	a5,a4,ed8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     ee8:	6422                	ld	s0,8(sp)
     eea:	0141                	addi	sp,sp,16
     eec:	8082                	ret
    dst += n;
     eee:	00c50733          	add	a4,a0,a2
    src += n;
     ef2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     ef4:	fec05ae3          	blez	a2,ee8 <memmove+0x28>
     ef8:	fff6079b          	addiw	a5,a2,-1
     efc:	1782                	slli	a5,a5,0x20
     efe:	9381                	srli	a5,a5,0x20
     f00:	fff7c793          	not	a5,a5
     f04:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     f06:	15fd                	addi	a1,a1,-1
     f08:	177d                	addi	a4,a4,-1
     f0a:	0005c683          	lbu	a3,0(a1)
     f0e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     f12:	fee79ae3          	bne	a5,a4,f06 <memmove+0x46>
     f16:	bfc9                	j	ee8 <memmove+0x28>

0000000000000f18 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     f18:	1141                	addi	sp,sp,-16
     f1a:	e422                	sd	s0,8(sp)
     f1c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     f1e:	ca05                	beqz	a2,f4e <memcmp+0x36>
     f20:	fff6069b          	addiw	a3,a2,-1
     f24:	1682                	slli	a3,a3,0x20
     f26:	9281                	srli	a3,a3,0x20
     f28:	0685                	addi	a3,a3,1
     f2a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     f2c:	00054783          	lbu	a5,0(a0)
     f30:	0005c703          	lbu	a4,0(a1)
     f34:	00e79863          	bne	a5,a4,f44 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     f38:	0505                	addi	a0,a0,1
    p2++;
     f3a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     f3c:	fed518e3          	bne	a0,a3,f2c <memcmp+0x14>
  }
  return 0;
     f40:	4501                	li	a0,0
     f42:	a019                	j	f48 <memcmp+0x30>
      return *p1 - *p2;
     f44:	40e7853b          	subw	a0,a5,a4
}
     f48:	6422                	ld	s0,8(sp)
     f4a:	0141                	addi	sp,sp,16
     f4c:	8082                	ret
  return 0;
     f4e:	4501                	li	a0,0
     f50:	bfe5                	j	f48 <memcmp+0x30>

0000000000000f52 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     f52:	1141                	addi	sp,sp,-16
     f54:	e406                	sd	ra,8(sp)
     f56:	e022                	sd	s0,0(sp)
     f58:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     f5a:	00000097          	auipc	ra,0x0
     f5e:	f66080e7          	jalr	-154(ra) # ec0 <memmove>
}
     f62:	60a2                	ld	ra,8(sp)
     f64:	6402                	ld	s0,0(sp)
     f66:	0141                	addi	sp,sp,16
     f68:	8082                	ret

0000000000000f6a <my_strcat>:

// functions added by us

char* my_strcat(char* destination, const char* source)
{
     f6a:	1141                	addi	sp,sp,-16
     f6c:	e422                	sd	s0,8(sp)
     f6e:	0800                	addi	s0,sp,16
    int i, j;
 
    // move to the end of destination string
    for (i = 0; destination[i] != '\0'; i++);
     f70:	00054783          	lbu	a5,0(a0)
     f74:	c7a9                	beqz	a5,fbe <my_strcat+0x54>
     f76:	00150713          	addi	a4,a0,1
     f7a:	87ba                	mv	a5,a4
     f7c:	4685                	li	a3,1
     f7e:	9e99                	subw	a3,a3,a4
     f80:	00f6863b          	addw	a2,a3,a5
     f84:	0785                	addi	a5,a5,1
     f86:	fff7c703          	lbu	a4,-1(a5)
     f8a:	fb7d                	bnez	a4,f80 <my_strcat+0x16>
 
    // i now points to terminating null character in destination
 
    // Appends characters of source to the destination string
    for (j = 0; source[j] != '\0'; j++)
     f8c:	0005c683          	lbu	a3,0(a1)
     f90:	ca8d                	beqz	a3,fc2 <my_strcat+0x58>
     f92:	4785                	li	a5,1
        destination[i + j] = source[j];
     f94:	00f60733          	add	a4,a2,a5
     f98:	972a                	add	a4,a4,a0
     f9a:	fed70fa3          	sb	a3,-1(a4)
    for (j = 0; source[j] != '\0'; j++)
     f9e:	0007881b          	sext.w	a6,a5
     fa2:	0785                	addi	a5,a5,1
     fa4:	00f58733          	add	a4,a1,a5
     fa8:	fff74683          	lbu	a3,-1(a4)
     fac:	f6e5                	bnez	a3,f94 <my_strcat+0x2a>
 
    // null terminate destination string
    destination[i + j] = '\0';
     fae:	0106063b          	addw	a2,a2,a6
     fb2:	962a                	add	a2,a2,a0
     fb4:	00060023          	sb	zero,0(a2)
 
    // destination is returned by standard strcat()
    return destination;
     fb8:	6422                	ld	s0,8(sp)
     fba:	0141                	addi	sp,sp,16
     fbc:	8082                	ret
    for (i = 0; destination[i] != '\0'; i++);
     fbe:	4601                	li	a2,0
     fc0:	b7f1                	j	f8c <my_strcat+0x22>
    for (j = 0; source[j] != '\0'; j++)
     fc2:	4801                	li	a6,0
     fc4:	b7ed                	j	fae <my_strcat+0x44>

0000000000000fc6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     fc6:	4885                	li	a7,1
 ecall
     fc8:	00000073          	ecall
 ret
     fcc:	8082                	ret

0000000000000fce <exit>:
.global exit
exit:
 li a7, SYS_exit
     fce:	4889                	li	a7,2
 ecall
     fd0:	00000073          	ecall
 ret
     fd4:	8082                	ret

0000000000000fd6 <wait>:
.global wait
wait:
 li a7, SYS_wait
     fd6:	488d                	li	a7,3
 ecall
     fd8:	00000073          	ecall
 ret
     fdc:	8082                	ret

0000000000000fde <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     fde:	4891                	li	a7,4
 ecall
     fe0:	00000073          	ecall
 ret
     fe4:	8082                	ret

0000000000000fe6 <read>:
.global read
read:
 li a7, SYS_read
     fe6:	4895                	li	a7,5
 ecall
     fe8:	00000073          	ecall
 ret
     fec:	8082                	ret

0000000000000fee <write>:
.global write
write:
 li a7, SYS_write
     fee:	48c1                	li	a7,16
 ecall
     ff0:	00000073          	ecall
 ret
     ff4:	8082                	ret

0000000000000ff6 <close>:
.global close
close:
 li a7, SYS_close
     ff6:	48d5                	li	a7,21
 ecall
     ff8:	00000073          	ecall
 ret
     ffc:	8082                	ret

0000000000000ffe <kill>:
.global kill
kill:
 li a7, SYS_kill
     ffe:	4899                	li	a7,6
 ecall
    1000:	00000073          	ecall
 ret
    1004:	8082                	ret

0000000000001006 <exec>:
.global exec
exec:
 li a7, SYS_exec
    1006:	489d                	li	a7,7
 ecall
    1008:	00000073          	ecall
 ret
    100c:	8082                	ret

000000000000100e <open>:
.global open
open:
 li a7, SYS_open
    100e:	48bd                	li	a7,15
 ecall
    1010:	00000073          	ecall
 ret
    1014:	8082                	ret

0000000000001016 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    1016:	48c5                	li	a7,17
 ecall
    1018:	00000073          	ecall
 ret
    101c:	8082                	ret

000000000000101e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    101e:	48c9                	li	a7,18
 ecall
    1020:	00000073          	ecall
 ret
    1024:	8082                	ret

0000000000001026 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    1026:	48a1                	li	a7,8
 ecall
    1028:	00000073          	ecall
 ret
    102c:	8082                	ret

000000000000102e <link>:
.global link
link:
 li a7, SYS_link
    102e:	48cd                	li	a7,19
 ecall
    1030:	00000073          	ecall
 ret
    1034:	8082                	ret

0000000000001036 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    1036:	48d1                	li	a7,20
 ecall
    1038:	00000073          	ecall
 ret
    103c:	8082                	ret

000000000000103e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    103e:	48a5                	li	a7,9
 ecall
    1040:	00000073          	ecall
 ret
    1044:	8082                	ret

0000000000001046 <dup>:
.global dup
dup:
 li a7, SYS_dup
    1046:	48a9                	li	a7,10
 ecall
    1048:	00000073          	ecall
 ret
    104c:	8082                	ret

000000000000104e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    104e:	48ad                	li	a7,11
 ecall
    1050:	00000073          	ecall
 ret
    1054:	8082                	ret

0000000000001056 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    1056:	48b1                	li	a7,12
 ecall
    1058:	00000073          	ecall
 ret
    105c:	8082                	ret

000000000000105e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    105e:	48b5                	li	a7,13
 ecall
    1060:	00000073          	ecall
 ret
    1064:	8082                	ret

0000000000001066 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    1066:	48b9                	li	a7,14
 ecall
    1068:	00000073          	ecall
 ret
    106c:	8082                	ret

000000000000106e <trace>:
.global trace
trace:
 li a7, SYS_trace
    106e:	48d9                	li	a7,22
 ecall
    1070:	00000073          	ecall
 ret
    1074:	8082                	ret

0000000000001076 <wait_stat>:
.global wait_stat
wait_stat:
 li a7, SYS_wait_stat
    1076:	48dd                	li	a7,23
 ecall
    1078:	00000073          	ecall
 ret
    107c:	8082                	ret

000000000000107e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    107e:	1101                	addi	sp,sp,-32
    1080:	ec06                	sd	ra,24(sp)
    1082:	e822                	sd	s0,16(sp)
    1084:	1000                	addi	s0,sp,32
    1086:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    108a:	4605                	li	a2,1
    108c:	fef40593          	addi	a1,s0,-17
    1090:	00000097          	auipc	ra,0x0
    1094:	f5e080e7          	jalr	-162(ra) # fee <write>
}
    1098:	60e2                	ld	ra,24(sp)
    109a:	6442                	ld	s0,16(sp)
    109c:	6105                	addi	sp,sp,32
    109e:	8082                	ret

00000000000010a0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    10a0:	7139                	addi	sp,sp,-64
    10a2:	fc06                	sd	ra,56(sp)
    10a4:	f822                	sd	s0,48(sp)
    10a6:	f426                	sd	s1,40(sp)
    10a8:	f04a                	sd	s2,32(sp)
    10aa:	ec4e                	sd	s3,24(sp)
    10ac:	0080                	addi	s0,sp,64
    10ae:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    10b0:	c299                	beqz	a3,10b6 <printint+0x16>
    10b2:	0805c863          	bltz	a1,1142 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    10b6:	2581                	sext.w	a1,a1
  neg = 0;
    10b8:	4881                	li	a7,0
    10ba:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    10be:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    10c0:	2601                	sext.w	a2,a2
    10c2:	00000517          	auipc	a0,0x0
    10c6:	58e50513          	addi	a0,a0,1422 # 1650 <digits>
    10ca:	883a                	mv	a6,a4
    10cc:	2705                	addiw	a4,a4,1
    10ce:	02c5f7bb          	remuw	a5,a1,a2
    10d2:	1782                	slli	a5,a5,0x20
    10d4:	9381                	srli	a5,a5,0x20
    10d6:	97aa                	add	a5,a5,a0
    10d8:	0007c783          	lbu	a5,0(a5)
    10dc:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    10e0:	0005879b          	sext.w	a5,a1
    10e4:	02c5d5bb          	divuw	a1,a1,a2
    10e8:	0685                	addi	a3,a3,1
    10ea:	fec7f0e3          	bgeu	a5,a2,10ca <printint+0x2a>
  if(neg)
    10ee:	00088b63          	beqz	a7,1104 <printint+0x64>
    buf[i++] = '-';
    10f2:	fd040793          	addi	a5,s0,-48
    10f6:	973e                	add	a4,a4,a5
    10f8:	02d00793          	li	a5,45
    10fc:	fef70823          	sb	a5,-16(a4)
    1100:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    1104:	02e05863          	blez	a4,1134 <printint+0x94>
    1108:	fc040793          	addi	a5,s0,-64
    110c:	00e78933          	add	s2,a5,a4
    1110:	fff78993          	addi	s3,a5,-1
    1114:	99ba                	add	s3,s3,a4
    1116:	377d                	addiw	a4,a4,-1
    1118:	1702                	slli	a4,a4,0x20
    111a:	9301                	srli	a4,a4,0x20
    111c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    1120:	fff94583          	lbu	a1,-1(s2)
    1124:	8526                	mv	a0,s1
    1126:	00000097          	auipc	ra,0x0
    112a:	f58080e7          	jalr	-168(ra) # 107e <putc>
  while(--i >= 0)
    112e:	197d                	addi	s2,s2,-1
    1130:	ff3918e3          	bne	s2,s3,1120 <printint+0x80>
}
    1134:	70e2                	ld	ra,56(sp)
    1136:	7442                	ld	s0,48(sp)
    1138:	74a2                	ld	s1,40(sp)
    113a:	7902                	ld	s2,32(sp)
    113c:	69e2                	ld	s3,24(sp)
    113e:	6121                	addi	sp,sp,64
    1140:	8082                	ret
    x = -xx;
    1142:	40b005bb          	negw	a1,a1
    neg = 1;
    1146:	4885                	li	a7,1
    x = -xx;
    1148:	bf8d                	j	10ba <printint+0x1a>

000000000000114a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    114a:	7119                	addi	sp,sp,-128
    114c:	fc86                	sd	ra,120(sp)
    114e:	f8a2                	sd	s0,112(sp)
    1150:	f4a6                	sd	s1,104(sp)
    1152:	f0ca                	sd	s2,96(sp)
    1154:	ecce                	sd	s3,88(sp)
    1156:	e8d2                	sd	s4,80(sp)
    1158:	e4d6                	sd	s5,72(sp)
    115a:	e0da                	sd	s6,64(sp)
    115c:	fc5e                	sd	s7,56(sp)
    115e:	f862                	sd	s8,48(sp)
    1160:	f466                	sd	s9,40(sp)
    1162:	f06a                	sd	s10,32(sp)
    1164:	ec6e                	sd	s11,24(sp)
    1166:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    1168:	0005c903          	lbu	s2,0(a1)
    116c:	18090f63          	beqz	s2,130a <vprintf+0x1c0>
    1170:	8aaa                	mv	s5,a0
    1172:	8b32                	mv	s6,a2
    1174:	00158493          	addi	s1,a1,1
  state = 0;
    1178:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    117a:	02500a13          	li	s4,37
      if(c == 'd'){
    117e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    1182:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    1186:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    118a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    118e:	00000b97          	auipc	s7,0x0
    1192:	4c2b8b93          	addi	s7,s7,1218 # 1650 <digits>
    1196:	a839                	j	11b4 <vprintf+0x6a>
        putc(fd, c);
    1198:	85ca                	mv	a1,s2
    119a:	8556                	mv	a0,s5
    119c:	00000097          	auipc	ra,0x0
    11a0:	ee2080e7          	jalr	-286(ra) # 107e <putc>
    11a4:	a019                	j	11aa <vprintf+0x60>
    } else if(state == '%'){
    11a6:	01498f63          	beq	s3,s4,11c4 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    11aa:	0485                	addi	s1,s1,1
    11ac:	fff4c903          	lbu	s2,-1(s1)
    11b0:	14090d63          	beqz	s2,130a <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    11b4:	0009079b          	sext.w	a5,s2
    if(state == 0){
    11b8:	fe0997e3          	bnez	s3,11a6 <vprintf+0x5c>
      if(c == '%'){
    11bc:	fd479ee3          	bne	a5,s4,1198 <vprintf+0x4e>
        state = '%';
    11c0:	89be                	mv	s3,a5
    11c2:	b7e5                	j	11aa <vprintf+0x60>
      if(c == 'd'){
    11c4:	05878063          	beq	a5,s8,1204 <vprintf+0xba>
      } else if(c == 'l') {
    11c8:	05978c63          	beq	a5,s9,1220 <vprintf+0xd6>
      } else if(c == 'x') {
    11cc:	07a78863          	beq	a5,s10,123c <vprintf+0xf2>
      } else if(c == 'p') {
    11d0:	09b78463          	beq	a5,s11,1258 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    11d4:	07300713          	li	a4,115
    11d8:	0ce78663          	beq	a5,a4,12a4 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    11dc:	06300713          	li	a4,99
    11e0:	0ee78e63          	beq	a5,a4,12dc <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    11e4:	11478863          	beq	a5,s4,12f4 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    11e8:	85d2                	mv	a1,s4
    11ea:	8556                	mv	a0,s5
    11ec:	00000097          	auipc	ra,0x0
    11f0:	e92080e7          	jalr	-366(ra) # 107e <putc>
        putc(fd, c);
    11f4:	85ca                	mv	a1,s2
    11f6:	8556                	mv	a0,s5
    11f8:	00000097          	auipc	ra,0x0
    11fc:	e86080e7          	jalr	-378(ra) # 107e <putc>
      }
      state = 0;
    1200:	4981                	li	s3,0
    1202:	b765                	j	11aa <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    1204:	008b0913          	addi	s2,s6,8
    1208:	4685                	li	a3,1
    120a:	4629                	li	a2,10
    120c:	000b2583          	lw	a1,0(s6)
    1210:	8556                	mv	a0,s5
    1212:	00000097          	auipc	ra,0x0
    1216:	e8e080e7          	jalr	-370(ra) # 10a0 <printint>
    121a:	8b4a                	mv	s6,s2
      state = 0;
    121c:	4981                	li	s3,0
    121e:	b771                	j	11aa <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1220:	008b0913          	addi	s2,s6,8
    1224:	4681                	li	a3,0
    1226:	4629                	li	a2,10
    1228:	000b2583          	lw	a1,0(s6)
    122c:	8556                	mv	a0,s5
    122e:	00000097          	auipc	ra,0x0
    1232:	e72080e7          	jalr	-398(ra) # 10a0 <printint>
    1236:	8b4a                	mv	s6,s2
      state = 0;
    1238:	4981                	li	s3,0
    123a:	bf85                	j	11aa <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    123c:	008b0913          	addi	s2,s6,8
    1240:	4681                	li	a3,0
    1242:	4641                	li	a2,16
    1244:	000b2583          	lw	a1,0(s6)
    1248:	8556                	mv	a0,s5
    124a:	00000097          	auipc	ra,0x0
    124e:	e56080e7          	jalr	-426(ra) # 10a0 <printint>
    1252:	8b4a                	mv	s6,s2
      state = 0;
    1254:	4981                	li	s3,0
    1256:	bf91                	j	11aa <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    1258:	008b0793          	addi	a5,s6,8
    125c:	f8f43423          	sd	a5,-120(s0)
    1260:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    1264:	03000593          	li	a1,48
    1268:	8556                	mv	a0,s5
    126a:	00000097          	auipc	ra,0x0
    126e:	e14080e7          	jalr	-492(ra) # 107e <putc>
  putc(fd, 'x');
    1272:	85ea                	mv	a1,s10
    1274:	8556                	mv	a0,s5
    1276:	00000097          	auipc	ra,0x0
    127a:	e08080e7          	jalr	-504(ra) # 107e <putc>
    127e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1280:	03c9d793          	srli	a5,s3,0x3c
    1284:	97de                	add	a5,a5,s7
    1286:	0007c583          	lbu	a1,0(a5)
    128a:	8556                	mv	a0,s5
    128c:	00000097          	auipc	ra,0x0
    1290:	df2080e7          	jalr	-526(ra) # 107e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1294:	0992                	slli	s3,s3,0x4
    1296:	397d                	addiw	s2,s2,-1
    1298:	fe0914e3          	bnez	s2,1280 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    129c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    12a0:	4981                	li	s3,0
    12a2:	b721                	j	11aa <vprintf+0x60>
        s = va_arg(ap, char*);
    12a4:	008b0993          	addi	s3,s6,8
    12a8:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    12ac:	02090163          	beqz	s2,12ce <vprintf+0x184>
        while(*s != 0){
    12b0:	00094583          	lbu	a1,0(s2)
    12b4:	c9a1                	beqz	a1,1304 <vprintf+0x1ba>
          putc(fd, *s);
    12b6:	8556                	mv	a0,s5
    12b8:	00000097          	auipc	ra,0x0
    12bc:	dc6080e7          	jalr	-570(ra) # 107e <putc>
          s++;
    12c0:	0905                	addi	s2,s2,1
        while(*s != 0){
    12c2:	00094583          	lbu	a1,0(s2)
    12c6:	f9e5                	bnez	a1,12b6 <vprintf+0x16c>
        s = va_arg(ap, char*);
    12c8:	8b4e                	mv	s6,s3
      state = 0;
    12ca:	4981                	li	s3,0
    12cc:	bdf9                	j	11aa <vprintf+0x60>
          s = "(null)";
    12ce:	00000917          	auipc	s2,0x0
    12d2:	37a90913          	addi	s2,s2,890 # 1648 <malloc+0x234>
        while(*s != 0){
    12d6:	02800593          	li	a1,40
    12da:	bff1                	j	12b6 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    12dc:	008b0913          	addi	s2,s6,8
    12e0:	000b4583          	lbu	a1,0(s6)
    12e4:	8556                	mv	a0,s5
    12e6:	00000097          	auipc	ra,0x0
    12ea:	d98080e7          	jalr	-616(ra) # 107e <putc>
    12ee:	8b4a                	mv	s6,s2
      state = 0;
    12f0:	4981                	li	s3,0
    12f2:	bd65                	j	11aa <vprintf+0x60>
        putc(fd, c);
    12f4:	85d2                	mv	a1,s4
    12f6:	8556                	mv	a0,s5
    12f8:	00000097          	auipc	ra,0x0
    12fc:	d86080e7          	jalr	-634(ra) # 107e <putc>
      state = 0;
    1300:	4981                	li	s3,0
    1302:	b565                	j	11aa <vprintf+0x60>
        s = va_arg(ap, char*);
    1304:	8b4e                	mv	s6,s3
      state = 0;
    1306:	4981                	li	s3,0
    1308:	b54d                	j	11aa <vprintf+0x60>
    }
  }
}
    130a:	70e6                	ld	ra,120(sp)
    130c:	7446                	ld	s0,112(sp)
    130e:	74a6                	ld	s1,104(sp)
    1310:	7906                	ld	s2,96(sp)
    1312:	69e6                	ld	s3,88(sp)
    1314:	6a46                	ld	s4,80(sp)
    1316:	6aa6                	ld	s5,72(sp)
    1318:	6b06                	ld	s6,64(sp)
    131a:	7be2                	ld	s7,56(sp)
    131c:	7c42                	ld	s8,48(sp)
    131e:	7ca2                	ld	s9,40(sp)
    1320:	7d02                	ld	s10,32(sp)
    1322:	6de2                	ld	s11,24(sp)
    1324:	6109                	addi	sp,sp,128
    1326:	8082                	ret

0000000000001328 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1328:	715d                	addi	sp,sp,-80
    132a:	ec06                	sd	ra,24(sp)
    132c:	e822                	sd	s0,16(sp)
    132e:	1000                	addi	s0,sp,32
    1330:	e010                	sd	a2,0(s0)
    1332:	e414                	sd	a3,8(s0)
    1334:	e818                	sd	a4,16(s0)
    1336:	ec1c                	sd	a5,24(s0)
    1338:	03043023          	sd	a6,32(s0)
    133c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1340:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1344:	8622                	mv	a2,s0
    1346:	00000097          	auipc	ra,0x0
    134a:	e04080e7          	jalr	-508(ra) # 114a <vprintf>
}
    134e:	60e2                	ld	ra,24(sp)
    1350:	6442                	ld	s0,16(sp)
    1352:	6161                	addi	sp,sp,80
    1354:	8082                	ret

0000000000001356 <printf>:

void
printf(const char *fmt, ...)
{
    1356:	711d                	addi	sp,sp,-96
    1358:	ec06                	sd	ra,24(sp)
    135a:	e822                	sd	s0,16(sp)
    135c:	1000                	addi	s0,sp,32
    135e:	e40c                	sd	a1,8(s0)
    1360:	e810                	sd	a2,16(s0)
    1362:	ec14                	sd	a3,24(s0)
    1364:	f018                	sd	a4,32(s0)
    1366:	f41c                	sd	a5,40(s0)
    1368:	03043823          	sd	a6,48(s0)
    136c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1370:	00840613          	addi	a2,s0,8
    1374:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1378:	85aa                	mv	a1,a0
    137a:	4505                	li	a0,1
    137c:	00000097          	auipc	ra,0x0
    1380:	dce080e7          	jalr	-562(ra) # 114a <vprintf>
}
    1384:	60e2                	ld	ra,24(sp)
    1386:	6442                	ld	s0,16(sp)
    1388:	6125                	addi	sp,sp,96
    138a:	8082                	ret

000000000000138c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    138c:	1141                	addi	sp,sp,-16
    138e:	e422                	sd	s0,8(sp)
    1390:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1392:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1396:	00000797          	auipc	a5,0x0
    139a:	2e27b783          	ld	a5,738(a5) # 1678 <freep>
    139e:	a805                	j	13ce <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    13a0:	4618                	lw	a4,8(a2)
    13a2:	9db9                	addw	a1,a1,a4
    13a4:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    13a8:	6398                	ld	a4,0(a5)
    13aa:	6318                	ld	a4,0(a4)
    13ac:	fee53823          	sd	a4,-16(a0)
    13b0:	a091                	j	13f4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    13b2:	ff852703          	lw	a4,-8(a0)
    13b6:	9e39                	addw	a2,a2,a4
    13b8:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    13ba:	ff053703          	ld	a4,-16(a0)
    13be:	e398                	sd	a4,0(a5)
    13c0:	a099                	j	1406 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    13c2:	6398                	ld	a4,0(a5)
    13c4:	00e7e463          	bltu	a5,a4,13cc <free+0x40>
    13c8:	00e6ea63          	bltu	a3,a4,13dc <free+0x50>
{
    13cc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    13ce:	fed7fae3          	bgeu	a5,a3,13c2 <free+0x36>
    13d2:	6398                	ld	a4,0(a5)
    13d4:	00e6e463          	bltu	a3,a4,13dc <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    13d8:	fee7eae3          	bltu	a5,a4,13cc <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    13dc:	ff852583          	lw	a1,-8(a0)
    13e0:	6390                	ld	a2,0(a5)
    13e2:	02059813          	slli	a6,a1,0x20
    13e6:	01c85713          	srli	a4,a6,0x1c
    13ea:	9736                	add	a4,a4,a3
    13ec:	fae60ae3          	beq	a2,a4,13a0 <free+0x14>
    bp->s.ptr = p->s.ptr;
    13f0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    13f4:	4790                	lw	a2,8(a5)
    13f6:	02061593          	slli	a1,a2,0x20
    13fa:	01c5d713          	srli	a4,a1,0x1c
    13fe:	973e                	add	a4,a4,a5
    1400:	fae689e3          	beq	a3,a4,13b2 <free+0x26>
  } else
    p->s.ptr = bp;
    1404:	e394                	sd	a3,0(a5)
  freep = p;
    1406:	00000717          	auipc	a4,0x0
    140a:	26f73923          	sd	a5,626(a4) # 1678 <freep>
}
    140e:	6422                	ld	s0,8(sp)
    1410:	0141                	addi	sp,sp,16
    1412:	8082                	ret

0000000000001414 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1414:	7139                	addi	sp,sp,-64
    1416:	fc06                	sd	ra,56(sp)
    1418:	f822                	sd	s0,48(sp)
    141a:	f426                	sd	s1,40(sp)
    141c:	f04a                	sd	s2,32(sp)
    141e:	ec4e                	sd	s3,24(sp)
    1420:	e852                	sd	s4,16(sp)
    1422:	e456                	sd	s5,8(sp)
    1424:	e05a                	sd	s6,0(sp)
    1426:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1428:	02051493          	slli	s1,a0,0x20
    142c:	9081                	srli	s1,s1,0x20
    142e:	04bd                	addi	s1,s1,15
    1430:	8091                	srli	s1,s1,0x4
    1432:	0014899b          	addiw	s3,s1,1
    1436:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1438:	00000517          	auipc	a0,0x0
    143c:	24053503          	ld	a0,576(a0) # 1678 <freep>
    1440:	c515                	beqz	a0,146c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1442:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1444:	4798                	lw	a4,8(a5)
    1446:	02977f63          	bgeu	a4,s1,1484 <malloc+0x70>
    144a:	8a4e                	mv	s4,s3
    144c:	0009871b          	sext.w	a4,s3
    1450:	6685                	lui	a3,0x1
    1452:	00d77363          	bgeu	a4,a3,1458 <malloc+0x44>
    1456:	6a05                	lui	s4,0x1
    1458:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    145c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1460:	00000917          	auipc	s2,0x0
    1464:	21890913          	addi	s2,s2,536 # 1678 <freep>
  if(p == (char*)-1)
    1468:	5afd                	li	s5,-1
    146a:	a895                	j	14de <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    146c:	00000797          	auipc	a5,0x0
    1470:	27c78793          	addi	a5,a5,636 # 16e8 <base>
    1474:	00000717          	auipc	a4,0x0
    1478:	20f73223          	sd	a5,516(a4) # 1678 <freep>
    147c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    147e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1482:	b7e1                	j	144a <malloc+0x36>
      if(p->s.size == nunits)
    1484:	02e48c63          	beq	s1,a4,14bc <malloc+0xa8>
        p->s.size -= nunits;
    1488:	4137073b          	subw	a4,a4,s3
    148c:	c798                	sw	a4,8(a5)
        p += p->s.size;
    148e:	02071693          	slli	a3,a4,0x20
    1492:	01c6d713          	srli	a4,a3,0x1c
    1496:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1498:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    149c:	00000717          	auipc	a4,0x0
    14a0:	1ca73e23          	sd	a0,476(a4) # 1678 <freep>
      return (void*)(p + 1);
    14a4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    14a8:	70e2                	ld	ra,56(sp)
    14aa:	7442                	ld	s0,48(sp)
    14ac:	74a2                	ld	s1,40(sp)
    14ae:	7902                	ld	s2,32(sp)
    14b0:	69e2                	ld	s3,24(sp)
    14b2:	6a42                	ld	s4,16(sp)
    14b4:	6aa2                	ld	s5,8(sp)
    14b6:	6b02                	ld	s6,0(sp)
    14b8:	6121                	addi	sp,sp,64
    14ba:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    14bc:	6398                	ld	a4,0(a5)
    14be:	e118                	sd	a4,0(a0)
    14c0:	bff1                	j	149c <malloc+0x88>
  hp->s.size = nu;
    14c2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    14c6:	0541                	addi	a0,a0,16
    14c8:	00000097          	auipc	ra,0x0
    14cc:	ec4080e7          	jalr	-316(ra) # 138c <free>
  return freep;
    14d0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    14d4:	d971                	beqz	a0,14a8 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    14d6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    14d8:	4798                	lw	a4,8(a5)
    14da:	fa9775e3          	bgeu	a4,s1,1484 <malloc+0x70>
    if(p == freep)
    14de:	00093703          	ld	a4,0(s2)
    14e2:	853e                	mv	a0,a5
    14e4:	fef719e3          	bne	a4,a5,14d6 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    14e8:	8552                	mv	a0,s4
    14ea:	00000097          	auipc	ra,0x0
    14ee:	b6c080e7          	jalr	-1172(ra) # 1056 <sbrk>
  if(p == (char*)-1)
    14f2:	fd5518e3          	bne	a0,s5,14c2 <malloc+0xae>
        return 0;
    14f6:	4501                	li	a0,0
    14f8:	bf45                	j	14a8 <malloc+0x94>
