import std.stdio;
import dpg;

string oldest_st = `num :
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
`;

string old_st = `num:4`;

string st = `num :
	SIGN? ('#B'BINNUM|'#X'HEXNUM | '#O' OCTNUM | DECNUM('.' DECNUM)?);`;

void main()
{
	Lexer l;
	l = new Lexer(st);

	Token[] tokens;

	Token t = l.next;
	while (t.type != TokenType.EOF) {
		t.dumpToken;
		tokens ~= t;
		t=l.next;
	}
}

void dumpToken(Token token) {
	writefln("\"%s\" [%s]: s%s e%s", token.val, token.type, token.start, token.end);
}