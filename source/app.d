import std.stdio;
import dpg;

string st = `num :
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


void main()
{
	Lexer l = new Lexer(st);

	Token[] tokens;

	Token t = l.next;
	while (t.type != TokenType.EOF) {
		//t.dumpToken;
		tokens ~= t;
		t=l.next;
	}

	Parser p = new Parser(tokens);
	auto tree = p.parse();

	writeln(tree.build_string);
}

void dumpToken(Token token) {
	writefln("\"%s\" [%s]: s%s e%s", token.val, token.type, token.start, token.end);
}