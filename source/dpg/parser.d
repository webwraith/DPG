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
		parse_root(root);
		return root;
	}

	private bool parse_root(ref Root tree) {
		while (stream[index].type != TokenType.EOF) {
			auto rule = new Rule;
			if (parse_rule(rule))
				tree.addRule(rule);
			else {
				handleErrors();
				clearErrors();
			}
		}

		return (tree.children.length > 0);
	}

	private bool parse_rule(ref Rule rule) {
		if (expect(TokenType.Identifier, "Expected rule identifier to start rule"))
			return false;
		rule.name = stream[index];
		index++;

		if (expect (TokenType.RuleSep, "Expected ':' separator between name and body of rule"))
			return false;
		rule.separator = stream[index];
		index++;

		OrBlock block = new OrBlock;
		parse_or_block(block);
		if (block.children.length > 1)
			rule.addBody(block);
		else
			rule.addBody(block.left);

		return (expect(TokenType.RuleEnd, "Expected ';' to finish rule"));
	}

	private bool parse_or_block(ref OrBlock or_block) {
		//
		return false;
	}

	private bool parse_paren_block(ref GroupBlock group_block) {
		if (expect(TokenType.GroupOp, "Expected '(' to start a group")) {
			pop_error();
			return false;
		}

		return true;
	}

	private bool expect(TokenType type, string error) {
		if (stream[index].type != type) {
			error_stack.insertFront(
				new ParseError(error, stream[index].line, stream[index].column)
				);
			index++;
			return false;
		}
		return true;
	}

	private void handleErrors() {
		foreach (ParseError error; error_stack)
		{
			writefln("[%s, %s] Error: %s", error.line, error.col, error.err);
		}
	}

	private void pop_error() {
		if (!error_stack.empty) error_stack.removeBack;
	}
	private void clearErrors() {
		error_stack.clear;
	}

	private {
		Token[] stream;
		size_t index;
		DList!ParseError error_stack;
	}
}