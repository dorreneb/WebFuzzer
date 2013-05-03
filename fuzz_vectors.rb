module FuzzVectors
  extend self
  def xss
    vuln = Array.new
    File.open('FuzzVectors/XSS.txt').each do |vector|
      next if rand > 0.5 and not @configs.complete
      @browser.text_fields.each do |text_field|
        text_field.set(vector.chomp)
      end
      @browser.input(type: "submit").click if not @browser.input(type: "submit").nil?
      if @browser.alert.exists?
        vuln << vector
        @browser.alert.ok
      end
      @browser.back
    end
    if vuln.count > 0
      @vulnerabilities_file.write("\tCross site scripting\n")
      vuln.each do |x|
        @vulnerabilities_file.write("\t\t#{x}\n")
      end
    end
  end

  def sql

  end

  def int

  end
end