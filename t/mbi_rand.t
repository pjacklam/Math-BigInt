#!/usr/bin/perl -w

use Test;
use strict;

my $count;
  
BEGIN
  {
  $| = 1;
  unshift @INC, '../lib'; # for running manually
  my $location = $0; $location =~ s/mbi_rand.t//;
  unshift @INC, $location; # to locate the testing files
  chdir 't' if -d 't';
  $count = 500;
  plan tests => $count*2;
  }

use Math::BigInt;
my $c = 'Math::BigInt';

my $length = 200;

# If you get a failure here, please re-run the test with the printed seed
# value as input: perl t/mbi_rand.t seed

my $seed = int(rand(65537)); print "# seed: $seed\n"; srand($seed);

my ($A,$B,$ADB,$AMB,$la,$lb);
for (my $i = 0; $i < $count; $i++)
  {
  # length of A and B
  $la = int(rand($length)+1); $lb = int(rand($length)+1);
  $A = ''; $B = '';
  # we create the numbers from "patterns", e.g. get a random number and a
  # random count and string them together. This means things like
  # "100000999999999999911122222222" are much more likely. If we just strung
  # together digits, we would end up with "1272398823211223" etc.
  while (length($A) < $la) { $A .= int(rand(100)) x int(rand(16)); }
  while (length($B) < $lb) { $B .= int(rand(100)) x int(rand(16)); }
  $A = $c->new($A); $B = $c->new($B);
  print "# A $A\n# B $B\n";
  if ($A->is_zero() || $B->is_zero())
    {
    ok (1,1); ok (1,1); next;
    }
  # check that int(A/B)*B + A % B == A holds for all inputs
  # $X = ($A/$B)*$B + 2 * ($A % $B) - ($A % $B);
  ($ADB,$AMB) = $A->copy()->bdiv($B);
  ok ($A,$ADB*$B+2*$AMB-$AMB);
  # swap 'em and try this, too
  # $X = ($B/$A)*$A + $B % $A;
  ($ADB,$AMB) = $B->copy()->bdiv($A);
  ok ($B,$ADB*$A+2*$AMB-$AMB);
  }
