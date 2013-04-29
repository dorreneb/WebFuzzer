
class CustomPages
	attr_reader :login_pages, :custom_scannable_pages, :ignore_pages

	def initialize()
		@login_pages = Hash.new
		@login_pages["http://127.0.0.1:80/dvwa/login.php"] = ["username", "admin", "password", "password"]

		@custom_scannable_pages = ["http://127.0.0.1:80/dvwa/login.php"]

		@ignore_pages = ["http://127.0.0.1:8080/WebGoat/attack"]
	end
end