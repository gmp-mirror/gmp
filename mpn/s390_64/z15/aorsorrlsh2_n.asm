dnl  S/390-64 mpn_addlsh2_n, mpn_sublsh2_n, mpn_rsblsh2_n.

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


define(LSH,		2)
define(RSH,		62)

ifdef(`OPERATION_addlsh2_n',`define(`DO_add')')
ifdef(`OPERATION_sublsh2_n',`define(`DO_sub')')
ifdef(`OPERATION_rsblsh2_n',`define(`DO_rsb')')

MULFUNC_PROLOGUE(mpn_addlsh2_n mpn_sublsh2_n mpn_rsblsh2_n)

include_mpn(`s390_64/z15/aorsorrlshC_n.asm')
