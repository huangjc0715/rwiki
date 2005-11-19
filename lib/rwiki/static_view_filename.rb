# -*- indent-tabs-mode: nil -*-

module RWiki
  module URLGenerator
    module StaticView

      def underline_html(name)
        name = name.gsub(/([^a-zA-Z0-9.\-]+)/n) do
          '_' + $1.unpack('H2' * $1.size).join('_').upcase
        end
        sprintf("%s.html", name)
      end

      def ja_man_html(name)
        return "methodlist.html" if name == "method"
        name = name.dup
        name.tr_s!(' -/:-@\[-`{-~', '_')
        name.gsub!(/([^a-zA-Z0-9_]+)/n) do
          '_' + $1.unpack('H2' * $1.size).join('').upcase
        end
        sprintf("%s.html", name.squeeze('_'))
      end

      begin
        require 'punycode'

        def p_encode_html(name)
          return "methodlist.html" if name == "method"
          name = name.dup
          name.tr_s!(' -/:-@\[-`{-~', '_')
          unless /\A[A-Za-z0-9_\-]+\z/ =~ name
            name = Punycode.encode(name.delete('_'))
          end
          sprintf("%s.html", name.squeeze('_'))
        end
      rescue LoadError
      end
    end
  end
end
