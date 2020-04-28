require 'hmac-sha1'

module Ems
	class HttpCaller
		# 三段码参数
		API_NAME     = 'routInfoQueryForPDD'
		API_VERSION  = '1.0.0'
		AccessKey 	 = 'dd979a77b2a44e54b65f01dcbc0bae04'
		SecretKey 	 = 'kCZfusS4Zn300MTnYtIlWzhdoE8='
		THREE_SEGMENT_CODE_URL = 'http://211.156.195.42:8086/csb_ceshinew_1'

		# 下单取号参数
		ORDER_NUMBER_URL = 'https://211.156.195.199/iwaybillno-web/a/iwaybill/receive'
		# 下单取号private_key
		ORDER_NUMBER_PRIVATE_KEY = 'key123xydJDPT'
		# 下单取号xml请求报文
		BODY_XML_STR = "<OrderNormal>
							<created_time>#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}</created_time>
							<logistics_provider>B</logistics_provider>
							<ecommerce_no>MZSFJD</ecommerce_no>
							<ecommerce_user_id>12</ecommerce_user_id>
							<sender_type>1</sender_type>
							<sender_no>11010787237000</sender_no>
							<inner_channel>0</inner_channel>
							<logistics_order_no>234124213423412</logistics_order_no>
							<batch_no></batch_no>
							<waybill_no></waybill_no>
							<one_bill_flag></one_bill_flag>
							<submail_no></submail_no>
							<one_bill_fee_type></one_bill_fee_type>
							<contents_attribute>3</contents_attribute>
							<base_product_no>21210</base_product_no>
							<biz_product_no>112104302300991</biz_product_no>
							<product_type>113124300000691</product_type>
							<weight></weight>
							<volume></volume>
							<length></length>
							<width></width>
							<height></height>
							<postage_total></postage_total>
							<pickup_notes></pickup_notes>
							<insurance_flag>1</insurance_flag>
							<insurance_amount></insurance_amount>
							<deliver_type></deliver_type>
							<deliver_pre_date></deliver_pre_date>
							<pickup_type>1</pickup_type>
							<pickup_pre_begin_time></pickup_pre_begin_time>
							<pickup_pre_end_time></pickup_pre_end_time>
							<payment_mode>1</payment_mode>
							<cod_flag>9</cod_flag>
							<cod_amount></cod_amount>
							<receipt_flag>1</receipt_flag>
							<receipt_waybill_no></receipt_waybill_no>
							<electronic_preferential_no></electronic_preferential_no>
							<electronic_preferential_amount></electronic_preferential_amount>
							<valuable_flag>0</valuable_flag>
							<sender_safety_code>0</sender_safety_code>
							<receiver_safety_code></receiver_safety_code>
							<note></note>
							<project_id></project_id>
							<sender>
								<name>陆安波</name>
								<post_code>510000</post_code>
								<phone>020-86210730</phone>
								<mobile>020-86210730</mobile>
								<prov>广东</prov>
								<city>广州</city>
								<county>白云区</county>
								<address>广州市白云区均禾街道夏花二路66号401</address>
							</sender>
							<pickup>
								<name>陆安波</name>
								<post_code>510000</post_code>
								<phone>020-86210730</phone>
								<mobile>020-86210730</mobile>
								<prov>广东</prov>
								<city>广州</city>
								<county>白云区</county>
								<address>广州市白云区均禾街道夏花二路66号401</address>
							</pickup>
							<receiver>
								<name>王丽婷</name>
								<post_code></post_code>
								<phone>18690972424</phone>
								<mobile>18690972424</mobile>
								<prov>新疆维吾尔自治区</prov>
								<city>新疆维吾尔自治区</city>
								<county>沙依巴克区</county>
								<address>新疆维吾尔自治区乌鲁木齐市沙依巴克区西山街道沙区西环中路151号中山花苑小区</address>
							</receiver>
							<cargos>
								<Cargo>
									<cargo_name>医用棉签(B型)</cargo_name>
									<cargo_category></cargo_category>
									<cargo_quantity></cargo_quantity>
									<cargo_value></cargo_value>
									<cargo_weight></cargo_weight>
								</Cargo>
								<Cargo>
									<cargo_name>过氧苯甲酰凝胶</cargo_name>
									<cargo_category></cargo_category>
									<cargo_quantity></cargo_quantity>
									<cargo_value></cargo_value>
									<cargo_weight></cargo_weight>
								</Cargo>
							</cargos>
						</OrderNormal>"
		class << self
			# 下单取号接口
			def request_order_number
				md5_digest = Digest::MD5.digest(BODY_XML_STR + ORDER_NUMBER_PRIVATE_KEY)
				data_digest = Base64.strict_encode64(md5_digest)
				_params = { data_digest: data_digest,
				            msg_type: 'ORDERCREATE',
				            logistics_interface: BODY_XML_STR,
				            ecCompanyId: 'MZSFJD'
				          }
				url = URI(ORDER_NUMBER_URL)
				url.query = URI.encode_www_form(_params)
				result = HTTParty.post(url, headers: { 'Content-Type' => 'text/plain;charset=UTF-8' }, verify: false )
				Hash.from_xml(result)
			end

			# 三段码接口
			def request_three_segment_code
				# 参数 logisticsInterface
				logisticsInterface = [{"senderAddress":{"province":"浙江省","city":"杭州市","area":"余杭","town":"余杭街道","detail":"狮山路11号","zip":"123456"},
									   "receiverAddress":{"province":"江苏省","city":"南京市","area":"江宁","town":"东山街道","detail":"东麒路33号A座","zip":"123456"},
									   "objectId":"ebc98d46-9ee2-4e23-a467-0e8086880e04"}]
				# 参数列表
				normal_params = { 
					              logisticsInterface: logisticsInterface.to_json,
					              data_digest: 'bb',
					              wp_code: 'WELLWIN'
					            }
				# 安全参数列表
				safe_params = { _api_name: API_NAME, _api_version: API_VERSION, _api_access_key: AccessKey, _api_timestamp: Time.now.strftime('%Y%m%d%H%M%S%L') }
				params = normal_params.merge(safe_params).sort
				signature = params.map { |key, value| "#{key}=#{value}" }.join('&')
				hmac_digest = Base64.strict_encode64(sign_params(SecretKey, signature))
				headers = { 'Content-Type' => 'application/x-www-form-urlencoded;charset=utf-8', _api_signature: hmac_digest }.merge(safe_params)

				url = URI(THREE_SEGMENT_CODE_URL)
				url.query = URI.encode_www_form(normal_params)
				result = HTTParty.post(url, headers: headers, verify: false )
				JSON.parse(result)
			end

			private
				# 对参数进行加密
				def sign_params(secret_key, signature)
					hmac = HMAC::SHA1.new(secret_key)
					hmac.update(signature)
					hmac.digest
				end
		end
	end
end