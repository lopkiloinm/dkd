<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-position="top">
      <el-form-item :label="$t('vm.innerCode')" prop="innerCode">
        <el-input
          v-model="queryParams.innerCode"
          :placeholder="$t('vm.innerCodePlaceholder')"
          clearable
          @keyup.enter="handleQuery"
          style="width: 200px"
        />
      </el-form-item>
      <el-form-item :label="$t('vm.nodeId')" prop="nodeId">
        <el-input
          v-model="queryParams.nodeId"
          :placeholder="$t('vm.nodeIdPlaceholder')"
          clearable
          @keyup.enter="handleQuery"
          style="width: 200px"
        />
      </el-form-item>
      <el-form-item :label="$t('vm.regionId')" prop="regionId">
        <el-input
          v-model="queryParams.regionId"
          :placeholder="$t('vm.regionIdPlaceholder')"
          clearable
          @keyup.enter="handleQuery"
          style="width: 200px"
        />
      </el-form-item>
      <el-form-item :label="$t('vm.partnerId')" prop="partnerId">
        <el-input
          v-model="queryParams.partnerId"
          :placeholder="$t('vm.partnerIdPlaceholder')"
          clearable
          @keyup.enter="handleQuery"
          style="width: 200px"
        />
      </el-form-item>
      <el-form-item :label="$t('vm.model')" prop="vmTypeId">
        <el-input
          v-model="queryParams.vmTypeId"
          :placeholder="$t('vm.vmTypeIdPlaceholder')"
          clearable
          @keyup.enter="handleQuery"
          style="width: 200px"
        />
      </el-form-item>
      <el-form-item :label="$t('vm.status')" prop="vmStatus">
        <el-select v-model="queryParams.vmStatus" :placeholder="$t('vm.statusPlaceholder')" clearable>
          <el-option
            v-for="dict in vm_status"
            :key="dict.value"
            :label="dict.label"
            :value="dict.value"
          />
        </el-select>
      </el-form-item>
      <el-form-item :label="$t('vm.policyId')" prop="policyId">
        <el-input
          v-model="queryParams.policyId"
          :placeholder="$t('vm.policyIdPlaceholder')"
          clearable
          @keyup.enter="handleQuery"
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
          v-hasPermi="['manage:vm:add']"
        >{{ $t('vm.addVm') }}</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['manage:vm:edit']"
        >{{ $t('vm.editVm') }}</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['manage:vm:remove']"
        >{{ $t('vm.deleteVm') }}</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="Download"
          @click="handleExport"
          v-hasPermi="['manage:vm:export']"
        >{{ $t('vm.exportVm') }}</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="vmList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column :label="$t('vm.primaryKey')" align="center" prop="id" width="80" show-overflow-tooltip />
      <el-table-column :label="$t('vm.innerCode')" align="center" prop="innerCode" min-width="150" show-overflow-tooltip />
      <el-table-column :label="$t('vm.addr')" align="center" prop="addr" min-width="150" show-overflow-tooltip />
      <el-table-column :label="$t('vm.partnerId')" align="center" prop="partnerId" width="120" show-overflow-tooltip />
      <el-table-column :label="$t('vm.model')" align="center" prop="vmTypeId" width="120" show-overflow-tooltip />
      <el-table-column :label="$t('vm.status')" align="center" prop="vmStatus" width="120" show-overflow-tooltip>
        <template #default="scope">
          <dict-tag :options="vm_status" :value="scope.row.vmStatus"/>
        </template>
      </el-table-column>
      <el-table-column :label="$t('vm.operation')" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['manage:vm:edit']">{{ $t('vm.editVm') }}</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['manage:vm:remove']">{{ $t('vm.deleteVm') }}</el-button>
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

    <!-- 添加或修改设备管理对话框 -->
    <el-dialog :title="title" v-model="open" width="700px" append-to-body>
      <el-form ref="vmRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item :label="$t('vm.innerCode')" prop="innerCode">
          <el-input v-model="form.innerCode" :placeholder="$t('vm.innerCodePlaceholder')" />
        </el-form-item>
        <el-form-item :label="$t('vm.nodeId')" prop="nodeId">
          <el-input v-model="form.nodeId" :placeholder="$t('vm.nodeIdPlaceholder')" />
        </el-form-item>
        <el-form-item :label="$t('vm.model')" prop="vmTypeId">
          <el-input v-model="form.vmTypeId" :placeholder="$t('vm.vmTypeIdPlaceholder')" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">{{ $t('common.confirm') }}</el-button>
          <el-button @click="cancel">{{ $t('common.cancel') }}</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="Vm">
import { listVm, getVm, delVm, addVm, updateVm } from "@/api/manage/vm";
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const { proxy } = getCurrentInstance();
const { vm_status } = proxy.useDict('vm_status');

const vmList = ref([]);
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
    innerCode: null,
    nodeId: null,
    businessType: null,
    regionId: null,
    partnerId: null,
    vmTypeId: null,
    vmStatus: null,
    runningStatus: null,
    policyId: null,
  },
  rules: {
    nodeId: [
      { required: true, message: t('vm.nodeIdRequired'), trigger: "blur" }
    ],
    vmTypeId: [
      { required: true, message: t('vm.vmTypeIdRequired'), trigger: "blur" }
    ],
  }
});

const { queryParams, form, rules } = toRefs(data);

/** 查询设备管理列表 */
function getList() {
  loading.value = true;
  listVm(queryParams.value).then(response => {
    vmList.value = response.rows;
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
    innerCode: null,
    channelMaxCapacity: null,
    nodeId: null,
    addr: null,
    lastSupplyTime: null,
    businessType: null,
    regionId: null,
    partnerId: null,
    vmTypeId: null,
    vmStatus: null,
    runningStatus: null,
    longitudes: null,
    latitude: null,
    clientId: null,
    policyId: null,
    createTime: null,
    updateTime: null
  };
  proxy.resetForm("vmRef");
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
  title.value = t('vm.addVmTitle');
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset();
  const _id = row.id || ids.value
  getVm(_id).then(response => {
    form.value = response.data;
    open.value = true;
    title.value = t('vm.editVmTitle');
  });
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["vmRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updateVm(form.value).then(response => {
          proxy.$modal.msgSuccess(t('vm.updateSuccess'));
          open.value = false;
          getList();
        });
      } else {
        addVm(form.value).then(response => {
          proxy.$modal.msgSuccess(t('vm.addSuccess'));
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
  proxy.$modal.confirm(t('vm.deleteConfirm', [0, _ids])).then(function() {
    return delVm(_ids);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess(t('vm.deleteSuccess'));
  }).catch(() => {});
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('manage/vm/export', {
    ...queryParams.value
  }, `vm_${new Date().getTime()}.xlsx`)
}

getList();
</script>
