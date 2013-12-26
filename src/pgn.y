/* PGN Parser Generator */

%lex

file  [a-h]
rank  [1-8]
piece [RNBKQ]


%%

\s*\{[^\}]*\}\s*                        return 'COMMENTARY' /* grab commentaries with surrounding whitespaces */
\s*";"[^\n]*\s*                         return 'COMMENTARY'
\s+                                     /* skip whitespaces */
\"(?:'\\'[\\"]|[^\\"])*\"               yytext = yytext.substr(1,yyleng-2); return 'STRING'
"1/2-1/2"                               return 'DRAW'
"1-0"                                   return 'WHITE_WINS'
"0-1"                                   return 'BLACK_WINS'
"O-O-O"                                 return 'QCASTLING'
"O-O"                                   return 'KCASTLING'
"0-0-0"                                 return 'QCASTLING'
"0-0"                                   return 'KCASTLING'
(?:[0-9]|[1-9][0-9]+)\b                 return 'INTEGER'


{piece}?{file}?{rank}?x?{file}{rank}(?:"="[RNBQ])?(?:(?:\+(?=$|[^-]))|"#")? return 'SAN'
"."                                     return '.'
"*"                                     return '*'
"["                                     return '['
"]"                                     return ']'
"("                                     return '('
")"                                     return ')'
"<"                                     return '<'
">"                                     return '>'
"+-"                                    return 'NAG'
"-+"                                    return 'NAG'
"!!"                                    return 'NAG'
"!?"                                    return 'NAG'
"?!"                                    return 'NAG'
"??"                                    return 'NAG'
"!"                                     return "NAG"
"?"                                     return "NAG"
"‼"                                     return "NAG"
"⁇"                                     return "NAG"
"⁉"                                     return "NAG"
"⁈"                                     return "NAG"
"□"                                     return "NAG"
"="                                     return "NAG"
"∞"                                     return "NAG"
"⩲"                                     return "NAG"
"⩱"                                     return "NAG"
"±"                                     return "NAG"
"∓"                                     return "NAG"
"⨀"                                     return "NAG"
"⟳"                                     return "NAG"
"→"                                     return "NAG"
"↑"                                     return "NAG"
"⇆"                                     return "NAG"
\$[1-9][0-9]{0,2}                       return "NAG"
[0-9A-Za-z][0-9A-Za-z_+#=:-]*           return 'SYMBOL'
<<EOF>>                                 return 'EOF'
.                                       return 'INVALID'

/lex

%start PGN

%%  /* GRAMMAR */

PGN
    : EOF
        {$$ = []}
    | Database
        {$$ = $1;return $$;}
    ;

Database
    : Game
        {$$ = [$1]}
    | Database Game
        {$$ = $1; $1.push($2)}
    ;

Game
    : TagList MoveText
        {$$ = {header: $1, moves: $2[0], terminator: $2[1]}}
    | TagList EOF
        {$$ = {header: $1, moves: [], terminator: null}}
    | MoveText
        {$$ = {header: null, moves: $1[0], terminator: $1[1]}}
    ;

TagList
    : Tag
        {$$ = {}; $$[$1[0]]=$1[1];}
    | TagList Tag
        {$$ = $1; $1[$2[0]]=$2[1];}
    ;

Tag
    : '[' SYMBOL PGNString ']'
        {$$ = [$2, $3];}
    ;

MoveText
    : GameTerminator EOF
        {$$ = [[], $1]}
    | GameTerminator
        {$$ = [[], $1]}
    | MoveList GameTerminator
        {$$ = [$1, $2]}
    | MoveList GameTerminator EOF
        {$$ = [$1, $2]}
    | MoveList EOF
        {$$ = [$1, null];}
    ;

MoveList
    : Move
        {$$ = [$1]}
    | MoveList Move
        {$$ = $1; $1.push($2);}
    ;

Move
    : NumberedMove
    | SANMove
        {$$ = {type: 'move', san: $1}}
    | COMMENTARY
        {$$ = {type: 'commentary', commentary: $1}}
    | RAV
    | NAG
        {$$ = {type: 'nag', value: $1}}
    ;

NumberedMove
    : MoveNumber SANMove
        {$$ = {type: 'move', number: $1, san: $2}}
    ;

MoveNumber
    : INTEGER PeriodSequence
        {$$ = (Number($1)-1) * 2 + ($2.length >= 3 ? 1 : 0);}
    | INTEGER
        {$$ = (Number($1)-1)*2;}
    ;

PeriodSequence
    : '.'
        {$$ = $1}
    | PeriodSequence '.'
        {$$ = $1 + $2}
    ;

SANMove
    : QCASTLING
    | KCASTLING
    | SAN
    ;

RAV
    : '(' MoveList ')'
        {$$ = {type: 'nodelist', moves: $2}}
    ;

GameTerminator
    : '*'
    | BLACK_WINS
    | WHITE_WINS
    | DRAW
    ;

PGNString
    : STRING
        { // replace escaped characters with actual character
          $$ = yytext.replace(/\\(\\|")/g, "$"+"1");
        }
    ;
