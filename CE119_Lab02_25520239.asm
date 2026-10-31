##############################################################################################################
################################################### TN3 ######################################################
##############################################################################################################
.data
   	# test_str: .asciiz "(a+b)*[c-{d/e}]"
    	# test_str: .asciiz "f(x[i]{j}))"
    	# test_str: .asciiz "{[(])}"
    	# test_str: .asciiz "((a)"
    	# test_str: .asciiz ""
    	# test_str: .asciiz "no brackets here"
    	# test_str: .asciiz "]"
    	# test_str: .asciiz "([)]"
    	test_str: .asciiz "([{([{([{([{}])}])}])}])"

    	msg_str:    .asciiz "Chuoi kiem tra: "
    	msg_v0:     .asciiz "\n$v0 =  "
    	msg_v1:     .asciiz "\n$v1 = "
    	msg_nl:     .asciiz "\n"
 
.text

main:
    	# In chuoi ra
    	li      $v0, 4
    	la      $a0, msg_str
    	syscall
    	la      $a0, test_str
    	syscall
	
	# Goi thu tuc check_brackets
    	la      $a0, test_str       
    	jal     check_brackets      

    	# Luu ket qua
    	move    $s0, $v0
    	move    $s1, $v1

    	# In ket qua $v0
    	li      $v0, 4
    	la      $a0, msg_v0
    	syscall
    	li      $v0, 1
    	move    $a0, $s0
    	syscall

    	# In ket qua $v1
    	li      $v0, 4
    	la      $a0, msg_v1
    	syscall
    	li      $v0, 1
    	move    $a0, $s1
    	syscall


    	li      $v0, 10
    	syscall
    	
# ===================================================================
# THU TUC: check_brackets
# Muc dich:   Kiem tra tinh hop le cua cac cap ngoac (), [], {}
# Tham so:    $a0 = Dia chi con tro chuoi ky tu ket thuc bang '\0' (.asciiz)
# Tra ve:     $v0 = Vi tri ky tu bi loi (dem tu 1) / 0 neu chuoi hop le / N+1 neu thieu ngoac dong
#             $v1 = Ma loi:
#                   0: Chuoi hop le
#                   1: Ngoac dong khong cung loai voi ngoac mo o dinh ngan xep
#                   2: Gap ngoac dong khi ngan xep rong
#                   3: Het chuoi nhung ngan xep van con ngoac mo
# Thanh ghi su dung:
#             $a0 : Con tro duyet chuoi (tang 1 byte sau moi ky tu)
#             $v0 : Luu vi tri loi / ket qua tra ve
#             $v1 : Luu ma loi tra ve (0, 1, 2, 3)
#             $t0 : Dem vi tri ky tu hien tai trong chuoi (bat dau tu 1)
#             $t1 : Ky tu ASCII vua doc tu chuoi
#             $t2 : Ma ASCII cac ngoac dung de so sanh
#             $t3 : Ky tu ngoac mo pop tu dinh ngan xep ra de doi chieu
#             $t4 : Ma ASCII ngoac mo ky vong de kiem tra khop cap
#             $t9 : Luu gia tri goc cua $sp ban dau (kiem tra rong va khoi phuc $sp)
#             $sp : Con tro ngan xep (giam/tang 4 byte, ghi de 0 khi pop)
# Quy uc:     Chi su dung thanh ghi tam $t0-$t4, $t9 va thanh ghi tra ve $v0-$v1.
#             Khoi phuc $sp ve $t9 tren moi duong thoat.
# ===================================================================

check_brackets:
	move $t9, $sp
	li $t0, 1

cb_loop:
	lbu $t1, 0($a0)
	beq $t1, $zero, cb_end
	
	#check ngoac mo
	li $t2, 40             
    	beq $t1, $t2, cb_push
    	li $t2, 91             
    	beq $t1, $t2, cb_push
    	li $t2, 123            
    	beq $t1, $t2, cb_push
	
	#check ngoac dong
	li $t2, 41             
   	beq $t1, $t2, cb_check_close
    	li $t2, 93             
    	beq $t1, $t2, cb_check_close
    	li $t2, 125            
    	beq $t1, $t2, cb_check_close
	
	j cb_next

cb_push:
	addi $sp, $sp, -4
	sw $t1, 0($sp)
	j cb_next

cb_check_close:
	beq $sp, $t9, cb_err2
	
	lw $t3, 0($sp)
	sw $zero, 0($sp)
	addi $sp, $sp, 4
	li $t2, 41             
   	beq $t1, $t2, match_round
    	li $t2, 93            
    	beq $t1, $t2, match_square
    	li $t2, 125          
    	beq $t1, $t2, match_curly
    	
match_round:
    	li $t4, 40             
    	bne $t3, $t4, cb_err1   
    	j cb_next

match_square:
    	li $t4, 91             
    	bne $t3, $t4, cb_err1   
    	j cb_next

match_curly:
    	li $t4, 123            
    	bne $t3, $t4, cb_err1   
    	j cb_next
  
cb_next:
	addi $a0, $a0, 1
	addi $t0, $t0, 1
	j cb_loop

cb_end:
	bne $sp, $t9, cb_err3
	
	li $v0, 0
	li $v1, 0
	j cb_exit
	
cb_err1:
	move $v0, $t0
	li $v1, 1
	j cb_exit
	
cb_err2:
	move $v0, $t0
	li $v1, 2
	j cb_exit

cb_err3:
	move $v0, $t0
	li $v1, 3
	j cb_exit

cb_exit:
	move $sp, $t9
	jr $ra


##############################################################################################################
################################################## TN2 #######################################################
##############################################################################################################
.data
	scores:		.word 4 1 6 7 0 3 5 0 4 7 2 1
	grade_tab:	.byte 0 0 0 0 1 1 1 2 2 3 3	
	hist: 		.word 0 0 0 0
	n_scores: 	.word 12

	str_min:	.asciiz "min="
	str_max:	.asciiz " max="
	str_g0:		.asciiz "g0="		
	str_g1:		.asciiz " g1="	
	str_g2:		.asciiz " g2="
	str_g3:		.asciiz " g3="
	str_nl:		.asciiz "\n"

.text

main:
# Goi stats va in ket qua
	la $a0, scores
	lw $a1, n_scores
	jal stats
	
	move $s0, $v0
	move $s1, $v1
	
	li $v0, 4
	la $a0, str_min
	syscall
	li $v0, 1
	move $a0, $s0
	syscall
	
	li $v0, 4
	la $a0, str_max
	syscall
	li $v0, 1
	move $a0, $s1
	syscall
	
	li $v0, 4
	la $a0, str_nl
	syscall
	
#Goi histogram va in ket qua
	la $a0, scores
	lw $a1, n_scores
	la $a2, grade_tab
	la $a3, hist
	jal histogram
	
	la $t0, hist
	
	li $v0, 4
	la $a0, str_g0
	syscall
	lw $a0, 0($t0)
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, str_g1
	syscall
	lw $a0, 4($t0)
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, str_g2
	syscall
	lw $a0, 8($t0)
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, str_g3
	syscall
	lw $a0, 12($t0)
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, str_nl
	syscall
	
	li $v0, 10
	syscall

# ===================================================================
# THU TUC: stats
# Muc dich:   Duyet mang diem sinh vien de tim gia tri Min va Max
# Tham so:    $a0 = Dia chi goc cua mang diem (.word)
#             $a1 = So luong sinh vien N (N > 0)
# Tra ve:     $v0 = Gia tri Min
#             $v1 = Gia tri Max
# Thanh ghi su dung:
#             $a0 : Con tro duyet mang diem (tang 4 byte sau moi vong)
#             $a1 : Bien dem lui so phan tu con lai (giam dan ve 0)
#             $v0 : Luu gia tri Min trong qua trinh duyet
#             $v1 : Luu gia tri Max trong qua trinh duyet
#             $t0 : Luu gia tri diem vua doc tu mang (scores[i])
# Quy uc:     Chi su dung thanh ghi tam $t0, thanh ghi tham so $a0-$a1 va thanh ghi tra ve $v0-$v1.
# ===================================================================

stats: 
	lw $v0, 0($a0)
	move $v1, $v0
	addi $a0, $a0, 4
	addi $a1, $a1, -1
	
stats_loop:
	beq $a1, $zero, stats_done
	
	lw $t0, 0($a0)
	
	bge $t0, $v0, stats_check_max
	move $v0, $t0

stats_check_max:
	ble $t0, $v1, stats_next
	move $v1, $t0

stats_next:
	addi $a0, $a0, 4
	addi $a1, $a1, -1
	j stats_loop
	
stats_done:
	jr $ra
	
# ===================================================================
# THU TUC: histogram
# Muc dich:   Duyet mang diem, tra cuu phan nhom
#             va cap nhat so luong sinh vien tuong ung vao mang hist.
# Tham so:    $a0 = Dia chi goc mang diem (.word)
#             $a1 = So luong sinh vien N (dem lui ve 0)
#             $a2 = Dia chi goc mang grade_tab (.byte)
#             $a3 = Dia chi goc mang hist (.word)
# Tra ve:     Khong co. Cap nhat truc tiep ket qua vao mang hist
# Thanh ghi su dung:
#             $a0 : Con tro duyet mang diem (tang 4 byte sau moi vong)
#             $a1 : Bien dem so phan tu con lai (giam 1 sau moi vong)
#             $a2 : Dia chi goc mang grade_tab
#             $a3 : Dia chi goc mang hist
#             $t0 : Gia tri diem doc tu mang scores (scores[i])
#             $t1 : Dia chi o nho tuong ung trong mang grade_tab ($a2 + $t0)
#             $t2 : Ma nhom thu duoc tu mang grade_tab (doc bang lbu)
#             $t3 : Dia chi phan tu nhom tuong ung trong mang hist ($a3 + $t2 * 4)
#             $t4 : Gia tri dem hien tai cua nhom trong hist (de cong them 1)
# Quy uc:     Chi su dung cac thanh ghi tham so $a0-$a3 va cac thanh ghi tam $t0-$t4.
# ===================================================================

histogram:
hist_loop:
	beq $a1, $zero, hist_done
	
	lw $t0, 0($a0)
	add $t1, $a2, $t0
	lbu $t2, 0($t1)
	
	sll $t3, $t2, 2
	add $t3, $a3, $t3
	lw $t4, 0($t3)
	addi $t4, $t4, 1
	sw $t4, 0($t3)
	
	addi $a0, $a0, 4
	addi $a1, $a1, -1
	j hist_loop

hist_done:
	jr $ra

	
	


##############################################################################################################
################################################# TN3_MR #####################################################
##############################################################################################################
.data
	scores:		.word 4 1 6 7 0 3 5 0 4 7 2 1
	grade_tab:	.byte 0 0 0 0 1 1 1 2 2 3 3	
	hist: 		.word 0 0 0 0
	n_scores: 	.word 12

    	str_g0:     .asciiz "g0: "
    	str_g1:     .asciiz "g1: "
    	str_g2:     .asciiz "g2: "
    	str_g3:     .asciiz "g3: "
    	str_nl:     .asciiz "\n"

    	labels:     .word str_g0, str_g1, str_g2, str_g3

.text
main:
    	# goi histogram
    	la      $a0, scores
    	lw      $a1, n_scores
    	la      $a2, grade_tab      
    	la      $a3, hist
    	jal     histogram

    	# Goi draw_hist
    	la      $a0, hist           # $a0 = dia chi mang hist sau tinh toan
    	li      $a1, 4              # $a1 = so nhom = 4
    	jal     draw_hist
	
    	li      $v0, 10
    	syscall


# ===================================================================
# THU TUC: histogram
# Muc dich:   Duyet mang diem, tra cuu phan nhom
#             va cap nhat so luong sinh vien tuong ung vao mang hist.
# Tham so:    $a0 = Dia chi goc mang diem (.word)
#             $a1 = So luong sinh vien N (dem lui ve 0)
#             $a2 = Dia chi goc mang grade_tab (.byte)
#             $a3 = Dia chi goc mang hist (.word)
# Tra ve:     Khong co. Cap nhat truc tiep ket qua vao mang hist
# Thanh ghi su dung:
#             $a0 : Con tro duyet mang diem (tang 4 byte sau moi vong)
#             $a1 : Bien dem so phan tu con lai (giam 1 sau moi vong)
#             $a2 : Dia chi goc mang grade_tab
#             $a3 : Dia chi goc mang hist
#             $t0 : Gia tri diem doc tu mang scores (scores[i])
#             $t1 : Dia chi o nho tuong ung trong mang grade_tab ($a2 + $t0)
#             $t2 : Ma nhom thu duoc tu mang grade_tab (doc bang lbu)
#             $t3 : Dia chi phan tu nhom tuong ung trong mang hist ($a3 + $t2 * 4)
#             $t4 : Gia tri dem hien tai cua nhom trong hist (de cong them 1)
# Quy uc:     Chi su dung cac thanh ghi tham so $a0-$a3 va cac thanh ghi tam $t0-$t4.
# ===================================================================

histogram:
hist_loop:
	beq $a1, $zero, hist_done
	
	lw $t0, 0($a0)
	add $t1, $a2, $t0
	lbu $t2, 0($t1)
	
	sll $t3, $t2, 2
	add $t3, $a3, $t3
	lw $t4, 0($t3)
	addi $t4, $t4, 1
	sw $t4, 0($t3)
	
	addi $a0, $a0, 4
	addi $a1, $a1, -1
	j hist_loop

hist_done:
	jr $ra


# ===================================================================
# THU TUC: draw_hist
# Muc dich:   Ve bieu do cot ngang bang ky tu '|' tu du lieu mang hist.
# Tham so:    $a0 = Dia chi mang hist (.word)
#             $a1 = So nhom (4)
# Tra ve:     Khong co. In truc tiep ra cua so Run I/O
# Thanh ghi su dung:
#             $a0 : Truyen dia chi chuoi / ky tu cho syscall
#             $a1 : Nhan so nhom (4)
#             $v0 : Ma lenh syscall (4: in chuoi, 11: in ky tu)
#             $t0 : Dia chi goc mang hist
#             $t1 : Bien dem vong lap ngoai i (0 -> $a1 - 1)
#             $t2 : So sinh vien nhom i (hist[i])
#             $t3 : Bien dem vong lap trong j (so ky tu '|' da in)
#             $t4 : Con tro duyet bang labels (tang 4 byte moi vong)
# Quy uc:     La thu tuc la (Leaf Procedure), bao ton hoan toan $s0-$s7.
# ===================================================================

draw_hist:
    	move $t0, $a0		# $t0 = dia chi mang hist
    	li $t1, 0              # i = 0
 	la $t4, labels
 	
dh_pra:
    	beq $t1, $a1, dh_done   # Neu i == $a1 -> Done

	#in "g_i:" 
    	lw $a0, 0($t4)         
    	li $v0, 4              
    	syscall
    	addi $t4, $t4, 4

    	# doc so luong sinh vien hist[i]
    	sll $t2, $t1, 2
    	add $t2, $t0, $t2
    	lw $t2, 0($t2)         # $t2 = hist[i]

    	# vong lap in |
    	li  $t3, 0              # j = 0

dh_loop:
   	beq $t3, $t2, dh_end  # j == hist[i] ->  ket thuc vong lap

    	li $v0, 11
    	li $a0, 124            # |
    	syscall

    	addi $t3, $t3, 1         # j++
    	j dh_loop

dh_end:
    	li $v0, 4
    	la $a0, str_nl
    	syscall

    	addi $t1, $t1, 1         # i++
    	j dh_pra

dh_done:
    	jr $ra
