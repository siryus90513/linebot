require 'line/bot'
class KamigoController < ApplicationController
  protect_from_forgery with: :null_session

  def webhook
      # 查天氣
  reply_image = get_weather(received_text) 

  # 有查到的話 後面的事情就不作了
  unless reply_image.nil?
    # 傳送訊息到 line
    response = reply_image_to_line(reply_image)

    # 回應 200
    head :ok

    return 
  end


    # 學說話
    reply_text = learn(channel_id, received_text)
    
     # random
    reply_text = feeling(received_text) if reply_text.nil?

    # chooselunch 
    reply_text = chooselunch(received_text) if reply_text.nil?

     # 推齊
    reply_text = echo2(channel_id, received_text) if reply_text.nil?

    # 關鍵字回覆
    reply_text = keyword_reply(channel_id, received_text) if reply_text.nil?

   

   

    # 記錄對話
    save_to_received(channel_id, received_text)
    save_to_reply(channel_id, reply_text)

    # 傳送訊息到 line
    response = reply_to_line(reply_text)

    # 回應 200
    head :ok
  end 


  def get_weather(received_text)
    return nil unless received_text.include? '天氣'
    get_weather_from_cwb
  end

  #增加一個上傳圖片到 imgur 的函數
   def upload_to_imgur(image_url)
    url = URI("https://api.imgur.com/3/image")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(url)
    request["authorization"] = 'Client-ID 31892b5246933aa'

    request.set_form_data({"image" => image_url})
    response = http.request(request)
    json = JSON.parse(response.read_body)
    puts json
    begin
      json['data']['link'].gsub("http:","https:")
    rescue
      nil
    end
  end

  #增加一個取得最新雷達回波圖的函數
   def get_weather_from_cwb
    uri = URI('https://www.cwb.gov.tw/Data/js/obs_img/Observe_radar_rain.js')
    response = Net::HTTP.get(uri)
    image_url = response.match /(CV1_RCNT_3600\/CV1_RCNT_3600_[0-9]*.png)/
    # start_index = response.index('","') + 3
    # end_index = response.index('"),') - 1
    "https://www.cwb.gov.tw/Data/radar_rain/" + image_url
  end

  # 傳送圖片到 line
  def reply_image_to_line(reply_image)
    return nil if reply_image.nil?
    
    # 取得 reply token
    reply_token = params['events'][0]['replyToken']
    
    # 設定回覆訊息
    message = {
      type: "image",
      originalContentUrl: reply_image,
      previewImageUrl: reply_image
    }

    # 傳送訊息
    line.reply_message(reply_token, message)
  end

  # 頻道 ID
  def channel_id
    source = params['events'][0]['source']
    source['groupId'] || source['roomId'] || source['userId']
  end

  # 儲存對話
  def save_to_received(channel_id, received_text)
    return if received_text.nil?
    Received.create(channel_id: channel_id, text: received_text)
  end

  # 儲存回應
  def save_to_reply(channel_id, reply_text)
    return if reply_text.nil?
    Reply.create(channel_id: channel_id, text: reply_text)
  end
  
  def echo2(channel_id, received_text)
    # 如果在 channel_id 最近沒人講過 received_text，卡米狗就不回應
    recent_received_texts = Received.where(channel_id: channel_id).last(5)&.pluck(:text)
    return nil unless received_text.in? recent_received_texts
    
    # 如果在 channel_id 卡米狗上一句回應是 received_text，卡米狗就不回應
    last_reply_text = Reply.where(channel_id: channel_id).last&.text
    return nil if last_reply_text == received_text

    received_text
  end

  # 取得對方說的話
  def received_text

    message = params['events'][0]['message']
    message['text'] unless message.nil?

  end

  def feeling(received_text)

    return nil unless received_text[0..6] == '米煮波心情如何'


      
     ['不錯', '還好', '不太行'].sample
  end

  def chooselunch(received_text)

    return nil unless received_text[0..3] == '午餐吃啥'

     ['晨間廚房','武媽媽','81HOME','豪緯麵食館','鍋道一號','外賣','咖哩拌飯','7-11','吃我','不要吃','三米藍','全家','大四喜牛肉麵','伊卓島','地中海','龍座','黃媽媽','泰麻吉','品味香','洪媽媽','阿寶','123早餐屋','早餐吃啥','麥當勞','肯德基','初八拉麵','鹿初Brunch','布格早午餐','吉多多早午餐店','歐伊系精緻早餐','豐正食堂','阿基鍋燒麵','窩不知道'].sample
  end


  # 學說話
  def learn(channel_id, received_text)
    #如果開頭不是 卡米狗學說話; 就跳出
    return nil unless received_text[0..5] == '米煮波學說話'
    
    received_text = received_text[7..-1]
    semicolon_index = received_text.index(';')

    # 找不到分號就跳出
    return nil if semicolon_index.nil?

    keyword = received_text[0..semicolon_index-1]
    message = received_text[semicolon_index+1..-1]

   KeywordMapping.create(channel_id: channel_id, keyword: keyword, message: message)
    '好哦> <'
  end



# 關鍵字回覆
  def keyword_reply(channel_id, received_text)
    message = KeywordMapping.where(channel_id: channel_id, keyword: received_text).last&.message
    return message unless message.nil?
    KeywordMapping.where(keyword: received_text).last&.message
  end

  # 傳送訊息到 line
  def reply_to_line(reply_text)
    reply_text = ['蛤','三小','哈哈','喔是喔','what up','用不到','你說的都對','好喔','靠邀','白爛','好笑嗎','好問題呢',
      '寶','520','7414','幹不要','不知道ㄟ','真的喔','好很喔','好強喔','你這人真噁心','你很棒','三小','為什麼','什麼拉',
      '再一年','怎麼了','這到底是三小','好醜喔','睡起來就好了','你在搞啥','對阿','真的差不多','真假','怎','喔','好貼心喔',
      '吐了','別搞笑','真的ㄟ','0','快樂快樂','感信你的提醒'].sample if reply_text.nil?
    
    # 取得 reply token
    reply_token = params['events'][0]['replyToken']
    
    # 設定回覆訊息
    message = {
      type: 'text',
      text: reply_text
    } 

    # 傳送訊息
    line.reply_message(reply_token, message)
  end

 # Line Bot API 物件初始化
  def line
    @line ||= Line::Bot::Client.new { |config|
       config.channel_secret = '068642867953c0cde3987cb696dccac7'
    config.channel_token = 'VUzbj9NMqRMCyDkbT3STQaXDCpIL7cMhLCTMbkfi153QP3RYghdWgcdFnWs02OHj5UvCZAuW/wsnBgLRwcC/o7dA1Pize8UG8A5Dsr/kIiw1t88GCVFBv8zAQW9jPiqtMIxArSfoXsctpvEN13SpwgdB04t89/1O/w1cDnyilFU='
    }
  end


  def eat
    render plain: "吃土啦"
  end 

  def request_headers
    render plain: request.headers.to_h.reject{ |key, value|
      key.include? '.'
    }.map{ |key, value|
      "#{key}: #{value}"
    }.sort.join("\n")
  end

  def response_headers
    response.headers['5566'] = 'QQ'
    render plain: response.headers.to_h.map{ |key, value|
      "#{key}: #{value}"
    }.sort.join("\n")
  end

  def request_body
    render plain: request.body
  end

  def show_response_body
    puts "===這是設定前的response.body:#{response.body}==="
    render plain: "虎哇花哈哈哈"
    puts "===這是設定後的response.body:#{response.body}==="
  end

  def sent_request
    uri = URI('http://localhost:3000/kamigo/eat')
    http = Net::HTTP.new(uri.host, uri.port)
    http_request = Net::HTTP::Get.new(uri)
    http_response = http.request(http_request)

    render plain: JSON.pretty_generate({
      request_class: request.class,
      response_class: response.class,
      http_request_class: http_request.class,
      http_response_class: http_response.class
    })
  end

  def translate_to_korean(message)
    "#{message}油~"
  end

end