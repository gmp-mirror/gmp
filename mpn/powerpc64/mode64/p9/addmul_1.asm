dnl  Power9/10 mpn_mul_1, mpn_addmul_1, mpn_mul_1c, mpn_addmul_1c.

dnl  Copyright 2017, 2018, 2023 Free Software Foundation, Inc.

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

C                   cycles/limb
C POWER3/PPC630		 -
C POWER4/PPC970		 -
C POWER5		 -
C POWER6		 -
C POWER7		 -
C POWER8		 -
C POWER9		 2.5
C POWER10		 1.5

C TODO
C  * Consider using lq/plq/stq/pstq for POWER10
C  * Combine with mul_1.asm.

define(`rp', `r3')
define(`up', `r4')
define(`n',  `r5')
define(`v0', `r6')
define(`cy', `r7')

undefine(`maddld')
undefine(`maddhdu')

PROLOGUE(mpn_addmul_1c)
define(`G',defn(`L'))
pushdef(`L',
defn(`L')_1c)
	mr	r0, cy
	mr	r7, cy
	b	G(ent)
popdef(`L')
EPILOGUE()

ASM_START()
PROLOGUE(mpn_addmul_1)
	li	r0, 0
	li	r7, 0
L(ent):	rldicl.	r9, n, 0, 63
	addi	r10, n, 2
	srdi	r10, r10, 2
	mtctr	r10
	rldicl	r8, n, 63, 63
	cmpdi	cr6, r8, 0
	cmpdi	cr7, n, 4
	bne	cr0, L(bx1)
	addic	r1, r1, 0	C clear CA
L(bx0):	beq	cr6, L(top)

L(b10):	addi	up, up, -16
	addi	rp, rp, -16
	b	L(mid)

L(bx1):	beq	cr6, L(b01)
L(b11):	ld	r9, 0(up)
	ld	r11, 0(rp)
	maddhdu	r7, r9, v0, r11
	maddld	r9, r9, v0, r11
	addc	r11, r9, r0
	std	r11, 0(rp)
	addi	up, up, -8
	addi	rp, rp, -8
	b	L(mid)

L(b01):	ld	r9, 0(up)
	ld	r11, 0(rp)
	maddhdu	r0, r9, v0, r11
	maddld	r9, r9, v0, r11
	addc	r11, r9, r7
	std	r11, 0(rp)
	blt	cr7, L(end)
	addi	up, up, 8
	addi	rp, rp, 8

	ALIGN(16)
L(top):	ld	r8, 0(up)
	ld	r9, 8(up)
	ld	r10, 0(rp)
	ld	r11, 8(rp)
	maddhdu	r5, r8, v0, r10
	maddld	r8, r8, v0, r10
	maddhdu	r7, r9, v0, r11
	maddld	r9, r9, v0, r11
	adde	r10, r8, r0
	adde	r11, r9, r5
	std	r10, 0(rp)
	std	r11, 8(rp)
L(mid):	ld	r8, 16(up)
	ld	r9, 24(up)
	ld	r10, 16(rp)
	ld	r11, 24(rp)
	maddhdu	r5, r8, v0, r10
	maddld	r8, r8, v0, r10
	maddhdu	r0, r9, v0, r11
	maddld	r9, r9, v0, r11
	adde	r10, r8, r7
	adde	r11, r9, r5
	addi	up, up, 32
	std	r10, 16(rp)
	std	r11, 24(rp)
	addi	rp, rp, 32
	bdnz	L(top)

L(end):	addze	r3, r0
	blr
EPILOGUE()
