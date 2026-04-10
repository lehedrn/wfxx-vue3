<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="设备型号名称" prop="name">
        <el-input
          v-model="queryParams.name"
          placeholder="请输入设备型号名称"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="设备类型" prop="deviceType">
        <el-select v-model="queryParams.deviceType" placeholder="请选择设备类型" clearable>
          <el-option
            v-for="dict in sys_device_type"
            :key="dict.value"
            :label="dict.label"
            :value="dict.value"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable>
          <el-option
            v-for="dict in sys_common_status"
            :key="dict.value"
            :label="dict.label"
            :value="dict.value"
          />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="Plus"
          @click="handleAdd"
          v-hasPermi="['base:deviceModel:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['base:deviceModel:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['base:deviceModel:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="Download"
          @click="handleExport"
          v-hasPermi="['base:deviceModel:export']"
        >导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="deviceModelList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="编号" align="center" prop="id" />
      <el-table-column label="设备型号名称" align="center" prop="name" />
      <el-table-column label="设备类型" align="center" prop="deviceType">
        <template #default="scope">
          <dict-tag :options="sys_device_type" :value="scope.row.deviceType"/>
        </template>
      </el-table-column>
      <el-table-column label="CPU型号" align="center" prop="cpuModel">
        <template #default="scope">
          <dict-tag :options="sys_cpu_model" :value="scope.row.cpuModel"/>
        </template>
      </el-table-column>
      <el-table-column label="GPU型号" align="center" prop="gpuModel">
        <template #default="scope">
          <dict-tag :options="sys_gpu_model" :value="scope.row.gpuModel"/>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status">
        <template #default="scope">
          <dict-tag :options="sys_common_status" :value="scope.row.status"/>
        </template>
      </el-table-column>
      <el-table-column label="备注" align="center" prop="remark" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['base:deviceModel:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['base:deviceModel:remove']">删除</el-button>
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

    <!-- 添加或修改设备型号管理对话框 -->
    <el-dialog :title="title" v-model="open" width="800px" append-to-body>
      <el-form ref="deviceModelRef" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="设备型号名称" prop="name">
              <el-input v-model="form.name" placeholder="请输入设备型号名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="设备类型" prop="deviceType">
              <el-select v-model="form.deviceType" placeholder="请选择设备类型">
                <el-option
                  v-for="dict in sys_device_type"
                  :key="dict.value"
                  :label="dict.label"
                  :value="dict.value"
                ></el-option>
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="内存(GB)" prop="memory">
              <el-input v-model="form.memory" placeholder="请输入内存(GB)" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="硬盘容量(GB)" prop="disk">
              <el-input v-model="form.disk" placeholder="请输入硬盘容量(GB)" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="操作系统" prop="os">
              <el-select v-model="form.os" placeholder="请选择操作系统">
                <el-option
                  v-for="dict in sys_device_os"
                  :key="dict.value"
                  :label="dict.label"
                  :value="dict.value"
                ></el-option>
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="主板厂家" prop="motherboardManufacturer">
              <el-input v-model="form.motherboardManufacturer" placeholder="请输入主板厂家" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="CPU型号" prop="cpuModel">
              <el-select v-model="form.cpuModel" placeholder="请选择CPU型号">
                <el-option
                  v-for="dict in sys_cpu_model"
                  :key="dict.value"
                  :label="dict.label"
                  :value="dict.value"
                ></el-option>
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="CPU核心数" prop="cpuCores">
              <el-input v-model="form.cpuCores" placeholder="请输入CPU核心数" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="主频(GHz)" prop="cpuFrequency">
              <el-input v-model="form.cpuFrequency" placeholder="请输入主频(GHz)" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="CPU数量" prop="cpuCount">
              <el-input v-model="form.cpuCount" placeholder="请输入CPU数量" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="GPU型号" prop="gpuModel">
              <el-select v-model="form.gpuModel" placeholder="请选择GPU型号">
                <el-option
                  v-for="dict in sys_gpu_model"
                  :key="dict.value"
                  :label="dict.label"
                  :value="dict.value"
                ></el-option>
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="GPU算力" prop="gpuComputePower">
              <el-input v-model="form.gpuComputePower" placeholder="请输入GPU算力" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="显存(GB)" prop="gpuMemory">
              <el-input v-model="form.gpuMemory" placeholder="请输入显存(GB)" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="GPU数量" prop="gpuCount">
              <el-input v-model="form.gpuCount" placeholder="请输入GPU数量" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-radio-group v-model="form.status">
                <el-radio
                  v-for="dict in sys_common_status"
                  :key="dict.value"
                  :label="dict.value"
                >{{dict.label}}</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="备注" prop="remark">
              <el-input v-model="form.remark" type="textarea" placeholder="请输入内容" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="DeviceModel">
import { listDeviceModel, getDeviceModel, delDeviceModel, addDeviceModel, updateDeviceModel } from "@/api/base/deviceModel"

const { proxy } = getCurrentInstance()
const { sys_gpu_model, sys_device_type, sys_common_status, sys_cpu_model, sys_device_os } = proxy.useDict('sys_gpu_model', 'sys_device_type', 'sys_common_status', 'sys_cpu_model', 'sys_device_os')

const deviceModelList = ref([])
const open = ref(false)
const loading = ref(true)
const showSearch = ref(true)
const ids = ref([])
const single = ref(true)
const multiple = ref(true)
const total = ref(0)
const title = ref("")

const data = reactive({
  form: {},
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    name: null,
    deviceType: null,
    status: null,
  },
  rules: {
    id: [
      { required: true, message: "编号不能为空", trigger: "blur" }
    ],
    name: [
      { required: true, message: "设备型号名称不能为空", trigger: "blur" }
    ],
    deviceType: [
      { required: true, message: "设备类型不能为空", trigger: "change" }
    ],
    memory: [
      { required: true, message: "内存(GB)不能为空", trigger: "blur" }
    ],
    status: [
      { required: true, message: "状态不能为空", trigger: "change" }
    ],
  }
})

const { queryParams, form, rules } = toRefs(data)

/** 查询设备型号管理列表 */
function getList() {
  loading.value = true
  listDeviceModel(queryParams.value).then(response => {
    deviceModelList.value = response.rows
    total.value = response.total
    loading.value = false
  })
}

// 取消按钮
function cancel() {
  open.value = false
  reset()
}

// 表单重置
function reset() {
  form.value = {
    id: null,
    name: null,
    deviceType: null,
    memory: null,
    disk: null,
    os: null,
    motherboardManufacturer: null,
    cpuModel: null,
    cpuCores: null,
    cpuFrequency: null,
    cpuCount: null,
    gpuModel: null,
    gpuComputePower: null,
    gpuMemory: null,
    gpuCount: null,
    status: "0",
    createTime: null,
    updateTime: null,
    createBy: null,
    updateBy: null,
    remark: null
  }
  proxy.resetForm("deviceModelRef")
}

/** 搜索按钮操作 */
function handleQuery() {
  queryParams.value.pageNum = 1
  getList()
}

/** 重置按钮操作 */
function resetQuery() {
  proxy.resetForm("queryRef")
  handleQuery()
}

// 多选框选中数据
function handleSelectionChange(selection) {
  ids.value = selection.map(item => item.id)
  single.value = selection.length != 1
  multiple.value = !selection.length
}

/** 新增按钮操作 */
function handleAdd() {
  reset()
  open.value = true
  title.value = "添加设备型号管理"
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset()
  const _id = row.id || ids.value
  getDeviceModel(_id).then(response => {
    form.value = response.data
    open.value = true
    title.value = "修改设备型号管理"
  })
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["deviceModelRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updateDeviceModel(form.value).then(() => {
          proxy.$modal.msgSuccess("修改成功")
          open.value = false
          getList()
        })
      } else {
        addDeviceModel(form.value).then(() => {
          proxy.$modal.msgSuccess("新增成功")
          open.value = false
          getList()
        })
      }
    }
  })
}

/** 删除按钮操作 */
function handleDelete(row) {
  const _ids = row.id || ids.value
  proxy.$modal.confirm('是否确认删除设备型号管理编号为"' + _ids + '"的数据项？').then(function() {
    return delDeviceModel(_ids)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('base/deviceModel/export', {
    ...queryParams.value
  }, `deviceModel_${new Date().getTime()}.xlsx`)
}

getList()
</script>
