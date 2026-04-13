<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-position="top">
      <el-form-item :label="$t('vmType.name')" prop="name">
        <el-input
          v-model="queryParams.name"
          :placeholder="$t('vmType.namePlaceholder')"
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
          v-hasPermi="['manage:vmType:add']"
        >{{ $t('vmType.addVmType') }}</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['manage:vmType:edit']"
        >{{ $t('vmType.editVmType') }}</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['manage:vmType:remove']"
        >{{ $t('vmType.deleteVmType') }}</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="Download"
          @click="handleExport"
          v-hasPermi="['manage:vmType:export']"
        >{{ $t('vmType.exportVmType') }}</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="vmTypeList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column :label="$t('vmType.name')" align="center" prop="name" min-width="150" show-overflow-tooltip />
      <el-table-column :label="$t('vmType.model')" align="center" prop="model" min-width="150" show-overflow-tooltip />
      <el-table-column :label="$t('vmType.image')" align="center" prop="image" width="120" show-overflow-tooltip>
        <template #default="scope">
          <image-preview :src="scope.row.image" :width="50" :height="50"/>
        </template>
      </el-table-column>
      <el-table-column :label="$t('vmType.vmRow')" align="center" prop="vmRow" width="100" />
      <el-table-column :label="$t('vmType.vmCol')" align="center" prop="vmCol" width="100" />
      <el-table-column :label="$t('vmType.channelMaxCapacity')" align="center" prop="channelMaxCapacity" width="150" show-overflow-tooltip />
      <el-table-column :label="$t('vmType.operation')" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['manage:vmType:edit']">{{ $t('vmType.editVmType') }}</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['manage:vmType:remove']">{{ $t('vmType.deleteVmType') }}</el-button>
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

    <!-- 添加或修改设备类型管理对话框 -->
    <el-dialog :title="title" v-model="open" width="700px" append-to-body>
      <el-form ref="vmTypeRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item :label="$t('vmType.name')" prop="name">
          <el-input v-model="form.name" :placeholder="$t('vmType.namePlaceholder')" />
        </el-form-item>
        <el-form-item :label="$t('vmType.model')" prop="model">
          <el-input v-model="form.model" :placeholder="$t('vmType.modelPlaceholder')" />
        </el-form-item>
        <el-form-item :label="$t('vmType.vmRow')" prop="vmRow">
          <el-input-number :min="1" :max="10" v-model="form.vmRow" :placeholder="$t('vmType.vmRowPlaceholder')" />
        </el-form-item>
        <el-form-item :label="$t('vmType.vmCol')" prop="vmCol">
          <el-input-number :min="1" :max="10" v-model="form.vmCol" :placeholder="$t('vmType.vmColPlaceholder')" />
        </el-form-item>
        <el-form-item :label="$t('vmType.channelMaxCapacity')" prop="channelMaxCapacity">
          <el-input-number
            v-model="form.channelMaxCapacity"
            :min="1"
            :max="10"
            :placeholder="$t('vmType.channelMaxCapacityPlaceholder')"
          />
        </el-form-item>
        <el-form-item :label="$t('vmType.image')" prop="image">
          <image-upload v-model="form.image"/>
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

<script setup name="VmType">
import { listVmType, getVmType, delVmType, addVmType, updateVmType } from "@/api/manage/vmType";
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const { proxy } = getCurrentInstance();

const vmTypeList = ref([]);
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
    name: null,
    model: null,
  },
  rules: {
    name: [
      { required: true, message: t('vmType.nameRequired'), trigger: "blur" }
    ],
    model: [
      { required: true, message: t('vmType.modelRequired'), trigger: "blur" }
    ],
    image: [
      { required: true, message: t('common.pleaseInput'), trigger: "blur" }
    ],
    vmRow: [
      { required: true, message: t('common.pleaseInput'), trigger: "blur" }
    ],
    vmCol: [
      { required: true, message: t('common.pleaseInput'), trigger: "blur" }
    ],
    channelMaxCapacity: [
      { required: true, message: t('common.pleaseInput'), trigger: "blur" }
    ]
  }
});

const { queryParams, form, rules } = toRefs(data);

/** 查询设备类型管理列表 */
function getList() {
  loading.value = true;
  listVmType(queryParams.value).then(response => {
    vmTypeList.value = response.rows;
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
    name: null,
    model: null,
    image: null,
    vmRow: null,
    vmCol: null,
    channelMaxCapacity: null
  };
  proxy.resetForm("vmTypeRef");
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
  title.value = t('vmType.addVmTypeTitle');
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset();
  const _id = row.id || ids.value
  getVmType(_id).then(response => {
    form.value = response.data;
    open.value = true;
    title.value = t('vmType.editVmTypeTitle');
  });
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["vmTypeRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updateVmType(form.value).then(response => {
          proxy.$modal.msgSuccess(t('vmType.updateSuccess'));
          open.value = false;
          getList();
        });
      } else {
        addVmType(form.value).then(response => {
          proxy.$modal.msgSuccess(t('vmType.addSuccess'));
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
  proxy.$modal.confirm(t('vmType.deleteConfirm', [0, _ids])).then(function() {
    return delVmType(_ids);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess(t('vmType.deleteSuccess'));
  }).catch(() => {});
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('manage/vmType/export', {
    ...queryParams.value
  }, `vmType_${new Date().getTime()}.xlsx`)
}

getList();
</script>
