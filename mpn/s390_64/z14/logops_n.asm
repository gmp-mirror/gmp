dnl  S/390-64 logops.

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

C cycles/limb
C z900		 -
C z990		 -
C z9		 -
C z10		 -
C z196		 -
C z12		 -
C z13		 -
C z14		 ?
C z15		 ?

C Most functions here run on z13, except the ones which use vnn, voc, and vnx.

define(`rp',	`%r2')
define(`ap',	`%r3')
define(`bp',	`%r4')
define(`n',	`%r5')

ifdef(`OPERATION_and_n',`
  define(`func',`mpn_and_n')
  define(`LOGOP',`vn')')
ifdef(`OPERATION_andn_n',`
  define(`func',`mpn_andn_n')
  define(`LOGOP',`vnc')')
ifdef(`OPERATION_nand_n',`
  define(`func',`mpn_nand_n')
  define(`LOGOP',`vnn')')
ifdef(`OPERATION_ior_n',`
  define(`func',`mpn_ior_n')
  define(`LOGOP',`vo')')
ifdef(`OPERATION_iorn_n',`
  define(`func',`mpn_iorn_n')
  define(`LOGOP',`voc')')
ifdef(`OPERATION_nior_n',`
  define(`func',`mpn_nior_n')
  define(`LOGOP',`vno')')
ifdef(`OPERATION_xor_n',`
  define(`func',`mpn_xor_n')
  define(`LOGOP',`vx')')
ifdef(`OPERATION_xnor_n',`
  define(`func',`mpn_xnor_n')
  define(`LOGOP',`vnx')')

MULFUNC_PROLOGUE(mpn_and_n mpn_andn_n mpn_nand_n mpn_ior_n mpn_iorn_n mpn_nior_n mpn_xor_n mpn_xnor_n)

ASM_START()
PROLOGUE(func)
	srlg	%r0, n, 2

	tmll	n, 2
	je	L(b0x)
L(b1x):	vl	%v1, 0(bp), 3
	vl	%v3, 0(ap), 3
	LOGOP	%v7, %v3, %v1
	vst	%v7, 0(rp), 3
	la	ap, 16(ap)
	la	bp, 16(bp)
	la	rp, 16(rp)
L(b0x):	clgije	%r0, 0, L(end)

L(top):	vl	%v0, 0(ap), 3
	vl	%v1, 16(ap), 3
	la	ap, 32(ap)
	vl	%v2, 0(bp), 3
	vl	%v3, 16(bp), 3
	la	bp, 32(bp)
	LOGOP	%v16, %v0, %v2
	LOGOP	%v17, %v1, %v3
	vst	%v16, 0(rp), 3
	vst	%v17, 16(rp), 3
	la	rp, 32(rp)
	brctg	%r0, L(top)

L(end):	tmll	n, 1
	je	L(ret)
	vllezg	%v1, 0(bp)
	vllezg	%v3, 0(ap)
	LOGOP	%v7, %v3, %v1
	vsteg	%v7, 0(rp), 0
L(ret):	br	%r14
EPILOGUE()
	.section .note.GNU-stack
