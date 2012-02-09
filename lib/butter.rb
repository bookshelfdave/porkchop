require 'parslet'

class Butter < Parslet::Parser
	rule(:lparen)     { str('(') >> space? }
	rule(:rparen)     { str(')') >> space? }
	rule(:lcurly)     { str('{') >> space? }
	rule(:rcurly)     { str('}') >> space? }
	rule(:lbracket)   { str('[') >> space? }
	rule(:rbracket)   { str(']') >> space? }
	rule(:comma)      { str(',') >> space? }
	rule(:doublecolon)      { str('::') >> space? }
	rule(:colon)      { str(':') >> space? }
	rule(:semi)      { str(';') >> space? }
	rule(:fnbody)     { str('->') >> space? }

	rule(:op_equals)  { str('=') >> space? }
	

	rule(:space)      { match('\s').repeat(1) }
	rule(:space?)     { space.maybe }

	rule(:kdef)		  { str("def") >> space? }
	rule(:kend)		  { str("end") >> space? }

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
	
	rule(:butterparam) { (match['a-z'] >> match['a-zA-Z0-9_'].repeat).as(:butterparam) >> space? }
	rule(:buttertype) { (match['A-Z'] >> match['a-zA-Z0-9_'].repeat).as(:buttertype) >> space? }
	
	rule(:buttertypedparam) { butterparam >> colon >> buttertype >> buttertype.maybe.as(:container_type) }
	
	rule(:operator)   { match('[+]') >> space? }

	rule(:lst) do 
		(lbracket >> (expression >> (comma >> expression).repeat).maybe	 >> rbracket).as(:lst) 
	end

	rule(:tuple) 		{ (lparen >> (expression >> (comma >> expression).repeat).maybe >> rparen).as(:tuple) }
	rule(:paramtuple) 		{ (lparen >> (buttertypedparam >> (comma >> buttertypedparam).repeat).maybe >> rparen).as(:paramtuple) }

	
	rule(:mapentry)		{ string.as(:mapkey) >> colon >> expression.as(:mapvalue) }
	rule(:mapentries) 	{ mapentry >> (comma >> mapentry).repeat}
	rule(:map) 			{ lcurly >> mapentries.maybe.as(:map) >> rcurly}
	
	rule(:expression) { integer | string | identifier | lst | map  }

	rule(:statement)	 { expression >> semi }
	rule(:statements)     { statement.repeat(1) }

	rule(:butterdef)	{ kdef >> identifier.as(:fnname) >> paramtuple.as(:fnparams) >> fnbody >> statements >> kend  }
	
	root(:butterdef)
end
