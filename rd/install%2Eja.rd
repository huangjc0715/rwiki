= install

((<RWiki>))�򥤥󥹥ȡ��뤷�褦��

== ɬ�פʤ�Ρ�

�������󤢤�ޤ���

* �Ķ�

  * ����ޥ���ˡ��ǡ����ʵ����Ѥʤ��ץ����ˤ��ͺ��ޤ���
    ���Υǡ����˥ݡ����ֹ��1�ĳ�����Ƥ�ɬ�פ�����ޤ���
    ���Υǡ���󡤷빽���꿩���ޤ��ΤǤ���աʸ������Ǥϥڡ�����������ˡ�
    root���¤��פ�ޤ��󤬡����̥ץ�Х������ȵ����Ƥ�館�ʤ����⡥

  * CGI���󥿥ե����������Ѥ����硤CGI�ץ���ब�Ȥ���Ķ���ɬ�פǤ���
    ����ˡ�CGI�ץ����ʤ�ư���ޥ���ˤ���
    ���Υǡ�������³�Ǥ��ʤ��Ȥ����ޤ���
    �̥ޥ��󤫤�Ǥ�OK�����ɥե�������������Ȥ�����ȸ�������

  * �ᥤ�륤�󥿥ե����������Ѥ����硤�ᥤ������ץ�����postfix�ʤɡˤ�
    �Ȥ���Ķ���ɬ�פǤ�������ˡ��ᥤ������ץ����ʤ�ư���ޥ���ˤ���
    ���Υǡ�������³�Ǥ��ʤ��Ȥ����ޤ��󡥰ʲ�Ʊʸ��

* Ruby����

  ruby/1.6�Ϥ�ɬ�פǤ���

* RWiki����

  * ((<RAA:RWiki>))

* �饤�֥��

  * ((<RAA:druby - distributed ruby>)) (2.0.0)
  * ((<RAA:ERB>)) (2.0.2)
  * ((<RAA:Devel::Logger>)) (1.2.0)
  * ((<RAA:RDtool>)) (0.6.10)
    * ((<RAA:OptionParser>))
    * ((<RAA:Racc>))
    * ((<RAA:strscan>))


=== root���¤ΤҤ�

���θ��¤���Ѥ��Ƥʤ�Ǥ�Ĥä���Ǥ�������
�ʳƥѥå������Υ��󥹥ȡ�������Ѥ��Ƥ��������ˡ�


=== �����Ǥʤ��Ҥ�

��ĥ��ޤ��礦��

(1) �Ƽ�饤�֥����äƤ���Ÿ�����ޤ���

(2) ~/lib/ruby��~/bin�ǥ��쥯�ȥ��ʤʤ���С˺��ޤ���

     # �ʲ���/home/nahi��Ŭ���ɤ��ؤ��Ƥ���������
     #   cd ~ && pwd
     # ���ƽФƤ���ǥ��쥯�ȥ�Ǥ���


(3) druby

     $ cp -pr lib/* /home/nahi/lib/ruby

(4) ERB

     $ cp -p lib/* /home/nahi/lib/ruby

(5) Devel::Logger

     $ cp -p lib/* /home/nahi/lib/ruby

(6) Racc

     $ ruby setup.rb config --bin-dir=/home/nahi/bin --rb-dir=/home/nahi/lib/ruby --so-dir=/home/nahi/lib/ruby
     $ ruby setup.rb setup
     $ ruby setup.rb install
     $ ruby setup.rb clean
     $ rm -rf config.save ext/cparse/Makefile

(7) strscan

     $ ruby setup.rb config --bin-dir=/home/nahi/bin --rb-dir=/home/nahi/lib/ruby --so-dir=/home/nahi/lib/ruby
     $ ruby setup.rb setup
     $ ruby setup.rb install
     $ ruby setup.rb clean
     $ rm -f config.save ext/strscanso/Makefile

(8) optparse

     $ cp -p optparse.rb /home/nahi/lib/ruby

(9) rdtool

     $ ruby rdtoolconf.rb

     $ vi Makefile        # Makefile��3�Ľꡤ�ʲ��Τ褦�˽񤭴����ޤ���
     BIN_DIR = /home/nahi/bin
     SITE_RUBY = /home/nahi/lib/ruby
     RD_DIR = /home/nahi/lib/ruby/rd

     $ make install install-rmi2html
     $ make clean

����ʤˤ��ɤ��������ץ겶��¾���Τ��:)

== RWiki�Υ��󥹥ȡ�����

(1) �ѥå��������äƤ���Ÿ�����ޤ���

(2) RWiki�Υ饤�֥��򥤥󥹥ȡ��뤷�ޤ���

    root���¤ΤҤ�

     $ sudo ruby install.rb

    �����Ǥʤ��Ҥ�

     $ cp -pr lib/* /home/nahi/lib/ruby

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
