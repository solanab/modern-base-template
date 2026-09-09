# 已生效代码合同

> **层 1 Stable**（当前 MUST）+ 少量未来可晋升的层 2 约束。 改任何一节：同步可执行配置和必要的 backlog → `just check`。
> 本文不能与 `justfile`、`prek.toml` 或 CI 形成第二套规则。

**层 0 Invariant** 不在此重复长文，见根 `AGENTS.md` 的维护者合同。

## Stable（层 1：当前 MUST）

### S1. 无主语言边界

| 政策                                                     | 执行手段                   |
| -------------------------------------------------------- | -------------------------- |
| 本模板只承载 `.sh`、`.md`、`.toml`、YAML 与纯数据文件    | 目录约定、代码审查         |
| 出现主语言需求时迁往对应 `modern-*-template`，不在此生长 | 根 `AGENTS.md`、代码审查   |
| 工具一律使用独立二进制，不引入语言包管理器               | `scripts/install-tools.sh` |

### S2. 命令入口和脚本边界

- 人类可见任务只有 `just` 入口；复杂 shell 编排放在 `scripts/`。
- 项目 shell 脚本放在 `scripts/`，自动纳入 shfmt、ShellCheck 和 source-lines 门禁。
- 不保留平行的 Makefile、Taskfile 或旧兼容入口。

执行手段：目录约定、`justfile-check`、`just check` 和人工审查。

### S3. 格式与文档基线

- shell、TOML、YAML、Markdown 各自只有一条格式化主链：shfmt 管 shell；Tombi 管 TOML； `yamlfmt` 管 YAML；dprint 管
  Markdown 格式，rumdl 管 Markdown lint。
- Tombi 在 `just check` 中把所有 warning 提升为错误。
- source-lines 是唯一的仓库源码规模门禁：默认每个文件不超过 300 个有效代码行和 1000
  个总行数；总行数包括有效代码、纯注释行与空行。300/1000 是治理护栏，不是普适缺陷阈值； 越界首先触发拆分或重构评审。
- 只有在 source-lines.toml 中以精确路径写明理由，文件才能提高限额；不预先放宽测试或示例。
- 新增或重命名 recipe、脚本或质量工具时，同步 `scripts/README.md`、README 和帮助文本。

执行手段：`just fmt-check`、`just lint`、`source-lines.toml`、`just check`。

### S4. 工具供应链

| 政策                                    | 执行手段                   |
| --------------------------------------- | -------------------------- |
| 每个下载工具固定版本并校验上游 SHA-256  | `scripts/install-tools.sh` |
| 工具只装入被忽略的 `runtime/tools/bin/` | `.gitignore`、安装脚本     |
| prek 的本地 hook 只复用 `just` recipes  | `prek.toml`                |

hook 与 `just check` 共享同一实现路径；不允许在 hook 里出现第二套检查命令。

### S5. 质量门禁与依赖审计

- `just check` 是本地唯一质量门禁聚合：justfile 语法、四类格式检查、Markdown/shell/TOML/ workflow lint、source-lines。
- 本模板没有运行时依赖，因此没有 `audit` recipe。一旦引入任何依赖（包括新的下载工具）， 必须在本文新增对应审计条目并补上
  recipe，不得静默跳过。

### S6. 下游复制合同

模板维护者规则保留在根 `AGENTS.md`，下游项目复制 `AGENTS.md.template` 后再添加项目专属
规则。下游合同不得引用维护者本机路径、兄弟仓库或本模板之外的隐含工具。

## Evolving（层 2：尚未默认晋升）

当前没有已经晋升且强制生效的 Evolving 条目。候选实践见
[`backlog.md`](./backlog.md)；启用后必须把政策移到本节、同步配置并删除 backlog 原条目。

## 变更清单

| 日期       | 变更                                           |
| ---------- | ---------------------------------------------- |
| 2026-08-24 | 初版：从 modern-\*-template 家族抽取无语言基线 |
