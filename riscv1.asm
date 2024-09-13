.data







.text

	li t0,10
	li t1,20
	li t2 ,30
	li t3,40

Grupo_imm:

	ori t0,t1,10
	andi t0,t1,-100
	xori t0,t1,100
	
Grupo_Comp:
	slti t0,t1,20
	sltu t0,t1,t2
	sltiu t0,t1,100
Grupo_shift:
	sll t0,t1,t2
	srl t0,t1,t2
	sra t0,t1,t2
Grupo_shift_immediato:
	slli t0,t1,10
	srli t0,t1,30
	srai t0,t2,10
Grupo_branch:
	addi t1,t1,10
	bge t1,t3,Grupo_branch
	bgeu t1,t3,Grupo_branch
Menor:
	addi t1,t1,-10
	blt t1,t3 ,Menor
	li t1,-10
	li t3,-30
Menor_que:
	addi t1,t1,-10
	bltu t1,t3,Menor_que


	
