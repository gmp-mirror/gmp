dnl  S/390-64 mpn_mul_basecase.

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
define(`rp',	`%r2')
define(`up',	`%r3')
define(`un',	`%r4')
define(`vp',	`%r5')
define(`vn_arg',`%r6')

define(`vn',    `%r13')

define(`idx',	`%r14')
define(`v0',	`%r11')
define(`v1',	`%r12')

define(`MUL_1',`
pushdef(`L',
defn(`L')$1`'_m1)

	vzero	%v29
	lghi	%r9, 0
	tmll	un, 1
	srlg	un, un, 1
	je	L(evn)
L(odd):	lg	%r7, 0(up)
	mlgr	%r6, v0			C W1 W0
	stg	%r7, 0(rp)
	lghi	idx, 8
	clgije	un, 0, L(end)		C FIXME: Done, return!
	j	L(top)
L(evn):	lghi	%r6, 0
	lghi	idx, 0

L(top):	lgr	%r9, %r6
	lg	%r1, 0(idx, up)
	lg	%r7, 8(idx, up)
	mlgr	%r0, v0			C W1 W0
	mlgr	%r6, v0			C W2 W1
	vlvgp	%v23, %r0, %r1		C W1 W0
	vlvgp	%v21, %r7, %r9		C W1 W0
	vacq	%v20, %v23, %v21, %v29	C
	vacccq	%v29, %v23, %v21, %v29	C	carry critical path 3
	vpdi	%v20, %v20, %v20, 4
	vst	%v20, 0(idx, rp), 3
	la	idx, 16(idx)
	brctg	un, L(top)

L(end):	vlgvg	%r7, %v29, 1
	algr	%r6, %r7
	stg	%r6, 0(idx, rp)
popdef(`L')
')

define(`MUL_2',`
pushdef(`L',
defn(`L')$1`'_m2)
	vzero	%v27
	vzero	%v28
	vzero	%v29
	vzero	%v30
	lghi	%r10, 0
	lg	v0, 0(vp)
	lg	v1, 8(vp)
	tmll	un, 1
	srlg	un, un, 1
	je	L(evn)

L(odd):	lg	%r7, 0(up)
	mlgr	%r6, v0			C W2 W1
	lg	%r1, 0(up)
	stg	%r7, 0(rp)
	lghi	idx, 8
dnl	clgije	un, 0, L(end)
	j	L(top)

L(evn):	lghi	%r6, 0
	lghi	idx, 0
	lghi	%r1, 0

L(top):	lg	%r9, 0(idx, up)
	mlgr	%r0, v1			C W2 W1
	mlgr	%r8, v1			C W3 W2
	vlvgp	%v22, %r0, %r1		C W2 W1
	vlvgp	%v23, %r9, %r6		C W2 W1
	lg	%r1, 0(idx, up)
	lg	%r7, 8(idx, up)
	mlgr	%r0, v0			C W2 W1
	mlgr	%r6, v0			C W3 W2
	vlvgp	%v20, %r0, %r1		C W2 W1
	vlvgp	%v21, %r7, %r10		C W2 W1
	vacq	%v24, %v22, %v23, %v27	C
	vacccq	%v27, %v22, %v23, %v27	C	carry critical path 1
	vacq	%v23, %v24, %v20, %v28	C
	vacccq	%v28, %v24, %v20, %v28	C	carry critical path 2
	vacq	%v20, %v23, %v21, %v29	C
	vacccq	%v29, %v23, %v21, %v29	C	carry critical path 3
	vpdi	%v20, %v20, %v20, 4
	lg	%r1, 8(idx, up)
	vst	%v20, 0(idx, rp), 3
	lgr	%r10, %r8
	la	idx, 16(idx)
	brctg	un, L(top)

L(end):	mlgr	%r0, v1
	algr	%r1, %r6
	alcgr	%r0, un
	algr	%r1, %r8
	alcgr	%r0, un
	vag	%v27, %v27, %v28
	vag	%v29, %v29, %v30
	vag	%v27, %v27, %v29
	vlgvg	%r10, %v27, 1
	algr	%r1, %r10
	stg	%r1, 0(idx, rp)
	alcgr	%r0, un
	stg	%r0, 8(idx, rp)
popdef(`L')
')

define(`ADDMUL_2',`
pushdef(`L',
defn(`L')$1`'_am2)
	vzero	%v27
	vzero	%v28
	vzero	%v29
	vzero	%v30
	lghi	%r10, 0
	lg	v0, 0(vp)
	lg	v1, 8(vp)
	tmll	un, 1
	srlg	un, un, 1
	je	L(evn)

L(odd):	lg	%r7, 0(up)
	mlgr	%r6, v0			C W2 W1
	alg	%r7, 0(rp)
	alcgr	%r6, %r10
	stg	%r7, 0(rp)
	lghi	idx, 8
dnl	clgije	un, 0, L(end)
	j	L(top)

L(evn):	lghi	%r6, 0
	lghi	idx, 0
	lghi	%r1, 0
	j	L(ent)

L(top):	lg	%r1, -8(idx, up)
L(ent):	lg	%r9, 0(idx, up)
	mlgr	%r0, v1			C W2 W1
	mlgr	%r8, v1			C W3 W2
	vlvgp	%v22, %r0, %r1		C W2 W1
	vlvgp	%v23, %r9, %r6		C W2 W1
	lg	%r1, 0(idx, up)
	lg	%r7, 8(idx, up)
	mlgr	%r0, v0			C W2 W1
	mlgr	%r6, v0			C W3 W2
	vlvgp	%v20, %r0, %r1		C W2 W1
	vlvgp	%v21, %r7, %r10		C W2 W1
	vacq	%v24, %v22, %v23, %v27	C
	vacccq	%v27, %v22, %v23, %v27	C	carry critical path 1
	vacq	%v23, %v24, %v20, %v28	C
	vacccq	%v28, %v24, %v20, %v28	C	carry critical path 2
	vacq	%v24, %v23, %v21, %v29	C
	vacccq	%v29, %v23, %v21, %v29	C	carry critical path 3
	vl	%v16, 0(idx, rp), 3
	vpdi	%v16, %v16, %v16, 4
	vacq	%v20, %v24, %v16, %v30	C
	vacccq	%v30, %v24, %v16, %v30	C	carry critical path 4
	vpdi	%v20, %v20, %v20, 4
	vst	%v20, 0(idx, rp), 3
	lgr	%r10, %r8
	la	idx, 16(idx)
	brctg	un, L(top)

L(end):	lg	%r1, -8(idx, up)
	mlgr	%r0, v1
	algr	%r1, %r6
	alcgr	%r0, un
	algr	%r1, %r8
	alcgr	%r0, un
	vag	%v27, %v27, %v28
	vag	%v29, %v29, %v30
	vag	%v27, %v27, %v29
	vlgvg	%r10, %v27, 1
	algr	%r1, %r10
	stg	%r1, 0(idx, rp)
	alcgr	%r0, un
	stg	%r0, 8(idx, rp)
popdef(`L')
')


ASM_START()

PROLOGUE(mpn_mul_basecase)
	stmg	%r4, %r14, 32(%r15)
	lgr	vn, vn_arg

	tmll	vn, 1
	je	L(vn_evn)
L(vn_odd):
	lg	v0, 0(vp)
	MUL_1()
	lay	vp, -8(vp)
	lay	rp, -8(rp)
	j	L(join)
L(vn_evn):
	MUL_2()
	lay	vn, -2(vn)
L(join):
	srlg	vn, vn, 1
	cgije	vn, 0, L(oend)
L(otop):
	lg	un, 32(%r15)
	la	rp, 16(rp)
	la	vp, 16(vp)
	ADDMUL_2()
	brctg	vn, L(otop)
L(oend):

	lmg	%r6, %r14, 48(%r15)
	br	%r14
EPILOGUE()
