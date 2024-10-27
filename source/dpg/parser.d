module dpg.parser;

import std.container.dlist;
import std.stdio:writefln;

import dpg.token;
import dpg.ast;

class ParseError {
	this(string s, size_t l, size_t c) {
		err = s; line = l; col = c;
	}

	string err;
	size_t line, col;
}


class Parser {
	this(Token[] tok_stream) {
		stream = tok_stream;
	}

	AST parse() {
		Root root = new Root;
		return (parse_root(root)) ? root : null;
	}

	

	private {
		bool parse_root(ref Root tree) {
			debug entry("root");

			while (stream[index].type != TokenType.EOF) {
				auto rule = parse_rule;
				if (rule is null) {
					handleErrors();
					clearErrors();
					continue;
				}
				tree.addRule(rule);
			}

			debug exit("root");
			return (tree.children.length > 0);
		}

		Rule parse_rule() {
			debug entry("rule");

			Rule rule = new Rule;

			if (!expect(TokenType.Identifier)) {
				push_error("Expected identifier at start of rule");
				index++;
				return rule;
			}
			rule.name = stream[index].val;

			if (!expect(TokenType.RuleSep)) {
				push_error("Expected separator to split rule name and body");
				return rule;
			}
			rule.separator = stream[index].val;

			rule.addBody(parse_or_block);

			if (!expect(TokenType.RuleEnd)) {
				push_error("rule should always end with a semicolon");
				return rule;
			}

			debug exit("rule");
			rule.is_valid = true;
			return rule;
		}

		OrBlock parse_or_block() {
			OrBlock or = new OrBlock;
			SuffixBlock suffix;

			suffix = parse_suffix_block;
			if (!suffix.is_valid) {
				push_error("Expected suffix block");
			}
			while (suffix.is_valid) {
				or.addLeft(suffix);
				suffix = parse_suffix_block;
			}

			while (stream[index].type == TokenType.Or) {
				index++;
				suffix = parse_suffix_block;
				while(suffix.is_valid) {
					or.addRight(suffix);
					suffix = parse_suffix_block;
				}
			}

			return or;
		}



		SuffixBlock parse_suffix_block() {
			SuffixBlock suffix = new SuffixBlock;
			ParenBlock paren;

			if (stream[index].type == TokenType.Selection) {
				suffix.selection = stream[index];
				index++;
			}
			else if ((paren = parse_paren_block).is_valid)
				suffix.addChild(paren);
			else { // the epsilon appears here
				suffix.is_valid = true;
				return suffix;
			}

			switch (stream[index].type) {
				case TokenType.ZeroOrOne:
				case TokenType.OneOrMore:
				case TokenType.ZeroOrMore:
				case TokenType.Not: suffix.suffix = stream[index]; index++; goto default;
				default: suffix.is_valid = true;
			}

			return suffix;
		}

		ParenBlock parse_paren_block() {
			ParenBlock paren = new ParenBlock;
			OrBlock or = new OrBlock;

			if (stream[index].type != TokenType.GroupOp)
				return paren;
			
			or = parse_or_block;
			if (!or.is_valid) {
				push_error("Expected valid section with parentheses");
				return paren;
			}
			paren.addChild(or);

			if (stream[index].type != TokenType.GroupCl)
				return paren;
			
			paren.is_valid = true;
			return paren;
		}




		bool expect(TokenType type) {
			return (stream[index].type == type);
		}

		void push_error(string error){
			error_stack.insertFront(
				new ParseError(error, stream[index].line, stream[index].column)
			);
		}

		void handleErrors() {
			foreach (ParseError error; error_stack)
			{
				writefln("[%s, %s] Error: %s", error.line, error.col, error.err);
			}
		}

		void pop_error() {
			if (!error_stack.empty) error_stack.removeBack;
		}
		void clearErrors() {
			error_stack.clear;
		}
	}
	private {
		Token[] stream;
		size_t index;
		size_t recursion_depth = 20, current_depth;
		DList!ParseError error_stack;

		debug string dbg_indent;
		debug void indent() {dbg_indent =  " " ~ dbg_indent;}
		debug void dedent() {dbg_indent = (dbg_indent.length) ? dbg_indent[0..$-1] : "";}
		debug void entry(string s) {writeln(dbg_indent~s); indent;}
		debug void exit(string s) {dedent; writeln(dbg_indent~s);}
	}
}