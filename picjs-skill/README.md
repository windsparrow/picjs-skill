# picjs skill

> English readers: the skill entry [`SKILL.md`](SKILL.md) and the guides in [`docs/`](docs/) are in English. This README is in Chinese.

一个 [picjs](https://github.com/pragdave/picjs) 技能包：**用法说明 + 官方文档快照 + 官方示例 + 实战示例 + 渲染/更新脚本**。picjs 运行时不在包里，首次使用时从 npm 在线安装到缓存。

picjs 是 Dave Thomas 写的约束式 SVG 绘图语言，用文本描述图形，由它计算布局。适合需要精确控制位置、配色、标注的架构图、流程图、示意图和动画。

## 目录

```
picjs-skill/
├── SKILL.md                     # 技能入口（很短，按任务路由到 docs/）
├── README.md                    # 本文件
├── package.json                 # 只有脚本；不包含运行时依赖
├── docs/                        # 按需加载的使用指南
│   ├── install.md               # skill 安装 + 运行时在线安装
│   ├── quickstart.md            # 第一张图、渲染、CLI/API
│   ├── syntax.md                # 语法与速查表
│   ├── animation.md             # 动画时间线、缓动、播放
│   ├── layout.md                # 布局、容器、可复用组件、总线走线
│   ├── centering.md             # 文字居中规则（含 CJK 修正）
│   ├── rendering.md             # 主题、背景、PNG、Markdown
│   ├── gotchas.md               # 实测坑位
│   ├── examples.md              # 示例索引
│   └── updating.md              # 版本与文档更新
├── references/                  # 官方文档快照（较大，按需读）
├── examples/
│   ├── transformer/             # 实战示例：Transformer 三张图 + 中文笔记
│   ├── gallery/                 # README 展示：流程图 + petal
│   └── upstream/                # 官方 .picjs 示例
├── scripts/
│   ├── ensure-picjs.sh          # 在线安装/检查运行时（写入缓存）
│   ├── picjs-cli.sh             # 用缓存里的 CLI 处理 Markdown
│   ├── render.mjs               # .picjs → SVG/PNG
│   ├── update-from-upstream.sh  # 从 GitHub 拉取最新文档和示例
│   └── install-skill.sh         # 软链到 <project>/.dsh/skills
└── LICENSE-picjs.md             # 上游 MIT 许可证
```

## 快速开始

在 `picjs-skill/` 目录下：

```bash
# 首次使用：从 npm 在线安装 picjs 运行时到缓存（不写进 skill 目录）
bash scripts/ensure-picjs.sh

# SVG
node scripts/render.mjs examples/upstream/architecture.picjs /tmp/architecture.svg

# PNG（需要 rsvg-convert；macOS: brew install librsvg）
node scripts/render.mjs examples/upstream/architecture.picjs /tmp/architecture.png
```

运行时默认装在 `${XDG_CACHE_HOME:-~/.cache}/picjs-skill`，skill 目录里没有 `node_modules`。如果已经装过，`bash scripts/ensure-picjs.sh --check` 会直接告诉你版本。

可用的环境变量：

| 变量 | 默认 | 作用 |
|---|---|---|
| `PICJS_BG` | `#FAF7F2` | 背景色；`none` 为透明 |
| `PICJS_WIDTH` | `1600` | PNG 宽度 |
| `PICJS_PADDING` | `0.2` | 画布留白 |
| `PICJS_NO_SOURCE` | 未设置 | 设为 `1` 时不在 SVG 里嵌入源码注释 |
| `PICJS_HOME` | `~/.cache/picjs-skill` | 运行时缓存目录 |
| `PICJS_MODULE` | 未设置 | 直接指定 `dist/picjs.js` 路径 |

如果你在 Markdown 里写图，也可以用官方 CLI：

```bash
bash scripts/picjs-cli.sh process README.md
bash scripts/picjs-cli.sh watch README.md
```

## 调用方式

这个 skill 在 `SKILL.md` 的 frontmatter 里设置了：

```yaml
disable-model-invocation: true
user-invocable: true
```

所以它**不会**被模型根据关键词自动触发，也不会出现在模型可自动加载的技能目录里。安装并重启会话后，用下面两种方式之一加载：

- 在输入框输入 `/picjs`（后面可以继续写需求）；
- 输入 `/`，在菜单里选择 **picjs**。

如果以后想恢复“根据关键词自动触发”，把 `disable-model-invocation: true` 删掉并重启即可。

## 作为 skill 安装

技能本体保留在本项目里，用软链接让 agent 发现它（在 `picjs-skill/` 目录下执行）：

```bash
bash scripts/install-skill.sh
# 默认创建 <project>/.dsh/skills/picjs -> picjs-skill
```

本项目已经创建了 `.dsh/skills/picjs` 软链；换机器或移动目录后重跑一次即可。装好后重启会话或重新加载 skills，然后输入 `/picjs` 使用。

不同 agent 的 skills 目录可能不同；`install-skill.sh` 接受一个参数：

```bash
bash scripts/install-skill.sh /path/to/skills
```

## 文字居中约定

这个 skill 默认要求图里的文字**上下左右都居中**，除非有明确理由（图例、列表、避免压线）：

- 盒内文字：交给形状的 label 自动居中。
- 多行文字：用**一个**三引号多行 label，而不是叠多个 rich label；这样 picjs 会生成 `text-anchor="middle"`，整块精确居中。
- 单行 CJK：picjs 按 0.52em/字符估宽，中文会右偏；可先用 `0.24 × 字号 × 汉字数` 估算，粗体/中英混排要再大一些，最好渲染后量一下，或直接改成多行 label。
- 图例/容器标签：用 `with .w` 左对齐，属于有意为之的例外。

[`docs/centering.md`](docs/centering.md) 有完整规则和示例；Transformer 示例就是按这个约定画的。

## 动画

picjs 的动画挂在 `@` 时间线上：`@ += 1` 前进一秒，`move` / `rotate` / `set` / `draw`
安排变化，`take` 设时长，`ease` 选缓动，`then` 串行，`@@` 跳到上一段动画结束。

静态渲染（`render.mjs` 出的 PNG/SVG）只展示 **0 时刻**，所以动效要在浏览器运行时或
playground 里看。0.4.0 有几个容易踩的点：`draw` / `nodraw` 只对线条有效（盒子要么在
目标时刻再创建，要么用 `opacity` 淡入）；`ease` 没有 `sine*`；`Label` 后面不能直接跟
变量名（用 `Label "#{name}"`）；`wait` 不是命令。

[`docs/animation.md`](docs/animation.md) 有命令表、缓动清单和常用模式。

## 更新

picjs 仍在快速迭代（当前为 0.x），`references/` 里的文档是**快照**。在 `picjs-skill/` 目录下，更新分三步：

```bash
# 1. 看最新版本，然后改 scripts/ensure-picjs.sh 里的 PICJS_VERSION
npm view @pragdave/picjs version

# 2. 安装/切换运行时
bash scripts/ensure-picjs.sh

# 3. 重新拉取文档和示例（浅克隆 GitHub main）
bash scripts/update-from-upstream.sh

# 只检查版本、不下载
bash scripts/update-from-upstream.sh --check
```

更新脚本会刷新：

- `references/*.md`（guide / language / layout / quick-reference / picjs-reference / animation / grammar / integrating / 拆解教程）
- `references/upstream-skill.md`、`upstream-skill-animation.md`（官方 skill）
- `examples/upstream/*.picjs`
- `LICENSE-picjs.md`、`references/history.md`
- `references/upstream-snapshot.md`（记录 commit、同步时间、npm 版本）

它**不会**动 `examples/transformer/` 和 `SKILL.md`。

上游信息：

- 仓库：<https://github.com/pragdave/picjs>
- 文档：<https://pragdave.github.io/picjs/>
- 在线 playground：<https://pragdave.github.io/picjs/editor/>
- npm：<https://www.npmjs.com/package/@pragdave/picjs>
- 版本 JSON：<https://registry.npmjs.org/@pragdave%2Fpicjs>

升级前建议先看 `references/history.md`。0.x 版本之间可能有语法/行为变化。

## 实战示例：Transformer

`examples/transformer/` 里有：

- `transformer.picjs` — 整体结构（Encoder/Decoder、位置编码、输出头、K/V 连线）
- `residual.picjs` — 子层内部的残差 + LayerNorm
- `attention.picjs` — 缩放点积注意力
- `notes.md` — 三张图对应的中文讲解（维度、训练/推理、常见误解）
- 对应的 `.svg` / `.png` 渲染结果

这个例子覆盖了：显式坐标布局、容器留白、跨容器连线、浅色主题、中英双语标签，以及"文字默认居中"的具体做法——盒内双语用单个多行 label，标题按渲染结果做 CJK 宽度修正，图例保持左对齐。改图时可以直接参考。

## 许可

picjs 及其文档、示例采用 MIT 许可证，版权归 Dave Thomas 所有。本 skill 中的 `references/` 与 `examples/upstream/` 来自上游仓库，保留 `LICENSE-picjs.md`。
