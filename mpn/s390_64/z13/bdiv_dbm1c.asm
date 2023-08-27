dnl  S/390-64 mpn_bdiv_dbm1c

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
C z990		 -
C z9		 -
C z10		 -
C z196		 -
C z12		 -
C z13		 ?
C z14		 ?
C z15		 5.0

C INPUT PARAMETERS
define(`qp',	  `%r2')
define(`up',	  `%r3')
define(`n',	  `%r4')
define(`bd',	  `%r5')
define(`cy',	  `%r6')

define(`idx',     `%r7')

ASM_START()
PROLOGUE(mpn_bdiv_dbm1c)
	stmg	%r6, %r9, 48(%r15)
	vlvgp	%v2, %r6, %r6
	lghi	idx, 0
	tmll	n, 1
	srlg	n, n, 1
	je	L(top)

	lg	%r1, 0(up)
	mlgr	%r0, bd
	agr	%r0, %r1
	vlvgp	%v0, %r0, %r1
	vsq	%v2, %v2, %v0
	vsteg	%v2, 0(qp), 1
	vpdi	%v2, %v2, %v2, 0	C copy left dword to both dwords
	cgije	n, 0, L(end)
	lghi	idx, 8

L(top):	lg	%r1, 0(idx,up)
	lg	%r9, 8(idx,up)
	mlgr	%r0, bd
	mlgr	%r8, bd
	agr	%r0, %r1
	vlvgp	%v0, %r0, %r1
	agr	%r8, %r9
	vlvgp	%v1, %r8, %r9
	vsq	%v3, %v2, %v0
	vpdi	%v4, %v3, %v3, 0
	vsq	%v5, %v4, %v1
	vpdi	%v2, %v5, %v5, 0
	vsteg	%v3, 0(idx,qp), 1
	vsteg	%v5, 8(idx,qp), 1
	la	idx, 16(idx)
	brctg	n, L(top)

L(end):	vlgvg	%r2, %v6, 0
	lmg	%r6, %r9, 48(%r15)
	br	%r14
EPILOGUE()
