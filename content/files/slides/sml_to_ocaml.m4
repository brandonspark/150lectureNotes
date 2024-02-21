
define(__sml,
`
  \begin{tikzpicture}
    \node (A) {
\begin{codeblock}$1\end{codeblock}
    };
    \node[draw, anchor=west, rectangle, fill=codeBackground, xshift=0.425pt,
    yshift=0.515pt,
    fill=blue!20!white
    ] (B) at
    (A.south west) {\scriptsize SML};
  \end{tikzpicture}
')

define(__ocaml,
`
  \begin{tikzpicture}
    \node (A) {
\begin{ocamlcodeblock}$1\end{ocamlcodeblock}
    };
    \node[draw, anchor=west, rectangle, fill=codeBackground, xshift=0.425pt,
    yshift=0.515pt,
    fill=red!20!white
    ] (B) at (A.south west) {\scriptsize OCaml};
  \end{tikzpicture}
')

define(__compare,
`
\begin{center}
  \begin{minipage}{0.47\textwidth}

__sml(<<<$1>>>)

  \end{minipage}
  \hspace{10pt}
  \begin{minipage}{0.47\textwidth}

__ocaml(<<<$2>>>)

  \end{minipage}
\end{center}
')

changequote(<<<, >>>)