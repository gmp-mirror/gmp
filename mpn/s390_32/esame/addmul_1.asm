dnl  S/390-32 mpn_addmul_1

dnl  Copyright 2023 Free Software Foundation, Inc.

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

C TODO
C  * Delay saving of registers to handle n < 2 faster.

C            cycles/limb
C z900		 ?
C z990		 ?
C z9		 ?
C z10		 ?
C z196		 ?
C z12		 ?
C z13		 ?
C z14		 ?
C z15		 4.0

define(`rp',	`%r2')
define(`up',	`%r3')
define(`n',	`%r4')
define(`v0',	`%r5')

define(`idx',	`%r10')
define(`cy',	`%r11')

ASM_START()
PROLOGUE(mpn_addmul_1c)
	stm	%r6, %r13, 24(%r15)
	lr	cy, %r6
	j	L(ent)
EPILOGUE()
PROLOGUE(mpn_addmul_1)
	stm	%r6, %r13, 24(%r15)
	lhi	cy, 0
L(ent):	tmll	n, 1
	la	n, 3(n)
	je	L(bx0)
L(bx1):	tmll	n, 2
	srl	n, 2
	je	L(b01)
L(b11):	l	%r7, 0(up)
	mlr	%r6, v0
	l	%r9, 4(up)
	l	%r13, 8(up)
	mlr	%r8, v0
	mlr	%r12, v0
	alr	%r7, cy
	alcr	%r9, %r6
	lhi	cy, 0
	alcr	%r8, %r13
	alcr	cy, %r12
	al	%r7, 0(rp)
	st	%r7, 0(rp)
	lhi	idx, -4
	j	L(m3)

L(b01):	l	%r9, 0(up)
	mlr	%r8, v0
	alr	%r9, cy
	lhi	cy, 0
	alcr	cy, %r8
	al	%r9, 0(rp)
	st	%r9, 0(rp)
	lhi	idx, 4
	brct	n, L(top)
	j	L(end)

L(bx0):	tmll	n, 2
	lhi	idx, 0
	srl	n, 2
	jne	L(b00)
L(b10):	l	%r9, 0(up)
	l	%r13, 4(up)
	mlr	%r8, v0
	mlr	%r12, v0
	alr	%r9, cy
	lhi	cy, 0
	alcr	%r8, %r13
	alcr	cy, %r12
	al	%r9, 0(rp)
	lhi	idx, -8
	j	L(m2)
L(b00):	clr	%r0, %r0		C clear CF

L(top):	l	%r1, 0(idx,up)
	l	%r7, 4(idx,up)
	mlr	%r0, v0
	mlr	%r6, v0
	l	%r9, 8(idx,up)
	l	%r13, 12(idx,up)
	mlr	%r8, v0
	mlr	%r12, v0
	alcr	%r1, cy
	alcr	%r0, %r7
	alcr	%r9, %r6
	lhi	cy, 0
	alcr	%r8, %r13
	alcr	cy, %r12
	al	%r1, 0(idx,rp)
	alc	%r0, 4(idx,rp)
	st	%r1, 0(idx,rp)
	st	%r0, 4(idx,rp)
L(m3):	alc	%r9, 8(idx,rp)
L(m2):	alc	%r8, 12(idx,rp)
	st	%r9, 8(idx,rp)
	st	%r8, 12(idx,rp)
	la	idx, 16(idx)
	brct	n, L(top)

L(end):	lhi	%r2, 0
	alcr	%r2, cy
	lm	%r6, %r13, 24(%r15)
	br	%r14
EPILOGUE()
	.section .note.GNU-stack
