require 'parslet'

class Butter < Parslet::Parser
	rule(:lparen)     { str('(') >> space? }
	rule(:rparen)     { str(')') >> space? }
	rule(:lcurly)     { str('{') >> space? }
	rule(:rcurly)     { str('}') >> space? }
	rule(:lbracket)   { str('[') >> space? }
	rule(:rbracket)   { str(']') >> space? }
	rule(:comma)      { str(',') >> space? }
	rule(:colon)      { str(':') >> space? }

	rule(:op_equals)  { str('=') >> space? }
	
	rule(:let)        { str("let") >> space? }
	rule(:fn)        { str("fn") >> space? }

	rule(:space)      { match('\s').repeat(1) }
	rule(:space?)     { space.maybe }

	# https://gist.github.com/966020
    rule(:number) {
      (
        str('-').maybe >> (
          str('0') | (match('[1-9]') >> digit.repeat)
        ) >> (
          str('.') >> digit.repeat(1)
        ).maybe >> (
          match('[eE]') >> (str('+') | str('-')).maybe >> digit.repeat(1)
        ).maybe
      ).as(:number)
    }

	# https://gist.github.com/966020
    rule(:string) {
      str('"') >> (
        str('\\') >> any | str('"').absent? >> any
      ).repeat.as(:string) >> str('"')
    }
	
	rule(:integer)    { match('[0-9]').repeat(1).as(:int) >> space? }
	rule(:identifier) { (match['a-z'] >> match['a-zA-Z0-9_'].repeat).as(:id) >> space? }
	rule(:operator)   { match('[+]') >> space? }

	rule(:letexpr)	  { let >> identifier >> op_equals >> expression }

	rule(:lst) do 
		(lbracket >> expression >> (comma >> expression).repeat >> rbracket).as(:lst) 
	end

	rule(:tuple) { (lparen >> expression >> (comma >> expression).repeat >> rparen).as(:tuple) }

	rule(:mapentry)		{ string.as(:mapkey) >> colon >> expression.as(:mapvalue) }
	rule(:mapentries) 	{ mapentry >> (comma >> mapentry).repeat}
	rule(:map) 			{ lcurly >> mapentries.maybe.as(:map) >> rcurly}
	rule(:expression) { integer | string | identifier | lst | map }

	rule(:program)    { letexpr.repeat(1) }

	root :program
end
