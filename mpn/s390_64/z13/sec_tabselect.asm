dnl  S/390-64 mpn_sec_tabselect

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

C            cycles/limb
C z900		 -
C z990		 -
C z9		 -
C z10		 -
C z196		 -
C z12		 -
C z13		 ?
C z14		 ?
C z15		0.7

dnl void
dnl mpn_sec_tabselect (volatile mp_limb_t *rp, volatile const mp_limb_t *tab,
dnl                    mp_size_t n, mp_size_t nents, mp_size_t which)

define(`rp',	`%r2')
define(`tp',	`%r3')
define(`n',	`%r4')
define(`nents',	`%r5')
define(`which_arg',`%r6')

define(`mask',	`%v19')
define(`k',	`%r1')
define(`which',	`%v16')
define(`vones',	`%v17')
define(`idx',	`%v18')

define(`FRAME', 64)

ASM_START()
PROLOGUE(mpn_sec_tabselect)
	stmg	%r6, %r9, 48(%r15)

	lghi	%r0, 1
	vlvgp	vones, %r0, %r0
	vlvgp	which, which_arg, which_arg

	sllg	n, n, 3
	lcgr	%r8, nents
	msgr	%r8, n

	srlg	%r7, n, 3+3
	cgije	%r7, 0, L(lt8)
L(outer):
	vzero	idx
	lgr	k, nents
	vlm	%v4, %v7, 0(tp)
	j	L(md8)
L(tp8):	vag	idx, idx, vones
	vceqg	mask, idx, which
	vlm	%v0, %v3, 0(tp)
	vsel	%v4, %v0, %v4, mask
	vsel	%v5, %v1, %v5, mask
	vsel	%v6, %v2, %v6, mask
	vsel	%v7, %v3, %v7, mask
L(md8):	la	tp, 0(n,tp)
	brctg	k, L(tp8)
	vstm	%v4, %v7, 0(rp)
	la	rp, 64(rp)
	la	tp, eval(8*8)(%r8,tp)
	brctg	%r7, L(outer)
L(lt8):
	tmll	n, 32
	je	L(end4)
	vzero	idx
	lgr	k, nents
	vl	%v4, 0(tp), 3
	vl	%v5, 16(tp), 3
	j	L(md4)
L(tp4):	vag	idx, idx, vones
	vceqg	mask, idx, which
	vl	%v0, 0(tp), 3
	vl	%v1, 16(tp), 3
	vsel	%v4, %v0, %v4, mask
	vsel	%v5, %v1, %v5, mask
L(md4):	la	tp, 0(n,tp)
	brctg	k, L(tp4)
	vst	%v4, 0(rp), 3
	vst	%v5, 16(rp), 3
	la	rp, 32(rp)
	la	tp, eval(4*8)(%r8,tp)
L(end4):
	tmll	n, 16
	je	L(end2)
	vzero	idx
	lgr	k, nents
	vl	%v6, 0(tp), 3
	j	L(md2)
L(tp2):	vag	idx, idx, vones
	vceqg	mask, idx, which
	vl	%v0, 0(tp), 3
	vsel	%v6, %v0, %v6, mask
L(md2):	la	tp, 0(n,tp)
	brctg	k, L(tp2)
	vst	%v6, 0(rp), 3
	la	rp, 16(rp)
	la	tp, eval(2*8)(%r8,tp)
L(end2):
	tmll	n, 8
	je	L(end1)
	vzero	idx
	lgr	k, nents
	vleg	%v6, 0(tp), 1
	j	L(md1)
L(tp1):	vag	idx, idx, vones
	vceqg	mask, idx, which
	vleg	%v0, 0(tp), 1
	vsel	%v6, %v0, %v6, mask
L(md1):	la	tp, 0(n,tp)
	brctg	k, L(tp1)
	vsteg	%v6, 0(rp), 1
L(end1):
	lmg	%r6, %r9, 48(%r15)
	br	%r14
EPILOGUE()
