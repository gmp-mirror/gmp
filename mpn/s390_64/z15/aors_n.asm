dnl  S/390-64 mpn_add_n and mpn_sub_n.

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
C z15		 ?

define(`rp',	`%r2')
define(`ap',	`%r3')
define(`bp',	`%r4')
define(`n',	`%r5')

define(`idx',	`%r1')

ifdef(`OPERATION_add_n', `
  define(ASR,  `vaq')
  define(ASCO, `vaccq')
  define(ASRCI,`vacq')
  define(ASCIO,`vacccq')
  define(CLCREG,vzero)
  define(RETVAL,`dnl
	vlgvg	%r2, %v31, 1')
  define(CNEG,`dnl')
  define(`func_n',	mpn_add_n)')

ifdef(`OPERATION_sub_n', `
  define(ASR,  `vsq')
  define(ASCO, `vscbiq')
  define(ASRCI,`vsbiq')
  define(ASCIO,`vsbcbiq')
  define(CLCREG,vone)
  define(RETVAL,`dnl
	vlgvg	%r2, %v31, 1
	xilf	%r2, 1')
  define(CNEG,`lcgr')
  define(`func_n',	mpn_sub_n)')

MULFUNC_PROLOGUE(mpn_add_n mpn_sub_n)

ASM_START()
PROLOGUE(func_n)
	srlg	%r0, n, 2
	CLCREG	%v31
	lghi	idx, 0

	tmll	n, 2
	je	L(b0x)
L(b1x):	vlerg	%v0, 0(ap)
	vlerg	%v2, 0(bp)
	ASR	%v4, %v0, %v2
	ASCO	%v31, %v0, %v2
	vsterg	%v4, 0(rp)
	lghi	idx, 16
L(b0x):	clgije	%r0, 0, L(end)

L(top):	vlerg	%v0,  0(idx,ap)
	vlerg	%v1,  16(idx,ap)
	vlerg	%v2,  0(idx,bp)
	vlerg	%v3,  16(idx,bp)
	ASRCI	%v4, %v0, %v2, %v31
	ASCIO	%v31, %v0, %v2, %v31
	ASRCI	%v5, %v1, %v3, %v31
	ASCIO	%v31, %v1, %v3, %v31
	vsterg	%v4, 0(idx,rp)
	vsterg	%v5, 16(idx,rp)
	la	idx,  32(idx)
	brctg	%r0,  L(top)

L(end):	tmll	n, 1
	je	L(ret)
	vzero	%v0
	vzero	%v2
	vleg	%v0, 0(idx,ap), 1
	vleg	%v2, 0(idx,bp), 1
	ASRCI	%v4, %v0, %v2, %v31
	vsteg	%v4, 0(idx,rp), 1
	vlgvg	%r2, %v4, 0
	CNEG	%r2, %r2
	br	%r14

L(ret):	RETVAL
	br	%r14
EPILOGUE()
	.section .note.GNU-stack
