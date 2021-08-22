.macro assign_constant (%destination, %constant)
li %destination, %constant
.end_macro

.macro set_syscall (%syscall_number)
assign_constant($v0, %syscall_number)
.end_macro

#assigns value stored in second arg into destination
.macro assign (%destination, %value_address)
add %destination, %value_address, $zero
.end_macro 

#end the program
.macro exit(%exit_status)
li $a0, %exit_status
set_syscall(17)
syscall #execute halt
.end_macro

#exit without status. 0 by default
.macro exit
exit (0) #exit with status 'successfull'
.end_macro

.macro print_a0
set_syscall(4) #sets syscall instruction to printing string value of a0
syscall #prints the value of a0
.end_macro

#print string with gpr address
.macro print(%string_gpr)
la $a0, (%string_gpr)
print_a0
.end_macro 

.macro print_name
print($t1)
.end_macro

#print string stored in data reference
.macro print_variable (%string_reference)
la $a0, %string_reference #loads the string stored in reference to a0
print_a0
.end_macro 

.macro print_int (%int_address)
set_syscall(1) #sets syscall to print int from a0
assign($a0, %int_address) 
syscall
.end_macro 

.macro print_attempts
print_int($t4)
.end_macro

.macro input_string (%string_reference, %destination)
print_variable(%string_reference)
set_syscall(8)
assign_constant($a1, 15)
syscall
la %destination, ($a0)
.end_macro

.macro input_int (%string_reference, %destination)
print_variable(%string_reference)
set_syscall(5) #sets syscall operation to reading integer input
syscall #executes syscall operation, first input is now stored in v0
assign(%destination, $v0) #stores input (x) in %destination 
.end_macro

.macro greet
print_variable(greeting)
print_name
.end_macro

.macro endscreen
print_variable(end1)
print_name
print_variable(end2)
print_attempts
print_variable(end3)
.end_macro

.macro transform_number
addi $t5, $t2, 69
mul $t2, $t2, $t5
addi $t2, $t2, 420 
.end_macro

# t1 - name
# t2 - main number
# t3 - attempted number
# t4 - attempt counter
.text 
main:
print_variable(intro)
input_string(enter_name, $t1)
greet
input_int(ask_for_number, $t2)
transform_number
print_variable(explain)

assign_constant($t4, 0)
loop:
    input_int(next_number, $t3)
    addiu $t4, $t4, 1 #increment attempt count
    sub $t3, $t3, $t2 #t3 = t3 - t2
    beq $t3,$0, endloop #break loop if difference is 0
    bgez $t3, greater #if difference > 0, jump
    print_variable(low)
    j loop
	greater:
    	print_variable(high)
    	j loop
endloop:

endscreen
exit

.data
intro: .asciiz "Wellcome to Guessing Game!\n" 
enter_name: .asciiz "Please, enter your name:\n"
greeting: .asciiz "Hello, "
ask_for_number: .asciiz "Since I have limited powers, I will need your help to generate a (pseudo)random number. Tell me a number in range [100-200] and I will transform it to play with:\n"
explain: .asciiz "Now you need to guess it.\n"
next_number: .asciiz "Input number:\n"
high: .asciiz "Too high...\n"
low: .asciiz "Too low...\n"
end1: .asciiz "Congratulations, "
end2: .asciiz "You won with "
end3: .asciiz " attempts!"
