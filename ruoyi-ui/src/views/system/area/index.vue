<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="区划名称" prop="name">
        <el-input
          v-model="queryParams.name"
          placeholder="请输入区划名称"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="区划编码" prop="code">
        <el-input
          v-model="queryParams.code"
          placeholder="请输入区划编码"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="层级" prop="areaLevel">
        <el-select v-model="queryParams.areaLevel" placeholder="请选择层级" clearable>
          <el-option
            v-for="dict in sys_area_level"
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
          v-hasPermi="['system:area:add']"
        >新增</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table
      v-if="refreshTable"
      v-loading="loading"
      :data="areaList"
      row-key="code"
      :tree-props="{children: 'children', hasChildren: 'hasChildren'}"
      lazy
      :load="loadChildren"
    >
      <el-table-column label="区划名称" prop="name" />
      <el-table-column label="区划编码" align="center" prop="code" />
      <el-table-column label="层级" align="center" prop="areaLevel">
        <template #default="scope">
          <dict-tag :options="sys_area_level" :value="scope.row.areaLevel"/>
        </template>
      </el-table-column>
      <el-table-column label="排序号" align="center" prop="sort" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['system:area:edit']">修改</el-button>
          <el-button link type="primary" icon="Plus" @click="handleAdd(scope.row)" v-hasPermi="['system:area:add']">新增</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['system:area:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 添加或修改区划管理对话框 -->
    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="areaRef" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="24">
            <el-form-item label="区划名称" prop="name">
              <el-input v-model="form.name" placeholder="请输入区划名称" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="区划编码" prop="code">
              <el-input v-model="form.code" placeholder="请输入区划编码" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="父级区划" prop="parentCode">
              <el-tree-select
                v-model="form.parentCode"
                v-loading="treeLoading"
                :data="areaOptions"
                :props="{ value: 'code', label: 'name', children: 'children' }"
                value-key="code"
                placeholder="请选择父级区划"
                check-strictly
                lazy
                :load="loadTreeselect"
                node-key="code"
                :render-after-expand="false"
              />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="层级" prop="areaLevel">
              <el-radio-group v-model="form.areaLevel">
                <el-radio
                  v-for="dict in sys_area_level"
                  :key="dict.value"
                  :label="dict.value"
                >{{dict.label}}</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="排序号" prop="sort">
              <el-input v-model="form.sort" placeholder="请输入排序号" />
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

<script setup name="Area">
import { listArea, listAreaTree, getArea, getAreaByCode, delArea, addArea, updateArea } from "@/api/system/area"

const { proxy } = getCurrentInstance()
const { sys_area_level } = proxy.useDict('sys_area_level')

const areaList = ref([])
const areaOptions = ref([])
const treeLoading = ref(false)
const open = ref(false)
const loading = ref(true)
const showSearch = ref(true)
const title = ref("")
const refreshTable = ref(true)
// 缓存已加载的树节点数据，key=parentCode, value=children数组
const treeCache = reactive({})

const data = reactive({
  form: {},
  queryParams: {
    name: null,
    code: null,
    areaLevel: null,
  },
  rules: {
    id: [
      { required: true, message: "编号不能为空", trigger: "blur" }
    ],
    name: [
      { required: true, message: "区划名称不能为空", trigger: "blur" }
    ],
    code: [
      { required: true, message: "区划编码不能为空", trigger: "blur" }
    ],
    areaLevel: [
      { required: true, message: "层级不能为空", trigger: "change" }
    ],
  }
})

const { queryParams, form, rules } = toRefs(data)

/** 查询区划管理列表 */
function getList() {
  loading.value = true
  listArea(queryParams.value).then(response => {
    // 标记是否有子节点（层级 < 4 才有子节点）
    areaList.value = (response.data || []).map(item => ({
      ...item,
      hasChildren: item.areaLevel < '4'
    }))
    loading.value = false
  })
}

/** 懒加载子节点 */
function loadChildren(row, treeNode, resolve) {
  listAreaTree(row.code).then(response => {
    const children = (response.data || []).map(item => ({
      ...item,
      hasChildren: item.areaLevel < '4'
    }))
    resolve(children)
  })
}

/** 查询区划管理下拉树结构（预加载省级数据，更深层级懒加载） */
function getTreeselect() {
  treeLoading.value = true
  return listArea().then(response => {
    const provinces = (response.data || []).map(item => ({
      ...item,
      hasChildren: item.areaLevel < '4'
    }))
    // 预加载省级数据到缓存
    treeCache['0'] = provinces
    // 根节点直接挂载省级子节点，首次展开即可见
    areaOptions.value = [
      { code: '0', name: '顶级节点', areaLevel: '0', children: provinces, hasChildren: provinces.length > 0 }
    ]
  }).catch(err => {
    areaOptions.value = [
      { code: '0', name: '顶级节点', areaLevel: '0', children: [], hasChildren: false }
    ]
    console.error('加载区划树失败:', err)
  }).finally(() => {
    treeLoading.value = false
  })
}

/**
 * 预加载 ancestors 路径上的所有节点并注入到 tree-select 数据中
 * @param {string} parentCode 父级区划编码
 * @param {string} ancestors 祖先编码链（逗号分隔），如 '0,44,4419'
 */
function loadAncestorPath(parentCode, ancestors) {
  return new Promise((resolve) => {
    if (!parentCode || parentCode === '0') return resolve()

    // ancestors 如 '0,44,4419'（逗号分隔），去掉最后一段得到纯祖先链
    const rawAncestors = ancestors || ''
    const allCodes = rawAncestors
      .split(',')
      .filter(c => c !== '0')
    // 加上父节点自己
    const pathCodes = [...allCodes, parentCode]

    const loadNext = (codes) => {
      if (codes.length === 0) return resolve()
      const code = codes[0]
      getAreaByCode(code).then(res => {
        if (!res.data) return loadNext(codes.slice(1))
        const node = res.data
        const findParent = (items) => {
          for (const item of items) {
            if (item.code === code) return null // 已存在，不注入
            if (item.code === node.parentCode) return item
            if (item.children) {
              const found = findParent(item.children)
              if (found) return found
            }
          }
          return null
        }
        const parentNode = findParent(areaOptions.value)
        if (parentNode) {
          if (!parentNode.children) parentNode.children = []
          // 避免重复注入
          if (!parentNode.children.some(c => c.code === node.code)) {
            parentNode.children.push(node)
          }
        }
        loadNext(codes.slice(1))
      }).catch(() => loadNext(codes.slice(1)))
    }
    loadNext(pathCodes)
  })
}

/** 懒加载下拉树子节点（仅用于更深层级的按需加载） */
function loadTreeselect(node, resolve) {
  const parentCode = node.data ? node.data.code : '0'
  // 根节点的省级数据已在 getTreeselect 中预加载并挂载到 children
  if (node.level === 0) {
    const cached = treeCache['0']
    if (cached && cached.length > 0) {
      return resolve(cached)
    }
    return resolve([])
  }
  // 检查缓存
  if (treeCache[parentCode]) {
    return resolve(treeCache[parentCode])
  }
  // 懒加载更深层级
  listAreaTree(parentCode).then(response => {
    const children = (response.data || []).map(item => ({
      ...item,
      hasChildren: item.areaLevel < '4'
    }))
    resolve(children)
  }).catch(() => resolve([]))
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
    code: null,
    parentCode: null,
    ancestors: null,
    areaLevel: null,
    sort: 1,
    createTime: null,
    updateTime: null,
    createBy: null,
    updateBy: null,
    remark: null
  }
  proxy.resetForm("areaRef")
}

/** 搜索按钮操作 */
function handleQuery() {
  getList()
}

/** 重置按钮操作 */
function resetQuery() {
  proxy.resetForm("queryRef")
  handleQuery()
}

/** 新增按钮操作 */
async function handleAdd(row) {
  reset()
  await getTreeselect()
  if (row != null && row.code) {
    form.value.parentCode = row.code
    // 子级层级 = 父级层级 + 1
    if (row.areaLevel) {
      const nextLevel = parseInt(row.areaLevel) + 1
      if (nextLevel <= 4) {
        form.value.areaLevel = String(nextLevel)
      }
    }
    // 预加载祖先路径，确保 tree-select 能显示父级名称
    await loadAncestorPath(row.code, row.ancestors)
  } else {
    form.value.parentCode = '0'
    form.value.areaLevel = '1'
  }
  open.value = true
  title.value = "添加区划管理"
}

/** 修改按钮操作 */
async function handleUpdate(row) {
  reset()
  // 先获取完整数据（包含 ancestors）
  const res = await getArea(row.id)
  const fullData = res.data
  await getTreeselect()
  // 预加载祖先路径
  await loadAncestorPath(fullData.parentCode, fullData.ancestors)
  form.value = fullData
  open.value = true
  title.value = "修改区划管理"
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["areaRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updateArea(form.value).then(() => {
          proxy.$modal.msgSuccess("修改成功")
          open.value = false
          getList()
        })
      } else {
        addArea(form.value).then(() => {
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
  proxy.$modal.confirm('是否确认删除区划管理编号为"' + row.id + '"的数据项？').then(function() {
    return delArea(row.id)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}

getList()
</script>
