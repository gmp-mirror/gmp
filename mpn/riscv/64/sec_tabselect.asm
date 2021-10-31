dnl  RISC-V/64 mpn_sec_tabselect

dnl  Copyright 2021 Free Software Foundation, Inc.

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

dnl This is compiler output, mildly edited.  We don't expect this to be faster
dnl than the C fallback code, but providing this in assembly avoids problems
dnl with compilers which generate side channel leaky code.

define(`rp',	`a0')
define(`tp',	`a1')
define(`n',	`a2')
define(`nents',	`a3')
define(`which',	`a4')

ASM_START()
PROLOGUE(mpn_sec_tabselect)
	slli	n, n, 3
	add	t4, a0, n

L(cpy):	ld	a7, 0(tp)
	addi	tp, tp, 8
	addi	rp, rp, 8
	sd	a7, -8(rp)
	bne	rp, t4, L(cpy)

	li	t5, 1
	ble	nents, t5, L(ret)

L(outer):
	xor	t3, which, t5
	neg	t3, t3
	srai	t3, t3, 63
	sub	rp, rp, n

L(top):	ld	a5, 0(rp)
	ld	t1, 0(tp)
	addi	rp, rp, 8
	addi	tp, tp, 8
	xor	a5, a5, t1
	and	a5, a5, t3
	xor	a5, a5, t1
	sd	a5, -8(rp)
	bne	t4, rp, L(top)

	addi	t5, t5, 1
	bne	nents, t5, L(outer)

L(ret):	ret
EPILOGUE()
