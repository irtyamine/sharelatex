Path = require('path')
http = require('http')
http.globalAgent.maxSockets = 300

# Make time interval config easier.
seconds = 1000
minutes = 60 * seconds

# These credentials are used for authenticating api requests
# between services that may need to go over public channels
httpAuthUser = "sharelatex"
httpAuthPass = "password"
httpAuthUsers = {}
httpAuthUsers[httpAuthUser] = httpAuthPass

sessionSecret = "secret-please-change"

module.exports =
	# File storage
	# ------------
	#
	# ShareLaTeX needs somewhere to store binary files like images.
	# There are currently two options:
	#     Your local filesystem (the default)
	#     Amazon S3
	filestore:
		# which backend persistor to use.
		# choices are 
		# s3 - Amazon S3
		# fs - local filesystem
		backend: "fs"	
		stores:
			# where to store user and template binary files
			#
			# For Amazon S3 this is the bucket name to store binary files
			#
			# For local filesystem this is the directory to store the files in.
			# This path must exist, not be tmpfs and be writable to by the user sharelatex is run as.
			user_files: Path.resolve("/var/user_files")
		# Uncomment if you need to configure your S3 credentials
		# s3:
		# 	# if you are using S3, then fill in your S3 details below
		# 	key: ""
		# 	secret: ""

	# Databases
	# ---------
	mongo:
		url : 'mongodb://127.0.0.1/sharelatex'

	redis:
		web:
			host: "127.0.0.1"
			port: "6379"
			password: ""

		api:
			host: "127.0.0.1"
			port: "6379"
			password: ""

		fairy:
			host: "127.0.0.1"
			port: "6379"
			password: ""

	mysql:
		clsi:
			database: "clsi"
			username: "clsi"
			password: ""
			dialect: "sqlite"
			storage: Path.resolve("/var/db.sqlite")

	# Service locations
	# -----------------

	# Configure which ports to run each service on. Generally you
	# can leave these as they are unless you have some other services
	# running which conflict, or want to run the web process on port 80.
	internal:
		web:
			port: webPort = 2999
			host: "127.0.0.1"
		documentupdater:
			port: docUpdaterPort = 2999
			host: "documentupdater.localhost"
		clsi:
			port: clsiPort = 2999
			host: "clsi.localhost"
		filestore:
			port: filestorePort = 2999
			host: "filestore.localhost"
		trackchanges:
			port: trackchangesPort = 2999
			host: "trackchanges.localhost"
		docstore:
			port: docstorePort = 2999
			host: "docstore.localhost"

	# Tell each service where to find the other services. If everything
	# is running locally then this is easy, but they exist as separate config
	# options incase you want to run some services on remote hosts.
	apis:
		web:
			url: "http://127.0.0.1:#{webPort}"
			user: httpAuthUser
			pass: httpAuthPass
		documentupdater:
			url : "http://documentupdater.localhost:#{docUpdaterPort}"
		clsi:
			url: "http://clsi.localhost:#{clsiPort}"
		filestore:
			url: "http://filestore.localhost:#{filestorePort}"
		trackchanges:
			url: "http://trackchanges.localhost:#{trackchangesPort}"
		docstore:
			url: "http://docstore.localhost:#{docstorePort}"
		thirdPartyDataStore:
			url : "http://127.0.0.1:3002"
			emptyProjectFlushDelayMiliseconds: 5 * seconds
		tags:
			url :"http://127.0.0.1:3012"
		spelling:
			url : "http://127.0.0.1:3005"
		versioning:
			snapshotwaitms:3000
			url: "http://127.0.0.1:4000"
			username: httpAuthUser
			password: httpAuthPass
		recurly:
			privateKey: ""
			apiKey: ""
			subdomain: ""
		chat:
			url: "http://127.0.0.1:3010"
		templates:
			port: 3007
		blog:
			port: 3008
		templates_api:
			url: "http://127.0.0.1:3007"

	# Where your instance of ShareLaTeX can be found publically. Used in emails
	# that are sent out, generated links, etc.
	siteUrl : 'http://127.0.0.1:3000'

	# Same, but with http auth credentials.
	httpAuthSiteUrl: 'http://#{httpAuthUser}:#{httpAuthPass}@localhost:3000'

	# Security
	# --------
	security:
		sessionSecret: sessionSecret

	httpAuthUsers: httpAuthUsers

	# Default features
	# ----------------
	#
	# You can select the features that are enabled by default for new
	# new users.
	defaultFeatures: defaultFeatures =
		collaborators: -1
		dropbox: true
		versioning: true

	plans: plans = [{
		planCode: "personal"
		name: "Personal"
		price: 0
		features: defaultFeatures
	}]

	# Spelling languages
	# ------------------
	#
	# You must have the corresponding aspell package installed to 
	# be able to use a language.
	languages: [
		{name: "English", code: "en"}
	]

	# Email support
	# -------------
	#
	# ShareLaTeX uses nodemailer (http://www.nodemailer.com/) to send transactional emails.
	# To see the range of transport and options they support, see http://www.nodemailer.com/docs/transports
	# email:
	#	fromAddress: ""
	#	replyTo: ""
	#	lifecycle: false
	#	transport: "SES"
	#	parameters:
	#		AWSAccessKeyID: ""
	#		AWSSecretKey: ""


	# Third party services
	# --------------------
	#
	# ShareLaTeX's regular newsletter is managed by Markdown mail. Add your
	# credentials here to integrate with this.
	# markdownmail:
	# 	secret: ""
	# 	list_id: ""
	#
	# Fill in your unique token from various analytics services to enable
	# them.
	# analytics:
	# 	mixpanel:
	# 		token: ""
	# 	ga:
	# 		token: ""
	# 	heap:
	# 		token: ""
	# 
	# ShareLaTeX's help desk is provided by tenderapp.com
	# tenderUrl: ""
	#

	# Production Settings
	# -------------------

	# Should javascript assets be served minified or not. Note that you will
	# need to run `grunt compile:minify` within the web-sharelatex directory
	# to generate these.
	useMinifiedJs: true

	# Should static assets be sent with a header to tell the browser to cache
	# them.
	cacheStaticAssets: false

	# If you are running ShareLaTeX over https, set this to true to send the
	# cookie with a secure flag (recommended).
	secureCookie: false

	# Internal configs
	# ----------------
	path:
		# If we ever need to write something to disk (e.g. incoming requests
		# that need processing but may be too big for memory, then write
		# them to disk here).
		dumpFolder: Path.resolve "/var/dumpFolder"
		# Where to write the project to disk before running LaTeX on it
		compilesDir:  Path.resolve("/var/compiles")
		# Where to cache downloaded URLs for the CLSI
		clsiCacheDir: Path.resolve("/var/cache")
		uploadFolder: Path.resolve("/var/uploads")
	
	# Automatic Snapshots
	# -------------------
	automaticSnapshots:
		# How long should we wait after the user last edited to 
		# take a snapshot?
		waitTimeAfterLastEdit: 5 * minutes
		# Even if edits are still taking place, this is maximum
		# time to wait before taking another snapshot.
		maxTimeBetweenSnapshots: 30 * minutes

	# Smoke test
	# ----------
	# Provide log in credentials and a project to be able to run
	# some basic smoke tests to check the core functionality.
	#
	# smokeTest:
	# 	user: ""
	# 	password: ""
	# 	projectId: ""

	# Filestore health check
	# ----------------------
	# Project and file details to check in filestore when calling /health_check
	# health_check:
	# 	project_id: ""
	# 	file_id: ""