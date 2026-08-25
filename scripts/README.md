# scripts —— RNA-seq 分析 R 脚本

把 README 中用 R 写的内容按 RNA-seq 功能模块整理成 6 个脚本，
输入输出全部通过命令行参数自定义，方便在 Snakemake 中调用。
每个脚本运行 `Rscript scripts/xx.R --help` 可查看全部参数。

| 脚本 | 模块 | 主要输入 | 主要输出 |
|---|---|---|---|
| [01_merge_counts.R](01_merge_counts.R) | 表达矩阵构建 | HTSeq-count 输出目录 | merge.csv |
| [02_normalize.R](02_normalize.R) | 表达量标准化 | count 矩阵 + 基因长度 / GFF | rpkm.tsv, tpm.tsv |
| [03_preprocess.R](03_preprocess.R) | 差异分析前处理 | merge.csv | countdata.clean.tsv |
| [04_deseq2.R](04_deseq2.R) | 差异表达分析 | count + phenotype | results.csv, PCA/热图/MA 图, dds.rds |
| [05_deg_annotation.R](05_deg_annotation.R) | 差异基因提取与注释 | results.csv | difference.csv, all_gene.tsv, diff_gene.tsv |
| [06_enrichment.R](06_enrichment.R) | 富集分析 | diff_gene.tsv | GO/KEGG/GSEA 表格与点图 |

## 一条完整的调用链示例

```bash
Rscript scripts/01_merge_counts.R --indir output/HTseq --out results/merge.csv
Rscript scripts/02_normalize.R --count results/countdata.clean.tsv \
    --gene-len results/rn6_gene_len.tsv --out-rpkm results/rpkm.tsv --out-tpm results/tpm.tsv
Rscript scripts/03_preprocess.R --input results/merge.csv --out results/countdata.clean.tsv
Rscript scripts/04_deseq2.R --count results/countdata.clean.tsv \
    --coldata phenotype/phenotype.csv --design "~ treatment" --ref-level control \
    --outdir results/DESeq2
Rscript scripts/05_deg_annotation.R --results results/DESeq2/results.csv \
    --outdir results/DESeq2 --method orgdb --orgdb org.Rn.eg.db
Rscript scripts/06_enrichment.R --diff results/DESeq2/diff_gene.tsv \
    --orgdb org.Rn.eg.db --organism rno --outdir results/enrichment
```

## 说明

- 依赖的 R 包: 01/03 仅用 base R；02 需要 GenomicFeatures/txdbmaker（仅 `--gff` 时）；
  04 需要 DESeq2/ggplot2/pheatmap/RColorBrewer；05/06 需要 clusterProfiler/org.*.eg.db，
  用 `--method biomart` 时还需要 biomaRt（联网）。
- 02_normalize 同时支持 README 的单样本两列格式（加 `--no-header`）和
  样本矩阵格式（第一列 gene_id，每列一个样本）。
- README 中 9.1 的“删除前五行”在这里是 `--drop-first 5`；更推荐用默认的
  `--drop-pattern "^__"` 直接删除 HTSeq 总结行（它们以 `__` 开头）。
- 06 的 GSEA 部分 README 只有标题没有代码，这里按 clusterProfiler 常规用法补了一个
  可选实现（`--gsea --results results.csv`）。
