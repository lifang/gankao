module User::AlipaysHelper

  #支付宝
  PAGE_WAY="https://www.alipay.com/cooperate/gateway.do"
  NOTIFY_URL="http://notify.alipay.com/trade/notify_query.do"
  PARTNER_KEY="y8wpddg38lpu0ks66uluaj8506sw7tks"
  PARTNER="2088002153002681"
  SELLER_EMAIL="yesen@yahoo.cn"
  CALLBACK_URL="http://demo.gankao.co/user/alipays/take_over_return"
  OPTIONS={
    :service=>"create_direct_pay_by_user",
    :notice_url=>CALLBACK_URL,
    :return_url=>CALLBACK_URL,
    :subject=>"赶考网英语四级vip",
    :payment_type=>Constant::VIP_TYPE[:good],
    :total_fee=>Constant::VIP_FEE
  }



end
