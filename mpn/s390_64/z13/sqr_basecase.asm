dnl  S/390-64 mpn_sqr_basecase for z13 and later.

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

dnl TODO
dnl  * The code at L(c2) could be greatly improved by accumulating using v
dnl    registers, also avoiding using memory as rewritten scratch.
dnl  * We could unroll the outer loop 4x, using 4 different, streamlined
dnl    ADDMUL_1C blocks (without the tmll nonsense).

define(`rp',	`%r2')
define(`ap',	`%r3')
define(`an',	`%r4')

define(`idx',	`%r5')
define(`b0',	`%r10')

ifdef(`HAVE_HOST_CPU_z15',`define(`HAVE_vler',1)')
ifdef(`HAVE_HOST_CPU_z16',`define(`HAVE_vler',1)')
ifdef(`HAVE_vler',`
define(`vpdi', `dnl')
',`
define(`vler', `vl')
define(`vster', `vst')
')

define(`MUL_1C',`
pushdef(`L',
defn(`L')$1`'_m1)
	vzero	%v2
	srlg	%r11, an, 2

	tmll	an, 1
	je	L(bx0)
L(bx1):	tmll	an, 2
	jne	L(b11)

L(b01):	lghi	idx, -24
	lg	%r7, 0(ap)
	mlgr	%r6, b0
	algr	%r7, %r0
	lghi	%r0, 0
	alcgr	%r6, %r0
	stg	%r7, 0(rp)
	j	L(cj0)

L(b11):	lghi	idx, -8
	lg	%r9, 0(ap)
	mlgr	%r8, b0
	algr	%r9, %r0
	lghi	%r0, 0
	alcgr	%r8, %r0
	stg	%r9, 0(rp)
	j	L(cj1)

L(bx0):	tmll	an, 2
	jne	L(b10)

L(b00):	lghi	idx, -32
	lgr	%r6, %r0
L(cj0):	lg	%r1, 32(idx, ap)
	lg	%r9, 40(idx, ap)
	mlgr	%r0, b0
	mlgr	%r8, b0
	vlvgp	%v6, %r0, %r1
	vlvgp	%v7, %r9, %r6
	j	L(mid)

L(b10):	lghi	idx, -16
	lgr	%r8, %r0
L(cj1):	lg	%r1, 16(idx, ap)
	lg	%r7, 24(idx, ap)
	mlgr	%r0, b0
	mlgr	%r6, b0
	vlvgp	%v6, %r0, %r1
	vlvgp	%v7, %r7, %r8
	cgije	%r11, 0, L(end)

L(top):	lg	%r1, 32(idx, ap)
	lg	%r9, 40(idx, ap)
	mlgr	%r0, b0
	mlgr	%r8, b0
	vacq	%v3, %v6, %v7, %v2
	vacccq	%v2, %v6, %v7, %v2
	vpdi	%v3, %v3, %v3, 4
	vster	%v3, 16(idx, rp), 3
	vlvgp	%v6, %r0, %r1
	vlvgp	%v7, %r9, %r6
L(mid):	lg	%r1, 48(idx, ap)
	lg	%r7, 56(idx, ap)
	mlgr	%r0, b0
	mlgr	%r6, b0
	vacq	%v3, %v6, %v7, %v2
	vacccq	%v2, %v6, %v7, %v2
	vpdi	%v3, %v3, %v3, 4
	vster	%v3, 32(idx, rp), 3
	vlvgp	%v6, %r0, %r1
	vlvgp	%v7, %r7, %r8
	la	idx, 32(idx)
	brctg	%r11, L(top)

L(end):	vacq	%v3, %v6, %v7, %v2
	vacccq	%v2, %v6, %v7, %v2
	vpdi	%v3, %v3, %v3, 4
	vster	%v3, 16(idx, rp), 3

	vlgvg	%r0, %v2, 1
	algr	%r0, %r6
	stg	%r0, 32(idx, rp)
popdef(`L')
')

define(`ADDMUL_1C',`
pushdef(`L',
defn(`L')$1`'_am1)
	vzero	%v0
	vzero	%v2
	srlg	%r11, an, 2

	tmll	an, 1
	je	L(bx0)
L(bx1):	vleg	%v2, 0(rp), 1
	vzero	%v4
	tmll	an, 2
	jne	L(b11)

L(b01):	lghi	idx, -24
	lg	%r7, 0(ap)
	mlgr	%r6, b0
	algr	%r7, %r0
	lghi	%r0, 0
	alcgr	%r6, %r0
	vlvgg	%v4, %r7, 1
	vaq	%v2, %v2, %v4
	vsteg	%v2, 0(rp), 1
	vmrhg	%v2, %v2, %v2
	j	L(cj0)

L(b11):	lghi	idx, -8
	lg	%r9, 0(ap)
	mlgr	%r8, b0
	algr	%r9, %r0
	lghi	%r0, 0
	alcgr	%r8, %r0
	vlvgg	%v4, %r9, 1
	vaq	%v2, %v2, %v4
	vsteg	%v2, 0(rp), 1
	vmrhg	%v2, %v2, %v2
	j	L(cj1)

L(bx0):	tmll	an, 2
	jne	L(b10)

L(b00):	lghi	idx, -32
	lgr	%r6, %r0
L(cj0):	lg	%r1, 32(idx, ap)
	lg	%r9, 40(idx, ap)
	mlgr	%r0, b0
	mlgr	%r8, b0
	vler	%v1, 32(idx, rp), 3
	vpdi	%v1, %v1, %v1, 4
	vlvgp	%v6, %r0, %r1
	vlvgp	%v7, %r9, %r6
	j	L(mid)

L(b10):	lghi	idx, -16
	lgr	%r8, %r0
L(cj1):	lg	%r1, 16(idx, ap)
	lg	%r7, 24(idx, ap)
	mlgr	%r0, b0
	mlgr	%r6, b0
	vler	%v1, 16(idx, rp), 3
	vpdi	%v1, %v1, %v1, 4
	vlvgp	%v6, %r0, %r1
	vlvgp	%v7, %r7, %r8
	cgije	%r11, 0, L(end)

L(top):	lg	%r1, 32(idx, ap)
	lg	%r9, 40(idx, ap)
	mlgr	%r0, b0
	mlgr	%r8, b0
	vacq	%v5, %v6, %v1, %v0
	vacccq	%v0, %v6, %v1, %v0
	vacq	%v3, %v5, %v7, %v2
	vacccq	%v2, %v5, %v7, %v2
	vpdi	%v3, %v3, %v3, 4
	vler	%v1, 32(idx, rp), 3
	vpdi	%v1, %v1, %v1, 4
	vster	%v3, 16(idx, rp), 3
	vlvgp	%v6, %r0, %r1
	vlvgp	%v7, %r9, %r6
L(mid):	lg	%r1, 48(idx, ap)
	lg	%r7, 56(idx, ap)
	mlgr	%r0, b0
	mlgr	%r6, b0
	vacq	%v5, %v6, %v1, %v0
	vacccq	%v0, %v6, %v1, %v0
	vacq	%v3, %v5, %v7, %v2
	vacccq	%v2, %v5, %v7, %v2
	vpdi	%v3, %v3, %v3, 4
	vler	%v1, 48(idx, rp), 3
	vpdi	%v1, %v1, %v1, 4
	vster	%v3, 32(idx, rp), 3
	vlvgp	%v6, %r0, %r1
	vlvgp	%v7, %r7, %r8
	la	idx, 32(idx)
	brctg	%r11, L(top)

L(end):	vacq	%v5, %v6, %v1, %v0
	vacccq	%v0, %v6, %v1, %v0
	vacq	%v3, %v5, %v7, %v2
	vacccq	%v2, %v5, %v7, %v2
	vpdi	%v3, %v3, %v3, 4
	vster	%v3, 16(idx, rp), 3

	vag	%v2, %v0, %v2
	vlgvg	%r0, %v2, 1
	algr	%r0, %r6
	stg	%r0, 32(idx, rp)
popdef(`L')
')

ASM_START()

PROLOGUE(mpn_sqr_basecase)
	clgijle	an, 2, L(sma)

	stmg	%r6,%r12,48(%r15)

	lg	%r1, 0(ap)
	sllg	b0, %r1, 1
	mlgr	%r0, %r1
	stg	%r1, 0(rp)
	la	rp, 8(rp)
	aghi	an, -1
	lg	%r12, 0(ap)
	la	ap, 8(ap)
	MUL_1C()
	j	L(ent)

L(top):	la	ap, 8(ap)
	ADDMUL_1C()
L(ent):	lg	%r1, 0(ap)
	srag	%r6, %r12, 63
	srlg	b0, %r12, 63
	lgr	%r12, %r1
	rosbg	b0, %r1, 0, 62, 1
	mlgr	%r0, %r1
	ngr	%r6, %r12
	alg	%r6, 8(rp)
	lghi	%r9, 0
	alcgr	%r0, %r9
	algr	%r6, %r1
	alcgr	%r0, %r9
	stg	%r6, 8(rp)
	la	rp, 16(rp)
	aghi	an, -1
	clgijh	an, 2, L(top)

L(c2):	clgije	an, 1, L(c1)
	la	ap, 8(ap)
	lgr	%r8, %r0
	lg	%r1, 0(ap)
	lg	%r7, 8(ap)
	mlgr	%r0, b0
	mlgr	%r6, b0
	vler	%v1, 0(rp), 3
	vpdi	%v1, %v1, %v1, 4
	vlvgp	%v6, %r0, %r1
	vlvgp	%v7, %r7, %r8
	vaq	%v5, %v6, %v1
	vaccq	%v0, %v6, %v1
	vaq	%v3, %v5, %v7
	vaccq	%v2, %v5, %v7
	vpdi	%v3, %v3, %v3, 4
	vster	%v3, 0(rp), 3
	vag	%v2, %v0, %v2
	vlgvg	%r0, %v2, 1
	algr	%r0, %r6
	stg	%r0, 16(rp)
	lg	%r1, 0(ap)
	srag	%r6, %r12, 63
	srlg	b0, %r12, 63
	lgr	%r12, %r1
	rosbg	b0, %r1, 0, 62, 1
	mlgr	%r0, %r1
	ngr	%r6, %r12
	alg	%r6, 8(rp)
	alcgr	%r0, %r9
	algr	%r6, %r1
	alcgr	%r0, %r9
	stg	%r6, 8(rp)
	la	rp, 16(rp)

L(c1):	lg	%r5, 8(ap)
	lgr	%r1, %r5
	mlgr	%r4, b0
	algr	%r5, %r0
	alcgr	%r4, %r9
	alg	%r5, 0(rp)
	alcgr	%r4, %r9
	stg	%r5, 0(rp)
	srag	%r6, %r12, 63
	ngr	%r6, %r1
	mlgr	%r0, %r1
	algr	%r6, %r4
	alcgr	%r0, %r9
	algr	%r6, %r1
	alcgr	%r0, %r9
	stg	%r6, 8(rp)
	stg	%r0, 16(rp)
	lmg	%r6,%r12,48(%r15)
	br	%r14

L(sma):	clgijh	an, 1, L(2)
L(1):	lg	%r1, 0(ap)
	mlgr	%r0, %r1
	stg	%r1, 0(rp)
	stg	%r0, 8(rp)
	br	%r14

L(2):	lg	%r1, 0(ap)
	mlgr	%r0, %r1
	stg	%r1, 0(rp)
	lg	%r1, 0(ap)
	lg	%r5, 8(ap)
	mlgr	%r4, %r1
	algr	%r5, %r5
	alcgr	%r4, %r4
	lg	%r1, 8(ap)
	lghi	%r3, 0
	alcgr	%r3, %r3
	algr	%r5, %r0
	stg	%r5, 8(rp)
	mlgr	%r0, %r1
	alcgr	%r4, %r1
	stg	%r4, 16(rp)
	alcgr	%r0, %r3
	stg	%r0, 24(rp)
	br	%r14
EPILOGUE()
