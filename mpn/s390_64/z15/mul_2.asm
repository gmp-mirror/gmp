dnl  S/390-64 mpn_mul_2

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
C z10		 ?
C z196		 ?
C z12		 ?
C z13		 ?
C z14		 ?
C z15		 2.0


define(`rp',	`%r2')
define(`ap',	`%r3')
define(`an',	`%r4')
define(`bp',	`%r5')

define(`idx',	`%r5')
define(`b0',	`%r10')
define(`b1',	`%r11')

ASM_START()
PROLOGUE(mpn_mul_2)
	stmg	%r4, %r13, 32(%r15)

	vzero	%v28
	vzero	%v29
	lg	b0, 0(bp)
	lg	b1, 8(bp)
	lg	%r13, 0(ap)
	lg	%r1,  8(ap)
	mlgr	%r12, b1
	mlgr	%r0,  b0
	lghi	%r9,  0
	lg	%r7,  0(ap)
	mlgr	%r6,  b0
	vlvgp	%v22, %r12, %r13
	vlvgp	%v20, %r0, %r1
	tmll	an, 2
	lay	an, -2(an)
	srlg	an, an, 2
	je	L(b00)

L(b10):	lghi	idx, -16
	clgije	an, 0, L(23)
	lg	%r13, 16(ap)
	lg	%r1,  24(ap)
	mlgr	%r12, b1
	mlgr	%r0,  b0
	vaq	%v0,  %v20, %v22
	vaccq	%v27, %v20, %v22
	vlvgp	%v25, %r6, %r7
	lg	%r9,  8(ap)
	lg	%r7,  16(ap)
	mlgr	%r8,  b1
	mlgr	%r6,  b0
	vzero	%v1
	vpdi	%v24, %v0, %v1, 4
	j	L(mid)

L(b00):	lghi	idx, 0
	lg	%r13, 16(ap)
	lg	%r1,  24(ap)
	mlgr	%r12, b1
	mlgr	%r0,  b0
	vaq	%v1,  %v20, %v22
	vaccq	%v27, %v20, %v22
	vlvgp	%v25, %r6, %r7
	lg	%r9,  8(ap)
	lg	%r7,  16(ap)
	mlgr	%r8,  b1
	mlgr	%r6,  b0
	vzero	%v0
	vpdi	%v24, %v1, %v0, 4
	clgije	an, 0, L(end)

L(top):	vlvgp	%v22, %r12, %r13	C o HH  4 3
	vlvgp	%v20, %r0, %r1		C o LL  4 3
	lg	%r13, 32(idx,ap)	C o H   4
	lg	%r1,  40(idx,ap)	C o L   5
	mlgr	%r12, b1		C o HH  6 5
	mlgr	%r0,  b0		C o LL  6 5
	vacq	%v26, %v24, %v25, %v29	C x     3 2
	vacccq	%v29, %v24, %v25, %v29
	vacq	%v0,  %v20, %v22, %v27	C o HL  4 3
	vacccq	%v27, %v20, %v22, %v27
	vlvgp	%v23, %r8, %r9		C e HH  3 2
	vlvgp	%v21, %r6, %r7		C e LL  3 2
	lg	%r9,  24(idx,ap)	C e H   3
	lg	%r7,  32(idx,ap)	C e L   4
	vster	%v26, 0(idx,rp), 3
	mlgr	%r8,  b1		C e HH  5 4
	mlgr	%r6,  b0		C e LL  5 4
	vpdi	%v24, %v0, %v1, 4	C x     3 2
	vacq	%v25, %v21, %v23, %v28	C e HL  3 2
	vacccq	%v28, %v21, %v23, %v28
L(mid):	vlvgp	%v22, %r12, %r13	C o HH  6 5
	vlvgp	%v20, %r0, %r1		C o LL  6 5
	lg	%r13, 48(idx,ap)	C o H   6
	lg	%r1,  56(idx,ap)	C o L   7
	mlgr	%r12, b1		C o HH  8 7
	mlgr	%r0,  b0		C o LL  8 7
	vacq	%v26, %v24, %v25, %v29	C x     3 2
	vacccq	%v29, %v24, %v25, %v29
	vacq	%v1,  %v20, %v22, %v27	C o HL  6 5
	vacccq	%v27, %v20, %v22, %v27
	vlvgp	%v23, %r8, %r9		C e HH  5 4
	vlvgp	%v21, %r6, %r7		C e LL  5 4
	lg	%r9,  40(idx,ap)	C e H   5
	lg	%r7,  48(idx,ap)	C e L   6
	vster	%v26, 16(idx,rp), 3
	mlgr	%r8,  b1		C e HH  7 6
	mlgr	%r6,  b0		C e LL  7 6
	vpdi	%v24, %v1, %v0, 4	C x     5 4
	vacq	%v25, %v21, %v23, %v28	C e HL  5 4
	vacccq	%v28, %v21, %v23, %v28
	la	idx, 32(idx)
	brctg	an, L(top)

L(end):	lg	an, 32(%r15)
	vlvgp	%v22, %r12, %r13
	vlvgp	%v20, %r0, %r1
	tmll	an, 1
	je	L(evn)
L(odd):	lg	%r13, 32(idx,ap)
	mlgr	%r12, b1
	vacq	%v26, %v24, %v25, %v29
	vacccq	%v29, %v24, %v25, %v29
	vacq	%v0,  %v20, %v22, %v27
	vacccq	%v27, %v20, %v22, %v27
	vlvgp	%v23, %r8, %r9
	vlvgp	%v21, %r6, %r7
	lg	%r9,  24(idx,ap)
	lg	%r7,  32(idx,ap)
	vster	%v26, 0(idx,rp), 3
	mlgr	%r8,  b1
	mlgr	%r6,  b0
	vpdi	%v24, %v0, %v1, 4
	vacq	%v25, %v21, %v23, %v28
	vacccq	%v28, %v21, %v23, %v28
L(cj3):	vlvgp	%v22, %r12, %r13
	vacq	%v26, %v24, %v25, %v29
	vacccq	%v29, %v24, %v25, %v29
	vaq	%v1,  %v22, %v27
	vlvgp	%v23, %r8, %r9
	vlvgp	%v21, %r6, %r7
	vster	%v26, 16(idx,rp), 3
	vpdi	%v24, %v1, %v0, 4
	vacq	%v25, %v21, %v23, %v28
	vacccq	%v28, %v21, %v23, %v28
	vacq	%v26, %v24, %v25, %v29
	vacccq	%v29, %v24, %v25, %v29
	vster	%v26, 32(idx,rp), 3
C	vzero	%v0
	vpdi	%v24, %v0, %v1, 4
	vacq	%v24, %v24, %v28, %v29
	vlgvg	%r2,  %v24, 1
	lmg	%r6,  %r13, 48(%r15)
	br	%r14

L(evn):	lg	%r13, 24(idx,ap)
	mlgr	%r12, b1
	vacq	%v26, %v24, %v25, %v29
	vacccq	%v29, %v24, %v25, %v29
	vacq	%v0,  %v20, %v22, %v27
	vacccq	%v27, %v20, %v22, %v27
	vlvgp	%v23, %r8, %r9
	vlvgp	%v21, %r6, %r7
	vster	%v26, 0(idx,rp), 3
	vpdi	%v24, %v0, %v1, 4
	vacq	%v25, %v21, %v23, %v28
	vacccq	%v28, %v21, %v23, %v28
	vlvgp	%v22, %r12, %r13
	vacq	%v26, %v24, %v25, %v29
	vacccq	%v29, %v24, %v25, %v29
	vster	%v26, 16(idx,rp), 3
	vpdi	%v24, %v27, %v0, 4
	vacq	%v22, %v22, %v28, %v29
	vaq	%v26, %v22, %v24
	vsteg	%v26, 32(idx,rp), 1
	vlgvg	%r2,  %v26, 0
	lmg	%r6,  %r13, 48(%r15)
	br	%r14

L(23):	lg	an, 32(%r15)
	tmll	an, 1
	je	L(2)
L(3):	lg	%r13, 16(ap)
	mlgr	%r12, b1
	vaq	%v0,  %v20, %v22
	vaccq	%v27, %v20, %v22
	vlvgp	%v25, %r6, %r7
	lg	%r9,  8(ap)
	lg	%r7,  16(ap)
	mlgr	%r8,  b1
	mlgr	%r6,  b0
	vzero	%v1
	vpdi	%v24, %v0, %v1, 4
	j	L(cj3)

L(2):	vaq	%v0,  %v20, %v22
	vaccq	%v27, %v20, %v22
	vlvgp	%v21, %r6, %r7
	lg	%r9,  8(ap)
	mlgr	%r8,  b1
	vzero	%v1
	vpdi	%v24, %v0, %v1, 4
	vaq	%v26, %v24, %v21
	vaccq	%v29, %v24, %v21
	vlvgp	%v23, %r8, %r9
	vster	%v26, 16(idx,rp), 3
	vpdi	%v24, %v27, %v0, 4
	vacq	%v26, %v23, %v24, %v29
	vsteg	%v26, 32(idx,rp), 1
	vlgvg	%r2,  %v26, 0
	lmg	%r6, %r13, 48(%r15)
	br	%r14
EPILOGUE()
	.section .note.GNU-stack
