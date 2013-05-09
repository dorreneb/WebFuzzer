module FuzzVectors
  extend self
  def check_xss
    vuln = Array.new
    array = Array.new
    form = @browser.form
    @xss.each do |vector|
      next if rand > 0.5 and not @configs.complete
      @browser.text_fields.each do |text_field|
        text_field.set(vector.chomp)
      end
      @browser.input(type: "submit").click if @browser.input(type: "submit").exists?
      sleep @configs.wait_time
      if @browser.cookies.to_a.select{|x| x[:name] == 'randomcookie'}.count > 0
        vuln << vector.chomp
         @browser.cookies.delete 'randomcookie'
      end
      @browser.back if @browser.text_fields.count == 0
    end
    if vuln.count > 0
      array << "\tCross site scripting\n"
      array << "\t\tForm #{form.name.empty? ? form.name : "Unamed Form"}:\n"
      vuln.each do |x|
        array << "\t\t\t#{x}\n"
      end
    end
    array
  end

  def check_sql_injection
    vuln = Array.new
    array = Array.new
    form = @browser.form
    @sql.each do |vector|
      next if rand > 0.5 and not @configs.complete
      @browser.text_fields.each do |text_field|
        text_field.set(vector.chomp)
      end
      @browser.input(type: "submit").click if not @browser.input(type: "submit").nil?
      @matches.each do |match|
        if @browser.body.html.include? match.chomp
          vuln << vector.chomp
          break
        end
      end
      sleep @configs.wait_time
      @browser.back if @browser.text_fields.count == 0
    end
    if vuln.count > 0
      array << "\tSQL Injection\n"
      array << "\t\tForm #{form.name.empty? ? form.name : "Unamed Form"}:\n"
      vuln.each do |x|
        array << "\t\t#{x}\n"
      end
    end
    array
  end
end