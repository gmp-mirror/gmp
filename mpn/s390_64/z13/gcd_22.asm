dnl  S/390-64 mpn_gcd_22.

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

define(`u1',    `%r3')
define(`u0',    `%r4')
define(`v1',    `%r5')
define(`v0_arg',`%r6')

define(`v0',    `%r11')

define(`cnt',   `%r12')
define(`s1',    `%r13')
define(`s0',    `%r14')
define(`t1',    `%r1')
define(`t0',    `%r0')

ASM_START()
PROLOGUE(mpn_gcd_22)
	stmg	%r11, %r15, 88(%r15)
	lgr	v0, v0_arg

L(top):	cgrje	v0, u0, L(lowz)		C jump when low limb result = 0

	slgrk	t0, v0, u0
	lgr	t1, v1
	slbgr	t1, u1

	lcgr	cnt, t0
	ngr	cnt, t0
	flogr	cnt, cnt		C clobbers next reg (r13)!
	xilf	cnt, 63

	lgr	s0, u0
	lgr	s1, u1
	slgr	u0, v0
	slbgr	u1, v1

L(bck):	locgr	u0, t0, 12		C u = |u - v|
	locgr	u1, t1, 12		C u = |u - v|
	locgr	v0, s0, 12		C v = min(u,v)
	locgr	v1, s1, 12		C v = min(u,v)

C Rightshift (u1,,u0) into (u1,,u0)
L(shr):	lcgr	t1, cnt
	srlg	u0, u0, 0(cnt)
	sllg	t1, u1, 0(t1)
	srlg	u1, u1, 0(cnt)
	ogr	u0, t1

	cgijne	v1, 0, L(top)	
	cgijne	u1, 0, L(top)	

L(gcd_11):
	lay	%r15, -160(%r15)
	lgr	%r13, %r2		C return struct pointer
	lgr	%r2, v0
	lgr	%r3, u0
	brasl	%r14, mpn_gcd_11@PLT
	stg	%r2, 0(%r13)
	mvghi	8(%r13), 0
	lmg	%r11, %r15, 88+160(%r15)
	br	%r14

L(lowz):C We come here when v0 - u0 = 0
	C 1. If v1 - u1 = 0, then gcd is u = v.
	C 2. Else compute gcd_21({v1,v0}, |u1-v1|)
	cgrje	  v1, u1, L(end)

	slgrk	t0, v1, u1
	lghi	t1, 0

	lcgr	cnt, t0
	ngr	cnt, t0
	flogr	cnt, cnt		C clobbers next reg (r13)!
	xilf	cnt, 63

	lgr	s0, u0
	lgr	s1, u1
	slgrk	u0, u1, v1
	lghi	u1, 0
	j	L(bck)

L(end):	stg	v0, 0(%r2)
	stg	v1, 8(%r2)
	lmg	%r11, %r15, 88(%r15)
	br	%r14
EPILOGUE()
	.section .note.GNU-stack
