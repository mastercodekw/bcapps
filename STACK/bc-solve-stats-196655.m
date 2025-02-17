(*

Subject: Faster way to test possible points-to-plane-fitting identity?

Summary: I want to confirm the three sum-defined quantities in
https://github.com/barrycarter/bcapps/blob/master/STACK/planetest.m
are identically zero for all values of n>=3.

While attempting to solve
http://stats.stackexchange.com/questions/196655 (fitting points to a
plane), I came up with these (probably either wrong or previously
derived by someone else) formulas for `a,b,c` such that `z=a*x+b*y+c`
is a best fit for n points `x[i], y[i], and z[i]`:

<pre><code>
a = 
-((Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
   Sum[x[i], {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
   Sum[y[i], {i, 1, n}]^2*Sum[x[i]*z[i], {i, 1, n}] + 
   n*Sum[y[i]^2, {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] + 
   Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}] - 
   n*Sum[x[i]*y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])/
  (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 
   2*Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
   n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
    Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]))

b =
-((-(Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}]) + 
   Sum[x[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}] + 
   Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] - 
   n*Sum[x[i]*y[i], {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] - 
   Sum[x[i], {i, 1, n}]^2*Sum[y[i]*z[i], {i, 1, n}] + 
   n*Sum[x[i]^2, {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])/
  (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 
   2*Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
   n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
    Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]))

c =
(Sum[x[i]*y[i], {i, 1, n}]^2*Sum[z[i], {i, 1, n}] - 
  Sum[x[i]^2, {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
  Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] + 
  Sum[x[i], {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] + 
  Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}] - 
  Sum[x[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])/
 (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 
  2*Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
  n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
   Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*Sum[y[i]^2, {i, 1, n}])
</code></pre>

To confirm these values, I'd compute the sum of the differences
squared. Each term would look like this:

`diff[i_] = (z[i]-(a*x[i]+b*y[i]+c))^2`

Treating the sum as a function of `a,b,c`, I would take partials with
respect to these three variables and set equal to 0.

Since derivatives add, I would be adding the sum of the derivatives of
each term:

<pre><code>
derva[i_] = -2*x[i]*(-c - a*x[i] - b*y[i] + z[i])
dervb[i_] = -2*y[i]*(-c - a*x[i] - b*y[i] + z[i])
dervc[i_] = -2*(-c - a*x[i] - b*y[i] + z[i])
</code></pre>

and setting each sum equal to 0.

Mathematica won't solve that for arbitrary `n` (which I sort of expected):

<pre><code>
Solve[{
 Sum[derva[i],{i,1,n}] == 0,
 Sum[dervb[i],{i,1,n}] == 0,
 Sum[dervc[i],{i,1,n}] == 0
}, {a,b,c}]

Out[74] = {}
</code></pre>

and `Reduce` doesn't help either. Keeping the derivative outside the
sum doesn't work either, albeit with a different error message (the
standard `Solve::nsmet: This system cannot be solved with the methods
available to Solve.`).

Mathematica *will* solve for `a,b,c` for specific values of `n`, which
led me to the guess above.

To test my guess, I need to confirm that each partial derivative is
zero. In other words, I need to confirm:

<pre><code>
Sum[-2*x[i]*(-c - a*x[i] - b*y[i] + z[i]),{i,1,n}] == 0
Sum[-2*y[i]*(-c - a*x[i] - b*y[i] + z[i]),{i,1,n}] == 0
Sum[-2*(-c - a*x[i] - b*y[i] + z[i]),{i,1,n}] == 0
</code></pre>

are identically zero for all values of x[i], y[i], z[i], and n, when I
put in my guesses above.

In other words (these are the big ugly equations which I'm
intentionally giving in "full" form for those who don't want to read
the rest of this question)...:

<pre><code>
atest[n_] := 

Sum[-2*x[i]*(-((Sum[x[i]*y[i], {i, 1, n}]^2*Sum[z[i], {i, 1, n}] - 
      Sum[x[i]^2, {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
      Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*
       Sum[x[i]*z[i], {i, 1, n}] + Sum[x[i], {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*
       Sum[x[i]*z[i], {i, 1, n}] + Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]*
       Sum[y[i]*z[i], {i, 1, n}] - Sum[x[i], {i, 1, n}]*
       Sum[x[i]*y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])/
     (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 2*Sum[x[i], {i, 1, n}]*
       Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
      n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
       Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*
       Sum[y[i]^2, {i, 1, n}])) + 
   ((Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
      Sum[x[i], {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
      Sum[y[i], {i, 1, n}]^2*Sum[x[i]*z[i], {i, 1, n}] + 
      n*Sum[y[i]^2, {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] + 
      Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}] - 
      n*Sum[x[i]*y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])*x[i])/
    (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 
     2*Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
     n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
      Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*
      Sum[y[i]^2, {i, 1, n}]) + 
   ((-(Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}]) + 
      Sum[x[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}] + 
      Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] - 
      n*Sum[x[i]*y[i], {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] - 
      Sum[x[i], {i, 1, n}]^2*Sum[y[i]*z[i], {i, 1, n}] + 
      n*Sum[x[i]^2, {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])*y[i])/
    (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 
     2*Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
     n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
      Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*
     Sum[y[i]^2, {i, 1, n}]) + z[i]), {i, 1, n}];

btest[n_] :=

Sum[-2*y[i]*(-((Sum[x[i]*y[i], {i, 1, n}]^2*Sum[z[i], {i, 1, n}] - 
      Sum[x[i]^2, {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
      Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*
       Sum[x[i]*z[i], {i, 1, n}] + Sum[x[i], {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*
       Sum[x[i]*z[i], {i, 1, n}] + Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]*
       Sum[y[i]*z[i], {i, 1, n}] - Sum[x[i], {i, 1, n}]*
       Sum[x[i]*y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])/
     (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 2*Sum[x[i], {i, 1, n}]*
       Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
      n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
       Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*
       Sum[y[i]^2, {i, 1, n}])) + 
   ((Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
      Sum[x[i], {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
      Sum[y[i], {i, 1, n}]^2*Sum[x[i]*z[i], {i, 1, n}] + 
      n*Sum[y[i]^2, {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] + 
      Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}] - 
      n*Sum[x[i]*y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])*x[i])/
    (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 
     2*Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
     n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
      Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*
      Sum[y[i]^2, {i, 1, n}]) + 
   ((-(Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}]) + 
      Sum[x[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}] + 
      Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] - 
      n*Sum[x[i]*y[i], {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] - 
      Sum[x[i], {i, 1, n}]^2*Sum[y[i]*z[i], {i, 1, n}] + 
      n*Sum[x[i]^2, {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])*y[i])/
    (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 
     2*Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
     n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
      Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*
      Sum[y[i]^2, {i, 1, n}]) + z[i]), {i, 1, n}];

ctest[n_] :=

Sum[-2*(-((Sum[x[i]*y[i], {i, 1, n}]^2*Sum[z[i], {i, 1, n}] - 
      Sum[x[i]^2, {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
      Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*
       Sum[x[i]*z[i], {i, 1, n}] + Sum[x[i], {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*
       Sum[x[i]*z[i], {i, 1, n}] + Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]*
       Sum[y[i]*z[i], {i, 1, n}] - Sum[x[i], {i, 1, n}]*
       Sum[x[i]*y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])/
     (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 2*Sum[x[i], {i, 1, n}]*
       Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
      n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
       Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*
       Sum[y[i]^2, {i, 1, n}])) + 
   ((Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
      Sum[x[i], {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
      Sum[y[i], {i, 1, n}]^2*Sum[x[i]*z[i], {i, 1, n}] + 
      n*Sum[y[i]^2, {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] + 
      Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}] - 
      n*Sum[x[i]*y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])*x[i])/
    (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 
     2*Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
     n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
      Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*
      Sum[y[i]^2, {i, 1, n}]) + 
   ((-(Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}]) + 
      Sum[x[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}] + 
      Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] - 
      n*Sum[x[i]*y[i], {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] - 
      Sum[x[i], {i, 1, n}]^2*Sum[y[i]*z[i], {i, 1, n}] + 
      n*Sum[x[i]^2, {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])*y[i])/
    (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 
     2*Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
     n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
      Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*
      Sum[y[i]^2, {i, 1, n}]) + z[i]), {i, 1, n}];
</code></pre>

I'm claiming `atest[n], btest[n], ctest[n]` are identially 0 for all
values of n>=3.

How far I've gotten on my own:

<pre><code>

t = Table[Simplify[{atest[i], btest[i], ctest[i]}], {i,3,6}]

Out[1]= {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}}

</code></pre>

However, `Simplify[atest[7]]` just hangs. Even if I waited for it, I
suspect `Simplify`ing atest, btest, and ctest for larger numbers would
take even longer.

I realize I'm asking Mathematica to do a lot, especially since I'm
using symbols instead of actual numbers, but is there a good way to
verify this identity for all n>=3 (or prove its false, of course).

*)

sum = Sum[diff[i],{i,1,n}]

sumda = Sum[D[diff[i],a],{i,1,n}]
sumdb = Sum[D[diff[i],b],{i,1,n}]
sumdc = Sum[D[diff[i],c],{i,1,n}]

comps = {
 xs -> Sum[x[i],{i,1,n}],
 ys -> Sum[y[i],{i,1,n}],
 zs -> Sum[z[i],{i,1,n}],
 xss -> Sum[x[i]^2,{i,1,n}],
 yys -> Sum[y[i]^2,{i,1,n}],
 zzs -> Sum[z[i]^2,{i,1,n}],
 xys -> Sum[x[i]*y[i],{i,1,n}],
 xzs -> Sum[x[i]*z[i],{i,1,n}],
 yzs -> Sum[y[i]*z[i],{i,1,n}]
}

afin = agen /. comps
bfin = bgen /. comps
cfin = cgen /. comps

sumat = sumda /. {a -> afin, b -> bfin, c -> cfin}
sumbt = sumdb /. {a -> afin, b -> bfin, c -> cfin}
sumct = sumdc /. {a -> afin, b -> bfin, c -> cfin}



sol = Solve[{D[sum,a] == 0, D[sum,b] == 0, D[sum,c] ==0},{a,b,c}]
a0 = a /. sol;
b0 = b /. sol;
c0 = c /. sol;

simps = {
 Sum[x[i],{i,1,n0}] -> xs,
 Sum[y[i],{i,1,n0}] -> ys,
 Sum[z[i],{i,1,n0}] -> zs,
 Sum[x[i]^2,{i,1,n0}] -> xss,
 Sum[y[i]^2,{i,1,n0}] -> yys,
 Sum[z[i]^2,{i,1,n0}] -> zzs,
 Sum[x[i]*y[i],{i,1,n0}] -> xys,
 Sum[x[i]*z[i],{i,1,n0}] -> xzs,
 Sum[y[i]*z[i],{i,1,n0}] -> yzs
}

FullSimplify[a0 /. simps] /. simps

(*

solutions for various n0

n0 = 4

{-(((-4*ys^2 + 16*yys)*(-16*xzs + 4*xs*zs) - (16*xys - 4*xs*ys)*
     (-16*yzs + 4*ys*zs))/(-(-16*xys + 4*xs*ys)^2 + 
    (-4*xs^2 + 16*xss)*(-4*ys^2 + 16*yys)))}

n0 = 5

a:

{-((-((-4*ys^2 + 20*yys)*(-20*xzs + 4*xs*zs)) + (20*xys - 4*xs*ys)*
     (-20*yzs + 4*ys*zs))/((-20*xys + 4*xs*ys)^2 - 
    (-4*xs^2 + 20*xss)*(-4*ys^2 + 20*yys)))}

{-((-(xzs*ys^2) + 5*xzs*yys - 5*xys*yzs + xs*ys*yzs + xys*ys*zs - xs*yys*zs)/
   (5*xys^2 - 2*xs*xys*ys + xss*ys^2 + xs^2*yys - 5*xss*yys))}


b:

{(20*xzs - 4*xs*zs + ((-4*xs^2 + 20*xss)*
     (-((-4*ys^2 + 20*yys)*(-20*xzs + 4*xs*zs)) + (20*xys - 4*xs*ys)*
       (-20*yzs + 4*ys*zs)))/((-20*xys + 4*xs*ys)^2 - 
     (-4*xs^2 + 20*xss)*(-4*ys^2 + 20*yys)))/(20*xys - 4*xs*ys)}

c:

{(zs + (ys*(-20*xzs + 4*xs*zs))/(20*xys - 4*xs*ys) + 
   ((xs - ((-4*xs^2 + 20*xss)*ys)/(20*xys - 4*xs*ys))*
     (-((-4*ys^2 + 20*yys)*(-20*xzs + 4*xs*zs)) + (20*xys - 4*xs*ys)*
       (-20*yzs + 4*ys*zs)))/((-20*xys + 4*xs*ys)^2 - 
     (-4*xs^2 + 20*xss)*(-4*ys^2 + 20*yys)))/5}

n0 = 6

{-((-((-4*ys^2 + 24*yys)*(-24*xzs + 4*xs*zs)) + (24*xys - 4*xs*ys)*
     (-24*yzs + 4*ys*zs))/((-24*xys + 4*xs*ys)^2 - 
    (-4*xs^2 + 24*xss)*(-4*ys^2 + 24*yys)))}

*)













