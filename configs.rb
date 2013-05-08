class Configs
	attr_reader :login_pages, :custom_scannable_pages, :ignore_pages, :root_url, :wait_time, :password_guessing, :common_passwords, :complete

	def initialize()
		# the first url to scan. will spider out from here.
		# must be a full (with http[s]://) domain
		@root_url = "http://127.0.0.1"

		# sets what pages should be logged into and what the credentials are
		# wooo multi-dimensional hash. don't try this at home.
		@login_pages = Hash.new{|a,b| a[b] = Hash.new(&a.default_proc)}
		set_login("http://127.0.0.1/dvwa/login.php", "admin", "password", "username", "password")
		set_login("http://127.0.0.1:8080/bodgeit/login.jsp", "test@thebodgeitstore.com", "password", "username", "password")

		# sets additional pages that should be manually scanned
		@custom_scannable_pages = ["http://127.0.0.1:8080/bodgeit/admin.jsp", "http://127.0.0.1/dvwa/vulnerabilities/view_source.php","http://127.0.0.1/dvwa/vulnerabilities/view_source_all.php", "http://127.0.0.1/dvwa/login.php"]

		# sets pages that should be ignored
		@ignore_pages = ["http://127.0.0.1:8080/WebGoat/attack", "http://127.0.0.1/dvwa/logout.php", "http://127.0.0.1:8080/bodgeit/password.jsp", "http://127.0.0.1/dvwa/vulnerabilities/csrf/"]

		# sets how long that it should wait between requests in seconds
		@wait_time = 0

		# sets whether password guessing should happen
		@password_guessing = false

		#sets whether it should try every page and input fields  or random pages and input fields
		@complete = true

		# common passwords to try during password guessing
		@common_passwords = []
		read_common_passwords

	end

	def set_login(url, username, password, userfieldname, passfieldname)
		@login_pages[url]["username"] = username
		@login_pages[url]["userfield"] = userfieldname
		@login_pages[url]["password"] = password
		@login_pages[url]["passfield"] = passfieldname
	end

	def read_common_passwords
		open('commonpasswords.txt').each do |line|
			@common_passwords << line.chomp
		end
	end
end