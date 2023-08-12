dnl  S/390-64 mpn_com.

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
C z15		 0.55

define(`rp',	`%r2')
define(`ap',	`%r3')
define(`n',	`%r4')

ASM_START()
PROLOGUE(mpn_com)
	srlg	%r0, n, 3

	tmll	n, 1
	je	L(xx0)
L(xx1):	lg	%r5, 0(ap)
	nngrk	%r5, %r5, %r5
	stg	%r5, 0(rp)
	la	ap, 8(ap)
	la	rp, 8(rp)
	cgije	n, 1, L(end)

L(xx0):	tmll	n, 2
	je	L(x00)
L(x10):	tmll	n, 4
	je	L(010)
L(110):	vlm	%v0, %v2, 0(ap)
	vno	%v0, %v0, %v0
	vno	%v1, %v1, %v1
	vno	%v2, %v2, %v2
	vstm	%v0, %v2, 0(rp)
	cgije	%r0, 0, L(end)
	la	ap, 48(ap)
	la	rp, 48(rp)
	j	L(top)
L(010):	vl	%v0, 0(ap), 3
	vno	%v0, %v0, %v0
	vst	%v0, 0(rp), 3
	cgije	%r0, 0, L(end)
	la	ap, 16(ap)
	la	rp, 16(rp)
	j	L(top)

L(x00):	tmll	n, 4
	je	L(top)
L(100):	vlm	%v0, %v1, 0(ap)
	vno	%v0, %v0, %v0
	vno	%v1, %v1, %v1
	vstm	%v0, %v1, 0(rp)
	cgije	%r0, 0, L(end)
	la	ap, 32(ap)
	la	rp, 32(rp)

L(top):	vlm	%v0, %v3, 0(ap)
	la	ap, 64(ap)
	vno	%v0, %v0, %v0
	vno	%v1, %v1, %v1
	vno	%v2, %v2, %v2
	vno	%v3, %v3, %v3
	vstm	%v0, %v3, 0(rp)
	la	rp, 64(rp)
	brctg	%r0, L(top)

L(end):	br	%r14
EPILOGUE()
