<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-position="top">
      <el-form-item :label="$t('partner.partnerName')" prop="partnerName">
        <el-input
          v-model="queryParams.partnerName"
          :placeholder="$t('partner.partnerNamePlaceholder')"
          clearable
          @keyup.enter="handleQuery"
          style="width: 200px"
        />
      </el-form-item>
      <el-form-item class="button-item">
        <el-button type="primary" icon="Search" @click="handleQuery">{{ $t('common.search') }}</el-button>
        <el-button icon="Refresh" @click="resetQuery">{{ $t('common.reset') }}</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="Plus"
          @click="handleAdd"
          v-hasPermi="['manage:partner:add']"
        >{{ $t('partner.addPartner') }}</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['manage:partner:edit']"
        >{{ $t('partner.editPartner') }}</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['manage:partner:remove']"
        >{{ $t('partner.deletePartner') }}</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="Download"
          @click="handleExport"
          v-hasPermi="['manage:partner:export']"
        >{{ $t('partner.exportPartner') }}</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="partnerList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column :label="$t('partner.serialNumber')" type="index" width="80" align="center" prop="id" />
      <el-table-column :label="$t('partner.partnerName')" align="center" prop="partnerName" min-width="150" show-overflow-tooltip />
      <el-table-column :label="$t('partner.nodeCount')" align="center" prop="nodeCount" width="100" />
      <el-table-column :label="$t('partner.account')" align="center" prop="account" width="140" show-overflow-tooltip />
      <el-table-column :label="$t('partner.profitRatio')" align="center" prop="profitRatio" width="100">
        <template #default="scope">{{ scope.row.profitRatio }}%</template>
      </el-table-column>
      <el-table-column :label="$t('partner.contactPerson')" align="center" prop="contactPerson" width="120" show-overflow-tooltip />
      <el-table-column :label="$t('partner.contactPhone')" align="center" prop="contactPhone" width="140" show-overflow-tooltip />
      <el-table-column :label="$t('partner.operation')" align="center" class-name="small-padding fixed-width" width="300px">
        <template #default="scope">
          <el-button link type="primary" icon="Key" @click="resetPwd(scope.row)" v-hasPermi="['manage:partner:edit']">{{ $t('partner.resetPwd') }}</el-button>
          <el-button link type="primary" icon="View" @click="getParnterInfo(scope.row)" v-hasPermi="['manage:partner:query']">{{ $t('partner.viewDetail') }}</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['manage:partner:edit']">{{ $t('partner.editPartner') }}</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['manage:partner:remove']">{{ $t('partner.deletePartner') }}</el-button>
        </template>
      </el-table-column>
    </el-table>
    
    <pagination
      v-show="total>0"
      :total="total"
      v-model:page="queryParams.pageNum"
      v-model:limit="queryParams.pageSize"
      @pagination="getList"
    />

    <!-- 添加或修改合作商管理对话框 -->
    <el-dialog :title="title" v-model="open" width="700px" append-to-body>
      <el-form ref="partnerRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item :label="$t('partner.partnerName')" prop="partnerName">
          <el-input v-model="form.partnerName" :placeholder="$t('partner.partnerNamePlaceholder')" />
        </el-form-item>
        <el-form-item :label="$t('partner.contactPerson')" prop="contactPerson">
          <el-input v-model="form.contactPerson" :placeholder="$t('partner.contactPersonPlaceholder')" />
        </el-form-item>
        <el-form-item :label="$t('partner.contactPhone')" prop="contactPhone">
          <el-input v-model="form.contactPhone" :placeholder="$t('partner.contactPhonePlaceholder')" />
        </el-form-item>
        <el-form-item :label="$t('partner.createTime')" prop="createTime" v-if="form.id!=null">
          {{form.createTime}}
        </el-form-item>
        <el-form-item :label="$t('partner.profitRatio')" prop="profitRatio">
          <el-input v-model="form.profitRatio" :placeholder="$t('partner.profitRatioPlaceholder')" />
        </el-form-item>
        <el-form-item :label="$t('partner.account')" prop="account" v-if="form.id==null">
          <el-input v-model="form.account" :placeholder="$t('partner.accountPlaceholder')" />
        </el-form-item>
        <el-form-item :label="$t('partner.password')" prop="password" v-if="form.id==null">
          <el-input v-model="form.password" type="password" :placeholder="$t('partner.passwordPlaceholder')" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">{{ $t('common.confirm') }}</el-button>
          <el-button @click="cancel">{{ $t('common.cancel') }}</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 查看合作商详情对话框 -->
    <el-dialog :title="$t('partner.detailTitle')" v-model="partnerInfoOpen" width="500px" append-to-body>
    <!-- 使用el-descriptions组件以卡片形式展示信息，更加整洁 -->
    <el-descriptions :column="2" border>
      <el-descriptions-item :label="$t('partner.partnerName')">{{ form.partnerName }}</el-descriptions-item>
      <el-descriptions-item :label="$t('partner.contactPerson')">{{ form.contactPerson }}</el-descriptions-item>
      <el-descriptions-item :label="$t('partner.contactPhone')">{{ form.contactPhone }}</el-descriptions-item>
      <el-descriptions-item :label="$t('partner.profitRatio')">{{ form.profitRatio }}%</el-descriptions-item>
    </el-descriptions>
  </el-dialog>
  </div>
</template>

<script setup name="Partner">
import { listPartner, getPartner, delPartner, addPartner, updatePartner,resetPartnerPwd } from "@/api/manage/partner";
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const { proxy } = getCurrentInstance();

const partnerList = ref([]);
const open = ref(false);
const loading = ref(true);
const showSearch = ref(true);
const ids = ref([]);
const single = ref(true);
const multiple = ref(true);
const total = ref(0);
const title = ref("");

const data = reactive({
  form: {},
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    partnerName: null,
  },
  rules: {
    partnerName: [
      { required: true, message: t('partner.partnerNameRequired'), trigger: "blur" }
    ],
    contactPerson: [
      { required: true, message: t('partner.contactPersonRequired'), trigger: "blur" }
    ],
    contactPhone: [
      { required: true, message: t('partner.contactPhoneRequired'), trigger: "blur" }
    ],
    profitRatio: [
      { required: true, message: t('partner.profitRatioRequired'), trigger: "blur" }
    ],
    account: [
      { required: true, message: t('partner.accountRequired'), trigger: "blur" }
    ],
    password: [
      { required: true, message: t('partner.passwordRequired'), trigger: "blur" }
    ],
  }
});

const { queryParams, form, rules } = toRefs(data);

/** 查询合作商管理列表 */
function getList() {
  loading.value = true;
  listPartner(queryParams.value).then(response => {
    partnerList.value = response.rows;
    total.value = response.total;
    loading.value = false;
  });
}

// 取消按钮
function cancel() {
  open.value = false;
  reset();
}

// 表单重置
function reset() {
  form.value = {
    id: null,
    partnerName: null,
    contactPerson: null,
    contactPhone: null,
    profitRatio: null,
    account: null,
    password: null,
    createTime: null,
    updateTime: null,
    createBy: null,
    updateBy: null,
    remark: null
  };
  proxy.resetForm("partnerRef");
}

/** 搜索按钮操作 */
function handleQuery() {
  queryParams.value.pageNum = 1;
  getList();
}

/** 重置按钮操作 */
function resetQuery() {
  proxy.resetForm("queryRef");
  handleQuery();
}

// 多选框选中数据
function handleSelectionChange(selection) {
  ids.value = selection.map(item => item.id);
  single.value = selection.length != 1;
  multiple.value = !selection.length;
}

/** 新增按钮操作 */
function handleAdd() {
  reset();
  open.value = true;
  title.value = t('partner.addPartnerTitle');
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset();
  const _id = row.id || ids.value
  getPartner(_id).then(response => {
    form.value = response.data;
    open.value = true;
    title.value = t('partner.editPartnerTitle');
  });
}
/* 查看合作商详情 */
const partnerInfoOpen=ref(false)
function getParnterInfo(row){
  reset();
  const _id = row.id 
  getPartner(_id).then(response => {
    form.value = response.data;
    partnerInfoOpen.value=true;
  });
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["partnerRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updatePartner(form.value).then(response => {
          proxy.$modal.msgSuccess(t('partner.updateSuccess'));
          open.value = false;
          getList();
        });
      } else {
        addPartner(form.value).then(response => {
          proxy.$modal.msgSuccess(t('partner.addSuccess'));
          open.value = false;
          getList();
        });
      }
    }
  });
}

/** 删除按钮操作 */
function handleDelete(row) {
  const _ids = row.id || ids.value;
  proxy.$modal.confirm(t('partner.deleteConfirm', [0, _ids])).then(function() {
    return delPartner(_ids);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess(t('partner.deleteSuccess'));
  }).catch(() => {});
}

/* 重置合作商密码 */
function resetPwd(row){
  const _id = row.id
  proxy.$modal.confirm(t('partner.resetPwdConfirm')).then(function() {
    return resetPartnerPwd(_id);
  }).then(() => {
    proxy.$modal.msgSuccess(t('partner.resetPwdSuccess'));
  }).catch(() => {});
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('manage/partner/export', {
    ...queryParams.value
  }, `partner_${new Date().getTime()}.xlsx`)
}

getList();
</script>
