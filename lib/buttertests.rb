require '~/src/butter/lib/butter.rb'
require "test/unit"

class TestParser < Test::Unit::TestCase 

	def test_identifier		
		p = Butter.new
		assert_equal("x", p.identifier.parse("x")[:id],"Single char ids")		

		assert_equal("abc", p.identifier.parse("abc")[:id],"Multi char ids")		
		assert_equal("a_b",p.identifier.parse("a_b")[:id],"Multi id with underscore")
		assert_equal("aBC",p.identifier.parse("aBC")[:id],"Mutil id with mixed case")
					
		assert_raise(Parslet::ParseFailed) { Butter.new.identifier.parse("ABC") }		
		assert_raise(Parslet::ParseFailed) { Butter.new.identifier.parse("_ABC") }
		assert_raise(Parslet::ParseFailed) { Butter.new.identifier.parse("1ABC") }
		assert_raise(Parslet::ParseFailed) { Butter.new.identifier.parse("_") }
	end	

	def test_list		
		lst = Butter.new.lst.parse("[0,1,2]")
		assert_not_nil(lst, "Simple integer list")
		assert_equal(0,lst[:lst][0][:int].to_i)		
		assert_equal(1,lst[:lst][1][:int].to_i)
		assert_equal(2,lst[:lst][2][:int].to_i)
				
		nested = Butter.new.lst.parse("[1,2,[a,b,c]]")
		assert_not_nil(nested, "Nested list")
		assert_equal("a",nested[:lst][2][:lst][0][:id].to_s)
		assert_equal("b",nested[:lst][2][:lst][1][:id].to_s)
		assert_equal("c",nested[:lst][2][:lst][2][:id].to_s)

		Butter.new.lst.parse("[]")
	end
	
	def test_map
		map = Butter.new.map.parse('{"Foo":1,"Bar":2}')		
		assert_equal("Foo",map[:map][0][:mapkey][:string])
		assert_equal(1,map[:map][0][:mapvalue][:int].to_i)

		assert_equal("Bar",map[:map][1][:mapkey][:string])
		assert_equal(2,map[:map][1][:mapvalue][:int].to_i)

		assert_not_nil(Butter.new.map.parse('{"Foo":1,"Bar":[1,2,3]}'),"Map with a nested list")		
		assert_not_nil(Butter.new.map.parse('{"Foo":1,"Bar":{}}'),"Map with an empty nested map")
	end

	def test_equals
		assert_not_nil(Butter.new.op_equals.parse("="))
		assert_not_nil(Butter.new.op_equals.parse("= "))
	end

	def test_tuple
		assert_not_nil(Butter.new.tuple.parse("(1,2,3)"))
		assert_not_nil(Butter.new.tuple.parse("()"))
	end
	
	def test_def
		program = 
		"def foo(x:String List,y:String) -> 
			print_hello;
			x;
		end"
		p Butter.new.parse(program)
	end
end