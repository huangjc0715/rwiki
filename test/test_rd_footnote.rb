require "rd-test-util"

require "rwiki/rd/rd2rwiki-lib"

class TestRDFootnote < Test::Unit::TestCase
  include RDTestUtil

  def footmark_attrs(n, foottext)
    footmark_id = "footmark-#{n}"
    footnote_id = "footnote-#{n}"

    {
      "name" => footmark_id,
      "id" => footmark_id,
      "class" => "footnote",
      "title" => foottext,
      "href" => '#' + footnote_id,
    }
  end

  def foottext_attrs(n)
    footmark_id = "footmark-#{n}"
    footnote_id = "footnote-#{n}"

    {
      "name" => footnote_id,
      "id" => footnote_id,
      "class" => "foottext",
      "href" => '#' + footmark_id,
    }
  end

  def sup_small_n(n)
    "<sup><small>*#{n}</small></sup>"
  end

  def footmark(n, foottext)
    "<a #{to_attr(footmark_attrs(n, foottext))}>#{sup_small_n(n)}</a>"
  end

  def footmark_in_foottext(n)
    "<a #{to_attr(foottext_attrs(n))}>#{sup_small_n(n)}</a>"
  end

  def test_footnote_one
    foottext = " "

    expected = HTree.parse(<<-"XHTML".chomp)
<p>#{footmark(1, foottext)}
</p><hr />
<p class="foottext">
#{footmark_in_foottext(1)}<small>#{foottext}</small><br />
</p>
    XHTML
    actual = HTree.parse(parse_rd("((-#{foottext}-))"))
    assert_equal(expected, actual)
  end

  def test_footnote_two
    foottext1 = "1"
    foottext2 = "2"

    expected = HTree.parse(<<-"XHTML".chomp)
<p>#{footmark(1, foottext1)}
#{footmark(2, foottext2)}
</p><hr />
<p class="foottext">
#{footmark_in_foottext(1)}<small>#{foottext1}</small><br />

#{footmark_in_foottext(2)}<small>#{foottext2}</small><br />
</p>
    XHTML
    actual = HTree.parse(parse_rd("((-#{foottext1}-))((-#{foottext2}-))"))
    assert_equal(expected, actual)
  end

end