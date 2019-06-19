# frozen_string_literal: true

module TrEscape
  refine String do
    def tr_escape
      gsub(/(?<escapee>[\^\-])/,'\\\\\\k<escapee>')
    end
  end
end
