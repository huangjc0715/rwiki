require "rd-test-util"

require "rwiki/rd/rd2rwiki-lib"

class TestRDFootnote < Test::Unit::TestCase
  include RDTestUtil

  def footmark_attrs(n, foottext)
    footmark_id = "footmark-#{n}"
    footnote_id = "footnote-#{n}"
    title = foottext.to_s.gsub(/<%[\s\S]*?%>/, '')
    title.gsub!(/<[\s\S]*?>/, '')
    title.sub!(/\A([\s\S]{80})[\s\S]{4,}/, '\\1...')

    {
      "name" => footmark_id,
      "id" => footmark_id,
      "class" => "footnote",
      "title" => title, # do not CGI.escapeHTML here, but in to_attr
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
<p>#{footmark(1, foottext)}</p><hr />
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
<p>#{footmark(1, foottext1)}#{footmark(2, foottext2)}</p><hr />
<p class="foottext">
#{footmark_in_foottext(1)}<small>#{foottext1}</small><br />
#{footmark_in_foottext(2)}<small>#{foottext2}</small><br />
</p>
    XHTML
    actual = HTree.parse(parse_rd("((-#{foottext1}-))((-#{foottext2}-))"))
    assert_equal(expected, actual)
  end


  def assert_footnote_inline(foottext, foottext_xhtml)
    expected = HTree.parse(<<-"XHTML".chomp)
<p>#{footmark(1, foottext_xhtml)}</p><hr />
<p class="foottext">
#{footmark_in_foottext(1)}<small>#{foottext_xhtml}</small><br />
</p>
    XHTML
    actual = HTree.parse(parse_rd("((-#{foottext}-))"))
    assert_equal(expected, actual)
  end

  def test_footnote_em
    foottext = "((*test*))"
    foottext_xhtml = "<em>test</em>"
    assert_footnote_inline(foottext, foottext_xhtml)
  end

  def test_footnote_code
    foottext = "(({test}))"
    foottext_xhtml = "<code>test</code>"
    assert_footnote_inline(foottext, foottext_xhtml)
  end

  def test_footnote_link
    foottext = "((<URL:http://localhost/>))"
    attrs = {
      'href' => 'http://localhost/',
      'class' => 'external',
    }
    foottext_xhtml = "<a #{to_attr(attrs)}>&lt;URL:http://localhost/&gt;</a>"
    assert_footnote_inline(foottext, foottext_xhtml)
  end

  def test_footnote_nest_2
    rd = "((-((-nest-))-))"
    expected = HTree.parse(<<-"XHTML".chomp)
<p>#{footmark(1, '*')}</p><hr />
<p class="foottext">
#{footmark_in_foottext(1)}<small>#{footmark(2, 'nest')}</small><br />
#{footmark_in_foottext(2)}<small>nest</small><br />
</p>
    XHTML
    actual = HTree.parse(parse_rd(rd))
    assert_equal(expected, actual)
  end

  def test_footnote_nest_3
    rd = "((-((-((-nest-))-))-))"
    expected = HTree.parse(<<-"XHTML".chomp)
<p>#{footmark(1, '*')}</p><hr />
<p class="foottext">
#{footmark_in_foottext(1)}<small>#{footmark(2, '*')}</small><br />
#{footmark_in_foottext(2)}<small>#{footmark(3, 'nest')}</small><br />
#{footmark_in_foottext(3)}<small>nest</small><br />
</p>
    XHTML
    actual = HTree.parse(parse_rd(rd))
    assert_equal(expected, actual)
  end

  def test_footnote_nest_4
    rd = "((-((-left-))((-right-))-))"
    expected = HTree.parse(<<-"XHTML".chomp)
<p>#{footmark(1, '**')}</p><hr />
<p class="foottext">
#{footmark_in_foottext(1)}<small>#{footmark(2, 'left')}#{footmark(3, 'right')}</small><br />
#{footmark_in_foottext(2)}<small>left</small><br />
#{footmark_in_foottext(3)}<small>right</small><br />
</p>
    XHTML
    actual = HTree.parse(parse_rd(rd))
    assert_equal(expected, actual)
  end

  def test_footnote_nest_mix
    rd = "((-first-))((-((-second-))-))((-((-((-third-))-))-))((-((-left-))((-right-))-))"
    expected = HTree.parse(<<-"XHTML".chomp)
<p>#{footmark(1, 'first')}#{footmark(2, '*')}#{footmark(3, '*')}#{footmark(4, '**')}</p><hr />
<p class="foottext">
#{footmark_in_foottext(1)}<small>first</small><br />
#{footmark_in_foottext(2)}<small>#{footmark(5, 'second')}</small><br />
#{footmark_in_foottext(3)}<small>#{footmark(6, '*')}</small><br />
#{footmark_in_foottext(4)}<small>#{footmark(7, 'left')}#{footmark(8, 'right')}</small><br />
#{footmark_in_foottext(5)}<small>second</small><br />
#{footmark_in_foottext(6)}<small>#{footmark(9, 'third')}</small><br />
#{footmark_in_foottext(7)}<small>left</small><br />
#{footmark_in_foottext(8)}<small>right</small><br />
#{footmark_in_foottext(9)}<small>third</small><br />
</p>
    XHTML
    actual = HTree.parse(parse_rd(rd))
    assert_equal(expected, actual)
  end
end
