# Transformer 的逻辑结构 · 图解学习笔记

这份笔记用三张图，从粗到细拆开 Transformer：

1. **图 1｜整体结构**：输入怎么变成输出，Encoder 和 Decoder 怎么分工；
2. **图 2｜一个子层内部**：残差连接和 LayerNorm 到底加在哪；
3. **图 3｜注意力计算**：Q、K、V 具体在算什么。

建议按 1 → 2 → 3 的顺序看，每张图配一段说明。

---

## 0. 一句话理解 Transformer

Transformer 是一台**"编码 → 查询 → 生成"**的机器：

- **Encoder** 把输入序列读成一组带上下文的向量；
- **Decoder** 根据"已经生成的部分"，去查询 Encoder 的结果，同时看自己前面的输出，预测下一个 token；
- 让这一切成立的核心是 **self-attention（自注意力）**：任意两个位置可以直接交换信息，不需要像 RNN 那样一步一步传递。

它没有循环、没有卷积，主要就是**矩阵乘法 + softmax + 逐位置的前馈网络**。

---

## 1. 整体结构

![图 1：Transformer 整体结构](transformer.png)

*图 1：从输入 token 到下一个 token 的概率。左右两条流水线分别是 Encoder 和 Decoder；橙色箭头是两者唯一的连接。*

### 1.1 读图顺序

从下往上、先左后右：

- **输入侧**：`输入 token → Input Embedding → + 位置编码 → Encoder × N`
- **输出侧**：`已生成 token → Output Embedding → + 位置编码 → Decoder × N`
- **连接**：`Encoder 输出 →（作为 K、V）→ Decoder 的 Cross-Attention`
- **输出头**：`Decoder 输出 → Linear → Softmax → 下一个 token 的概率`

### 1.2 输入侧：Embedding + 位置编码

- **Input Embedding**：把离散 token 查表变成 `d_model` 维向量。可以理解为"每个词的身份向量"。
- **Positional Encoding（位置编码）**：attention 本身对顺序是无感的——把句子打乱，每个词看到的内容集合不变。所以必须把位置信息**加**进 embedding（原论文是相加，不是拼接），否则模型分不清"猫追狗"和"狗追猫"。
- 原论文用的是固定的正弦/余弦编码；后来的模型也常用可学习的位置向量、RoPE 等。

### 1.3 Encoder × N：把输入读懂

Encoder 由 N 个相同的层堆叠（原论文 N = 6）。每一层只有两个子层：

1. **Multi-Head Self-Attention**：每个位置和输入序列里的**所有位置**（包括自己）做注意力，所以是双向的；
2. **Add & Norm**：残差 + 层归一化；
3. **Feed Forward（FFN）**：两层线性变换 + 非线性激活，对每个位置**独立**处理；
4. **Add & Norm**。

输出仍然是"每个位置一个向量"，长度不变——**不是**压成一个固定向量。

### 1.4 Decoder × N：边看答案边生成

Decoder 也是 N 层，但每层有三个子层：

1. **Masked Self-Attention**：只能看当前位置和它之前的位置。训练时把"未来"遮住，防止偷看答案；
2. **Add & Norm**；
3. **Cross-Attention（交叉注意力）**：**Q 来自 Decoder，K 和 V 来自 Encoder 的输出**。这是 Encoder 和 Decoder 之间唯一的连接点；
4. **Add & Norm**；
5. **Feed Forward**；
6. **Add & Norm**。

注意：Decoder 的**每一层**都会用同一份 Encoder 输出做 K、V。图 1 里橙色箭头从 Encoder 顶部（最后一个 Add & Norm）引出，沿上方绕到 Decoder 左侧，再进入 Cross-Attention——这样画只是为了避免线条穿过其他方块；实际是每一层都接。

### 1.5 输出头：变成概率

- **Linear**：把 `d_model` 维映射到词表大小 `V`，得到每个 token 的 logits；
- **Softmax**：转成概率分布；
- 取概率最大的 token（或按概率采样），就是"下一个 token"。

原论文中，**输入 Embedding、输出 Embedding 和这个 Linear 共享同一套权重**（weight tying），既省参数，也让输入输出空间对齐。

### 1.6 训练与推理的区别

| | 训练 | 推理 |
|---|---|---|
| Decoder 输入 | 整段目标序列（右移一位，加起始符） | 已生成的前缀，逐个追加 |
| 并行性 | 所有位置可并行计算（靠 mask 防泄漏） | 自回归，一次一个 token |
| 典型优化 | —— | KV cache：缓存历史 K、V，避免重复计算 |

所谓"右移（shifted right）"，是指预测第 `t` 个 token 时，Decoder 的输入是第 `1..t-1` 个 token，再加上起始符。这样训练时可以用**teacher forcing**：不管模型上一秒预测对错，下一秒都喂入真实的前缀。

---

## 2. 一个子层内部：残差 + LayerNorm

![图 2：一个子层内部](residual.png)

*图 2：每个子层外面都套着"残差 + LayerNorm"，也就是图 1 里那些紫色的小方块。*

### 2.1 公式

```
y = LayerNorm(x + Sublayer(x))
```

- `Sublayer(x)` 可以是 self-attention、cross-attention 或 FFN；
- `x` 通过一条"旁路"原样加回输出，这就是**残差连接（residual connection）**；
- 相加之后再做 **LayerNorm（层归一化）**。

### 2.2 为什么需要残差

- 给梯度一条"高速公路"：反向传播时，梯度可以直接沿着 `+` 流回去，不用穿过整个子层；
- 让深层网络至少不会比"什么都不做"更差：如果子层学不到东西，模型可以退化成恒等映射；
- 原论文的 Encoder/Decoder 各有 6 层，残差是能堆深的关键。

### 2.3 为什么需要 LayerNorm

- 对**每个 token 的特征维**做归一化（减均值、除标准差），再乘可学习的缩放、加偏移；
- 和 BatchNorm 不同：LN 不依赖 batch 里的其他样本，处理变长序列更自然；
- 作用是稳定数值、让不同层的数据分布更可控，训练更稳。

> 注意顺序：原论文是 **Post-LN**（先相加，再归一化）。很多现代实现（如 GPT 系列）改成 **Pre-LN**：先 LayerNorm，再进子层，最后相加，并在最后再加一次 LN。两者都叫 Transformer，但训练稳定性不同。

### 2.4 一共有多少个 Add & Norm

- Encoder 每层 2 个 × N 层；
- Decoder 每层 3 个 × N 层；
- 原论文 N = 6，所以 Encoder 12 个、Decoder 18 个。

---

## 3. 注意力到底怎么算

![图 3：缩放点积注意力](attention.png)

*图 3：Scaled Dot-Product Attention 的五步计算。V 不参与打分，只在最后一步被加权求和。*

### 3.1 Q、K、V 的直觉

把 attention 想成"查字典"：

- **Q（Query，查询）**：我现在想找什么信息？
- **K（Key，键）**：我能提供什么信息，用来被匹配？
- **V（Value，值）**：如果匹配上了，我实际给你的内容是什么？

每个 token 都会生成自己的 Q、K、V（通过三个可学习的线性投影）。

### 3.2 五步计算

1. **MatMul：`Q · Kᵀ`**
   每个 Q 和每个 K 做点积，得到 `n × n` 的相似度矩阵。第 `(i, j)` 个元素表示"第 i 个位置有多关注第 j 个位置"。

2. **Scale：除以 `√d_k`**
   维度 `d_k` 越大，点积的方差越大，softmax 容易变得极端（几乎 one-hot），梯度会很小。除以 `√d_k` 把数值拉回合适范围。

3. **Mask（按需）**
   把不该看的位置设成 `-∞`（softmax 后权重为 0）：
   - Decoder 的 self-attention 遮住未来位置（因果 mask）；
   - 处理 padding 时遮住补齐的位置。

4. **Softmax：按行归一化**
   每一行变成和为 1 的权重分布，表示"这个位置把注意力分给哪些位置"。

5. **MatMul：`权重 · V`**
   用权重对 V 做加权求和，得到每个位置的新表示。

合起来就是：

```
Attention(Q, K, V) = softmax(QKᵀ / √d_k) · V
```

### 3.3 形状（单头，序列长度 n）

| 张量 | 形状 |
|---|---|
| Q | `n × d_k` |
| K | `n × d_k` |
| V | `n × d_v` |
| `QKᵀ`（注意力分数） | `n × n` |
| softmax 后的权重 | `n × n` |
| 输出 | `n × d_v` |

注意 `n × n` 这个矩阵：**序列越长，它越大**。这是 Transformer 长文本成本高的根本原因之一。

### 3.4 多头注意力（Multi-Head）

图 3 只画了单头。实际做法是：

1. 把 `d_model` 维切成 `h` 份，每份 `d_k = d_model / h`；
2. 每个头**独立**做一次上面的 attention；
3. 把 `h` 个头的输出拼接起来，再过一次线性层 `W^O`。

为什么要多头？不同的头可以关注不同的模式：有的看语法依赖、有的看指代、有的看局部搭配。多头不是"多层"，它们是**同一层里并行**的。

### 3.5 三种注意力别混

| 类型 | Q 来自 | K、V 来自 | 能不能看未来 |
|---|---|---|---|
| Encoder self-attention | Encoder | Encoder | 可以（双向） |
| Decoder masked self-attention | Decoder | Decoder | 不可以（因果） |
| Cross-attention | Decoder | Encoder | 可以看完整输入 |

---

## 4. 把维度串起来（原论文 base 配置）

| 超参数 | 值 |
|---|---|
| `d_model` | 512 |
| `h`（头数） | 8 |
| `d_k = d_v` | 64 |
| `d_ff` | 2048 |
| `N`（层数） | 6（Encoder、Decoder 各 6） |
| Dropout | 0.1 |

一次前向的张量变化（`B` = batch，`n` = 序列长度，`V` = 词表大小）：

| 阶段 | 形状 |
|---|---|
| token id | `B × n` |
| Embedding | `B × n × 512` |
| 每个头的 Q/K/V | `B × 8 × n × 64` |
| 注意力分数 | `B × 8 × n × n` |
| 多头拼接后 | `B × n × 512` |
| FFN 中间层 | `B × n × 2048` |
| 输出 logits | `B × n × V` |

计算量上：

- Self-attention 每层约 `O(n² · d_model)`，主要花在 `QKᵀ` 和 `权重 · V`；
- FFN 每层约 `O(n · d_model · d_ff)`；
- 序列短时 FFN 占大头，序列长时 attention 的 `n²` 项占大头。

---

## 5. 常见误解（重点）

- ❌ **"Encoder 把输入压成一个固定向量。"**
  ✅ Encoder 输出的是 `n` 个向量，长度不变；"压成一个向量"是旧式 RNN seq2seq 的做法。

- ❌ **"Cross-attention 的 Q 来自 Encoder。"**
  ✅ Q 来自 Decoder 当前表示，K、V 来自 Encoder 输出。可以记成："Decoder 发问，Encoder 提供答案。"

- ❌ **"多头 = 多层。"**
  ✅ 多头是同一层内并行多个子空间；层是串联堆叠的。

- ❌ **"位置编码是 attention 的一部分。"**
  ✅ 位置编码发生在输入侧，是加在 embedding 上的；attention 本身不含位置信息。

- ❌ **"LayerNorm 和 BatchNorm 差不多。"**
  ✅ LN 在**特征维**归一化，与 batch 无关；BN 在 batch 维归一化，对变长序列不友好。

- ❌ **"Add & Norm 是先归一化再相加。"**
  ✅ 原论文是 `LayerNorm(x + Sublayer(x))`：先相加，再归一化。

- ❌ **"Decoder 的 self-attention 能看到完整目标序列。"**
  ✅ 训练时用 mask 遮住未来位置，否则就是作弊，推理时也做不到。

---

## 6. 图里省略了什么

为了不把图画成蜘蛛网，这三张图做了这些简化：

- 多头注意力的**拆分与拼接**（图 3 只画单头）；
- **Dropout**、label smoothing、学习率 warmup 等训练细节；
- **残差的具体走线**（图 1 只画了 Add & Norm 方块，图 2 单独解释）；
- Decoder **每一层**都接 Encoder 输出（图 1 只画了一条 K/V 箭头）；
- **Pre-LN** 等现代变体（图 2 按原论文画的是 Post-LN）；
- 位置编码的具体公式（正弦/余弦）。

---

## 7. 这三张图是怎么画的

图是用 [picjs](https://pragdave.github.io/picjs/) 写的——一种"用代码描述图形、由约束自动布局"的 SVG 绘图语言。三张图的文字都按"默认居中"处理：盒内双语使用单个多行标签（`text-anchor="middle"`），标题则按渲染结果做了 CJK 宽度修正。三张图的源码就在本目录；渲染脚本在 skill 的 `../../scripts/` 下，改完可以重新渲染：

| 文件 | 内容 |
|---|---|
| [transformer.picjs](transformer.picjs) | 图 1，整体结构 |
| [residual.picjs](residual.picjs) | 图 2，子层内部的残差 + LayerNorm |
| [attention.picjs](attention.picjs) | 图 3，缩放点积注意力 |
| [render.mjs](../../scripts/render.mjs) | 把 `.picjs` 渲染成 SVG/PNG 的脚本 |

重新生成：

在 `examples/transformer/` 目录下执行（默认背景就是纸张色，PNG 需要 `rsvg-convert`）：

```bash
PICJS_WIDTH=1800 node ../../scripts/render.mjs transformer.picjs transformer.png
PICJS_WIDTH=1600 node ../../scripts/render.mjs residual.picjs residual.png
PICJS_WIDTH=800  node ../../scripts/render.mjs attention.picjs attention.png
```

只想要矢量图时，把输出后缀换成 `.svg` 即可。

---

## 8. 怎么用这三张图复习

1. **合上笔记，自己画一遍图 1 的骨架**：两条流水线、每层子层的顺序、一个输出头。能画出来，说明结构记住了。
2. **对着图 2 问自己**：为什么是 `x + Sublayer(x)`，而不是 `Sublayer(x + ...)`？LN 和 BN 差在哪？
3. **对着图 3 手算一个小例子**：`n = 2`、`d_k = 2`，写出 `QKᵀ`、除以 `√2`、softmax、再乘 `V`。算一遍比看十遍有用。
4. **最后回到图 1**：把"训练时整段并行、推理时逐个生成"和 mask、KV cache 对应起来。

参考：Vaswani et al., *Attention Is All You Need*, NeurIPS 2017。
