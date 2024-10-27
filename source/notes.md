Notes
===

The following is the BNF for EBNF, at least my subset of it:
```EBNF
root:
	rule*;

rule:
	IDENTIFIER ':' or_block ';'

or_block:
	suffixed_block+ (OR suffixed_block+)*;

suffixed_block:
	(paren_block | SELECTION) (OPT|NONEPLUS|ONEPLUS|NOT)?
	| ; // ε, epsilon, or empty

paren_block:
	OP_PAREN or_block CL_PAREN;
```

With the lexical tokens being:
```EBNF
OR: '|';
OPT: '?';
NONEPLUS: '*';
ONEPLUS: '+';
NOT: '!';
OP_PAREN: '(';
CL_PAREN: ')';
OP_SELECT: '[';
CL_SELECT: ']';
CHARS: // any printable character that isn't ']'
```

Attempting to collapse this into one rule gives us the following:

```EBNF
root:
	(IDENTIFIER ':' ((paren_block | SELECTION) (OPT|NONEPLUS|ONEPLUS|NOT)?
	| ) (OR ((paren_block | SELECTION) (OPT|NONEPLUS|ONEPLUS|NOT)?
	| ))* ';')*;

paren_block:
	OP_PAREN or_block CL_PAREN;
```

As can be seen, this leaves us with a cyclic rule. I'm not sure if there is a way to remove this to collapse to a single rule.

Example Grammar
---
```EBNF
num :
	SIGN? ('#B'BINNUM|'#X'HEXNUM | '#O' OCTNUM | DECNUM('.' DECNUM)?);

SIGN:
	'+'|'-';

DECNUM:
	[0123456789][0123456789_]*;

BINNUM:
	[01][01_]*;

HEXNUM:
	[0123456789ABCDEF][0123456789ABCDEF_]*;

OCTNUM:
	[01234567][01234567_]*;

```