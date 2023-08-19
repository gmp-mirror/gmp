dnl  S/390-64 mpn_copyi

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

C            cycles/limb
C z900		 -
C z990           -
C z9		 -
C z10		 -
C z196		 -
C z12		 -
C z13		 -
C z14		 -
C z15		 0.62	(@4.2)

C NOTE
C  * This code is inspired by GNU libc memcpy which was written by Martin
C    Schwidefsky.

C INPUT PARAMETERS
define(`rp',	`%r2')
define(`up',	`%r3')
define(`n',	`%r4')

ASM_START()
PROLOGUE(mpn_copyd)
	clgije	n, 0, L(rtn)
	sllg	%r4, %r4, 3
	la	rp, 0(%r4,rp)
	la	up, 0(%r4,up)
	aghi	%r4, -1
	srlg	%r5, %r4, 8
	lghi	%r0, 255
	clgije	%r5, 0, L(1)

L(top):	lay	rp, -256(rp)
	lay	up, -256(up)
	mvcrl	0(rp), 0(up)
	brctg	%r5, L(top)

L(1):	ngr	%r0, %r4
	nngrk	%r1, %r0, %r0
	la	rp, 0(%r1,rp)
	la	up, 0(%r1,up)
	mvcrl	0(rp), 0(up)
L(rtn):	br	%r14
EPILOGUE()
	.section .note.GNU-stack
