define(__pattern,
`
  \begin{tikzpicture}
    \node (A) {
\begin{pythoncodeblock}[mathescape=false]$1\end{pythoncodeblock}
    };
    \node[draw, anchor=west, rectangle, fill=codeBackground, xshift=0.445pt,
    yshift=0.515pt,
    fill=blue!20!white
    ] (B) at
    (A.south west) {\scriptsize Pattern};
  \end{tikzpicture}
')

define(__rule,
`
  \begin{tikzpicture}
    \node (A) {
\begin{yamlcodeblock}[mathescape=false]$1\end{yamlcodeblock}
    };
    \node[draw, anchor=west, rectangle, fill=codeBackground, xshift=0.445pt,
    yshift=0.515pt,
    fill=green!20!white
    ] (B) at
    (A.south west) {\scriptsize Rule};
  \end{tikzpicture}
')


define(__target,
`
  \begin{tikzpicture}
    \node (A) {
\begin{pythoncodeblock}[mathescape=false]$1\end{pythoncodeblock}
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

define(__compare_rule,
`
\begin{center}
  \begin{minipage}{0.47\textwidth}

__rule(<<<$1>>>)

  \end{minipage}
  \hspace{10pt}
  \begin{minipage}{0.47\textwidth}

__target(<<<$2>>>)

  \end{minipage}
\end{center}
')




define(__compare_30,
`
\begin{center}
  \begin{minipage}{0.3\textwidth}

__pattern(<<<$1>>>)

  \end{minipage}
  \hspace{10pt}
  \begin{minipage}{0.64\textwidth}

__target(<<<$2>>>)

  \end{minipage}
\end{center}
')

define(__useless,`')

changequote(<<<, >>>)