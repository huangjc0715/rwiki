require "rd-test-util"

require "rwiki/rd/rd2rwiki-lib"

class TestRDHeading < Test::Unit::TestCase
  include RDTestUtil

  def test_a_name_id
    expected = HTree.parse(%Q[<h1><a name="test" id="test">t</a>est<!-- RDLabel: "test" --></h1>])
    actual = HTree.parse(parse_rd("= test"))
    assert_equal(expected, actual)
  end

  def test_a_name_id_duplicated
    expected = %Q|<h1><a name="test" id="test">t</a>est<!-- RDLabel: "test" --></h1>| +
      "\n" +
      %Q|<h1><a name="test_2" id="test_2">t</a>est<!-- RDLabel: "test" --></h1>|
    expected = HTree.parse(expected)
    actual = HTree.parse(parse_rd("= test\n= test"))
    assert_equal(expected, actual)
  end

  # id attributes must begin alphabets
  def test_a_name_id_number
    expected = %Q|<h1><a name="a123" id="a123">1</a>23<!-- RDLabel: "123" --></h1>| +
      "\n" +
      %Q|<h1><a name="a123_2" id="a123_2">1</a>23<!-- RDLabel: "123" --></h1>|
    expected = HTree.parse(expected)
    actual = HTree.parse(parse_rd("= 123\n= 123"))
    assert_equal(expected, actual)
  end

  def test_a_name_id_amp
    expected = %Q|<h1><a name="a.26" id="a.26">&amp;</a><!-- RDLabel: "&" --></h1>| +
      "\n" +
      %Q|<h1><a name="a.26_2" id="a.26_2">&amp;</a><!-- RDLabel: "&" --></h1>| +
      "\n" +
      %Q|<h1><a name="a.26.26" id="a.26.26">&amp;</a>&amp;<!-- RDLabel: "&&" --></h1>|
    expected = HTree.parse(expected)
    actual = HTree.parse(parse_rd("= &\n= &\n= &&"))
    assert_equal(expected, actual)
  end


  def test_a_name_id_hyphen
    expected = %Q|<h1><a name="a-" id="a-">-</a><!-- RDLabel: "-" --></h1>| +
      "\n" +
      %Q|<h1><a name="a-_2" id="a-_2">-</a><!-- RDLabel: "-" --></h1>|
    expected = HTree.parse(expected)
    actual = HTree.parse(parse_rd("= -\n= -"))
    assert_equal(expected, actual)
  end

  # '--' escaped to '&shy;&shy;' to avoid '--' into HTML comments
  def test_a_name_id_shy
    expected = %Q|<h1><a name="a.26shy.3b.26shy.3b" id="a.26shy.3b.26shy.3b">-</a>-<!-- RDLabel: "&shy;&shy;" --></h1>| +
      "\n" +
      %Q|<h1><a name="a.26shy.3b.26shy.3b_2" id="a.26shy.3b.26shy.3b_2">-</a>-<!-- RDLabel: "&shy;&shy;" --></h1>|
    expected = HTree.parse(expected)
    actual = HTree.parse(parse_rd("= --\n= --"))
    assert_equal(expected, actual)
  end
end
