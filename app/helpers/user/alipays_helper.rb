# encoding: utf-8
module User::AlipaysHelper

  #支付宝
  PAGE_WAY="https://www.alipay.com/cooperate/gateway.do"
  NOTIFY_URL="http://notify.alipay.com/trade/notify_query.do"
  PARTNER_KEY="y8wpddg38lpu0ks66uluaj8506sw7tks"
  PARTNER="2088002153002681"
  SELLER_EMAIL="yesen@yahoo.cn"
  CALLBACK_URL="http://#{Constant::IP}/alipays/take_over_return"
  NONSYNCH_URL="http://#{Constant::IP}/user/alipays/over_pay"



end
