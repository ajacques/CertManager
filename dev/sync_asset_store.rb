#!/usr/bin/ruby
# DO NOT COMMIT THIS FILE
require 'json'
require 'zlib'
require 'aws-sdk'

bucket = 'ndxvbsft9gbwww0u'

Aws.config = {
  region: 'us-east-1',
  credentials: Aws::Credentials.new('AKIAJLGXROBTXY7X7M4A', 'G7haZoC1NF+7ZT0zuyiW1qrEPZRhsUAFnxSWSFFh')
}

@mimes = {
  html: 'text/html',
  css: 'text/css',
  js: 'application/js'
}

s3 = Aws::S3::Client.new

def asset_files
  file_names = Dir.glob 'public/assets/.sprockets-manifest-*.json'
  json = JSON.parse File.read file_names.first
  json['files'].keys
end

def compress(file)
  str = StringIO.new
  gz = Zlib::GzipWriter.new str
  gz.write file
  gz.close
  str.string
end

def mime_type(file_name)
  @mimes[File.extname(file_name)[1..-1].to_sym]
end

asset_files.each do |file|
  opts = {
    acl: 'bucket-owner-read',
    key: "web_content/assets/#{file}",
    content_encoding: 'gzip',
    bucket: bucket,
    cache_control: 'max-age=31556926'
  }
  opts[:content_type] = mime_type(file) if mime_type(file)
  opts[:body] = compress(File.read("public/assets/#{file}"))
  s3.put_object opts
end
