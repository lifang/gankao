# encoding: utf-8
module User::AlipaysHelper

  #支付宝
  PAGE_WAY="https://www.alipay.com/cooperate/gateway.do"
  NOTIFY_URL="http://notify.alipay.com/trade/notify_query.do"
  PARTNER_KEY="y8wpddg38lpu0ks66uluaj8506sw7tks"
  PARTNER="2088002153002681"
  SELLER_EMAIL="yesen@yahoo.cn"
  CALLBACK_URL="http://www.gankao.co/user/alipays/take_over_return"
  NONSYNCH_URL="http://www.gankao.co/user/alipays/over_pay"
  OPTIONS={
    :service=>"create_direct_pay_by_user",
    :notify_url=>CALLBACK_URL,
    :return_url=>NONSYNCH_URL,
    :subject=>"CET4-vip",
    :payment_type=>Constant::VIP_TYPE[:good],
    :total_fee=>Constant::VIP_FEE
  }



end
