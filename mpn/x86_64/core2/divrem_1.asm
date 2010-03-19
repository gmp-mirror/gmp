dnl  x86-64 mpn_divrem_1 -- mpn by limb division.

dnl  Copyright 2004, 2005, 2007, 2008, 2009, 2010 Free Software Foundation,
dnl  Inc.

dnl  This file is part of the GNU MP Library.

dnl  The GNU MP Library is free software; you can redistribute it and/or modify
dnl  it under the terms of the GNU Lesser General Public License as published
dnl  by the Free Software Foundation; either version 3 of the License, or (at
dnl  your option) any later version.

dnl  The GNU MP Library is distributed in the hope that it will be useful, but
dnl  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
dnl  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
dnl  License for more details.

dnl  You should have received a copy of the GNU Lesser General Public License
dnl  along with the GNU MP Library.  If not, see http://www.gnu.org/licenses/.

include(`../config.m4')


C		norm	unorm	frac
C AMD K8,K9	13	14	12	The norm number assumes special code
C AMD K10	13	14	12	The norm number assumes special code
C Intel P4	47	45	43
C Intel core2	23	23	19.5
C Intel corei	19	19	18	The norm number assumes !special code
C Intel atom	43	51	36	The norm number assumes special code
C VIA nano	25	43	24

C mp_limb_t
C mpn_divrem_1 (mp_ptr qp, mp_size_t fn,
C               mp_srcptr np, mp_size_t nn, mp_limb_t d)

C mp_limb_t
C mpn_preinv_divrem_1 (mp_ptr qp, mp_size_t fn,
C                      mp_srcptr np, mp_size_t nn, mp_limb_t d,
C                      mp_limb_t dinv, int cnt)

C INPUT PARAMETERS
define(`qp',		`%rdi')
define(`fn_param',	`%rsi')
define(`up_param',	`%rdx')
define(`un_param',	`%rcx')
define(`d',		`%r8')
define(`dinv',		`%r9')		C only for mpn_preinv_divrem_1
C       shift passed on stack		C only for mpn_preinv_divrem_1

define(`cnt',		`%rcx')
define(`up',		`%rsi')
define(`fn',		`%r12')
define(`un',		`%rbx')


C rax rbx rcx rdx rsi rdi rbp r8  r9  r10 r11 r12 r13 r14 r15
C         cnt         qp      d  dinv

ASM_START()
	TEXT
	ALIGN(16)
PROLOGUE(mpn_preinv_divrem_1)
	xor	R32(%rax), R32(%rax)
	push	%r13
	push	%r12
	push	%rbp
	push	%rbx

	mov	fn_param, fn
	mov	un_param, un
	add	fn_param, un_param
	mov	up_param, up

	lea	-8(qp,un_param,8), qp

	mov	40(%rsp), R8(cnt)
	shl	R8(cnt), d
	jmp	L(uent)
EPILOGUE()

	ALIGN(16)
PROLOGUE(mpn_divrem_1)
	xor	R32(%rax), R32(%rax)
	push	%r13
	push	%r12
	push	%rbp
	push	%rbx

	mov	fn_param, fn
	mov	un_param, un
	add	fn_param, un_param
	mov	up_param, up
	je	L(ret)

	lea	-8(qp,un_param,8), qp
	xor	R32(%rbp), R32(%rbp)

L(unnormalized):
	test	un, un
	je	L(44)
	mov	-8(up,un,8), %rax
	cmp	d, %rax
	jae	L(44)
	mov	%rbp, (qp)
	mov	%rax, %rbp
	lea	-8(qp), qp
	je	L(ret)
	dec	un
L(44):
	bsr	d, %rcx
	not	R32(%rcx)
	sal	R8(%rcx), d
	sal	R8(%rcx), %rbp

	push	%rcx
	push	%rdi
	push	%rsi
	push	%r8
	mov	d, %rdi
	CALL(	mpn_invert_limb)
	pop	%r8
	pop	%rsi
	pop	%rdi
	pop	%rcx

	mov	%rax, dinv
	mov	%rbp, %rax
	test	un, un
	je	L(87)
L(uent):mov	-8(up,un,8), %rbp
	shr	R8(%rcx), %rax
	shld	R8(%rcx), %rbp, %rax
	sub	$2, un
	js	L(uend)

	ALIGN(16)
L(utop):lea	1(%rax), %r11
	mul	dinv
	mov	(up,un,8), %r10
	shld	R8(%rcx), %r10, %rbp
	add	%rbp, %rax
	adc	%r11, %rdx
	mov	%rax, %r11
	mov	%rdx, %r13
	imul	d, %rdx
	sub	%rdx, %rbp
	mov	d, %rax
	add	%rbp, %rax
	sub	$8, qp
	cmp	%r11, %rbp
	cmovb	%rbp, %rax
	adc	$-1, %r13
	cmp	d, %rax
	jae	L(ufx)
L(uok):	dec	un
	mov	%r13, 8(qp)
	mov	%r10, %rbp
	jns	L(utop)

L(uend):lea	1(%rax), %r11
	sal	R8(%rcx), %rbp
	mul	dinv
	add	%rbp, %rax
	adc	%r11, %rdx
	mov	%rax, %r11
	mov	%rdx, %r13
	imul	d, %rdx
	sub	%rdx, %rbp
	mov	d, %rax
	add	%rbp, %rax
	cmp	%r11, %rbp
	cmovb	%rbp, %rax
	adc	$-1, %r13
	cmp	d, %rax
	jae	L(efx)
L(eok):	mov	%r13, (qp)
	sub	$8, qp
	jmp	L(87)

L(ufx):	sub	d, %rax
	inc	%r13
	jmp	L(uok)
L(efx):	sub	d, %rax
	inc	%r13
	jmp	L(eok)

L(87):	mov	d, %rbp
	neg	%rbp
	jmp	L(fent)

	ALIGN(16)			C	    K8-K10  P6-CNR P6-NHM  P4
L(ftop):mul	dinv			C	      0,12   0,17   0,17
	add	%r11, %rdx		C	      5      8     10
	mov	%rax, %r11		C	      4      8      3
	mov	%rdx, %r13		C	      6      9     11
	imul	%rbp, %rdx		C	      6      9     11
	mov	d, %rax			C
	add	%rdx, %rax		C	     10     14     14
	cmp	%r11, %rdx		C	     10     14     14
	cmovb	%rdx, %rax		C	     11     15     15
	adc	$-1, %r13		C
	mov	%r13, (qp)		C
	sub	$8, qp			C
L(fent):lea	1(%rax), %r11		C
	dec	fn			C
	jns	L(ftop)			C

	shr	R8(%rcx), %rax
L(ret):	pop	%rbx
	pop	%rbp
	pop	%r12
	pop	%r13
	ret
EPILOGUE()
