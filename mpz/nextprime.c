/* mpz_nextprime(p,t) - compute the next prime > t and store that in p.

Copyright 1999-2001, 2008, 2009, 2012 Free Software Foundation, Inc.

Contributed to the GNU project by Niels Möller and Torbjorn Granlund.

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

#include <string.h>

#include "gmp-impl.h"
#include "longlong.h"

/*********************************************************/
/* Section sieve: sieving functions and tools for primes */
/*********************************************************/

static mp_limb_t
id_to_n  (mp_limb_t id)  { return id*3+1+(id&1); }

static mp_limb_t
n_to_bit (mp_limb_t n) { return ((n-5)|1)/3U; }

static mp_size_t
primesieve_size (mp_limb_t n) { return n_to_bit(n) / GMP_LIMB_BITS + 1; }


/************************************/
/* Section macros: macros for sieve */
/************************************/

#define LOOP_ON_SIEVE_BEGIN(prime,start,end,sieve)     \
  do {                                                 \
    mp_limb_t __mask, __index, __max_i, __i;           \
    __i = (start);                                     \
    __index = __i / GMP_LIMB_BITS;                     \
    __mask = CNST_LIMB(1) << (__i % GMP_LIMB_BITS);    \
    __max_i = (end);                                   \
    do {                                               \
      ++__i;                                           \
      if (((sieve)[__index] & __mask) == 0)            \
        {                                              \
          mp_limb_t prime = id_to_n(__i)               \

#define LOOP_ON_SIEVE_END                                 \
        }                                                 \
      __mask = __mask << 1 | __mask >> (GMP_LIMB_BITS-1); \
      __index += __mask & 1;                              \
    }  while (__i <= __max_i);                            \
  } while (0)



static const unsigned char primegap_small[] =
{
  2,2,4,2,4,2,4,6,2,6,4,2,4,6,6,2,6,4,2,6,4,6,8,4,2,4,2,4,14,4,6,
  2,10,2,6,6,4,6,6,2,10,2,4,2,12,12,4,2,4,6,2,10,6,6,6,2,6,4,2,10,14,4,2,
  4,14,6,10,2,4,6,8,6,6,4,6,8,4,8,10,2,10,2,6,4,6,8,4,2,4,12,8,4,8,4,6,
  12,2,18,6,10
};

#define NUMBER_OF_PRIMES 100

long calculate_sievelimit(mp_bitcnt_t nbits) {
  long sieve_limit;

  // Estimate a good sieve bound. Based on derivative of
  //   Merten's 3rd theorem * avg gap * cost of mod
  //      vs
  //   Cost of PRP test O(N^2.55)
  if (nbits < 12800)
    {
      mpz_t tmp;
      // sieve_limit ~= nbits ^ (5/2) / 124
      mpz_init (tmp);
      mpz_ui_pow_ui (tmp, nbits, 5);
      mpz_sqrt (tmp, tmp);
      mpz_tdiv_q_ui(tmp, tmp, 124);

      // TODO: Storing gap/2 would allow this to go far beyond 436M.
      sieve_limit = mpz_get_ui(tmp);
      mpz_clear (tmp);
    }
  else
    {
      /* Larger threshold is faster but takes ~O(n/ln(n)) memory.
       * For 33,000 bits limitting to 150M is ~12% slower than using the
       * optimal 1.5B sieve_limit.
       */
      sieve_limit = 150000000;
    }

  ASSERT( 1000 < sieve_limit && sieve_limit <= 150000000 );
  return sieve_limit;
}

void
mpz_nextprime (mpz_ptr p, mpz_srcptr n)
{
  char *composite;
  const unsigned char *primegap;
  unsigned prime_limit;
  unsigned prime;
  mp_size_t pn;
  mp_bitcnt_t nbits;
  int i, m;
  unsigned incr;
  unsigned odds_in_composite_sieve;
  unsigned long difference;
  TMP_DECL;

  /* First handle tiny numbers */
  if (mpz_cmp_ui (n, 2) < 0)
    {
      mpz_set_ui (p, 2);
      return;
    }
  mpz_add_ui (p, n, 1);
  mpz_setbit (p, 0);

  if (mpz_cmp_ui (p, 7) <= 0)
    return;

  TMP_MARK;
  pn = SIZ(p);
  MPN_SIZEINBASE_2EXP(nbits, PTR(p), pn, 1);
  if (nbits / 2 <= NUMBER_OF_PRIMES)
    {
      primegap = primegap_small;
      prime_limit = nbits / 2;
    }
  else
    {
      long sieve_limit;
      mp_limb_t *sieve;
      unsigned char *primegap_tmp;
      int last_prime;

      /* sieve numbers up to sieve_limit and save prime count */
      sieve_limit = calculate_sievelimit(nbits);
      sieve = TMP_ALLOC_LIMBS (primesieve_size (sieve_limit));
      prime_limit = gmp_primesieve(sieve, sieve_limit);

      /* Needed to avoid assignment of read-only location */
      primegap_tmp = TMP_ALLOC_TYPE (prime_limit, unsigned char);
      primegap = primegap_tmp;

      i = 0;
      last_prime = 3;
      LOOP_ON_SIEVE_BEGIN (prime, n_to_bit (5), n_to_bit (sieve_limit), sieve);
        primegap_tmp[i++] = prime - last_prime;
        last_prime = prime;
      LOOP_ON_SIEVE_END;

      /* Both primesieve and prime_limit ignore the first two primes. */
      ASSERT(i == prime_limit);
    }

  if (nbits <= 32)
    odds_in_composite_sieve = 336 / 2;
  else if (nbits <= 64)
    odds_in_composite_sieve = 1550 / 2;
  else
    /* Corresponds to a merit 14 prime_gap, which is rare. */
    odds_in_composite_sieve = 5 * nbits;

  /* composite[2*i] stores if p+2*i is a known composite */
  composite = TMP_SALLOC_TYPE (odds_in_composite_sieve, char);

  difference = 0;
  for (;;)
    {
      memset (composite, 0, odds_in_composite_sieve);
      prime = 3;
      for (i = 0; i < prime_limit; i++)
        {
          m = mpz_cdiv_ui(p, prime);
          /* Only care about odd multiplies of prime. */
          if (m & 1)
            m += prime;
          m >>= 1;

          /* Mark off any composites in sieve */
          for (; m < odds_in_composite_sieve; m += prime)
            composite[m] = 1;
          prime += primegap[i];
        }

      for (incr = 0; incr < odds_in_composite_sieve; difference += 2, incr += 1)
        {
          if (composite[incr])
            continue;

          mpz_add_ui (p, p, difference);
          difference = 0;

          /* Miller-Rabin test */
          if (mpz_millerrabin (p, 25))
            goto done;
        }

      /* Sieve next segment, very rare */
      mpz_add_ui (p, p, difference);
      difference = 0;
    }
 done:
  TMP_FREE;
}

#undef LOOP_ON_SIEVE_END
#undef LOOP_ON_SIEVE_BEGIN
