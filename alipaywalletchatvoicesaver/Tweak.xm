/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.

%hook ClassName

// Hooking a class method
+ (id)sharedInstance {
	return %orig;
}

// Hooking an instance method with an argument.
- (void)messageName:(int)argument {
	%log; // Write a message about this call, including its class, name and arguments, to the system log.

	%orig; // Call through to the original function with its original arguments.
	%orig(nil); // Call through to the original function with a custom argument.

	// If you use %orig(), you MUST supply all arguments (except for self and _cmd, the automatically generated ones.)
}

// Hooking an instance method with no arguments.
- (id)noArguments {
	%log;
	id awesome = %orig;
	[awesome doSomethingElse];

	return awesome;
}

// Always make sure you clean up after yourself; Not doing so could have grave consequences!
%end
*/


#import <substrate.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>


/*
// these
int fake_ptrace(int request, pid_t pid, caddr_t addr, int data){
	return 0;
}

void *(*old_dlsym)(void *handle, const char *symbol);

void *my_dlsym(void *handle, const char *symbol){
	if(strcmp(symbol,"ptrace") == 0){
		return (void*)fake_ptrace;
	}

	return old_dlsym(handle,symbol);
}

%ctor{
	MSHookFunction((void*)dlsym,(void*)my_dlsym,(void**)&old_dlsym);
}
*/

// or these
static int (*oldptrace)(int request, pid_t pid, caddr_t addr, int data);
static int newptrace(int request, pid_t pid, caddr_t addr, int data){
	return 0; // just return zero
/*
	// or return oldptrace with request -1
	if (request == 31) {
		request = -1;
	}
	return oldptrace(request,pid,addr,data);
*/
}


%ctor {
	MSHookFunction((void *)MSFindSymbol(NULL,"_ptrace"), (void *)newptrace, (void **)&oldptrace);
}




