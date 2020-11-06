require 'hmac-sha1'
require 'pry'

module Ems
	class HttpCaller
		# 三段码参数
		API_NAME     = 'routInfoQueryForPDD'
		API_VERSION  = '1.0.0'
		AccessKey 	 = 'fb47938ddfe3439abf082aabeef4440b'
		SecretKey 	 = 'slXp9uMJE9LBUmAZZasL0WuPJrI='
		THREE_SEGMENT_CODE_URL = 'https://211.156.195.14:443/csb_jidi1_1'

		# 下单取号参数
		ORDER_NUMBER_URL = 'https://211.156.195.15/iwaybillno-web/a/iwaybill/receive'
		# 下单取号private_key
		ORDER_NUMBER_PRIVATE_KEY = 'klnjDnoumh3y'

		class << self
			# 下单取号接口
			def request_order_number(current_order)
				current_org = Organization.first
				# 下单取号xml请求报文
				xml_str = "<OrderNormal>
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
									<name>#{current_org.name}</name>
									<post_code>#{current_org.post_code}</post_code>
									<phone>#{current_org.phone}</phone>
									<mobile>#{current_org.phone}</mobile>
									<prov>#{current_org.province_name}</prov>
									<city>#{current_org.city_name}</city>
									<county>#{current_org.district_name}</county>
									<address>#{current_org.addr}</address>
								</sender>
								<pickup>
									<name>#{current_org.name}</name>
									<post_code>#{current_org.post_code}</post_code>
									<phone>#{current_org.phone}</phone>
									<mobile>#{current_org.phone}</mobile>
									<prov>#{current_org.province_name}</prov>
									<city>#{current_org.city_name}</city>
									<county>#{current_org.district_name}</county>
									<address>#{current_org.addr}</address>
								</pickup>
								<receiver>
									<name>#{current_order.reporter}</name>
									<post_code>#{current_order.receiver_post_code}</post_code>
									<phone>#{current_order.receiver_phone}</phone>
									<mobile>#{current_order.receiver_phone}</mobile>
									<prov>#{current_order.province_name}</prov>
									<city>#{current_order.city_name}</city>
									<county>#{current_order.district_name}</county>
									<address>#{current_order.receiver_addr}</address>
								</receiver>
								<cargos>
									<Cargo>
										<cargo_name>文件</cargo_name>
										<cargo_category></cargo_category>
										<cargo_quantity></cargo_quantity>
										<cargo_value></cargo_value>
										<cargo_weight></cargo_weight>
									</Cargo>
								</cargos>
							</OrderNormal>"
				md5_digest = Digest::MD5.digest(xml_str + ORDER_NUMBER_PRIVATE_KEY)
				data_digest = Base64.strict_encode64(md5_digest)
				_params = { data_digest: data_digest,
				            msg_type: 'ORDERCREATE',
				            logistics_interface: xml_str,
				            ecCompanyId: 'MZSFJD'
				          }
				url = URI(ORDER_NUMBER_URL)
				url.query = URI.encode_www_form(_params)
				result = HTTParty.post(url, headers: { 'Content-Type' => 'text/plain;charset=UTF-8' }, verify: false )
				Rails.logger.info result
				rs = Hash.from_xml(result)
				rs["responses"]["responseItems"]["response"]["waybill_no"]
			end

			# 三段码接口
			def request_three_segment_code(current_order)
				current_org = Organization.first
				# 参数 logisticsInterface
				logisticsInterface = [{"senderAddress":{"province":"#{current_org.province_name}","city":"#{current_org.city_name}","area":"#{current_org.district_name}","town":"#{current_org.town}","detail":"#{current_org.addr}","zip":"#{current_org.post_code}"},
									   "receiverAddress":{"province":"#{current_order.province_name}","city":"#{current_order.city_name}","area":"#{current_order.district_name}","town":"#{current_order.town}","detail":"#{current_order.receiver_addr}","zip":"#{current_order.receiver_post_code}"},
									   "objectId":"#{current_order.order_num}"}]
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
				result["body"]["result"][0]["routeCode"]
			end

			def get_ems_logistics express_num
				trace_hash = { "traceNo" => express_num }.to_json
		    private_key = '74C258A9EB489431'
		    md5_digest = Digest::MD5.hexdigest(trace_hash + private_key)
		    dataDigest = Base64.strict_encode64(md5_digest)
		    msgBody = URI.encode(trace_hash)
		    _params = { dataDigest: dataDigest,
		                msgBody: msgBody,
		                serialNo: '2',
		                dataType: '1',
		                batchNo: '999',
		                receiveID: 'JDPT',
		                sendDate: Time.now.strftime('%Y%m%d%H%M%S'),
		                msgKind: 'zhijian_JDPT_TRACE',
		                proviceNo: '99',
		                sendID: 'zhijian',
		              }
		    url = URI('http://211.156.195.29/querypush-twswn/mailTrack/queryMailTrackWn/plus')
		    url.query = URI.encode_www_form(_params)
		    result = HTTParty.post(url, headers: { 'Content-Type' => 'text/plain;charset=UTF-8' } )
		    result
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
