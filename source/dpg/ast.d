module dpg.ast;

import dpg.token;

abstract class AST {
	AST[] children;
}

class Root : AST {
	void addRule(Rule tree) {
		children ~= tree;
	}
}

class Rule : AST {
	Token name, separator;

	void addBody(AST tree) {
		children ~= tree;
	}
}

class OrBlock : AST {
	enum Left = 0;
	enum Right = 1;
	Token or_sym;

	AST left () {
		return children[Left];
	}

	AST right () {
		return (children.length > 1) ? children[Right] : null;
	}
}

class SuffixBlock : AST {
	Token suffix;
}

class GroupBlock : AST {
	Token open, close;
}