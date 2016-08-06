#include "stdlib.h"
#include "stdio.h"

void move_a_to_b() {
	int a = 10, b;
	asm("movl %1, %%eax\n\t"
	    "movl %%eax, %0\n"
	    :"=r"(b)	/* output */
	    :"r"(a)	/* input */
	    :"%eax"	/* clobbered register */
	   );
	printf("b = %d\n", b);
}

void add_a_and_b(int a, int b) {
	int res = 0;
	__asm__("movl %1, %0\n\t"
		"addl %2, %0\n"
		:"=r"(res)
		:"r"(a),"r"(b));
	printf("a + b = %d\n", res);
}

int five_times(int x) {
	int res;
	asm("lea (%0, %0, 4), %0"
	    :"=r"(res)
	    :"0"(x)
	   );
	return res;
}

static inline char* strcpy(const char* src, char* dest) {
	__asm__("1:\tlodsb\n\t"
		"stosb\n\t"
		"testb %%al, %%al\n\t"
		"jne 1b"
		:"=&D"(dest)
		:"S"(src), "0"(dest)
		:"memory", "%eax"
	       );
	return dest;
}

void my_exit(int code) {
	__asm__("movl $1, %%eax\n\t"
		"int $0x80"
		: /* no output */
		:"b"(code)
		:"%eax"
	       );
}

int main(int argc, char** argv) {
	printf("move a=10 to b\n");
	move_a_to_b();
	printf("add a=10, b=20\n");
	add_a_and_b(10, 20);
	printf("five_times(3) = %d\n", five_times(3));
	char src[] = "Hello, world\n";
	char dest[20];
	char *res = 0;
	res = strcpy(src, dest);
	printf("copied dest: %s\n", dest);
	my_exit(1);
}
