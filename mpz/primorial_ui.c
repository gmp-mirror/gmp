/* mpz_primorial_ui(RESULT, N) -- Set RESULT to N# the product of primes <= N.

Contributed to the GNU project by Marco Bodrato.

Copyright 2012, 2015, 2016 Free Software Foundation, Inc.

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

/* TODO: Remove duplicated constants / macros / static functions...
 */

/*************************************************************/
/* Section macros: common macros, for swing/fac/bin (&sieve) */
/*************************************************************/

#define FACTOR_LIST_STORE(P, PR, MAX_PR, VEC, I)		\
  do {								\
    if ((PR) > (MAX_PR)) {					\
      (VEC)[(I)++] = (PR);					\
      (PR) = (P);						\
    } else							\
      (PR) *= (P);						\
  } while (0)

/*********************************************************/
/* Section sieve: sieving functions and tools for primes */
/*********************************************************/

#if WANT_ASSERT
/* n_to_bit (n) = ((n-1)&(-CNST_LIMB(2)))/3U-1 */
static mp_limb_t
n_to_bit (mp_limb_t n) { return ((n-5)|1)/3U; }

static mp_size_t
primesieve_size (mp_limb_t n) { return n_to_bit(n) / GMP_LIMB_BITS + 1; }
#endif

/*********************************************************/
/* Section primorial: implementation                     */
/*********************************************************/

void
mpz_primorial_ui (mpz_ptr x, unsigned long n)
{
  ASSERT (n <= GMP_NUMB_MAX);

  if (n < 5)
    {
      MPZ_NEWALLOC (x, 1)[0] = (066211 >> (n*3)) & 7;
      SIZ (x) = 1;
    }
  else
    {
      mp_limb_t *sieve, *factors;
      mp_size_t size, j;
      mp_limb_t prod;
      TMP_DECL;

      size = n / GMP_NUMB_BITS;
      size = size + (size >> 1) + 1;
      ASSERT (size >= primesieve_size (n));
      sieve = MPZ_NEWALLOC (x, size);
      size = (gmp_primesieve (sieve, n) + 1) / log_n_max (n) + 1;

      TMP_MARK;
      factors = TMP_ALLOC_LIMBS (size);

      j = 0;

      prod = 6;

      /* Store primes from 5 to n */
      {
	mp_limb_t max_prod;

	max_prod = GMP_NUMB_MAX / n;

	for (mp_limb_t i = 4, *sp = sieve; i < n; i += GMP_LIMB_BITS * 3)
	  for (mp_limb_t b = i, x = ~ *(sp++); x != 0; b += 3, x >>= 1)
	    if (x & 1)
	      {
		mp_limb_t prime = b | 1;
	FACTOR_LIST_STORE (prime, prod, max_prod, factors, j);
	      }
      }

      if (j != 0)
	{
	  factors[j++] = prod;
	  mpz_prodlimbs (x, factors, j);
	}
      else
	{
	  PTR (x)[0] = prod;
	  SIZ (x) = 1;
	}

      TMP_FREE;
    }
}
