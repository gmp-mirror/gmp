dnl  S/390-64 mpn_popcount

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
C z12		 ?
C z13		 ?
C z14		 ?
C z15		 0.66	(@4.2)

define(`ap',	`%r2')
define(`n',	`%r3')

ASM_START()
PROLOGUE(mpn_popcount)
	clgije	n, 1, L(1)
	vzero	%v31
	lay	%r0, -2(n)
	srlg	%r0, %r0, 2

	vl	%v16, 0(ap), 3
	vpopctg	%v30, %v16
	tmll	n, 2
	je	L(b0x)

L(b1x):	la	ap, 16(ap)
	clgijle	n, 3, L(end)
	vl	%v16, 0(ap), 3
	vpopctg	%v31, %v16
	j	L(mid)

L(b0x):	vl	%v16, 16(ap), 3
	la	ap, 32(ap)
	vpopctg	%v31, %v16
	clgijle	n, 5, L(end)

L(top):	vl	%v16, 0(ap), 3
	vpopctg	%v20, %v16
	vag	%v30, %v30, %v20
L(mid):	vl	%v16, 16(ap), 3
	vpopctg	%v20, %v16
	vag	%v31, %v31, %v20
	la	ap, 32(ap)
	brctg	%r0, L(top)

L(end):	tmll	n, 1
	je	L(evn)
	vllezg	%v16, 0(ap)
	vpopctg	%v20, %v16
	vag	%v30, %v30, %v20

L(evn):	vag	%v30, %v30, %v31
	vzero	%v29
	vsumqg	%v30, %v30, %v29
	vlgvg	%r2, %v30, 1(%r0)
	br	%r14

L(1):	vllezg	%v16, 0(ap)
	vpopctg	%v30, %v16
	vlgvg	%r2, %v30, 0
	br	%r14
EPILOGUE()
