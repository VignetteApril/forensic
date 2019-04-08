require "test_helper"

describe Department do
  let(:department) { Department.roots[0].children.build }

  it "部门名称不能为空" do
    department.valid?
    department.errors[:name].must_include "不能为空字符"
  end

  it "部门名称长度不能超过200" do
    department.name = 'a'*201
    department.valid?
    department.errors[:name].must_include "过长（最长为 200 个字符）"
  end

  it "人员编码用户不填的时候系统会自动生成默认值" do
    department.name = '本部门'
    department.valid?
    department.errors.must_be_empty
    department.code.wont_be_nil
  end

  it "人员编码长度不能超过20" do
    department.code = '1'*21
    department.valid?
    department.errors[:code].must_include "过长（最长为 20 个字符）"
  end

  it "简称长度不能超过100" do
    department.brief = 'a'*101
    department.valid?
    department.errors[:brief].must_include "过长（最长为 100 个字符）"
  end

  it "组织行政级别长度不能超过100" do
    department.admin_level = 'a'*101
    department.valid?
    department.errors[:admin_level].must_include "过长（最长为 100 个字符）"
  end

  it "组织角色属性长度不能超过100" do
    department.role_type = 'a'*101
    department.valid?
    department.errors[:role_type].must_include "过长（最长为 100 个字符）"
  end
end
