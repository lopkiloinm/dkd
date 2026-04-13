<template>
  <div>
    <el-dialog :title="t('build.addOption')" v-model="open" width="800px" :close-on-click-modal="false" :modal-append-to-body="false"
      @open="onOpen" @close="onClose">
      <el-form ref="treeNodeForm" :model="formData" :rules="rules" label-width="100px">
        <el-col :span="24">
          <el-form-item :label="t('build.optionName')" prop="label">
            <el-input v-model="formData.label" :placeholder="t('build.optionNamePlaceholder')" clearable />
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <el-form-item :label="t('build.optionValue')" prop="value">
            <el-input v-model="formData.value" :placeholder="t('build.optionValuePlaceholder')" clearable>
              <template #append>
                <el-select v-model="dataType" :style="{ width: '100px' }">
                  <el-option v-for="(item, index) in dataTypeOptions" :key="index" :label="item.label" :value="item.value"
                    :disabled="item.disabled" />
                </el-select>
              </template>

            </el-input>
          </el-form-item>
        </el-col>
      </el-form>
      <div slot="footer">
        <el-button type="primary" @click="handelConfirm">
          {{ t('common.confirm') }}
        </el-button>
        <el-button @click="onClose">
          {{ t('common.cancel') }}
        </el-button>
      </div>
    </el-dialog>
  </div>
</template>
<script setup>
import { useI18n } from 'vue-i18n'
const { t } = useI18n()
const open = defineModel()
const emit = defineEmits(['confirm'])
const formData = ref({
  label: undefined,
  value: undefined
})
const rules = {
  label: [
    {
      required: true,
      message: t('build.optionNameRequired'),
      trigger: 'blur'
    }
  ],
  value: [
    {
      required: true,
      message: t('build.optionValueRequired'),
      trigger: 'blur'
    }
  ]
}
const dataType = ref('string')
const dataTypeOptions = ref([
  {
    label: t('build.stringType'),
    value: 'string'
  },
  {
    label: t('build.numberType'),
    value: 'number'
  }
])
const id = ref(100)
const treeNodeForm = ref()

function onOpen() {
  formData.value = {
    label: undefined,
    value: undefined
  }
}

function onClose() {
  open.value = false
}

function handelConfirm() {
  treeNodeForm.value.validate(valid => {
    if (!valid) return
    if (dataType.value === 'number') {
      formData.value.value = parseFloat(formData.value.value)
    }
    formData.value.id = id.value++
    emit('commit', formData.value)
    onClose()
  })
}
</script>
