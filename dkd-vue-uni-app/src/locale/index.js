import { createI18n } from 'vue-i18n'

const messages = {
  'zh-CN': {
    common: {
      confirm: '确认',
      cancel: '取消',
    },
    login: {
      title: '登录'
    },
    node: {
      businessTypes: {
        1: '旅游区',
        2: '商场写字楼',
        3: '学校',
        4: '工厂',
        5: '其他'
      }
    },
    emp: {
      title: '人员管理',
      userName: '人员名称',
      mobile: '联系电话',
      regionName: '负责区域',
      roleName: '角色名称',
      status: '状态',
      statusTypes: {
        1: '启用',
        0: '停用'
      }
    },
    region: {
      title: '区域管理',
      regionName: '区域名称',
      nodeCount: '点位数',
      remark: '备注说明'
    },
    partner: {
      title: '合作商管理',
      partnerName: '合作商名称',
      contactPerson: '联系人',
      contactPhone: '联系电话',
      account: '账号',
      profitRatio: '分成比例',
      nodeCount: '点位数'
    },
    vmType: {
      title: '设备类型管理',
      name: '型号名称',
      model: '型号编码',
      image: '设备图片',
      vmRow: '货道行',
      vmCol: '货道列',
      channelMaxCapacity: '设备容量'
    }
  },
  'en-US': {
    common: {
      confirm: 'Confirm',
      cancel: 'Cancel',
    },
    login: {
      title: 'Login'
    },
    node: {
      businessTypes: {
        1: 'Tourist Area',
        2: 'Shopping Mall/Office',
        3: 'School',
        4: 'Factory',
        5: 'Other'
      }
    },
    emp: {
      title: 'Employee Management',
      userName: 'Employee Name',
      mobile: 'Phone Number',
      regionName: 'Region',
      roleName: 'Role Name',
      status: 'Status',
      statusTypes: {
        1: 'Active',
        0: 'Inactive'
      }
    },
    region: {
      title: 'Region Management',
      regionName: 'Region Name',
      nodeCount: 'Node Count',
      remark: 'Remark'
    },
    partner: {
      title: 'Partner Management',
      partnerName: 'Partner Name',
      contactPerson: 'Contact Person',
      contactPhone: 'Contact Phone',
      account: 'Account',
      profitRatio: 'Profit Ratio',
      nodeCount: 'Node Count'
    },
    vmType: {
      title: 'VM Type Management',
      name: 'Type Name',
      model: 'Model Code',
      image: 'Device Image',
      vmRow: 'Rows',
      vmCol: 'Columns',
      channelMaxCapacity: 'Capacity'
    }
  }
}

const savedLanguage = uni.getStorageSync('language') || 'zh-CN'

const i18n = createI18n({
  legacy: false,
  locale: savedLanguage,
  fallbackLocale: 'zh-CN',
  messages
})

export default i18n
