Notes
===

The following is the BNF for EBNF, at least my subset of it:
```
root:
	rule*;

rule:
	IDENTIFIER ':' or_block ';'

or_block:
	suffixed_block (OR or_block)?;

suffixed_block:
	(paren_block | selection) (OPT|NONEPLUS|ONEPLUS|NOT)?
	| ε; // epsilon, or empty

paren_block:
	OP_PAREN or_block CL_PAREN;

/* - this is a token, not a parse rule
selection:
	OP_SELECT CHARS* CL_SELECT;
*/
```

With the lexical tokens being:
```
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

Example Grammar
---
```
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