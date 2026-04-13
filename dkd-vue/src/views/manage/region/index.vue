<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-position="top">
      <el-form-item :label="$t('region.regionName')" prop="regionName">
        <el-input
          v-model="queryParams.regionName"
          :placeholder="$t('region.regionNamePlaceholder')"
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
          v-hasPermi="['manage:region:add']"
        >{{ $t('region.addRegion') }}</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['manage:region:edit']"
        >{{ $t('region.editRegion') }}</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['manage:region:remove']"
        >{{ $t('region.deleteRegion') }}</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="Download"
          @click="handleExport"
          v-hasPermi="['manage:region:export']"
        >{{ $t('region.exportRegion') }}</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="regionList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column :label="$t('region.serialNumber')" type="index" width="80" align="center" prop="id" />
      <el-table-column :label="$t('region.regionName')" align="center" prop="regionName" min-width="150" show-overflow-tooltip />
      <el-table-column :label="$t('region.nodeCount')" align="center" prop="nodeCount" width="100" />
      <el-table-column :label="$t('region.remark')" align="center" prop="remark" min-width="180" show-overflow-tooltip />
      <el-table-column :label="$t('region.operation')" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="getRegionInfo(scope.row)" v-hasPermi="['manage:node:list']">{{ $t('region.viewDetail') }}</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['manage:region:edit']">{{ $t('region.editRegion') }}</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['manage:region:remove']">{{ $t('region.deleteRegion') }}</el-button>
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

    <!-- 添加或修改区域管理对话框 -->
    <el-dialog :title="title" v-model="open" width="700px" append-to-body>
      <el-form ref="regionRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item :label="$t('region.regionName')" prop="regionName">
          <el-input v-model="form.regionName" :placeholder="$t('region.regionNamePlaceholder')" />
        </el-form-item>
        <el-form-item :label="$t('region.remark')" prop="remark">
          <el-input v-model="form.remark" type="textarea" :placeholder="$t('region.remarkPlaceholder')" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">{{ $t('common.confirm') }}</el-button>
          <el-button @click="cancel">{{ $t('common.cancel') }}</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 查看详情对话框 -->
     <el-dialog :title="$t('region.detailTitle')" v-model="regionInfoOpen" width="500px" append-to-body>
      <el-form-item :label="$t('region.regionName')" prop="regionName">
          <el-input v-model="form.regionName" :placeholder="$t('region.regionNamePlaceholder')" disabled />
        </el-form-item>
        <label>{{ $t('region.includedNodes') }}</label>
    <el-table :data="nodeList" >
      <el-table-column :label="$t('region.serialNumber')" type="index" width="80" align="center" prop="id" />
      <el-table-column :label="$t('region.nodeName')" align="center" prop="nodeName" />
      <el-table-column :label="$t('region.vmCount')" align="center" prop="vmCount" />
    </el-table>
    </el-dialog>
  </div>
</template>

<script setup name="Region">
import { listRegion, getRegion, delRegion, addRegion, updateRegion } from "@/api/manage/region";
import{listNode} from "@/api/manage/node";
import{loadAllParams} from "@/api/page";
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const { proxy } = getCurrentInstance();

const regionList = ref([]);
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
    regionName: null,
  },
  rules: {
    regionName: [
      { required: true, message: t('region.regionNameRequired'), trigger: "blur" }
    ],
    remark: [
      { required: true, message: t('common.pleaseInput'), trigger: "blur" }
    ]
  }
});

const { queryParams, form, rules } = toRefs(data);

/** 查询区域管理列表 */
function getList() {
  loading.value = true;
  listRegion(queryParams.value).then(response => {
    regionList.value = response.rows;
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
    regionName: null,
    createTime: null,
    updateTime: null,
    createBy: null,
    updateBy: null,
    remark: null
  };
  proxy.resetForm("regionRef");
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
  title.value = t('region.addRegionTitle');
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset();
  const _id = row.id || ids.value
  getRegion(_id).then(response => {
    form.value = response.data;
    open.value = true;
    title.value = t('region.editRegionTitle');
  });
}

/* 查看详情操作按钮 */
const nodeList=ref([]);
const regionInfoOpen=ref(false);
function getRegionInfo(row){
  // 查询区域信息
  reset();
  const _id = row.id 
  getRegion(_id).then(response => {
    form.value = response.data;
  });
  // 查看点位列表
  loadAllParams.regionId=row.id
  listNode(loadAllParams).then(response => {
    nodeList.value = response.rows;
  });
  regionInfoOpen.value=true;
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["regionRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updateRegion(form.value).then(response => {
          proxy.$modal.msgSuccess(t('region.updateSuccess'));
          open.value = false;
          getList();
        });
      } else {
        addRegion(form.value).then(response => {
          proxy.$modal.msgSuccess(t('region.addSuccess'));
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
  proxy.$modal.confirm(t('region.deleteConfirm', [0, _ids])).then(function() {
    return delRegion(_ids);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess(t('region.deleteSuccess'));
  }).catch(() => {});
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('manage/region/export', {
    ...queryParams.value
  }, `region_${new Date().getTime()}.xlsx`)
}

getList();
</script>
