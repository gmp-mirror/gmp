dnl  AMD64 mpn_submul_1 for CPUs with mulx and adx.

dnl  Contributed to the GNU project by Torbjörn Granlund.

dnl  Copyright 2022 Free Software Foundation, Inc.

dnl  This file is part of the GNU MP Library.
dnl
dnl  The GNU MP Library is free software; you can redistribute it and/or modify
dnl  it under the terms of either:
dnl
dnl    * the GNU Lesser General Public License as published by the Free
dnl      Software Foundation; either version 3 of the License, or (at your
dnl      option) any later version.
dnl
dnl  or
dnl
dnl    * the GNU General Public License as published by the Free Software
dnl      Foundation; either version 2 of the License, or (at your option) any
dnl      later version.
dnl
dnl  or both in parallel, as here.
dnl
dnl  The GNU MP Library is distributed in the hope that it will be useful, but
dnl  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
dnl  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
dnl  for more details.
dnl
dnl  You should have received copies of the GNU General Public License and the
dnl  GNU Lesser General Public License along with the GNU MP Library.  If not,
dnl  see https://www.gnu.org/licenses/.

include(`../config.m4')

C	     cycles/limb
C AMD K8,K9	 -
C AMD K10	 -
C AMD bd1	 -
C AMD bd2	 -
C AMD bd3	 -
C AMD bd4	 -
C AMD zn1	 ?
C AMD zn2	 ?
C AMD zn3	 ?
C AMD bt1	 -
C AMD bt2	 -
C Intel P4	 -
C Intel CNR	 -
C Intel PNR	 -
C Intel NHM	 -
C Intel WSM	 -
C Intel SBR	 -
C Intel IBR	 -
C Intel HWL	 -
C Intel BWL	 ?
C Intel SKL	 ?
C Intel RKL	 ?
C Intel ALD	 1.53
C Intel atom	 -
C Intel SLM	 -
C Intel GLM	 -
C VIA nano	 -

define(`rp',      `%rdi')	dnl rcx
define(`up',      `%rsi')	dnl rdx
define(`n_param', `%rdx')	dnl r8
define(`v0_param',`%rcx')	dnl r9

define(`n',       `%rcx')	dnl
define(`v0',      `%rdx')	dnl


ASM_START()
	TEXT
	ALIGN(16)
PROLOGUE(mpn_submul_1)
	mov	n_param, %rax
	mov	v0_param, v0
	mov	%rax, n
	test	$1, R8(n)
	mov	$-1, %rax
	adox(	%rax, %rax)		C Set OF
	jz	L(b0)

L(b1):	mov	$0, R32(%r8)
	lea	-8(up), up
	lea	-8(rp), rp
	lea	1(n), n
	jmp	L(lo1)

L(b0):	mov	$0, R32(%r10)

L(top):	mulx(	(up), %r9, %r8)
	adcx(	%r10, %r9)
	not	%r9
	adox(	(rp), %r9)
	mov	%r9, (rp)
L(lo1):	mulx(	8,(up), %r11, %r10)
	adcx(	%r8, %r11)
	not	%r11
	adox(	8,(rp), %r11)
	mov	%r11, 8(rp)
	lea	16(up), up
	lea	16(rp), rp
	lea	-2(n), n
	jrcxz	L(end)
	jmp	L(top)

L(end):	adcx(	%rcx, %r10)
	not	%r10
	adox(	%rcx, %r10)
	mov	%r10, %rax
	neg	%rax
	ret
EPILOGUE()
ASM_END()
