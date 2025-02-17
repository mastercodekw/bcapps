(* https://www.quora.com/What-is-%E2%80%A6log-log-log-2-%E2%80%A6 *)

f[0] = N[2];

f[x_] := f[x] = Log[f[x-1]]

Table[{n,f[n]}, {n,0,50}]

Superscript["Log","(n)"] // TeXForm

[math]
                  \begin{array}{|c|c|}
\hline
n & \text{ln}^{\text{(n)}}2 \\
\hline
                   0 & 2. \\
                   1 & 0.693147 \\
                   2 & -0.366513 \\
                   3 & -1.00372+3.14159 i \\
                   4 & 1.19333\, +1.88004 i \\
                   5 & 0.80056\, +1.00523 i \\
                   6 & 0.250805\, +0.898256 i \\
                   7 & -0.069765+1.29852 i \\
                   8 & 0.262664\, +1.62447 i \\
                   9 & 0.498087\, +1.41049 i \\
                   10 & 0.402697\, +1.23134 i \\
                   11 & 0.258906\, +1.25472 i \\
                   12 & 0.247761\, +1.36731 i \\
                   13 & 0.328996\, +1.39154 i \\
                   14 & 0.357605\, +1.33863 i \\
                   15 & 0.326116\, +1.30975 i \\
                   16 & 0.299912\, +1.32677 i \\
                   17 & 0.307663\, +1.34849 i \\
                   18 & 0.324355\, +1.34648 i \\
                   19 & 0.325698\, +1.33441 i \\
                   20 & 0.317422\, +1.3314 i \\
                   21 & 0.313873\, +1.33675 i \\
                   22 & 0.317077\, +1.34017 i \\
                   23 & 0.320031\, +1.33847 i \\
                   24 & 0.319328\, +1.3361 i \\
                   25 & 0.31753\, +1.3362 i \\
                   26 & 0.317295\, +1.33749 i \\
                   27 & 0.318168\, +1.33787 i \\
                   28 & 0.318586\, +1.33732 i \\
                   29 & 0.318265\, +1.33693 i \\
                   30 & 0.317936\, +1.33709 i \\
                   31 & 0.317995\, +1.33735 i \\
                   32 & 0.318189\, +1.33735 i \\
                   33 & 0.318223\, +1.33721 i \\
                   34 & 0.318132\, +1.33717 i \\
\hline
                  \end{array}
[/math]
