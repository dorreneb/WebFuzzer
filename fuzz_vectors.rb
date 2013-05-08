module FuzzVectors
  extend self
  def check_xss
    vuln = Array.new
    form = @browser.form
    File.open('FuzzVectors/XSS.txt').each do |vector|
      next if rand > 0.5 and not @configs.complete
      @browser.text_fields.each do |text_field|
        text_field.set(vector.chomp)
      end
      @browser.input(type: "submit").click if not @browser.input(type: "submit").nil?
      sleep @configs.wait_time
      if @browser.cookies.to_a.select{|x| x[:name] == 'randomcookie'}.count > 0
        vuln << vector.chomp
         @browser.cookies.delete 'randomcookie'
      end
      @browser.back if @browser.text_fields.count == 0
    end
    if vuln.count > 0
      @vulnerabilities_file.write("\tCross site scripting\n")
      @vulnerabilities_file.write("\t\tForm #{form.name.empty? ? form.name : "Unamed Form"}:\n")
      vuln.each do |x|
        @vulnerabilities_file.write("\t\t\t#{x}\n")
      end
    end
  end

  def check_sql_injection
    vuln = Array.new
    form = @browser.form
    matches = File.open('FuzzVectors/sql_match.txt')
    File.open('FuzzVectors/SQL.txt').each do |vector|
      next if rand > 0.5 and not @configs.complete
      @browser.text_fields.each do |text_field|
        text_field.set(vector.chomp)
      end
      @browser.input(type: "submit").click if not @browser.input(type: "submit").nil?
      File.open('FuzzVectors/sql_match.txt').each do |match|
        if @browser.body.html.include? match.chomp
          vuln << vector.chomp
          break
        end
      end
      sleep @configs.wait_time
      @browser.back if @browser.text_fields.count == 0
    end
    if vuln.count > 0
      @vulnerabilities_file.write("\tSQL Injection\n")
      @vulnerabilities_file.write("\t\tForm #{form.name.empty? ? form.name : "Unamed Form"}:\n")
      vuln.each do |x|
        @vulnerabilities_file.write("\t\t#{x}\n")
      end
    end
  end
end