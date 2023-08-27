dnl  S/390-64 mpn_submul_1

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
C  * Clean up register usage in feed-in code (b11 is worst)

C            cycles/limb
C z900		 ?
C z990		 ?
C z9		 ?
C z10		 ?
C z196		 ?
C z12		 ?
C z13		 ?
C z14		 ?
C z15		 5.0

define(`rp',	`%r2')
define(`up',	`%r3')
define(`n',	`%r4')
define(`v0',	`%r5')

define(`idx',	`%r10')
define(`cy',	`%r11')

ASM_START()
PROLOGUE(mpn_submul_1)
	stmg	%r6, %r14, 48(%r15)
	lghi	%r14, 0
	lghi	cy, 0
	tmll	n, 1
	la	n, 3(n)
	je	L(bx0)
L(bx1):	tmll	n, 2
	srlg	n, n, 2
	je	L(b01)
L(b11):	lg	%r7, 0(up)
	mlgr	%r6, v0
	lg	%r9, 8(up)
	lg	%r13, 16(up)
	mlgr	%r8, v0
	mlgr	%r12, v0
	algr	%r7, cy
	alcgr	%r9, %r6
	lghi	cy, 0
	alcgr	%r8, %r13
	alcgr	cy, %r12
	lg	%r0, 0(rp)
	slgr	%r0, %r7
	stg	%r0, 0(rp)
	lghi	idx, -8
	j	L(m3)

L(b01):	lg	%r13, 0(up)
	mlgr	%r12, v0
	algr	%r13, cy
	lghi	cy, 0
	alcgr	cy, %r12
	lg	%r6, 0(rp)
	slgr	%r6, %r13
	stg	%r6, 0(rp)
	slbgr	%r14, %r14
	lghi	idx, 8
	brctg	n, L(top)
	j	L(end)

L(bx0):	tmll	n, 2
	lghi	idx, 0
	srlg	n, n, 2
	jne	L(b00)
L(b10):	lg	%r9, 0(up)
	lg	%r13, 8(up)
	mlgr	%r8, v0
	mlgr	%r12, v0
	algr	%r9, cy
	lghi	cy, 0
	alcgr	%r8, %r13
	alcgr	cy, %r12
	lg	%r12, 0(rp)
	lg	%r13, 8(rp)
	slgr	%r12, %r9
	lghi	idx, -16
	j	L(m2)
L(b00):

L(top):	lg	%r1, 0(idx,up)
	lg	%r7, 8(idx,up)
	mlgr	%r0, v0
	mlgr	%r6, v0
	lg	%r9, 16(idx,up)
	lg	%r13, 24(idx,up)
	mlgr	%r8, v0
	mlgr	%r12, v0
	algr	%r1, cy
	alcgr	%r0, %r7
	alcgr	%r9, %r6
	lghi	cy, 0
	alcgr	%r8, %r13
	alcgr	cy, %r12
	cghi	%r14, -1
	lg	%r6, 0(idx,rp)
	lg	%r7, 8(idx,rp)
	slbgr	%r6, %r1
	slbgr	%r7, %r0
	stg	%r6, 0(idx,rp)
	stg	%r7, 8(idx,rp)
L(m3):	lg	%r12, 16(idx,rp)
	lg	%r13, 24(idx,rp)
	slbgr	%r12, %r9
L(m2):	slbgr	%r13, %r8
	slbgr	%r14, %r14
	stg	%r12, 16(idx,rp)
	stg	%r13, 24(idx,rp)
	la	idx, 32(idx)
	brctg	n, L(top)

L(end):	lgr	%r2, cy
	slgr	%r2, %r14
	lmg	%r6, %r14, 48(%r15)
	br	%r14
EPILOGUE()
	.section .note.GNU-stack
