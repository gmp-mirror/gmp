dnl  Loongarch mpn_addmul_1 and mpn_submul_1

dnl  Contributed to the GNU project by Torbjorn Granlund.

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

C INPUT PARAMETERS
define(`rp_arg',`$r4')
define(`ap',	`$r5')
define(`n',	`$r6')
define(`b0',	`$r7')

define(`rp',	`$r8')

ifdef(`OPERATION_addmul_1',`
    define(`ADDSUB',	`add.d')
    define(`CMPCY',	`sltu	$1, $2, $3')
    define(`func',	`mpn_addmul_1')
')
ifdef(`OPERATION_submul_1',`
    define(`ADDSUB',	`sub.d')
    define(`CMPCY',	`sltu	$1, $3, $2')
    define(`func',	`mpn_submul_1')
')

MULFUNC_PROLOGUE(mpn_addmul_1 mpn_submul_1)

ASM_START()
PROLOGUE(func)
	alsl.d	rp, n, rp_arg, 3
	alsl.d	ap, n, ap, 3
	sub.d	n, $r0, n
	slli.d	n, n, 3
	or	$r4, $r0, $r0

L(top):	ldx.d	$r13, ap, n
	mul.d	$r17, $r13, b0
	mulh.du	$r13, $r13, b0
	ldx.d	$r12, rp, n
	ADDSUB	$r17, $r12, $r17
	CMPCY(	$r12, $r17, $r12)
	ADDSUB	$r4, $r17, $r4		C cycle 0, 3, ...
	add.d	$r12, $r12, $r13
	CMPCY(	$r17, $r4, $r17)	C cycle 1, 4, ...
	stx.d	$r4, rp, n
	addi.d	n, n, 8			C bookkeeping
	add.d	$r4, $r12, $r17		C cycle 2, 5, ...
	bnez	n, L(top)

	jr	$r1
EPILOGUE()
