require 'nokogiri'
require 'httpclient'
require 'stringio'
require 'faster_xml_simple'

module Net
  module GitHub
    class Upload
      VERSION = '0.0.1'
      def initialize params=nil
        @login = params[:login]
        @token = params[:token]
      end

      def upload info
        unless info[:repos]
          raise "required repository name"
        end
        info[:repos] = @login + '/' + info[:repos] unless info[:repos].include? '/'

        if info[:file]
          file = info[:file]
          unless File.exist?(file) && File.readable?(file)
            raise "file does not exsits or readable"
          end
          info[:name] ||= File.basename(file)
        end
        unless  info[:file] || info[:data]
          raise "required file or data parameter to upload"
        end

        unless info[:name]
          raise "required name parameter for filename with data parameter"
        end

        if list_files(info[:repos]).any?{|obj| obj[:name] == info[:name]}
          raise "file '#{info[:name]}' is already uploaded. please try different name"
        end

        stat = HTTPClient.post("http://github.com/#{info[:repos]}/downloads", {
          "file_size"    => info[:file] ? File.stat(info[:file]).size : info[:data].size,
          "content_type" => info[:content_type] || 'application/octet-stream',
          "file_name"    => info[:name],
          "description"  => info[:description] || '',
          "login"        => @login,
          "token"        => @token
        })

        unless stat.code == 200
          raise "Failed to post file info"
        end

        upload_info = FasterXmlSimple.xml_in(stat.content)['hash']
        if info[:file]
          f = File.open(info[:file], 'rb')
          stat = HTTPClient.post("http://github.s3.amazonaws.com/", [
            ['Filename', info[:name]],
            ['policy', upload_info['policy']],
            ['success_action_status', 201],
            ['key', upload_info['prefix'] + info[:name]],
            ['AWSAccessKeyId', upload_info['accesskeyid']],
            ['Content-Type', info[:content_type] || 'application/octet-stream'],
            ['signature', upload_info['signature']],
            ['acl', upload_info['acl']],
            ['file', f]
          ])
          f.close
        else
          stat = HTTPClient.post("http://github.s3.amazonaws.com/", [
            ['Filename', info[:name]],
            ['policy', upload_info['policy']],
            ['success_action_status', 201],
            ['key', upload_info['prefix'] + info[:name]],
            ['AWSAccessKeyId', upload_info['accesskeyid']],
            ['Content-Type', info[:content_type] || 'application/octet-stream'],
            ['signature', upload_info['signature']],
            ['acl', upload_info['acl']],
            ['file', StringIO.new(info[:data])]
          ])
        end

        if stat.code == 201
          return FasterXmlSimple.xml_in(stat.content)['PostResponse']['Location']
        else
          pp stat.content
          raise 'Failed to upload'
        end
      end

      private
      def list_files repos
        raise "required repository name" unless repos
        res = HTTPClient.get_content("http://github.com/#{repos}/downloads", {
          "login" => @login,
          "token" => @token
        })
        Nokogiri::HTML(res).xpath('id("browser")/descendant::tr[contains(@id, "download")]').map do |fileinfo|
          obj = {
            :id          => fileinfo.attribute('id').text,
            :description => fileinfo.at_xpath('descendant::td[3]').text,
            :date        => fileinfo.at_xpath('descendant::td[4]').text,
            :size        => fileinfo.at_xpath('descendant::td[5]').text
          }
          anchor = fileinfo.at_xpath('descendant::td[2]/a')
          obj[:link] = anchor.attribute('href').text
          obj[:name] = anchor.text
          obj
        end
      end
    end
  end
end

