</
define p:threadNum=1;
define q:threadNum=2;
next(next((next(p and empty);next(q and empty))#))
/> 
//上面部分为PPTL描述的周期重复的性质，表示从第四个状态开始，两个原子命题p和q交替成立。下面为待验证的MSVL程序
frame(turn,manager,childHandle1,childHandle2,fp1,i,threadNum) and
(	
	function MyAwait(int waitValue) 
	{
		await(turn=waitValue) //一直等待，直到全局变量turn等于参数waitValue的值
	};
	function NewChildThread1() //子线程1
	{
		while(true)
		{
			fprintf(fp1, "a") and threadNum<==1 and skip; //向文件中输入字符"a"，并将变量threadNum置为1
			turn <== 1 and skip; //将共享变量turn置为1
			extern MyAwait(0) and skip	//一直等待，直到turn为0
		}
	};
	function NewChildThread2() //子线程2
	{
		while(true)
		{
			fprintf(fp1, "b") and threadNum<==2 and skip; //向文件中输入字符"b"，并将变量threadNum置为2
			turn <== 1 and skip; //将共享变量turn置为1
			extern MyAwait(0) and skip //一直等待，直到turn为0
		}
	};
	function MyManagerThread(void* para, unsigned int RValue) //管理线程
	{
		fp1 <== fopen("result.txt", "w+") and skip; //打开输入字符的文件
		while(true)
		{
			turn<==0 and ResumeThread(childHandle1) and extern MyAwait(1) and empty; //将共享变量turn置为0，恢复子线程1，并一直等待，直到turn为1
			SuspendThread(childHandle1) and skip;//将子线程1恢复
			
			turn<==0 and ResumeThread(childHandle2) and extern MyAwait(1) and empty;//将共享变量turn置为0，恢复子线程2，并一直等待，直到turn为1
			SuspendThread(childHandle2) and i:=i+1 //将子线程2恢复，将表示循环次数的变量i加1
		};
		fclose(fp1) and RValue<==1 and skip //关闭打开的文件，并返回
	};
	function ChildThread1(void* para, unsigned int RValue)//调用子线程1
	{
		extern NewChildThread1() and skip
	};
	function ChildThread2(void* para, unsigned int RValue)//调用子线程2
	{
		extern NewChildThread2() and skip
	};
	int turn and FILE *fp1 and int threadNum<==0 and int i<==0 and 
	HANDLE manager <== (HANDLE)_beginthreadex(NULL, 0, MyManagerThread, NULL, 4, NULL) and 
	HANDLE childHandle1 <== (HANDLE)_beginthreadex(NULL, 0, ChildThread1, NULL, 4, NULL) and
	HANDLE childHandle2 <== (HANDLE)_beginthreadex(NULL, 0, ChildThread2, NULL, 4, NULL) and skip; //创建管理线程和两个子线程，初始状态都为阻塞
	ResumeThread(manager) and skip; //管理线程开始执行
	WaitForSingleObject(manager, 2147483647) and skip //等待管理线程执行结束
)



