#
# syscal on 64-bits Linux
#
	.global _start

	.text
_start:
	mov $1, %rax		# syscall 1 = write
	mov $1, %rdi		# to stdout
	mov $msg, %rsi		# message base address
	mov $len, %rdx		# message length
	syscall

exit:
	mov $60, %rax		# syscall 60 = exit
	xor %rdi, %rdi		# return code 0
	syscall

msg:	.ascii "Hello, world!\n"
	len = . - msg
