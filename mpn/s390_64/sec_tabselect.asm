dnl  S/390-64 mpn_sec_tabselect

dnl  Copyright 2021 Free Software Foundation, Inc.

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
C z900		 ?
C z990		 ?
C z9		 ?
C z10		 ?
C z196		 ?
C z13		 ?
C z14		 ?
C z15		 ?

dnl void
dnl mpn_sec_tabselect (volatile mp_limb_t *rp, volatile const mp_limb_t *tab,
dnl                    mp_size_t n, mp_size_t nents, mp_size_t which)

define(`rp',	`%r2')
define(`tp',	`%r3')
define(`n',	`%r4')
define(`nents',	`%r5')
define(`which',	`%r6')

ASM_START()
PROLOGUE(mpn_sec_tabselect)
	stmg	%r7, %r8, 56(%r15)
	lgr	%r8, n
	sllg	n, n, 3

L(cpy):	lg	%r0, 0(tp)
	stg	%r0, 0(rp)
	aghi	tp, 8
	aghi	rp, 8
	brctg	%r8, L(cpy)

	aghi	nents, -1
	jle	L(ret)
	slfi	which, 1

L(outer):
	slfi	which, 1
	slbgr	%r0, %r0
	sgr	rp, n
	srlg	%r8, n, 3

L(top):	lg	%r1, 0(rp)
	lg	%r7, 0(tp)
	xgr	%r7, %r1
	ngr	%r7, %r0
	xgr	%r1, %r7
	stg	%r1, 0(rp)
	aghi	tp, 8
	aghi	rp, 8
	brctg	%r8, L(top)

	brctg	nents, L(outer)

L(ret):	lmg	%r7, %r8, 56(%r15)
	br	%r14
EPILOGUE()
