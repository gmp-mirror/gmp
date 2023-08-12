dnl  S/390-64 mpn_cnd_add_n and mpn_cnd_sub_n.

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
C z13		 -
C z14		 -
C z15		1.7-2.0

define(`arp',	`%r2')
define(`srp',	`%r3')
define(`ap',	`%r4')
define(`bp',	`%r5')
define(`n',	`%r6')

define(`idx', `%r1')

ASM_START()
PROLOGUE(mpn_add_n_sub_n)
	srlg	%r0, n, 2
	tmll	n, 1
	je	L(bx0)
L(bx1):	vllezg	%v1, 0(bp)
	vllezg	%v3, 0(ap)
	vaq	%v5,  %v3, %v1
	vaccq	%v31, %v3, %v1
	vsteg	%v5,  0(arp), 0
	vsq	%v7,  %v3, %v1
	vscbiq	%v30, %v3, %v1
	vsteg	%v7,  0(srp), 0
	tmll	n, 2
	je	L(b01)
L(b11):	lghi	idx, -8
	aghi	%r0, 1
	j	L(mid)
L(b01):	clgije	%r0, 0, L(end)
	lghi	idx, 8
	j	L(top)
L(bx0):	vzero	%v31
	vone	%v30
	tmll	n, 2
	je	L(b00)
L(b10):	lghi	idx, -16
	aghi	%r0, 1
	j	L(mid)
L(b00):	clgije	%r0, 0, L(end)
	lghi	idx, 0

ALIGN(32)
L(top):	vlerg	%v0,  0(idx,bp)
	vlerg	%v2,  0(idx,ap)
	vacq	%v4,  %v2, %v0, %v31
	vacccq	%v31, %v2, %v0, %v31
	vsterg	%v4,  0(idx,arp)
	vsbiq	%v6,  %v2, %v0, %v30
	vsbcbiq	%v30, %v2, %v0, %v30
	vsterg	%v6,  0(idx,srp)
L(mid):	vlerg	%v1,  16(idx,bp)
	vlerg	%v3,  16(idx,ap)
	vacq	%v5,  %v3, %v1, %v31
	vacccq	%v31, %v3, %v1, %v31
	vsterg	%v5,  16(idx,arp)
	vsbiq	%v7,  %v3, %v1, %v30
	vsbcbiq	%v30, %v3, %v1, %v30
	vsterg	%v7,  16(idx,srp)

	la	idx,  32(idx)
	brctg	%r0,  L(top)

L(end):	vlgvg	%r2, %v31, 1
	vlgvg	%r3, %v30, 1
	risbg	%r3, %r3, 63, 128+63, 0
	xilf	%r3, 1
	sllg	%r2, %r2, 1
	algr	%r2, %r3
	br	%r14
EPILOGUE()
	.section .note.GNU-stack
