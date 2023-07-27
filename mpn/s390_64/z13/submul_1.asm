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

dnl TODO
dnl * Schedule vlvgp away from mlgr; that saves 20% of the run time.
dnl * Perhaps use vp[0]/vp[1] in innerloop instead preloading v0/v1.

C            cycles/limb
C z900		 -
C z990		 -
C z9		 -
C z10		 -
C z196		 -
C z12		 ?
C z13		 ?
C z14		 ?
C z15		 3.9


define(`rp',	`%r2')
define(`up',	`%r3')
define(`un',	`%r4')
define(`v0',	`%r5')
define(`cy',	`%r6')

define(`idx',	`%r8')

ASM_START()

PROLOGUE(mpn_submul_1)
	stmg	%r6, %r9, 48(%r15)
	tmll	un, 1
	srlg	un, un, 1
	je	L(evn)

L(odd):	lg	%r7, 0(up)
	mlgr	%r6, v0			C W1 W0
	lghi	%r9, 0
	lg	%r1, 0(rp)
	slbgr	%r1, %r7
	slbgr	%r7, %r7
	slgr	%r6, %r7
	stg	%r1, 0(rp)
	clgije	un, 0, L(1)
	lghi	idx, 8
	j	L(lst)
L(evn):	lghi	%r6, 0
	lghi	idx, 0

L(lst):	vzero	%v29
	vone	%v30
L(top):	lgr	%r9, %r6
	lg	%r1, 0(idx, up)
	lg	%r7, 8(idx, up)
	mlgr	%r0, v0			C W1 W0
	mlgr	%r6, v0			C W2 W1
	vlvgp	%v23, %r0, %r1		C W1 W0
	vlvgp	%v21, %r7, %r9		C W1 W0
	vacq	%v24, %v23, %v21, %v29	C
	vacccq	%v29, %v23, %v21, %v29	C	carry critical path 1
	vl	%v16, 0(idx, rp), 3
	vpdi	%v16, %v16, %v16, 4
	vsbiq	%v20, %v16, %v24, %v30	C
	vsbcbiq	%v30, %v16, %v24, %v30	C	carry critical path 2
	vpdi	%v20, %v20, %v20, 4
	vst	%v20, 0(idx, rp), 3
	la	idx, 16(idx)
	brctg	un, L(top)

L(end):	vsg	%v29, %v29, %v30
	vlgvg	%r2, %v29, 1
	algr	%r2, %r6
	aghi	%r2, 1
	lmg	%r6, %r9, 48(%r15)
	br	%r14
L(1):	lgr	%r2, %r6
	lmg	%r6, %r9, 48(%r15)
	br	%r14
EPILOGUE()
