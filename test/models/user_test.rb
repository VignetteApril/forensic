require "test_helper"

describe User do
  before do
    User.create login: 'admin', name: '系统管理员', password: 'Dz123456', password_confirmation: 'Dz123456'
  end
  let(:user) { User.new }

  it "登录名必须存在" do
    user.valid?
    user.errors[:login].must_include '不能为空字符'
  end

  it "登录名必须唯一" do
    user.login = 'admin'
    user.valid?
    user.errors[:login].must_include '已经被使用'
  end

  it "登录名的长度必须在1到50之间" do
    user.login = ''
    user.valid?
    user.errors[:login].must_include '过短（最短为一个字符）'
    user.login = 'a'*51
    user.valid?
    user.errors[:login].must_include '过长（最长为 50 个字符）'
  end

  it "真实姓名长度不能超过20" do
    user.name = 'a'*21
    user.valid?
    user.errors[:name].must_include '过长（最长为 20 个字符）'
  end

  it "身份证号长度不能超过20" do
    user.id_card_no = '1'*21
    user.valid?
    user.errors[:id_card_no].must_include '过长（最长为 20 个字符）'
  end

  it "EMAIL地址长度不能超过100" do
    user.email = 'a'*101
    user.valid?
    user.errors[:email].must_include '过长（最长为 100 个字符）'
  end

  it "EMAIL地址格式必须符合要求" do
    user.email = 'abc@abc'
    user.valid?
    user.errors[:email].must_include '是无效的'
  end

  it "办公电话长度不能超过200" do
    user.work_phone = '1'*201
    user.valid?
    user.errors[:work_phone].must_include '过长（最长为 200 个字符）'
  end

  it "现任职务长度不能超过100" do
    user.position = 'a'*101
    user.valid?
    user.errors[:position].must_include '过长（最长为 100 个字符）'
  end

  it "人员编码长度不能超过100" do
    user.code = '1'*101
    user.valid?
    user.errors[:code].must_include '过长（最长为 100 个字符）'
  end

  it "英文姓名长度不能超过100" do
    user.english_name = 'a'*101
    user.valid?
    user.errors[:english_name].must_include '过长（最长为 100 个字符）'
  end

  it "政治面貌长度不能超过20" do
    user.politics_status = 'a'*21
    user.valid?
    user.errors[:politics_status].must_include '过长（最长为 20 个字符）'
  end

  it "证件类型长度不能超过20" do
    user.id_type = 'a'*21
    user.valid?
    user.errors[:id_type].must_include '过长（最长为 20 个字符）'
  end

  it "性别长度不能超过10" do
    user.gender = 'a'*11
    user.valid?
    user.errors[:gender].must_include '过长（最长为 10 个字符）'
  end

  it "婚姻状况长度不能超过20" do
    user.marital_status = 'a'*21
    user.valid?
    user.errors[:marital_status].must_include '过长（最长为 20 个字符）'
  end
  
  it "最高学历长度不能超过20" do
    user.top_education = 'a'*21
    user.valid?
    user.errors[:top_education].must_include '过长（最长为 20 个字符）'
  end

  it "最高学位长度不能超过20" do
    user.top_degree = 'a'*21
    user.valid?
    user.errors[:top_degree].must_include '过长（最长为 20 个字符）'
  end

  it "职级长度不能超过100" do
    user.rank = 'a'*101
    user.valid?
    user.errors[:rank].must_include '过长（最长为 100 个字符）'
  end

  it "家庭电话长度不能超过100" do
    user.home_phone = '1'*101
    user.valid?
    user.errors[:home_phone].must_include '过长（最长为 100 个字符）'
  end

  it "办公传真长度不能超过100" do
    user.work_fax = '1'*101
    user.valid?
    user.errors[:work_fax].must_include '过长（最长为 100 个字符）'
  end

  it "移动电话长度不能超过100" do
    user.mobile_phone = 'a'*101
    user.valid?
    user.errors[:mobile_phone].must_include '过长（最长为 100 个字符）'
  end

  it "第2EMAIL地址长度不能超过100" do
    user.email2 = 'a'*101
    user.valid?
    user.errors[:email2].must_include '过长（最长为 100 个字符）'
  end

  it "国家长度不能超过100" do
    user.country = 'a'*101
    user.valid?
    user.errors[:country].must_include '过长（最长为 100 个字符）'
  end

  it "省长度不能超过100" do
    user.province = 'a'*101
    user.valid?
    user.errors[:province].must_include '过长（最长为 100 个字符）'
  end

  it "城市长度不能超过100" do
    user.city = 'a'*101
    user.valid?
    user.errors[:city].must_include '过长（最长为 100 个字符）'
  end

  it "邮政编码长度不能超过20" do
    user.zip_code = 'a'*21
    user.valid?
    user.errors[:zip_code].must_include '过长（最长为 20 个字符）'
  end

  it "密码不能为空" do
    u = User.new
    user.valid?
    user.errors[:password].must_include '不能为空字符'

    user.password = ''
    user.valid?
    user.errors[:password].must_include '不能为空字符'
  end

  it "两次输入的密码必须一致" do
    user.password = 'Dz123456'
    user.password_confirmation = 'Dz1234567'
    user.valid?
    user.errors[:password_confirmation].must_include '与确认值不匹配'
  end

  it "密码必须同时包含大小写字母和数字" do 
    user.password = 'dz123456'
    user.valid?
    user.errors[:password].must_include '是无效的'
  end

  it "用户登录验证" do
    u = User.authenticate 'admin', 'dz123456'
    u.must_be_nil
    u = User.authenticate 'admin', 'Dz123456'
    # u.class.must_equal User
    u.must_be_instance_of User
  end
end
