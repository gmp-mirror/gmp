dnl  S/390-64 mpn_mul_1

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
C z15		 3.5

define(`rp',	`%r2')
define(`up',	`%r3')
define(`n',	`%r4')
define(`v0',	`%r5')

define(`idx',	`%r10')

ASM_START()
PROLOGUE(mpn_mul_1c)
	stmg	%r6, %r10, 48(%r15)
	lgr	%r8, %r6
	j	L(ent)
EPILOGUE()
PROLOGUE(mpn_mul_1)
	stmg	%r6, %r10, 48(%r15)
	lghi	%r8, 0			C clear carry limb
	lghi	%r6, 0			C clear carry limb
L(ent):	tmll	n, 1
	la	n, 3(n)
	je	L(bx0)
L(bx1):	tmll	n, 2
	srlg	n, n, 2
	je	L(b01)
L(b11):	lg	%r7, 0(up)
	mlgr	%r6, v0
	algr	%r7, %r8
	stg	%r7, 0(rp)
	lghi	idx, -8
	j	L(mid)
L(b01):	lg	%r9, 0(up)
	mlgr	%r8, v0
	algr	%r9, %r6
	lghi	%r6, 0
	alcgr	%r8, %r6
	stg	%r9, 0(rp)
	lghi	idx, 8
	brctg	n, L(top)
	j	L(end)
L(bx0):	tmll	n, 2
	srlg	n, n, 2
	jne	L(b00)
L(b10):	lghi	idx, -16
C	clgr	%r0, %r0		C clear CF
	j	L(mid)
L(b00):	clgr	%r0, %r0		C clear CF
	lghi	idx, 0

L(top):	lg	%r1, 0(idx,up)
	lg	%r7, 8(idx,up)
	mlgr	%r0, v0
	mlgr	%r6, v0
	alcgr	%r8, %r1
	alcgr	%r0, %r7
	stg	%r8, 0(idx,rp)
	stg	%r0, 8(idx,rp)
L(mid):	lg	%r1, 16(idx,up)
	lg	%r9, 24(idx,up)
	mlgr	%r0, v0
	mlgr	%r8, v0
	alcgr	%r6, %r1
	alcgr	%r0, %r9
	stg	%r6, 16(idx,rp)
	stg	%r0, 24(idx,rp)
	la	idx, 32(idx)
	brctg	n, L(top)

L(end):	lghi	%r2, 0
	alcgr	%r2, %r8
	lmg	%r6, %r10, 48(%r15)
	br	%r14
EPILOGUE()
	.section .note.GNU-stack
