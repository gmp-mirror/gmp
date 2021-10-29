/* mpn_sec_tabselect.

Copyright 2007-2009, 2011, 2013, 2021 Free Software Foundation, Inc.

This file is part of the GNU MP Library.

The GNU MP Library is free software; you can redistribute it and/or modify
it under the terms of either:

  * the GNU Lesser General Public License as published by the Free
    Software Foundation; either version 3 of the License, or (at your
    option) any later version.

or

  * the GNU General Public License as published by the Free Software
    Foundation; either version 2 of the License, or (at your option) any
    later version.

or both in parallel, as here.

The GNU MP Library is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received copies of the GNU General Public License and the
GNU Lesser General Public License along with the GNU MP Library.  If not,
see https://www.gnu.org/licenses/.  */

#include "gmp-impl.h"

/* Select entry `which' from table `tab', which has nents entries, each `n'
   limbs.  Store the selected entry at rp.  Reads entire table to avoid
   side-channel information leaks.  O(n*nents).  */
void
mpn_sec_tabselect (volatile mp_limb_t *rp, volatile const mp_limb_t *tab,
		   mp_size_t n, mp_size_t nents, mp_size_t which)
{
  mp_size_t k, i;
  mp_limb_t mask;
  volatile const mp_limb_t *tp;

  tp = tab;

  /* Place first entry into result area. */
  for (i = 0; i < n; i++)
    rp[i] = tp[i];

  /* Conditionally replace entry in result area by entry 1...(nents-1) using
     masking trickery. */
  for (k = 1; k < nents; k++)
    {
      /* Generate a mask using an expression which all compilers should compile
	 into branch-free code.  The convoluted expression is designed to both
	 allow mp_limb_t greater and mp_limb_t smaller than mp_size_t. */
      mask = -(mp_limb_t) ((-(unsigned long) (which ^ k)) >> (BITS_PER_ULONG - 1));
      tp += n;
      for (i = 0; i < n; i++)
	rp[i] = (rp[i] & mask) | (tp[i] & ~mask);
    }
}
