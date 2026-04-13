<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-position="top">
      <el-form-item :label="$t('node.nodeName')" prop="nodeName">
        <el-input
          v-model="queryParams.nodeName"
          :placeholder="$t('node.nodeNamePlaceholder')"
          clearable
          @keyup.enter="handleQuery"
          style="width: 200px"
        />
      </el-form-item>
      <el-form-item :label="$t('node.regionSearch')" prop="regionId">
        <el-select  v-model="queryParams.regionId" :placeholder="$t('node.regionPlaceholder')" clearable style="width: 200px">
          <el-option v-for="item in regionList" :key="item.id" :label="item.regionName" :value="item.id"></el-option>
        </el-select>
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
          v-hasPermi="['manage:node:add']"
        >{{ $t('node.addNode') }}</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['manage:node:edit']"
        >{{ $t('node.editNode') }}</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['manage:node:remove']"
        >{{ $t('node.deleteNode') }}</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="Download"
          @click="handleExport"
          v-hasPermi="['manage:node:export']"
        >{{ $t('node.exportNode') }}</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="nodeList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column :label="$t('node.serialNumber')" type="index" width="80" align="center" prop="id" />
      <el-table-column :label="$t('node.nodeName')" align="center" prop="nodeName" min-width="150" show-overflow-tooltip />
      <el-table-column :label="$t('node.regionName')" align="center" prop="region.regionName" min-width="150" show-overflow-tooltip />
      <el-table-column :label="$t('node.businessType')" align="center" prop="businessType" width="150" show-overflow-tooltip>
        <template #default="scope">
          <dict-tag :options="business_type" :value="scope.row.businessType"/>
        </template>
      </el-table-column>
      <el-table-column :label="$t('node.partner')" align="center" prop="partner.partnerName" min-width="150" show-overflow-tooltip />
      <el-table-column :label="$t('node.address')" align="left" prop="address" min-width="200" show-overflow-tooltip/>
      <el-table-column :label="$t('node.operation')" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['manage:node:edit']">{{ $t('node.editNode') }}</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['manage:node:remove']">{{ $t('node.deleteNode') }}</el-button>
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

    <!-- 添加或修改点位管理对话框 -->
    <el-dialog :title="title" v-model="open" width="700px" append-to-body>
      <el-form ref="nodeRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item :label="$t('node.nodeName')" prop="nodeName">
          <el-input v-model="form.nodeName" :placeholder="$t('node.nodeNamePlaceholder')" />
        </el-form-item>
        <el-form-item :label="$t('node.region')" prop="regionId">
           <el-select v-model="form.regionId" :placeholder="$t('node.regionPlaceholder')">
            <el-option v-for="item in regionList" :key="item.id" :label="item.regionName" :value="item.id"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item :label="$t('node.businessType')" prop="businessType">
          <el-select v-model="form.businessType" :placeholder="$t('node.businessTypePlaceholder')">
            <el-option
              v-for="dict in business_type"
              :key="dict.value"
              :label="dict.label"
              :value="parseInt(dict.value)"
            ></el-option>
          </el-select>
        </el-form-item>
        <el-form-item :label="$t('node.belongPartner')" prop="partnerId">
           <el-select v-model="form.partnerId" :placeholder="$t('node.partnerPlaceholder')">
            <el-option v-for="item in partnerList" :key="item.id" :label="item.partnerName" :value="item.id"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item :label="$t('node.address')" prop="address">
          <el-input v-model="form.address" type="textarea" :placeholder="$t('node.addressPlaceholder')" />
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

<script setup name="Node">
import { listNode, getNode, delNode, addNode, updateNode } from "@/api/manage/node";
import {listRegion} from "@/api/manage/region";
import {listPartner} from "@/api/manage/partner";
import{loadAllParams} from "@/api/page";
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const { proxy } = getCurrentInstance();
const { business_type } = proxy.useDict('business_type');

const nodeList = ref([]);
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
    nodeName: null,
    regionId: null,
    partnerId: null,
  },
  rules: {
    nodeName: [
      { required: true, message: t('node.nodeNameRequired'), trigger: "blur" }
    ],
    address: [
      { required: true, message: t('node.addressRequired'), trigger: "blur" }
    ],
    businessType: [
      { required: true, message: t('common.pleaseSelect'), trigger: "change" }
    ],
    regionId: [
      { required: true, message: t('common.pleaseSelect'), trigger: "blur" }
    ],
    partnerId: [
      { required: true, message: t('common.pleaseSelect'), trigger: "blur" }
    ],
  }
});

const { queryParams, form, rules } = toRefs(data);

/** 查询点位管理列表 */
function getList() {
  loading.value = true;
  listNode(queryParams.value).then(response => {
    nodeList.value = response.rows;
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
    nodeName: null,
    address: null,
    businessType: null,
    regionId: null,
    partnerId: null,
    createTime: null,
    updateTime: null,
    createBy: null,
    updateBy: null,
    remark: null
  };
  proxy.resetForm("nodeRef");
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
  title.value = t('node.addNodeTitle');
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset();
  const _id = row.id || ids.value
  getNode(_id).then(response => {
    form.value = response.data;
    open.value = true;
    title.value = t('node.editNodeTitle');
  });
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["nodeRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updateNode(form.value).then(response => {
          proxy.$modal.msgSuccess(t('node.updateSuccess'));
          open.value = false;
          getList();
        });
      } else {
        addNode(form.value).then(response => {
          proxy.$modal.msgSuccess(t('node.addSuccess'));
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
  proxy.$modal.confirm(t('node.deleteConfirm', [0, _ids])).then(function() {
    return delNode(_ids);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess(t('node.deleteSuccess'));
  }).catch(() => {});
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('manage/node/export', {
    ...queryParams.value
  }, `node_${new Date().getTime()}.xlsx`)
}
/* 查询所有的条件对象 */
/* const loadAllParams=reactive({
  pageNum:1,
  pageSize:10000
}) */


/* 查询区域列表 */
const regionList=ref([]);
function getRegionList(){
  listRegion(loadAllParams).then(response => {
    regionList.value = response.rows;
  });
}

/* 查询合作商列表 */
const partnerList=ref([]);
function getPartnerList(){
  listPartner(loadAllParams).then(response => {
    partnerList.value = response.rows;
  });
}
getPartnerList();
getRegionList();
getList();
</script>
