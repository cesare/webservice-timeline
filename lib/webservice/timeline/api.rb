require 'date'
require 'net/http'
require 'uri'
require 'rexml/document'

require 'webservice/timeline/xmlobjectmapping'
require 'webservice/timeline/version'

module WebService #:nodoc:
  module TimeLine #:nodoc:

    REQUEST_URI_BASE = URI.parse('http://api.timeline.nifty.com/api/v1/')

    DEFAULT_OPEN_TIMEOUT = 10
    DEFAULT_READ_TIMEOUT = 20

    class Config
      # base path of request URIs.
      attr_accessor :request_path_base

      # domain name of request URIs.
      attr_accessor :request_domain

      # request port
      attr_accessor :request_port

      # connection timeout
      attr_accessor :open_timeout

      # IO read timeout
      attr_accessor :read_timeout

      # timeline_key
      attr_accessor :timeline_key

      # name of user-agent
      attr_accessor :user_agent

      def initialize(&block)
        block.call(self)
      end
    end

    class API

      # creates new API client instance.
      #
      # you can create default client instance.
      #
      #   client = WebService::TimeLine::API.new
      #
      # if you'd like to create/modify some information,
      # or get private information, set your timeline_key, as follows.
      #
      #   client = WebService::TimeLine::API.new do |c|
      #     c.timeline_key = 'your timeline key'
      #   end
      #
      # you can chage some behaviors such as timeout values
      #
      #   client = WebService::TimeLine::API.new do |c|
      #     c.open_timeout = 20
      #     c.read_timeout = 60
      #   end
      #
      #
      # see http://webservice.nifty.com/timeline/v1/common/index.htm#apikey for timeline_key details.
      #
      def initialize(args = {}, &block)
        @config = Config.new do |c|
          c.timeline_key = args[:timeline_key]

          c.request_domain = args[:domain] ||= REQUEST_URI_BASE.host
          c.request_port   = args[:port]   ||= REQUEST_URI_BASE.port
          c.request_path_base = REQUEST_URI_BASE.path

          c.open_timeout = args[:open_timeout] ||= DEFAULT_OPEN_TIMEOUT
          c.read_timeout = args[:read_timeout] ||= DEFAULT_READ_TIMEOUT

          c.user_agent = "TimeLine API client for Ruby ver-#{Version.to_version}"
        end

        if block_given?
          block.call @config
        end
      end

      # finds a timeline by id.
      #
      #   response = client.find_timeline(123)
      #   timeline = response.timeline
      #
      # see http://webservice.nifty.com/timeline/v1/timelines/show.htm for API details.
      #
      def find_timeline(id)
        request(ShowTimelineRequest, ShowTimelineResponse, :id => id)
      end

      # finds an article by id.
      #
      #   response = client.find_article(9876)
      #   article = response.article
      #
      # see http://webservice.nifty.com/timeline/v1/articles/show.htm for API details.
      #
      def find_article(id)
        request(ShowArticleRequest, ShowArticleResponse, :id => id)
      end

      # gets image file data of the article.
      #
      #   response = client.get_article_image(9876)
      #   content_type = response.content_type
      #   raw_data = response.data
      #
      # see http://webservice.nifty.com/timeline/v1/users/image.htm for API details.
      #
      def get_article_image(article_id)
        request(GetArticleImageRequest, GetRawDataResponse, :id => article_id)
      end

      # creates new timeline.
      #
      #   response = client.create_timeline(
      #     :title => 'this is timeline title',
      #     :desctiption => 'some desctiption of the timeline',
      #     :label_for_vaxis => 'the name of vertical axis',
      #     :time_scale => 'day',
      #     :initial_position => 'recent',
      #     :category => 'testing',
      #     :commentable => true,
      #     :open_level => 1,
      #     :opened_for => 'user1,user2,user3',
      #     :lock_level => 1,
      #     :locked_for => 'user1,user2'
      #   )
      #
      # see http://webservice.nifty.com/timeline/v1/timelines/create.htm for API details.
      #
      def create_timeline(params = {})
        request(CreateTimelineRequest, ShowTimelineResponse, params)
      end

      # modifies existing timeline.
      #
      #   response = client.update_timeline(
      #     98765,
      #     :title => 'this is timeline title',
      #     :desctiption => 'some desctiption of the timeline',
      #     :label_for_vaxis => 'the name of vertical axis',
      #     :time_scale => 'day',
      #     :initial_position => 'recent',
      #     :category => 'testing',
      #     :commentable => true,
      #     :open_level => 1,
      #     :opened_for => 'user1,user2,user3',
      #     :lock_level => 1,
      #     :locked_for => 'user1,user2'
      #   )
      #
      # see http://webservice.nifty.com/timeline/v1/timelines/create.htm for API details.
      #
      def update_timeline(id, params = {})
        request(UpdateTimelineRequest, ShowTimelineResponse, params.merge(:id => id))
      end

      # creates new article.
      #
      #   response = client.create_article(
      #     :timeline_id => 98765,
      #     :title => 'this is title of new article',
      #     :description => 'some description of the article.',
      #     :start_time => '2007-08-08T12:34:56+09:00',
      #     :end_time => DateTime.now,
      #     :grade => 99,
      #     :link => [
      #       'http://example.com/link1',
      #       'http://www.example.com/link2',
      #     ],
      #     :image => '/path/to/an/image/file.jpg',
      #     :image_type => 'image/jpg'
      #   )
      #
      # see http://webservice.nifty.com/timeline/v1/articles/create.htm for API details.
      #
      def create_article(params)
        request(CreateArticleRequest, ShowArticleResponse, params)
      end

      # modifies existing article.
      #
      #   response = client.update_article(
      #     1234567,
      #     :timeline_id => 98765,
      #     :title => 'this is title of new article',
      #     :description => 'some description of the article.',
      #     :start_time => '2007-08-08T12:34:56+09:00',
      #     :end_time => DateTime.now,
      #     :grade => 99,
      #     :link => [
      #       'http://example.com/link1',
      #       'http://www.example.com/link2',
      #     ],
      #     :image => '/path/to/an/image/file.jpg',
      #     :image_type => 'image/jpg'
      #   )
      #
      # see http://webservice.nifty.com/timeline/v1/articles/create.htm for API details.
      #
      def update_article(id, params = {})
        request(UpdateArticleRequest, ShowArticleResponse, params.merge(:id => id))
      end

      # looks up timelines.
      #
      #   response = client.search_timeline(
      #     :owner => 'timeline-staff',
      #     :page => 1,
      #     :hits => 100,
      #     :order => 'hot'
      #   )
      #   response.timelines.each { |timeline| do_something_with(timeline) }
      #
      # see http://webservice.nifty.com/timeline/v1/timelines/search.htm for API details.
      #
      def search_timeline(params = {})
        request(SearchTimelineRequest, SearchTimelineResponse, params)
      end

      # looks up articles.
      #
      #   response = client.search_article(
      #     :timeline_id => 98765,
      #     :time_spec => 'cross',
      #     :start_time => '1970-01-01T00:00:00Z',
      #     :end_time => DateTime.now,
      #     :page => 1,
      #     :hits => 50,
      #     :order => 'new_to_old'
      #   )
      #   response.articles.each { |article| do_something_with(article) }
      #
      # see http://webservice.nifty.com/timeline/v1/articles/search.htm for API details.
      #
      def search_article(params = {})
        request(SearchArticleRequest, SearchArticleResponse, params)
      end

      # deletes a timeline.
      #
      #   response = client.delete_timeline(98765)
      #
      # see http://webservice.nifty.com/timeline/v1/timelines/delete.htm for API details.
      #
      def delete_timeline(id)
        request(DeleteTimelineRequest, ResponseBase, :id => id)
      end

      # deletes an article.
      #
      #   response = client.delete_article(1234567)
      #
      # see http://webservice.nifty.com/timeline/v1/articles/delete.htm for API details.
      #
      def delete_article(id)
        request(DeleteArticleRequest, ResponseBase, :id => id)
      end

      # finds information of a user.
      #
      # find owner of timeline_key.
      #   client = WebService::TimeLine::API.new do |c|
      #     c.timeline_key = 'your timeline_key'
      #   end
      #
      #   response = client.show_user
      #   myself = response.user
      #
      # find one of others.
      #   response = client.show_user(999)
      #   user = response.user
      #
      # see http://webservice.nifty.com/timeline/v1/users/show.htm for API details.
      #
      def show_user(id = nil)
        if id.nil?
          request(ShowOneselfRequest, ShowUserResponse)
        else
          request(ShowUserRequest, ShowUserResponse, :id => id)
        end
      end

      # gets image file data of the user.
      #
      #   resonse = client.get_user_image(999)
      #   content_type = response.content_type
      #   image_data = response.data
      #
      # see http://webservice.nifty.com/timeline/v1/articles/image.htm for API details.
      #
      def get_user_image(user_id)
        request(GetUserImageRequest, GetRawDataResponse, :id => user_id)
      end

      # lists all categories.
      #
      #   response = client.list_categories
      #   response.categories.each do |category|
      #     do_something_with(category)
      #     category.sub_categories.each {|sc| do_something_with(sc) }
      #   end
      #
      # see http://webservice.nifty.com/timeline/v1/categories/list.htm for API details.
      #
      def list_categories
        request(ListCategoryRequest, ListCategoryResponse)
      end


      private

      def request(request_class, response_class, params = {})
        timeline_key = @config.timeline_key
        if timeline_key
          params[:timeline_key] = timeline_key
        end

        req = request_class.new(@config, response_class)
        req.request(params)
      end
    end

    class Request #:nodoc:

      def initialize(config, response_class = nil)
        @config = config
        @response_class = response_class
      end


      def request(params = {})
        path = create_request_path(params)
        method = get_method
        http_response = _request(path, method, params)
        parse_response(http_response)
      end


      private

      def get_method
        :get
      end

      def create_query_string(params, separator = '&')
        queries = create_query(params)
        queries.join(separator)
      end

      def create_query(params)
        queries = []
        params.each_pair do |key, val|
          if val.instance_of? Array
            val.each { |v| queries << create_key_value_pair(key, v) }
          else
            queries << create_key_value_pair(key, val)
          end
        end
        queries
      end

      def create_key_value_pair(key, val)
        [key.to_s,  URI.encode(val.to_s, /[^a-zA-Z0-9_\.\-]/)].join('=')
      end

      def create_request_uri(request_path)
        URI::HTTP.build({ :host => @config.request_domain,
                          :port => @config.request_port,
                          :path => request_path,
                        })
      end

      def _request(path, method = :get, params = {})
        uri = create_request_uri(@config.request_path_base + path)
        query = fix_query_parameters(params)

        req = create_http_request(method, uri, query)
        response = Net::HTTP.start(uri.host, uri.port) do |http|
          http.open_timeout = @config.open_timeout
          http.read_timeout = @config.read_timeout
          http.request(req)
        end

        response
      end

      def parse_response(response)
        xml = REXML::Document.new(response.body)
        @response_class.unmarshal(xml.root)
      end

      def fix_query_parameters(params)
        params  # default behavior
      end

      def create_http_request(method, uri, params)
        initheader = { 'User-Agent' => @config.user_agent }
        query = create_query_string(params)

        case method
        when :get
          path = [uri.path, query].join('?')
          Net::HTTP::Get.new(path, initheader)
        when :post
          r = Net::HTTP::Post.new(uri.path, initheader)
          r.body = query
          r.content_type = 'application/x-www-form-urlencoded'
          r
        else
          raise "#{method} is not supported."
        end
      end
    end

    class EditRequest < Request #:nodoc:
      def get_method
        :post
      end
    end


    class ShowTimelineRequest < Request #:nodoc:
      def create_request_path(params)
        id = params[:id]
        "timelines/show/#{id}"
      end
    end

    class ShowArticleRequest < Request #:nodoc:
      def create_request_path(params)
        id = params[:id]
        "articles/show/#{id}"
      end
    end

    class CreateTimelineRequest < EditRequest #:nodoc:
      def create_request_path(params)
        "timelines/create"
      end
    end

    class UpdateTimelineRequest < EditRequest #:nodoc:
      def create_request_path(params)
        id = params[:id]
        "timelines/update/#{id}"
      end
    end


    class EditArticleRequest < EditRequest #:nodoc:
      def fix_query_parameters(params)
        img = params[:image]
        return params unless img

        f = img.kind_of?(IO) ? img : File.new(img)
        base64str = [f.read].pack('m')

        query = params.dup
        query[:image] = base64str
        query
      end
    end

    class CreateArticleRequest < EditArticleRequest #:nodoc:
      def create_request_path(params)
        "articles/create"
      end
    end

    class UpdateArticleRequest < EditArticleRequest #:nodoc:
      def create_request_path(params)
        id = params[:id]
        "articles/update/#{id}"
      end
    end

    class SearchTimelineRequest < Request #:nodoc:
      def create_request_path(params)
        "timelines/search"
      end
    end

    class SearchArticleRequest < Request #:nodoc:
      def create_request_path(params)
        "articles/search"
      end
    end

    class DeleteTimelineRequest < EditRequest #:nodoc:
      def create_request_path(params)
        id = params[:id]
        "timelines/delete/#{id}"
      end
    end

    class DeleteArticleRequest < EditRequest #:nodoc:
      def create_request_path(params)
        id = params[:id]
        "articles/delete/#{id}"
      end
    end

    class ListCategoryRequest < Request #:nodoc:
      def create_request_path(params)
        "categories/list"
      end
    end

    class ShowUserRequest < Request #:nodoc:
      def create_request_path(params)
        id = params[:id]
        "users/show/#{id}"
      end
    end

    class ShowOneselfRequest < Request # :nodoc:
      def create_request_path(params)
        "users/me"
      end
    end

    class GetRawDataRequestBase < Request # :nodoc:
      def parse_response(http_response)
        code = http_response.code.to_i
        if code / 100 != 2
          return super(http_response)
        end

        status = ResponseStatus.new
        status.code = code
        status.message = http_response.message

        response = @response_class.new
        response.status = status
        response.data = http_response.body
        response.content_type = http_response.content_type

        response
      end
    end

    class GetArticleImageRequest < GetRawDataRequestBase
      def create_request_path(params)
        id = params[:id]
        "articles/image/#{id}"
      end
    end

    class GetUserImageRequest < GetRawDataRequestBase
      def create_request_path(params)
        id = params[:id]
        "users/image/#{id}"
      end
    end

    class ResponseStatus < XmlObjectMapping::Base
      attr_mapping :code, :type => :integer
      attr_mapping :message
      attr_mapping :language
    end

    class Summary < XmlObjectMapping::Base
      attr_mapping :total, :type => :integer
      attr_mapping :page, :type => :integer
      attr_mapping :page_count, :type => :integer
    end

    class Timeline < XmlObjectMapping::Base
      attr_mapping :id, :type => :integer
      attr_mapping :title
      attr_mapping :link
      attr_mapping :description
      attr_mapping :owner
      attr_mapping :label_for_vaxis
      attr_mapping :commentable
      attr_mapping :open_level, :type => :integer
      attr_mapping :opened_for
      attr_mapping :lock_level, :type => :integer
      attr_mapping :locked_for
      attr_mapping :articles_count, :type => :integer, :path => 'articles_count'
      attr_mapping :initial_position
      attr_mapping :time_scale
      attr_mapping :updated_at, :type => :datetime
      attr_mapping :created_at, :type => :datetime
      attr_mapping :score, :type => :integer
      attr_mapping :point, :type => :integer
      attr_mapping :page_views, :type => :integer, :path => 'page_view'
      attr_mapping :category

      # predicates if others are allowed to post comments to this Timeline.
      def commentable?
        @commentable == 'true'
      end

      # lists all members who are allowed to browse this Timeline.
      def readable_members
        (list_members(@opened_for) + list_members(@locked_for)).uniq
      end

      # list all members who are allowed to post articles to this Timeline.
      def writable_members
        list_members(@locked_for)
      end

      private
      def list_members(source)
        source.nil? ? [] : source.split(/\s+/)
      end
    end

    class Article < XmlObjectMapping::Base
      attr_mapping :id, :type => :integer
      attr_mapping :title
      attr_mapping :description
      attr_mapping :owner
      attr_mapping :start_time, :type => :datetime
      attr_mapping :end_time, :type => :datetime
      attr_mapping :grade
      attr_mapping :image_url, :path => 'image'
      attr_mapping :link
      attr_mapping :related_urls, :array => true, :path => 'related_links', :subnode => 'url'
      attr_mapping :updated_at, :type => :datetime
      attr_mapping :created_at, :type => :datetime
    end

    class Category < XmlObjectMapping::Base
      attr_mapping :name
      attr_mapping :display_name
      attr_array :sub_categories, :type => Category, :subnode => 'sub_category'
    end

    class User < XmlObjectMapping::Base
      attr_mapping :nickname
      attr_mapping :link
      attr_mapping :introduction
      attr_mapping :image_url, :path => 'image'
    end


    class SearchTimelineResult < XmlObjectMapping::Base
      attr_mapping :summary, :type => Summary
      attr_array :timelines, :type => Timeline, :subnode => 'timeline'
    end

    class SearchArticleResult < XmlObjectMapping::Base
      attr_mapping :summary, :type => Summary
      attr_array :articles, :type => Article, :subnode => 'article'
    end


    class ResponseBase < XmlObjectMapping::Base
      attr_mapping :status, :type => ResponseStatus

      def success?
        if @status
          @status.code == 200
        end
        # returns nil unless @status
      end
    end

    class ShowTimelineResponse < ResponseBase
      attr_mapping :timeline, :type => Timeline, :path => 'result', :subnode => 'timeline'
    end

    class ShowArticleResponse < ResponseBase
      attr_mapping :article, :type => Article, :path => 'result', :subnode => 'article'
    end


    class SearchTimelineResponse < ResponseBase
      attr_mapping :result, :type => SearchTimelineResult, :private => true
      attr_accessor :summary
      attr_accessor :timelines

      private
      def post_population
        @summary = @result.summary
        @timelines = @result.timelines
      end
    end

    class SearchArticleResponse < ResponseBase
      attr_mapping :result, :type => SearchArticleResult, :private => true
      attr_accessor :summary
      attr_accessor :articles

      private
      def post_population
        @summary = @result.summary
        @articles = @result.articles
      end
    end

    class ShowUserResponse < ResponseBase
      attr_mapping :user, :type => User, :path => 'result', :subnode => 'user'
    end

    class ListCategoryResponse < ResponseBase
      attr_array :categories, :type => Category, :path => 'result', :subnode => 'categories/category'
    end


    class GetRawDataResponse < ResponseBase
      # raw data (such as image file).
      attr_accessor :data

      # content type of data
      attr_accessor :content_type
    end
  end

  Timeline = TimeLine # @deprecated
end
