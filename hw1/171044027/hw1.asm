# Ahmet Hilmi Berber #
#     171044027      #
#    CSE331 HW01     #

.data
	setArr:			.space 80
	subsetArr:		.space 800
	subsetSizes:		.space 40
	intersectionArr:	.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	bufferSet: 		.space 80
	bufferSubset: 		.space 800
	dot:			.asciiz "."
	exclamationMark:	.asciiz "!"
	NULL:			.asciiz "N"
	comma:			.asciiz ","
	false:			.asciiz "-"
	set_file: 		.asciiz "./set.txt"
	subset_file:		.asciiz "./subset.txt"
.text
	main:
		j initSet		
	
	initSet:
		li   	$v0, 13       # system call for open file
		la   	$a0, set_file # set file name
		li   	$a1, 0        # open file for reading
		li 	$a2, 0
		syscall             
		move 	$s0, $v0       
		
		li  	$v0, 14       # system call for reading from file
		move 	$a0, $s0      # file descriptor 
		la      $a1, bufferSet# address of buffer to which to read
		li   	$a2, 80       # hardcoded buffer length
		syscall             
		
		la $s4, setArr #temporary setArr adress for determining (later) the size of the setArr
		la $s1, setArr #array adress	
		li $t3, 0 #array counter
		li $t4, 0 #buffer counter
		lb $t5, comma
		lb $t6, dot
		
	LoopSet:
		la $t1, bufferSet($t4)	#taking adress of the $t4 th index element
		lb $a0, ($t1)		#taking the value of the given adress
		beq $a0, $t6, closeSet	
		beq $a0, $t5, incrementBufferCounter#if comma, then increment buffer
		bne $a0, $t5, CommaSet#if not comma, then write the value in the setArr
		
	CommaSet:
		la $t1, bufferSet($t4)
		lb $a0, ($t1)	
		sw $a0, ($s1)
		############ printing setArr
		li $v0, 11
		add $a0, $zero, $a0
		syscall
		li $v0, 11
		add $a0, $zero, ','
		syscall
		###########
		addi $s1, $s1, 4 
		jal incrementBufferCounter
		j LoopSet
		
	closeSet:	
		li $v0, 16       
		move $a0, $s0      #closing setArr file
		syscall       
		j initSubset  
		
	initSubset:
		li   	$v0, 13       # system call for open file
		la   	$a0, subset_file     # input file name
		li   	$a1, 0        # Open for reading
		li 	$a2, 0
		syscall            # open a file 
		move 	$s0, $v0      # save the file descriptor 
		
		li  	$v0, 14       # system call for reading from file
		move 	$a0, $s0      # file descriptor 
		la      $a1, bufferSubset   # address of buffer to which to read
		li   	$a2, 800     # hardcoded buffer length
		syscall            # read from file
		
		la $s2, subsetArr # array adress	
		la $s3, subsetSizes # array that taking sizes of the subsets
		li $t2, 0 # variable that taking the size of the subset
		li $t3, 0 # array counter
		li $t4, 0 # buffer counter
		lb $t5, comma
		lb $t6, dot
		lb $t7, false
		li $t8, 0
		
	LoopSubset:
		la $t1, bufferSubset($t4)	
		lb $a0, ($t1)	
		beq $a0, $t7, closeSubset# end of the subsets
		beq $a0, $t6, PutDot# if dot, this means the beginning of the subset
		beq $a0, $t5, incrementBufferCounter # if comma, increment the buffer
		bne $a0, $t5, CommaSubset# if not comma, then write the value in subsetArr
		
	closeSubset:	
		jal storeSubSizes
		li $v0, 16       
		move $a0, $s0      #close subsetArr file
		syscall      
		
		sub $s5, $s1, $s4
		addi $t1, $zero, 4
		div $s0, $s5, $t1
		mflo $s5 # the size of the setArr stored in $s5
		
		#######################################################################
		# we are taking intersections of array and substracting the intersected
		# subset from the setArr till the setArr completely empty 
		#######################################################################
		
	outer_loop_start:
		lb $t8, dot
		la $s1, setArr 
		
		# loop 1 beginning #		
		li $t0, 0          # loop 1 counter
  		move $t1, $s5      # loop 1 end condition variable ($t1)
  		
	start_loop_1:  
 		beq $t0, $t1, end_loop_1  #loop 1 exit condition
		la $s4, intersectionArr #intersectionArr
		la $s3, subsetSizes #take the subset size array's adress of each set array element loop
		la $s2, subsetArr 
		# loop 2 beginning #
  		li $t9, 0         # loop 2 counter
  				  # loop 2 end condition variable is $t2	
  		lw $s0, 0($s1)#take the first element of the set array for the comparison with all the subarray elements		  
		lb $s7, NULL #if there is a "N" in the setArr, skip that because this value has comparised before
		beq $s0, $s7, end_loop_2
		
	start_loop_2:  
  		beq $t9, $t2, end_loop_2  #loop 2 exit condition     				
  		# loop 3 beginning #
  		li $t4, 0	# loop 3 counter  
  		lw $t5, 0($s3)	# loop 3 end condition variable ($t5)   
  		lb $t3, 0($s2)# taking the first element of the subsetArr for the dot or unlem comparison  		
		bne $t3, $t8, nottake #if there is a exclamationMark, then we already compared the arrays so we don't need that 	
		beq $t3, $t8, take #if there is a dot at the beginning of the subarr, this means we'll compare the intersection of the arrays.
				   #jump the next index 
		
  	start_loop_3:
  		beq $t4, $t5, end_loop_3 #loop 3 exit condition 		
  		# $s2 den yani sub arrayden element alacagiz. set arrayin ilk elementi zaten $a2 de
  		lb $s6, 0($s2) #taking element from subarray  		
  		beq $s6, $s0, intersect   #comparing setarr with subsetarr elements
		addi $s2, $s2, 4    # Incrementing subsetArr index
  		addi $t4, $t4, 1    # Incrementing loop 3 counter
  		j start_loop_3
  		
  	end_loop_3:
  		# loop 3 ending #
  		addi $s4, $s4, 4    # Incrementing intersection array index
  		addi $s3, $s3, 4    # Increment subset size array index
  		addi $t9, $t9, 1    # Incrementing loop 2 counter
  		j start_loop_2  
  		
	end_loop_2:  
		# loop 2 ending #
  		addi $s1, $s1, 4    # Incrementing setArr index
  		addi $t0, $t0, 1    # Increment loop 1 counter  
  		j start_loop_1  
  		
	end_loop_1:  
		# loop 1 ending #
		#we found the intersection elements between setArr and subsetArr, now we have to find the biggest element in
		#the intersectionArr 
		###############################################
		#finding the max element in the intersectionArr 
		###############################################
		move $t3, $t2 #intersectionArr size
		la $t1, intersectionArr #intersectionArr adress
		lw $s6, ($t1)       # set max, $s5 to array[0]
		add $t1, $t1, 4    # skip the first element
		add $t3, $t3, -1       # decrease the array size
		
	loopMax1:
		lw $t4, ($t1) # get n of array[n]
		ble $t4,$s6,loopMax2 #if t4 is not less than t5 we got a new max
		move $s6,$t4 # get element in array  
		sw $s6,0($t1) # max value

	loopMax2:
		add $t3, $t3, -1             # counter-1
		addi $t1, $t1, 4 	     # increment index
		bnez $t3, loopMax1 	     # if not 0 then go on and loop
		
		# $s6 is the maximum value of the intersectionArr 
		la $t5, intersectionArr
		addi $t1, $t1, -4
		sub $t0, $t1, $t5 
		div $t0, $t0, 4
		# t0 is the index of the maximum value of the intersectionArr
		#########################################################
		# now we have to search the t0'th subset of the subsetArr
		#########################################################
		li $t1, 0 #subsetArr finding counter
		la $t3, subsetArr
		lb $t4, dot
		
	whileSearchSubset:	
  		lw $t5, 0($t3) #taking element from subarray  	
		beq $t5, $t4, incrementDot
		addi $t3, $t3, 4
		j whileSearchSubset

	incrementDot:
		addi $t1, $t1, 1
		beq $t1, $t0, exitWhile
		addi $t3, $t3, 4
		j whileSearchSubset
		
	exitWhile:
		# after that while loop, the adres of the target subset array storing in the $t3 variable 
		# now we have to change the dot to the exclamation mark
		lb $t0, exclamationMark
		sw $t0, 0($t3)
		# now we have to subtract that subarray from the setarray
		# remember that the max value of the intersection is stored in the $s6
		addi $t3, $t3, 4	
		#the size of the setArr stored in $s5
		###############################################
		# substracting the subsetArr from setArr part #
		###############################################
		# loop 1 beginning #		
		li $t0, 0          # loop 1 counter
  		move $t1, $s6      # loop 1 end condition variable ($t1)
  		
	Start_loop_1:  
 		beq $t0, $t1, End_loop_1  #loop 1 exit condition
		lw $t4, 0($t3) #storing the subsetarray value in $t4
		la $s0, setArr
		# loop 2 beginning #		
		li $t5, 0
		move $t6, $s5
		
	Start_loop_2:  
  		beq $t5, $t6, End_loop_2  #loop 2 exit condition     				
  		lw $t7, 0($s0) #storing the setarray value in $t2
  		beq $t7, $t4, eliminateValue
  		
  		addi $t5, $t5, 1    # Incrementing loop 2 counter
  		addi $s0, $s0, 4    # Incrementing setArr index
  		j Start_loop_2  
  		
	End_loop_2:  
		# loop 2 ending #
		addi $t3, $t3, 4    # Incrementing subsetArr index
  		addi $t0, $t0, 1    # Increment loop 1 counter  
  		j Start_loop_1  
		
	eliminateValue:
		lb $t9, NULL
		sw $t9, 0($s0)
  		addi $t5, $t5, 1    # Incrementing loop 2 counter
  		addi $s0, $s0, 4    # Incrementing setArr index
  		j Start_loop_2  
		
	End_loop_1:  
		# loop 1 ending #
	# deleting completed 
	# deleting means put the 'N' inside the destroyed value #
	##########################
	# reseting intersectionArr	
	##########################	
		li $t0, 0
		li $t1, 20
		la $t3, intersectionArr
		jal resetIntersectionArr
		
	outer_loop_end:
		li $v0, 11
		add $a0, $zero, '\n' # printing newline after the setArr printed
		syscall 
		li $t0, 0 # loop counter
		move $t1, $s5 # the size of the setArr storing in the $s5
		la $t3, setArr
		jal checkSetarrEmpty #checking if all the elements in setArr is deleted. if not, then we
		# have to take another subsetArr
	 
	computeSubsets:
		la $t0, subsetSizes
		li $t1, 0 # counter the size
		li $t4, 0 # counter of the loop
		li $t7, 0
		move $t3, $t2 # the size of the subsetSizesArr
		
	CalculateSizeSubsetArr:
		bge $t4, $t3, exitCalculateSizeSubsetArr
		lw $t5, ($t0)
		addu $t1, $t1, $t5
		addi $t0, $t0, 4
		addi $t4, $t4, 1
		j CalculateSizeSubsetArr
		
	exitCalculateSizeSubsetArr:
		addu $t1, $t1, $t3 #t1 is the total size of the subsetArr
		addi $t1, $t1, 1
		li $t0, 0 # counter of the loop
		la $t3, subsetArr
		lb $t6, exclamationMark
		lb $t8, dot
		jal checkReturnValue
	
	TERMINATE: 		
		li $v0, 10			
		syscall  
		########## ENDING PROGRAM ###########
			
	checkReturnValue:
		addi $t0, $t0, 1
		beq $t0, $t1, TERMINATE	# exit condition 
		lw $t5, 0($t3)
		beq $t5, $t6, printSubset #comparing the subsetArrr element with the exclamationMark
		addi $t3, $t3, 4
		j checkReturnValue
		
	printSubset:
		addi $t0, $t0, 1
		addi $t3, $t3, 4 #incrementing subsetArr index (after the exclamationMark)
		lw $t7, 0($t3)
		beq $t7, $t6, printNewline
		beq $t7, $t8, printNewline 
		li $v0, 11
		add $a0, $zero, $t7 # printing subsetArr element
		syscall
		li $v0, 11
		add $a0, $zero, ',' # printing comma
		syscall
		beq $t0, $t1, TERMINATE	# exit condition 
		j printSubset
		
	printNewline:
		li $v0, 11
		add $a0, $zero, '\n'
		syscall	
		j checkReturnValue 
	
	checkSetarrEmpty:
		beq $t0, $t1, computeSubsets
		lw $t5, 0($t3)
		lb $t6, NULL
		bne $t5, $t6, outer_loop_start #if there is not "N" char in the setArr, this means there is still
					       # numbers in the array
		addi $t3, $t3, 4 #incrementing setArr index
		addi $t0, $t0, 1 #incrementing loop counter
		j checkSetarrEmpty		
		
	resetIntersectionArr:
		beq $t0, $t1, outer_loop_end # oop condition $t1 = 20
		li $t5, 0 
		lw $t5, ($t3) #filling intersectionArr with 0.
		addi $t3, $t3, 4 #incrementing intersectionArr index
		addi $t0, $t0, 1 #incrementing loop counter
		j resetIntersectionArr
		
	nottake:
		add $s2, $s2, $t5
		j start_loop_2
				
	take:
		addi $s2, $s2, 4
		j start_loop_3
		 
	intersect:  						
  		lw $s7, 0($s4) # take the intersection count from the intersectionArr
  		addi $s7, $s7, 1 # increment the intersection count
		sw $s7, 0($s4)	# store that value at the intersecionArr
		addi $s2, $s2, 4    # Incrementing subsetArr index
  		addi $t4, $t4, 1    # Incrementing loop 3 counter
  		j start_loop_3
	
	PutDot:				
		bne $t8, $zero, storeSubSizes	
		sw $t6, ($s2)		
		addi $s2, $s2, 4
		jal incrementBufferCounter
		jal incrementSubsetSize
		j LoopSubset
		
	storeSubSizes:
		sw $t8, ($s3)	
		addi $s3, $s3, 4
		li $t8, 0
		jr $ra
		
	incrementBufferCounter:			
		add $t4, $t4, 1
		jr $ra
		
	incrementSubsetSize:
		add $t2, $t2, 1
		jr $ra

	CommaSubset:
		addi $t8, $t8, 1
		la $t1, bufferSubset($t4)
		lb $a0, ($t1)	
		sw $a0, ($s2)
		addi $s2, $s2, 4 
		jal incrementBufferCounter
		j LoopSubset
		
		
	
