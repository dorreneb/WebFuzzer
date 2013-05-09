module SanitizedData
	extend self
  def check_sanitized_data
    vuln = Array.new
    @sanitized.each do |vector|
      next if rand > 0.5 and not @configs.complete
      form = @browser.form
      @browser.text_fields.each do |text_field|
        text_field.set(vector.chomp)
      end
      @browser.input(type: "submit").click if @browser.input(type: "submit").exists?
      sleep @configs.wait_time
      @browser.alert.close if @browser.alert.exists?
      if !@browser.text.include?(vector.chomp) and @browser.html.include?(vector.chomp)
        vuln << form
      end
      sleep @configs.wait_time
      @browser.back
    end
    if vuln.count > 0
      @vulnerabilities_file.write("\tImproperly Sanitized Data\n")
      vuln.each do |x|
        @vulnerabilities_file.write("\t\tForm Name: #{x.name.empty? ? x.name : "Unamed Form"}\n")
      end
    end
  end
end