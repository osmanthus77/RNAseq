详细版流程为[flow.md](flow.md)

根据[参考流程](https://github.com/eternal-bug/RNA)改写为snakemake

```shell
#下载pipeline
git clone
cd 

# 安装环境
conda env create --file envs/envs.yaml
conda activate --stack RNAseq

# 下载ref
bash ref_download.sh
# 下载sortmerna数据库，可选
bash sortmerna_db.sh

# 运行
snakemake -n   #先dry run测试pipeline
snakemake --core 16 -j 2 #正式运行
snakemake --core 16 -j 4 --rerun-incomplete #异常中断后重跑
```
