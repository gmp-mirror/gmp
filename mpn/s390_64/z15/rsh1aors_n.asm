dnl  S/390-64 mpn_rsh1add_n, mpn_rsh1sub_n.

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
C z15		1.4-1.7

define(`rp',	`%r2')
define(`ap',	`%r3')
define(`bp',	`%r4')
define(`n',	`%r5')

define(`idx',	`%r1')

ifdef(`OPERATION_rsh1add_n', `
  define(ASR,  `vaq    $1, $2, $3')
  define(ASCO, `vaccq  $1, $2, $3')
  define(ASRCI,`vacq   $1, $2, $3, $4')
  define(ASCIO,`vacccq $1, $2, $3, $4')
  define(CLCREG,vzero)
  define(FIXCY, `dnl')
  define(`func_n',	mpn_rsh1add_n)')

ifdef(`OPERATION_rsh1sub_n', `
  define(ASR,  `vsq	$1, $2, $3')
  define(ASCO, `vscbiq	$1, $2, $3')
  define(ASRCI,`vsbiq	$1, $2, $3, $4')
  define(ASCIO,`vsbcbiq	$1, $2, $3, $4')
  define(CLCREG,vone)
  define(FIXCY, `vno')
  define(`func_n',	mpn_rsh1sub_n)')

MULFUNC_PROLOGUE(mpn_rsh1add_n mpn_rsh1sub_n)

ASM_START()
PROLOGUE(func_n)
	lay	%r0, -2(n)
	srlg	%r0, %r0, 2

	tmll	n, 1
	je	L(bx0)
L(bx1):	tmll	n, 2
	je	L(b01)
L(b11):	vllezg	%v1,  0(bp)
	vllezg	%v3,  0(ap)
	vlerg	%v0,  8(bp)
	vlerg	%v2,  8(ap)
	ASR(	%v5,  %v3, %v1)
	ASCO(	%v31, %v3, %v1)
	vpdi	%v30, %v5, %v5, 4
	clgije	n, 3, L(3)
	vlerg	%v1,  24(bp)
	vlerg	%v3,  24(ap)
	ASRCI(	%v4,  %v2, %v0, %v31)
	ASCIO(	%v31, %v2, %v0, %v31)
	vlerg	%v0,  40(bp)
	vlerg	%v2,  40(ap)
	vsrd	%v6,  %v4, %v5, 1
	vsteg	%v6, 0(rp), 0
	ASRCI(	%v5,  %v3, %v1, %v31)
	ASCIO(	%v31, %v3, %v1, %v31)
	lghi	idx,  8
	brctg	%r0, L(top)
	j	L(end)

L(3):	ASRCI(	%v4,  %v2, %v0, %v31)
	ASCIO(	%v31, %v2, %v0, %v31)
	vsrd	%v7,  %v4, %v5, 1
	vsteg	%v7, 0(rp), 0
	FIXCY	%v31, %v31, %v31
	vsrd	%v6,  %v31, %v4, 1
	vsterg	%v6,  8(rp)
	vlgvg	%r2,  %v30, 1
	risbg	%r2,  %r2, 63, 128+63, 0
	br	%r14

L(b01):	lghi	idx, -8
	vllezg	%v0,  0(bp)
	vllezg	%v2,  0(ap)
	clgije	n, 1, L(1)
	vlerg	%v1,  8(bp)
	vlerg	%v3,  8(ap)
	ASR(	%v4,  %v2, %v0)
	ASCO(	%v31, %v2, %v0)
	vpdi	%v30, %v4, %v4, 4
	vlerg	%v0,  24(bp)
	vlerg	%v2,  24(ap)
	ASRCI(	%v5,  %v3, %v1, %v31)
	ASCIO(	%v31, %v3, %v1, %v31)
	clgije	n, 5, L(5)
	vlerg	%v1,  40(bp)
	vlerg	%v3,  40(ap)
	vsrd	%v6,  %v5, %v4, 1
	vsteg	%v6, 0(rp), 0
	ASRCI(	%v4,  %v2, %v0, %v31)
	ASCIO(	%v31, %v2, %v0, %v31)
	j	L(mid)

L(1):	ASR(	%v4,  %v2, %v0)
	ASCO(	%v31, %v2, %v0)
	vpdi	%v30, %v4, %v4, 4
	FIXCY	%v31, %v31, %v31
	vsrd	%v6,  %v31, %v4, 1
	vsteg	%v6,  0(rp), 0
	vlgvg	%r2,  %v30, 1
	risbg	%r2,  %r2, 63, 128+63, 0
	br	%r14

L(5):	vsrd	%v6,  %v5, %v4, 1
	vsteg	%v6, 0(rp), 0
	j	L(e2)

L(bx0):	tmll	n, 2
	je	L(b00)
L(b10):	lghi	idx, 0
	vlerg	%v0,  0(bp)
	vlerg	%v2,  0(ap)
	clgije	n, 2, L(2)
	vlerg	%v1,  16(bp)
	vlerg	%v3,  16(ap)
	ASR(	%v4,  %v2, %v0)
	ASCO(	%v31, %v2, %v0)
	vlr	%v30, %v4
	vlerg	%v0,  32(bp)
	vlerg	%v2,  32(ap)
	ASRCI(	%v5,  %v3, %v1, %v31)
	ASCIO(	%v31, %v3, %v1, %v31)
	brctg	%r0,  L(top)
	j	L(end)

L(2):	ASR(	%v4,  %v2, %v0)
	ASCO(	%v31, %v2, %v0)
	vlr	%v30, %v4
	FIXCY	%v31, %v31, %v31
	vsrd	%v6,  %v31, %v4, 1
	vsterg	%v6,  0(rp)
	vlgvg	%r2,  %v30, 1
	risbg	%r2,  %r2, 63, 128+63, 0
	br	%r14

L(b00):	lghi	idx, -16
	vlerg	%v1,  0(bp)
	vlerg	%v3,  0(ap)
	vlerg	%v0,  16(bp)
	vlerg	%v2,  16(ap)
	ASR(	%v5,  %v3, %v1)
	ASCO(	%v31, %v3, %v1)
	vlr	%v30, %v5
	clgije	%r0, 0, L(e2)
	vlerg	%v1,  32(bp)
	vlerg	%v3,  32(ap)
	ASRCI(	%v4,  %v2, %v0, %v31)
	ASCIO(	%v31, %v2, %v0, %v31)
	j	L(mid)

	ALIGN(64)
L(top):	vlerg	%v1,  48(idx,bp)
	vlerg	%v3,  48(idx,ap)
	vsrd	%v6,  %v5, %v4, 1
	vsterg	%v6,  0(idx,rp)
	ASRCI(	%v4,  %v2, %v0, %v31)
	ASCIO(	%v31, %v2, %v0, %v31)
L(mid):	vlerg	%v0,  64(idx,bp)
	vlerg	%v2,  64(idx,ap)
	vsrd	%v7,  %v4, %v5, 1
	vsterg	%v7,  16(idx,rp)
	ASRCI(	%v5,  %v3, %v1, %v31)
	ASCIO(	%v31, %v3, %v1, %v31)
	la	idx,  32(idx)
	brctg	%r0,  L(top)

L(end):	vsrd	%v6,  %v5, %v4, 1
	vsterg	%v6,  0(idx,rp)
L(e2):	ASRCI(	%v4,  %v2, %v0, %v31)
	ASCIO(	%v31, %v2, %v0, %v31)
	vsrd	%v7,  %v4, %v5, 1
	vsterg	%v7,  16(idx,rp)
	FIXCY	%v31, %v31, %v31
	vsrd	%v6,  %v31, %v4, 1
	vsterg	%v6,  32(idx,rp)
	vlgvg	%r2,  %v30, 1
	risbg	%r2,  %r2, 63, 128+63, 0
	br	%r14
EPILOGUE()
	.section .note.GNU-stack
