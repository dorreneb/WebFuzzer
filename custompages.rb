
class CustomPages
	attr_reader :login_pages, :custom_scannable_pages, :ignore_pages

	def initialize()
		# wooo multi-dimensional hash. don't try this at home.
		@login_pages = Hash.new{|a,b| a[b] = Hash.new(&a.default_proc)}
		set_login("http://127.0.0.1/dvwa", nil, "admin", "password", "username", "password");		


		@custom_scannable_pages = ["http://127.0.0.1:80/dvwa/login.php"]

		@ignore_pages = ["http://127.0.0.1:8080/WebGoat/attack"]
	end

	def set_login(url, formid, username, password, userfieldname, passfieldname)
		@login_pages[url]["username"] = username
		@login_pages[url]["userfield"] = userfieldname
		@login_pages[url]["password"] = password
		@login_pages[url]["passfield"] = passfieldname
		@login_pages[url]["formid"] = formid
	end
end