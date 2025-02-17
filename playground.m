(* arb rotation spherical to spherical *)

conds = {0 <= gamma <= 2*Pi, 0 <= beta <= 2*Pi, 0 <= alpha <= 2*Pi,
	 0 <= th <= 2*Pi, 0<= ph <= 2*Pi}

temp1902 = xyz2sph[
 rotationMatrix[z,gamma].
  rotationMatrix[y,beta].
   rotationMatrix[x,alpha].
    sph2xyz[th,ph,1]
];


temp1903 = FullSimplify[temp1902, conds]

temp1903 /. ArcTan[x_, y_] -> ArcTan[y/x]

(* NMinimize and http://stackoverflow.com/questions/4463481/ *)

(* the data *)

data = Table[N[753+919*Sin[x/623-125]], {x,1,25000}];

(* Find the position of the largest Fourier coefficient, after
removing the last half of the list (which is redundant) and the
constant term; the [[1]] is necessary because Ordering returns a list *)

f2 = Ordering[Abs[Take[Fourier[data], {2,Round[Length[data]/2+1]}]],-1][[1]]

(* Result: 6 *)

(* Directly find the least squares difference between all functions of
the form a+b*Sin[c*n-d], with intelligent starting values *)

sol = FindMinimum[Sum[((a+b*Sin[c*n-d]) - data[[n]])^2, {n,1,Length[data]}],
{{a,Mean[data]},{b,(Max[data]-Min[data])/2},{c,2*f2*Pi/Length[data]},d}]

(* Result (using //InputForm): 

FindMinimum::sszero: 
   The step size in the search has become less than the tolerance prescribed by
   the PrecisionGoal option, but the gradient is larger than the tolerance
   specified by the AccuracyGoal option. There is a possibility that the method
   has stalled at a point that is not a local minimum.

{2.1375902350021628*^-19, {a -> 753., b -> -919., c -> 0.0016051364365971107, 
  d -> 2.477886509998064}}

*)

(* For ABQ temps, first solution is:

{a -> 56.5323, b -> 21.843, c -> 0.000707367, d -> 1.79006} w 500824 and true mean error 6.55626

then:

{a -> -0.000368675, b -> -10.0667, c -> 0.261809, d -> 1.46924} w 55728.5 and true mean error 2.03277

then:

{a -> 4.63661*10^-7  , b -> -2.08204, c -> 0.523609,  d -> 0.292938}

then:

{a -> -0.0746423, b -> 1.7464, c -> 0.00131012, d -> -0.0196226}

then:

{a -> 0.00012338, b -> 0.89525, c -> 0.262574, d -> 1.05245}

*)




(* Create a table of values for the resulting function to compare to 'data' *)

tab = Table[a+b*Sin[c*x-d], {x,1,Length[data]}] /. sol[[2]];

ListPlot[{tab,data},PlotJoined->True,PlotRange->All]

(* The maximal difference is effectively 0 *)

Max[Abs[data-tab]] // InputForm

(* Result: 7.73070496506989*^-12 *)






Take[Reverse[Ordering[Abs[Fourier[data]]]],10]

FindFit[data, a+b*Cos[c*x-d], {a,b,c,d}, x]

FindFit[data, a+b*Cos[c*x-d], {a,b,c,d}, x, Method->NMinimize]

FindMinimum[Sum[((a+b*Cos[c*n-d]) - data[[n]])^2, {n,1,Length[data]}],
{{a,Mean[data]},{b,(Max[data]-Min[data])/2},{c,1},d}];


(* birthday "paradox" *)

f[n_,p_] = FullSimplify[Product[n-i,{i,1,p-1}]/n^(p-1),Integers]

lf[n_,p_] = LogGamma[1+n]-p*Log[n]-LogGamma[1+n-p]

Solve[lf[n,p]==Log[1/2],p,Reals]

Solve[f[n,p]==1/2,p,Integers]

Log[f[n,p]]

Solve[Product[(n-i)/n, {i,1,p}]== 1/2, p]


(* average ages *)

(* a = average age, n = population, a*n = total age *)

birth = a*n/(n+1)- a

death = (a*n-x)/(n-1) - a 


(* best fit ellipse thoughts *)

dist[t_] = Sqrt[(x[t]-x0)^2 + (y[t]-y0)^2 + (z[t]-z0)^2] +
Sqrt[(x[t]-x1)^2 + (y[t]-y1)^2 + (z[t]-z1)^2]

(* derv should be constant *)

FullSimplify[dist'[t]]




(* solving http://math.stackexchange.com/questions/6195  *)

ex[n_] = Sum[k*Binomial[n,k]/2^n, {k,0,n}]/n

ex2[n_] = Sum[(5+k)*Binomial[n,k]/2^n, {k,0,n}]/(n+8)

(* merc orbit again *)

<< /home/barrycarter/BCGIT/MATHEMATICA/cheb1.m

c1 = {-58530838.674342, 1206238.210822, 999294.823938, -28113.498473,
-272.722636, 56.342058, -4.283451, 0.195789, -0.004699, -0.000192,
0.000033, -0.000002, 0.000000, -0.000000, 0}

f1[x_] = Sum[c1[[i]]*ChebyshevT[i-1,x],{i,1,Length[c1]}]

c2 = {-49206237.094725, 7834232.176761, 659142.610233, -27513.436970,
175.954246, 1.321026, -0.961817, 0.055457, -0.002719, 0.000097,
-0.000002, -0.000000, 0.000000, -0.000000, 0}

f2[x_] =  Sum[c2[[i]]*ChebyshevT[i-1,x],{i,1,Length[c2]}]

a[i_] := c1[[i+1]]
b[i_] := c2[[i+1]]
a[14] = 0
b[14] = 0

h[x_] := If[x<0,f1[x*2+1],f2[x*2-1]]

f3[x_] = Sum[cheb1[c1,c2][[i]]*ChebyshevT[i-1,x], {i,1,14}]

coeff[n_] := 2/Pi*Integrate[h[x]/Sqrt[1-x^2]*ChebyshevT[n,x],{x,-1,1}]

f1[x_] = Sum[a[n]*ChebyshevT[n,x],{n,0,14}]
f2[x_] = Sum[b[n]*ChebyshevT[n,x],{n,0,14}]

coeff[n_] := coeff[n] = 2/Pi*(
 Integrate[f1[x*2+1]/Sqrt[1-x^2]*ChebyshevT[n,x],{x,-1,0}] +
 Integrate[f2[x*2-1]/Sqrt[1-x^2]*ChebyshevT[n,x],{x,0,1}]
)



Table[D[coeff[i], a[0]],{i,0,7}] 

Table[D[coeff[i], a[1]],{i,0,7}] 

Table[D[coeff[i], a[2]],{i,0,7}] 

Table[D[coeff[i], a[3]],{i,0,7}] 

Table[D[coeff[i], a[4]],{i,0,7}] 

Table[D[coeff[i], a[5]],{i,0,7}] 

Table[D[coeff[i],a[j]],{i,0,7},{j,0,5}]


D[coeff[2],a[0]]

FullSimplify[coeff[0] /. f1[1] -> f2[-1], Reals]




mm[x_] = MiniMaxApproximation[h[x],{x,{-1,1},3,2}][[2,1]]

mm[x_] = MiniMaxApproximation[h[x],{x,{-1,1},3,4}][[2,1]]





tab = Table[c[i],{i,0,5}]
poly[x_] = Sum[tab[[i]]*x^(i-1),{i,1,Length[tab]}]
f = Integrate[(f1[x]-poly[x])^2,{x,-1,1}]

Minimize[f,tab]

f1[x]-poly[x]

mmlist = EconomizedRationalApproximation[f1[x], {x, {-1, 1}, 1, 2}]






(* TODO: below doesn't work for 0th coeff, actual value is half of result *)

coeff1[n_] := 2/Pi*Integrate[f1[x]/Sqrt[1-x^2]*ChebyshevT[n,x],{x,-1,1}]
coeff2[n_] := 2/Pi*Integrate[f2[x]/Sqrt[1-x^2]*ChebyshevT[n,x],{x,-1,1}]

coeff3[n_] := 2/Pi*Integrate[h[x]/Sqrt[1-x^2]*ChebyshevT[n,x],{x,-1,1}]

f3[x_] = Sum[coeff3[n]*ChebyshevT[n,x],{n,0,13}] - coeff3[0]/2

(* now suppose I only had 5 coeffs each *)

f1[x_] = -58530838.674342*ChebyshevT[0,x]+
1206238.210822*ChebyshevT[1,x]+
999294.823938*ChebyshevT[2,x]+
-28113.498473*ChebyshevT[3,x]+
-272.722636*ChebyshevT[4,x]+
56.342058*ChebyshevT[5,x];

f2[x_] = -49206237.094725*ChebyshevT[0,x]+
7834232.176761*ChebyshevT[1,x]+
659142.610233*ChebyshevT[2,x]+
-27513.436970*ChebyshevT[3,x]+
175.954246*ChebyshevT[4,x]+
1.321026*ChebyshevT[5,x];

h[x_] = If[x<0,f1[x*2+1],f2[x*2-1]]

coeff3[n_] := 2/Pi*Integrate[h[x]/Sqrt[1-x^2]*ChebyshevT[n,x],{x,-1,1}]

f3[x_] = Sum[coeff3[n]*ChebyshevT[n,x],{n,0,5}] - coeff3[0]/2




(* hourly average temps, in Farenheit *)

<</home/barrycarter/BCGIT/db/abq-hourly-avg.txt


Plot[ChebyshevT[5,x],{x,-1,1}]

(* convert -1,0 interval to -1,1 *)

f[x_] = 2*x+1

(* same for 0,1 to -1,1 *)

g[x_] = 2*x-1

Plot[ChebyshevT[5,f[x]],{x,-1,0}]
Plot[ChebyshevT[5,g[x]],{x,0,1}]

f[n_]:=f[n]=Integrate[ChebyshevT[5,2*x]/Sqrt[1-x^2]*ChebyshevT[n,x],
 {x,-1/2,1/2}]



Sum[chebycoeff[data,n]*ChebyshevT[n,x],{n,1,300}]

f[x_] = Sin[Pi*x-1.04];

tab = Table[f[x],{x,-1,1,.001}];

cheb[n_] := 2/Pi*NIntegrate[f[x]*ChebyshevT[n,x]/Sqrt[1-x^2],{x,-1,1}]

g[x_] = (x-1)/Length[tab]*2 - 1 + 1/Length[tab]

cheb2[n_] := 2/Length[tab]*2/Pi*
 Sum[tab[[i]]/Sqrt[1-g[i]^2]*ChebyshevT[n,g[i]], {i, 1, Length[tab]}]

cheb2g[x_] = Sum[cheb2[n]*ChebyshevT[n,x],{n,0,10}];
chebg[x_] = Sum[cheb[n]*ChebyshevT[n,x],{n,0,10}];

Plot[{f[x],chebg[x],cheb2g[x]},{x,-1,1}]


Table[{cheb[n],cheb2[n]},{n,0,10}]

tab2 = Table[{g[x],tab[[x]]},{x,1,Length[tab]}]

tab2 = Table[{g[x],tab[[x]]},{x,1,Length[tab]}]

f3[n_] := 2/Pi*NIntegrate[Sin[x]*ChebyshevT[n,x]/Sqrt[1-x^2],{x,-1,1}]

Table[f3[n],{n,0,3}]

(* result is {0., 0.880101, 0., -0.0391267} *)

f7[x_] = Sum[f3[i]*ChebyshevT[i,x], {i,0,3}]

tab = Table[Sin[x],{x,-1,1,0.01}]

f8[x_] = (x-1)/Length[tab]*2 - 1 + 1/Length[tab]

FullSimplify[(x-1)/t*2 - 1 + 1/t,Reals]


f9[x_] = (1+Length[tab]*(1+x))/2

f10 = Interpolation[tab]

f11[x_] = f10[f9[x]]

f12[n_] := 2/Pi*NIntegrate[f11[x]*ChebyshevT[n,x]/Sqrt[1-x^2],{x,-1,1}]

f13[x_] = Sum[f12[i]*ChebyshevT[i,x], {i,0,3}]

f14[n_] := 2/Length[tab]*2/Pi*Sum[tab[[i]]*Sqrt[1-f8[i]^2]*ChebyshevT[n,f8[i]],
 {i, 1, Length[tab]}]

Table[f3[n],{n,0,3}]
Table[f14[n],{n,0,3}]



[Sin[x]*ChebyshevT[n,x]/Sqrt[1-x^2],{x,-1,1}]



f4[n_] = Integrate[ChebyshevT[n,x]^2,{x,-1,1}]
f5[n_] = Integrate[ChebyshevT[n,x]^2/Sqrt[1-x^2],{x,-1,1}]

f6[n_] = Integrate[Sin[Pi*x]*ChebyshevT[n,x]/Sqrt[1-x^2],{x,-1,1}]

a6 = Table[N[f6[n]],{n,0,9}]

Sum[a6[[i]]*ChebyshevT[i-1,x],{i,1,10}]
Sum[a6[[i]]*ChebyshevT[i-1,x],{i,1,4}]



a0 = Table[N[f3[n]],{n,0,9}]

Sum[a0[[i]]*ChebyshevT[i-1,x],{i,1,10}]

Sum[a0[[i]]*ChebyshevT[i-1,x],{i,1,3}]




Table[f4[n],{n,0,9}]
Table[f5[n],{n,0,9}]



d[x_] = Interpolation[data][x]

f[x_] = (x+1)*(Length[data]-1)/2+1

f2[x_] = 2*(x-1)/(Length[data]-1)-1

s[n_] := s[n] = Sum[data[[i]]*ChebyshevT[f2[i],n], {i, 1, Length[data]}]

a3 = Table[s[n],{n,0,1600}]

g[x_] = d[f[x]]

Table[data[[x]]*ChebyshevT[2,f[x]], {x,1,Length[data]}]

a0 = Table[g[Cos[x]],{x,0,Pi,.01}]
Fourier[a0, FourierParameters->{-1,1}]
a1 = Abs[Take[Fourier[a0, FourierParameters -> {-1,1}],{1,20}]]

Sum[a1[[i]]*ChebyshevT[i-1,x],{i,1,Length[a1]}]

a0 = FourierDCT[data]
ListPlot[a0,PlotRange->All,PlotJoined->True]

a1 = FourierDCT[PadRight[Take[FourierDCT[data],1000],Length[data]],3]

a2 = Take[Table[{i,a0[[i]]}, {i, Reverse[Ordering[Abs[a0]]]}],20]

a3 = Table[0,{i,Length[data]}]

(* should probably be a for loop *)
Table[a3[[i[[1]]]] = i[[2]], {i,a2}]

ListPlot[{FourierDCT[a3,3],data}]


ListPlot[{a1,data},PlotJoined->True]


(* our extrema occur near 0000 GMT, which creates issues, so... *)

data = RotateLeft[data,6];

daily = Partition[data,24];

(* fit for a given day *)

fit[x_,n_] = a+b*Cos[2*Pi*(x+d)/n]
f[data_] := {a,b,d} /. FindFit[data, fit[x,24], {{a,Mean[data]},b,d}, x]

t1 = Transpose[Table[f[data],{data,daily}]]

FourierDCT[PadRight[Take[FourierDCT[avg],10],366],3]
FourierDST[PadRight[Take[FourierDST[avg],10],366],3]

FourierDCT[PadRight[Take[FourierDCT[amp],6],366],3]

a1 = FourierDCT[PadRight[Take[FourierDCT[amp],5],366],3]
a2 = FourierDST[PadRight[Take[FourierDST[amp],5],366],3]
ListPlot[{a1,a2,amp}]

avg = t1[[1]]
favg[x_] = Interpolation[avg][x]
amp = t1[[2]]
shift = Mod[t1[[3]],24]

a0 = FourierDCT[avg,2]
a2 = Take[Table[{i,a0[[i]]}, {i, Reverse[Ordering[Abs[a0]]]}],2]

a3 = Table[0,{i,Length[avg]}] 
 
(* should probably be a for loop *) 
Table[a3[[i[[1]]]] = i[[2]], {i,a2}] 

a4 = FourierDCT[a3,3]
ListPlot[{a4-avg}]
showit
Total[Abs[a4-avg]]/Length[avg]


f21 = Fourier[avg, FourierParameters -> {-1,1}]
f20 = Take[f21,366/2]

f22[x_] = Total[Table[
 2*Abs[f20[[i]]]*Cos[2*Pi*(i-1)*x-Arg[f20[[i]]]], {i, 1, Length[f20]}]
] - f20[[1]]

Table[f22[(x-1)/365]-avg[[x]], {x,1,366}]

Plot[{f22[x]-favg[x*365]},{x,0,1}]

t7 = N[Transpose[sample[5*Cos[#] + 3*Cos[2*#] &,0,2*Pi,1000]][[2]]]

Abs[Take[Fourier[t7, FourierParameters -> {-1,1}], 20]]


(* since all below are integral, can use direct Fourier analysis! *)

f0[x_] = fit[x,366] /. FindFit[avg, fit[x,366], {a,b,d}, x]
t3 = Table[avg[[i]]-f0[i],{i,1,366}];

f1[x_] = fit[x,366/2] /. FindFit[t3, fit[x,366/2], {a,b,d}, x]
t4 = Table[avg[[i]]-f0[i]-f1[i],{i,1,366}];

f2[x_] = fit[x,366/3] /. FindFit[t4, fit[x,366/3], {a,b,d}, x]
t5 = Table[avg[[i]]-f0[i]-f1[i]-f2[i],{i,1,366}];



g[x_] = calmfourier[superleft[avg,1]][x];
h[x_] = Interpolation[superleft[avg,1]][x]
j[x_] = hyperfourier[superleft[avg,1]][x];

Plot[{g[x],h[x],j[x]}, {x,1,366}]

f2[x_] = 
a+b*Cos[2*Pi*(x+d)/366] /. FindFit[avg, a+b*Cos[2*Pi*(x+d)/366], {a,b,d}, x]

Plot[{f2[x],favg[x]}, {x,1,366}]

t2 = Table[f2[x]-favg[x],{x,1,366}]








(* I know this is one period of data, so ... *)

fit[x_] = a+b*Cos[2*Pi*(x-1)/Length[data] +d]
f[x_] = fit[x] /. FindFit[data, fit[x], {a,b,d}, x]

(* residuals, ie, daily temperature variance *)

r1 = Table[data[[i]]-f[i],{i,1,Length[data]}]
ListPlot[r1,PlotJoined->True]

r7 = superleft[r1,1]

g5[x_] = hyperfourier[r7][x]
g6[x_] = calmfourier[r7][x]


r6 = Table[r7[[i]]-g5[i], {i,1, Length[data]}]
r8 = Table[r7[[i]]-g6[i], {i,1, Length[data]}]

g[x_] = hyperfourier[r1][x]
g2[x_] = calmfourier[r1][x]

r2 = Table[data[[i]]-f[i]-g[i], {i,1,Length[data]}]
r3 = Table[data[[i]]-f[i]-g2[i], {i,1,Length[data]}]

g3[x_] = calmfourier[r3][x]
g4[x_] = hyperfourier[r3][x]

r4 = Table[data[[i]]-f[i]-g2[i]-g3[i], {i,1,Length[data]}]
r5 = Table[data[[i]]-f[i]-g2[i]-g4[i], {i,1,Length[data]}]


f1[x_] := Abs[cft[pdist-Mean[pdist],x]];
f2[x_] := fakederv[f1,x,0.001];
findroot2[f2,11+.002,12,.0001]

Table[{x,f2[x]},{x,11,13,.25}]
Table[{x,f1[x]},{x,11,13,.025}]
ListPlot[%,PlotJoined->True]
showit

FindFit[superleft[pdist,1], 
 d1*Cos[(0.00115699+e)*x-d3]*Cos[(0.00115699-e)*x-d5], 
 {{d1,Mean[Abs[superleft[pdist,1]]]*2},{d3,0},{d5,0},{e,0}}, x]

FindFit[superleft[pdist,1], 
 d1*Cos[d2*x-d3]*Cos[d4*x-d5], 
 {{d1,Mean[Abs[superleft[pdist,1]]]*2},{d3,0},{d5,0},{d2,0.00115699*2},d4}, x]

FindFit[superleft[pdist,1], 
 314975*Cos[d2*x-d3]*Cos[d4*x-d5], 
 {{d3,0},{d5,0},{d2,0.00115699*2},{d4,0}}, x]

FindFit[superleft[pdist,1], 
d1*Cos[d3]*Cos[d5]*Cos[d2*x]*Cos[d4*x] + d1*Cos[d5]*Cos[d4*x]*Sin[d3]*
  Sin[d2*x] + d1*Cos[d3]*Cos[d2*x]*Sin[d5]*Sin[d4*x] + 
 d1*Sin[d3]*Sin[d5]*Sin[d2*x]*Sin[d4*x]
,
 {{d1,Mean[Abs[superleft[pdist,1]]]*2},{d3,0},{d5,0},{d2,0.00115699*2},d4}, x]





(* generalized sum/product rule for cosines *)

f[x_] = c1*Cos[c2*x-c3] + c4*Cos[c5*x-c6];

(* note that phase of one variable is irrelevant *)
g[x_] = d1*Cos[(c2+c5)/2*x-d2]*Cos[(c2-c5)/2*x-d3];

(* f's FourierTransform is only non-0 at c2 and c5 *)

Solve[{
 c1*Cos[c3] == d1*Cos[d2 + d3]/2,
 c4*Cos[c6] == d1*Cos[d2 - d3]/2,
 c1*Sin[c3] == d1*Sin[d2 + d3]/2,
 c4*Sin[c6] == d1*Sin[d2 - d3]/2
}, {d1,d2,d3}
]

fc2=FourierTransform[f[x],x,t] /. t->c2 /. {DiracDelta[0]->1,DiracDelta[_]->0}
fc5=FourierTransform[f[x],x,t] /. t->c5 /. {DiracDelta[0]->1,DiracDelta[_]->0}

gp=FourierTransform[g[x],x,t]/.t->c2/.{DiracDelta[0]->1,DiracDelta[_]->0}
gn=FourierTransform[g[x],x,t]/.t->c5/.{DiracDelta[0]->1,DiracDelta[_]->0}

Solve[{gp==fc2, gn==fc5}, Reals]

(* g's FourierTransform is only non-0 at d2+-d3 *)

gp=FourierTransform[g[x],x,t]/.t->d2+d3/.{DiracDelta[0]->1,DiracDelta[_]->0}
gn=FourierTransform[g[x],x,t]/.t->d2-d3/.{DiracDelta[0]->1,DiracDelta[_]->0}

(* above requires d2=(c2+c5)/2, d3=(c2-c5)/2 *)

h[x_, c1_, c2_, c3_, c4_, c5_, c6_] = 
g[x]/.Solve[{fc2==gp, fc5==gn, d2+d3==c2, d2-d3==c5}, {d1,d2,d3,d4}][[1]]



gp /. {d2->(c2+c5)/2, d3->(c2-c5)/2}


(* graphing various functions for Fourier type analysis thingy *)

a = Table[N[753 + 919*Sin[x/62.3 - 125]], {x, 1, 10000}];
b = Fourier[a];
c = Table[superfour[a,2][t],{t,1,10000}];
d = Table[superfour[c,2][t], {t,1,10000}];

ListPlot[a-d]
ListPlot[a-c]
ListPlot[c-d]

f = Interpolation[a];

g[t_] = Integrate[f[x]*Cos[t*x],{x,1,10000}]

Plot[g[t],{t,0,1}]




Total[Table[i*Abs[b[[i]]]^2,{i,2,1000}]]
Total[Table[Abs[b[[i]]]^2,{i,2,1000}]]

f[x_] = a*Cos[b-c*x] + d*Cos[e-c*x]

f'[x]


g[t_] = FourierTransform[f[x],x,t]

FullSimplify[g[c],Reals] /. {DiracDelta[c]->0, DiracDelta[0]->1}

(* leaves a*E**(I*b) + d*E**(I*e) *)

Solve[c1*Cos[c2-c3*x] + c4*Cos[c5-c3*x] == c6*Cos[c7-c3*x],
 {c6,c7}, Reals]


Maximize[f[x],x]

c = Table[i*Abs[b[[i]]],{i,2,Length[a/2]}]
b = Fourier[Take[a,{1,9984}]];

ListPlot[Table[{i,Abs[b[[i]]]},{i,2,30}], PlotRange->All, PlotJoined-> True]

b = Flatten[{a,Reverse[a],a,Reverse[a]}];

ListPlot[Take[Abs[Fourier[b]],{80,120}], PlotRange->All, PlotJoined-> True]





a = Table[Cos[40*x]*Cos[2*x],{x,0,2*Pi,.0001}];
(* a has length 62832 *)
c = Fourier[a];

(* coefficients 39 and 43 are really high and equal at 62.275 + ~0 I *)

a = Table[Cos[40*x]*Cos[3*x],{x,0,2*Pi,.0001}];
c = Fourier[a];

(* 38 and 44 high about same value *)

a = Table[Cos[1/5*x]*Cos[10*x],{x,0,2*Pi,.01}];
ListPlot[Take[Abs[Fourier[a]],25],PlotJoined->True,PlotRange->All]
ListPlot[Take[Abs[Fourier[a^2]],25],PlotJoined->True,PlotRange->All]
ListPlot[Take[Abs[Fourier[a^3]],50],PlotJoined->True,PlotRange->All]
ListPlot[Take[Abs[Fourier[a^4]],25],PlotJoined->True,PlotRange->All]
ListPlot[Take[Abs[Fourier[Sqrt[a]]],25],PlotJoined->True,PlotRange->All]
b = Table[superfour[a,2][t],{t,1,Length[a]}];
c = Table[superfour[b,1][t],{t,1,Length[a]}];
ListPlot[{a,b},PlotJoined->True]



ListPlot[a, PlotJoined->True]
showit

ListPlot[HilbertFilter[a,Pi/10], PlotJoined->True]

c = Fourier[a];
cft[a,10.8]
ListPlot[Take[Abs[c],50],PlotRange->All]
ListPlot[Table[{x,Abs[cft[a,x]]},{x,10,12,.1}]]

FourierTransform[Cos[1/5*x]*Cos[10*x],x,t]
ListPlot[HilbertFilter[a,0]]
ListPlot[HilbertFilter[a,Pi*.1]]
ListPlot[HilbertFilter[a,Pi]]
ListPlot[HilbertFilter[a,Pi]]
ListPlot[HilbertFilter[a,Pi]]
ListPlot[HilbertFilter[a,Pi]]



ListPlot[Take[Abs[c],50],PlotRange->All]
b = Sqrt[a*Reverse[a]];
ListPlot[b]
showit


FourierTransform[Cos[x]*Cos[5-x],x,t]

Plot[Cos[x]*Cos[5-x],{x,0,2*Pi}]



(* Given a point x,y,z, if we rotate so the x axis points upwards and
pretend the x axis is now the z-axis:

x axis value becomes z axis value
y axis value doesnt change
z axis value becomes -x axis value

(all rotations below chosen so that some axis remains positive in the
"up" direction)

*)

(* two wrongs don't make a right, but three rights make a left... *)

roty[{x_,y_,z_}] = {-z,y,x}
unroty[{x_,y_,z_}] = roty[roty[roty[{x,y,z}]]]

rotx[{x_,y_,z_}] = {x,-z,y}
unrotx[{x_,y_,z_}] = rotx[rotx[rotx[{x,y,z}]]]

rotz[{x_,y_,z_}] = {-y,x,z}
unrotz[{x_,y_,z_}] = rotz[rotz[rotz[{x,y,z}]]]

sph2xyz[{th_,ph_}] = {Cos[ph]*Cos[th], Cos[ph]*Sin[th], Sin[ph]}
xyz2sph[{x_,y_,z_}] = {ArcTan[x,y], ArcTan[Sqrt[1-z^2],z]}
(* not 100% accurate below but testing *)
xyz2sph[{x_,y_,z_}] = {ArcTan[x,y], ArcTan[Sqrt[1-z^2],z]}

(* given a latitude, longitude (theta/phi), I want to add w (omega) in
a given direction *)

xyz2sph[unroty[sph2xyz[xyz2sph[roty[sph2xyz[{th,ph}]]]+{w,0}]]]
xyz2sph[unrotz[sph2xyz[xyz2sph[rotz[sph2xyz[{th,ph}]]]+{w,0}]]]
xyz2sph[unrotx[sph2xyz[xyz2sph[rotx[sph2xyz[{th,ph}]]]+{w,0}]]]

FullSimplify[xyz2sph[unrotz[sph2xyz[xyz2sph[rotz[sph2xyz[{th,ph}]]]+{w,0}]]],
 {Member[ph,Reals], Member[th,Reals], -Pi/2 < ph, ph < Pi/2, -Pi < w, w < Pi,
  -Pi < th +w , th +w < Pi
}]

FullSimplify[xyz2sph[unroty[sph2xyz[xyz2sph[roty[sph2xyz[{th,ph}]]]+{w,0}]]],
 {Member[ph,Reals], Member[th,Reals], -Pi/2 < ph, ph < Pi/2, -Pi < w, w < Pi,
  -Pi < th +w , th +w < Pi
}]

FullSimplify[xyz2sph[unrotx[sph2xyz[xyz2sph[rotx[sph2xyz[{th,ph}]]]+{w,0}]]],
 {Member[ph,Reals], Member[th,Reals], -Pi/2 < ph, ph < Pi/2, -Pi < w, w < Pi,
  -Pi < th +w , th +w < Pi
}]

(* around z axis first [testing] *)
rot[{th_,ph_},w_] = 
 xyz2sph[unrotz[sph2xyz[xyz2sph[rotz[sph2xyz[{th,ph}]]]+{w,0}]]]-{th,ph}

rotx[{th_,ph_},w_] = 
 xyz2sph[unrotx[sph2xyz[xyz2sph[rotx[sph2xyz[{th,ph}]]]+{w,0}]]]-{th,ph}

roty[{th_,ph_},w_] = 
 xyz2sph[unroty[sph2xyz[xyz2sph[roty[sph2xyz[{th,ph}]]]+{w,0}]]]-{th,ph}

VectorPlot[roty[{th,ph},10*Degree], {th,-Pi,Pi}, {ph,-Pi/2,Pi/2}]

StreamPlot[roty[{th,ph},1*Degree], {th,-Pi,Pi}, {ph,-Pi/2,Pi/2}]

rotp[x_,y_,w_] = {Cos[w + ArcTan[x, y]], Sin[w + ArcTan[x, y]]}*Norm[{x,y}]

StreamPlot[rotp[x,y,1*Degree]-{x,y}, {x,-Pi,Pi}, {y,-Pi/2,Pi/2},
AspectRatio -> Automatic]

StreamPlot[roty[{th,ph},1*Degree], {th,-Pi,Pi}, {ph,-Pi/2,Pi/2},
AspectRatio -> Automatic]

StreamPlot[rotp[th,ph,1*Degree]-{th,ph}-roty[{th,ph},1*Degree],
{th,-Pi,Pi}, {ph,-Pi/2,Pi/2}, AspectRatio -> Automatic]

StreamPlot[{rotp[th,ph,1*Degree]-{th,ph}, roty[{th,ph},1*Degree]},
{th,-Pi/2,Pi/2}, {ph,-Pi/4,Pi/4}, AspectRatio -> Automatic]




thc = xyz2sph[unroty[sph2xyz[xyz2sph[roty[sph2xyz[{th,ph}]]]+{w,0}]]][[1]]
phc = xyz2sph[unroty[sph2xyz[xyz2sph[roty[sph2xyz[{th,ph}]]]+{w,0}]]][[2]]

FullSimplify[thc, {Member[ph,Reals], Member[th,Reals]}]
FullSimplify[phc, {Member[ph,Reals], Member[th,Reals], -Pi < ph, ph < Pi}]




(* wii tennis stuff *)

(* if you have p chance of winning volley, these are you changes of achieve various scores *)

dist[p_] = List[p^4, 4*q*p^4, 10*q^2*p^4, (20*p^5*q^3)/(1-2*p*q),
(20*q^5*p^3)/(1-2*p*q), 10*p^2*q^4, 4*p*q^4, q^4] /. q->1-p

(* your next possible scores [wii tennis, elisa/sarah] given your current score *)

(* the asymptotes *)

asym = List[2400, 2250, 2100, 2000, 1600, 1500, 1350, 1200]

ns[sc_] = (asym + 19*sc)/20

(* your next score estimation, given current score and prob of hit *)

nse[sc_, p_] = Simplify[Total[dist[p]*ns[sc]]]

(* your estimated "fixed" score given p chance of hit *)

fixedscore[p_] := FixedPoint[nse[#,p]&, 2000]

(* my high score of 2050 = 64% chance of winning volley *)
fixedscore[.64]

Table[{p,fixedscore[p]}, {p,.25,1,.05}] // TableForm


FixedPoint[nse[#,.9]&, 2000]
FixedPoint[nse[#,.1]&, 2000]

Plot[FixedPoint[nse[#,p]&, 2000], {p,.1,1}]

nse[2000,1]
nse[2000,.5]
nse[1990,.5]


ListPlot[dist[.5], Joined->True]

ListPlot[dist[.3], Joined->True]

ListPlot[dist[.7], Joined->True]





(* http://stackoverflow.com/questions/13977107 *)

(* fake multiply, etc?; f= addition, fm=minus, g= mult, gd=divide, h= expon *)

SetAttributes[f,{Orderless,Flat}]
SetAttributes[g,{Orderless,Flat}]
fm[x_,y_] = -f[x,y]
gd[x_,y_] = 1/g[x,y]

(* distributive property *)
g[a_,f[x_,y_]] = f[g[a,x],g[a,y]]

(* START HERE; see stack1.m, broken out *)

(* it turns out the symbolizing + * is not that useful after all *)
f[x_,y_] = x+y
fm[x_,y_] = x-y
g[x_,y_] = x*y
gd[x_,y_] = x/y
gd[x_,0] = Null

(* "unlog[x]" means 2^x but I dont want Mathematica to expand *)
(* using log base 2 since 2,4,8 all powers of two *)
h[a_,b_] = unlog[b*Log[2,a]]

(* expand unlog if "small" *)
unlog[x_] := 2^x /; x<10

(* power properties *)
h[h[a_,b_],c_] = h[a,b*c]
h[a_/b_,n_] = h[a,n]/h[b,n]
h[1,n_] = 1

(* expand simple powers only! *)
(* does this make things worse? *)
h[a_,2] = a*a
h[a_,3] = a*a*a

(* all symbols for two numbers *)
allsyms[x_,y_] := allsyms[x,y] = 
 DeleteDuplicates[Flatten[{f[x,y], fm[x,y], fm[y,x], 
 g[x,y], gd[x,y], gd[y,x], h[x,y], h[y,x]}]]

allsymops[s_,t_] := allsymops[s,t] = 
 DeleteDuplicates[Flatten[Outer[allsyms[#1,#2]&,s,t]]]

Clear[reach];
reach[{}] = {}
reach[{n_}] := reach[n] = {n}
reach[s_] := reach[s] = DeleteDuplicates[Flatten[
 Table[allsymops[reach[i],reach[Complement[s,i]]], 
  {i,Complement[Subsets[s],{ {},s}]}]]]

(* given two numbers, return all 'operations' between them, bidirectionally *)
alltest[x_,y_] := alltest[x,y] = 
 DeleteDuplicates[Flatten[{x+y, x-y, x*y, x^y, y-x, y^x, x/y, y/x}]]

s = {2,3,4,5,6,7,8}



Clear[reach];
reach[{}] = {}
reach[{n_}] := reach[n] = {n}
reach[s_] := reach[s] = DeleteDuplicates[Flatten[
 Table[allsops[reach[i],reach[Complement[s,i]]], 
  {i,Complement[Subsets[s],{ {},s}]}]]]

(* given two numbers, return all 'operations' between them, bidirectionally *)
allops[x_,y_] := allops[x,y] = 
 DeleteDuplicates[{x+y, x-y, x*y, x^y, y-x, y^x, x/y, y/x}]
(* same for two sets *)
allsops[s_,t_] := allsops[s,t] = 
 DeleteDuplicates[Flatten[Outer[allops[#1,#2]&,s,t]]]

(* testing superfourier *)

t1 = N[Table[Cos[2*Pi*x/789],{x,1,10001}]]

t1 = N[Table[Cos[2*Pi*x/10001*73],{x,1,10001}]]
t1 = N[Table[Cos[2*Pi*x/10001*73.001],{x,1,10001}]]

t1 = N[Table[Cos[2*Pi*x/10001*73.01],{x,1,10001}]]
t1 = N[Table[Cos[2*Pi*x/10001*73.01]-Cos[2*Pi*x/10001*73],{x,1,10001}]]

welch = 1 - (2 (Range[10001] - (10001 - 1)/2)/(10001 + 1))^2;
fData = Append[Abs[Fourier[welch t1]]^2 / (Plus @@ (welch^2)), 0];
fData = (fData + Reverse[fData])/2;
fData = fData / (Plus @@ fData);

t2 = Take[Abs[Fourier[t1]],73]
t4 = Take[Abs[Fourier[t1]],{75,74+73}]

ListPlot[t2, PlotRange->All]
ListPlot[t4, PlotRange->All]

t3 = Table[t2[[n]]*(74-n),{n,1,73}]
t5 = Table[t4[[n]]*n,{n,1,73}]

ListPlot[t3, PlotRange->All]
ListPlot[t5, PlotRange->All]

ac[n_] := Sum[t1[[i]]*t1[[i+n]],{i,1,Length[t1]-n}]

t2 = Table[ac[n],{n,0,Length[t1],10}]

t3 = Table[ArcCos[i],{i,t1}]

t4 = Table[Abs[Fourier[t1]]]

Sum[i*t4[[i]],{i,1,Length[t4]}]

Sum[i*Abs[t4[[i]]],{i,1,Length[t4]}]

ListPlot[Table[Abs[Fourier[t1]][[x]], {x,2,20}], PlotJoined->True, 
 PlotRange->All] 

convolve[n_] := Sum[t1[[x]]*Cos[n*x], {x,1,10001}] 

ListPlot[Abs[fx2],PlotRange->All]

Plot[convolve[n],{n,12,14}, PlotRange->All] 
Plot[convolve[n],{n,12.5,12.7}, PlotRange->All] 
Plot[convolve[n],{n,12.55,12.6}, PlotRange->All] 
Plot[convolve[n],{n,12.59,12.6}, PlotRange->All] 
Plot[convolve[n],{n,12.59,12.59+10/10001.}, PlotRange->All] 

f = superfour[t1,1]
Table[t1[[i]]-f[i],{i,1,10001}]

n=10001
pdata = t1 - Total[t1]/Length[t1];
f = Abs[Fourier[pdata]];
ListPlot[f,PlotRange->All]
pos = Ordering[-f, 1][[1]]; (*the position of the first Maximal value*)  
fr = Abs[Fourier[pdata Exp[2 Pi I (pos - 2) N[Range[0, n - 1]]/n], 
   FourierParameters -> {0, 2/n}]];
ListPlot[fr,PlotRange->All]
frpos = Ordering[-fr, 1][[1]];


(* random thoughts *)

Sum[Cos[n*x]/n,{n,1,100}]

(* ellipses where one focus is origin, other is (-1,0) and d=3 *)

y[x_] = y /.  Solve[Sqrt[x^2+y^2] + Sqrt[(x+1)^2+y^2] == 3, y][[2,1]]

Plot[y[x], {x,-2,1}, AspectRatio->Automatic]

(* area carved out at x *)
area[x_] := NIntegrate[y[t],{t,x,1}] + x*y[x]/2

(* x for given area *)
xarea[a_] := x /. FindRoot[area[x] == a,{x,-2,1}]

t3 = Table[xarea[a],{a,0,3.33,.01}]

t1 = Table[{x,area[x]},{x,-2,1,.01}]

ListPlot[t1]

t2 = Table[{a[[2]],a[[1]]},{a,t1}]
ListPlot[t2]

t3 = Table [xa

Abs[Fourier[t2]]

(* How much does the Earth move when you jump? *)

(* Earths circumference in meters)
ec = 40*10^6

(* Earths radius in meters *)
er = ec/2/Pi

(* Earths angular rotation in s seconds *)
ar[s_] = Mod[s*2*Pi/86400,2*Pi]

(* rotation speed in m/s at equator *)
rs = ec/86400

(* straight-line distance you travel in s seconds *)
sld[s_] =s*rs

(* angular distance you travel *)
angd[s_] = Mod[ArcTan[sld[s]/er],2*Pi]

(* Your gain/loss vs Earths angle change *)
angdelta[s_] = If[angd[s] - ar[s] < Pi, angd[s]-ar[s], angd[s]-ar[s]-2-Pi]

(* And how far that moves you along the Earths surface *)
d[s_] = er*angdelta[s]

(*

if my weight loss is proportional to calories eaten [which I measure]
minus calories burned [which is proportional to my weight itself],
what happens?

c[i] = calories eaten on ith day

*)

Solve[w[t] == b0 + b1*w[t] + b2*c[t], w[t]]

w[0] = w0
w[i_] := w[i-1] + k1*(c[i] - k2*w[i-1]) + k3

DSolve[{w'[t] == k1*c[t] - k2*w[t], w[0]==w0}, w[t], t]

(* truncated sine waves *)

t1 = Table[If[Abs[Sin[x]]>.9,Sign[Sin[x]]*.9,Sin[x]],{x,0,2*Pi,.01}]

f1 = Abs[Fourier[t1]]

(* hourly data averages *)

<<"!bzcat /home/barrycarter/BCGIT/db/abqhourly.m.bz2"

data2 = Gather[data, (#1[[2]] == #2[[2]] && #1[[3]] == #2[[3]] &&
#1[[4]] == #2[[4]]) &]


(* below messes up hourly data *)
data = Select[Table[x[[5]],{x,data}], # > -9999&];

f0[x_] = Interpolation[data]
f1[x_] = hyperfourier[data][x]
f2[x_] = calmfourier[data][x]

Plot[f1[x],{x,1,Length[data]}]

f3[x_] = hyperfourier[superleft[data,1]][x]
f4[x_] = calmfourier[superleft[data,1]][x]

(* another shot at polar transforms *)

(* polar transformation using matrix *)

(* start with point at 1, theta, phi *)

pt = {Cos[theta]*Cos[phi], Sin[theta]*Cos[phi], Cos[phi]}

(* arbitrary three D matrix, assuming it is a rotation *)

mat = { {a11, a12, a13}, {a21, a22, a23}, {a31, a32, a33}}

Solve[{
 (mat.pt)[[1]] == Cos[theta2],
 (mat.pt)[[2]] == Sin[theta2],
 (mat.pt)[[3]] == Cos[phi2]
},Flatten[mat]]

(* result only depends on first col? *)

Solve[{
 (mat.pt)[[1]] == Cos[theta2],
 (mat.pt)[[2]] == Sin[theta2],
 (mat.pt)[[3]] == Cos[phi2],
 a21 == 1,
 a22 == 1,
 a12 == 1,
 a13 == 1,
 a21 == 1,
 a22 == 1,
 a32 == 1,
 a33 == 1
},Flatten[mat]]



(* Deal or No Deal *)

dond = {.01, 1, 5, 10, 25, 50, 75, 100, 200, 300, 400, 500, 750, 1000, 5000,
10000, 25000, 50000, 75000, 100000, 200000, 300000, 400000, 500000,
750000, 1000000};

(* no cool pattern, sadly, more like double broken parabola [break at
1000/5000] *)

ListPlot[Log[dond]/Log[10], PlotJoined->True, PlotRange->All]

(* Simple segment-to-point distance *)

(* the x and y value of line segment x1,y1 to x2,y2 parametrized by t *)
segx[t_] = x1 + t*(x2-x1)
segy[t_] = y1 + t*(y2-y1)

(* square of distance from x0,y0 at parameter t *)
dist2[x0_,y0_,t_] = (x0-segx[t])^2 + (y0-segy[t])^2
dist[x0_,y0_,t_] = Sqrt[(x0-segx[t])^2 + (y0-segy[t])^2]

mint2[x0_,y0_] = t /. Solve[D[dist2[x0,y0,t],t]==0,t][[1,1]]
mint[x0_,y0_] = t /. Solve[D[dist[x0,y0,t],t]==0,t][[1,1]]



least[ax_,ay_,bx_,by_,cx_,cy_] = t /. Solve[D[dist[cx,cy,t],t]==0,t][[1,1]]

segx[least[ax,ay,bx,by,cx,cy]]
segy[least[ax,ay,bx,by,cx,cy]]
dist[cx,cy,least[ax,ay,bx,by,cx,cy]]

least[ax,ay,bx,by,cx,cy] // TeXForm
least[ax,ay,bx,by,cx,cy] // MathML

(* below does not work [because of complex numbers?] *)

Minimize[dist[cx,cy,t],t]

(* 

Assuming local planarity but a NON-square grid, what's the closest a
line through t1,t2 comes to a point p?

*)

(* Allowing t1 and t2 to be complex and p to be 0, equation of line is *)

f[t_] = t1 + (t2-t1)*t

d[t_] = Abs[f[t]]

D[d[t],t]

Minimize[d[t],t,{t1,t2}]

(* above didn't work, so... *)

lat[t_] = lat1 + (lat2-lat1)*t
lon[t_] = lon1 + (lon2-lon1)*t

(* Cos[theta] is a constant below, based on user latitude *)

dist[t_] = lat[t]^2+Cos[theta]*lon[t]^2

Solve[D[dist[t],t]==0,t]

(*

Answer: (lat1*(lat1 - lat2) + lon1*(lon1 - lon2)*Cos[theta])/
 ((lat1 - lat2)^2 + (lon1 - lon2)^2*Cos[theta])

*)

(*

How much water at 55F [tap water] would it take to cool my 25x25x8
living room from 80F to 79F?

http://www.wolframalpha.com/input/?i=mass+of+5000+cubic+feet+of+air
tells us my 5000 cu ft living room has 181kg of air (wow!) [assuming I
lived at sea level, which I don't, but let's pretend-- in reality,
pressure is about 20% lower here]

The specific heat of air
http://www.wolframalpha.com/input/?i=specific+heat+of+air&a=*C.specific+heat-_*ThermodynamicPropertyPhrase-
is about 717.8 joules per kilogram kelvin

The specific heat of water 1 calorie/gram (definition of calorie) or http://www.wolframalpha.com/input/?i=specific+heat+of+water&a=*C.specific+heat-_*ThermodynamicPropertyPhrase- 4157 joules per kilogram kelvin

80F is 26.6666666666C, 79F is 26.1111111111C, 55F is 12.7777777777

To decrease 181kg of air by 5/9 degree Celsius/Kelvin (ie, 1 degree
Farenheit), we need:

717.8 joules per kilogram kelvin * 181kg * 5/9 Kelvin =
72178.7777777777 joules of energy

for every kg of water we raise from 12.77C to 26.11C, we lose

4157 joules per kilogram kelvin * 1 kg * 13.3333 kelvins or

55426.66 joules of energy

So, we need 72178.7777777777/55426.666666 or 1.302kg of water to lower
the temperature 1 degree; that's about http://www.wolframalpha.com/input/?i=1.302+kg+of+water+in+gallons 0.344 gallons

[unrealistically assuming there is no other heat gain/loss, and the
entire room is full of air and the walls have no effect, etc]

*)

(* figuring out linear regression myself *)

(yi-(a*xi+b))^2

(* sum of squares for given line *)
diff[a_,b_] = Sum[(y[i]-(a*x[i]+b))^2,{i,1,5}]

(* Minimize, but below hangs Mathematica *)
Minimize[diff[a,b],{a,b}]

(* look for 0 derv *)
Solve[D[diff[a,b],a]==0, a]
Solve[D[diff[a,b],b]==0, b]
zd[a_] = b /. %[[1,1]] 

(* from above b == -a*(sumx) + (sumy) *)

Solve[D[diff[a,b],a]==0, a] /. b -> zd[a]

(* another approach: *)

Solve[{D[diff[a,b],a]==0, D[diff[a,b],b]==0}, {a,b}]

sola = a /. %[[1,1]]

test1 = a /. {Table[x[i],{i,1,5}],Table[y[i],{i,1,5}]}

Simplify[sola, {Sum[x[i]^2,{i,1,5}] == sumx2}]
Simplify[sola, {Sum[x[i]^2,{i,1,2}] == sumx2}]
Simplify[sola, {x[1]^2+x[2]^2+x[3]^2 == sumx2}]
Simplify[sola, {x[1]^2+x[2]^2 == sx2}]
Simplify[sola, {x[1]^2+x[2]^2 == sx2}]
Simplify[sola, {x[1]^2+x[2]^2+x[3]^2+x[4]^2 == sx2}]



(* if you save $1/month at r% for y years... *)

m[t_,r_] = m[t,r] /.
DSolve[{D[m[t,r],t] == 12 + m[t,r]*r, m[0,r]==0}, m[t,r], {t,r}][[1]]

m[t_,0] = 12*t

t1 = Table[m[t,r],{t,1,40},{r,0,.24,.01}]

StringJoin[
Table["<td>"<>ToString[m[1,r]]<>"</td>",{r,0,.24,.01}]
]


mon[0] = 0
mon[n_] = mon[n-1] + 1 + r*mon[n-1]

RSolve[{
 mon[0] == 0,
 mon[n] == mon[n-1] + 1 + r*mon[n-1]},
mon[n],n]

RSolve[{
 mon[0] == 0,
 mon[n] == mon[n-1] + 1 + ((1+r)^(1/12)-1)*mon[n-1]},
mon[n],n]

(* credit card DFQ from bc-cc-interest.pl; see also http://stackoverflow.com/questions/4455575/find-equivalent-interest-rate-for-cash-advance-fee-promo-rate *)

(*

int = yearly interest charge on loan
min = minimum payment (per year) on loan
int2 = interest earned on borrowed money
amt = amount borrowed (but this is actually irrelevant)
fee = %fee charged for loan ("points")

*)

(* specific example from apr.barrycarter.info *)

t3 = DSolve[{
 owed[0] == 10000*1.03,
 have[0] == 10000,
 owed'[t] == (.04/12-.02)*owed[t],
 have'[t] == (.06/12)*have[t] - .02*owed[t]
}, {owed[t], have[t]}, t]

t2[t_] = owed[t] /. t3[[1]]
t4[t_] = have[t] /. t3[[1]]

Table[{t,t2[t]},{t,1,16}] // TableForm
Table[{t,t4[t]},{t,1,16}] // TableForm

(* generalizing slightly, and exactifying *)

t3 = DSolve[{
 owed[0] == 10000*103/100,
 have[0] == 10000,
 owed'[t] == (4/100/12-2/100)*owed[t],
 have'[t] == (r/12)*have[t] - 2/100*owed[t]
}, {owed[t], have[t]}, t]

Solve[have[16] == owed[16], r] /.
DSolve[{
 owed[0] == 10000*103/100,
 have[0] == 10000,
 owed'[t] == (4/100/12-2/100)*owed[t],
 have'[t] == (r/12)*have[t] - 2/100*owed[t]
}, {owed[t], have[t]}, t][[1]]

Solve[t2[16/12] == t4[16/12], r]

FindRoot[t2[16/12] == t4[16/12], {r,0,1}]

Solve[Exp[1/45]*t2[16/12] == Exp[1/45]*t4[16/12], r]

Series[Solve[t2[16/12] == t4[16/12], r],r, 10]

(* form that kills Math *)

Solve[r + Exp[r] + r*Exp[r] == 10, r]

Limit[r + Exp[r] + r*Exp[r], r->0]

Series[r + Exp[r] + r*Exp[r], {r,0,4}]

Solve[owed[t] == have[t], t] /.
DSolve[{
 owed'[t] == (int-min)*owed[t],
 have'[t] == int2*have[t] - min*owed[t],
 have[0] == amt,
 owed[0] == amt*(1+fee)
}, {owed[t], have[t]}, t]


t5 = DSolve[{
 owed'[t] == (int-min)*owed[t],
 have'[t] == int2*have[t] - min*owed[t],
 have[0] == amt,
 owed[0] == amt*(1+fee)
}, {owed[t], have[t]}, t]

t2[t_] = owed[t] /. t5[[1]]
t4[t_] = have[t] /. t5[[1]]

Normal[Series[t2[t], {int, 0, 2}]]
Normal[Series[t4[t], {int, 0, 2}]]

Normal[Series[t2[t], {int-min, 0, 2}]]


Solve[Normal[Series[t2[t], {int, 0, 2}]] ==
      Normal[Series[t4[t], {int, 0, 2}]], t]

t9[t_] = t4[t] /. Exp[x_] -> 1+x
t8[t_] = t2[t] /. Exp[x_] -> 1+x

Solve[t9[t]==t8[t], int2]

(* roughly int + fee*int + fee/t *)

(* so the extra interest is roughly fee/t*12 [12 for months] *)

t1[int_, min_, int2_, fee_] = t /. %[[1,1,1]]

t1[.36, .01*12, .02*12, 0.01]

(* more exact calc *)

t9[t_] = t4[t] /. Exp[x_] -> 1+x+x^2/2
t8[t_] = t2[t] /. Exp[x_] -> 1+x+x^2/2

Solve[t9[t]==t8[t], int2] /.
 {fee*min -> 0, fee*int -> 0, int*min->0, fee*int^2 -> 0,
  int^2*min -> 0, min^2 -> 0, int^2 ->0, min^2*t^2 -> 0}

ExpandAll[Solve[t9[t]==t8[t], int2]] /.
 {fee*min -> 0, fee*int -> 0, int*min->0, fee*int^2 -> 0,
  int^2*min -> 0, min^2 -> 0, int^2 ->0, min^2*t^2 -> 0}

int2 /. %[[1]]



conds =  {int -> 6/100, min -> 3/100, fee -> 2/100}

Solve[owed[t] == have[t], int2] /.
DSolve[{
 owed'[t] == int*owed[t] - min*owed[t] /. conds,
 have'[t] == int2*have[t] - min*owed[t] /. conds,
 have[0] == 1 /. conds,
 owed[0] == 1+fee /. conds
}, {owed[t], have[t]}, t]

(* use http://aa.usno.navy.mil/cgi-bin/aa_rstablew.pl data to find best fit curve for length of day *)

<<"!perl -anle 'sub BEGIN {print \"data={\"} sub END {print \"}\"} unless (/^[0-9]/) {next;} print \"{\"; for $i (0..11) {$x=substr($_,5+11*$i,10);$x=~s/\s/,/;$x=~s/\s*$//; print \"{$x},\"}; print \"},\"' /home/barrycarter/BCGIT/db/srss-60n.txt"

(* below is probably correct version for all files, but turns out to
be irrelevant south of 60N? *)

<<"!perl -anle 'sub BEGIN {print \"data={\"} sub END {print \"}\"} unless (/^[0-9]/) {next;} print \"{\"; for $i (0..11) {$x=substr($_,4+11*$i,10);$x=~s/\s/,/;$x=~s/\s*$//; print \"{$x},\"}; print \"},\"' /home/barrycarter/BCGIT/db/srss-70n.txt"

(* the data is in ugly form: hhmm, and each rows represents a date,
like the 27th, for each month; the below cleans this up nicely *)

f[x_] = Floor[x/100] + Mod[x,100]/60
d2 = Map[f,DeleteCases[Flatten[Transpose[DeleteCases[data,Null]]],Null]]
d3 = Table[d2[[i+1]]-d2[[i]],{i,1,Length[d2],2}]

(* nice, sine-like wave below *)

ListPlot[d3]

(* first three Fourier terms appear to work well *)

fitme[x_] = c0 + c1*Sin[x/366*2*Pi + c2] + c3*Sin[2*x/366*2*Pi + c4] +
 c5*Sin[3*x/366*2*Pi + c6]

(* modified below for 65N case *)

fitme[x_] = c0 + c1*Sin[x/366*2*Pi + c2] + c3*Sin[2*x/366*2*Pi + c4] +
 c5*Sin[3*x/366*2*Pi + c6] + c7*Sin[4*x/366*2*Pi + c8] + 
 c9*Sin[5*x/366*2*Pi + c10]

fitme[x_] = c0 + c1*Sin[x/366*2*Pi + c2] + c3*Sin[2*x/366*2*Pi + c4] +
 c5*Sin[3*x/366*2*Pi + c6] + c7*Sin[5*x/366*2*Pi + c8]*Sin[1/2*x/366*2*Pi+c9]


fit[x_] = fitme[x] /.
FindFit[d3, fitme[x], {c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10}, x]

fit[x_] = fitme[x] /.
FindFit[d3, fitme[x], {c0,c1,c2,c3,c4,c5,c6}, x]

(* residuals (in minutes) *)
diffs = Table[60*(d3[[i]] - fit[i]),{i,1,366}]

ListPlot[diffs,PlotRange->All,PlotJoined->True]

(*

Results:

for 35N: 

12.17695810564663 - 2.2953248962442743*Sin[1.3975767265331764 - (Pi*x)/183] - 
 0.021757064356510064*Sin[1.4830003645309824 + (2*Pi*x)/183] - 
 0.05791554634652895*Sin[2.0862521448266143 + (Pi*x)/61]

for 40N:

12.195309653916212 - 2.7657088311643028*
  Sin[1.3970291332060125 - (Pi*x)/183] - 0.026018266221687174*
  Sin[1.4457660007570647 + (2*Pi*x)/183] - 
 0.07493789567389378*Sin[2.078928604511676 + (Pi*x)/61]

for 45N:

12.21848816029144 - 3.3213738010117693*Sin[1.3975212065347047 - (Pi*x)/183] - 
 0.029619752930272168*Sin[1.4369720568764897 + (2*Pi*x)/183] - 
 0.10039096273827293*Sin[2.0864065165171435 + (Pi*x)/61]

for 50N:

12.249863387978142 - 4.004529463127261*Sin[1.3975199952244841 - (Pi*x)/183] - 
 0.032938707095312054*Sin[1.3708424645486041 + (2*Pi*x)/183] - 
 0.13710842909531928*Sin[2.09344402070527 + (Pi*x)/61]

for 55N: (diffs of over 1m, and definitely showing a "sin(5x)" pattern)

12.29535519125683 - 4.88712126398891*Sin[1.3974823984389089 - (Pi*x)/183] - 
 0.03179707785286025*Sin[1.2247093298434937 + (2*Pi*x)/183] - 
 0.20085908488999415*Sin[2.0960777979500858 + (Pi*x)/61]

for 60N: (diffs approaching 3m, strong "sin(5x)" pattern)

12.366621129326047 - 0.3323859261039487*Sin[1.0498084329064128 - (Pi*x)/61] + 
 6.126639453559547*Sin[4.539058614130759 - (Pi*x)/183] - 
 0.028173091102636834*Sin[0.5143017626631174 + (2*Pi*x)/183]

for 65N: (diffs up to 20m, "sin(5x)" pattern is strong)

12.53943533697632 + 8.227563673411336*Sin[4.538803223403626 - (Pi*x)/183] + 
 0.14114455405156695*Sin[2.20319450021785 + (2*Pi*x)/183] - 
 0.7550946690168826*Sin[2.093554971972919 + (Pi*x)/61]

12.538333951043256 + 8.230179551945618*Sin[4.538729883308269 - (Pi*x)/183] - 
 0.24546385293978604*Sin[3.8150139254154904 - (5*Pi*x)/183]*
  Sin[3.1507227641197093 + (Pi*x)/366] - 0.13662959788605702*
  Sin[5.343824436119907 + (2*Pi*x)/183] - 0.7651221272215183*
  Sin[2.09729425139858 + (Pi*x)/61]


*)


(* Use KABQ hourly data to determine trends, db/abqhourly.m (after bunzip) *)

(* -9999 = temp unknown  and drops nulls *)
data = Select[data, #[[5]] > -9999 &];
data = Table[i[[5]], {i,data}];


(* closer to the way we need it *)
data2 = Table[{ {x[[2]],x[[3]],x[[4]]}, {x[[1]],x[[5]]}}, {x,data}];

(* Gather by mo-da-hr *)

data3 = Gather[data2, #1[[1]] == #2[[1]] &];

(* now get da-mo-hr -> list (easy way to do this? 
http://stackoverflow.com/questions/6974544/using-mathematica-gather-collect-properly)
*)

data4 = Table[{x[[1,1]], Table[y[[2]], {y,x[[2]]}]}, {x,data3}];

f[m_] := {data3[[m,1,1]], Table[data3[[m,n,2]],{n,Length[data3[[m]]]}]}

data5 = Table[f[i],{i,1,Length[data3]}];

Fit[data5[[8,2]], {1,x}, x]

data6 = Table[{x[[1]], Fit[x[[2]], {1,t}, t]}, {x, data5}];

data7 = Table[{x[[1]], D[x[[2]],t]}, {x, data6}];

data8 = Sort[data7];

data9 = Table[x[[2]], {x,data8}]

(* daily *)
Table[Take[data9,{i*24+1,i*24+24}],{i,0,365}]
data11 = Table[Mean[Take[data9,{i*24+1,i*24+24}]],{i,0,365}]

ListPlot[data11, PlotJoined->True]

data10 = Fourier[data9]

ListPlot[data9, PlotJoined -> True]

(* normal approximation to binomial distribution *)

(* roll 100d6 and look at frequency of individual numbers *)

Plot[PDF[NormalDistribution[100/6, Sqrt[100/6*5/6]], x],{x,0,100}, 
 PlotRange->All]

Solve[CDF[NormalDistribution[100/6, Sqrt[100/6*5/6]], x] == 5/6, x]

(* Out[23]= {{x -> 20.272}} *)

(* prob that at least one will exceed 20 is about 70% *)

1-CDF[NormalDistribution[100/6, Sqrt[100/6*5/6]], 20]^6

(* whats the CDF? of that *)

atleastone[x_] = 1-CDF[NormalDistribution[100/6, Sqrt[100/6*5/6]], x]^6

(* CDF for highest freq? *)

Plot[1-atleastone[x],{x,0,100}]

pdfatleastone[x_] = D[CDF[NormalDistribution[100/6, Sqrt[100/6*5/6]], x]^6,x]

Plot[pdfatleastone[x],{x,0,100},PlotRange->All]

(* for
http://www.quora.com/If-I-repeatedly-roll-a-fair-k-sided-die-how-many-rolls-on-average-will-it-take-before-Ive-rolled-any-number-n-times
between 10-55 *)

quorarolls[n_] = 1-CDF[NormalDistribution[n/6, Sqrt[n/6*5/6]], 10]^6
dquorarolls[n_] = D[1-CDF[NormalDistribution[n/6, Sqrt[n/6*5/6]], 10]^6,n]

Plot[quorarolls[n],{n,10,54}]
Plot[dquorarolls[n],{n,10,54}]

Integrate[quorarolls[n],{n,10,54}]
Integrate[dquorarolls[n],{n,10,54}]

t1 = N[Table[quorarolls[n],{n,10,54}]]

Plot[PDF[BionomialDistribution[96,1/6],x],{x,0,96}]

(* unusual property of Sin[] that may be an alternative to Fourier *)

f[x_] = a+b*Sin[c*x+d]

(* result below is -c^2 *)
f'''[x]/f'[x]

(* how about this... *)

Log[f'[x]]
D[Log[f'[x]],x]
Log[D[Log[f'[x]],x]]
D[Log[D[Log[f'[x]],x]],x]
Log[D[Log[D[Log[f'[x]],x]],x]]
D[Log[D[Log[D[Log[f'[x]],x]],x]],x]

(* above is fun, but useless *)

(* slightly more complex *)

f[x_] = a1 +b1*Sin[c1*x+d1] +b2*Sin[c2*x+d2]

(* with x data of jupiter *)

<<"/home/barrycarter/SPICE/KERNELS/final-pos-500-0-299.txt"; 

p0 = planet299;
p1 = p0[[1;;Length[p0];;10]];
Clear[p0];
Clear[planet299];
px = Table[{x[[2]]-2455562.500000000,x[[3]]},{x,p1}];
px2 = Table[x[[3]],{x,p1}];

fx2 = Abs[Fourier[px2]]
ListPlot[Take[fx2,50],PlotRange->All]

ListPlot[Log[Take[fx2,50]],PlotRange->All]

fx3 = Table[{i,fx2[[i]],convolve[i]},{i,1,50}]

convolve[n_] := Sum[px2[[x]]*Cos[n*x], {x,1,Length[px2]}]
Plot[convolve[n],{n,31,33}, PlotRange->All]

meanleft[n_] := meanleft[n] = Mean[Abs[superfourtwoleft[test,n]]]
maxleft[n_] := maxleft[n] = Max[Abs[superfourtwoleft[test,n]]]

tab3 = Table[meanleft[n],{n,0,20}]
tab3 = Table[maxleft[n],{n,0,20}]


fx2 = Fourier[px2];
Take[fx2,100]
ListPlot[Abs[%],PlotRange->All]
ListPlot[Abs[fx2],PlotRange->All]
g = Interpolation[px, InterpolationOrder->3]
Plot[g'''[x]/g'[x],{x,0,2922}]
Integrate[g'''[x]/g'[x],{x,0,2922}]/2922.

(* anti-Fourier values? *)

(* known perpindicular *)
Integrate[Sin[2*x]*Sin[3*x],{x,0,2*Pi}]

Integrate[Sin[58/10*x]*Sin[7*x],{x,0,2*Pi}]

h[n_] = Integrate[Sin[58/10*x]*Sin[n*x],{x,0,2*Pi}]

Solve[%==0, n]

Plot[h[n],{n,3,8}]


(* metaf2xml's first formula for humidity, reversing to get dewpoint *)

humid[t_, d_] = 10^(7.5 * (d / (d + 237.7) - t / (t + 237.7)))
humidf[t_, d_] = humid[(t-32)/1.8, (d-32)/1.8]

dewpoint[t_, h_] = d /. Solve[humidf[t,d]==h, d][[1]]

(* t in Celsius *)
satpressure[t_] = 6.1121*Exp[(18.678-t/234.5)*(t/(257.14+t))]

humid[t_, d_] = satpressure[d]/satpressure[t]

Solve[humid[t,d]==h, d]



(* the two body problem? *)

DSolve[{
 d2[t] == (x1[t]-x0[t])^3/2 + (y1[t]-y0[t])^3/2 + (z1[t]-z0[t])^3/2,
 D[x0[t], t,t] == (x1[t]-x0[t])/d2[t],
 D[y0[t], t,t] == (y1[t]-y0[t])/d2[t],
 D[z0[t], t,t] == (z1[t]-z0[t])/d2[t],
 D[x1[t], t,t] == -(x1[t]-x0[t])/d2[t],
 D[y1[t], t,t] == -(y1[t]-y0[t])/d2[t],
 D[z1[t], t,t] == -(z1[t]-z0[t])/d2[t],
 x0[0] == 0, y0[0] == 0, z0[0] == 0,
 x1[0] == 1, y0[0] == 0, z0[0] == 0,
 x0'[0] == 0, y0'[0] == 0, z0'[0] == 0
}, {x0,y0,z0,x1,y1,z1,d2}, t
]


(* ellipse in 2d? *)

DSolve[{
 d2[t] == (x1[t]-x0[t])^2 + (y1[t]-y0[t])^2;
 D[x0[t], t,t] == (x1[t]-x0[t])/d2[t],
 D[x1[t], t,t] == -(x1[t]-x0[t])/d2[t],
 D[y0[t], t,t] == (y1[t]-y0[t])/d2[t],
 D[y1[t], t,t] == -(y1[t]-y0[t])/d2[t],
 x0[0] == 0, y0[0] == 0, x0'[0] == 0, y0'[0] == 0
}, {x0,y0,x1,y1}, t
]

{x1[t]-x0[t],y1[t]-y0[t]} /.
NDSolve[{
 d2[t_] = (x1[t]-x0[t])^2 + (y1[t]-y0[t])^2;
 x0''[t] == -(x1[t]-x0[t])/d2[t],
 x1''[t] == -x0''[t],
 y0''[t] == -(y1[t]-y0[t])/d2[t],
 y1''[t] == -y0''[t],
 x0[0] == 0, y0[0] == 0, x0'[0] == 0, y0'[0] == 0,
 x1[0] == 1, y1[0] == 0, x1'[0] == 0, y1'[0] == 0.1
}, {x0,y0,x1,y1}, t
][[1]]
ParametricPlot[%,{t,0,5},AspectRatio->Automatic]





n = 200;
data = N[Table[Sin[3.17*2*Pi*x/200], {x, 1, n}]];
welch = 1 - (2 (Range[n] - (n - 1)/2)/(n + 1))^2;
fData = Append[Abs[Fourier[welch*data]]^2 / (Plus @@ (welch^2)), 0];
ListPlot[fData, PlotRange->All]
fData = (fData + Reverse[fData])/2;
fData = fData / (Plus @@ fData);
Log[fData]
f = Interpolation[Log[fData], InterpolationOrder -> 3];
Plot[f[x],{x,1,5}]

t1 = N[Table[Sin[3/2*2*Pi*x/10000], {x,1,10000}]];
t2 = N[Table[Sin[20*2*Pi*x/10000], {x,1,10000}]];
t3 = N[t1*t2]
t4 = N[Table[Sin[2*Pi*x/200], {x,1,200}]];
t5 = N[Table[Sin[20*2*Pi*x/10000], {x,1,9750}]];
t4 = N[Table[Sin[3.17*2*Pi*x/200], {x,1,200}]];

t4m = t4[[1;;Length[t4];;10]]
i1 = Interpolation[t4m, InterpolationOrder->16]

Plot[i1[x],{x,1,20}]

Table[i1[1+(x-1)/10] - t4[[x]], {x,1,200}]

diffs = Table[t4[[i]] - t4[[i-1]], {i,2,Length[t4]}]
diff[t_] := Table[t[[i]] - t[[i-1]], {i,2,Length[t]}]

t42 = diff[diff[t4]]

NonlinearModelFit[t4, a*Cos[b*x-c], {{a, 0.983639} ,{b, -0.0992743},
 {c, -1.49867}}, x]

superfourier[t4]

ListPlot[t4/Max[Abs[t4]]]
ListPlot[ArcCos[t4/Max[Abs[t4]]]]

Integrate[Sin[x], {x,0,2*Pi*3.17}]
Integrate[Cos[x], {x,0,2*Pi*3.17}]
Integrate[Cos[1.49867-x], {x,0,2*Pi*3.17}]

superfour[t2,1][7]

t3 = N[Table[Sin[3/2*2*Pi*x/10000]  * Sin[20*2*Pi*x/10000], {x,1,10000}]];

t3 = N[Table[Sin[n*2*Pi*x/10000]  * Sin[m*2*Pi*x/10000], {x,1,10000}]];
t3 = Table[Sin[n*2*Pi*x/10000]  * Sin[m*2*Pi*x/10000], {x,1,10000}];
t3 = Table[Sin[n*2*Pi*x/10000]  * Sin[m*2*Pi*x/10000], {x,1,100}];

t4 = Fourier[t3]

ListPlot[Abs[t4], PlotRange->All]

Select[t4, # != 0 &]


Simplify[Sin[n*x]*Sin[m*x], {Element[x,Reals]}]
TrigFactor[Sin[n*x]*Sin[m*x]]
TrigReduce[Sin[n*x]*Sin[m*x]]
Log[Sin[n*x]*Sin[m*x]]



(* from http://hpiers.obspm.fr/eop-pc/models/constants.html *)
ecliptic = ArcSin[0.397776995]
mecliptic = {{1,0,0}, {0, Cos[ecliptic], -Sin[ecliptic]},
 {0, Sin[ecliptic], Cos[ecliptic]}}

(* positions at 2455833.933333333 *)

earth = {1.485770387408892*10^+08, 1.494799659360260*10^+07,
3.747770517099129*10^+02}

jupiter = {6.257010398453077*10^+08, 3.974473247851866*10^+08,
-1.566407515423084*10^+07}

vec1 = jupiter - earth
vec = mecliptic . (vec1)

ArcSin[vec[[3]]/Norm[vec]]

(* -1.46448 in degrees *)


(* figure out 1900 GMT today and next Friday *)

DateList[{"next Friday", {"DayName"}}]


(* an ellipse w/ semimajor axis a, periapsis qr, apoapsis ad, NE quadrant *)

y[x_, a_, qr_] = y /.
 Solve[{Sqrt[(x+a-qr)^2 + y^2] + 
        Sqrt[(x-a+qr)^2 + y^2] == 2*a}, {y}][[2,1]]

Plot[y[x,3,2],{x,-5,5},AspectRatio->Automatic]

Plot[y[x,5,2],{x,-5,5},AspectRatio->Automatic]

Graphics[Plot[y[x,3,2],{x,-5,5}], Text["hello",{1,3}]]

Plot[Text["Hello",{1,0}], {x,-1,1}]

(* tti = thing to integrate *)

tti[x_, a_, qr_, theta_] = Min[(x-(a-qr))*Tan[theta], y[x, a, qr]]

Plot[tti[x,3,2, 60 Degree],{x,1,6}]

Plot[{y[x,3,2], tti[x,3,2, 60 Degree]},{x,-5,5}]

area[a_, qr_, theta_] = Integrate[tti[x,a,qr,theta], {x,a-qr,a}, 
 Assumptions -> {0 < theta < Pi/2, a>0, qr>0, Member[theta, Reals], 
 Member[a, Reals], Member[qr, Reals]}]

Integrate[tti[x,1,5,45 Degree], {x,1,1+5}]

Integrate[tti[x,1,5,theta], {x,1,1+5}]

(* mathematica does above, but not below *)

Integrate[tti[x,1,5,theta], {x,a,a+5}]

Integrate[tti[x,a,5,theta], {x,a,a+5}]

Integrate[Min[y[x,a,qr], (x-a)*m], {x,a,a+qr}]

Integrate[Min[y[x,a,qr], (x-a)*2], {x,a,a+qr}]

Integrate[Min[y[x,a,3], (x-a)*2], {x,a,a+3}]

Integrate[y[x,a,qr], {x,x1,x2}]

sliver[a_, qr_, x1_] = 
Integrate[y[x,a,qr], {x,x1,a}, Assumptions -> {a>0, qr>0, x1>0, a > x1}]

meetpt[a_, qr_, m_] = x /. Solve[y[x,a,qr] == m*(x-(a-qr)), x][[2]]

sliver[a, qr, meetpt[a,qr,m]] // CForm
sliver[a, qr, meetpt[a,qr,m]] // SyntaxForm
sliver[a, qr, meetpt[a,qr,m]] // TreeForm

tti[x, 3.870991416593402/10, 3.075015900415988/10, theta]

sliver[1,qr,m*qr]


(* area at angle theta from focus [not center] *)

tti[x_, theta_] = Min[Tan[theta]*(x-a), y[x]]
tti[x_, m_] = Min[m*(x-a), y[x]]
Integrate[tti[x,theta], {x,a,a+qr}]

(* mathematica won't do above, so lets figure out what breaks it *)

Integrate[Min[x-a,y[x]],{x,a,a+qr}] /. a->4


(* ellipses *)

f[x_] = y/. Solve[Sqrt[(x+1)^2 + y^2] + Sqrt[(x-1)^2 + y^2] == 5, y][[2,1]]
Plot[f[x], {x,-6,6}, AspectRatio -> Fixed, AxesOrigin -> {0,0}]
Integrate[f[x], {x,0,2}]
g[x_, m_] = Min[m*(x-1), f[x]]
Plot[g[x,2], {x,1,5/2}, AspectRatio -> Fixed, AxesOrigin -> {0,0}]
Integrate[g[x,2], {x,1,5/2}]
h[m_] = Simplify[Integrate[g[x,m], {x,1,5/2}], {m>0}]
Solve[h[m] == x, m]

Integrate[g[x,ArcTan[theta]], {x,1,5/2}]

(* Eternal Lands *)

(* how much stuff do I have right now? ii = in inventory *)
coalii = 101;
feii = 150;
ioii = 1313;
gpii = 1225;

(* how much does stuff cost from bots? bs = botsell *)

coalbs = 0;
febs = 4.95;
iobs = 3.20;

(* how to buy stuff to maximize number of steel bars? tb = to buy *)

(* tb < 0 non-sensical since I can't sell at botsell prices *)

Solve[{
 (ioii+iotb)/8 == (feii+fetb)/3 == (coalii+coaltb)/5,
 Max[iotb,0]*iobs + Max[fetb,0]*febs + Max[coaltb,0]*coalbs == gpii
}, {iotb,fetb,coaltb}]

(* tennis game at deuce, p change of getting point, q=1-p *)

Simplify[Solve[x == p^2 + 2*p*q*x, x] /. q -> 1-p]


(* box options *)

Integrate[
PDF[NormalDistribution[0,v1]][x]*(1-CDF[NormalDistribution[0,v2]][a-x]),
{x,-Infinity,a}
]

Integrate[
PDF[NormalDistribution[0,v1]][x]*PDF[NormalDistribution[0,v2]][y],
{x,-Infinity,a}, {y,a-x,Infinity}, Assumptions -> {v1>0, v2>0}
]

Plot[PDF[HalfNormalDistribution[1]][x], {x,-10,10}]

testmax[x_] = If[x>0, PDF[HalfNormalDistribution[1]][x], 0]

Plot[testmax[x],{x,-5,5}]

test2[x_] = Integrate[
 PDF[NormalDistribution[0,1]][y] * testmax[x-y], {y,-Infinity,x}]

Plot[test2[x],{x,-5,5}]

testmax[x_] = If[x>0, PDF[HalfNormalDistribution[1/10]][x], 0]

maxdist[x_, v_] = If[x>0, PDF[HalfNormalDistribution[v]][x], 0]

maxdistv[x_, v1_, v2_] = Integrate[
 PDF[NormalDistribution[0,v1]][y] * maxdist[x-y, v2], {y,-Infinity,x},
 Assumptions -> {v1>0, v2>0}]

maxdistv[x,1,2]

val1[a_, v1_, v2_] := 
NIntegrate[
PDF[NormalDistribution[0,v1]][x] * (1-CDF[HalfNormalDistribution[v2]][a-x]),
{x,-Infinity,a}]

Interpolation[{{a,v1,v2}, val1[a,v1,v2]}

Table[{{a,v1,v2},val1[a,v1,v2]}, {a,1}, {v1,0.1,0.2,.01}, {v2,0.1,0.2,.01}]

val1[1,.1,.1]

FunctionInterpolation[val1[a,v1,v2], {a,0,1}, {v1,0,1}, {v2,0,1}]


(* combining two barrier options?

stays above: upper+lower long wins
stays below: upper+lower short wins
inbetween: lower: long wins; upper: short wins

suppose upper long pays 300 w/ 100 bet, profit is:
suppose lower long pays 200 w/ 100 bet, profit is:

upper is 1.5
lower is 1.25

*)

profit[p_] = If[p>1.5, 300-100, -100] - If[p>1.25, 200-100, -100]

Plot[profit[p], {p,1,2}]



Exit[]

tox[ra_, dec_] = (Pi+dec*Degree)*Cos[ra*Degree]
toy[ra_, dec_] = (Pi+dec*Degree)*Sin[ra*Degree]

dec1 = AstronomicalData["Moon", "Declination"]
ra1 = AstronomicalData["Moon", "RightAscension"]*15

tox[ra1,dec1]
toy[ra1,dec1]

Table[AstronomicalData["Moon", {"RightAscension", DateList[x]}], 
 {x, AbsoluteTime[{2011,5,25,19}], AbsoluteTime[{2011,5,26,10}]}]



Exit[]

tab = Table[a[i], {i,1,100}]

f = Interpolation[tab]

f1[x_] := f[42+x] /. {a[42] -> 0, a[43] ->0, a[44] -> 0, a[41] -> 1}
t1 = Table[{x,f1[x]}, {x,.01,.99,.01}]
FindFit[t1, c0 + c1*x + c2*x^2 + c3*x^3, {c0,c1,c2,c3}, x]
Factor[Chop[c0 + c1*x + c2*x^2 + c3*x^3 /. %]]

f2[x_] := f[42+x] /. {a[41] -> 0, a[43] ->0, a[44] -> 0, a[42] -> 1}
t2 = Table[{x,f2[x]}, {x,.01,.99,.01}]
FindFit[t2, c0 + c1*x + c2*x^2 + c3*x^3, {c0,c1,c2,c3}, x]
Factor[Chop[c0 + c1*x + c2*x^2 + c3*x^3 /. %]]

f3[x_] := f[42+x] /. {a[41] -> 0, a[42] ->0, a[44] -> 0, a[43] -> 1}
t3 = Table[{x,f3[x]}, {x,.01,.99,.01}]
FindFit[t3, c0 + c1*x + c2*x^2 + c3*x^3, {c0,c1,c2,c3}, x]
Factor[Chop[c0 + c1*x + c2*x^2 + c3*x^3 /. %]]

f4[x_] := f[42+x] /. {a[41] -> 0, a[42] ->0, a[43] -> 0, a[44] -> 1}
t4 = Table[{x,f4[x]}, {x,.01,.99,.01}]
FindFit[t4, c0 + c1*x + c2*x^2 + c3*x^3, {c0,c1,c2,c3}, x]
Factor[Chop[c0 + c1*x + c2*x^2 + c3*x^3 /. %]]

Plot[f1[x]+f2[x]+f3[x]+f4[x], {x,0,1}]

(* below is identically one as expected *)
Table[f1[x]+f2[x]+f3[x]+f4[x], {x,0,1,.01}]

h1[x_] = (x-2)*(x-1)*x/-6
h2[x_] = (x-2)*(x-1)*(x+1)/2
h3[x_] = x*(x+1)*(x-2)/-2
h4[x_] = (x-1)*x*(x+1)/6

Plot[{h1[x],h2[x],h3[x],h4[x]}, {x,0,1}]

Plot[{h1[x],f1[x]}, {x,0,1}]
Plot[{h2[x],f2[x]}, {x,0,1}]
Plot[{h3[x],f3[x]}, {x,0,1}]
Plot[{h4[x],f4[x]}, {x,0,1}]

(* results:

(x-2)*(x-1)*x/-6 <- coeff of 41

(x-2)*(x-1)*(x+1)/2 <- coeff of 42

x*(x+1)*(x-2)/-2 <- coeff of 43

(x-1)*x*(x+1)/6 <- coeff of 44

*)

Plot[{f[42+x] /. {a[42] -> 0, a[43] ->0, a[44] -> 0, a[41] -> 1}},
 {x,0,1}]

Plot[{f[42+x] /. {a[41] -> 0, a[43] ->0, a[44] -> 0, a[42] -> 1}},
 {x,0,1}]

Plot[{f[42+x] /. {a[42] -> 0, a[41] ->0, a[44] -> 0, a[43] -> 1}},
 {x,0,1}]

Plot[{f[42+x] /. {a[42] -> 0, a[43] ->0, a[41] -> 0, a[44] -> 1}},
 {x,0,1}]




Exit[]

altintfuncalc[f_, t_] := Module[
 {xvals, yvals, xint, tisin, tpos, m0, m1, p0, p1},

 (* figure out x values *)
 xvals = Flatten[f[[3]]];

 (* and corresponding y values *)
 yvals = Flatten[f[[4,3]]];

 (* HACK: for some reason, t1 is bizarre *)
// yvals = Flatten[f[[4]]];


 (* and size of each x interval; there are many other ways to do this *)
 (* <h>almost all of which are better than this?</h> *)
 xint = (xvals[[-1]]-xvals[[1]])/(Length[xvals]-1);

 (* for efficiency, all vars above this point should be cached *)

 (* which interval is t in?; interval i = x[[i]],x[[i+1]] *)
 tisin = Min[Max[Ceiling[(t-xvals[[1]])/xint],1],Length[xvals]-1];

Print["TISIN ",tisin];
Print["XVALS ",xvals];
Print["YVALS ",yvals];

 (* and the y values for this interval, using Hermite convention *)
 p0 = yvals[[tisin]];
 p1 = yvals[[tisin+1]];

 (* what is t's position in this interval? *)
 tpos = (t-xvals[[tisin]])/xint;

 (* what are the slopes for the intervals immediately before/after this one? *)
 (* we are assuming interval length of 1, so we do NOT divide by int *)
 m0 = p0-yvals[[tisin-1]];
 m1 = yvals[[tisin+2]]-p1;

 (* return the Hermite approximation *)
 (* <h>Whoever wrote the wp article was thinking of w00t</h> *)
 h00[tpos]*p0 + h10[tpos]*m0 + h01[tpos]*p1 + h11[tpos]*m1
]

t1 = Interpolation[Table[x*x,{x,1,10}]]

altintfuncalc[t1, 9.5]


Exit[]

(* if we map ra/dec as theta, r (r= 90+dec), do we have something? 
(it's at least only 2D *)

dec[t_] = 23*Sin[t*2*Pi/365]
ra[t_] = t/365*24/24*2*Pi

Plot[{ra[t],dec[t]},{t,0,365}]

x[t_] = (90+dec[t])*Sin[ra[t]]
y[t_] = (90+dec[t])*Cos[ra[t]]

Plot[x[t],{t,0,365}]
Plot[y[t],{t,0,365}]

Exit[]

(* if we have lots of data, can we "compress" it in an odd way? *)

(* trying to do 10 years at a time slow things down a bit, so maybe 1 year *)

data = Take[data, 10000];

(* start with dec *)

moondec = Table[{i[[1]], i[[3]]}, {i,data}];

datareduce[data_, n_] := Module[{halfdata, inthalfdata, tabhalfdata, origdata},
 halfdata = Take[data, {1,Length[data],2^n}];
Print["halfdata complete"];
 inthalfdata = Interpolation[halfdata];
Print["inthalfdata complete"];
 tabhalfdata = Table[inthalfdata[data[[i,1]]], {i, 1, Length[data]}];
Print["tabhalfdata complete"];
 Return[tabhalfdata];
]

t1 = datareduce[moondec, 1];
t2 = Table[moondec[[i,2]], {i, 1, Length[data]}];
t3 = t1-t2;

(* vaguely bad that I'm using data as a parameter, but won't cause
Mathematica problem *)

(* take each 2^nth piece of data *)
halfdata[data_, n_] := Take[data, {1,Length[data],2^n}]

(* interpolate it *)
inthalfdata[data_, n_] := Interpolation[halfdata[data,n]]

(* new data *)
tabhalfdata[data_, n_] := 
 Table[inthalfdata[data,n][data[[i,1]]], {i, 1, Length[data]}]

(* and compare *)
maxdiff[data_, n_] := Max[tabhalfdata[data,n]];

moondechd = halfdata[moondec,1];





mindata = Table[{i, data[[i]]}, {i,1,Length[data],50}]

mindata = Table[{i, data[[i]]}, {i,1,Length[data],500}]

mindata = Table[{i, data[[i]]}, {i,1,Length[data],5000}]

amindata = Interpolation[mindata]
amindata = Interpolation[mindata, InterpolationOrder->1]
amindata = Interpolation[mindata, InterpolationOrder->2]
amindata = Interpolation[mindata, InterpolationOrder->0]
amindata = Interpolation[mindata, InterpolationOrder->5]
amindata = Interpolation[mindata, InterpolationOrder->17]

atab = Table[amindata[x], {x,1,Length[data]}]

ListPlot[data-atab]

Max[Abs[data-atab]]



Exit[]

mod[x_] := Module[{coeff,a},
 coeff= {1,2,3};
 Function[y, Evaluate[x+coeff[[1]]+y]]
]

mod[7]


Exit[]

(* table of inverse normal curve for NADEX vols *)

inv[x_] = y /. Solve[CDF[NormalDistribution[0,1]][y]==x,y][[1]]

Flatten[Table[{N[x,4],N[inv[x],10]},{x,0,1,25/10000}]
 ] >> /home/barrycarter/BCGIT/data/inv-norm-as-list.txt

Exit[]

(* how much worse is linear interpolation for moonpos? *)

t = << /home/barrycarter/BCGIT/sample-data/manytables.txt

Flatten[t[[1,3,3,3]]]

(* the xyz vals from Hermite approx, for 2011 *)

hxval[r_] := t[[1,1,3]][r]
hyval[r_] := t[[1,2,3]][r]
hzval[r_] := t[[1,3,3]][r]

hdec[r_] := ArcSin[hzval[r]/Sqrt[hxval[r]^2+hyval[r]^2+hzval[r]^2]]/Degree

Plot[hdec[r],{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]

(* and the domain, range for the x values of the moon *)

Flatten[t[[1,1,3,3]]]
Flatten[t[[1,1,3,4,3]]]

xm1 = Table[{t[[1,1,3,3,1,i]], t[[1,1,3,4,3,i]]}, {i, Length[t[[1,1,3,3,1]]]}]
ym1 = Table[{t[[1,1,3,3,1,i]], t[[1,2,3,4,3,i]]}, {i, Length[t[[1,1,3,3,1]]]}]
zm1 = Table[{t[[1,1,3,3,1,i]], t[[1,3,3,4,3,i]]}, {i, Length[t[[1,1,3,3,1]]]}]

flatx = Interpolation[xm1, InterpolationOrder -> 1]
flaty = Interpolation[ym1, InterpolationOrder -> 1]
flatz = Interpolation[zm1, InterpolationOrder -> 1]

flatdec[r_] := ArcSin[flatz[r]/Sqrt[flatx[r]^2+flaty[r]^2+flatz[r]^2]]/Degree

Plot[{flatx[r] - hxval[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]
Plot[{flaty[r] - hyval[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]
Plot[{flatz[r] - hzval[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]

Plot[{flatdec[r],hdec[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]
Plot[{flatdec[r]-hdec[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]},
 PlotRange->All]

(* trivial difference, so could've just used linear *)

(* Hermite broken, fixing? *)

l={3.391804676434298,3.183960097542073,2.9043571833527966,2.5667537942969005}

l1=Interpolation[l]
d1[x_] = D[l1[x],x]
d2 = D[d1]

Plot[{l1[x],d1[x]}, {x,1,4}]
Plot[{d1[x]}, {x,1,2}]

Plot[l1[x] - l1[Floor[x]]*h00[x-Floor[x]] -
     h01[x-Floor[x]]*l1[Ceiling[x]]
, {x,1,2}]

Plot[l1[x],{x,1,4}]

Plot[D[l1][y], {y,1,2}]

altintfuncalc[l1, 2.5]

(* confirmed that my implementation of hermite above is broken *)

Plot[{h00[t], h01[t], h10[t], h11[t]}, {t,0,1}]

(* list = {1,4,9,16,25,36} *)

list = Table[x*x*x,{x,1,6}]

func = Interpolation[list]

Plot[func[x], {x,1,6}]

Plot[func[x]-x*x*x, {x,1,6}]

test1[x_] := func[x] - h00[x-Floor[x]]*list[[Floor[x]]] - 
 h01[x-Floor[x]]*list[[Floor[x+1]]]

Plot[test1[x],{x,1,6}]

Solve[{
 h10[.25]*m0 + h11[.25]*m1 == 1.54688,
 h10[.75]*m0 + h11[.75]*m1 == -5.48438
}, {m0,m1}
]

(slopes 27 and 48, NOT 28 and 49 as expected)

Solve[{
 h10[.25]*m0 + h11[.25]*m1 == 0.421875,
 h10[.75]*m0 + h11[.75]*m1 == -3.23438
}, {m0,m1}
]

(slopes 12 and 27, vs 13 and 28 as expected)

Solve[{
 h10[.25]*m0 + h11[.25]*m1 == test1[2.25],
 h10[.75]*m0 + h11[.75]*m1 == test1[2.75]
}, {m0,m1}
]

slopes 3 and 12; expected 1 and 13

Solve[{
 h10[.25]*m0 + h11[.25]*m1 == test1[4.25],
 h10[.75]*m0 + h11[.75]*m1 == test1[4.75]
}, {m0,m1}
]

slopes 48 and 75 vs 49 and 76

Solve[{
 h10[.125]*m0 + h11[.125]*m1 == test1[4.125],
 h10[.375]*m0 + h11[.375]*m1 == test1[4.375]
}, {m0,m1}
]

Solve[{
 h10[.25]*m0 + h11[.25]*m1 == test1[2.25],
 h10[.75]*m0 + h11[.75]*m1 == test1[2.75]
}, {m0,m1}
]

slopes 5 and 30.5 vs 2.5, 28 my calc [when first number is 22]

making it 200

my slopes: -86.5, 28

theirs: -54.3333 and 60.1667

32.167 higher in both cases

so 22 -> 2.5, 200 -> 32.167

67 higher in another case

Table[list[[i]]-list[[j]], {i,1,Length[list]}, {j,1,Length[list]}]

between 8,27 what does my way give you?

h00[.75]*8 + h01[.75]*27 + h10[.75]*13 + h11[.75]*28

(this is for 2.75)

h00[t]*8 + h01[t]*27 + h10[t]*13 + h11[t]*28

yields: 8 + 13*t + 3*t^2 + 3*t^3

h00[t-2]*8 + h01[t-2]*27 + h10[t-2]*13 + h11[t-2]*28

-30 + 37*t - 15*t^2 + 3*t^3

where as using their #s

h00[t]*8 + h01[t]*27 + h10[t]*12 + h11[t]*27

yields (2+t)^3


h00[t]*8 + h01[t]*27 + h10[t]*13 + h11[t]*28 - (t+2)^3

t*(1 - 3*t + 2*t^2) <- hermite polynomial?

left[t_] = t*(1 - 3*t + 2*t^2)

Simplify[left[t] - h00[t]]
Simplify[left[t] - h01[t]]
Simplify[left[t] - h10[t]]
Simplify[left[t] - h11[t]]

h00 is 1 - 3*t^2 + 2*t^3

while leftover is

t - 3*t^2 + 2*t^3

(interesting)

Solve[h00[t]*8 + h01[t]*27 + h10[t]*m0 + h11[t]*m1 - (t+2)^3 == 0, {m0,m1}]

(3^3-1.5^3)/2

Solve[3^3-x^3 == 24,x]

Interpolation[{8,27,64,125}]

Plot[5*h10[t] + 7*h11[t], {t,0,1}]


myway[t_] = h00[t]*8 + h01[t]*27 + h10[t]*13 + h11[t]*28

hmmm, why doesn't 28 show up in derv

myway[t_] = h00[t]*27 + h01[t]*8 + h10[t]*28 + h11[t]*13

test1[t_] = h10[t]*28 + h11[t]*13

Plot[D[test1][t], {t,0,1}]

28*(1 - t)^2*t + 13*(-1 + t)*t^2 <- derv of my way

Plot[27*(1 - t)^2*t + 12*(-1 + t)*t^2, {t,0,1}]

Plot[(27*(1 - t)^2*t + 12*(-1 + t)*t^2)-D[test1][t], {t,0,1}]

derv1[t_] = D[test1[t],t]

derv2[t_] = D[derv1[t],t]

dtheir[t_] = D[27*(1 - t)^2*t + 12*(-1 + t)*t^2, t]
d2their[t_] = D[dtheir[t],t]

(* wow, mathematica lets you do general interpolation! *)

f = Interpolation[{a,b,c,d}]

Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[2+1/4],
 h10[3/4]*m0 + h11[3/4]*m1 == f[2+3/4]
}, {m0,m1}
]

f = Interpolation[{a,b,c,d,e,f}]

Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[1/4],
 h10[3/4]*m0 + h11[3/4]*m1 == f[3/4]
}, {m0,m1}
]

Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[2+1/4],
 h10[3/4]*m0 + h11[3/4]*m1 == f[2+3/4]
}, {m0,m1}
]

Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[3+1/4],
 h10[3/4]*m0 + h11[3/4]*m1 == f[3+3/4]
}, {m0,m1}
]




Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[2+1/4],
 h10[3/4]*m0 + h11[3/4]*m1 == f[2+3/4]
}, {m0,m1}
]

Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[3+1/4],
 h10[3/4]*m0 + h11[3/4]*m1 == f[3+3/4]
}, {m0,m1}
]

f = Interpolation[{
 {7, y0},
 {8, y1},
 {9, y2},
 {10, y3},
 {11, y4},
 {12, y5}
}]


Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[9+1/4],
 h10[3/4]*m0 + h11[3/4]*m1 == f[9+3/4]
}, {m0,m1}
]

f = Interpolation[{
 {7, y0},
 {7.01, y1},
 {7.02, y2},
 {7.03, y3},
 {7.04, y4},
 {7.05, y5}
}]

Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[7.02+1/400],
 h10[3/4]*m0 + h11[3/4]*m1 == f[7.02+3/400]
}, {m0,m1}
]

f = Interpolation[{
 {7, y0},
 {8, y1},
 {15, y2},
 {22, y3},
 {115, y4},
 {116, y5}
}]

cubic[x_] = (Random[]-.5) + (Random[]-.5)*x + (Random[]-.5)*x*x + 
 (Random[]-.5)*x*x*x

Plot[cubic[x],{x,0,1}]

(* my own spline? (quadratic?) *)

(*

suppose (a5,a6) is the interval of interest

(a5+a6)/2 = constant

(a6-a5)/len = first derv

((a6-a5)/len - (a5-a4)/len + ((a6-a5)/len - (a7-a6)/len))/2

(1,3,3,1)/2

*)

Solve[{a==a1, c/2*1/2*1/2 + b + a == a2}, {a,b}]

Solve[{c/2*1/2*1/2 - b/2 + a == a1,
       c/2*1/2*1/2 + b/2 + a == a2
}, {a,b}]

Table[a[i], {i,1,20}]

(* first differences *)
ad1[i_, f_] = f[i]-f[i-1]

(* second diffs *)
ad2[i_, f_] = ad1[i,f] - ad1[i-1,f]

(* third diffs *)
ad3[i_, f_] = ad2[i,f] - ad2[i-1,f]

Table[Sin[i/20], {i,0,100}]
Table[ad1[i, Sin[#/20] &], {i,0,100}]
Table[ad2[i, Sin[#/20] &], {i,0,100}]
Table[ad3[i, Sin[#/20] &], {i,0,100}]

Table[Sin[i/20], {i,0,100}]

bd1[i_, f_] = (f[i+1] - f[i-1])/2
bd2[i_, f_] = (bd1[i+1, f] - bd1[i-1, f])/2
bd3[i_, f_] = (bd2[i+1, f] - bd2[i-1, f])/2

f'''[x] == c3
f''[x] == c3*x + c2 
 
slope[i_] = a[i+1] - a[i]

slope2[i_] = (slope[i+1] - slope[i-1])/2

slope3[i_] = (slope2[i+1] - slope2[i-1])/2

consider [1, 8, 27, 64, 125, 216]

and the interval 27,64 (the 2.5th interval in Perl, i=2 above)

slope = 37

slope2 = 21

slope3 = (-1 + 8 + 2*27 - 2*64 - 125 + 216)/4 = 6

rebuilding

6x + C <- second derv

6x + 21 <- second derv

3*x^2 + 21 x + 37 <- first der

f[x_] = x^3 + 21/2*x*x + 37*x + 91/2

Plot[f[x] - (x+3.5)^3, {x,-.5,.5}]

bad... instead, interval around each point

consider [1, 8, 27, 64, 125, 216]

and 4^3==64

slope[i_] = (f[i+1] - f[i-1])/2

slope2[i_] = (slope[i+1]-slope[i-1])/2

slope3[i_] = (slope2[i+1]-slope2[i-1])/2

so for 64

slope3 = (-1 + 3*27 - 3*125 + 343)/8

slope3 is 6

slope2 is (8 - 2*64 + 216)/4

slope2 is 24

slope1 is 49

constant is 64

g[x_] = 64 + 49*x + 12*x*x + x*x*x

Plot[g[x],{x,-.5,.5}]

Plot[g[x]-(4+x)^3,{x,-.5,.5}]

Table[g[x], {x,-.5,.5,.1}]

now the interval for 27

slope3 = (0 + 3*8 - 3*64 + 216)/8 == 6

slope2 = (1 - 2*27 + 125)/4 == 18

slope = 28

constant = 27

h[x_] = 27 + 28*x + 9*x*x + x*x*x

Plot[h[x],{x,-.5,.5}]

DSolve[{
 f''[x][-1/2] == a,
 f'[x][-1/2] == b,
 f[-1/2] == c,
 f''''[x] == 0,
 f[0] ==d},
f, {a,b,c,d}]

j[x_] = a3*x^3 + a2*x^2 + a1*x + a0

Solve[{
 j''[-1/2] == c2,
 j'[-1/2] == c1,
 j[-1/2] == c0,
 j[0] == c3
}, {a0,a1,a2,a3}]

consider {27,64,125}

constantleft = 91/2
constantright = 189/2

constant average ai, ai-1 and ai+1, ai

slope: left: (a[i]-a[i-2])/2 left (a[i+1] - a[i+1])/2 right

Solve[{
 j[-1/2] == c0,
 j[0] == c1,
 j[1/2] == c2,
 j'[-1/2] == c3,
 j'[1/2] == c4
}, {a0,a1,a2,a3}]

Solve[{
 j[0] == c1,
 j'[-1/2] == c4
 j'[1/2] == c2
}, {a0,a1,a2,a3}]

Solve[{
 j[0] == c0,
 j[-1] == c1,
 j[1] == c2
}, {a0,a1,a2,a3}]

j[x_] = a4*x^4 + a3*x^3 + a2*x^2 + a1*x + a0

Solve[{
 j[-1/2] == c0,
 j[0] == c1,
 j[1/2] == c2,
 j'[-1/2] == c3,
 j'[1/2] == c4
}, {a0,a1,a2,a3,a4}]

for [1,8,27,64,125,216], the 27 interval


Solve[{
 j[-1/2] == (8+27)/2,
 j[0] == 27,
 j[1/2] == (27+64)/2,
 j'[-1/2] == 27-8,
 j'[1/2] == 64-27
}, {a0,a1,a2,a3,a4}]

test1[x_] = j[x] /. %[[1]]

Plot[test1[x] - (x+3)^3,{x,-.5,.5}]

Plot[test1[x],{x,-.5,.5}]

Solve[{
 j[-1/2] == (27+64)/2,
 j[0] == 64,
 j[1/2] == (64+125)/2,
 j'[-1/2] == 64-27,
 j'[1/2] == 125-64
}, {a0,a1,a2,a3,a4}]

test2[x_] = j[x] /. %[[1]]

Plot[test2[x],{x,-.5,.5}]

Plot[If[x>3.5, test2[x-4], test1[x-3]] - x^3, {x,2.5,4.5}]

j[x_] = a4*x^4 + a3*x^3 + a2*x^2 + a1*x + a0

j[x_] = a3*x^3 + a2*x^2 + a1*x + a0

Solve[{
 j[-1/2] == (f[-1]+f[0])/2,
 j[0] == f[0],
 j[1/2] == (f[0]+f[1])/2,
 j'[-1/2] == f[0]-f[-1],
 j'[1/2] == f[1]-f[0]
}, {a0,a1,a2,a3,a4}]

(* how about 2nd derv matching? *)

Solve[{
 j''[-1/2] == (f[1]-f[0]) - (f[-1]-f[-2])
 j[0] == f[0],
 j''[1/2] == (f[2]-f[1]) - (f[0]-f[-1])
}, {a0,a1,a2,a3}]

test2[x_] = j[x] /. %[[1]]

Solve[{
 j''[-1/2] == (f[i+1]-f[i]) - (f[i-1]-f[i-2])
 j[0] == f[i],
 j''[1/2] == (f[i+2]-f[i+1]) - (f[i]-f[i-1])
}, {a0,a1,a2,a3}]

test4[x_,i_] = j[x] /. %[[1]]

D[test4[x,i],x] /. x -> -1/2

D[test4[x,i-1],x] /. x -> 1/2

Solve[(D[test4[x,i],x] /. x -> -1/2) == (D[test4[x,i-1],x] /. x -> 1/2), a1]

pre[x_, i_] = a3*x^3 + a2*x^2 + a1*x + f[i-1]
me[x_, i_] = b3*x^3 + b2*x^2 + b1*x + f[i]
post[x_, i_] = c3*x^3 + c2*x^2 + c1*x + f[i+1]

D[pre[x,i],x,x] /. x -> 1/2
D[me[x,i],x,x] /. x -> -1/2

D[pre[x,i],x] /. x -> 1/2
D[me[x,i],x] /. x -> -1/2



Solve[{
 2*a2 + 3*a3 == 2*b2 - 3*b3,
 a1 + a2 + 3/4*a3 == b1 - b2 + 3/4*b3,
 a1/2 + a2/4 + a3/8 + f[i-1] == -b1/2 + b2/4 - b3/8 + f[i],
 2*b2 + 3*b3 == 2*c2 - 3*c3,
 b1 + b2 + 3/4*b3 == c1 - c2 + 3/4*c3,
 b1/2 + b2/4 + b3/8 + f[i] == -c1/2 + c2/4 - c3/8 + f[i+1]
}, {a1,a2,a3,b1,b2,b3,c1,c2,c3}]


Solve[{
 a1 + a2 == b1 - b2,
 a1/2 + a2/4 + f[i-1] == -b1/2 + b2/4 + f[i],
 b1 + b2 == c1 - c2,
 b1/2 + b2/4 + f[i] == -c1/2 + c2/4 + f[i+1]
}, {a1,a2,a3,b1,b2,b3,c1,c2,c3}]


Solve[{
 2*a2 + 3*a3 == 2*b2 - 3*b3,
 a1 + a2 + 3/4*a3 == b1 - b2 + 3/4*b3,
 a1/2 + a2/4 + a3/8 + f[i-1] == -b1/2 + b2/4 - b3/8 + f[i],
 2*b2 + 3*b3 == 2*c2 - 3*c3,
 b1 + b2 + 3/4*b3 == c1 - c2 + 3/4*c3,
 b1/2 + b2/4 + b3/8 + f[i] == -c1/2 + c2/4 - c3/8 + f[i+1]
}, {b1,b2,b3}]

Solve[{

-5 b1 + 4 b2 - 3 b3 - 6 (f[i-1] - f[i]) ==
97 c1 - 88 c2 + 72 c3 - 6 (f[-1 + i] - 18 f[i] + 17 f[1 + i]),

12 b1 - 11 b2 + 9 b3 + 12 (f[i-1] - f[i]) ==
-264 c1 + 241 c2 - 198 c3 + 12 (f[-1 + i] - 24 f[i] + 23 f[1 + i]),

-8 b1 + 8 b2 - 7 b3 - 8 (f[i-1] - f[i]) ==
192 c1 - 176 c2 + 145 c3 - 8 (f[-1 + i] - 26 f[i] + 25 f[1 + i]),

a1 == -5 b1 + 4 b2 - 3 b3 - 6 (f[i-1] - f[i]),

a2 == 12 b1 - 11 b2 + 9 b3 + 12 (f[i-1] - f[i]),

a3 == -8 b1 + 8 b2 - 7 b3 - 8 (f[i-1] - f[i])

}, {a1,a2,a3,b1,b2,b3,c1,c2,c3}]

(* http://www.physicsforums.com/showthread.php?t=690745 *)

f[x_,y_] = x*Sqrt[1+y^2]+y*Sqrt[1+x^2]

f[f[x,y],z]
f[x,f[y,z]]

f[f[x,y],z]/f[x,f[y,z]]

g[x_,y_,z_] = f[f[x,y],z]-f[x,f[y,z]]

g[x,y,z] /. {x->r*Cos[th]*Cos[ph], y->r*Sin[th]*Cos[ph], z->r*Sin[ph]}
Simplify[%,Member[{th,ph,r},Reals]]

t4 = N[Table[Sin[3.17*2*Pi*x/200+.9752], {x,1,200}]]

(* partial transforms *)

t4 = N[Table[Sin[1/3.17*2*Pi*x/2000+.9752], {x,1,2000}]]
t8[t_] = Interpolation[t4][t]
t9[t_] = D[t8[t],t,t]
t6 = Table[t4[[i]]-t4[[i-1]], {i,2,Length[t4]}]
t7 = Table[t6[[i]]-t6[[i-1]], {i,2,Length[t6]}]


t5 = Fourier[t4]
ListPlot[Abs[Take[t5,20]], PlotRange->All]

Plot[superfour[t4,2][x],{x,1,2000}]
Plot[superfour[t4,3][x],{x,1,2000}]

f[x_] = a + b*Cos[c*x-d] + e*Cos[f*x-g]

g[x_] = f'[x]/f'''[x]

f[x]/D[f[x],x,x]

D[f[x],x,x]/D[f[x],x,x,x,x]
D[f[x],x]/D[f[x],x,x,x]

(* enveloping functions *)

g[x_] = (a + b*Cos[c*x-d])*(f + g*Cos[h*x-j])

g'[x]/g'''[x]

g'[x]
g[x]/g''[x]

g[x_] = Cos[x]*Cos[x*9.315-1]

Plot[Cos[50*x]*Cos[x/2],{x,0,2*Pi}]

a1 = Table[Cos[50*(x-1.1)]*Cos[13*(x-2.7)],{x,0,10*Pi,.01}];
ListPlot[Abs[Take[Fourier[a1],1000]], PlotRange->All]

(* trying to figure out http://reference.wolfram.com/mathematica/ref/Fourier.html *)

data = Table[N[753 + 919*Sin[x/623 - 125]], {x, 1, 7829}];


f2[x_] = Interpolation[data][x]

f1[x_] = m + b*Cos[freq*2*Pi/n*x-d]
diffs = Table[data[[i]] - f1[i], {i,1,Length[data]}]

ArcCos[(Cos[n*x+a]+Cos[n*x+b])/2/n]

Solve[Cos[n*x+a]+Cos[n*x+b] == d*Cos[n*x+c], x, c]

Cos[3*x + Pi/15] + Cos[3*x + Pi/10]

Plot[ArcCos[(Cos[3*x + Pi/5] + Cos[3*x + Pi/6])/2], {x,0,2*Pi}]

Maximize[Cos[3*x+0.72]+Cos[3*x+0.41],x]

normal maxed at -.72/3 or -phase/mult

Plot[Cos[3*x+0.72]+Cos[3*x+0.41] - Cos[3*x+0.355125],{x,0,2*Pi}]

Im[FourierTransform[Cos[n*x+a]+Cos[n*x+b],x,t]]

guess: average of the phase shift (yes it is)





