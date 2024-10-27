module dpg.ast;

import dpg.token;
import std.string;

abstract class AST {
	AST[] children;
	bool is_valid;

	void addChild(AST child) {
		children ~= child;
	}

	string build_string(int indent = 0) {
		string s;
		for (auto i = 0; i < indent; i++) 
			s ~= "| ";
		s ~= this.classinfo.toString ~ "\n";
		foreach(child;children) {
			child.build_string(indent+1);
		}
		return s;
	}
}

class Root : AST {
	void addRule(Rule tree) {
		children ~= tree;
	}
}

class Rule : AST {
	string name, separator;

	void addBody(OrBlock tree) {
		children ~= tree;
	}
}

class OrBlock : AST {
	alias left = children;
	AST[] right;

	void addLeft(AST child) {
		child.addChild;
	}

	void addRight(AST child) {
		right ~= child;
	}	
}

class SuffixBlock : AST {
	Token suffix, selection;
}

class ParenBlock : AST {
	Token open, close;
}