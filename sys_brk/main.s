#
# Allocate 16K memory using sys_brk()
#

.text
	.global _start
_start:
	mov $45, %eax		# sys_brk system call
	xor %ebx, %ebx		# to get the current highest address
	int $0x80

	add $0x08, %eax		# calculate the desired highest address
	mov %eax, %ebx		# 0x08 bytes to reserved
	mov $45, %eax
	int $0x80

	cmp $0, %eax		# if res = -1
	mov $-1, %ebx		# exit with -1
	jl exit			# allocate failed, exit
	mov %eax, %edi		# EDI = highest available address
	mov $8, %ecx		# total 8 byte
	mov $'a', %eax		# init using 'a'
	std			# backward
	rep stosb		# 
	cld 

	mov $4, %eax		# sys_write
	mov $1, %ebx		# to stdout
	mov $msg, %ecx		# message base address
	mov $len, %edx		# message length
	int $0x80

	mov $4, %eax		# sys_write
	mov $1, %ebx		# to stdout
	add $1, %edi
	mov %edi, %ecx		# output the allocated memory
	mov $8, %edx		# total 8 byte
	int $0x80

	mov $0, %ebx		# exit with 0
exit:
	mov $1, %eax		# sys_exit = 1
	int $0x80

.data
msg: 	.ascii "Allocated success.\n",
	len = . - msg

addr:	.word 0
	.word 0
