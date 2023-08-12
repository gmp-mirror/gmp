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
C z15		1.5-1.7

define(`cnd',	`%r2')
define(`rp',	`%r3')
define(`ap',	`%r4')
define(`bp',	`%r5')
define(`n',	`%r6')

define(`idx', `%r1')

ifdef(`OPERATION_cnd_add_n', `
  define(ASR,  `vaq    $1, $2, $3')
  define(ASCO, `vaccq  $1, $2, $3')
  define(ASRCI,`vacq   $1, $2, $3, $4')
  define(ASCIO,`vacccq $1, $2, $3, $4')
  define(CLCREG,vzero)
  define(RETVAL,`dnl
	vlgvg	%r2, %v31, 1')
  define(`func_n',	mpn_cnd_add_n)')

ifdef(`OPERATION_cnd_sub_n', `
  define(ASR,  `vsq	$1, $2, $3')
  define(ASCO, `vscbiq	$1, $2, $3')
  define(ASRCI,`vsbiq	$1, $2, $3, $4')
  define(ASCIO,`vsbcbiq	$1, $2, $3, $4')
  define(CLCREG,vone)
  define(RETVAL,`dnl
	vlgvg	%r2, %v31, 1
	xilf	%r2, 1')
  define(`func_n',	mpn_cnd_sub_n)')

MULFUNC_PROLOGUE(mpn_cnd_add_n mpn_cnd_sub_n)

ASM_START()
PROLOGUE(func_n)
	lghi	%r0, 0
	slgr	%r0, cnd
	slbgr	cnd, cnd
	vlvgp	%v30, cnd, cnd

	srlg	%r0, n, 2
	tmll	n, 1
	je	L(bx0)
L(bx1):	tmll	n, 2
	vllezg	%v1, 0(bp)
	vn	%r5, %r1, %v30
	vllezg	%v3, 0(ap)
	ASR(	%v7, %v3, %v5)
	ASCO(	%v31, %v3, %v5)
	vsteg	%v7, 0(rp), 0
	je	L(b01)
L(b11):	vlerg	%v1, 8(bp)
	vn	%r5, %r1, %v30
	vlerg	%v3, 8(ap)
	ASRCI(	%v7, %v3, %v5, %v31)
	ASCIO(	%v31, %v3, %v5, %v31)
	vsterg	%v7, 8(rp)
	clgije	%r0, 0, L(end)
	lghi	idx, 24
	j	L(top)
L(b01):	clgije	%r0, 0, L(end)
	lghi	idx, 8
	j	L(top)
L(bx0):	tmll	n, 2
	je	L(b00)
L(b10):	vlerg	%v1, 0(bp)
	vn	%r5, %r1, %v30
	vlerg	%v3, 0(ap)
	ASR(	%v7, %v3, %v5)
	ASCO(	%v31, %v3, %v5)
	vsterg	%v7, 0(rp)
	clgije	%r0, 0, L(end)
	lghi	idx, 16
	j	L(top)
L(b00):	CLCREG	%v31
	lghi	idx, 0

L(top):	vlerg	%v0,  0(idx,bp)
	vlerg	%v1,  16(idx,bp)
	vn	%v4,  %v0, %v30
	vn	%v5,  %v1, %v30
	vlerg	%v2,  0(idx,ap)
	vlerg	%v3,  16(idx,ap)
	ASRCI(	%v6,  %v2, %v4, %v31)
	ASCIO(	%v31, %v2, %v4, %v31)
	ASRCI(	%v7,  %v3, %v5, %v31)
	ASCIO(	%v31, %v3, %v5, %v31)
	vsterg	%v6,  0(idx,rp)
	vsterg	%v7,  16(idx,rp)
	la	idx,  32(idx)
	brctg	%r0,  L(top)

L(end):	RETVAL
	br	%r14
EPILOGUE()
	.section .note.GNU-stack
