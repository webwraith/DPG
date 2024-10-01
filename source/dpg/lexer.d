module dpg.lexer;

/**

The lexer would normally use a regex for matching specific tokens
How do I generate a specific and fast sequence reader?

**/

import std.stdio;
import std.uni;
import std.algorithm.searching;

struct Token {
	string val;
	size_t start, end;
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

	EOF = "End of File" // end of file
}

class Lexer {

	this(string str) {
		line = str;
	}

	void skipWs() {
		while (current < line.length && line[current].isWhite) {
			current++;
		}
	}

	Token next() {
		Token result;
		
		skipWs;
		result.start = current;

		if (current >= line.length)
			result.type = TokenType.EOF;
		else {
			// process the token
			result.start = current;
			switch (line[current]) {
				case '"' :
				case '\'': readString(result, line[current]);				break;
				case '(' : result.type = TokenType.GroupOp;		current++;	break;
				case ')' : result.type = TokenType.GroupCl;		current++;	break;
				case '[' : readSelection(result);							break;
				case '?' : result.type = TokenType.ZeroOrOne; 	current++;	break;
				case '*' : result.type = TokenType.ZeroOrMore; 	current++;	break;
				case '+' : result.type = TokenType.OneOrMore; 	current++;	break;
				case '|' : result.type = TokenType.Or;			current++;	break;
				case ':' : result.type = TokenType.RuleSep;		current++;	break;
				case ';' : result.type = TokenType.RuleEnd;		current++;	break;
				default : {
					if (line[current].isAlpha || line[current] == '_')
						readIdentifier(result);
					else {
						result.type = TokenType.Unrecognised;
						current++;
					}
					
				}
			}

			if (result.end == 0)
				result.end = current;
		}
		
		if (result.type != TokenType.EOF)
			result.val = line[result.start..result.end];

		return result;
	}

	private void readString(ref Token result, char closing) {
		auto end = current+1;
		
		while (end < line.length && line[end] != closing)
			end += (line[end]=='\\') ? 2:1;

		current = result.end = end+1;
		result.type = TokenType.String;
	}

	private void readIdentifier(ref Token result) {
		auto end = current + 1;
		while (end < line.length && (line[end] == '_' || line[end].isAlphaNum))
			end ++;
		
		current = result.end = end;
		result.type = TokenType.Identifier;
	}

	private void readSelection(ref Token result) {
		auto end = current + 1;
		
		while (end < line.length && line[end] != ']')
			end ++;
		
		current = result.end = end+1;
		result.type = TokenType.Selection;
	}

	private string line;
	private size_t current;
}