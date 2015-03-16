module Differ
  module Format
    module CDIFF
      class << self
        def call(change)
          if change.change?
            as_change(change)
          elsif change.delete?
            as_delete(change)
          elsif change.insert?
            as_insert(change)
          else
            ''
          end
        end

        private
        def as_insert(change)
          %Q(<ins class="differ">#{handle_linebreaks(change.insert, 'ins')}</ins>)
        end

        def as_delete(change)
          %Q(<del class="differ">#{handle_linebreaks(change.delete, 'del')}</del>)
        end

        def as_change(change)
          as_delete(change) << as_insert(change)
        end

        def handle_linebreaks(text, html_element_name)
          #byebug
          replacement =<<-EOL
</#{html_element_name}>
<br class="cdiff_linebreak" />
<#{html_element_name} class="differ">
EOL
          text.gsub(/\r\n|\n/, replacement.chop)
        end
      end
    end
  end
end
