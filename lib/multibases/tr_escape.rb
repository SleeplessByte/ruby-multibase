module TrEscape
  refine String do
    def tr_escape
      self.gsub(/(?<escapee>[\^\-])/,'\\\\\\k<escapee>')
    end
  end
end
