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

  



    # 選 A/B/C

    reply_text = choose(received_text) if reply_text.nil?
    
    # dinner 

    reply_text = dinner(received_text) if reply_text.nil?

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
    # upload_to_imgur(get_weather_from_cwb)

    '天氣真好'
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




  def dinner(received_text)

    return nil unless received_text[0..2] == '晚餐吃'


      
     ['武媽媽','81HOME','豪緯麵食館','鍋道一號','外賣','咖哩拌飯','7-11','吃我','不要吃','八方雲集',
      '三米藍','全家','大四喜牛肉麵','伊卓島','地中海','龍座','黃媽媽','泰麻吉','品味香','洪媽媽',
      '麥當勞','肯德基','初八拉麵','豐正食堂','阿基鍋燒麵','窩不知道','我想一下','王仔','嘉農','自己煮',
      '夯極味','8鍋','瘋beef','A咖','小羚','味自慢','阿吉麵攤','煮動一點','小豬很忙','一番',
      '二口','薩克廚房','中正快炒','老地方','花亭壽司','松坂家','阜壽司','紅樓','伊豆壽司','允好食堂'].sample
  end

  def chooselunch(received_text)

    return nil unless received_text[0..3] == '午餐吃啥'

     ['晨間廚房','武媽媽','81HOME','豪緯麵食館','鍋道一號','外賣','咖哩拌飯','7-11','吃我','不要吃',
      '三米藍','全家','大四喜牛肉麵','伊卓島','地中海','龍座','黃媽媽','泰麻吉','品味香','洪媽媽',
      '阿寶','123早餐屋','早餐吃啥','麥當勞','肯德基','初八拉麵','鹿初Brunch','布格早午餐','吉多多早午餐店','歐伊系精緻早餐',
      '豐正食堂','阿基鍋燒麵','窩不知道','八方雲集','我想一下','王仔','小間早午餐','嘉農'].sample
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

    # 選一個  選 A B C

  def choose(received_text)

    return nil unless received_text[0..1] == '選 '

    received_text = received_text[2..-1]
    arr = Array.new 
    arr = received_text.split(' ')
   

     arr.sample
  end 



# 關鍵字回覆
  def keyword_reply(channel_id, received_text)
    message = KeywordMapping.where(channel_id: channel_id, keyword: received_text).last&.message
    return message unless message.nil?
    KeywordMapping.where(keyword: received_text).last&.message
  end

  # 傳送訊息到 line
  def reply_to_line(reply_text)
    return if reply_text.nil?
    
    
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

end