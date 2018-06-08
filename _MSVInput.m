</
define p:threadNum=1;
define q:threadNum=2;
next(next((next(p and empty);next(q and empty))#))
/>
frame(turn,manager,childHandle1,childHandle2,fp,fp1,i,threadNum) and
(	
	function MyAwait(int waitValue)
	{
		await(turn=waitValue)
	};
	function NewChildThread1()
	{
		while(true)
		{
			fprintf(fp1, "a") and threadNum<==1 and skip;
			turn <== 1 and skip;
			extern MyAwait(0) and skip			
		}
	};
	function NewChildThread2()
	{
		while(true)
		{
			fprintf(fp1, "b") and threadNum<==2 and skip;
			turn <== 1 and skip;
			extern MyAwait(0) and skip
		}
	};
	function MyManagerThread(void* para, unsigned int RValue)
	{
		fp <== fopen("1.txt", "w+") and fp1 <== fopen("result.txt", "w+") and skip;
		while(true)
		{
			turn<==0 and ResumeThread(childHandle1) and extern MyAwait(1) and empty;
			SuspendThread(childHandle1) and skip;
			
			turn<==0 and ResumeThread(childHandle2) and extern MyAwait(1) and empty;
			SuspendThread(childHandle2) and i:=i+1
		};
		fclose(fp) and fclose(fp1) and RValue<==1 and skip
	};
	function ChildThread1(void* para, unsigned int RValue)
	{
		extern NewChildThread1() and skip
	};
	function ChildThread2(void* para, unsigned int RValue)
	{
		extern NewChildThread2() and skip
	};
	int turn and FILE *fp,*fp1 and int threadNum<==0 and int i<==0 and
	HANDLE manager <== (HANDLE)_beginthreadex(NULL, 0, MyManagerThread, NULL, 4, NULL) and 
	HANDLE childHandle1 <== (HANDLE)_beginthreadex(NULL, 0, ChildThread1, NULL, 4, NULL) and
	HANDLE childHandle2 <== (HANDLE)_beginthreadex(NULL, 0, ChildThread2, NULL, 4, NULL) and skip;
	ResumeThread(manager) and skip;
	WaitForSingleObject(manager, 2147483647) and skip
)



