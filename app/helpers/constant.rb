module Constant
  #邮箱地址
  EMAILS = {
    :e126 => ['http://www.126.com','网易126'],
    :eqq => ['http://mail.qq.com','QQ'],
    :e163 => ['http://mail.163.com','网易163'],
    :esina => ['http://mail.sina.com.cn','新浪'],
    :esohu => ['http://mail.sohu.com','搜狐'],
    :etom => ['http://mail.tom.com','TOM'],
    :esogou => ['http://mail.sogou.com','搜狗'],
    :e139 => ['http://mail.10086.cn','139手机'],
    :egmail => ['http://gmail.google.com','Gmail'],
    :ehotmail => ['http://www.hotmail.com','Hotmail'],
    :e189 => ['http://www.189.cn','189'],
    :eyahoo => ['http://mail.cn.yahoo.com','雅虎'],
    :eyou => ['http://www.eyou.com','亿邮'],
    :e21cn => ['http://mail.21cn.com','21CN'],
    :e188 => ['http://www.188.com','188财富邮'],
    :eyeah => ['http://www.yeah.net','网易Yeah.net'],
    :efoxmail => ['http://www.foxmail.com','foxmail'],
    :ewo => ['http://mail.wo.com.cn','联通手机'],
    :e263 => ['http://www.263.net','263']
  }
 
  #服务路径
  SERVER_PATH = "http://localhost:3000"
  BACK_SERVER_PATH = "http://localhost:3001"
  #项目文件目录
  PUBLIC_PATH = "#{Rails.root}/public"
  #试卷生成路径
  PAPER_PATH = "#{PUBLIC_PATH}/papers"
  #试卷服务器访问路径
  PAPER_URL_PATH = SERVER_PATH + "/papers"
  #客户端访问试卷
  PAPER_CLIENT_PATH = BACK_SERVER_PATH + "/paperjs"
  #客户端访问答卷
  ANSWER_CLIENT_PATH = SERVER_PATH + "/result"
  #导出未确认名单路径
  UNAFFIRM_PATH = "/excels"
  #收藏文件路径
  COLLECTION_PATH = "/collections"

  #代理权限
   RIGHTS = {
    "english_fourth_level" => ["英语四级",1],
    "english_sixth_level" => ["英语六级",2]
  }

  #免费名额数量
  FREE_NUM=1000

  
   #优惠价格
  FAVOURABLE=50
  #代理支付
  AGENCY_COST=2


#  # 新浪微博接口
#  SINA_API_KEY = "3987186573"
#  SINA_API_SECRET = "645c8b4c620d162d84450c9e93f79d4c"

  # 人人接口
  RENREN_API_KEY = "7f4d7bacf5b144d8940d5a8177b592b0"
  RENREN_API_SECRET = "fe0430b144ff4cb48f1060933e1f68b0"


#  # 人人接口
#  RENREN_API_KEY = "84792db011c343bbb2ec2f431c054f12"
#  RENREN_API_SECRET = "1ba540a351a846cdb52a3798605d2fbb"

  
end
