PDFKit.configure do |config|
     config.wkhtmltopdf = '/usr/local/bin/wkhtmltopdf' if Rails.env.production? && defined?(JRUBY_VERSION) #only run on production JRuby
end