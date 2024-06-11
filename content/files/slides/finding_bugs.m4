define(__pattern,
`
  \begin{tikzpicture}
    \node (A) {
\begin{pythoncodeblock}$1\end{pythoncodeblock}
    };
    \node[draw, anchor=west, rectangle, fill=codeBackground, xshift=0.445pt,
    yshift=0.515pt,
    fill=blue!20!white
    ] (B) at
    (A.south west) {\scriptsize Pattern};
  \end{tikzpicture}
')

define(__target,
`
  \begin{tikzpicture}
    \node (A) {
\begin{pythoncodeblock}$1\end{pythoncodeblock}
    };
    \node[draw, anchor=west, rectangle, fill=codeBackground, xshift=0.5pt,
    fill=orange!30!white
    ] (B) at
    (A.south west) {\scriptsize Target};
  \end{tikzpicture}
')

define(__compare,
`
\begin{center}
  \begin{minipage}{0.47\textwidth}

__pattern(<<<$1>>>)

  \end{minipage}
  \hspace{10pt}
  \begin{minipage}{0.47\textwidth}

__target(<<<$2>>>)

  \end{minipage}
\end{center}
')

changequote(<<<, >>>)