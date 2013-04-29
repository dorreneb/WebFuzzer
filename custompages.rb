
class CustomPages
	attr_reader :login_pages, :custom_scannable_pages, :ignore_pages, :root_url

	def initialize()
		# the first url to scan. will spider out from here.
		# must be a full (with http[s]://) domain
		@root_url = "http://127.0.0.1/"

		# sets what pages should be logged into and what the credentials are
		# wooo multi-dimensional hash. don't try this at home.
		@login_pages = Hash.new{|a,b| a[b] = Hash.new(&a.default_proc)}
		set_login("http://127.0.0.1/dvwa", "admin", "password", "username", "password");

		# sets additional pages that should be manually scanned
		@custom_scannable_pages = ["http://127.0.0.1:80/dvwa/login.php"]

		# sets pages that should be ignored
		@ignore_pages = ["http://127.0.0.1:8080/WebGoat/attack", "http://127.0.0.1/dvwa/logout.php"]
	end

	def set_login(url, username, password, userfieldname, passfieldname)
		@login_pages[url]["username"] = username
		@login_pages[url]["userfield"] = userfieldname
		@login_pages[url]["password"] = password
		@login_pages[url]["passfield"] = passfieldname
	end
end