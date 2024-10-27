module dpg.token;

struct Token {
	string val;
	size_t start, end;
	size_t line, column;
	TokenType type;
}

enum TokenType : string
{
	Unrecognised = "Unrecognised Token", // Used when none of the other types are valid

	Identifier = "Identifier",
	String = "String", //"" or ''
	GroupOp = "GroupOp", //(
	GroupCl = "GroupCl", //)
	Selection = "Selection", //[
	ZeroOrOne = "ZeroOrOne", //?
	ZeroOrMore = "ZeroOrMore", //*
	OneOrMore = "OneOrMore", //+
	Or = "Or", //|
	RuleSep = "RuleSep", // :
	RuleEnd = "RuleEnd", // ;
	Not = "Not",

	EOF = "End of File" // end of file
}