= install

((<RWiki>))�򥤥󥹥ȡ��뤷�褦��



== ɬ�פʤ�Ρ�

* Ruby����

  ruby-1.8.4��ɬ�פǤ���

* RWiki����

  * ((<RAA:RWiki>))

* �饤�֥��

  * ((<RAA:RDtool>)) (0.6.20)

== ����Ȥ��ڤ������

* �饤�֥��

  * �ʤ�?

== RWiki�Υ��󥹥ȡ�����

RWiki���̾���󤹤�RWiki�����Ф�CGI�ʤɤγƼ磻�󥿡��ե�������
��İʾ�Υץ����ǹ�������ޤ���
�Ϥ���ˡ�RWiki�����С��Ƽ磻�󥿡��ե����������Ѥ���RWiki�Υ饤�֥���
���󥹥ȡ��뤷��³����RWiki�����С����󥿡��ե�������������������ޤ���

=== RWiki�饤�֥��Υ��󥹥ȡ���

 $ tar xzvf rwiki-2.x.tar.gz
 $ cd rwiki-2.x
 $ sudo ruby install.rb

=== RWiki�����Ф�����

 FIXME

(3) rw-config.rb���ľ�������ꤷ�Ƥ���������

     $ cd site
     $ vi rw-config.rb 

(4) rw-cgi.rb �� CGI �Ȥ��Ƶ�ư�Ǥ���褦�ˤ��ޤ���~/public_html���֤����ꡤchmod�����ꡥ

     $ cp interface/rw-cgi.rb ~/public
     $ chmod 755 ~/public/rw-cgi.rb

(5) rw-cgi.rb �� SETUP �ȥ����ȤΤ����դ���ľ���Ƥ���������

(6) �饤�֥��򥤥󥹥ȡ��뤷���ǥ��쥯�ȥ���㤨��/home/nahi/lib/ruby�ˤ�ruby�Υ饤�֥�긡���ѥ��ˤ��뤳�Ȥ��ǧ���ޤ���

     $ ruby -e 'p $:'

(7) �ʤ���дĶ��ѿ�RUBYLIB���ɲä��ޤ��礦���㤨�аʲ��Τɤ줫��

     $ setenv RUBYLIB /home/nahi/lib/ruby
     $ setenv RUBYLIB $RUBYLIB:"/home/nahi/lib/ruby"
     $ export RUBYLIB="/home/nahi/lib/ruby"

(8) rwiki�����Ф�ư���ޤ���

    �Ȥꤢ�����ǥХå��⡼�ɤǤϼ��Τ褦��

     $ ruby -dv -Ke rwiki.rb

    ư�������ʵ����������

     $ ruby -Ke rwiki.rb

(9) rw-cgi.rb��֥饦���ǳ����ƤߤƤ���������
