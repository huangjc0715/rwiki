require 'rwiki/rwiki'
require 'rwiki/rd/rddoc'

module RWiki
  module StoryCard
    class PropLoader
      def load(content)
	doc = StoryCardDocument.new(content.tree)
	prop = doc.to_prop
	prop[:name] = content.name
	prop
      end

      class StoryCardDocument < RDDoc::SectionDocument
	def summary
	  text = first_child(@doc.root, RD::TextBlock)
	  return nil unless text
	  as_str(text.content)
	end
	
	def delete_tail(str)
	  str = str.split("\n").collect {|s| s.strip}.join(" ")

	  return nil if str.size == 0

	  ary = str.split("")
	  return str if ary.size <= 40
	  ary[0,40].join("") + "..."
	end

	def to_prop
	  prop = {}

	  s = summary
	  if s
	    prop["summary"] = s
	    prop[:summary] = delete_tail(s)
	  end

	  each_section do |head, content|
	    next unless head
	    title = as_str(head.title).strip.downcase
	    if head.level == 2 && ['status', '����'].include?(title)
	      StatusSection.new(prop).apply_Section(content)
	    elsif head.level == 2 && title == 'history'
	      HistorySection.new(prop).apply_Section(content)
	    elsif head.level >= 2 && ['test', '�'].include?(title)
	      TestSection.new(prop).apply_Section(content)
	    end
	  end
	  prop
	end
      end

      class StatusSection < RDDoc::PropSection
	def apply_Prop(key, value)
	  super(key, value)
	  case key.downcase
	  when 'ô��', '������', 'charge', 'sign'
	    @prop[:sign] = value
	  when '����', 'status'
	    apply_status(value)
	  when '������', '����', 'card', 'kind'
	    apply_card_type(value)
	  when '���ƥ졼�����', 'iteration'
	    apply_iteration(value)
	  when '����', 'estimation'
	    apply_estimation(value)
	  end
	end

	def apply_card_type(value)
	  case value.downcase
	  when '������', 'task'
	    @prop[:card_type] = :task
	  when '�Х�', 'bug'
	    @prop[:card_type] = :bug
	  when '���ȡ��꡼', 'story'
	    @prop[:card_type] = :story
	  else 
	    nil
	  end
	end
	
	def apply_status(value)
	  case value.downcase
	  when 'open'
	    @prop[:status] = :open
	  when 'close'
	    @prop[:status] = :close
	  when 'discard'
	    @prop[:status] = :discard
	  end
	end

	def apply_iteration(value)
	  @prop[:iteration] = value.to_i unless value.empty?
	end
	
	def apply_estimation(value)
	  ary = value.split('/')
	  begin
	    @prop[:estimation] = ary[0].to_f if ary[0]
	  rescue
	  end
	  begin
	    @prop[:actual] = ary[1].to_f if ary[1]
	  rescue
	  end
	end
      end

      class HistorySection < RDDoc::HistorySection
	def apply_History(time, who, value)
	  @prop[:history] ||= []
	  @prop[:history].push([time, who, value])

	  case value.downcase
	  when 'open'
	    @prop[:open] = time
	  when 'close'
	    @prop[:close] = time
	  when 'ok', 'ng'
	    apply_Test(time, value) if ['test', 'uft'].include?(who.downcase)
	  end
	end

	def apply_Test(time, value)
	  case value.strip.downcase
	  when 'ok'
	    v = true
	  when 'ng'
	    v = false
	  else
	    v = false
	  end

	  @prop[:test_result] ||= {}
	  @prop[:test_result][time] = v
	end
      end

      class TestSection < RDDoc::PropSection

	def initialize(prop = {})
	  super(prop)
	  @curr_q = nil
	  @v = RD::RD2RWikiVisitor.new
	end

	def apply_ItemListItem(item)
	  first = first_Child(item)
	  return unless RD::TextBlock === first
	  str = as_str(first.content).strip
	  if /^Q:/ =~ str
	    apply_Q(item)
	  elsif /^A:/ =~ str
	    apply_A(item)
	  else
	    apply_QA(item)
	  end
	end

	def add_prop_test(it)
	  prop[:test] ||= []
	  prop[:test] << it
	end

	def apply_QA(item)
	  if @curr_q
	    add_prop_test([to_html(@curr_q)]) 
	    @curr_q = nil
	  end
	  add_prop_test([to_html(item)])
	end
	
	def apply_Q(item)
	  @curr_q = item
	end

	def apply_A(item)
	  if @curr_q
	    prop[:test] ||= []
	    prop[:test] << create_QA(@curr_q, item)
	    @curr_q = nil
	  end
	end

	def create_QA(q, a)
	  [to_html(q), to_html(a)]
	end
	
	def to_html(item)
	  return "" unless item
	  @v.visit_children(item).join("")
	end
      end
    end

    class IndexLoader < PropLoader
      def load(content)
	doc = StoryIndexDocument.new(content.tree)
	prop = doc.to_prop
	prop[:name] = content.name
	prop
      end

      class StoryIndexSection < RDDoc::PropSection
	def apply_ItemListItem(item)
	  size = 0
	  value = nil
	  item.each_child do |e|
	    size += 1
	    break if size > 1
	    case e
	    when RD::TextBlock
	      ee = first_child(e, Object)
	      if RD::Reference === ee 
		if RD::Reference::RWikiLabel === ee.label
		  @prop[:index] ||= []
		  @prop[:index] << ee.label.wikiname
		end
	      end
	    end
	  end
	end
      end

      class StoryIndexDocument < RDDoc::SectionDocument
	def to_prop
	  prop = {}
	  ary = []
	  each_section do |head, content|
	    next unless head
	    title = as_str(head.title).strip
	    if head.level == 2 && as_str(head.title).strip == 'story-card' 
	      StoryIndexSection.new(prop).apply_Section(content)
	    end
	  end
	  prop
	end
      end
    end

    class IndexSection < RWiki::Section
      def initialize(config, name, base_name, item_section)
	super(config, name)
	@page = IndexPage
	add_prop_loader(:story_index, IndexLoader.new)
	@base_name = base_name
	@item_section = item_section
      end
      attr_reader :item_section, :base_name
    end

    class IndexPage < RWiki::Page
      def initialize(name, book, section) 
	super(name, book, section)
	@index_tmpl = ERB.new(IndexTmpl)
      end

      IndexTmpl = <<EOS
= <%= @name %>

== story-card

* ((<<%=new_name%>>)) empty item
<% 
   ary.each do |story| 
%>
* ((<<%=story[:name]%>>)) <%=story[:card_type]%> <%=story[:iteration]%>- <%=story[:summary]%>
<% 
   end 
%>
EOS

      def view_html(env = {}, &block)
	story ,= block ? block.call('story') : nil

	update = index_dirty?
	make_index if update
	
	case story
	when 'update'
	  index.make_index unless update
	  return @format.new(env, &block).view(self)
	when 'table'
	  return StoryCardTableFormat.new(env, &block).view(self)
	when 'plan'
	  return StoryCardPlanFormat.new(env, &block).view(self)
	when 'test'
	  test_name ,= block ? block.call('testname') : nil
	  test_result ,= block ? block.call('testresult') : nil
	  if test_name && test_result
	    add_test_result(test_name, test_result) 
	  end
	  return StoryCardTestFormat.new(env, &block).view(self)
	when 'plain'
	  return @format.new(env, &block).view(self)
	else # 'plan'
	  return StoryCardPlanFormat.new(env, &block).view(self)
	end
      end

      def items(remove_empty=false)
	item_section = @section.item_section
	index = prop(:story_index)
	return [] unless index && index[:index]

	ary = index[:index].find_all { |nm| item_section.match?(nm) }
	ary = ary.sort.reverse

	item = ary.collect { |nm| @book[nm].prop(:story) }.compact

	if remove_empty
	  item = item.delete_if { |story| empty_story?(story) }
	end

	item
      end

      def empty_story?(story)
	return true unless story
	return true unless story[:summary]
	return true if /empty item/ =~ story[:summary]
	false
      end

      def desc_page
	@book[@name + '-desc']
      end
      
      def index_dirty?
	newer = hot_links[0]
	return true if newer.nil?
	return false unless @book.include_name?(newer)
	mod = @book[newer].modified || Time.at(1)
	return false unless mod > self.modified
	return true
      end

      def make_index
	ary = items(true)

	if ary.size > 0
	  new_name = ary[0][:name].succ
	else
	  new_name = @section.base_name
	end

	self.src = @index_tmpl.result(binding)
      end

      def find_empty_story
	index = prop(:story_index)
	return nil unless index && index[:index]

	index[:index].find do |nm|
	  if @section.item_section.match?(nm)
	    empty_story?(@book[nm].prop(:story))
	  else
	    false
	  end
	end
      end

      def add_test_result(name, value)
	return unless %w(OK NG).include?(value)
	page = @book[name]
	return unless ItemPage === page
	page.add_test_result(value)
      end
    end

    class ItemSection < RWiki::Section
      def initialize(config, pattern)
	super(config, pattern)
	@page = ItemPage
	add_prop_loader(:story, PropLoader.new)
	add_default_src_proc(method(:default_src))
      end

      RWiki::ERbLoader.new('default_src(name)', 'story-item.erd').load(self)
    end

    class ItemPage < RWiki::Page
      def add_test_result(value)
	new_history = "* #{Time.now.strftime('%Y-%m-%d')} TEST: #{value}"

	src = self.src.split("\n")
	ary = []
	status = nil
	src.each do |line|
	  if status == nil
	    status = :history_head if /^==\s*history\s*$/ =~ line
	  elsif status == :history_head
	    status = :history_items if /^\*/ =~ line
	  elsif status == :history_items
	    if line.strip.size == 0
	      ary << new_history 
	      status = :done
	    end
	  end
	  ary << line
	end
	ary << new_history if status == :history_items
	ary << ''
	self.src = ary.join("\n")
      end
    end
    
    class StoryCardIndexFormat < RWiki::PageFormat
      @rhtml = {}
      @rhtml[:view] = RWiki::ERbLoader.new('view(pg)', 'story-index.rhtml')
      @rhtml[:control] = RWiki::ERbLoader.new('control(pg)', 'story-control.rhtml')
      reload_rhtml
    end

    class StoryCardTableFormat < StoryCardIndexFormat
      @rhtml = { :view => RWiki::ERbLoader.new('view(pg)', 'story-table.rhtml')}
      reload_rhtml

      def make_matrix(pg)
	items = pg.items(true).find_all { |story|
	  story[:test_result] && story[:test_result].size > 0
	}

	matrix = {}

	items.each do |story|
	  story[:test_result].each do |time, value|
	    matrix[time] ||= {}
	    matrix[time][story[:name]] = value
	  end
	end
	
	[ items.collect{|story| story[:name]}.sort, matrix.keys.sort, matrix]
      end
    end

    class StoryCardTestFormat < StoryCardIndexFormat
      @rhtml = { :view => RWiki::ERbLoader.new('view(pg)', 'story-test.rhtml')}
      reload_rhtml
      
      def view_html(env = {}, &block)
	@iter ,= block ? block.call('iter') : false
	@format.new(env, &block).view(self)
      end

      def items(pg, iter)
	ary = pg.items(true).find_all { |story|
	  if story.include?(:test) 
	    if iter 
	      story[:iteration] && story[:iteration] <= iter
	    else
	      true
	    end
	  else
	    false
	  end
	}
	ary.sort { |a, b| 
	  v = a[:iteration].to_i <=> b[:iteration].to_i
	  v = a[:card_type].to_s <=> b[:card_type].to_s if v == 0
	  v = a[:name] <=> b[:name] if v == 0
	  v 
	}
      end
    end

    class StoryCardPlanFormat < StoryCardIndexFormat
      @rhtml = { :view => RWiki::ERbLoader.new('view(pg)', 'story-plan.rhtml')}
      reload_rhtml

      def items(pg, card_type)
	ary = pg.items(true).find_all { |story|
	  story[:card_type] == card_type
	}

	ary.sort { |a, b| 
	  v = (a[:iteration] || -1) <=> (b[:iteration] || -1)
	  v = a[:name] <=> b[:name] if v == 0
	  v
	}
      end
    end

    def install(name, base_name, pattern)
      item_section = ItemSection.new(nil, pattern)
      RWiki::Book.section_list.push(item_section)
      index_section = IndexSection.new(nil, name, base_name, item_section)
      RWiki::Book.section_list.push(index_section)
    end
    module_function :install
  end
end
