/*

Copyright 2012, Free Software Foundation, Inc.

This file is part of the GNU MP Library test suite.

The GNU MP Library test suite is free software; you can redistribute it
and/or modify it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 3 of the License,
or (at your option) any later version.

The GNU MP Library test suite is distributed in the hope that it will be
useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
Public License for more details.

You should have received a copy of the GNU General Public License along with
the GNU MP Library test suite.  If not, see https://www.gnu.org/licenses/.  */

#include <limits.h>
#include <stdlib.h>
#include <stdio.h>

#include "testutils.h"

#define MAXBITS 400
#define COUNT 10000

/* Called when g is supposed to be gcd(a,b), and g = s a + t b. */
static int
gcdext_valid_p (const mpz_t a, const mpz_t b,
		const mpz_t g, const mpz_t s, const mpz_t t)
{
  mpz_t ta, tb, r;

  /* It's not clear that gcd(0,0) is well defined, but we allow it and
     require that gcd(0,0) = 0. */
  if (mpz_sgn (g) < 0)
    return 0;

  if (mpz_sgn (a) == 0)
    {
      /* Must have g == abs (b). Any value for s is in some sense "correct",
	 but it makes sense to require that s == 0, t = sgn (b)*/
      return mpz_cmpabs (g, b) == 0
	&& mpz_sgn (s) == 0 && mpz_cmp_si (t, mpz_sgn (b)) == 0;
    }
  else if (mpz_sgn (b) == 0)
    {
      /* Must have g == abs (a), s == sign (a), t = 0 */
      return mpz_cmpabs (g, a) == 0
	&& mpz_cmp_si (s, mpz_sgn (a)) == 0 && mpz_sgn (t) == 0;
    }

  if (mpz_sgn (g) <= 0)
    return 0;

  /* Require that s==0 iff g==abs(b) */
  if (!mpz_sgn (s) != !mpz_cmpabs (g, b))
    goto fail;

  mpz_init (ta);
  mpz_init (tb);
  mpz_init (r);

  mpz_mul (ta, s, a);
  mpz_mul (tb, t, b);
  mpz_add (ta, ta, tb);

  if (mpz_cmp (ta, g) != 0)
    {
    fail:
      mpz_clear (ta);
      mpz_clear (tb);
      mpz_clear (r);
      return 0;
    }
  mpz_tdiv_qr (ta, r, a, g);
  if (mpz_sgn (r) != 0)
    goto fail;

  mpz_tdiv_qr (tb, r, b, g);
  if (mpz_sgn (r) != 0)
    goto fail;

  /* Require that 2 |s| < |b/g|, or s == sgn(a) */
  if (mpz_cmp_si (s, mpz_sgn (a)) != 0)
    {
      mpz_mul_2exp (r, s, 1);
      if (mpz_cmpabs (r, tb) >= 0)
	goto fail;
    }

  /* Require that 2 |t| < |a/g| or t == sgn(b) */
  if (mpz_cmp_si (t, mpz_sgn (b)) != 0)
    {
      mpz_mul_2exp (r, t, 1);
      if (mpz_cmpabs (r, ta) >= 0)
	goto fail;
    }

  mpz_clear (ta);
  mpz_clear (tb);
  mpz_clear (r);

  return 1;
}

static void
test_one (const mpz_t a, const mpz_t b)
{
  mpz_t g, s, t;

  mpz_init (g);
  mpz_init (s);
  mpz_init (t);

  mpz_gcdext (g, s, t, a, b);
  if (!gcdext_valid_p (a, b, g, s, t))
    {
      fprintf (stderr, "mpz_gcdext failed:\n");
      dump ("a", a);
      dump ("b", b);
      dump ("g", g);
      dump ("s", s);
      dump ("t", t);
      abort ();
    }

  mpz_gcd (s, a, b);
  if (mpz_cmp (g, s))
    {
      fprintf (stderr, "mpz_gcd failed:\n");
      dump ("a", a);
      dump ("b", b);
      dump ("r", g);
      dump ("ref", s);
      abort ();
    }

  /* Test mpn_gcd, if inputs are valid. */
  if (mpz_sgn (a) && mpz_sgn (b) && (mpz_odd_p (a) || mpz_odd_p (b)))
    {
      mp_size_t an, bn, gn;
      mp_ptr ap, bp, tp;
      mpz_t t;

      an = mpz_size (a); ap = a->_mp_d;
      bn = mpz_size (b); bp = b->_mp_d;

      if (an < bn)
	{
	  mp_ptr sp = ap;
	  mp_size_t sn = an;
	  ap = bp; an = bn;
	  bp = sp; bn = sn;
	}

      tp = malloc ((an + bn) * sizeof (mp_limb_t));
      if (!tp)
	abort ();

      mpn_copyi (tp, ap, an);
      mpn_copyi (tp + an, bp, bn);
      gn = mpn_gcd (tp, tp, an, tp + an, bn);
      if (mpz_cmp (s, mpz_roinit_n (t, tp, gn)))
	{
	  fprintf (stderr, "mpn_gcd failed:\n");
	  dump ("a", a);
	  dump ("b", b);
	  dump ("r", t);
	  dump ("ref", s);
	  abort ();
	}
    }

  mpz_clear (g);
  mpz_clear (s);
  mpz_clear (t);
}

void
testmain (int argc, char **argv)
{
  unsigned i;
  mpz_t a, b, g, s;
  int ai, bi;

  mpz_init (a);
  mpz_init (b);
  mpz_init (g);
  mpz_init (s);

  for (i = 0; i < COUNT; i++)
    {
      mini_random_op3 (OP_GCD, MAXBITS, a, b, s);
      mpz_gcd (g, a, b);
      if (mpz_cmp (g, s))
	{
	  fprintf (stderr, "mpz_gcd failed:\n");
	  dump ("a", a);
	  dump ("b", b);
	  dump ("r", g);
	  dump ("ref", s);
	  abort ();
	}
    }

  /* Exhaustive test of small inputs */
  for (ai = -30; ai <= 30; ai++)
    for (bi = -30; bi <= 30; bi++)
      {
	mpz_set_si (a, ai);
	mpz_set_si (b, bi);
	test_one (a, b);
      }

  for (i = 0; i < COUNT; i++)
    {
      unsigned flags;
      mini_urandomb (a, 32);
      flags = mpz_get_ui (a);
      mini_rrandomb (a, MAXBITS);
      mini_rrandomb (b, MAXBITS);

      if (flags % 37 == 0)
	mpz_mul (a, a, b);
      if (flags % 37 == 1)
	mpz_mul (b, a, b);

      if (flags & 1)
	mpz_neg (a, a);
      if (flags & 2)
	mpz_neg (b, b);

      test_one (a, b);
    }

  mpz_clear (a);
  mpz_clear (b);
  mpz_clear (g);
  mpz_clear (s);
}
