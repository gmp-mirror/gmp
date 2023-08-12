dnl  S/390 mpn_gcd_11 -- 1 x 1 gcd.

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

define(`u0',    `%r2')
define(`v0',    `%r3')

ASM_START()
PROLOGUE(mpn_gcd_11)
	cgrje	v0, u0, L(end)

L(top):	slgrk	%r0, v0, u0
	slgrk	%r4, u0, v0
	ngr	%r4, %r0
	flogr	%r4, %r4
	xilf	%r4, 63
	lgr	%r1, u0
	slgr	u0, v0			C u - v
	locgr	u0, %r0, 4		C u = |u - v|
	locgr	v0, %r1, 4		C v = min(u,v)
	srlg	u0, u0, 0(%r4)
	cgrjne	v0, u0, L(top)

L(end):	br	%r14
EPILOGUE()
	.section .note.GNU-stack
