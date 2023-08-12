dnl  S/390-64 mpn_rshift.

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
C z13		 ?
C z14		 ?
C z15		 1.25

define(`rp',	`%r2')
define(`ap',	`%r3')
define(`n',	`%r4')
define(`cnt',	`%r5')

define(`tnc',	`%r1')

ASM_START()
PROLOGUE(mpn_rshift)
	lghi	tnc, 64
	slgr	tnc, cnt

	lg	%r0, 0(ap)

	tmll	n, 1
	je	L(bx0)
L(bx1):
	clgijne	n, 1, L(gt1)

L(1):	srlg	%r5, %r0, 0(cnt)
	stg	%r5, 0(rp)
	sllg	%r2, %r0, 0(tnc)
	br	%r14

L(gt1):	stmg	%r6, %r7, 48(%r15)
	lg	%r6, 8(ap)
	sllg	%r6, %r6, 0(tnc)
	srlg	%r7, %r0, 0(cnt)
	ogr	%r6, %r7
	stg	%r6, 0(rp)
	la	ap, 8(ap)
	la	rp, 8(rp)
	lmg	%r6, %r7, 48(%r15)

L(bx0):	tmll	n, 2
	srlg	n, n, 2
	jne	L(bx10)
L(bx00):vleg	%v0, 0(ap), 1
	lay	ap, -16(ap)
	lay	rp, -16(rp)
	j	L(mid)

L(bx10):vleg	%v1, 0(ap), 1
	clgije	n, 0, L(end)

L(top):	vl	%v0, 8(ap), 3
	vpdi	%v2, %v1, %v0, 4
	vesrlg	%v4, %v2, 0(cnt)
	veslg	%v6, %v0, 0(tnc)
	vo	%v6, %v4, %v6
	vst	%v6, 0(rp), 3
L(mid):	vl	%v1, 24(ap), 3
	vpdi	%v3, %v0, %v1, 4
	vesrlg	%v5, %v3, 0(cnt)
	veslg	%v7, %v1, 0(tnc)
	vo	%v7, %v5, %v7
	vst	%v7, 16(rp), 3
	la	ap, 32(ap)
	la	rp, 32(rp)
	brctg	n, L(top)

L(end):	vzero	%v0
	vleg	%v0, 8(ap), 0
	vpdi	%v2, %v1, %v0, 4
	vesrlg	%v4, %v2, 0(cnt)
	veslg	%v6, %v0, 0(tnc)
	vo	%v6, %v4, %v6
	vst	%v6, 0(rp), 3

	sllg	%r2, %r0, 0(tnc)
	br	%r14
EPILOGUE()
	.section	.note.GNU-stack
